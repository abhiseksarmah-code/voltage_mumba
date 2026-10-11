#!/usr/bin/env bash
#
# One-shot VoltageOS 17 build for Motorola G57 Power (mumba).
#
# Run on Ubuntu 22.04 / 24.04 (x86_64) with >= 32 GB RAM (or 16 GB + 32 GB swap)
# and >= 400 GB free SSD space.
#
#   curl -fsSL https://raw.githubusercontent.com/abhiseksarmah-code/voltage_mumba/main/voltage/build.sh | bash
#
# Environment overrides:
#   SRC_DIR   where the source tree lives      (default: ~/voltage)
#   VARIANT   user | userdebug | eng           (default: userdebug)
#   JOBS      parallel sync/build jobs         (default: nproc)
#   SKIP_DEPS set to 1 to skip apt installs
#
set -euo pipefail

SRC_DIR="${SRC_DIR:-$HOME/voltage}"
VARIANT="${VARIANT:-userdebug}"
JOBS="${JOBS:-$(nproc)}"
MANIFEST_URL="https://raw.githubusercontent.com/abhiseksarmah-code/voltage_mumba/main/voltage/mumba.xml"

log() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }

# ---- 1. Host dependencies -------------------------------------------------
if [[ "${SKIP_DEPS:-0}" != "1" ]]; then
  log "Installing build dependencies"
  sudo apt-get update
  sudo apt-get install -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs \
    gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool \
    libsdl1.2-dev libssl-dev libxml2 libxml2-utils lz4 lzop pngcrush rsync \
    schedtool squashfs-tools xsltproc zip zlib1g-dev python3 python-is-python3 \
    protobuf-compiler python3-protobuf
  git lfs install
fi

# ---- 2. repo tool ---------------------------------------------------------
if ! command -v repo >/dev/null; then
  log "Installing repo"
  mkdir -p "$HOME/bin"
  curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/bin/repo"
  chmod a+x "$HOME/bin/repo"
  export PATH="$HOME/bin:$PATH"
fi

git config --global user.name  >/dev/null || git config --global user.name  "VoltageOS Builder"
git config --global user.email >/dev/null || git config --global user.email "builder@localhost"

# ---- 3. Source ------------------------------------------------------------
mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

if [[ ! -d .repo ]]; then
  log "Initialising VoltageOS 17 manifest"
  repo init -u https://github.com/VoltageOS/manifest.git -b 17 --git-lfs \
            --depth=1 --no-clone-bundle
fi

log "Adding mumba local manifest"
mkdir -p .repo/local_manifests
curl -fsSL "$MANIFEST_URL" -o .repo/local_manifests/mumba.xml

log "Syncing source (this is ~100+ GB and takes a while)"
repo sync -c -j"$JOBS" --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune

# ---- 4. Build -------------------------------------------------------------
export USE_CCACHE=1
export CCACHE_EXEC="$(command -v ccache)"
ccache -M 50G >/dev/null || true

log "Building voltage_mumba ($VARIANT)"
set +u
source build/envsetup.sh
brunch mumba "$VARIANT"
set -u

log "Done. Output:"
ls -lh out/target/product/mumba/VoltageOS-*.zip 2>/dev/null || true
ls -lh out/target/product/mumba/{boot,vendor_boot,init_boot,dtbo,recovery}.img 2>/dev/null || true
