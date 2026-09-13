#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

package="paseo-bin"
paseo_home="${PASEO_HOME:-$HOME/.paseo}"
config_file="$paseo_home/config.json"
dry_run=0
enable_relay=1
start_now=1
tailscale_ip=""

usage() {
  cat <<'EOF'
Usage: setup.sh [options]

Install Paseo on Arch-like Linux and keep its daemon available to the phone app:

  1. installs the AUR package paseo-bin through yay (or paru)
  2. links the XDG autostart entry that starts the daemon with the session
  3. enables the end-to-end encrypted relay in ~/.paseo/config.json
  4. starts the daemon now

The desktop app bundles the daemon; the GUI attaches to the same daemon, so
launching Paseo never starts a second one. The local GUI talks to the daemon
over a unix socket, so changing the TCP listen address does not lock it out.

Options:
  --dry-run          Print the actions without changing the machine
  --no-relay         Do not enable the relay (phone access stays off until enabled)
  --no-start         Do not start the daemon now
  --tailscale        Bind daemon.listen to this machine's Tailscale IPv4 and
                     restart the daemon, so the phone can connect directly over
                     the tailnet instead of using the relay
  --tailscale-ip IP  Same as --tailscale with an explicit address
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --no-relay) enable_relay=0; shift ;;
    --no-start) start_now=0; shift ;;
    --tailscale) tailscale_ip="detect"; shift ;;
    --tailscale-ip) tailscale_ip="${2:?--tailscale-ip needs an address}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[paseo] this installer is Linux-only" >&2
  exit 1
fi

if ! grep -Eq '^(ID|ID_LIKE)=.*(arch|garuda|manjaro|endeavouros)' /etc/os-release; then
  echo "[paseo] only Arch-like Linux is managed by these dotfiles" >&2
  exit 1
fi

# 0. Resolve the Tailscale address before touching anything -------------------
if [[ "$tailscale_ip" == "detect" ]]; then
  if ! command -v tailscale >/dev/null 2>&1; then
    echo "[paseo] tailscale is not installed" >&2
    exit 1
  fi
  tailscale_ip="$(tailscale ip -4 2>/dev/null | head -n1 | tr -d '[:space:]')"
  if [[ -z "$tailscale_ip" ]]; then
    echo "[paseo] Tailscale is not connected; run 'tailscale up' first" >&2
    exit 1
  fi
fi

if [[ -n "$tailscale_ip" ]]; then
  echo "[paseo] Tailscale listen address: ${tailscale_ip}:6767"
fi

# 1. Package -----------------------------------------------------------------
if pacman -Q "$package" >/dev/null 2>&1; then
  echo "[paseo] already installed: $(pacman -Q "$package" | awk '{print $2}')"
else
  if command -v yay >/dev/null 2>&1; then
    installer=(yay -S --needed "$package")
  elif command -v paru >/dev/null 2>&1; then
    installer=(paru -S --needed "$package")
  else
    echo "[paseo] install yay or paru first, then rerun this script" >&2
    exit 1
  fi
  run "${installer[@]}"
  run pacman -Q "$package"
fi

# 2. Autostart ---------------------------------------------------------------
run "$module_dir/link.sh"

# 3. Config ------------------------------------------------------------------
# Paseo ships with the relay disabled and asks on first pairing. Pre-enabling it
# means the daemon is reachable from the phone as soon as it starts.
if [[ "$enable_relay" == "1" || -n "$tailscale_ip" ]]; then
  if [[ "$dry_run" == "1" ]]; then
    [[ "$enable_relay" == "1" ]] && echo "[dry-run] set daemon.relay.enabled=true in $config_file"
    [[ -n "$tailscale_ip" ]] && echo "[dry-run] set daemon.listen=${tailscale_ip}:6767 in $config_file"
  else
    mkdir -p "$paseo_home"
    PASEO_CONFIG_FILE="$config_file" \
    PASEO_SET_RELAY="$enable_relay" \
    PASEO_SET_LISTEN="$tailscale_ip" \
    python3 - <<'PY'
import json
import os
import pathlib

path = pathlib.Path(os.environ["PASEO_CONFIG_FILE"])
schema = "https://paseo.sh/schemas/paseo.config.v1.json"

data = {}
if path.exists():
    raw = path.read_text(encoding="utf-8").strip()
    if raw:
        data = json.loads(raw)
    if not isinstance(data, dict):
        raise SystemExit(f"[paseo] {path} is not a JSON object; fix it manually")

data.setdefault("$schema", schema)
data.setdefault("version", 1)
daemon = data.setdefault("daemon", {})

if os.environ.get("PASEO_SET_RELAY") == "1":
    daemon.setdefault("relay", {})["enabled"] = True
    print("[paseo] relay enabled")

listen = os.environ.get("PASEO_SET_LISTEN", "").strip()
if listen:
    daemon["listen"] = f"{listen}:6767"
    print(f"[paseo] daemon.listen={daemon['listen']}")

path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
os.chmod(path, 0o600)
PY
  fi
fi

# 4. Start / restart ---------------------------------------------------------
# daemon.listen is a startup setting, so a Tailscale rebind needs a restart.
if [[ "$start_now" == "1" ]]; then
  if [[ -n "$tailscale_ip" ]]; then
    action="restart"
  else
    action="start"
  fi
  run systemctl --user "$action" paseo.service
  if [[ "$dry_run" != "1" ]]; then
    sleep 3
    systemctl --user --no-pager --lines=0 status paseo.service || true
    echo "[paseo] listening on:"
    ss -ltnp 2>/dev/null | grep 6767 || echo "  (nothing on 6767 yet)"
  fi
fi

cat <<'EOF'

[paseo] done.

Phone access:
  Relay  — Paseo Desktop -> Settings -> your host -> Pair a device -> scan the QR
  Direct — Paseo app -> Settings -> Add host -> Direct connection
           Host <tailscale-ip>  Port 6767  SSL off  (Tailscale connected on the phone)

Treat the pairing QR/link like a password: it carries the daemon public key.
EOF
