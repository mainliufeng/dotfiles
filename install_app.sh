#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    echo "support only macos"
    exit 1
fi

show() {
    echo "\n---"
    echo $1
    echo "-------------------------------------"
}

if ! type brew > /dev/null; then
    show "install homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "skip homebrew brew command exist"
fi

show "install vim-plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

show "install brew apps"
brew bundle --file ~/dotfiles/brewfiles/Brewfile.base
brew bundle --file ~/dotfiles/brewfiles/Brewfile.home
brew bundle --file ~/dotfiles/brewfiles/Brewfile.develop
brew bundle --file ~/dotfiles/brewfiles/Brewfile.design
# sudo softwareupdate -i -a

show "set macos defaults"
sh ~/dotfiles/macos/defaults.sh

show "set macos file limits"
sudo cp -f ~/dotfiles/macos/limit.maxfiles.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist

show "install spacemacs"
if [ -d "$HOME/.emacs.d" ]; then
    mv ~/.emacs.d ~/.emacs.d.bak
    mv ~/.emacs ~/.emacs.bak
fi
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
