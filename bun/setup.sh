#!/usr/bin/env bash
set -euo pipefail

if command -v bun >/dev/null 2>&1; then
  bun --version
  exit 0
fi

curl -fsSL https://bun.sh/install | bash
