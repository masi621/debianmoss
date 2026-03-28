#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
host_arch="$(uname -m)"
release="${DEBIAN_RELEASE:-bookworm}"
mirror="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
tool_root="${ARM_TOOL_ROOT:-$SCRIPT_DIR/.build/tooling/arm64}"
debs_dir="$tool_root/debs"
indexes_dir="$tool_root/indexes"
extract_dir="$tool_root/extracted"
host_bin_dir="$tool_root/host-bin"

host_debian_arch() {
  case "$host_arch" in
    x86_64) printf 'amd64\n' ;;
    aarch64|arm64) printf 'arm64\n' ;;
    i?86) printf 'i386\n' ;;
    *) printf '%s\n' "$host_arch" ;;
  esac
}

warn() {
  printf '[debianmoss][warn] %s\n' "$*" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '[debianmoss][err] Missing required command for build-arm.sh: %s\n' "$1" >&2
    exit 1
  }
}

extract_deb() {
  local deb="$1" dest="$2" member
  rm -rf "$dest"
  mkdir -p "$dest"
  member="$(ar t "$deb" | grep -E '^data\.tar(\.|$)' | head -n1)"
  [[ -n "$member" ]] || {
    printf '[debianmoss][err] Could not find data.tar member inside %s\n' "$deb" >&2
    exit 1
  }
  case "$member" in
    *.xz)
      ar p "$deb" "$member" | tar -xJf - -C "$dest"
      ;;
    *.gz)
      ar p "$deb" "$member" | tar -xzf - -C "$dest"
      ;;
    *.zst)
      require_cmd zstd
      ar p "$deb" "$member" | tar --zstd -xf - -C "$dest"
      ;;
    *.tar)
      ar p "$deb" "$member" | tar -xf - -C "$dest"
      ;;
    *)
      printf '[debianmoss][err] Unsupported Debian package payload: %s\n' "$member" >&2
      exit 1
      ;;
  esac
}

ensure_packages_index() {
  local arch="$1"
  local idx="$indexes_dir/Packages-${release}-${arch}.gz"
  mkdir -p "$indexes_dir"
  if [[ ! -f "$idx" ]]; then
    printf '[debianmoss] Downloading Debian package index for %s (%s)\n' "$arch" "$release" >&2
    curl -fsSL "$mirror/dists/$release/main/binary-$arch/Packages.gz" -o "$idx"
  fi
  printf '%s\n' "$idx"
}

lookup_deb_filename() {
  local package="$1" arch="$2" idx
  idx="$(ensure_packages_index "$arch")"
  gzip -dc "$idx" | awk -v pkg="$package" '
    BEGIN { RS=""; FS="\n" }
    $1 == "Package: " pkg {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^Filename: /) {
          sub(/^Filename: /, "", $i)
          found = $i
        }
      }
    }
    END {
      if (found != "") {
        print found
      }
    }
  '
}

ensure_extracted_deb_package() {
  local package="$1" arch="$2" marker="$3" out_var="$4"
  local filename deb extract_to
  filename="$(lookup_deb_filename "$package" "$arch")"
  [[ -n "$filename" ]] || {
    printf '[debianmoss][err] Could not resolve Debian package %s for architecture %s\n' "$package" "$arch" >&2
    exit 1
  }
  mkdir -p "$debs_dir" "$extract_dir"
  deb="$debs_dir/$(basename "$filename")"
  extract_to="$extract_dir/${package}_${arch}"
  if [[ ! -f "$deb" ]]; then
    printf '[debianmoss] Downloading %s (%s)\n' "$package" "$arch" >&2
    curl -fsSL "$mirror/$filename" -o "$deb"
  fi
  if [[ ! -e "$extract_to/$marker" ]]; then
    printf '[debianmoss] Extracting %s (%s)\n' "$package" "$arch" >&2
    extract_deb "$deb" "$extract_to"
  fi
  printf -v "$out_var" '%s' "$extract_to"
}

binfmt_entry_name() {
  printf 'debianmoss-qemu-aarch64\n'
}

ensure_binfmt_misc_mounted() {
  if command -v systemctl >/dev/null 2>&1; then
    systemctl start proc-sys-fs-binfmt_misc.mount >/dev/null 2>&1 || true
    systemctl restart systemd-binfmt.service >/dev/null 2>&1 || true
  fi
  if [[ ! -e /proc/sys/fs/binfmt_misc/register ]]; then
    command -v modprobe >/dev/null 2>&1 && modprobe binfmt_misc >/dev/null 2>&1 || true
    mountpoint -q /proc/sys/fs/binfmt_misc || \
      mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc >/dev/null 2>&1 || true
  fi
  [[ -w /proc/sys/fs/binfmt_misc/register ]] || {
    printf '[debianmoss][err] Could not access /proc/sys/fs/binfmt_misc/register for arm64 binfmt setup.\n' >&2
    exit 1
  }
}

ensure_arm64_binfmt() {
  local entry qemu_path current_entry system_entry
  [[ "$host_deb_arch" != "arm64" ]] || return 0
  [[ $EUID -eq 0 ]] || {
    warn 'arm64 cross-builds need root so binfmt_misc can be configured automatically.'
    return 0
  }
  qemu_path="$(command -v qemu-aarch64-static || true)"
  [[ -n "$qemu_path" ]] || {
    printf '[debianmoss][err] qemu-aarch64-static is not available for arm64 cross-builds.\n' >&2
    exit 1
  }
  entry="$(binfmt_entry_name)"
  ensure_binfmt_misc_mounted
  system_entry="/proc/sys/fs/binfmt_misc/qemu-aarch64"
  if [[ -f "$system_entry" ]] && grep -q '^enabled$' "$system_entry"; then
    return 0
  fi
  current_entry="/proc/sys/fs/binfmt_misc/$entry"
  if [[ -f "$current_entry" ]] && grep -q "^interpreter $qemu_path\$" "$current_entry"; then
    grep -q '^enabled$' "$current_entry" && return 0
  fi
  if [[ -f "$current_entry" ]]; then
    echo -1 > "$current_entry"
  fi
  printf ':%s:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:%s:OCF\n' \
    "$entry" "$qemu_path" > /proc/sys/fs/binfmt_misc/register
}

case "$host_arch" in
  aarch64|arm64|x86_64) ;;
  *)
    printf '[debianmoss][err] build-arm.sh supports native arm64 hosts and x86_64 cross-build hosts. Current host: %s\n' "$host_arch" >&2
    exit 1
    ;;
esac

require_cmd curl
require_cmd gzip
require_cmd ar
require_cmd tar

host_deb_arch="$(host_debian_arch)"
grub_pkg_root=''
qemu_pkg_root=''
export DEBIAN_ARCH=arm64
export DEBIAN_KERNEL_PACKAGE="${DEBIAN_KERNEL_PACKAGE:-linux-image-arm64}"
export OUT_NAME="${OUT_NAME:-debianmoss-arm64.iso}"

ensure_extracted_deb_package grub-efi-arm64-bin arm64 usr/lib/grub/arm64-efi grub_pkg_root
export GRUB_PLATFORM_DIR="$grub_pkg_root/usr/lib/grub/arm64-efi"

if [[ "$host_deb_arch" != "arm64" ]] && ! command -v qemu-aarch64-static >/dev/null 2>&1; then
  ensure_extracted_deb_package qemu-user-static "$host_deb_arch" usr/bin/qemu-aarch64-static qemu_pkg_root
  mkdir -p "$host_bin_dir"
  install -m 755 "$qemu_pkg_root/usr/bin/qemu-aarch64-static" "$host_bin_dir/qemu-aarch64-static"
  export PATH="$host_bin_dir:$PATH"
fi

ensure_arm64_binfmt

exec bash "$SCRIPT_DIR/build.sh" "$@"
