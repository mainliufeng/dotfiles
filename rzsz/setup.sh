#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install lrzsz
    ;;
  Linux)
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed lrzsz
    else
      sudo pacman -S --needed lrzsz
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

# 从服务器下载文件sz /a/b/c.txt
