#!/bin/bash

manual_step() {
    local msg=$1

    echo "$msg"
    read -p "完成后按回车键继续..."
}

execute() {
    local cmd=$1

    echo "正在执行命令: $cmd"
    eval $cmd

    if [ $? -ne 0 ]; then
        echo "命令 $cmd 失败，请手动重试并输入 'retry' 以继续，或者输入 'skip' 跳过此步骤。"
        while true; do
            read -p "请输入指令: " input
            if [ "$input" == "retry" ]; then
                eval $cmd
                if [ $? -eq 0 ]; then
                    break
                else
                    echo "重试失败，请再次输入 'retry' 或 'skip'。"
                fi
            elif [ "$input" == "skip" ]; then
                break
            else
                echo "无效输入，请输入 'retry' 或 'skip'。"
            fi
        done
    else
        echo "命令 $cmd 成功完成。"
    fi
}

# ssh key
execute "ssh-keygen -t rsa -b 4096 -C \"mainliufeng@gmail.com\""

# base
execute "sh pacman/link.sh"
execute "sudo pacman -S yay"
execute "sudo pacman -S base-devel patch yay gcc make automake pkg-config fasd the_silver_searcher dmenu fasd htop alsa-utils vulkan-intel feh ripgrep xclip downgrade libinput-gestures xdotool wmctrl the_silver_searcher ripgrep fzf kitty openssh google-chrome"
#execute "sudo pacman -S acpilight pass browserpass"
execute "yay -S clash-verge batterymon-clone"
execute "yay -S nerd-fonts-hack"
execute "sh libinput/link.sh"
execute "sh locale/link.sh"
execute "sh openvpn/setup.sh"
execute "sh resolv/link.sh"
execute "sh rofi/setup.sh"
execute "sh rofi/link.sh"
execute "sh user-dirs/link.sh"
execute "sh xorg/setup.sh"
execute "sh xorg/link.sh"
execute "sh awesome/setup.sh"
execute "sh awesome/link.sh"

# input method
execute "sudo pacman -S fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-chinese-addons fcitx5"
execute "yay -S fcitx5-pinyin-zhwiki rime-ice-git fcitx5-rime"

# zsh
execute "sh zsh/setup.sh"
execute "sh zsh/link.sh"

# git
execute "sh git/setup.sh"
execute "sh git/link.sh"

# kitty
execute "sh kitty/link.sh"

# neovim
execute "sh nvim/setup.sh"
execute "sh nvim/link.sh"

# golang
execute "sh go/setup.sh"
execute "sh go/link.sh"
execute "sudo pacman -S delve graphviz"

# node
execute "sudo pacman -S npm"

# python
execute "sh python/setup.sh"
execute "sh python/link.sh"

# docker
execute "sh docker/setup.sh"
execute "sh docker/link.sh"

# k8s
execute "sh kube/setup.sh"

# application
execute "sudo pacman -S volumeicon blueman libinput-gestures network-manager-applet flameshot xautolock slock nitrogen"
execute "yay -S google-chrome"

# dingtalk
execute "yay -S dingtalk-bin"

# rcrai
execute "sh ~/dotfiles-private/setup.sh"

manual_step "rime-ice-git配置：https://github.com/iDvel/rime-ice?tab=readme-ov-file#arch-linux"
manual_step "clash-verge导入订阅"

execute "sh go/after.sh"
execute "sh kube/after.sh"
execute "sh scripts/dotfiles-setup-scripts"

echo "所有步骤完成。"

