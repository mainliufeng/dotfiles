#!/usr/bin/env bash
set -euo pipefail

ALMA_VERSION="${ALMA_VERSION:-}"
ALMA_URL=""
INSTALL_DIR="${HOME}/.local/bin"
APPIMAGE_PATH="${INSTALL_DIR}/alma.AppImage"
LINK_PATH="${INSTALL_DIR}/alma"
API_URL="https://api.github.com/repos/yetone/alma-releases/releases/latest"
GITHUB_RELEASES_URL="https://github.com/yetone/alma-releases/releases"
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

fetch_latest_release_api() {
  local headers=()
  local token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  local response http_code

  if [ -n "${token}" ]; then
    headers+=("-H" "Authorization: Bearer ${token}")
  fi

  if command -v curl >/dev/null 2>&1; then
    response="$(
      curl -sSL -H "Accept: application/vnd.github+json" -H "User-Agent: alma-setup" \
        "${headers[@]}" -w '\n%{http_code}' "${API_URL}"
    )"
    http_code="$(printf '%s' "${response}" | tail -n1)"
    response="$(printf '%s' "${response}" | sed '$d')"
    if [ "${http_code}" -ge 200 ] && [ "${http_code}" -lt 300 ]; then
      printf '%s' "${response}"
      return 0
    fi
    return 1
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO - "${API_URL}"
    return
  fi

  echo "Error: curl or wget is required to query Alma releases." >&2
  exit 1
}

fetch_latest_release_html() {
  local release_html tag assets_html asset_path

  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to query Alma releases without the GitHub API." >&2
    exit 1
  fi

  release_html="$(curl -fsSL "${GITHUB_RELEASES_URL}/latest")"
  tag="$(grep -m1 -oE 'releases/tag/v[0-9.]+' <<< "${release_html}" || true)"
  tag="${tag#releases/tag/}"
  if [ -z "${tag}" ]; then
    echo "Error: failed to resolve Alma tag from release page." >&2
    exit 1
  fi

  assets_html="$(curl -fsSL "${GITHUB_RELEASES_URL}/expanded_assets/${tag}")"
  asset_path="$(grep -m1 -oE 'href="[^"]+linux-x86_64\.AppImage"' <<< "${assets_html}" || true)"
  asset_path="${asset_path#href=\"}"
  asset_path="${asset_path%\"}"
  if [ -z "${asset_path}" ]; then
    echo "Error: failed to locate Alma AppImage asset in release ${tag}." >&2
    exit 1
  fi

  ALMA_VERSION="${tag#v}"
  ALMA_URL="https://github.com${asset_path}"
}

if [ -z "${ALMA_VERSION}" ]; then
  if release_json="$(fetch_latest_release_api)"; then
    tag_name="$(printf '%s' "${release_json}" | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\\1/p')"
    ALMA_VERSION="${tag_name#v}"
    ALMA_URL="$(printf '%s' "${release_json}" | sed -nE 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"([^"]*linux-x86_64\\.AppImage)".*/\\1/p')"
    if [ -z "${ALMA_URL}" ] || [ -z "${ALMA_VERSION}" ]; then
      fetch_latest_release_html
    fi
  else
    fetch_latest_release_html
  fi
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
