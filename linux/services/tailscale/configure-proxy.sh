#!/usr/bin/env bash
set -euo pipefail

proxy="${TAILSCALE_HTTPS_PROXY:-${https_proxy:-${HTTPS_PROXY:-}}}"

if [[ -z "$proxy" ]]; then
  cat <<'EOF' >&2
Set TAILSCALE_HTTPS_PROXY or https_proxy first.

Example:
  TAILSCALE_HTTPS_PROXY=http://127.0.0.1:7897 bash linux/services/tailscale/configure-proxy.sh
EOF
  exit 1
fi

sudo install -d -m 0755 /etc/systemd/system/tailscaled.service.d
sudo tee /etc/systemd/system/tailscaled.service.d/proxy.conf >/dev/null <<EOF
[Service]
Environment=HTTP_PROXY=$proxy
Environment=HTTPS_PROXY=$proxy
Environment=NO_PROXY=localhost,127.0.0.1,::1,100.64.0.0/10,fd7a:115c:a1e0::/48
EOF

sudo systemctl daemon-reload
sudo systemctl restart tailscaled

echo "[tailscale] configured tailscaled proxy: $proxy"
echo "[tailscale] restarted tailscaled"
