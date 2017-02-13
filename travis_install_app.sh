#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    echo "support only macos"
    exit 1
fi

if ! type brew > /dev/null; then
    echo "install homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "skip homebrew brew command exist"
fi

echo "install brew apps"
brew bundle --file ~/dotfiles/brewfiles/Brewfile.min
sudo softwareupdate -i -a

echo "set macos defaults"
sh ~/dotfiles/macos/defaults.sh

echo "install spacemacs"
if [ -d "$HOME/.emacs.d" ]; then
    mv ~/.emacs.d ~/.emacs.d.bak
    mv ~/.emacs ~/.emacs.bak
fi
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
