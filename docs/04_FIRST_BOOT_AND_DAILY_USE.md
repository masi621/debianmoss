# First Boot and Daily Use

## What to expect on first boot

A successful boot should bring you to the LightDM greeter and then into the default XFCE session, with DebianMOSS branding already applied.

Typical first impressions:
- green MOSS-styled wallpaper
- MOSS issue/MOTD text in terminal sessions
- `moss-welcome` available
- development tools already installed
- `moss-session`, `mossdev`, and `mosspkg` on the path

## Default user model

Depending on how the hooks are configured, the live user is usually created automatically by the live environment. Check with:

```bash
whoami
id
```

## First commands to run

```bash
moss-welcome
moss-session status
python3 --version
gcc --version
cargo --version
go version
```

## Daily usage model

DebianMOSS is meant to be used like a normal Debian desktop with extra developer conveniences.

Use it like this:
- install system packages with `apt`
- use `mosspkg` for source helpers or MOSS-style app metadata
- use `mossdev` to scaffold projects
- switch sessions with `moss-session`
- keep custom code under `~/dev` or a similar user-owned path

## Basic desktop tasks

### Open a terminal
Use XFCE Terminal from the menu or launcher.

### Change wallpaper
If the bundled helper exists:

```bash
moss-set-wallpaper /path/to/file.png
```

### Create project directories
A sane convention:

```bash
mkdir -p ~/dev ~/build ~/bin ~/notes
```

### Install a common package
```bash
sudo apt update
sudo apt install -y git-lfs
```

## Common use cases

### Coding workstation
- open terminal
- scaffold with `mossdev`
- edit in Neovim or another editor
- build locally
- launch from the terminal or desktop entry

### Live rescue/developer environment
Because this is a live Debian system, it is also useful as:
- a portable coding image
- a hardware test environment
- a quick GUI live distro
- a custom session playground

### WM testing box
Use `moss-session` to switch between XFCE, Openbox, or your own WM without rebuilding the whole distro.

## Persistence notes

If you boot as a pure live ISO without installation or configured persistence:
- changes may disappear on reboot
- user-installed packages and files may not survive

If you want a real daily-use environment:
- install it to disk, or
- configure persistence properly, or
- move to a proper installed DebianMOSS target later

## What this distro is good at right now

- live booting
- development tooling
- desktop experimentation
- branding experiments
- building a Debian-based custom distro
- testing custom sessions and WMs

## What it is not automatically good at

- replacing every mature desktop distro feature on day one
- acting like a polished KDE clone without extra work
- becoming a daily driver without installation, testing, and maintenance
