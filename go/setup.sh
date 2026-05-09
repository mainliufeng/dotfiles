#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install go
    ;;
  Linux)
    sudo pacman -S --needed go
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

go env -w GO111MODULE=on
