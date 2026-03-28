# Building Programs on DebianMOSS

DebianMOSS is a normal Debian-based system with a developer-first package set.

## Included toolchains and tools

The starter distro includes or is designed to include:

- GCC / G++
- Clang / clangd
- make
- CMake
- Meson / Ninja
- Python / pip / venv / pipx
- Rust / Cargo
- Go
- Java
- Git / gh
- Neovim / tmux / ripgrep / fd / bat / jq / yq

## Project location conventions

Recommended per-user layout:

```text
~/dev        source trees
~/build      scratch build output
~/.local/bin user-installed binaries
~/.local/share/applications desktop entries
```

## Quick scaffolding with mossdev

### C
```bash
mossdev new c hello-c
cd hello-c
make
./hello-c
```

### C++
```bash
mossdev new cpp hello-cpp
cd hello-cpp
cmake -S . -B build
cmake --build build
./build/hello-cpp
```

### Python
```bash
mossdev new python hello-py
cd hello-py
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
python __APP_NAME__.py
```

### Rust
```bash
mossdev new rust hello-rs
cd hello-rs
cargo run
cargo install --path . --root ~/.local
```

### Go
```bash
mossdev new go hello-go
cd hello-go
go run .
go build
install -Dm755 hello-go ~/.local/bin/hello-go
```

### Custom WM starter
```bash
mossdev new wm mywm
cd mywm
cat README.md
```

## Terminal-first program guidelines

A terminal program should:
- print helpful usage when called with `--help`
- return nonzero on failure
- install to `~/.local/bin` for user-local installs
- avoid writing into `/usr/local` unless you intend a system-wide install

## Desktop app guidelines

A desktop app needs:
- a real executable
- an icon or sensible fallback
- a `.desktop` file in `~/.local/share/applications/`
- `Terminal=true` only if it needs a terminal

Example desktop entry:

```ini
[Desktop Entry]
Type=Application
Name=Hello App
Exec=/home/moss/.local/bin/hello-app
Icon=utilities-terminal
Terminal=false
Categories=Development;Utility;
```

## Runtime dependency philosophy

When you build apps:
- prefer distro packages for libraries
- vendor only when absolutely necessary
- document extra build dependencies in the project README
- do not turn every app into a snowflake

## Install methods

### Local user install
Best for personal development:

```bash
install -Dm755 mytool ~/.local/bin/mytool
```

### System-wide install
Use only when you really mean it:

```bash
sudo install -Dm755 mytool /usr/local/bin/mytool
```

### Package-based install
Best long-term answer for apps you plan to keep:
- build a `.deb`
- or later add a proper DebianMOSS packaging flow

## Recommended standards for apps you ship with the distro

- README
- license file
- build instructions
- clear install location
- `.desktop` entry if GUI-facing
- uninstall instructions
- versioning
