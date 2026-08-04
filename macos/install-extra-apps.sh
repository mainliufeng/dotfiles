#!/usr/bin/env bash
set -euo pipefail

# These apps were installed manually on the audited Mac, but have official or
# Homebrew-maintained casks. Keep them out of Brewfile so re-running setup on
# the existing Mac does not collide with an app that Homebrew does not own.
install_if_missing() {
  local cask="$1"
  local app_path="$2"

  if [[ -e "$app_path" ]]; then
    echo "[macos] already present: $app_path"
    return 0
  fi

  echo "[macos] installing extra app: $cask"
  brew install --cask "$cask"
}

install_if_missing google-chrome "/Applications/Google Chrome.app"
install_if_missing microsoft-teams "/Applications/Microsoft Teams.app"
install_if_missing openvpn-connect "/Applications/OpenVPN Connect.app"
install_if_missing chatgpt-atlas "/Applications/ChatGPT Atlas.app"
install_if_missing doubao "/Applications/Doubao.app"
install_if_missing typeless "/Applications/Typeless.app"
install_if_missing wpsoffice-cn "/Applications/wpsoffice.app"
