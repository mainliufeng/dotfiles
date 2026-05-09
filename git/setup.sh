#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    brew install git git-lfs gh
    ;;
  Linux)
    sudo pacman -S --needed git git-lfs github-cli
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

git config --global user.email "mainliufeng@gmail.com"
git config --global user.name "Liu Feng"
git config --global log.date "format:%Y-%m-%d %H:%M:%S"

# 安装github-cli后执行gh auth login
