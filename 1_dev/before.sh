#!/bin/bash

sudo pacman -Sy openssh git bat exa # bat和exa是garuda kde lite需要的
git clone https://gitee.com/mainliufeng/dotfiles.git
git clone https://gitee.com/mainliufeng/dotfiles-private.git

# 进入dotfiles目录，执行sh 1_dev/setup.sh"
