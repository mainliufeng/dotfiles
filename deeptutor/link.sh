#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/dotfiles/deeptutor/deeptutor-local" "$HOME/.local/bin/deeptutor-local"
