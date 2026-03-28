#!/usr/bin/env bash
# Merge a kernel fragment into an existing defconfig under kernel/common (ACK).
set -euo pipefail

COMMON_DIR="${1:?Usage: $0 <path/to/kernel/common> <fragment file> [defconfig-relative-path]}"
FRAGMENT="${2:?fragment file required}"
DEFCONFIG_REL="${3:-arch/arm64/configs/gki_defconfig}"
DEFCONFIG="${COMMON_DIR}/${DEFCONFIG_REL}"

if [ ! -d "$COMMON_DIR" ]; then
  echo "Not a directory: $COMMON_DIR" >&2
  exit 1
fi
if [ ! -f "$FRAGMENT" ]; then
  echo "Fragment not found: $FRAGMENT" >&2
  exit 1
fi
if [ ! -f "$DEFCONFIG" ]; then
  echo "Defconfig not found: $DEFCONFIG — set the third argument to your tree's GKI defconfig path." >&2
  exit 1
fi

export ARCH=arm64
export SRCARCH=arm64
cd "$COMMON_DIR"

MERGE="./scripts/kconfig/merge_config.sh"
if [ ! -f "$MERGE" ]; then
  echo "Missing $MERGE (wrong tree or incomplete sync?)" >&2
  exit 1
fi

cp "$DEFCONFIG" .config
# -m: merge; produce updated .config
bash "$MERGE" -m .config "$FRAGMENT"
make ARCH=arm64 olddefconfig
cp .config "$DEFCONFIG"
echo "Updated $DEFCONFIG from $FRAGMENT"
