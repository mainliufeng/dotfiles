#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install rustup
    export PATH="$(brew --prefix rustup)/bin:$HOME/.cargo/bin:$PATH"
    ;;
  Linux)
    sudo pacman -S --needed rustup base-devel
    export PATH="$HOME/.cargo/bin:$PATH"
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

rustup default stable
rustup component add rustfmt clippy

if [[ "$(uname -s)" == "Linux" ]]; then
  sudo pacman -S --needed gtk3 webkit2gtk libsoup libayatana-appindicator librsvg
fi

if command -v cargo-tauri >/dev/null 2>&1; then
  echo "tauri-cli is already installed"
else
  cargo install tauri-cli
fi
