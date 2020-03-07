#!/bin/sh
brew install zsh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh

# powerlevel9k
brew tap sambadevi/powerlevel9k
brew install powerlevel9k
