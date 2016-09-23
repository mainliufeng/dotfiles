#!/bin/sh

SYNC_PATH=~/Sync/Dropbox

# ~/dotfiles
tar -C ~ -xvzf $SYNC_PATH/dotfiles.tar.gz

# ~/.oh-my-zsh
tar -C ~ -xvzf $SYNC_PATH/oh-my-zsh.tar.gz

# ~/.vim
tar -C ~ -xvzf $SYNC_PATH/vim.tar.gz

# ~/Code/home
tar -C ~ -xvzf $SYNC_PATH/Code.home.tar.gz
