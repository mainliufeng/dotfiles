#!/bin/sh

# install neovim nightly manually

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# install neovim py
pip3 install --user pynvim

# install nodejs (required by coc.vim)
brew install node npm yarn
sudo npm install -g neovim

# install luarocks (required by lua-lsp) 
brew install luarocks
sudo luarocks install --server=http://luarocks.org/dev lua-lsp

# install gopls
go get golang.org/x/tools/gopls@latest

# install ripgrep (required by coc-search)
brew install ripgrep

# vim-floaterm
pip3 install neovim-remote

# :CocInstall coc-python
# :CocInstall coc-marketplace
