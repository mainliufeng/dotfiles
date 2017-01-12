#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    echo "support only macos"
    exit 1
fi

LOG=./install.log

if ! type brew > /dev/null; then
    echo "install homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> $LOG
else
    echo "skip homebrew brew command exist"
fi

echo "install brew apps"
brew bundle --file ~/dotfiles/brewfiles/Brewfile.base &> $LOG
brew bundle --file ~/dotfiles/brewfiles/Brewfile.home &> $LOG
brew bundle --file ~/dotfiles/brewfiles/Brewfile.develop &> $LOG
brew bundle --file ~/dotfiles/brewfiles/Brewfile.design &> $LOG
sudo softwareupdate -i -a &> $LOG

echo "set macos defaults"
sh ~/dotfiles/macos/defaults.sh &> $LOG
