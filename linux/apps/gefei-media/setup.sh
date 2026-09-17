#!/usr/bin/env bash
# Install / refresh the gefei-media web app (phone-viewable share videos + docs).
#
#   1. builds the site from ~/Documents/gefei-share (thumbnail + doc conversion cache)
#   2. installs a `systemd --user` service serving it on 127.0.0.1 + Tailscale
#   3. registers the public path (default /gefei-media) via `tailscale serve`
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$ROOT_DIR/sites.conf"
UNIT_DIR="$HOME/.config/systemd/user"

# name|root|port|base_path|app_name|app_short
IFS='|' read -r NAME MROOT PORT BASE_PATH _APP_NAME _APP_SHORT < <(grep -v '^#' "$CONF" | grep -v '^$' | head -1)
MROOT="$HOME/$MROOT"

chmod +x "$ROOT_DIR"/bin/*

# --- 1. build ---------------------------------------------------------------
python3 "$ROOT_DIR/bin/gefei-media-build"

# --- 2. systemd --user service ---------------------------------------------
mkdir -p "$UNIT_DIR"
cat > "$UNIT_DIR/gefei-media.service" <<UNIT
[Unit]
Description=gefei-media share videos/docs web app (Tailscale-only)
After=network-online.target tailscaled.service

[Service]
Type=simple
ExecStart=%h/dotfiles/linux/apps/gefei-media/bin/gefei-media-serve
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
UNIT
systemctl --user daemon-reload
systemctl --user enable --now gefei-media.service
echo "[gefei-media] systemd --user service: gefei-media.service"

# --- 3. tailscale serve (HTTPS, path on 443) -------------------------------
if command -v tailscale >/dev/null 2>&1; then
  if tailscale serve --bg --https=443 --set-path="$BASE_PATH" "http://127.0.0.1:$PORT" >/dev/null 2>&1; then
    echo "[gefei-media] tailscale serve: https://<tailnet>${BASE_PATH}/ -> 127.0.0.1:$PORT"
  else
    echo "[gefei-media] WARN: tailscale serve failed; run 'sudo tailscale set --operator=$USER' once" >&2
  fi
fi

echo "[gefei-media] done. Rebuild after new downloads with: gefei-media-build"
