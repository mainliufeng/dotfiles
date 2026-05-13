#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macOS Tailscale setup must run on Darwin" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Homebrew is required.
Install it from https://brew.sh, then re-run this script.
EOF
  exit 1
fi

echo "[tailscale] installing Tailscale.app"
brew install --cask tailscale-app

open -a Tailscale || true

tailscale_cli=""
if command -v tailscale >/dev/null 2>&1; then
  tailscale_cli="$(command -v tailscale)"
elif [[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
  tailscale_cli="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

if [[ -n "$tailscale_cli" ]] && TAILSCALE_BE_CLI=1 "$tailscale_cli" status --json 2>/dev/null | grep -q '"BackendState": "Running"'; then
  echo "[tailscale] already connected"
elif [[ -n "$tailscale_cli" ]]; then
  cat <<EOF
[tailscale] Tailscale.app is installed.
[tailscale] Log in from the app, then verify with:
[tailscale]   TAILSCALE_BE_CLI=1 "$tailscale_cli" status
EOF
else
  cat <<'EOF'
[tailscale] Tailscale.app is installed.
[tailscale] Log in from the menu bar app and install CLI integration from
[tailscale] Settings if you want terminal verification.
EOF
fi

cat <<'EOF'
[tailscale] next step: connect from this Mac to the Linux host:
[tailscale]   ssh liufeng@liufeng-82tk
EOF
