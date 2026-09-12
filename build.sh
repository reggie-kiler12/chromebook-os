#!/bin/bash
set -e

echo "================================"
echo " Chromebook OS Builder"
echo " ARM64 Windows-style OS project"
echo "================================"

mkdir -p build rootfs

echo "[1/4] Checking architecture..."
uname -m

echo "[2/4] Preparing build directories..."

mkdir -p rootfs/{bin,etc,home,usr/bin,var,tmp}

echo "[3/4] Creating project information..."

cat > rootfs/etc/os-release <<EOF
NAME="Chromebook OS"
ID=chromebook-os
VERSION="0.1"
ARCH="arm64"
PRETTY_NAME="Chromebook OS 0.1"
EOF

echo "[4/4] Build preparation complete."

tar -czf build/chromebook-os-rootfs.tar.gz rootfs

echo
echo "================================"
echo "Build complete!"
echo "Output:"
echo "build/chromebook-os-rootfs.tar.gz"
echo "================================"
