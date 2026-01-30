# fzf setup (macOS + Linux)

# Prefer Homebrew locations on macOS; fall back to system paths on Linux.
if [ -d /opt/homebrew/opt/fzf ]; then
  FZF_BASE=/opt/homebrew/opt/fzf
elif [ -d /usr/local/opt/fzf ]; then
  FZF_BASE=/usr/local/opt/fzf
elif [ -d /usr/share/fzf ]; then
  FZF_BASE=/usr/share/fzf
fi

# Add fzf bin to PATH when present
if [ -n "${FZF_BASE:-}" ] && [ -d "$FZF_BASE/bin" ] && [[ ":$PATH:" != *":$FZF_BASE/bin:"* ]]; then
  export PATH="$PATH:$FZF_BASE/bin"
fi

# Auto-completion
[[ $- == *i* ]] && {
  if [ -n "${FZF_BASE:-}" ] && [ -f "$FZF_BASE/shell/completion.zsh" ]; then
    source "$FZF_BASE/shell/completion.zsh" 2>/dev/null
  elif [ -f "/usr/share/fzf/completion.zsh" ]; then
    source "/usr/share/fzf/completion.zsh" 2>/dev/null
  fi
}

# Key bindings
if [ -n "${FZF_BASE:-}" ] && [ -f "$FZF_BASE/shell/key-bindings.zsh" ]; then
  source "$FZF_BASE/shell/key-bindings.zsh"
elif [ -f "/usr/share/fzf/key-bindings.zsh" ]; then
  source "/usr/share/fzf/key-bindings.zsh"
fi
