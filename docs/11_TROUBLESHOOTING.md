# Troubleshooting

## Build problems

### `debootstrap: command not found`
Cause:
- you are on a host without the build dependencies installed

Fix:
- use a Debian host, Debian container, or Debian VM
- or install the host dependencies from `scripts/install-host-deps-*.sh`

### package installation fails during build
Cause:
- wrong package name
- package not in the selected Debian release
- transient network/repo issue

Fix:
- verify the package name
- remove the package from the list and rebuild
- test with a smaller package set first

### hook script fails
Cause:
- a script in `config/hooks/live/` exited nonzero

Fix:
- run the hook body manually inside a Debian environment
- add `set -x` or logging
- keep hooks small and obvious

### permissions errors
Cause:
- build started without required privileges

Fix:
```bash
sudo ./build.sh
```

## Runtime problems

### boots to console or fails to reach the greeter
Cause:
- LightDM/X stack issue
- bad session config
- broken custom WM selection

Fix:
- switch back to a known-good session
- check `/var/log/lightdm/`
- test with XFCE as the default again

### custom session black screen
Cause:
- the WM command exits instantly
- bad path in `~/.config/debianmoss/session`
- the script never `exec`s the main process

Fix:
```bash
moss-session use xfce
```
Then fix the custom script.

### desktop launcher does not appear
Cause:
- `.desktop` file missing
- wrong permissions
- invalid entry fields
- desktop cache/menu did not refresh

Fix:
- validate the file contents
- keep it in `~/.local/share/applications/` or `/usr/share/applications/`
- relog if needed

### command not found for a user-installed app
Cause:
- app installed to `~/.local/bin`, but PATH does not include it

Fix:
ensure your shell init includes:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Packaging confusion

### `mosspkg` does not behave like apt
That is expected. `mosspkg` is a helper, not the system package manager.

Use:
- `apt` for system packages
- `flatpak` for selected GUI apps
- `mosspkg` for source/community/MOSS helper workflows

## Virtualization issues

### QEMU works, VirtualBox acts weird
Treat hypervisors as separate targets.

Fix path:
- get QEMU clean first
- then test VirtualBox specifically
- then adjust graphics/input packages and defaults as needed

Do not assume one success means universal success.

## When in doubt

Return to the boring baseline:
- XFCE
- stock Debian packages
- no custom session
- no custom WM
- no experimental hooks

Once that works, add complexity one layer at a time.
