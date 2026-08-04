#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install python pyenv pyenv-virtualenv pipx
    ;;
  Linux)
    sudo pacman -S --needed python-pip
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed pyenv pyenv-virtualenv
    else
      sudo pacman -S --needed pyenv
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

if command -v pipx >/dev/null 2>&1; then
  if command -v notebooklm >/dev/null 2>&1; then
    echo "[python] notebooklm already installed"
  else
    pipx install notebooklm-py
  fi
fi
