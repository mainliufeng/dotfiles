if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ -x /Applications/Codex.app/Contents/Resources/codex ]]; then
  export PATH="/Applications/Codex.app/Contents/Resources:$PATH"
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if command -v brew >/dev/null 2>&1; then
  rustup_prefix="$(brew --prefix rustup 2>/dev/null || true)"
  if [[ -n "$rustup_prefix" && -d "$rustup_prefix/bin" ]]; then
    export PATH="$rustup_prefix/bin:$PATH"
  fi
  unset rustup_prefix
fi

if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
fi
