#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./apply-config.sh

What it does:
  - Copies ./howdy/config.ini to the system howdy config.ini path (overwrite)
  - Creates a timestamped backup next to the target config.ini
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${#}" -ne 0 ]]; then
  usage
  exit 0
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source="${script_dir}/config.ini"

if [[ ! -f "${source}" ]]; then
  echo "[howdy][apply-config] Error: source not found: ${source}" >&2
  exit 1
fi

target=""
if [[ -f "/lib/security/howdy/config.ini" ]]; then
  target="/lib/security/howdy/config.ini"
elif [[ -f "/usr/lib/security/howdy/config.ini" ]]; then
  target="/usr/lib/security/howdy/config.ini"
else
  echo "[howdy][apply-config] Error: howdy config.ini not found under /lib/security/howdy/ or /usr/lib/security/howdy/" >&2
  exit 1
fi

timestamp="$(date +%Y%m%d_%H%M%S)"
backup="${target}.bak.${timestamp}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E "$0"
fi

cp -a "${target}" "${backup}"
echo "[howdy][apply-config] Backup created: ${backup}"

install -m 0644 "${source}" "${target}"

echo "[howdy][apply-config] Installed config: ${target}"
echo "[howdy][apply-config] If you need to change device_path, edit: ${source}"
