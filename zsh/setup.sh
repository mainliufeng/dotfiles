#!/bin/sh
sudo pacman -S zsh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh

# powerlevel10k
sudo pacman -S zsh-theme-powerlevel10k

# completions
sudo pacman -S zsh-completions zsh-history-substring-search zsh-syntax-highlighting

# change default shell to zsh
chsh -s /usr/bin/zsh
