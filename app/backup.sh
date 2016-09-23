#!/bin/sh

SYNC_PATH=~/Sync/Dropbox

# ~/dotfiles
tar -C ~ -cvzf $SYNC_PATH/dotfiles.tar.gz dotfiles

# ~/.oh-my-zsh
tar -C ~ -cvzf $SYNC_PATH/oh-my-zsh.tar.gz .oh-my-zsh

# ~/.vim
tar -C ~ -cvzf $SYNC_PATH/vim.tar.gz .vim

# ~/Code/home
tar -C ~ -cvzf $SYNC_PATH/Code.home.tar.gz Code/home

# restore.sh
cp ~/dotfiles/app/restore.sh $SYNC_PATH
