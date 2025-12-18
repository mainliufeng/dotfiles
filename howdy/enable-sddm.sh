#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./enable-sddm.sh [enable|backup|restore|disable]

One command (recommended):
  ./enable-sddm.sh
    - backup /etc/pam.d
    - enable howdy for SDDM (idempotent)

Actions:
  enable   Backup /etc/pam.d, then enable howdy for SDDM
  backup   Only create a snapshot of /etc/pam.d
  restore  Restore /etc/pam.d from the latest snapshot
  disable  Comment out howdy-related PAM lines (first aid)

Notes:
  - Keep a TTY login open before running `enable`.
  - After `enable`, restart SDDM: `sudo systemctl restart sddm`
EOF
}

action="${1:-enable}"
case "${action}" in
  enable|backup|restore|disable) ;;
  -h|--help) usage; exit 0 ;;
  *)
    echo "[howdy][enable-sddm] Error: unknown action: ${action}" >&2
    usage
    exit 2
    ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pam_file="/etc/pam.d/sddm"
backup_root="/var/backups/howdy-dotfiles/pam.d"
timestamp="$(date +%Y%m%d_%H%M%S)"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    exec sudo -E "$0" "$@"
  fi
}

create_snapshot() {
  install -d -m 0700 "${backup_root}/${timestamp}"
  cp -a /etc/pam.d/. "${backup_root}/${timestamp}/"
  echo "[howdy][enable-sddm] Snapshot created: ${backup_root}/${timestamp}"
}

if [[ ! -f "${pam_file}" ]]; then
  echo "[howdy][enable-sddm] Error: ${pam_file} not found" >&2
  echo "[howdy][enable-sddm] Hint: list available PAM services: ls /etc/pam.d | rg '^sddm'" >&2
  exit 1
fi

case "${action}" in
  backup)
    require_root "${action}"
    create_snapshot
    exit 0
    ;;
  restore)
    require_root "${action}"
    exec "${script_dir}/pam-rollback.sh" --restore --apply
    ;;
  disable)
    require_root "${action}"
    exec "${script_dir}/pam-rollback.sh" --disable --apply
    ;;
esac

howdy_pam_py=""
if [[ -f "/lib/security/howdy/pam.py" ]]; then
  howdy_pam_py="/lib/security/howdy/pam.py"
elif [[ -f "/usr/lib/security/howdy/pam.py" ]]; then
  howdy_pam_py="/usr/lib/security/howdy/pam.py"
fi

line=""
if [[ -f "/usr/lib/security/pam_howdy.so" || -f "/lib/security/pam_howdy.so" ]]; then
  line='auth sufficient pam_howdy.so'
elif [[ -f "/usr/lib/security/pam_python3.so" || -f "/lib/security/pam_python3.so" ]]; then
  if [[ -z "${howdy_pam_py}" ]]; then
    echo "[howdy][enable-sddm] Error: howdy pam.py not found under /lib/security/howdy/ or /usr/lib/security/howdy/" >&2
    exit 1
  fi
  line="auth sufficient pam_python3.so ${howdy_pam_py}"
elif [[ -f "/usr/lib/security/pam_python.so" || -f "/lib/security/pam_python.so" ]]; then
  if [[ -z "${howdy_pam_py}" ]]; then
    echo "[howdy][enable-sddm] Error: howdy pam.py not found under /lib/security/howdy/ or /usr/lib/security/howdy/" >&2
    exit 1
  fi
  line="auth sufficient pam_python.so ${howdy_pam_py}"
else
  echo "[howdy][enable-sddm] Error: no suitable PAM module found." >&2
  echo "[howdy][enable-sddm] Looked for pam_howdy.so, pam_python3.so, pam_python.so under /usr/lib/security and /lib/security." >&2
  exit 1
fi

marker='added-by-howdy-dotfiles'

if grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_howdy\.so([[:space:]]|$)' "${pam_file}" \
  || grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_python(3)?\.so[[:space:]]+.*howdy/pam\.py([[:space:]]|$)' "${pam_file}"; then
  echo "[howdy][enable-sddm] Already enabled in ${pam_file}"
  exit 0
fi

require_root "${action}"
create_snapshot

tmp="$(mktemp)"
awk -v newline="${line} # ${marker}" '
  BEGIN { inserted=0 }
  inserted==0 && $0 !~ /^[[:space:]]*#/ && $0 ~ /^[[:space:]]*auth[[:space:]]/ {
    print newline
    inserted=1
  }
  { print }
  END { if (inserted==0) print newline }
' "${pam_file}" >"${tmp}"

install -m 0644 "${tmp}" "${pam_file}"
rm -f "${tmp}"

echo "[howdy][enable-sddm] Enabled howdy for SDDM in ${pam_file}"
echo "[howdy][enable-sddm] Next: restart SDDM: systemctl restart sddm"

