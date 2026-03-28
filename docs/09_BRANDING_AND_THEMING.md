# Branding and Theming

DebianMOSS gets its identity from overlays and hooks, not from rewriting the OS core.

## Where the branding lives

### Source assets
```text
assets/
```

Typical bundled assets:
- `wall-green.png`
- `newLOGO.png`
- `ascii_art.json`
- optional SVG variants

### Rootfs overlay destination
```text
config/includes.chroot/opt/debianmoss-assets/
```

### Greeter config
```text
config/includes.chroot/etc/lightdm/lightdm-gtk-greeter.conf.d/
```

### Shell defaults and MOTD
```text
config/includes.chroot/etc/profile.d/
config/includes.chroot/etc/motd
config/includes.chroot/etc/issue
```

### First-login or branding hooks
```text
config/hooks/live/
```

## Changing the wallpaper

Replace the file under:

```text
assets/wall-green.png
```

Then make sure the matching overlay copy under `config/includes.chroot/opt/debianmoss-assets/` is updated too, or make the build hook copy from `assets/` automatically.

Rebuild the ISO.

## Changing the boot logo

There are two different things people often mix up:

1. bootloader branding
2. desktop/session branding

For the starter project, the clean path is:
- use LightDM greeter branding and wallpaper for the login/session experience
- only add a bootloader splash if you really want to own that complexity

## Changing terminal/MOTD branding

Edit:
- `config/includes.chroot/etc/motd`
- `config/includes.chroot/etc/issue`
- `config/includes.chroot/etc/profile.d/debianmoss.sh`

## Changing application launchers

Desktop files live under:
```text
config/includes.chroot/usr/share/applications/
```

Change:
- Name
- Comment
- Icon
- Exec
- Categories

Then rebuild.

## Changing the default shell environment

Use files under:
```text
config/includes.chroot/etc/skel/
config/includes.chroot/etc/profile.d/
```

That is where you should put:
- aliases
- editor defaults
- PATH adjustments
- welcome text
- session hints

## Keep branding layered

Good branding:
- wallpaper
- logo
- greeter
- MOTD
- icons
- colors
- helpful helper scripts

Bad branding:
- patching everything for no reason
- replacing standard Debian behavior with brittle hacks
- coupling visual identity to low-level boot logic unless needed

## Recommended policy

Keep the visual identity strong, but keep the mechanics boring. Boring mechanics are what make a distro maintainable.
