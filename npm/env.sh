export PATH="$HOME/.npm-global/bin:$PATH"
export PLAYWRIGHT_BROWSERS_PATH="$HOME/.cache/ms-playwright"

if command -v npm >/dev/null 2>&1; then
    NODE_GLOBAL_ROOT=$(npm root -g 2>/dev/null)
    if [ -n "$NODE_GLOBAL_ROOT" ]; then
        export NODE_PATH="$NODE_GLOBAL_ROOT${NODE_PATH:+:$NODE_PATH}"
    fi
fi
