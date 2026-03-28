# DebianMOSS Documentation Pack

This pack is a drop-in documentation upgrade for the `debianmoss` starter distro project.

It is written for the current DebianMOSS tree. The docs assume:

- the project lives at `/home/masi/debianmoss`
- the ISO is built with the native `build.sh` debootstrap/chroot pipeline
- the default desktop stack is XFCE with LightDM
- `moss-session`, `mossdev`, and `mosspkg` are helper tools layered on top of a normal Debian base

## What this documentation pack covers

- what DebianMOSS is and is not
- host setup on Debian/Ubuntu, Arch, or in a Debian container
- how to build the ISO
- first boot and what to expect
- daily usage
- package management with `apt`, `flatpak`, and `mosspkg`
- building terminal apps, desktop apps, and custom sessions/WMs
- how to customize branding, wallpapers, and defaults
- troubleshooting
- release workflow

## Files in this pack

- `README.md`
- `docs/00_INDEX.md`
- `docs/01_OVERVIEW.md`
- `docs/02_HOST_SETUP.md`
- `docs/03_BUILDING_THE_ISO.md`
- `docs/04_FIRST_BOOT_AND_DAILY_USE.md`
- `docs/05_PACKAGE_MANAGEMENT.md`
- `docs/06_BUILDING_PROGRAMS.md`
- `docs/07_APP_TUTORIALS.md`
- `docs/08_CUSTOM_SESSIONS_AND_WMS.md`
- `docs/09_BRANDING_AND_THEMING.md`
- `docs/10_ARCHITECTURE_AND_LAYOUT.md`
- `docs/11_TROUBLESHOOTING.md`
- `docs/12_RELEASES_AND_PUBLISHING.md`
- `docs/13_FAQ.md`

## Install into your project

From `/home/masi/Downloads` after downloading the archive:

```bash
cd /home/masi/Downloads
rm -rf debianmoss-docs-v1
tar -xzf debianmoss-docs-v1.tar.gz
cp -av debianmoss-docs-v1/README.md /home/masi/debianmoss/
cp -av debianmoss-docs-v1/docs/. /home/masi/debianmoss/docs/
```
