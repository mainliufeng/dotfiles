#!/bin/bash

sudo pacman -Sy openssh git bat exa # bat和exa是garuda kde lite需要的

ssh-keygen -t rsa -b 4096 -C "mainliufeng@gmail.com"
cat ~/.ssh/id_rsa.pub

# key加到github

git clone git@github.com:mainliufeng/dotfiles.git
git clone git@github.com:mainliufeng/dotfiles-private.git

sudo pacman -Syyu

# 进入dotfiles目录，执行sh 1_dev/setup.sh"
