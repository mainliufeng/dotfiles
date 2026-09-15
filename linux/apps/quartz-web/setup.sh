#!/usr/bin/env bash
# Install / refresh the Quartz web mirror for the external document vaults.
#
# Idempotent. Does three things:
#   1. ensures a Quartz v5 checkout + its npm dependencies
#   2. installs a `systemd --user` service that serves every site in sites.conf
#   3. points `tailscale serve` (HTTPS on the tailnet) at each site's local port
#
# It does NOT build the sites; run `quartz-web-build` for that (slow).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUARTZ_DIR="${QUARTZ_DIR:-$HOME/Code/source/quartz}"
SITES_CONF="$ROOT_DIR/sites.conf"
UNIT_DIR="$HOME/.config/systemd/user"

chmod +x "$ROOT_DIR"/bin/*

# --- 1. Quartz checkout ------------------------------------------------------
if [[ ! -d "$QUARTZ_DIR/.git" ]]; then
  echo "[quartz-web] cloning Quartz v5 into $QUARTZ_DIR"
  mkdir -p "$(dirname "$QUARTZ_DIR")"
  git clone --depth 1 https://github.com/jackyzha0/quartz.git "$QUARTZ_DIR"
else
  echo "[quartz-web] Quartz checkout present: $QUARTZ_DIR"
fi

if [[ ! -d "$QUARTZ_DIR/node_modules" ]]; then
  echo "[quartz-web] installing npm dependencies"
  ( cd "$QUARTZ_DIR" && npm install )
fi

# npm >= 11 blocks dependency install scripts by default; esbuild's postinstall
# fetches the platform binary and is required for `quartz build`.
if command -v npm >/dev/null 2>&1; then
  ( cd "$QUARTZ_DIR" \
    && npm install-scripts approve esbuild @parcel/watcher >/dev/null 2>&1 || true
    npm rebuild esbuild @parcel/watcher >/dev/null 2>&1 || true )
fi

# --- 2. systemd --user service ----------------------------------------------
mkdir -p "$UNIT_DIR"
cat > "$UNIT_DIR/quartz-web.service" <<EOF
[Unit]
Description=Quartz web mirror for external vaults (Tailscale-only)
After=network-online.target tailscaled.service

[Service]
Type=simple
ExecStart=%h/dotfiles/linux/apps/quartz-web/bin/quartz-web-serve
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now quartz-web.service
echo "[quartz-web] systemd --user service: quartz-web.service"

# --- 3. tailscale serve (HTTPS) ---------------------------------------------
if command -v tailscale >/dev/null 2>&1; then
  while IFS='|' read -r name _vault _title _short lport base_path; do
    [[ -z "${name//[[:space:]]/}" || "$name" == \#* ]] && continue
    if tailscale serve --bg --https=443 --set-path="$base_path" \
         "http://127.0.0.1:$lport" >/dev/null 2>&1; then
      echo "[quartz-web] tailscale serve: https://<tailnet>${base_path}/ -> 127.0.0.1:$lport ($name)"
    else
      echo "[quartz-web] WARN tailscale serve failed for $name ($base_path);" \
           "run 'sudo tailscale set --operator=$USER' once, or configure it manually" >&2
    fi
  done < "$SITES_CONF"
fi

echo "[quartz-web] done. Build with: quartz-web-build"
