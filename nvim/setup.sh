#!/bin/sh
set -e

if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed neovim ctags
  # language servers / tools (optional)
  sudo pacman -S --needed delve || true
  command -v yay >/dev/null 2>&1 && yay -S --needed pyright bash-language-server lua-language-server || true
elif command -v brew >/dev/null 2>&1; then
  brew install neovim ctags ripgrep node npm yarn
  sudo npm install -g neovim
  brew install luarocks
  # vim-plug
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
else
  echo "Please install neovim using your package manager (pacman/brew)." >&2
  exit 1
fi

# Python provider
pip3 install --user pynvim || true

# gopls
command -v go >/dev/null 2>&1 && go install golang.org/x/tools/gopls@latest || true
