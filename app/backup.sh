#!/bin/sh

# ~/tools
tar -C ~ -cvzf ~/Sync/Dropbox/tools.tar.gz tools

# ~/.oh-my-zsh
tar -C ~ -cvzf ~/Sync/Dropbox/oh-my-zsh.tar.gz .oh-my-zsh

# ~/.vim
tar -C ~ -cvzf ~/Sync/Dropbox/vim.tar.gz .vim

# ~/Code/home
tar -C ~ -cvzf ~/Sync/Dropbox/Code.home.tar.gz Code/home
