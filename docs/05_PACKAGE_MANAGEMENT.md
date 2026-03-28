# Package Management

There are three layers to understand:

1. `apt` — the real system package manager
2. `flatpak` — optional app delivery for GUI apps
3. `mosspkg` — helper for source-based or MOSS-style app installs

## The rule

Use `apt` first.

Use `flatpak` when a desktop app is easier to manage that way.

Use `mosspkg` when you want to:
- install a source project from a local path
- install from a Git repository or GitHub URL
- create an app entry from project metadata
- manage small MOSS-style community apps

## apt

Examples:

```bash
sudo apt update
sudo apt install -y build-essential git neovim
sudo apt remove -y package-name
sudo apt full-upgrade
```

Use `apt` for:
- drivers
- firmware
- libraries
- core desktop apps
- compilers
- system services
- runtime dependencies

## flatpak

Flatpak is useful for user-facing desktop apps that you want isolated from the base system.

Examples:

```bash
flatpak remotes
flatpak install flathub org.gimp.GIMP
flatpak run org.gimp.GIMP
```

Use Flatpak for:
- GUI apps with heavy dependencies
- apps you do not want coupled to the system root
- optional developer tools or creative apps

## mosspkg

### What it is
`mosspkg` is a convenience layer, not a replacement for Debian packaging.

### Good uses
- build a source repo locally
- install to `~/.local`
- generate a desktop entry from a simple manifest
- keep custom/community tools separate from system packages

### Bad uses
- replacing `apt`
- installing kernel modules
- doing security-critical system updates
- managing the desktop base

## Suggested install conventions

### System-wide packages
Use `apt`.

### User-owned source-built apps
Install into:
```text
~/.local/bin
```

### User-owned desktop entries
Install into:
```text
~/.local/share/applications
```

### Shared project-specific assets
Use:
```text
/opt/debianmoss-assets
```
for distro-provided assets, or project-local directories for app assets.

## Example workflow: install a source tool

```bash
git clone https://github.com/example/tool ~/dev/tool
cd ~/dev/tool
make
install -Dm755 tool ~/.local/bin/tool
```

If it is a GUI app, add a desktop file to `~/.local/share/applications/`.

## If you later package DebianMOSS properly

The long-term clean path is:

- `apt` for the OS
- `.deb` packages for DebianMOSS tools
- optional DebianMOSS repo for MOSS-specific packages
- `mosspkg` only for community/source convenience

That is the point where the distro starts feeling serious.
