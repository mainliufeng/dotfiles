#!/bin/sh

# ~/tools
tar xvzf ~/Sync/Dropbox/tools.tar.gz -C ~

# ~/.oh-my-zsh
tar xvzf ~/Sync/Dropbox/oh-my-zsh.tar.gz -C ~

# ~/.vim
tar xvzf ~/Sync/Dropbox/vim.tar.gz -C ~

# ~/Code/home
mkdir -p ~/Code
tar xvzf ~/Sync/Dropbox/Code.home.tar.gz -C ~/Code

for restore_sh in ~/dotfiles/app/common/*/restore.sh; do
    source $restore_sh
done

if [ "$(uname -s)" == "Darwin" ]; then
    for restore_sh in ~/dotfiles/app/macos/*/restore.sh; do
        source $restore_sh
    done
fi
