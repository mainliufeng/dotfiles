#!/usr/bin/env bash
set -euo pipefail

ALMA_VERSION="${ALMA_VERSION:-}"
ALMA_URL=""
INSTALL_DIR="${HOME}/.local/bin"
APPIMAGE_PATH="${INSTALL_DIR}/alma.AppImage"
LINK_PATH="${INSTALL_DIR}/alma"
API_URL="https://api.github.com/repos/yetone/alma-releases/releases/latest"
TMP_APPIMAGE_PATH=""

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: Alma AppImage supports x86_64 only." >&2
  exit 1
fi

mkdir -p "${INSTALL_DIR}"

download() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    echo "Downloading Alma AppImage..."
    curl -fL --progress-bar "${url}" -o "${output}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    echo "Downloading Alma AppImage..."
    wget --show-progress -O "${output}" "${url}"
    return
  fi

  echo "Error: curl or wget is required to download Alma." >&2
  exit 1
}

cleanup_tmp() {
  if [ -n "${TMP_APPIMAGE_PATH}" ] && [ -f "${TMP_APPIMAGE_PATH}" ]; then
    rm -f "${TMP_APPIMAGE_PATH}"
  fi
}

fetch_latest_release() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${API_URL}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO - "${API_URL}"
    return
  fi

  echo "Error: curl or wget is required to query Alma releases." >&2
  exit 1
}

if [ -z "${ALMA_VERSION}" ]; then
  release_json="$(fetch_latest_release)"
  tag_name="$(printf '%s' "${release_json}" | grep -m1 -E '"tag_name":[[:space:]]*"[^"]+"' | sed -E 's/.*"([^"]+)".*/\1/')"
  ALMA_VERSION="${tag_name#v}"
  ALMA_URL="$(printf '%s' "${release_json}" | grep -m1 -E '"browser_download_url":[[:space:]]*"[^"]*linux-x86_64\.AppImage"' | sed -E 's/.*"([^"]+)".*/\1/')"
else
  ALMA_URL="https://github.com/yetone/alma-releases/releases/download/v${ALMA_VERSION}/alma-${ALMA_VERSION}-linux-x86_64.AppImage"
fi

if [ -z "${ALMA_URL}" ] || [ -z "${ALMA_VERSION}" ]; then
  echo "Error: failed to resolve Alma release metadata." >&2
  exit 1
fi

TMP_APPIMAGE_PATH="$(mktemp "${INSTALL_DIR}/alma.AppImage.XXXXXX")"
trap cleanup_tmp EXIT
download "${ALMA_URL}" "${TMP_APPIMAGE_PATH}"
chmod +x "${TMP_APPIMAGE_PATH}"
mv -f "${TMP_APPIMAGE_PATH}" "${APPIMAGE_PATH}"
TMP_APPIMAGE_PATH=""
trap - EXIT

ln -sfn "${APPIMAGE_PATH}" "${LINK_PATH}"

echo "Alma installed: ${LINK_PATH} (v${ALMA_VERSION})"
