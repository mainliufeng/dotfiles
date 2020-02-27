#!/bin/sh
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
pip3 install --user pynvim

# install nodejs (required by coc.vim)
brew install node

# install ctags (required by leaderf.vim)
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
