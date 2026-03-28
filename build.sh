#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
WORK_DIR="${WORK_DIR:-$SCRIPT_DIR/.build}"
CHROOT_DIR="$WORK_DIR/chroot"
ISO_DIR="$WORK_DIR/iso"
CACHE_DIR="$WORK_DIR/cache"
RELEASE="${DEBIAN_RELEASE:-bookworm}"
ARCH="${DEBIAN_ARCH:-amd64}"
case "$ARCH" in
  amd64) DEFAULT_OUT_NAME="debianmoss-amd64.hybrid.iso" ; DEFAULT_KERNEL_PACKAGE="linux-image-amd64" ;;
  arm64) DEFAULT_OUT_NAME="debianmoss-arm64.iso" ; DEFAULT_KERNEL_PACKAGE="linux-image-arm64" ;;
  *) DEFAULT_OUT_NAME="debianmoss-${ARCH}.iso" ; DEFAULT_KERNEL_PACKAGE="linux-image-$ARCH" ;;
esac
OUT_NAME="${OUT_NAME:-$DEFAULT_OUT_NAME}"
KERNEL_PACKAGE="${DEBIAN_KERNEL_PACKAGE:-$DEFAULT_KERNEL_PACKAGE}"
MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-http://deb.debian.org/debian-security}"
HOSTNAME_VALUE="${DEBIANMOSS_HOSTNAME:-debianmoss}"
LIVE_USER="${DEBIANMOSS_USER:-moss}"
REUSE_CHROOT=0
ONLY_ISO=0
DO_CLEAN=0
DO_CHECK=0
START_TIME_EPOCH="$(date +%s)"
SUMMARY_ENABLED=1

log() { printf '[debianmoss] %s\n' "$*"; }
warn() { printf '[debianmoss][warn] %s\n' "$*" >&2; }
die() { printf '[debianmoss][err] %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

format_elapsed_hms() {
  local total="$1" h m s
  h=$(( total / 3600 ))
  m=$(( (total % 3600) / 60 ))
  s=$(( total % 60 ))
  printf '%02d:%02d:%02d' "$h" "$m" "$s"
}

show_build_target_menu() {
  local choice
  cat <<'EOF'
[debianmoss] Select build target:
  1) x86 / amd64
  2) arm / arm64
  3) sequential (amd64 first, then arm64)
EOF
  while true; do
    read -r -p "[debianmoss] Enter choice [1-3]: " choice
    case "$choice" in
      1)
        export DEBIANMOSS_BUILD_MENU_DONE=1
        return 0
        ;;
      2)
        export DEBIANMOSS_BUILD_MENU_DONE=1
        exec bash "$SCRIPT_DIR/build-arm.sh" "$@"
        ;;
      3)
        export DEBIANMOSS_BUILD_MENU_DONE=1
        log 'Running sequential build: amd64 first, then arm64'
        DEBIANMOSS_BUILD_MENU_DONE=1 DEBIAN_ARCH=amd64 bash "$SCRIPT_DIR/build.sh" "$@"
        DEBIANMOSS_BUILD_MENU_DONE=1 bash "$SCRIPT_DIR/build-arm.sh" "$@"
        exit 0
        ;;
      *)
        printf '[debianmoss][warn] Please choose 1, 2, or 3.\n' >&2
        ;;
    esac
  done
}

host_debian_arch() {
  if command -v dpkg >/dev/null 2>&1; then
    dpkg --print-architecture
    return
  fi
  case "$(uname -m)" in
    x86_64) printf 'amd64\n' ;;
    aarch64|arm64) printf 'arm64\n' ;;
    i?86) printf 'i386\n' ;;
    riscv64) printf 'riscv64\n' ;;
    *) uname -m ;;
  esac
}

HOST_ARCH="$(host_debian_arch)"

default_grub_platform_dir() {
  case "$ARCH" in
    amd64) printf '/usr/lib/grub/x86_64-efi\n' ;;
    arm64) printf '/usr/lib/grub/arm64-efi\n' ;;
    i386) printf '/usr/lib/grub/i386-efi\n' ;;
    riscv64) printf '/usr/lib/grub/riscv64-efi\n' ;;
    *) return 1 ;;
  esac
}

GRUB_PLATFORM_DIR="${GRUB_PLATFORM_DIR:-$(default_grub_platform_dir || true)}"

foreign_arch() {
  [[ "$HOST_ARCH" != "$ARCH" ]]
}

qemu_emulator_basename() {
  case "$ARCH" in
    arm64) printf 'qemu-aarch64-static\n' ;;
    amd64) printf 'qemu-x86_64-static\n' ;;
    i386) printf 'qemu-i386-static\n' ;;
    riscv64) printf 'qemu-riscv64-static\n' ;;
    *) return 1 ;;
  esac
}

ensure_foreign_arch_support() {
  local qemu_bin host_qemu
  foreign_arch || return 0
  qemu_bin="$(qemu_emulator_basename)" || die "No QEMU static emulator mapping is defined for target architecture: $ARCH"
  host_qemu="$(command -v "$qemu_bin" || true)"
  [[ -n "$host_qemu" ]] || die "Missing required host emulator for cross-builds: $qemu_bin"
}

ensure_foreign_arch_emulator_in_chroot() {
  local qemu_bin host_qemu
  foreign_arch || return 0
  qemu_bin="$(qemu_emulator_basename)" || die "No QEMU static emulator mapping is defined for target architecture: $ARCH"
  host_qemu="$(command -v "$qemu_bin" || true)"
  [[ -n "$host_qemu" ]] || die "Missing required host emulator for cross-builds: $qemu_bin"
  install -Dm755 "$host_qemu" "$CHROOT_DIR/usr/bin/$qemu_bin"
}

included_package_lists() {
  local list base
  for list in "$SCRIPT_DIR"/config/package-lists/*.list.chroot; do
    [[ -f "$list" ]] || continue
    base="$(basename "$list")"
    case "$base" in
      *.amd64.list.chroot) [[ "$ARCH" == "amd64" ]] || continue ;;
      *.arm64.list.chroot) [[ "$ARCH" == "arm64" ]] || continue ;;
    esac
    printf '%s\n' "$list"
  done | sort
}

check_grub_platform_support() {
  case "$ARCH" in
    amd64)
      [[ -d /usr/lib/grub/i386-pc ]] || die 'Missing host GRUB BIOS modules at /usr/lib/grub/i386-pc'
      [[ -n "$GRUB_PLATFORM_DIR" && -d "$GRUB_PLATFORM_DIR" ]] || die "Missing host GRUB EFI modules at ${GRUB_PLATFORM_DIR:-<unset>}"
      ;;
    arm64)
      [[ -n "$GRUB_PLATFORM_DIR" && -d "$GRUB_PLATFORM_DIR" ]] || die "Missing host GRUB EFI modules at ${GRUB_PLATFORM_DIR:-<unset>}"
      ;;
    *)
      warn "No explicit GRUB platform directory check for architecture: $ARCH"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reuse-chroot) REUSE_CHROOT=1 ;;
    --only-iso) ONLY_ISO=1 ;;
    --clean) DO_CLEAN=1 ;;
    --check) DO_CHECK=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: sudo ./build.sh [options]
  --reuse-chroot   Reuse an existing debootstrap root instead of rebuilding it.
  --only-iso       Skip package installation and only rebuild the squashfs + ISO.
  --clean          Delete build artifacts and exit.
  --check          Validate scripts and required host commands, then exit.
EOF
      exit 0
      ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

if [[ -t 0 && -z "${DEBIANMOSS_BUILD_MENU_DONE:-}" && -z "${DEBIAN_ARCH:-}" ]]; then
  show_build_target_menu "$@"
fi

cleanup_mounts() {
  local m
  for m in "$CHROOT_DIR/dev/pts" "$CHROOT_DIR/dev" "$CHROOT_DIR/proc" "$CHROOT_DIR/sys" "$CHROOT_DIR/run"; do
    mountpoint -q "$m" && umount -lf "$m" || true
  done
}
finish_build() {
  local rc="$?" elapsed
  cleanup_mounts
  if [[ "${SUMMARY_ENABLED:-1}" -eq 1 ]]; then
    elapsed="$(format_elapsed_hms "$(( $(date +%s) - START_TIME_EPOCH ))")"
    if [[ "$rc" -eq 0 ]]; then
      printf '[debianmoss] [success] completed in %s\n' "$elapsed"
    else
      printf '[debianmoss] [failure] completed in %s\n' "$elapsed" >&2
    fi
  fi
  exit "$rc"
}
trap finish_build EXIT

if [[ $DO_CLEAN -eq 1 ]]; then
  SUMMARY_ENABLED=0
  cleanup_mounts
  rm -rf "${WORK_DIR:?}" "${SCRIPT_DIR:?}/$OUT_NAME"
  log 'Cleaned build artifacts.'
  exit 0
fi

mkdir -p "$WORK_DIR" "$CACHE_DIR"

if [[ $DO_CHECK -eq 1 ]]; then
  SUMMARY_ENABLED=0
  for cmd in debootstrap chroot rsync mksquashfs grub-mkrescue xorriso awk sed grep sort mount umount; do
    need "$cmd"
  done
  ensure_foreign_arch_support
  check_grub_platform_support
  for required in \
    "$SCRIPT_DIR/assets/newLOGO.png" \
    "$SCRIPT_DIR/assets/tiles.png" \
    "$SCRIPT_DIR/config/includes.chroot/opt/debianmoss-assets/tiles.png" \
    "$SCRIPT_DIR/config/includes.chroot/opt/debianmoss-assets/calamares-show.qml" \
    "$SCRIPT_DIR/config/includes.chroot/etc/calamares/modules/shellprocess.conf" \
    "$SCRIPT_DIR/config/includes.chroot/etc/xdg/autostart/debianmoss-wallpaper.desktop" \
    "$SCRIPT_DIR/config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" \
    "$SCRIPT_DIR/config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" \
    "$SCRIPT_DIR/config/includes.chroot/usr/share/plymouth/themes/debianmoss/debianmoss.plymouth" \
    "$SCRIPT_DIR/config/includes.chroot/boot/grub/themes/debianmoss/theme.txt" \
    "$SCRIPT_DIR/config/includes.chroot/boot/grub/themes/debianmoss/dejavu_10.pf2" \
    "$SCRIPT_DIR/config/includes.chroot/boot/grub/themes/debianmoss/dejavu_12.pf2" \
    "$SCRIPT_DIR/config/includes.chroot/boot/grub/themes/debianmoss/dejavu_16.pf2" \
    "$SCRIPT_DIR/config/includes.chroot/boot/grub/themes/debianmoss/dejavu_bold_14.pf2" \
    "$SCRIPT_DIR/config/includes.chroot/usr/share/themes/DebianMOSS-Greeter/index.theme" \
    "$SCRIPT_DIR/config/includes.chroot/usr/share/themes/DebianMOSS-Greeter/gtk-3.0/gtk.css"; do
    [[ -e "$required" ]] || die "Missing required source file: $required"
  done
  find "$SCRIPT_DIR/config" "$SCRIPT_DIR/scripts" -type f \( -name "*.sh" -o -name "*.hook.chroot" -o -path "$SCRIPT_DIR/config/includes.chroot/usr/local/bin/*" \) -print0 | \
    while IFS= read -r -d "" f; do
      if head -n1 "$f" | grep -qE '(^#!.*(bash|sh)$|^#!/usr/bin/env (bash|sh)$)'; then
        bash -n "$f"
      fi
    done
  package_manifest="$(
    while IFS= read -r list; do
      awk 'NF && $1 !~ /^#/' "$list"
    done < <(included_package_lists)
  )"
  printf '%s\n' "$package_manifest" >/dev/null
  if printf '%s\n' "$package_manifest" | grep -qx 'grub-pc' && \
     printf '%s\n' "$package_manifest" | grep -qx 'grub-efi-amd64'; then
    die 'Package lists must not include both grub-pc and grub-efi-amd64; use grub-pc-bin and grub-efi-amd64-bin in the live rootfs.'
  fi
  log 'Check passed.'
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  die 'Run this build as root (debootstrap, chroot, and ISO assembly need it).'
fi

for cmd in debootstrap chroot rsync mksquashfs grub-mkrescue xorriso awk sed grep sort mount umount; do
  need "$cmd"
done
check_grub_platform_support

mandatory_packages=(
  "$KERNEL_PACKAGE"
  initramfs-tools
  live-boot
  live-config
  live-config-systemd
  systemd-sysv
  sudo
  locales
  dialog
  dbus-x11
)

read_package_lists() {
  while IFS= read -r list; do
    awk 'NF && $1 !~ /^#/' "$list"
  done < <(included_package_lists)
}

write_sources_list() {
  cat > "$CHROOT_DIR/etc/apt/sources.list" <<EOF
# DebianMOSS generated sources
deb $MIRROR $RELEASE main contrib non-free non-free-firmware
deb $MIRROR ${RELEASE}-updates main contrib non-free non-free-firmware
deb $SECURITY_MIRROR ${RELEASE}-security main contrib non-free non-free-firmware
EOF
}

bootstrap_rootfs() {
  local opts=(
    "--arch=$ARCH"
    "--variant=minbase"
    "--components=main,contrib,non-free,non-free-firmware"
  )
  if foreign_arch; then
    opts+=(--foreign)
  fi
  if [[ ! -e /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
    warn 'debian-archive-keyring.gpg not found on the host; falling back to --no-check-gpg.'
    opts+=(--no-check-gpg)
  fi
  rm -rf "$CHROOT_DIR"
  mkdir -p "$CHROOT_DIR"
  log "Bootstrapping Debian $RELEASE into $CHROOT_DIR"
  debootstrap "${opts[@]}" "$RELEASE" "$CHROOT_DIR" "$MIRROR"
  ensure_foreign_arch_emulator_in_chroot
  write_sources_list
  echo "$HOSTNAME_VALUE" > "$CHROOT_DIR/etc/hostname"
  cat > "$CHROOT_DIR/etc/hosts" <<EOF
127.0.0.1 localhost
127.0.1.1 $HOSTNAME_VALUE
::1 localhost ip6-localhost ip6-loopback
EOF
  mkdir -p "$CHROOT_DIR/etc/apt/apt.conf.d"
  cat > "$CHROOT_DIR/etc/apt/apt.conf.d/99debianmoss" <<'EOF'
APT::Install-Recommends "1";
APT::Install-Suggests "0";
Acquire::Retries "3";
EOF
}

mount_chroot() {
  mkdir -p "$CHROOT_DIR/dev/pts" "$CHROOT_DIR/proc" "$CHROOT_DIR/sys" "$CHROOT_DIR/run"
  mount --bind /dev "$CHROOT_DIR/dev"
  mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
  mount -t proc proc "$CHROOT_DIR/proc"
  mount -t sysfs sys "$CHROOT_DIR/sys"
  mount --bind /run "$CHROOT_DIR/run"
  cp -L /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
}

chroot_run() {
  local guest_cmd
  guest_cmd="export DEBIAN_FRONTEND=noninteractive HOME=/root LANG=C.UTF-8 LC_ALL=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; $*"
  if foreign_arch; then
    local qemu_bin
    qemu_bin="$(qemu_emulator_basename)" || die "No QEMU static emulator mapping is defined for target architecture: $ARCH"
    chroot "$CHROOT_DIR" "/usr/bin/$qemu_bin" /bin/bash -lc "$guest_cmd"
  else
    chroot "$CHROOT_DIR" /bin/bash -lc "$guest_cmd"
  fi
}

install_packages_and_overlay() {
  local packages_file="$WORK_DIR/packages.txt"
  { printf '%s\n' "${mandatory_packages[@]}"; read_package_lists; } | sort -u > "$packages_file"
  log 'Installing DebianMOSS package set inside chroot'
  install -m 644 "$packages_file" "$CHROOT_DIR/tmp/packages.txt"
  ensure_foreign_arch_emulator_in_chroot
  if foreign_arch && [[ -x "$CHROOT_DIR/debootstrap/debootstrap" ]]; then
    log "Completing foreign-architecture bootstrap second stage for $ARCH"
    chroot_run '/debootstrap/debootstrap --second-stage'
  fi
  chroot_run 'apt-get update'
  chroot_run "xargs -a /tmp/packages.txt apt-get install -y"
  chroot_run "sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || true"
  chroot_run 'locale-gen en_US.UTF-8 || true'
  chroot_run 'update-locale LANG=en_US.UTF-8 || true'
  rsync -a "$SCRIPT_DIR/config/includes.chroot/" "$CHROOT_DIR/"
  local hook hook_name
  for hook in "$SCRIPT_DIR"/config/hooks/live/*.hook.chroot; do
    [[ -f "$hook" ]] || continue
    hook_name="$(basename "$hook")"
    install -m 755 "$hook" "$CHROOT_DIR/tmp/$hook_name"
    chroot_run "/tmp/$hook_name"
    rm -f "$CHROOT_DIR/tmp/$hook_name"
  done
  chroot_run 'systemctl enable lightdm NetworkManager avahi-daemon || true'
  chroot_run 'apt-get clean'
  chroot_run 'update-initramfs -u -k all'
  rm -f "$CHROOT_DIR/tmp/packages.txt"
  if foreign_arch; then
    rm -f "$CHROOT_DIR/usr/bin/$(qemu_emulator_basename)"
  fi
}

assemble_iso_tree() {
  local kernel initrd grub_theme_dir
  rm -rf "$ISO_DIR"
  mkdir -p "$ISO_DIR/live" "$ISO_DIR/boot/grub"
  kernel="$(find "$CHROOT_DIR/boot" -maxdepth 1 -type f -name 'vmlinuz-*' | sort | tail -n1)"
  initrd="$(find "$CHROOT_DIR/boot" -maxdepth 1 -type f -name 'initrd.img-*' | sort | tail -n1)"
  [[ -n "$kernel" && -f "$kernel" ]] || die 'Could not find a kernel in the chroot.'
  [[ -n "$initrd" && -f "$initrd" ]] || die 'Could not find an initrd in the chroot.'
  log 'Creating compressed live filesystem'
  # Keep /boot inside the installed rootfs. Calamares installs from the
  # squashfs, and the target system needs the kernel, initramfs, and GRUB
  # theme assets present before bootloader-config / grub-mkconfig runs.
  mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" -comp xz -wildcards >/dev/null
  cp -f "$kernel" "$ISO_DIR/live/vmlinuz"
  cp -f "$initrd" "$ISO_DIR/live/initrd.img"
  grub_theme_dir="$CHROOT_DIR/boot/grub/themes/debianmoss"
  if [[ -d "$grub_theme_dir" ]]; then
    mkdir -p "$ISO_DIR/boot/grub/themes"
    cp -a "$grub_theme_dir" "$ISO_DIR/boot/grub/themes/"
  fi
  cat > "$ISO_DIR/boot/grub/grub.cfg" <<EOF
insmod all_video
insmod gfxterm
insmod png
insmod part_msdos
insmod part_gpt
insmod ext2
insmod fat
if [ -f /boot/grub/themes/debianmoss/dejavu_12.pf2 ]; then
    loadfont /boot/grub/themes/debianmoss/dejavu_12.pf2
fi
if [ -f /boot/grub/themes/debianmoss/dejavu_16.pf2 ]; then
    loadfont /boot/grub/themes/debianmoss/dejavu_16.pf2
fi
if [ -f /boot/grub/themes/debianmoss/dejavu_bold_14.pf2 ]; then
    loadfont /boot/grub/themes/debianmoss/dejavu_bold_14.pf2
fi
if [ -f /boot/grub/themes/debianmoss/theme.txt ]; then
    set theme=/boot/grub/themes/debianmoss/theme.txt
    export theme
fi
terminal_output gfxterm
set gfxmode=auto
set default=0
set timeout=6

menuentry "Start DebianMOSS Live" --class os --class gnu-linux {
    linux /live/vmlinuz boot=live components username=$LIVE_USER hostname=$HOSTNAME_VALUE quiet splash loglevel=3 rd.systemd.show_status=false vt.global_cursor_default=0
    initrd /live/initrd.img
}

menuentry "Start DebianMOSS Live (safe graphics)" --class os --class gnu-linux {
    linux /live/vmlinuz boot=live components username=$LIVE_USER hostname=$HOSTNAME_VALUE nomodeset quiet splash loglevel=3 rd.systemd.show_status=false vt.global_cursor_default=0
    initrd /live/initrd.img
}

if [ "\$grub_platform" = "efi" ]; then
menuentry "UEFI Firmware Settings" {
    fwsetup
}
fi
EOF
}

build_iso() {
  rm -f "$SCRIPT_DIR/$OUT_NAME"
  log "Building ISO $OUT_NAME"
  if [[ -n "$GRUB_PLATFORM_DIR" ]]; then
    grub-mkrescue -d "$GRUB_PLATFORM_DIR" -o "$SCRIPT_DIR/$OUT_NAME" "$ISO_DIR"
  else
    grub-mkrescue -o "$SCRIPT_DIR/$OUT_NAME" "$ISO_DIR"
  fi
  log "ISO ready: $SCRIPT_DIR/$OUT_NAME"
}

if [[ $ONLY_ISO -eq 0 ]]; then
  if [[ $REUSE_CHROOT -eq 0 || ! -x "$CHROOT_DIR/bin/bash" ]]; then
    bootstrap_rootfs
  else
    log "Reusing existing chroot: $CHROOT_DIR"
    write_sources_list
  fi
  cleanup_mounts
  mount_chroot
  install_packages_and_overlay
  cleanup_mounts
else
  [[ -d "$CHROOT_DIR" ]] || die '--only-iso requested, but no chroot exists.'
fi

assemble_iso_tree
build_iso
