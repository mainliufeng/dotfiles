#!/usr/bin/env bash
set -euo pipefail

# Restart gateway only when unhealthy.
# 1) systemd user unit is not active, or
# 2) openclaw RPC probe is not ok.

if ! systemctl --user is-active --quiet openclaw-gateway.service; then
  openclaw gateway restart >/dev/null 2>&1 || true
  exit 0
fi

status_out="$(openclaw gateway status 2>&1 || true)"
if ! grep -q "RPC probe: ok" <<<"$status_out"; then
  openclaw gateway restart >/dev/null 2>&1 || true
fi
