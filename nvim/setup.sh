#!/bin/sh

sudo pacman -S neovim vim-plug

#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
pip3 install --user pynvim

# install luarocks (required by lua-lsp)
sudo pacman -S luarocks

# install nodejs (required by coc.vim)
sudo pacman -S nodejs npm yarn
sudo npm install -g neovim
go get golang.org/x/tools/gopls@latest

# install ripgrep (required by coc-search)
sudo pacman -S ripgrep

# vim-floaterm
pip3 install neovim-remote

# :CocInstall coc-python
# sudo luarocks install --server=http://luarocks.org/dev lua-lsp
# :CocInstall coc-marketplace

sudo pacman -S ctags
