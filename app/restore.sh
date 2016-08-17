#!/bin/sh

# ~/tools
tar xvzf ~/Sync/Dropbox/tools.tar.gz -C ~

# ~/.oh-my-zsh
tar xvzf ~/Sync/Dropbox/.oh-my-zsh.tar.gz -C ~

# ~/.vim
tar xvzf ~/Sync/Dropbox/.vim.tar.gz -C ~

# ~/Code/home
mkdir -p ~/Code
tar xvzf ~/Sync/Dropbox/Code.home.tar.gz -C ~/Code
