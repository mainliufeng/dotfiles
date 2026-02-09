#!/bin/bash

set -e
set -u

# Define paths
BIN_DIR="${HOME}/.local/bin"
APPS_DIR="${HOME}/.local/share/applications"
SCRIPT_NAME="chrome-with-proxy"
SCRIPT_PATH="${BIN_DIR}/${SCRIPT_NAME}"

# Create bin directory if it doesn't exist
mkdir -p "${BIN_DIR}"

# Create the proxy script
echo "Creating proxy script at ${SCRIPT_PATH}"
cat > "${SCRIPT_PATH}" <<'EOF'
#!/bin/bash
# Set proxy for Chrome
export http_proxy="http://127.0.0.1:7897"
export https_proxy="http://127.0.0.1:7897"

# Check if google-chrome-unstable exists
if ! command -v google-chrome-unstable &> /dev/null
then
    echo "google-chrome-unstable could not be found"
    exit
fi

exec /usr/bin/google-chrome-unstable "$@"
EOF

# Make the script executable
chmod +x "${SCRIPT_PATH}"
echo "Made script executable."

# Handle .desktop file
ORIGINAL_DESKTOP_FILE_PATH=$(find /usr/share/applications -name "*google-chrome.desktop" | head -n 1 || true)

if [ -z "${ORIGINAL_DESKTOP_FILE_PATH}" ]; then
    echo "Warning: Could not find google-chrome.desktop in /usr/share/applications"
    echo "Skipping .desktop file creation."
    exit 0
fi

DESKTOP_FILE_NAME="google-chrome-proxy.desktop"
NEW_DESKTOP_FILE_PATH="${APPS_DIR}/${DESKTOP_FILE_NAME}"

echo "Found original .desktop file at ${ORIGINAL_DESKTOP_FILE_PATH}"
echo "Creating new .desktop file at ${NEW_DESKTOP_FILE_PATH}"

# Create applications directory if it doesn't exist
mkdir -p "${APPS_DIR}"

# Copy original and modify it
# 1. Change the Name
# 2. Change the Exec command
# Using a temporary file for sed to avoid issues on different systems
TMP_FILE=$(mktemp)
sed -e 's/^Name=.*/Name=Google Chrome (Proxy)/' "${ORIGINAL_DESKTOP_FILE_PATH}" > "${TMP_FILE}"
sed -E "s|/usr/bin/google-chrome(-stable|-unstable)?|${SCRIPT_PATH}|g" "${TMP_FILE}" > "${NEW_DESKTOP_FILE_PATH}"
rm "${TMP_FILE}"

echo "Successfully created ${NEW_DESKTOP_FILE_PATH}"
echo "You may need to logout and login again for the new application to appear in your menu."
