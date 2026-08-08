#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/ilysenko/codex-desktop-linux.git"
repo_dir="${CODEX_DESKTOP_LINUX_REPO:-$HOME/Code/source/codex-desktop-linux}"
dry_run=0
rebuild="${DOTFILES_CODEX_DESKTOP_REBUILD:-0}"
update_source="${DOTFILES_CODEX_DESKTOP_UPDATE_SOURCE:-0}"

usage() {
  cat <<'EOF'
Usage: setup.sh [--dry-run] [--rebuild] [--update-source]

Install the unofficial Codex Desktop Linux wrapper on Arch-like Linux.
The first install runs: CODEX_SUDO_ALERT=1 make bootstrap-native

Options:
  --dry-run        Print the actions without cloning, building, or installing
  --rebuild        Rebuild/reinstall even when codex-desktop is already installed
  --update-source  Fast-forward an existing clean source checkout before building
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --rebuild) rebuild=1; shift ;;
    --update-source) update_source=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[codex-desktop] this installer is Linux-only" >&2
  exit 1
fi

if ! grep -Eq '^(ID|ID_LIKE)=.*(arch|garuda|manjaro|endeavouros)' /etc/os-release; then
  echo "[codex-desktop] only Arch-like Linux is managed by these dotfiles" >&2
  exit 1
fi

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

if [[ ! -e "$repo_dir" ]]; then
  run mkdir -p "$(dirname "$repo_dir")"
  run git clone "$repo_url" "$repo_dir"
elif [[ ! -d "$repo_dir/.git" ]]; then
  echo "[codex-desktop] refusing non-git source path: $repo_dir" >&2
  exit 1
else
  actual_url="$(git -C "$repo_dir" remote get-url origin 2>/dev/null || true)"
  if [[ "$actual_url" != "$repo_url" && "$actual_url" != "${repo_url%.git}" ]]; then
    echo "[codex-desktop] unexpected origin: ${actual_url:-<missing>}" >&2
    exit 1
  fi
fi

if [[ "$update_source" == "1" && -d "$repo_dir/.git" ]]; then
  if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
    echo "[codex-desktop] source checkout is dirty; refusing to update: $repo_dir" >&2
    exit 1
  fi
  run git -C "$repo_dir" pull --ff-only
fi

installed=0
if command -v pacman >/dev/null 2>&1 && pacman -Q codex-desktop >/dev/null 2>&1; then
  installed=1
fi

if [[ "$installed" == "1" && "$rebuild" != "1" ]]; then
  version="$(pacman -Q codex-desktop | awk '{print $2}')"
  echo "[codex-desktop] already installed: $version"
  echo "[codex-desktop] set DOTFILES_CODEX_DESKTOP_REBUILD=1 or use --rebuild to rebuild"
else
  if [[ "$dry_run" == "1" ]]; then
    echo "[dry-run] cd $repo_dir && CODEX_SUDO_ALERT=1 make bootstrap-native"
  else
    echo "[codex-desktop] building and installing from $repo_dir"
    (
      cd "$repo_dir"
      CODEX_SUDO_ALERT="${CODEX_SUDO_ALERT:-1}" make bootstrap-native
    )
    pacman -Q codex-desktop
  fi
fi

if [[ "$dry_run" != "1" ]] && systemctl --user list-unit-files codex-update-manager.service >/dev/null 2>&1; then
  updater_enabled="$(systemctl --user is-enabled codex-update-manager.service 2>/dev/null || true)"
  updater_active="$(systemctl --user is-active codex-update-manager.service 2>/dev/null || true)"
  echo "[codex-desktop] updater: enabled=${updater_enabled:-unknown} active=${updater_active:-unknown}"
fi
