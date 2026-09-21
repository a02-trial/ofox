#
# Copyright (C) 2023 The Android Open Source Project
# Copyright (C) 2023 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Branch fox_11.0 (dan ke atas) pakai prefix "twrp_", bukan "omni_".
# Lunch: lunch twrp_a02-eng

# Inherit some common stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit common TWRP/OrangeFox product config (fox_11.0+ pakai vendor/twrp;
# fallback ke vendor/omni buat manifest lama). Di-guard biar gak fatal kalau
# salah satunya gak ada.
ifneq ($(wildcard vendor/twrp/config/common.mk),)
$(call inherit-product, vendor/twrp/config/common.mk)
else ifneq ($(wildcard vendor/omni/config/common.mk),)
$(call inherit-product, vendor/omni/config/common.mk)
endif

# Inherit from a02 device
$(call inherit-product, device/samsung/a02/device.mk)

PRODUCT_DEVICE := a02
PRODUCT_NAME := twrp_a02
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A022F
PRODUCT_MANUFACTURER := samsung
