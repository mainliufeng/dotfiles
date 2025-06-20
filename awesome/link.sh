#!/bin/sh

mkdir -p ~/.config
ln -svfn ~/dotfiles/awesome ~/.config/awesome

# 创建 picom 配置目录（如果不存在）
mkdir -p ~/.config/picom

# 删除已有的 picom.conf（如果是软链接或文件）
rm -f ~/.config/picom/picom.conf

# 建立软链接
ln -s "$PWD/picom.conf" ~/.config/picom/picom.conf

echo "已将 picom.conf 软链接到 ~/.config/picom/picom.conf"
