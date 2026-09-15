#!/usr/bin/env bash
# Install / refresh the Tailnet portal (the front door of the tailnet).
#
#   1. builds the portal page from sites.tsv
#   2. installs a `systemd --user` service serving it on 127.0.0.1 + Tailscale
#   3. proxies the tailnet root (https://<tailnet>/) to it, and registers the
#      /workbench path for the Knowledge Workbench (which used to own the root)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIT_DIR="$HOME/.config/systemd/user"
PORT="${TAILNET_PORTAL_PORT:-8093}"
WORKBENCH_TARGET="${WORKBENCH_TARGET:-http://100.79.161.127:8791}"
ENTITY_TARGET="${ENTITY_TARGET:-http://100.79.161.127:8787}"

chmod +x "$ROOT_DIR"/bin/*

# --- 1. build ---------------------------------------------------------------
python3 "$ROOT_DIR/bin/tailnet-portal-build"

# --- 2. systemd --user service ---------------------------------------------
mkdir -p "$UNIT_DIR"
cat > "$UNIT_DIR/tailnet-portal.service" <<EOF
[Unit]
Description=Tailnet portal (front door)
After=network-online.target tailscaled.service

[Service]
Type=simple
ExecStart=%h/dotfiles/linux/apps/tailnet-portal/bin/tailnet-portal-serve
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now tailnet-portal.service
echo "[portal] systemd --user service: tailnet-portal.service"

# --- 3. tailscale serve -----------------------------------------------------
if command -v tailscale >/dev/null 2>&1; then
  # root -> portal (replaces whatever owned "/" before)
  tailscale serve --bg --https=443 "http://127.0.0.1:$PORT" >/dev/null 2>&1 \
    && echo "[portal] tailscale serve: https://<tailnet>/ -> 127.0.0.1:$PORT" \
    || echo "[portal] WARN: could not set the root mapping" >&2
  # Knowledge Workbench moved off the root
  tailscale serve --bg --https=443 --set-path=/workbench "$WORKBENCH_TARGET" >/dev/null 2>&1 \
    && echo "[portal] tailscale serve: /workbench -> $WORKBENCH_TARGET" \
    || echo "[portal] WARN: could not set /workbench" >&2
  # Knowledge Entity Index uses absolute URLs, so it needs its own port/root
  tailscale serve --bg --https=10000 "$ENTITY_TARGET" >/dev/null 2>&1 \
    && echo "[portal] tailscale serve: https://<tailnet>:10000/ -> $ENTITY_TARGET" \
    || echo "[portal] WARN: could not set :10000" >&2
fi

echo "[portal] done."
