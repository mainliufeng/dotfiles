#!/usr/bin/env bash
set -euo pipefail

# Build self-contained binaries for clash-fetch-subscription & clash-merge
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/.build"
VENV_DIR="${BUILD_DIR}/venv"
PREFIX="${PREFIX:-/usr/local}"
DIST_DIR="${BUILD_DIR}/dist"
WORK_DIR="${BUILD_DIR}/build"
SPEC_DIR="${BUILD_DIR}/spec"
BINARIES=("clash-fetch-subscription" "clash-merge")
SUDO_CMD=""

if ! [ -w "${PREFIX}/bin" ]; then
  echo "需要 sudo 将二进制安装到 ${PREFIX}/bin"
  SUDO_CMD="sudo"
fi

python3 -m venv "${VENV_DIR}"
# shellcheck disable=SC1090
source "${VENV_DIR}/bin/activate"
pip install --upgrade pip
pip install pyinstaller requests PyYAML

mkdir -p "${BUILD_DIR}"

pyinstaller \
  --onefile \
  --clean \
  --name "clash-fetch-subscription" \
  --distpath "${DIST_DIR}" \
  --workpath "${WORK_DIR}" \
  --specpath "${SPEC_DIR}" \
  "${PROJECT_ROOT}/clash_fetch_subscription.py"

pyinstaller \
  --onefile \
  --clean \
  --name "clash-merge" \
  --distpath "${DIST_DIR}" \
  --workpath "${WORK_DIR}" \
  --specpath "${SPEC_DIR}" \
  "${PROJECT_ROOT}/clash_merge.py"

${SUDO_CMD} install -d "${PREFIX}/bin"
for bin in "${BINARIES[@]}"; do
  ${SUDO_CMD} install -m 755 "${DIST_DIR}/${bin}" "${PREFIX}/bin/${bin}"
  echo "Installed ${bin} to ${PREFIX}/bin/${bin}"
done
