# Building programs on DebianMOSS

DebianMOSS is a normal Debian-based system, so the default answer is:

- use `apt` for distro packages
- use standard build systems
- install user-built apps into `~/.local`
- add desktop entries into `~/.local/share/applications`

## Toolchain already included

- GCC / G++
- Clang / clangd
- make
- CMake
- Meson + Ninja
- Python + pip + venv + pipx
- Rust + Cargo
- Go
- Java (default-jdk)
- Git / gh
- Neovim / tmux / ripgrep / fd / bat

## Fast start

### C

```bash
mossdev new c hello-c
cd hello-c
make
./hello-c
```

### Python

```bash
mossdev new python hello-py
cd hello-py
python3 -m pip install --user .
hello-py
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

## WM / desktop apps

For a launcher-visible app, add a `.desktop` file to `~/.local/share/applications`.
`mosspkg` can also build one from `mossapp.json`.
