#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.local/bin"
chmod +x "$ROOT_DIR/bin/telegram-codex-gateway" "$ROOT_DIR/bin/telegram-codex-gateway-run"
ln -sfn "$ROOT_DIR/bin/telegram-codex-gateway" "$HOME/.local/bin/telegram-codex-gateway"

echo "[telegram-codex-gateway] linked command -> $HOME/.local/bin/telegram-codex-gateway"
