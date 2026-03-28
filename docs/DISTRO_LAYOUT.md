# DebianMOSS distro layout

- `auto/` → compatibility wrapper for the native builder
- `config/package-lists/` → package sets
- `config/includes.chroot/` → files copied into the live rootfs
- `config/hooks/live/` → scripts executed late in chroot customization
- `assets/` → branding and theme assets
- `docs/` → developer and distro docs
- `scripts/` → host setup and validation tools
