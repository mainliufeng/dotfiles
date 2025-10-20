#!/usr/bin/env bash

# Launch Windows Chrome with a remote debugging port that chrome-devtools-mcp can attach to.
# Usage: start-chrome-remote.sh [optional URL]

set -euo pipefail

CHROME_PATH="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
REMOTE_PORT="${REMOTE_DEBUG_PORT:-9222}"
USER_DATA_DIR="$HOME/.cache/chrome-devtools-codex"

if ! [ -f "$CHROME_PATH" ]; then
  echo "Chrome executable not found at: $CHROME_PATH" >&2
  exit 1
fi

mkdir -p "$USER_DATA_DIR"

WIN_USER_DATA_DIR=$(wslpath -w "$USER_DATA_DIR")

nohup "$CHROME_PATH" \
  --remote-debugging-port="$REMOTE_PORT" \
  --remote-debugging-address="0.0.0.0" \
  --remote-allow-origins="*" \
  --user-data-dir="$WIN_USER_DATA_DIR" \
  --no-first-run \
  --no-default-browser-check \
  "$@" >/dev/null 2>&1 &

echo "Chrome launched on port $REMOTE_PORT (profile: $WIN_USER_DATA_DIR). Close the browser window to stop it."
