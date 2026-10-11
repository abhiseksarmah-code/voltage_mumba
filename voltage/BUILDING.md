# VoltageOS 17 for Motorola G57 Power (mumba)

This repo is the `mumba` device tree from [moto-elysia](https://github.com/moto-elysia/android_device_motorola_mumba)
(full history and authorship preserved), ported from CloverAOSP to **VoltageOS 17** (Android 17).

## What changed in the port

| File | Change |
| --- | --- |
| `clover_mumba.mk` → `voltage_mumba.mk` | Inherits `vendor/voltage/config/common_full_phone.mk`, product `voltage_mumba`, Voltage flags |
| `AndroidProducts.mk` | Points at `voltage_mumba.mk` |
| `BoardConfig.mk` | `vendor/voltage/...BoardConfigReservedSize.mk`, `device/voltage/sepolicy/libperfmgr` |
| `device.mk`, `Android.bp` | Power HAL namespace → `hardware/voltage/interfaces/power-libperfmgr` |
| `overlay-clover` → `overlay-voltage` | Dropped `lineage-sdk` overlays (VoltageOS 17 has no lineage-sdk); kept Settings + Aperture |

Everything else (kernel, blobs, sepolicy, HALs) is unchanged from upstream.

## Requirements

- Ubuntu 22.04 or 24.04, x86_64
- 32 GB RAM or more (16 GB works with 32 GB swap, but slowly)
- 400 GB or more free **SSD** space
- A fast, stable connection (the sync is 100+ GB)

A cloud VM works well. Something like 16 vCPU / 64 GB RAM / 500 GB SSD builds in about 2–3 hours, and you only pay while it runs.

## Build

```bash
curl -fsSL https://raw.githubusercontent.com/abhiseksarmah-code/voltage_mumba/main/voltage/build.sh | bash
```

Options (set as environment variables before the command):

- `SRC_DIR=~/voltage`: source location
- `VARIANT=userdebug`: `user`, `userdebug` or `eng`
- `SKIP_DEPS=1`: skip the apt install

Manual equivalent:

```bash
repo init -u https://github.com/VoltageOS/manifest.git -b 17 --git-lfs --depth=1
mkdir -p .repo/local_manifests
curl -fsSL https://raw.githubusercontent.com/abhiseksarmah-code/voltage_mumba/main/voltage/mumba.xml \
     -o .repo/local_manifests/mumba.xml
repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
brunch mumba userdebug
```

Output: `out/target/product/mumba/VoltageOS-*.zip`, plus `boot`, `init_boot`, `vendor_boot`, `dtbo` and `recovery` images.

## Flashing

> Unlocked bootloader required. This wipes data. Back up first.
> The phone should be on the latest stock Android 16 firmware before the first flash.

```bash
adb reboot bootloader
fastboot flash boot_a        boot.img        && fastboot flash boot_b        boot.img
fastboot flash init_boot_a   init_boot.img   && fastboot flash init_boot_b   init_boot.img
fastboot flash vendor_boot_a vendor_boot.img && fastboot flash vendor_boot_b vendor_boot.img
fastboot flash dtbo_a        dtbo.img        && fastboot flash dtbo_b        dtbo.img
fastboot flash recovery_a    recovery.img    && fastboot flash recovery_b    recovery.img
fastboot reboot recovery
```

In recovery: **Factory reset → Format data**, then **Apply update → Apply from ADB**:

```bash
adb sideload VoltageOS-*.zip
```

Reboot.

## Credits

Device tree, kernel, blobs and hardware: [moto-elysia](https://github.com/moto-elysia) (HoShinoKaw, xrenopnn and contributors).
ROM: [VoltageOS](https://github.com/VoltageOS).
