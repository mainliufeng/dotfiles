#!/usr/bin/env bash
set -euo pipefail

install_fasd_from_git() {
  if command -v fasd >/dev/null 2>&1; then
    return 0
  fi

  local fasd_dir="$HOME/.local/share/fasd"
  mkdir -p "$HOME/.local/bin" "$(dirname "$fasd_dir")"

  if [[ -d "$fasd_dir/.git" ]]; then
    git -C "$fasd_dir" pull --ff-only
  else
    git clone https://github.com/clvv/fasd.git "$fasd_dir"
  fi

  chmod +x "$fasd_dir/fasd"
  ln -sfn "$fasd_dir/fasd" "$HOME/.local/bin/fasd"
}

case "$(uname -s)" in
  Darwin)
    brew install zsh zplug powerlevel10k zsh-completions zsh-history-substring-search zsh-syntax-highlighting zoxide
    install_fasd_from_git
    ;;
  Linux)
    sudo pacman -S --needed zsh zsh-theme-powerlevel10k zsh-completions zsh-history-substring-search zsh-syntax-highlighting zoxide
    if command -v yay >/dev/null 2>&1; then
      yay -S --needed zplug
    fi
    ;;
  *)
    echo "unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

if [[ "$SHELL" != *zsh ]]; then
  echo "Current shell is $SHELL. Change it manually with: chsh -s $(command -v zsh)"
fi
