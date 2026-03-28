# Custom Sessions and Window Managers

## The model

DebianMOSS does not try to fake a full custom desktop stack from thin air.

Instead, it gives you a wrapper that can launch:
- XFCE
- Openbox
- a custom command
- your own WM/compositor script

This is the smart way to experiment without rebuilding the whole OS around every idea.

## Session entry point

The project uses:

```text
/usr/local/bin/debianmoss-xsession
```

That wrapper reads your per-user session choice, typically from:

```text
~/.config/debianmoss/session
```

## See current status

```bash
moss-session status
```

## Use XFCE

```bash
moss-session use xfce
```

## Use Openbox

```bash
moss-session use openbox
```

## Use your own WM

Examples:

```bash
moss-session use custom "i3"
moss-session use custom "awesome"
moss-session use custom "$HOME/dev/mywm/start.sh"
```

## What makes a good custom session script

A good session script should:
- be executable
- set up environment variables it needs
- launch exactly one long-running WM/compositor process
- not daemonize itself into weirdness unless that is intentional
- exit cleanly so LightDM can return to the greeter

Minimal example:

```bash
#!/usr/bin/env bash
set -euo pipefail

xsetroot -solid "#1d241f"
exec openbox-session
```

## Developing your own WM on DebianMOSS

Reasonable paths:
- configure an existing WM heavily
- write scripts around Openbox or i3
- build an X11 WM as a learning project
- experiment with a Wayland compositor later, once the distro base is stable

Unreasonable first move:
- write a giant custom compositor before the distro basics are solid

## Distro-level custom default session

If you want the live image itself to default to a different session, update:
- session-related defaults under `config/includes.chroot/etc/skel/`
- session hooks under `config/hooks/live/`

Then rebuild.

## Safety advice

Keep one known-good session available.

If your custom WM breaks, switch back with:

```bash
moss-session use xfce
```

That keeps you from locking yourself out of your own desktop experiments.
