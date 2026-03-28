#!/usr/bin/env bash
# Copy SukiSU-Ultra kernel driver into ACK drivers/kernelsu and wire drivers/Kconfig + drivers/Makefile.
set -euo pipefail

COMMON_DIR="${1:?Usage: $0 <path/to/kernel/common> [SukiSU-Ultra git ref]}"
SUKISU_REF="${2:-main}"
WORKDIR="${SUKISU_WORKDIR:-/tmp/SukiSU-Ultra-src}"

if [ ! -d "$COMMON_DIR/drivers" ]; then
  echo "No drivers/ under $COMMON_DIR — not a kernel tree?" >&2
  exit 1
fi

rm -rf "$WORKDIR"
git clone https://github.com/SukiSU-Ultra/SukiSU-Ultra.git "$WORKDIR"
git -C "$WORKDIR" checkout "$SUKISU_REF"

rm -rf "${COMMON_DIR}/drivers/kernelsu"
mkdir -p "${COMMON_DIR}/drivers/kernelsu"
cp -a "${WORKDIR}/kernel/." "${COMMON_DIR}/drivers/kernelsu/"

KCONFIG="${COMMON_DIR}/drivers/Kconfig"
if ! grep -qF 'source "drivers/kernelsu/Kconfig"' "$KCONFIG"; then
  printf '\nsource "drivers/kernelsu/Kconfig"\n' >> "$KCONFIG"
fi

MAKEFILE="${COMMON_DIR}/drivers/Makefile"
if ! grep -qF 'obj-$(CONFIG_KSU) += kernelsu/' "$MAKEFILE"; then
  printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> "$MAKEFILE"
fi

echo "SukiSU driver installed under drivers/kernelsu/ (ref: $SUKISU_REF)"
