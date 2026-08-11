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

The macOS `obsidian` module installs the pinned Front Matter Title plugin and its Knowledge-vault preset so English filenames can be displayed as Chinese frontmatter titles.
