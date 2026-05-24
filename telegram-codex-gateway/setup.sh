#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CMD="$ROOT_DIR/bin/telegram-codex-gateway"

case "$(uname -s)" in
  Darwin)
    "$ROOT_DIR/link.sh"
    "$CMD" install-local "${MOBIUS_REPO:-$HOME/Code/self/mobius}"
    "$CMD" install-launchd
    if "$CMD" doctor | grep -q '^env_ready=yes$'; then
      "$CMD" restart
    else
      echo "[telegram-codex-gateway] installed but not started; configure $("$CMD" env-path)"
    fi
    ;;
  *)
    echo "telegram-codex-gateway setup is currently managed here for macOS only." >&2
    echo "On Linux, use the mobius service script: apps/telegram-codex-gateway/service/scripts/telegram-codex-gateway deploy" >&2
    ;;
esac
