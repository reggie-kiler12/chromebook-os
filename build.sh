#!/bin/bash
set -e

echo "======================================"
echo "       Chromebook OS ARM64 Builder"
echo "======================================"

BUILD_DIR="build"
ROOTFS_DIR="rootfs"

rm -rf "$BUILD_DIR" "$ROOTFS_DIR"
mkdir -p "$BUILD_DIR" "$ROOTFS_DIR"

echo "[1/5] Installing build tools..."

sudo apt-get update
sudo apt-get install -y debootstrap qemu-user-static

echo "[2/5] Creating ARM64 Ubuntu base..."

sudo debootstrap \
    --arch=arm64 \
    --foreign \
    noble \
    "$ROOTFS_DIR" \
    http://ports.ubuntu.com/ubuntu-ports

echo "[3/5] Preparing ARM64 environment..."

sudo cp /usr/bin/qemu-aarch64-static \
    "$ROOTFS_DIR/usr/bin/qemu-aarch64-static"

sudo cp /usr/bin/qemu-aarch64-static \
    "$ROOTFS_DIR/usr/bin/"

echo "[4/5] Adding Chromebook OS information..."

sudo tee "$ROOTFS_DIR/etc/os-release" > /dev/null <<EOF
NAME="Chromebook OS"
ID=chromebook-os
VERSION="0.2"
VERSION_ID="0.2"
PRETTY_NAME="Chromebook OS 0.2 ARM64"
ARCHITECTURE="arm64"
EOF

echo "Chromebook OS ARM64 base" | \
    sudo tee "$ROOTFS_DIR/etc/hostname" > /dev/null

echo "[5/5] Creating archive..."

sudo tar -czf \
    "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz" \
    -C "$ROOTFS_DIR" .

sudo chown "$USER:$USER" \
    "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz"

echo
echo "======================================"
echo "        BUILD COMPLETED"
echo "======================================"
echo
echo "Output:"
echo "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz"
