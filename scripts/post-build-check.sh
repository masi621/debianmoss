#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
ISO="$SCRIPT_DIR/debianmoss-amd64.hybrid.iso"
CHROOT="$SCRIPT_DIR/.build/chroot"
SQUASHFS="$SCRIPT_DIR/.build/iso/live/filesystem.squashfs"

die() {
  echo "$*" >&2
  exit 1
}

if [[ ! -f "$ISO" ]]; then
  die "ISO not found: $ISO"
fi
ls -lh "$ISO"
file "$ISO" || true

if [[ ! -d "$CHROOT" ]]; then
  echo "Chroot not found: $CHROOT"
  exit 0
fi

mapfile -t installer_entries < <(
  find "$CHROOT/usr/share/applications" -maxdepth 1 -type f -name '*.desktop' -print0 |
    while IFS= read -r -d '' f; do
      if grep -Eq '(^Exec=.*calamares|^Exec=.*install-debian|^Exec=.*/usr/local/bin/moss-installer)' "$f"; then
        if ! grep -Eq '^NoDisplay=true$' "$f"; then
          printf '%s\n' "$f"
        fi
      fi
    done | sort
)

if [[ ${#installer_entries[@]} -ne 1 ]]; then
  printf 'Expected exactly one visible installer launcher, found %s:\n' "${#installer_entries[@]}" >&2
  printf '  %s\n' "${installer_entries[@]}" >&2
  exit 1
fi

if ! grep -q '^Name=Install DebianMOSS$' "${installer_entries[0]}"; then
  die "Visible installer launcher is not branded as Install DebianMOSS: ${installer_entries[0]}"
fi

if find "$CHROOT/etc/skel/Desktop" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null |
   xargs -0 -r grep -El '(^Exec=.*calamares|^Exec=.*install-debian|^Exec=.*/usr/local/bin/moss-installer|^Name=.*Install Debian)' >/dev/null; then
  die "Installer desktop launchers are still present in /etc/skel/Desktop"
fi

if [[ ! -L "$CHROOT/etc/skel/Desktop/DebianMOSS Welcome.desktop" ]]; then
  die "Moss Field Guide desktop icon in /etc/skel/Desktop should be a symlink"
fi
if [[ "$(readlink "$CHROOT/etc/skel/Desktop/DebianMOSS Welcome.desktop")" != "/usr/share/applications/debianmoss-welcome.desktop" ]]; then
  die "Moss Field Guide desktop icon should point at /usr/share/applications/debianmoss-welcome.desktop"
fi
grep -q 'ln -sfn /usr/share/applications/install-debian.desktop' "$CHROOT/usr/bin/add-calamares-desktop-icon" ||
  die "add-calamares-desktop-icon no longer creates a trusted symlinked launcher"

if [[ -f "$CHROOT/etc/calamares/modules/packages.conf" ]]; then
  grep -q "calamares-settings-debian" "$CHROOT/etc/calamares/modules/packages.conf" ||
    die "Calamares packages.conf no longer removes calamares-settings-debian"
  grep -q "calamares'" "$CHROOT/etc/calamares/modules/packages.conf" ||
    die "Calamares packages.conf no longer removes calamares from the installed system"
fi

if [[ -f "$CHROOT/usr/share/calamares/branding/debianmoss/branding.desc" ]]; then
  grep -q '^componentName: debianmoss$' "$CHROOT/usr/share/calamares/branding/debianmoss/branding.desc" ||
    die "Calamares branding componentName does not match the debianmoss directory"
  grep -q '^slideshow: "show.qml"$' "$CHROOT/usr/share/calamares/branding/debianmoss/branding.desc" ||
    die "Calamares branding is missing the DebianMOSS slideshow setting"
  if grep -nE '^[[:space:]]*[A-Za-z][A-Za-z0-9_]*:"' "$CHROOT/usr/share/calamares/branding/debianmoss/branding.desc" >/dev/null; then
    die "Calamares branding YAML contains malformed key/value lines without a space after ':'"
  fi
fi
[[ -f "$CHROOT/usr/share/calamares/branding/debianmoss/show.qml" ]] ||
  die "Missing DebianMOSS Calamares slideshow in chroot"
[[ -f "$CHROOT/etc/calamares/modules/shellprocess.conf" ]] ||
  die "Missing DebianMOSS Calamares shellprocess cleanup config in chroot"
[[ "$(grep -c '^  - shellprocess$' "$CHROOT/etc/calamares/settings.conf")" -eq 1 ]] ||
  die "Calamares settings should include exactly one shellprocess cleanup step"
grep -q '^  - shellprocess$' "$CHROOT/etc/calamares/settings.conf" ||
  die "Calamares settings do not run shellprocess cleanup during install"

[[ -f "$CHROOT/usr/share/plymouth/themes/debianmoss/debianmoss.plymouth" ]] ||
  die "Missing DebianMOSS Plymouth theme metadata in chroot"
[[ -f "$CHROOT/usr/share/plymouth/themes/debianmoss/debianmoss.script" ]] ||
  die "Missing DebianMOSS Plymouth theme script in chroot"
[[ -f "$CHROOT/usr/share/plymouth/themes/debianmoss/newlogo.png" ]] ||
  die "Missing DebianMOSS Plymouth logo in chroot"
[[ -f "$CHROOT/usr/share/backgrounds/debianmoss/tiles.png" ]] ||
  die "Missing DebianMOSS canonical wallpaper in chroot"
[[ -L "$CHROOT/usr/share/backgrounds/debianmoss/wall-green.png" ]] ||
  die "wall-green.png compatibility link is missing in chroot"
[[ "$(readlink "$CHROOT/usr/share/backgrounds/debianmoss/wall-green.png")" = "tiles.png" ]] ||
  die "wall-green.png should point at tiles.png in chroot"
grep -q '/usr/share/backgrounds/debianmoss/tiles.png' "$CHROOT/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ||
  die "System-wide XFCE desktop defaults do not point at tiles.png"
grep -q '/usr/share/backgrounds/debianmoss/tiles.png' "$CHROOT/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" ||
  die "Skeleton XFCE desktop defaults do not point at tiles.png"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/theme.txt" ]] ||
  die "Missing DebianMOSS GRUB theme in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/background.png" ]] ||
  die "Missing DebianMOSS GRUB background in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/newlogo.png" ]] ||
  die "Missing DebianMOSS GRUB logo in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/dejavu_10.pf2" ]] ||
  die "Missing DebianMOSS GRUB 10pt font in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/dejavu_12.pf2" ]] ||
  die "Missing DebianMOSS GRUB 12pt font in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/dejavu_16.pf2" ]] ||
  die "Missing DebianMOSS GRUB 16pt font in chroot"
[[ -f "$CHROOT/boot/grub/themes/debianmoss/dejavu_bold_14.pf2" ]] ||
  die "Missing DebianMOSS GRUB bold font in chroot"
[[ -f "$CHROOT/etc/lightdm/lightdm-gtk-greeter.conf.d/50-debianmoss.conf" ]] ||
  die "Missing DebianMOSS LightDM greeter config in chroot"
grep -q '^theme-name=DebianMOSS-Greeter$' "$CHROOT/etc/lightdm/lightdm-gtk-greeter.conf.d/50-debianmoss.conf" ||
  die "LightDM greeter is not configured to use DebianMOSS-Greeter"
[[ -f "$CHROOT/usr/share/themes/DebianMOSS-Greeter/index.theme" ]] ||
  die "Missing DebianMOSS greeter index.theme in chroot"
[[ -f "$CHROOT/usr/share/themes/DebianMOSS-Greeter/gtk-3.0/gtk.css" ]] ||
  die "Missing DebianMOSS greeter theme CSS in chroot"

if [[ -f "$SQUASHFS" ]] && command -v unsquashfs >/dev/null 2>&1; then
  unsquashfs -ll "$SQUASHFS" boot/grub/themes/debianmoss/theme.txt >/dev/null 2>&1 ||
    die "Installed rootfs squashfs is missing the DebianMOSS GRUB theme"
  unsquashfs -ll "$SQUASHFS" boot/grub/themes/debianmoss/dejavu_16.pf2 >/dev/null 2>&1 ||
    die "Installed rootfs squashfs is missing the DebianMOSS GRUB font"
  unsquashfs -ll "$SQUASHFS" | grep -q 'boot/vmlinuz-' ||
    die "Installed rootfs squashfs is missing the kernel under /boot"
  unsquashfs -ll "$SQUASHFS" | grep -q 'boot/initrd.img-' ||
    die "Installed rootfs squashfs is missing the initrd under /boot"
fi

echo "Post-build checks passed."
