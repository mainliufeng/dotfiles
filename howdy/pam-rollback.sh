#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./pam-rollback.sh --disable [--apply]
  ./pam-rollback.sh --restore [--apply] [--snapshot <name>]

Purpose:
  Help recover from a broken howdy PAM setup (possible lockout).

Modes:
  --disable   Comment out howdy-related lines in /etc/pam.d/* (recommended first aid)
  --restore   Restore /etc/pam.d from a snapshot created by this script

Safety:
  Default is DRY-RUN (no writes). Add --apply to actually modify files.

Backups:
  Snapshots are stored in: /var/backups/howdy-dotfiles/pam.d/<timestamp>/

Examples:
  sudo ./pam-rollback.sh --disable --apply
  sudo ./pam-rollback.sh --restore --apply
  sudo ./pam-rollback.sh --restore --snapshot 20251218_180012 --apply
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${#}" -eq 0 ]]; then
  usage
  exit 0
fi

mode=""
apply="0"
snapshot=""
backup_root="/var/backups/howdy-dotfiles/pam.d"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disable|--restore)
      mode="$1"
      shift
      ;;
    --apply)
      apply="1"
      shift
      ;;
    --snapshot)
      snapshot="${2:-}"
      if [[ -z "${snapshot}" ]]; then
        echo "[howdy][pam-rollback] Error: --snapshot requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --backup-root)
      backup_root="${2:-}"
      if [[ -z "${backup_root}" ]]; then
        echo "[howdy][pam-rollback] Error: --backup-root requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    *)
      echo "[howdy][pam-rollback] Error: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

pam_dir="/etc/pam.d"

if [[ "${apply}" == "1" && "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E "$0" "$@"
fi

if [[ ! -d "${pam_dir}" ]]; then
  echo "[howdy][pam-rollback] Error: ${pam_dir} not found" >&2
  exit 1
fi

timestamp="$(date +%Y%m%d_%H%M%S)"

create_snapshot() {
  local dest="${backup_root}/${timestamp}"
  if [[ "${apply}" == "1" ]]; then
    install -d -m 0700 "${dest}"
    cp -a "${pam_dir}/." "${dest}/"
    echo "[howdy][pam-rollback] Snapshot created: ${dest}"
  else
    echo "[howdy][pam-rollback] DRY-RUN: would snapshot ${pam_dir} -> ${dest}"
  fi
}

list_snapshots() {
  if [[ -d "${backup_root}" ]]; then
    ls -1 "${backup_root}" 2>/dev/null | sort || true
  fi
}

resolve_snapshot_dir() {
  if [[ -n "${snapshot}" ]]; then
    echo "${backup_root}/${snapshot}"
    return 0
  fi

local latest=""
latest="$(list_snapshots | tail -n 1 || true)"
if [[ -z "${latest}" ]]; then
  echo ""
  return 0
fi
echo "${backup_root}/${latest}"
}

restore_from_snapshot() {
  local snap_dir
  snap_dir="$(resolve_snapshot_dir)"

  if [[ -z "${snap_dir}" || ! -d "${snap_dir}" ]]; then
    echo "[howdy][pam-rollback] Error: no snapshot found under ${backup_root}" >&2
    echo "[howdy][pam-rollback] Hint: run --disable first (it will create a snapshot before changing files)." >&2
    exit 1
  fi

  if [[ "${apply}" == "1" ]]; then
    create_snapshot
    cp -a "${snap_dir}/." "${pam_dir}/"
    echo "[howdy][pam-rollback] Restored ${pam_dir} from: ${snap_dir}"
  else
    echo "[howdy][pam-rollback] DRY-RUN: would restore ${pam_dir} from: ${snap_dir}"
  fi
}

disable_howdy_lines() {
  create_snapshot

  local changed=0
  local file
  while IFS= read -r -d '' file; do
    if ! grep -qiE '(howdy|/lib/security/howdy|/usr/lib/security/howdy|pam_python\.so.*howdy|pam_exec\.so.*howdy)' "${file}"; then
      continue
    fi

    echo "[howdy][pam-rollback] Match: ${file}"
    if [[ "${apply}" == "1" ]]; then
      local tmp
      tmp="$(mktemp)"
      awk '
        BEGIN { IGNORECASE=1 }
        /^[[:space:]]*#/ { print; next }
        $0 ~ /(howdy|\/lib\/security\/howdy|\/usr\/lib\/security\/howdy|pam_python\.so.*howdy|pam_exec\.so.*howdy)/ {
          print "# disabled-by-howdy-dotfiles " $0
          next
        }
        { print }
      ' "${file}" >"${tmp}"
      install -m 0644 "${tmp}" "${file}"
      rm -f "${tmp}"
      changed=1
    else
      echo "[howdy][pam-rollback] DRY-RUN: would comment out howdy lines in ${file}"
    fi
  done < <(find "${pam_dir}" -maxdepth 1 -type f -print0)

  if [[ "${apply}" == "1" ]]; then
    if [[ "${changed}" == "1" ]]; then
      echo "[howdy][pam-rollback] Done: howdy lines disabled (commented)."
    else
      echo "[howdy][pam-rollback] Done: no howdy lines found in ${pam_dir}."
    fi
  else
    echo "[howdy][pam-rollback] DRY-RUN complete. Re-run with --apply to write changes."
  fi
}

case "${mode}" in
  --restore) restore_from_snapshot ;;
  --disable) disable_howdy_lines ;;
  *)
    echo "[howdy][pam-rollback] Error: you must choose --disable or --restore" >&2
    usage
    exit 2
    ;;
esac
