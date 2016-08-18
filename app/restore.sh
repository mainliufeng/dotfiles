#!/bin/sh

# ~/tools
tar -C ~ -xvzf ~/Sync/Dropbox/tools.tar.gz

# ~/.oh-my-zsh
tar -C ~ -xvzf ~/Sync/Dropbox/oh-my-zsh.tar.gz

# ~/.vim
tar -C ~ -xvzf ~/Sync/Dropbox/vim.tar.gz

# ~/Code/home
tar -C ~ -xvzf ~/Sync/Dropbox/Code.home.tar.gz

for restore_sh in ~/dotfiles/app/common/*/restore.sh; do
    source $restore_sh
done

if [ "$(uname -s)" == "Darwin" ]; then
    for restore_sh in ~/dotfiles/app/macos/*/restore.sh; do
        source $restore_sh
    done
fi
