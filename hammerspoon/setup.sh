#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install --cask hammerspoon
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

