#!/usr/bin/env bash
set -Eeuo pipefail
sudo apt update
sudo apt install -y \
  debootstrap squashfs-tools xorriso grub-efi-arm64-bin qemu-user-static \
  mtools dosfstools rsync ca-certificates curl git cpio gzip
