#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install --cask font-hack-nerd-font
    ;;
  Linux)
    sudo pacman -S --needed adobe-source-han-serif-cn-fonts noto-fonts-cjk
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed ttf-hack-nerd
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac
