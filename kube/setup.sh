#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install kubernetes-cli
    ;;
  Linux)
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed kubectl
    else
      sudo pacman -S --needed kubectl
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac
