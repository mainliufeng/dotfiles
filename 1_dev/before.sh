#!/bin/bash

sudo pacman -Sy openssh git bat exa # bat和exa是garuda kde lite需要的

# 生成 SSH key 方便后续 git clone
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "mainliufeng@gmail.com"
fi
cat ~/.ssh/id_rsa.pub
echo "# 将上述公钥添加到 GitHub"

# 建议直接使用 GitHub 源；如需国内镜像可自行替换
git clone git@github.com:mainliufeng/dotfiles.git
git clone git@github.com:mainliufeng/dotfiles-private.git

sudo pacman -Syyu

# 进入dotfiles目录，执行sh 1_dev/setup.sh"
