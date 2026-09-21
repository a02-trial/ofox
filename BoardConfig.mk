#
# Copyright (C) 2023 The Android Open Source Project
# Copyright (C) 2023 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a02

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Architecture
TARGET_ARCH                  := arm
TARGET_ARCH_VARIANT          := armv7-a-neon
TARGET_CPU_ABI               := armeabi-v7a
TARGET_CPU_ABI2              := armeabi
TARGET_CPU_VARIANT           := generic
TARGET_CPU_VARIANT_RUNTIME   := cortex-a53

# Platform
BOARD_VENDOR                 := samsung
TARGET_SOC                   := k39tv1_bsp_titan_hamster
TARGET_BOOTLOADER_BOARD_NAME := k39tv1_bsp_titan_hamster
TARGET_BOARD_PLATFORM        := mt6739
TARGET_BOARD_PLATFORM_GPU    := powervr
TARGET_USES_64_BIT_BINDER    := true

# Kernel
BOARD_KERNEL_IMAGE_NAME      := Image
TARGET_PREBUILT_KERNEL       := $(DEVICE_PATH)/prebuilt/Image
BOARD_PREBUILT_DTBIMAGE      := $(DEVICE_PATH)/prebuilt/dtb/dtb.dtb
BOARD_PREBUILT_DTBOIMAGE     := $(DEVICE_PATH)/prebuilt/dtbo
BOARD_INCLUDE_RECOVERY_DTBO  := true
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_KERNEL_BASE            := 0x40000000
BOARD_KERNEL_PAGESIZE        := 2048
BOARD_KERNEL_OFFSET          := 0x00008000
BOARD_RAMDISK_OFFSET         := 0x05000000
BOARD_KERNEL_TAGS_OFFSET     := 0x04000000
BOARD_DTB_OFFSET             := 0x04000000
BOARD_KERNEL_CMDLINE         := androidboot.hardware=mt6739
BOARD_MKBOOTIMG_ARGS := \
    --kernel_offset  $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset    $(BOARD_KERNEL_TAGS_OFFSET) \
    --header_version $(BOARD_BOOTIMG_HEADER_VERSION) \
    --board          SRPTK19C000SA \
    --dtb            $(BOARD_PREBUILT_DTBIMAGE) \
    --dtb_offset     $(BOARD_DTB_OFFSET)

# Partitions
BOARD_FLASH_BLOCK_SIZE               := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE       := 25165824
BOARD_RECOVERYIMAGE_PARTITION_SIZE   := 25165824
BOARD_HAS_LARGE_FILESYSTEM           := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE     := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE   := ext4
TARGET_COPY_OUT_VENDOR               := vendor

# Dynamic Partitions
BOARD_SUPER_PARTITION_SIZE              := 4831838208
BOARD_SUPER_PARTITION_GROUPS           := samsung_dynamic_partitions
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE  := 4068474880
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product odm
BOARD_USES_METADATA_PARTITION          := true

# System as root
BOARD_ROOT_EXTRA_FOLDERS := cache efs optics prism omr

# Recovery
TARGET_USERIMAGES_USE_EXT4  := true
TARGET_USERIMAGES_USE_F2FS  := true
TARGET_RECOVERY_FSTAB       := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# Security patch
PLATFORM_VERSION         := 11
PLATFORM_SECURITY_PATCH  := 2025-11-05
VENDOR_SECURITY_PATCH    := 2025-11-05

# Verified Boot
# AVB dimatiin buat recovery: image gak perlu footer AVB (test key), dan di
# Samsung ada tambahan tail SEANDROIDENFORCE. Device wajib vbmeta-disabled
# (flash vbmeta_disabled.tar lewat Odin) biar recovery custom bisa boot.
BOARD_AVB_ENABLE := false

# Crypto - disabled untuk hemat size (sama seperti a01core)
TW_INCLUDE_CRYPTO              := false
TW_INCLUDE_CRYPTO_FBE          := false
TW_INCLUDE_FBE_METADATA_DECRYPT := false

# TWRP Flags
RECOVERY_SDCARD_ON_DATA          := true
TARGET_RECOVERY_PIXEL_FORMAT     := "BGRA_8888"
TARGET_USES_MKE2FS               := true
BOARD_SUPPRESS_SECURE_ERASE      := true
TW_THEME                         := portrait_hdpi
TW_BRIGHTNESS_PATH               := "/sys/class/backlight/panel/brightness"
TW_MAX_BRIGHTNESS                := 255
TW_DEFAULT_BRIGHTNESS            := 100
TW_Y_OFFSET                      := 84
TW_H_OFFSET                      := -84
TW_HAS_DOWNLOAD_MODE             := true
TW_NO_LEGACY_PROPS               := true
TW_NO_BIND_SYSTEM                := true
TW_NO_REBOOT_BOOTLOADER          := true
TW_EXCLUDE_DEFAULT_USB_INIT      := true
TW_INTERNAL_STORAGE_PATH         := "/data/media/0"
TW_INTERNAL_STORAGE_MOUNT_POINT  := "data"
TW_EXTERNAL_STORAGE_PATH         := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT  := "external_sd"
TW_INPUT_BLACKLIST               := "hbtp_vm"
TW_SUPPORT_INPUT_1_2             := true
TW_FILTER_TOUCH_EVENTS           := true
TW_EXCLUDE_APEX                  := true
TW_EXCLUDE_PYTHON                := true
TW_EXCLUDE_NANO                  := true
TW_EXCLUDE_TZDATA                := true
TW_EXCLUDE_LPDUMP                := true
TW_EXCLUDE_TWRPAPP               := true
TW_INCLUDE_FUSE_EXFAT            := true
TW_INCLUDE_FUSE_NTFS             := true
TW_INCLUDE_NTFS_3G               := true
TW_USE_TOOLBOX                   := true
TW_USE_NEW_MINADBD               := true

# ============================================================
# ORANGEFOX
# Semua flag FOX_* / OF_* ada di vendorsetup.sh (di-export), bukan di sini,
# karena banyak yang dibaca script shell build OrangeFox, bukan cuma Makefile.
#
# Ramdisk WAJIB gzip (default). JANGAN aktifin OF_USE_LZMA_COMPRESSION /
# BOARD_RAMDISK_USE_LZMA: .config kernel prebuilt cuma punya CONFIG_RD_GZIP=y
# (CONFIG_KERNEL_LZMA=y itu buat kompresi image kernel-nya sendiri, bukan
# initramfs) -> ramdisk LZMA = kernel gak bisa unpack = bootloop.
# ============================================================
