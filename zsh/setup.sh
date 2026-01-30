#!/bin/sh
set -e

if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed zsh
  # zplug
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  # powerlevel10k + common completions
  sudo pacman -S --needed zsh-theme-powerlevel10k zsh-completions zsh-history-substring-search zsh-syntax-highlighting
  chsh -s /usr/bin/zsh
elif command -v brew >/dev/null 2>&1; then
  brew install zsh zplug powerlevel10k
  chsh -s "$(command -v zsh)"
else
  echo "Please install zsh using your package manager (pacman/brew)." >&2
  exit 1
fi
