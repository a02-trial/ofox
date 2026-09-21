#!/bin/bash
#
# OrangeFox build vars - Samsung Galaxy A02 (a02 / SM-A022F, MT6739, arm32)
# Referensi: orangefox_build_vars.txt (vendor/recovery) + wiki.orangefox.tech/en/dev/building
#
# Ini di-source otomatis sama build/envsetup.sh, dan juga di-source manual
# oleh ulti.sh / z. Flag baru cuma aktif kalau FOX_BUILD_DEVICE=a02.

FDEVICE="a02"

fox_get_target_device() {
    local chkdev
    chkdev=$(echo "$BASH_SOURCE" | grep -w $FDEVICE)
    if [ -n "$chkdev" ]; then
        FOX_BUILD_DEVICE="$FDEVICE"
    else
        chkdev=$(set | grep BASH_ARGV | grep -w $FDEVICE)
        [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
    fi
}

if [ -z "$1" ] && [ -z "$FOX_BUILD_DEVICE" ]; then
    fox_get_target_device
fi

if [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
    export ALLOW_MISSING_DEPENDENCIES=true
    export LC_ALL="C"

    # --- Arsitektur & kernel -------------------------------------------
    # Default OrangeFox itu arm64; A02 userspace + kernel-nya arm32 (CPU_V7)
    export TARGET_ARCH=arm
    # Kernel prebuilt (bukan build dari source) -> hindari error "NO KERNEL CONFIG"
    export OF_FORCE_PREBUILT_KERNEL=1

    # --- Identitas -----------------------------------------------------
    export FOX_BUILD_TYPE="Unofficial"
    export FOX_MAINTAINER_PATCH_VERSION=1
    export OF_MAINTAINER="rdbckp"
    export TARGET_DEVICE_ALT="a02, SM-A022F, a022f, a022"

    # --- Samsung -------------------------------------------------------
    # JANGAN set FOX_NO_SAMSUNG_SPECIAL: flag itu MEMATIKAN penambahan tail
    # "SEANDROIDENFORCE" + pembuatan tar Odin. Tanpa itu Odin nolak imagenya.
    # (Biarin default = 0, supaya output-nya dapet recovery .tar buat Odin.)

    # --- Layar: 720x1600 (20:9), punch-hole -----------------------------
    # OF_SCREEN_H = rasio_tinggi * 120 (bukan tinggi pixel) -> 20 * 120 = 2400
    export OF_SCREEN_H=2400
    export OF_STATUS_H=84
    export OF_STATUS_INDENT_LEFT=48
    export OF_STATUS_INDENT_RIGHT=48
    export OF_HIDE_NOTCH=1
    export OF_CLOCK_POS=1

    # --- Diet mode (partisi recovery ~24MB) ----------------------------
    export FOX_REMOVE_BASH=1
    export FOX_EXCLUDE_NANO_EDITOR=1
    export FOX_REMOVE_AAPT=1
    export FOX_DELETE_AROMAFM=1
    export FOX_DELETE_MAGISK_ADDON=1
    export OF_FLASHLIGHT_ENABLE=0

    # --- Perilaku ------------------------------------------------------
    export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
    export OF_FORCE_USE_RECOVERY_FSTAB=1

    # Ramdisk pakai gzip (default). JANGAN aktifin OF_USE_LZMA_COMPRESSION:
    # kernel prebuilt cuma punya CONFIG_RD_GZIP.
fi
