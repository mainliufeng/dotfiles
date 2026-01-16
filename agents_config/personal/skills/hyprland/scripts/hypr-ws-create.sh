#!/usr/bin/env bash
set -euo pipefail

name="${1:-}"
if [[ -z "$name" ]]; then
  echo "usage: hypr-ws-create <workspace-name>" >&2
  exit 1
fi

hyprctl dispatch workspace "name:${name}"
