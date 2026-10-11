#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from mumba device
$(call inherit-product, device/motorola/mumba/device.mk)

# Inherit some common VoltageOS stuff.
$(call inherit-product, vendor/voltage/config/common_full_phone.mk)

PRODUCT_NAME := voltage_mumba
PRODUCT_DEVICE := mumba
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := Motorola
PRODUCT_MODEL := G57 Power

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="mumba_g-user 16 W1WAAS36M.48-12-ST12.1 c557f6 release-keys" \
    BuildFingerprint=motorola/mumba_g/mumba:16/W1WAAS36M.48-12-ST12.1/c557f6:user/release-keys \
    DeviceName=mumba \
    DeviceProduct=mumba \
    SystemDevice=mumba \
    SystemName=mumba

# VoltageOS flags
VOLTAGE_BUILD_TYPE := UNOFFICIAL
TARGET_BOOT_ANIMATION_RES := 1080
TARGET_ENABLE_BLUR := true
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_FACE_UNLOCK_SUPPORTED := true
