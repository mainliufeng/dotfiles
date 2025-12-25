#!/usr/bin/env bash
set -euo pipefail

field="${1:-}"
value="${2:-}"

if [ "$field" = "1" ]; then
  if [ "$value" = "1" ]; then
    printf '2:@disabled@\n'
  else
    printf '2:%s\n' "${CODE_AGENTS_DEFAULT_PATH:-$HOME}"
  fi
fi
