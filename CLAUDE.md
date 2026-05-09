# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is mainliufeng's personal dotfiles repository for configuring shared macOS/Linux development environments plus a Linux desktop setup. The repository follows a modular structure where common components (nvim, git, zsh, codex, etc.) live at the repo root, Linux-only components live under `linux/`, and macOS setup lives under `macos/`.

## Setup and Installation Commands

### Initial Setup
```bash
# Run common setup plus the current platform setup
./setup.sh

# Link common configs plus the current platform configs
./link.sh

# Dry-run without touching the system
./link.sh --dry-run

# Install individual components 
sh <component>/setup.sh    # Install dependencies for specific component
sh <component>/link.sh     # Create symbolic links for component configs
```

### Key Setup Scripts
- `setup.sh` - Root setup entrypoint; runs common modules and the detected platform modules
- `link.sh` - Root link entrypoint; runs common modules and the detected platform modules
- `modules/common.txt`, `modules/linux.txt`, `modules/macos.txt` - Explicit module lists used by the entrypoints
- `linux/arch/1_dev/setup.sh` - Arch development environment setup with Chinese prompts
- `linux/scripts/dotfiles-setup-scripts` - Copies common and Linux custom scripts to `/usr/local/bin/`

### Development Tools Installation
The setup installs essential development tools including:
- Base packages: `yay`, `base-devel`, `ripgrep`, `fzf`, `fasd`, `htop`
- Development languages: Go, Node.js/npm, Python
- Containerization: Docker, Kubernetes tools
- Editor: Neovim with extensive plugin configuration

## Architecture and Key Components

### Neovim Configuration (`nvim/`)
- **Entry point**: `init.lua` - Detects VSCode mode vs classic Neovim
- **Plugin manager**: Lazy.nvim (`lua/mainliufeng/init.lua`)
- **Key plugins**: 
  - Blink.cmp for completion & snippets
  - Snacks.nvim terminal replacing toggleterm
  - Telescope for fuzzy finding
  - lspsaga + go.nvim + nvim-dap for LSP/Debug
  - go-debug.lua & .env 支持用于 Go Tests
- **Language support**: 强化 Go（fatih/vim-go, ray-x/go.nvim），同时保持通用 LSP 能力

### Linux Desktop (`linux/desktop/`)

Linux desktop modules live under `linux/desktop/`, including Hyprland, AwesomeWM, Xorg, Wayland, Rofi, Mako, KDE, GNOME, and related configuration.

### Window Manager (`linux/desktop/awesome/`)
- **Configuration**: `rc.lua` - AwesomeWM configuration
- **Custom widgets**: Battery widget, scratch pad support
- **Terminal**: Uses custom `kitt` terminal
- **Key bindings**: Mod4 (Super) as primary modifier

### Shell Environment (`zsh/`)
- Environment files in various `env.zsh` and `env.sh` files
- Modular environment loading for different tools

### Custom Scripts (`scripts/`, `linux/scripts/`)
Common scripts remain in `scripts/`; Linux-only desktop/system helpers live in `linux/scripts/`. They include:
- `git-backup`, `git-restore` - Git workflow helpers
- `screenshot-ocr`, `screen-capture-*` - Screen capture utilities
- `chatsh`, `mobius_*` - AI/automation tools
- `dotfiles-setup-*` - Environment management
- `start-chrome-remote` - launches Chrome/Chromium with a remote debugging port for Codex MCP

### Claude Code & Codex (`claude-code/`, `codex/`)
- Claude Code: hooks, statusline, commands, cross-platform notification script
- Codex: managed `~/.codex` config with Chrome DevTools MCP server and launch helper

### Terminal Multiplexer (`zellij/`)
- `config.kdl` defines shared keybinds (Alt+m fullscreen, Alt-based focus tweaks) and mouse behaviour
- `zellij/setup.sh` installs/links the config and is invoked by the root setup entrypoint

## File Linking Strategy

Each component directory contains:
- `setup.sh` - Installs dependencies
- `link.sh` - Creates symbolic links to `~/.config/` or appropriate locations
- Configuration files that get linked

The root entrypoints use explicit module lists in `modules/`; they do not scan every directory. This keeps macOS from accidentally running Linux-only scripts.

## Development Workflow

1. **Environment setup**: Run `./setup.sh`; Arch-specific legacy setup lives at `linux/arch/1_dev/setup.sh`
2. **Individual updates**: Use component-specific setup scripts for targeted updates
3. **Script installation**: Run `linux/scripts/dotfiles-setup-scripts` on Linux to update custom utilities
4. **Configuration changes**: Edit files in place - they're already linked to system locations

## Language-Specific Notes

- **Go**: Includes delve debugger, graphviz for visualization
- **Python**: Custom pip configuration, development tools
- **JavaScript/Node**: Basic npm setup
- **Shell**: Extensive zsh configuration with custom environment variables

This dotfiles setup is optimized for shared development tooling across macOS and Linux, with an additional Arch/Linux desktop layer.
