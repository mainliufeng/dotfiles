#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${WORKSPACE_PROJECTS_ROOTS:-}" ]]; then
  IFS=':' read -r -a project_roots <<<"$WORKSPACE_PROJECTS_ROOTS"
elif [[ -n "${WORKSPACE_PROJECTS_ROOT:-}" ]]; then
  project_roots=("$WORKSPACE_PROJECTS_ROOT")
else
  project_roots=("$HOME/Code/self" "$HOME/Code/rcrai")
fi
project_arg="${1:-}"

if [[ -z "$project_arg" ]]; then
  if command -v wofi >/dev/null 2>&1; then
    project_arg="$(
      {
        for root in "${project_roots[@]}"; do
          [[ -d "$root" ]] || continue
          root_label="${root#$HOME/Code/}"
          if [[ "$root_label" == "$root" || -z "$root_label" ]]; then
            root_label="$(basename "$root")"
          fi
          find "$root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
            | sort \
            | sed "s#^#${root_label}/#"
        done
      } | sort | wofi --show dmenu --prompt "Project"
    )"
  else
    echo "missing project name and wofi not installed" >&2
    exit 1
  fi
fi

if [[ -z "$project_arg" ]]; then
  exit 0
fi

repo=""
if [[ "$project_arg" = /* ]]; then
  repo="$project_arg"
elif [[ "$project_arg" == *"/"* ]]; then
  repo="$HOME/Code/$project_arg"
else
  for root in "${project_roots[@]}"; do
    if [[ -d "$root/$project_arg" ]]; then
      repo="$root/$project_arg"
      break
    fi
  done
fi

if [[ -z "$repo" ]]; then
  repo="${project_roots[0]}/${project_arg}"
fi

if [[ ! -d "$repo" ]]; then
  echo "repo not found: $repo" >&2
  exit 1
fi

workspace="${WORKSPACE_NAME:-${MOBIUS_WORKSPACE:-$(basename "$repo")}}"
term="${WORKSPACE_TERM:-${MOBIUS_TERM:-ghostty}}"
codex_cmd="${WORKSPACE_CODEX_CMD:-${MOBIUS_CODEX_CMD:-codex}}"
codex_bin="${WORKSPACE_CODEX_BIN:-${MOBIUS_CODEX_BIN:-$HOME/.npm-global/bin/codex}}"
nvim_cmd="${WORKSPACE_NVIM_CMD:-${MOBIUS_NVIM_CMD:-nvim}}"
codex_args="${WORKSPACE_CODEX_ARGS:-${MOBIUS_CODEX_ARGS:---dangerously-bypass-approvals-and-sandbox}}"
shell="${WORKSPACE_SHELL:-${MOBIUS_SHELL:-zsh}}"
path_prefix="${WORKSPACE_PATH_PREFIX:-${MOBIUS_PATH_PREFIX:-$HOME/.npm-global/bin:$HOME/.opencode/bin}}"

if [[ -z "${WORKSPACE_SHELL_ARGS:-${MOBIUS_SHELL_ARGS:-}}" ]]; then
  if [[ "$shell" == "bash" ]]; then
    shell_args="-lc"
  else
    shell_args="-lic"
  fi
else
  shell_args="${WORKSPACE_SHELL_ARGS:-$MOBIUS_SHELL_ARGS}"
fi

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing command: $cmd" >&2
    return 1
  fi
}

require_cmd hyprctl
require_cmd "$term"
require_cmd "$nvim_cmd"

hypr_instance() {
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
    return 0
  fi

  hyprctl -j instances 2>/dev/null | python -c '
import json,os,sys
try:
  items=json.load(sys.stdin)
except Exception:
  items=[]
if not items:
  sys.exit(0)
want=os.environ.get("WAYLAND_DISPLAY")
if want:
  for it in items:
    if it.get("wl_socket")==want and it.get("instance"):
      print(it["instance"])
      sys.exit(0)
print(items[0].get("instance",""))
'
}

hypr() {
  local inst
  inst="$(hypr_instance || true)"
  if [[ -n "$inst" ]]; then
    hyprctl --instance "$inst" "$@"
  else
    hyprctl "$@"
  fi
}

spawn_term() {
  local title="$1"
  local snippet="$2"
  local repo_quoted shell_cmd path_prefix_quoted

  repo_quoted="$(printf %q "$repo")"
  path_prefix_quoted="$(printf %q "$path_prefix")"
  shell_cmd="export PATH=${path_prefix_quoted}:\$PATH; cd $repo_quoted; printf '\033]0;${title}\007'; ${snippet}"
  hypr dispatch exec "$term -e $shell $shell_args $(printf %q "$shell_cmd")"
}

hypr dispatch workspace "name:${workspace}"

spawn_term "${workspace} Codex" "if [ -x $(printf %q "$codex_bin") ]; then $(printf %q "$codex_bin") $codex_args; elif command -v $codex_cmd >/dev/null 2>&1; then $codex_cmd $codex_args; else echo 'codex not found'; fi; exec $shell"
sleep 0.2
spawn_term "${workspace} Shell" "exec $shell"
sleep 0.2
spawn_term "${workspace} Nvim" "exec $nvim_cmd"
