# Host Setup

This document is about the machine that builds the ISO, not the machine that runs the ISO later.

## Supported host approaches

The cleanest build environments are:

1. Debian or Ubuntu host
2. Debian container on a non-Debian host
3. Debian VM
4. Arch host only if you are comfortable with extra setup

Because DebianMOSS builds a Debian rootfs directly with `debootstrap`, the smoothest path is still a Debian environment.

## Option A: Debian or Ubuntu host

From the project directory:

```bash
cd /home/masi/debianmoss
./scripts/install-host-deps-debian.sh
sudo ./build.sh
```

If you want the raw package list:

```bash
sudo apt update
sudo apt install -y \
  debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin \
  mtools dosfstools rsync ca-certificates curl git
```

## Option B: Arch host, but build inside a Debian container

This is the recommended Arch workflow.

Install container tooling:

```bash
sudo pacman -Sy --needed podman distrobox
```

Create and enter a Debian builder:

```bash
distrobox create -n debianmoss-builder -i debian:bookworm
distrobox enter debianmoss-builder
```

Inside the container:

```bash
sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools rsync ca-certificates curl git
cd /home/masi/debianmoss
sudo ./build.sh
```

## Option C: Arch host directly

Use the helper script first:

```bash
cd /home/masi/debianmoss
./scripts/install-host-deps-arch.sh
```

If direct Arch-host building gets annoying, stop fighting the host and switch to the Debian-container path above.

## Required host resources

Minimum reasonable build host:
- 4 CPU threads
- 8 GB RAM
- 20 GB free disk space

More comfortable:
- 8 threads
- 16 GB RAM
- 40+ GB free disk space

## Project location

The docs assume:

```text
/home/masi/debianmoss
```

That matters because examples, hooks, and helper scripts all refer to the project from there.

## Build outputs

The ISO is written to:

```text
/home/masi/debianmoss/debianmoss-amd64.hybrid.iso
```

Temporary build state appears under the project directory, mainly in `.build/`.

## Before your first build

Run these sanity checks:

```bash
cd /home/masi/debianmoss
ls
ls assets
ls config/package-lists
ls config/includes.chroot/usr/local/bin
```

You should see:
- `build.sh`
- `README.md`
- `assets/`
- `config/`
- `docs/`
- `scripts/`

## Clean rebuild

If you want to nuke the build state and start fresh:

```bash
cd /home/masi/debianmoss
sudo ./clean.sh
sudo ./build.sh
```

## Common host mistakes

### Building directly on Arch without a Debian environment
Possible, but annoying. If packages are missing, use a Debian container.

### Running build scripts without root
The actual rootfs build and ISO assembly need elevated privileges.

### Editing files as root accidentally
Only run the actual build steps with `sudo`. Do the normal editing as your user.

### Not enough disk space
ISOs and chroots eat space fast. Check free disk before blaming the scripts.
