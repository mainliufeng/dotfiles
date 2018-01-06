#!/bin/sh

confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

case $(uname) in
Linux)
    ;;
Darwin)
    ;;
*)
    echo "os not supported"
    exit 1
esac

if ! type brew > /dev/null; then
    printf "install homebrew\n"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "skip homebrew brew command exist"
fi

printf "install vim-plug\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

printf "install brew apps\n"
brew bundle --file ~/dotfiles/brewfiles/Brewfile.base
brew bundle --file ~/dotfiles/brewfiles/Brewfile.home
brew bundle --file ~/dotfiles/brewfiles/Brewfile.develop
brew bundle --file ~/dotfiles/brewfiles/Brewfile.design
# sudo softwareupdate -i -a

printf "set macos defaults\n"
sh ~/dotfiles/macos/defaults.sh

printf "set macos file limits\n"
sudo cp -f ~/dotfiles/macos/limit.maxfiles.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
