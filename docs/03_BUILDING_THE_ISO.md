# Building the ISO

## Quick build

From the project root:

```bash
cd /home/masi/debianmoss
sudo ./build.sh
```

The final ISO will be:

```text
./debianmoss-amd64.hybrid.iso
```

## What build.sh does

At a high level:

1. bootstraps a Debian rootfs with `debootstrap`
2. installs package lists from `config/package-lists/`
3. copies overlay files from `config/includes.chroot/`
4. runs late custom hooks from `config/hooks/live/`
5. rebuilds initramfs in the chroot
6. assembles the squashfs and final live ISO

## Important folders in the build

### `auto/`
Small compatibility wrapper for the native build flow.

### `config/package-lists/`
The Debian packages that will be installed into the live system.

### `config/includes.chroot/`
Files copied directly into the live root filesystem.

### `config/hooks/live/`
Scripts that run inside the build late in the process and can do package config, branding, user defaults, and cleanup.

## Recommended build flow

### 1. Optional clean rebuild
```bash
sudo ./clean.sh
```

### 2. Build
```bash
sudo ./build.sh
```

### 3. Verify the ISO exists
```bash
ls -lh ./debianmoss-amd64.hybrid.iso
```

### 4. Boot-test it
QEMU example:

```bash
qemu-system-x86_64 -m 4096 -smp 4 -cdrom ./debianmoss-amd64.hybrid.iso
```

## Fast iteration loop

When changing docs, wallpapers, branding files, or overlays and you already have a good chroot:

```bash
sudo ./build.sh --reuse-chroot
```

Use a full clean rebuild when the package set, bootstrap logic, or chroot state is suspect.

## How to add packages to the ISO

Edit one of the files under:

```text
config/package-lists/
```

Suggested split:
- `base.list.chroot` for system basics
- `desktop.list.chroot` for GUI/session packages
- `dev.list.chroot` for toolchains
- `extra.list.chroot` for optional quality-of-life tools

Then rebuild.

## How to add files to the ISO

Put them under:

```text
config/includes.chroot/
```

Examples:
- `/usr/local/bin/` for custom scripts
- `/opt/debianmoss-assets/` for bundled artwork
- `/etc/skel/` for new-user defaults
- `/usr/share/applications/` for launchers

Then rebuild.

## How to run post-build checks

If the project includes:

```text
scripts/post-build-check.sh
```

run it after the build:

```bash
cd /home/masi/debianmoss
./scripts/post-build-check.sh
```

## Common build failures

### `debootstrap: command not found`
Install the host dependencies first or build inside a Debian environment.

### permission errors
Use `sudo` for the build step.

### package not found
You likely added a package name that does not exist in the target Debian release.

### hook failures
A script under `config/hooks/live/` exited nonzero. Test the hook body manually inside a Debian environment.

## Keep builds reproducible

Good habits:
- keep package lists clean
- avoid random host-specific dependencies
- keep custom scripts in version control
- document every new hook
- prefer standard Debian packages before inventing custom plumbing
