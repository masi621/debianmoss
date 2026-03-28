# App Tutorials

This document is tutorial-first. Copy the examples, run them, then adapt.

## Tutorial 1: Build a tiny C terminal tool

Create the project:

```bash
mossdev new c hello-c
cd hello-c
```

Build it:

```bash
make
./hello-c
```

Install it for your user:

```bash
install -Dm755 hello-c ~/.local/bin/hello-c
```

Run it from anywhere:

```bash
hello-c
```

## Tutorial 2: Turn that tool into a launcher-visible app

Create a desktop file:

```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/hello-c.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Hello C
Exec=/home/$USER/.local/bin/hello-c
Icon=utilities-terminal
Terminal=true
Categories=Development;Utility;
EOF
```

Log out and back in if your menu does not refresh automatically.

## Tutorial 3: Build a Python app with pip

```bash
mossdev new python hello-py
cd hello-py
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

Now run it either as the Python module or as the installed command.

If you want it launcher-visible, create a `.desktop` file pointing at the installed executable.

## Tutorial 4: Build and install a Rust tool

```bash
mossdev new rust hello-rs
cd hello-rs
cargo run
cargo install --path . --root ~/.local
```

Ensure your `~/.local/bin` is on `PATH`.

## Tutorial 5: Build a custom WM/session command

```bash
mossdev new wm mywm
cd mywm
chmod +x start.sh
./start.sh
```

Set it as your current session:

```bash
moss-session use custom "$PWD/start.sh"
```

If the script works under X, it can become your session entry point.

## Tutorial 6: Install a source repo manually

```bash
git clone https://github.com/example/project ~/dev/project
cd ~/dev/project
```

Then inspect which build system it uses:
- `Makefile`
- `CMakeLists.txt`
- `meson.build`
- `Cargo.toml`
- `pyproject.toml`

Build and install accordingly.

## Tutorial 7: Add an app manifest for mosspkg

Create `mossapp.json` in the project root:

```json
{
  "name": "Cool Tool",
  "exec": "/home/moss/.local/bin/cool-tool",
  "icon": "utilities-terminal",
  "terminal": false,
  "categories": "Development;Utility;"
}
```

Then let your helper generate the desktop entry if you wire `mosspkg` to do that.

## Tutorial 8: Replace the default session with Openbox

```bash
moss-session use openbox
```

Log out, log in again, and test.

## Tutorial 9: Put your own script on the desktop menu

Make the script executable:

```bash
chmod +x ~/bin/myscript
```

Create:

```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/myscript.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=My Script
Exec=/home/$USER/bin/myscript
Icon=utilities-terminal
Terminal=true
Categories=Utility;
EOF
```

## Tutorial 10: Ship an app with the distro itself

For a distro-bundled app:

1. put the executable or source-built artifact into `config/includes.chroot/usr/local/bin/`
2. add a desktop file under `config/includes.chroot/usr/share/applications/`
3. rebuild the ISO

That makes it part of the live image.
