# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is mainliufeng's personal dotfiles repository for configuring a Linux development environment. The repository follows a modular structure where each major component (nvim, git, awesome, zsh, etc.) has its own directory with setup scripts, configuration files, and linking scripts.

## Setup and Installation Commands

### Initial Setup
```bash
# Run the main development setup script (Chinese prompts)
sh 1_dev/setup.sh

# Install individual components 
sh <component>/setup.sh    # Install dependencies for specific component
sh <component>/link.sh     # Create symbolic links for component configs
```

### Key Setup Scripts
- `1_dev/setup.sh` - Main development environment setup with error handling and retry logic
- `link.sh` - Root script that calls all individual component `link.sh` scripts
- `scripts/dotfiles-setup-scripts` - Copies all custom scripts to `/usr/local/bin/`

### Development Tools Installation
The setup installs essential development tools including:
- Base packages: `yay`, `base-devel`, `ripgrep`, `fzf`, `fasd`, `htop`
- Development languages: Go, Node.js/npm, Python
- Containerization: Docker, Kubernetes tools
- Editor: Neovim with extensive plugin configuration

## Architecture and Key Components

### Neovim Configuration (`nvim/`)
- **Entry point**: `init.lua` - Detects VSCode mode vs standard Neovim
- **Plugin manager**: Lazy.nvim with configuration in `lua/mainliufeng/init.lua`
- **Key plugins**: 
  - Windsurf.vim for AI code completion
  - Blink.cmp for completion engine
  - Telescope for fuzzy finding
  - LSP configuration with lspsaga
  - Debug support with nvim-dap
- **Language support**: Go (fatih/vim-go, ray-x/go.nvim), general LSP

### Window Manager (`awesome/`)
- **Configuration**: `rc.lua` - AwesomeWM configuration
- **Custom widgets**: Battery widget, scratch pad support
- **Terminal**: Uses custom `kitt` terminal
- **Key bindings**: Mod4 (Super) as primary modifier

### Shell Environment (`zsh/`)
- Environment files in various `env.zsh` and `env.sh` files
- Modular environment loading for different tools

### Custom Scripts (`scripts/`)
Contains numerous utility scripts including:
- `git-backup`, `git-restore` - Git workflow helpers
- `screenshot-ocr`, `screen-capture-*` - Screen capture utilities
- `chatsh`, `mobius_*` - AI/automation tools
- `dotfiles-setup-*` - Environment management

### Claude Code Integration (`claude-code/`)
- Custom statusline configuration showing directory, git branch, changes, model, and output style
- Settings example with autoSave enabled and 4000 token limit

## File Linking Strategy

Each component directory contains:
- `setup.sh` - Installs dependencies
- `link.sh` - Creates symbolic links to `~/.config/` or appropriate locations
- Configuration files that get linked

The root `link.sh` iterates through all directories and calls their individual `link.sh` scripts.

## Development Workflow

1. **Environment setup**: Run `1_dev/setup.sh` for complete environment setup
2. **Individual updates**: Use component-specific setup scripts for targeted updates
3. **Script installation**: Run `scripts/dotfiles-setup-scripts` to update custom utilities
4. **Configuration changes**: Edit files in place - they're already linked to system locations

## Language-Specific Notes

- **Go**: Includes delve debugger, graphviz for visualization
- **Python**: Custom pip configuration, development tools
- **JavaScript/Node**: Basic npm setup
- **Shell**: Extensive zsh configuration with custom environment variables

This dotfiles setup is optimized for a Linux development environment with focus on Go development, system administration, and window management efficiency.