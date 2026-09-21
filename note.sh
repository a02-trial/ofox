#!/bin/bash
# Jalanin: bash note.sh
# Nyetak briefing singkat buat di-paste ke AI/asisten baru biar dia
# langsung paham konteks proyek ini tanpa perlu dijelasin ulang dari nol.
cat << 'EOF'
Build ORANGEFOX RECOVERY buat Samsung Galaxy A02 (SM-A022F, MT6739, arm32,
Android 11 stock, dynamic partitions/super, non-A/B, ada partisi recovery
sendiri ~24MB). Build di GitHub Actions (atau Codespaces). Repo ini ITU
SENDIRI device tree recovery-nya (dipasang ke device/samsung/a02 di source
OrangeFox). Kernel = prebuilt di prebuilt/Image (sebenernya zImage arm32,
Linux 4.14.186 hasil build sendiri; .config: CONFIG_RD_GZIP=y SAJA, jadi
ramdisk WAJIB gzip - JANGAN aktifin LZMA/LZ4). prebuilt/dtb/dtb.dtb itu
container DT-table (magic d7b7ab1e) hasil ekstrak dari image stock - memang
begitu, jangan "dibenerin" jadi DTB polos.

BEDA DARI PROYEK LINEAGEOS A02: gak butuh vendor blob (vendor/samsung/a02
Android.bp) sama sekali. Jadi whack-a-mole bentrok modul di sana gak berlaku.

FILE-FILE PENTING (root repo):
- ulti.sh        = setup env + sync OrangeFox (orangefox_sync.sh --branch 12.1)
                   + pasang tree ke device/samsung/a02 + fixlog.sh + build
                   (lunch twrp_a02-eng && mka adbd recoveryimage) + copy hasil ke out/
- z              = rebuild cepat (rsync tree -> source, lunch, mka)
- fixlog.sh      = catetan fix ad-hoc, di-APPEND tiap ketemu fix baru
                   (sisipin SEBELUM baris "=== APPEND-FIX-DI-ATAS-BARIS-INI ===")
- vendorsetup.sh = SEMUA flag FOX_* / OF_* (di-export). Bukan di BoardConfig.mk.
- BoardConfig.mk / twrp_a02.mk / device.mk / AndroidProducts.mk = tree TWRP
- recovery/root/ = rc, fstab, twrp.flags, ueventd, multidisabler
- .github/workflows/build.yml = workflow manual "OrangeFox Build"
- _old/          = BoardConfig lama (cuma arsip, gak ikut build)

ATURAN PENTING (hasil audit tree):
- Prefix product HARUS twrp_ (fox_12.1+), bukan omni_.
- JANGAN set FOX_NO_SAMSUNG_SPECIAL (itu matiin SEANDROIDENFORCE + tar Odin).
- JANGAN set FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER (butuh patch Makefile, obsolet).
- JANGAN set FOX_USE_SPECIFIC_MAGISK_ZIP ke nilai kosong/0 (dianggap path file).
- OF_SCREEN_H = rasio_tinggi*120 -> 720x1600 (20:9) = 2400, bukan 1600.
- TARGET_ARCH=arm + OF_FORCE_PREBUILT_KERNEL=1 harus di-export.
- BOARD_AVB_ENABLE := false; device wajib vbmeta-disabled.

ALUR:
1. bash ulti.sh   (atau jalanin workflow "OrangeFox Build" di tab Actions)
2. Kalau error baru: fix di ~/fox_12.1, VERIFIKASI, lalu APPEND ke fixlog.sh
   (atau benerin langsung file tree-nya kalau itu masalah tree).
3. Rebuild berikutnya cukup: ./z
4. Hasil: out/ (recovery.img, OrangeFox-*.zip, .tar buat Odin).

FLASH: Odin mode AP, recovery .tar; vbmeta_disabled.tar juga; uncheck Auto Reboot;
abis flash langsung tahan Vol Up + Power buat masuk recovery. Format data
(yes), lalu jalanin multidisabler dari terminal Fox.

STATUS SEKARANG: tree udah diaudit statis & dirapiin, BELUM PERNAH di-build.
Yang belum terverifikasi: ukuran image vs partisi 24MB (25165824 - cek asli:
blockdev --getsize64 /dev/block/by-name/recovery; BoardConfigX lama pernah
nulis 31252480), USB/MTP di recovery (init.recovery.usb.rc), touch (tsp),
decrypt /data (TW_INCLUDE_CRYPTO sengaja false -> /data gak ke-decrypt).
Next: jalanin build, lihat error pertama, fix satu-satu.
EOF
