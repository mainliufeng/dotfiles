#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_PATH_DEFAULT="$ROOT_DIR/config/manifest.json"

expand_path() {
  local p="$1"
  if [[ "$p" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "$p" == "~/"* ]]; then
    printf '%s\n' "$HOME/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

require_bin() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Error: missing command '$name'" >&2
    exit 1
  fi
}

resolve_targets() {
  local target="$1"
  case "$target" in
    codex)
      printf '%s\n' "codex"
      ;;
    claude)
      printf '%s\n' "claude"
      ;;
    all)
      printf '%s\n' "codex" "claude"
      ;;
    *)
      echo "Error: invalid --target '$target' (use codex|claude|all)" >&2
      exit 1
      ;;
  esac
}
