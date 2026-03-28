# Custom WM / session support

DebianMOSS uses a session wrapper at `/usr/local/bin/debianmoss-xsession`.
That wrapper reads `~/.config/debianmoss/session`.

## Set XFCE

```bash
moss-session use xfce
```

## Set Openbox

```bash
moss-session use openbox
```

## Use your own WM or compositor

```bash
moss-session use custom "i3"
moss-session use custom "awesome"
moss-session use custom "$HOME/dev/mywm/start.sh"
```
