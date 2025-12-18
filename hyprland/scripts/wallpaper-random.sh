#!/usr/bin/env bash
set -euo pipefail

pick_wallpaper_dir() {
  local pictures_dir=""

  if command -v xdg-user-dir >/dev/null 2>&1; then
    pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null || true)"
  fi
  if [[ -z "${pictures_dir}" ]]; then
    pictures_dir="${HOME}/Pictures"
  fi

  local candidates=(
    "${HYPR_WALLPAPER_DIR:-}"
    "${WALLPAPER_DIR:-}"
    "${pictures_dir}/Wallpapers"
    "${pictures_dir}/wallpapers"
    "${pictures_dir}/Wallpaper"
    "${pictures_dir}/wallpaper"
    "${pictures_dir}"
  )

  local dir=""
  for dir in "${candidates[@]}"; do
    [[ -n "${dir}" ]] || continue
    [[ -d "${dir}" ]] || continue
    if find "${dir}" -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      -print -quit | grep -q .; then
      echo "${dir}"
      return 0
    fi
  done

  return 1
}

pick_random_wallpaper() {
  local dir="$1"
  local last="${2:-}"

  if ! command -v shuf >/dev/null 2>&1; then
    echo "[wallpaper] Error: missing 'shuf' (coreutils)." >&2
    return 1
  fi

  local file="" attempt="" tries=0 max_tries=20

  while (( tries < max_tries )); do
    attempt="$(
      find "${dir}" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 \
        | shuf -z -n 1 \
        | tr -d '\0'
    )"
    [[ -n "${attempt}" ]] || break
    if [[ -n "${last}" && "${attempt}" == "${last}" ]]; then
      tries=$((tries + 1))
      continue
    fi
    file="${attempt}"
    break
  done

  # If we couldn't avoid repeats (e.g. only 1 file), just pick anything.
  if [[ -z "${file}" ]]; then
    file="$(
      find "${dir}" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 \
        | shuf -z -n 1 \
        | tr -d '\0'
    )"
  fi

  [[ -n "${file}" ]] || return 1
  echo "${file}"
}

state_dir() {
  printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}/hypr-wallpaper"
}

last_wallpaper_file() {
  printf '%s\n' "$(state_dir)/last.txt"
}

read_last_wallpaper() {
  local f
  f="$(last_wallpaper_file)"
  [[ -f "${f}" ]] || return 0
  head -n 1 "${f}" || true
}

write_last_wallpaper() {
  local img="$1"
  local d f
  d="$(state_dir)"
  f="$(last_wallpaper_file)"
  mkdir -p "${d}"
  printf '%s\n' "${img}" >"${f}"
}

supports_namespace() {
  swww --help 2>/dev/null | grep -q -- '--namespace'
}

run_with_timeout() {
  local duration="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "${duration}" "$@"
  else
    "$@"
  fi
}

ensure_swww_daemon() {
  local namespace="${SWWW_NAMESPACE:-}"

  local -a swww_cli=(swww)
  local -a daemon_cmd=(swww-daemon)

  if [[ -n "${namespace}" ]] && supports_namespace; then
    swww_cli+=(--namespace "${namespace}")
    daemon_cmd+=(--namespace "${namespace}")
  fi

  if [[ -z "${WAYLAND_DISPLAY:-}" || -z "${XDG_RUNTIME_DIR:-}" ]]; then
    echo "[wallpaper] Error: not in a Wayland session (WAYLAND_DISPLAY/XDG_RUNTIME_DIR missing)." >&2
    return 1
  fi

  if run_with_timeout 1s "${swww_cli[@]}" query >/dev/null 2>&1; then
    return 0
  fi

  # Preferred: let swww manage the daemon.
  run_with_timeout 2s "${swww_cli[@]}" init >/dev/null 2>&1 || true
  for _ in {1..20}; do
    run_with_timeout 1s "${swww_cli[@]}" query >/dev/null 2>&1 && return 0
    sleep 0.1
  done

  # Fallback: start daemon explicitly.
  if command -v swww-daemon >/dev/null 2>&1; then
    ("${daemon_cmd[@]}" >/dev/null 2>&1 &) || true
    disown >/dev/null 2>&1 || true
    for _ in {1..30}; do
      run_with_timeout 1s "${swww_cli[@]}" query >/dev/null 2>&1 && return 0
      sleep 0.1
    done
  fi

  echo "[wallpaper] Error: swww-daemon not reachable (socket missing)." >&2
  echo "[wallpaper] Debug: WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>} XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-<unset>} SWWW_NAMESPACE=${namespace:-<unset>}" >&2
  echo "[wallpaper] Tip: try running: swww init (or set SWWW_NAMESPACE to match your daemon)" >&2
  return 1
}

main() {
  if ! command -v swww >/dev/null 2>&1; then
    echo "[wallpaper] Error: 'swww' not found. Install it first (see hyprland/setup-swww.sh)." >&2
    exit 1
  fi

  local dir="${1:-}"
  if [[ -z "${dir}" ]]; then
    dir="$(pick_wallpaper_dir)" || {
      echo "[wallpaper] Error: no wallpaper directory found." >&2
      echo "[wallpaper] Tip: set HYPR_WALLPAPER_DIR or WALLPAPER_DIR to your wallpaper folder." >&2
      exit 1
    }
  fi

  local img=""
  local last=""
  last="$(read_last_wallpaper || true)"
  img="$(pick_random_wallpaper "${dir}" "${last}")" || {
    echo "[wallpaper] Error: failed to pick a random wallpaper from: ${dir}" >&2
    exit 1
  }

  ensure_swww_daemon

  swww img "${img}" \
    --transition-type "${SWWW_TRANSITION_TYPE:-grow}" \
    --transition-duration "${SWWW_TRANSITION_DURATION:-0.8}" \
    --transition-fps "${SWWW_TRANSITION_FPS:-60}"

  write_last_wallpaper "${img}"
}

main "$@"
