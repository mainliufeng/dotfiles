#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install neovim delve pyright bash-language-server lua-language-server universal-ctags uv
    ;;
  Linux)
    sudo pacman -S --needed neovim delve ctags uv
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed pyright bash-language-server lua-language-server
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

if command -v go >/dev/null 2>&1; then
  go install golang.org/x/tools/gopls@latest
fi
