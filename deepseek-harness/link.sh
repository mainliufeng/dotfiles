#!/usr/bin/env bash
# deepseek-harness — link the `dsh-app` launcher onto PATH (common module).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$ROOT_DIR/bin/dsh-app"

mkdir -p "$HOME/.local/bin"
chmod +x "$BIN"
ln -sfn "$BIN" "$HOME/.local/bin/dsh-app"

echo "[deepseek-harness] linked -> $HOME/.local/bin/dsh-app"
