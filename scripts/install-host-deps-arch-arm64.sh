#!/usr/bin/env bash
set -Eeuo pipefail
sudo pacman -Sy --needed \
  debootstrap squashfs-tools xorriso qemu-user-static qemu-user-static-binfmt \
  mtools dosfstools rsync ca-certificates curl git cpio gzip

if [[ ! -d /usr/lib/grub/arm64-efi ]]; then
  printf '[debianmoss] Host arm64 GRUB EFI modules are not installed at /usr/lib/grub/arm64-efi.\n' >&2
  printf '[debianmoss] That is okay: build-arm.sh will fetch Debian arm64 EFI GRUB modules automatically.\n' >&2
fi
