#!/usr/bin/env bash
set -euo pipefail

echo "[tailscale] app:"
ls -ld /Applications/Tailscale.app 2>/dev/null || true

echo
echo "[tailscale] cli:"
tailscale_cli=""
if command -v tailscale >/dev/null 2>&1; then
  tailscale_cli="$(command -v tailscale)"
elif [[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
  tailscale_cli="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
printf '%s\n' "${tailscale_cli:-not found}"
if [[ -n "$tailscale_cli" ]]; then
  TAILSCALE_BE_CLI=1 "$tailscale_cli" version 2>/dev/null || true
fi

echo
echo "[tailscale] status:"
if [[ -n "$tailscale_cli" ]]; then
  TAILSCALE_BE_CLI=1 "$tailscale_cli" status 2>/dev/null || true
else
  echo "Install CLI integration from Tailscale.app Settings for terminal status."
fi

echo
echo "[tailscale] ip:"
if [[ -n "$tailscale_cli" ]]; then
  TAILSCALE_BE_CLI=1 "$tailscale_cli" ip -4 2>/dev/null || true
fi

echo
echo "[tailscale] prefs:"
if [[ -n "$tailscale_cli" ]]; then
  TAILSCALE_BE_CLI=1 "$tailscale_cli" debug prefs 2>/dev/null | grep -E '"RunSSH"|"OperatorUser"|"WantRunning"|"LoggedOut"|"ControlURL"' || true
fi

echo
echo "[ssh] macOS Remote Login:"
systemsetup -getremotelogin 2>/dev/null || true
