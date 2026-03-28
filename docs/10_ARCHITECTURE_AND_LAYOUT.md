# Architecture and Layout

This file explains what each top-level folder is for.

## Top-level layout

### `auto/`
Build compatibility entry point.

Purpose:
- points users at the native build flow
- keeps a familiar `auto/` entry for tooling and docs

### `assets/`
Raw source branding assets.

Typical contents:
- wallpaper
- logos
- ASCII/Braille art
- optional SVG or alternative formats

Keep this as the canonical source asset directory.

### `build.sh`
Top-level build command. Intended to be the normal entry point.

### `clean.sh`
Removes build state so you can rebuild cleanly.

### `scripts/`
Host-side support tools.

Typical contents:
- build dependency installers
- post-build checks
- helper utilities used during authoring or verification

### `docs/`
Human-facing project documentation.

### `config/package-lists/`
Package groups split by responsibility.

Why this split is useful:
- smaller review diffs
- easier dependency reasoning
- cleaner experimentation
- easier removal of optional packages

### `config/includes.chroot/`
Files that are copied directly into the live filesystem.

Use this for:
- scripts
- static assets
- desktop entries
- default configs
- MOTD/issue files
- `/etc/skel` content

### `config/hooks/live/`
Late customization scripts run inside the chroot during the native build process.

Use hooks for:
- creating defaults that need commands to run
- branding steps
- user/session setup
- cleanup

Do not use hooks for files that could have just lived in `includes.chroot/`.

## Why the split layout is good

It prevents the distro from becoming one giant unreviewable blob.

This structure gives you:
- clear responsibilities
- easier debugging
- easier onboarding for contributors
- lower chance of accidental breakage

## Recommended future additions

As the project grows, add:

### `packages/`
For real DebianMOSS `.deb` packaging metadata.

### `overrides/`
If you later need package overrides or patches.

### `tests/`
For smoke tests, boot checks, or validation scripts.

### `ci/`
For GitHub Actions or release automation.

## Ownership model

A good rule of thumb:

- Debian owns the operating system foundation
- DebianMOSS owns the user experience layer
- your apps own themselves

That separation is how the project stays sane.
