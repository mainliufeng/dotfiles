#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install zsh zplug powerlevel10k zsh-completions zsh-history-substring-search zsh-syntax-highlighting zoxide
    ;;
  Linux)
    sudo pacman -S --needed zsh zsh-theme-powerlevel10k zsh-completions zsh-history-substring-search zsh-syntax-highlighting zoxide
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed zplug
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

if [[ "$SHELL" != *zsh ]]; then
  echo "Current shell is $SHELL. Change it manually with: chsh -s $(command -v zsh)"
fi
