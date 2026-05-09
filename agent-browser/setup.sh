#!/usr/bin/env bash
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to install agent-browser" >&2
  exit 1
fi

npm install -g agent-browser
agent-browser install
