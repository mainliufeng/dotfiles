#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.local/bin"
for f in "$ROOT_DIR"/bin/*; do
  chmod +x "$f"
  ln -sfn "$f" "$HOME/.local/bin/$(basename "$f")"
  echo "[portal] linked -> $HOME/.local/bin/$(basename "$f")"
done
