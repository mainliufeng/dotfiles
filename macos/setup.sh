#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$ROOT_DIR/macos/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Homebrew is required for macOS setup.
Install it from https://brew.sh, then re-run ./setup.sh.
EOF
  exit 1
fi

echo "[macos] Homebrew: $(brew --version | head -n 1)"
echo "[macos] Applying $BREWFILE"
brew bundle --file "$BREWFILE"

if [[ -d /Applications/Codex.app ]]; then
  echo "[macos] Codex.app detected"
fi

if [[ -d /Applications/Ghostty.app ]]; then
  echo "[macos] Ghostty.app detected"
fi
