#!/bin/bash
# ============================================================
# ULTI.SH - Build OrangeFox Recovery, Samsung Galaxy A02 (SM-A022F, MT6739)
# Repo ini = device tree recovery (dipasang ke device/samsung/a02).
# Idempotent: aman dijalanin ulang (bagian yang udah beres bakal di-skip).
#
# Env opsional:
#   FOX_BRANCH=12.1        branch OrangeFox (default 12.1)
#   FOX_DIR=/path          lokasi source OrangeFox (default ~/fox_<branch>)
#   SKIP_DEPS=1            skip apt install / setup env
#   FORCE_SYNC=1           paksa sync ulang source OrangeFox
#   CLEAN=1                hapus folder out/ sebelum build
# ============================================================
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOX_BRANCH="${FOX_BRANCH:-12.1}"
FOX_DIR="${FOX_DIR:-/tmp/fox_${FOX_BRANCH}}"
DEVICE="a02"
DEVICE_PATH="device/samsung/a02"
OUT_DIR="$REPO_DIR/out"
export PATH="$HOME/bin:$PATH"

echo "== Repo tree : $REPO_DIR"
echo "== Fox dir   : $FOX_DIR  (branch $FOX_BRANCH)"

# ============================================================
# BAGIAN 0: SETUP ENVIRONMENT
# ============================================================
if [ -z "$SKIP_DEPS" ]; then
  sudo apt-get update
  for pkg in git aria2 curl rsync python3 python3-pip zip unzip bc bison build-essential ccache flex g++-multilib gcc-multilib gnupg gperf lib32z1-dev libssl-dev libxml2-utils lzop pngcrush squashfs-tools xsltproc zlib1g-dev liblz4-tool libncurses5 libtinfo5 libncurses6 libtinfo6 openjdk-8-jdk; do
    sudo apt-get install -y "$pkg" >/dev/null 2>&1 && echo "ok   $pkg" || echo "SKIP $pkg (gak ada di distro ini)"
  done

  # Script setup resmi OrangeFox (repo tool, dependensi build)
  if [ ! -d "$HOME/fox_scripts" ]; then
    git clone --depth 1 https://gitlab.com/OrangeFox/misc/scripts "$HOME/fox_scripts"
  fi
  (cd "$HOME/fox_scripts" && sudo bash setup/android_build_env.sh) \
    || echo "WARN: android_build_env.sh gagal - lanjut, pakai paket apt di atas"
fi

git config --global user.name  >/dev/null 2>&1 || git config --global user.name  "ofox-builder"
git config --global user.email >/dev/null 2>&1 || git config --global user.email "ofox-builder@localhost"
git config --global color.ui true

if ! command -v repo >/dev/null 2>&1; then
  mkdir -p "$HOME/bin"
  curl -s https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/bin/repo"
  chmod a+x "$HOME/bin/repo"
fi

# ============================================================
# BAGIAN 1: SYNC SOURCE ORANGEFOX (skip kalau udah ada)
# Paksa ulang: FORCE_SYNC=1 bash ulti.sh
# ============================================================
if [ ! -f "$FOX_DIR/build/envsetup.sh" ] || [ -n "$FORCE_SYNC" ]; then
  mkdir -p "$HOME/OrangeFox_sync"
  cd "$HOME/OrangeFox_sync"
  [ -d sync ] || git clone --depth 1 https://gitlab.com/OrangeFox/sync.git
  cd sync
  ./orangefox_sync.sh --branch "$FOX_BRANCH" --path "$FOX_DIR"
  [ -f "$FOX_DIR/build/envsetup.sh" ] || { echo "ERROR: sync selesai tapi build/envsetup.sh gak ada di $FOX_DIR"; exit 1; }
else
  echo "Source OrangeFox udah ada - skip sync (paksa: FORCE_SYNC=1 bash ulti.sh)"
fi

# ============================================================
# BAGIAN 2: PASANG DEVICE TREE (repo ini -> device/samsung/a02)
# ============================================================
for f in prebuilt/Image prebuilt/dtb/dtb.dtb prebuilt/dtbo BoardConfig.mk twrp_a02.mk vendorsetup.sh; do
  [ -f "$REPO_DIR/$f" ] || { echo "ERROR: $f gak ada di tree"; exit 1; }
done

mkdir -p "$FOX_DIR/$DEVICE_PATH"
rsync -a --delete \
  --exclude '.git' --exclude '.github' --exclude '_old' --exclude 'out' \
  --exclude 'ulti.sh' --exclude 'z' --exclude 'note.sh' --exclude 'fixlog.sh' \
  --exclude 'README.md' --exclude '.gitignore' \
  "$REPO_DIR/" "$FOX_DIR/$DEVICE_PATH/"
echo "Device tree terpasang di $FOX_DIR/$DEVICE_PATH"

# ============================================================
# BAGIAN 3: FIX AD-HOC (fixlog.sh) - di-append tiap ketemu fix baru
# ============================================================
cd "$FOX_DIR"
if [ -f "$REPO_DIR/fixlog.sh" ]; then
  # shellcheck disable=SC1091
  source "$REPO_DIR/fixlog.sh"
fi

# ============================================================
# BAGIAN 4: BUILD
# ============================================================
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_DEVICE="$DEVICE"
export LC_ALL="C"
if command -v ccache >/dev/null 2>&1; then
  export USE_CCACHE=1
  export CCACHE_EXEC="$(command -v ccache)"
fi
[ -n "$CLEAN" ] && rm -rf "$FOX_DIR/out"

# envsetup/lunch ngasih return code non-zero di kasus tertentu -> jangan set -e di sini
set +e
source build/envsetup.sh
source "$DEVICE_PATH/vendorsetup.sh"
lunch "twrp_${DEVICE}-eng"
LUNCH_RC=$?
set -e
[ $LUNCH_RC -eq 0 ] || { echo "ERROR: lunch twrp_${DEVICE}-eng gagal"; exit 1; }

mka adbd recoveryimage

# ============================================================
# BAGIAN 5: HASIL
# ============================================================
PRODUCT_OUT="$FOX_DIR/out/target/product/$DEVICE"
mkdir -p "$OUT_DIR"
cp -v "$PRODUCT_OUT/recovery.img" "$OUT_DIR/" 2>/dev/null || true
cp -v "$PRODUCT_OUT"/OrangeFox* "$OUT_DIR/" 2>/dev/null || true
cp -v "$PRODUCT_OUT"/*.tar "$OUT_DIR/" 2>/dev/null || true

LIMIT=$(grep -oP 'BOARD_RECOVERYIMAGE_PARTITION_SIZE\s*:=\s*\K[0-9]+' "$REPO_DIR/BoardConfig.mk" | head -1)
if [ -f "$PRODUCT_OUT/recovery.img" ] && [ -n "$LIMIT" ]; then
  SIZE=$(stat -c %s "$PRODUCT_OUT/recovery.img")
  echo "== recovery.img = $SIZE byte, batas partisi = $LIMIT byte"
  if [ "$SIZE" -gt "$LIMIT" ]; then
    echo "!! MELEBIHI partisi. Kurangi isi ramdisk (flag FOX_* diet di vendorsetup.sh)"
    echo "!! atau cek ukuran partisi recovery asli: blockdev --getsize64 /dev/block/by-name/recovery"
  fi
fi
echo "== SELESAI. Hasil ada di: $OUT_DIR"
ls -la "$OUT_DIR"
