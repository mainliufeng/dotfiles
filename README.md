# mainliufeng's dotfiles

Cross-platform dotfiles for macOS and Linux.

## Usage

```bash
./setup.sh
./link.sh
```

The top-level entrypoints detect the current platform and run common modules plus the matching platform modules.

Useful variants:

```bash
./link.sh --common-only
./link.sh --platform-only
./setup.sh --platform macos
./setup.sh --platform linux
./link.sh --dry-run
```

Common modules live at the repo root. Linux-only modules live under `linux/`; macOS-only setup lives under `macos/`.
