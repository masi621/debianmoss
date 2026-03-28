# Overview

## What DebianMOSS is

DebianMOSS is a Debian-based live distro project that keeps the MOSS identity while switching the hard systems work to a real Debian base.

That means:

- Debian provides the kernel, initramfs, package manager, hardware support, firmware, networking stack, desktop plumbing, security updates, and huge software ecosystem.
- DebianMOSS provides the branding, desktop defaults, helper scripts, developer workflow, project templates, documentation, and a place for custom sessions or window managers.

## What DebianMOSS is not

It is not:

- a from-scratch operating system
- a custom kernel project
- a replacement for `apt`
- a guarantee that every custom MOSS experiment will be stable on every hypervisor

That distinction matters because it keeps the project realistic. The point is to build something usable, not to rebuild Debian the hard way.

## Design goals

### 1. Be buildable by one person
The project should be understandable and maintainable without a giant distro team.

### 2. Stay close to Debian
The closer you stay to stock Debian tools and conventions, the easier upgrades and debugging become.

### 3. Keep MOSS as a layer, not a fork of reality
MOSS should shape the experience:
- branding
- defaults
- helper commands
- templates
- sessions
- packaging convenience
- documentation

Debian should still do the heavy lifting.

### 4. Be good for coding
A fresh DebianMOSS live system should be comfortable for:
- C and C++
- Python
- Rust
- Go
- shell scripting
- small desktop app experiments
- trying alternative WMs and sessions

## Core user-facing pieces

### XFCE desktop
The starter build uses XFCE because it is light, familiar, and easy to bend without building a compositor from scratch.

### LightDM
The greeter and desktop entry point are standard and easy to theme.

### moss-session
This tool switches between:
- XFCE
- Openbox
- custom command/session paths

### mossdev
A developer scaffolder for starting new projects quickly.

### mosspkg
A helper around source installs and lightweight app metadata. It is not the main system package manager.

## Recommended project philosophy

Use DebianMOSS like this:

- use Debian packages whenever possible
- use Flatpak for desktop apps that are easier that way
- use `mosspkg` for source-based MOSS/community/dev tools
- use `mossdev` to scaffold code
- use `moss-session` to experiment with sessions and WMs

## Maturity expectations

The starter tree is a strong base, but it is still a starter tree.

Reasonable expectations:
- buildable live ISO
- normal Debian desktop
- MOSS-branded defaults
- developer-friendly tooling
- clean path for customization

Unreasonable expectations:
- instant polished daily-driver parity with a mature distro
- zero-maintenance custom package ecosystem
- magical support for every hypervisor without testing

## If you want this to become a real daily distro

The path is:

1. keep Debian as the base
2. package MOSS tools properly as `.deb` packages
3. tighten defaults and branding
4. test on real hardware, QEMU, and VirtualBox separately
5. add installer/release discipline
6. only then start replacing desktop components if there is a clear win
