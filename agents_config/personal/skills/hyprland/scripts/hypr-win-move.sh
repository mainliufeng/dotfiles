#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-}"
follow=0

if [[ -z "$workspace" ]]; then
  echo "usage: hypr-win-move <workspace-name> [--follow]" >&2
  exit 1
fi

shift || true
if [[ "${1:-}" == "--follow" ]]; then
  follow=1
fi

hyprctl dispatch movetoworkspace "name:${workspace}"
if [[ "$follow" -eq 1 ]]; then
  hyprctl dispatch workspace "name:${workspace}"
fi
