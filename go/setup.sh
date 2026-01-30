#!/bin/sh
set -e

if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed go
  go env -w GO111MODULE=on
elif command -v brew >/dev/null 2>&1; then
  brew install go
  # golangci-lint
  brew install golangci-lint || brew install golangci/tap/golangci-lint
  brew upgrade golangci-lint || true
else
  echo "Please install Go using your package manager (pacman/brew)." >&2
  exit 1
fi
