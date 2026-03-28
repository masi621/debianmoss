#!/usr/bin/env bash
set -Eeuo pipefail
sudo pacman -Sy --needed \
  debootstrap squashfs-tools xorriso grub mtools dosfstools \
  rsync ca-certificates curl git cpio gzip
