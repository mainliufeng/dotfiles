#!/usr/bin/env bash
set -euo pipefail

echo "[tailscale] package:"
pacman -Q tailscale 2>/dev/null || true

echo
echo "[tailscale] daemon:"
systemctl --no-pager --full status tailscaled 2>/dev/null | sed -n '1,18p' || true

echo
echo "[tailscale] service environment:"
systemctl show tailscaled -p Environment 2>/dev/null || true

echo
echo "[tailscale] status:"
tailscale status 2>/dev/null || true

echo
echo "[tailscale] ip:"
tailscale ip -4 2>/dev/null || true

echo
echo "[ssh] listeners:"
ss -tlnp | rg ':(22)\b|tailscale|sshd' || true

echo
echo "[ssh] sshd service:"
systemctl is-enabled sshd 2>/dev/null || true
systemctl is-active sshd 2>/dev/null || true
