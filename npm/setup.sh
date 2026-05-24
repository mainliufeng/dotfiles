#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin) ;;
  *)
    echo "[npm] global npm CLI setup is currently managed for macOS only; skipping."
    exit 0
    ;;
esac

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to install global npm CLIs" >&2
  exit 1
fi

NPM_GLOBAL_HOME="${NPM_GLOBAL_HOME:-$HOME/.npm-global}"
mkdir -p "$NPM_GLOBAL_HOME"

current_prefix="$(npm config get prefix 2>/dev/null || true)"
case "$current_prefix" in
  "$HOME"/*) ;;
  *) npm config set prefix "$NPM_GLOBAL_HOME" >/dev/null ;;
esac

install_global() {
  local package="$1"
  local bin_name="${2:-$1}"

  if command -v "$bin_name" >/dev/null 2>&1; then
    echo "[npm] $bin_name already installed"
    return 0
  fi

  echo "[npm] installing $package"
  if npm install -g "$package"; then
    return 0
  fi

  echo "[npm] retrying $package with npmmirror registry"
  npm install -g "$package" --registry=https://registry.npmmirror.com
}

install_global happy happy
