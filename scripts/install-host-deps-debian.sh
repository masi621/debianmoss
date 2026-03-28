#!/usr/bin/env bash
set -Eeuo pipefail
sudo apt update
sudo apt install -y \
  debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin \
  mtools dosfstools rsync ca-certificates curl git cpio gzip
