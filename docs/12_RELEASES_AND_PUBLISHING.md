# Releases and Publishing

## Versioning advice

Treat the distro as a real product.

Suggested scheme:
- `0.x` while fundamentals are moving
- `1.0` when install/build/boot/docs are consistent
- semantic-ish minor releases for user-facing additions

Examples:
- `0.2.0` starter improvements
- `0.3.0` packaging and installer work
- `1.0.0` first stable public release

## What to release

At minimum, publish:
- the Git repository
- the ISO
- a release notes file
- checksums

Optional:
- screenshots
- changelog
- documentation bundle
- package repo metadata later

## Git workflow

Typical public release flow:

```bash
git add -A
git commit -m "Release 0.3.0"
git tag v0.3.0
git push origin main --tags
```

## Create a GitHub release with an ISO

Using GitHub CLI:

```bash
gh release create v0.3.0 ./debianmoss-amd64.hybrid.iso \
  --repo masi621/moss-os \
  --title "DebianMOSS 0.3.0" \
  --notes "Initial DebianMOSS live ISO release."
```

## Checksums

Generate at least SHA256:

```bash
sha256sum debianmoss-amd64.hybrid.iso > debianmoss-amd64.hybrid.iso.sha256
```

Upload both the ISO and checksum file.

## Release notes checklist

Include:
- base Debian release
- notable package changes
- desktop/session changes
- tooling changes
- known limitations
- tested environments

## Suggested tested environments section

Document separately:
- QEMU
- VirtualBox
- real hardware
- UEFI vs BIOS
- persistence or installed mode, if supported

## Publishing advice

Never claim:
- universal hardware support
- full daily-driver readiness
- every hypervisor works
unless you have actually tested those things.

Claim exactly what you tested.

That will save you a ridiculous amount of pain.
