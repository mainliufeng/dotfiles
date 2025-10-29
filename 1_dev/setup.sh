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

# base
execute "sudo pacman -S yay"
execute "sudo pacman -S base-devel patch yay gcc make automake pkg-config fasd the_silver_searcher dmenu fasd htop alsa-utils feh ripgrep xclip downgrade the_silver_searcher ripgrep fzf openssh openvpn"
execute "yay -S nerd-fonts-hack"

# zsh
execute "sh zsh/setup.sh"
execute "sh zsh/link.sh"

# zellij
execute "sh zellij/setup.sh"
execute "sh zellij/link.sh"

# git
execute "sh git/setup.sh"
execute "sh git/link.sh"

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

# redis
execute "sh redis/setup.sh"

# k8s
execute "sh kube/setup.sh"

# rcrai
execute "sh ~/dotfiles-private/setup.sh"

execute "sh go/after.sh"
execute "sh kube/after.sh"
execute "sh scripts/dotfiles-setup-scripts"

echo "所有步骤完成。"

