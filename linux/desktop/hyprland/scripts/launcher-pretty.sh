#!/usr/bin/env bash
set -euo pipefail

line="${1-}"
[[ -z "$line" ]] && exit 0

IFS=$'\t' read -r type data label <<<"$line"

case "$type" in
  APP) printf '󰀻  %s' "$label" ;;
  WS) printf '󰌒  %s' "${label:-$data}" ;;
  WS_CREATE) printf '%s' "$label" ;;
  CMD) printf '%s' "$label" ;;
  *) printf '%s' "$line" ;;
esac
