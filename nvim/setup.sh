#!/bin/sh

sudo pacman -S neovim

#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# pip3 install --user pynvim

# install luarocks (required by lua-lsp)
# sudo pacman -S luarocks

# golang
go get golang.org/x/tools/gopls@latest
sudo pacman -S delve

yay -S pyright

# install bash-language-server
yay -S bash-language-server
# or npm i -g bash-language-server

sudo pacman -S ctags
