#!/bin/bash
set -e

echo "======================================"
echo "       Chromebook OS ARM64 Builder"
echo "======================================"

BUILD_DIR="build"
ROOTFS_DIR="rootfs"

rm -rf "$BUILD_DIR" "$ROOTFS_DIR"
mkdir -p "$BUILD_DIR" "$ROOTFS_DIR"

echo "[1/6] Installing build tools..."

sudo apt-get update

sudo apt-get install -y \
    debootstrap \
    qemu-user-static \
    binfmt-support \
    ca-certificates

echo "[2/6] Creating ARM64 Ubuntu base..."

sudo debootstrap \
    --arch=arm64 \
    --foreign \
    noble \
    "$ROOTFS_DIR" \
    http://ports.ubuntu.com/ubuntu-ports

echo "[3/6] Preparing ARM64 environment..."

sudo cp /usr/bin/qemu-aarch64-static \
    "$ROOTFS_DIR/usr/bin/qemu-aarch64-static"

sudo mount --bind /dev "$ROOTFS_DIR/dev" || true
sudo mount --bind /proc "$ROOTFS_DIR/proc" || true
sudo mount --bind /sys "$ROOTFS_DIR/sys" || true

echo "[4/6] Completing ARM64 installation..."

sudo chroot "$ROOTFS_DIR" /debootstrap/debootstrap --second-stage

echo "[5/6] Configuring Chromebook OS..."

sudo tee "$ROOTFS_DIR/etc/os-release" > /dev/null <<EOF
NAME="Chromebook OS"
ID=chromebook-os
VERSION="0.2"
VERSION_ID="0.2"
PRETTY_NAME="Chromebook OS 0.2 ARM64"
ARCHITECTURE="arm64"
CHROMEOS_BOARD="steelix"
CHROMEOS_DEVICE="magneton"
CHROMEOS_SOC="mediatek-mt8186"
CHROMEOS_SKU="393218/393221"
EOF

echo "magneton" | sudo tee \
    "$ROOTFS_DIR/etc/hostname" > /dev/null

sudo mkdir -p "$ROOTFS_DIR/etc/chromebook-os"

sudo tee "$ROOTFS_DIR/etc/chromebook-os/hardware" > /dev/null <<EOF
BOARD=steelix
DEVICE=magneton
SOC=mediatek-mt8186
ARCH=aarch64
SKU=393218/393221
EOF

echo "[6/6] Creating ARM64 rootfs archive..."

sudo tar -czf \
    "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz" \
    -C "$ROOTFS_DIR" .

sudo chown "$USER:$USER" \
    "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz"

sudo umount "$ROOTFS_DIR/dev" 2>/dev/null || true
sudo umount "$ROOTFS_DIR/proc" 2>/dev/null || true
sudo umount "$ROOTFS_DIR/sys" 2>/dev/null || true

echo
echo "======================================"
echo "        BUILD COMPLETED"
echo "======================================"
echo
echo "Target:"
echo "  Board:  Steelix"
echo "  Device: Magneton"
echo "  SoC:    MediaTek MT8186"
echo "  SKU:    393218/393221"
echo "  Arch:   ARM64"
echo
echo "Output:"
echo "$BUILD_DIR/chromebook-os-arm64-rootfs.tar.gz"
