#!/usr/bin/env bash
set -euo pipefail

ALMA_VERSION="0.0.164"
ALMA_URL="https://github.com/yetone/alma-releases/releases/download/v${ALMA_VERSION}/alma-${ALMA_VERSION}-linux-x86_64.AppImage"
INSTALL_DIR="${HOME}/.local/bin"
APPIMAGE_PATH="${INSTALL_DIR}/alma.AppImage"
LINK_PATH="${INSTALL_DIR}/alma"

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: Alma AppImage supports x86_64 only." >&2
  exit 1
fi

mkdir -p "${INSTALL_DIR}"

if command -v curl >/dev/null 2>&1; then
  curl -L "${ALMA_URL}" -o "${APPIMAGE_PATH}"
elif command -v wget >/dev/null 2>&1; then
  wget -O "${APPIMAGE_PATH}" "${ALMA_URL}"
else
  echo "Error: curl or wget is required to download Alma." >&2
  exit 1
fi

chmod +x "${APPIMAGE_PATH}"
ln -sfn "${APPIMAGE_PATH}" "${LINK_PATH}"

echo "Alma installed: ${LINK_PATH}"
