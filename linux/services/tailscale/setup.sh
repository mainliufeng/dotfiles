#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "tailscale setup is only supported on Linux" >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman is required for this dotfiles module" >&2
  exit 1
fi

operator="${TAILSCALE_OPERATOR:-${SUDO_USER:-${USER}}}"

echo "[tailscale] installing package"
sudo pacman -S --needed tailscale

echo "[tailscale] enabling tailscaled"
sudo systemctl enable --now tailscaled

if sudo tailscale set --ssh=true --operator="$operator" >/dev/null 2>&1; then
  echo "[tailscale] enabled Tailscale SSH for operator: $operator"
else
  echo "[tailscale] logging in and enabling Tailscale SSH"
  sudo tailscale up --ssh --operator="$operator"
fi

if ! tailscale status --json 2>/dev/null | grep -q '"BackendState": "Running"'; then
  echo "[tailscale] login required"
  sudo tailscale up --ssh --operator="$operator"
fi

if systemctl is-enabled --quiet sshd || systemctl is-active --quiet sshd; then
  cat <<'EOF'
[tailscale] note: system sshd is enabled or running.
[tailscale] Tailscale SSH does not require sshd.service. If you do not need
[tailscale] traditional LAN/public SSH, consider:
[tailscale]   sudo systemctl disable --now sshd
EOF
fi

cat <<'EOF'
[tailscale] next step: verify tailnet SSH policy allows this host.
[tailscale] Recommended policy snippet is in linux/services/tailscale/README.md.
EOF
