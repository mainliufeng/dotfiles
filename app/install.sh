#!/bin/sh

# env config
source ~/dotfiles/app/env.sh

# install common apps
for install_sh in ~/dotfiles/app/common/*/install.sh; do
    source $install_sh
done

if [ "$(uname -s)" == "Darwin" ]; then
    # install brew
    if ! type brew > /dev/null; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    
    # install brew apps
    brew bundle --file ~/dotfiles/app/macos/Brewfile
    sudo softwareupdate -i -a
    
    # macos defaults
    sh ~/dotfiles/app/macos/defaults.sh
    
    # install apps
    for install_sh in ~/dotfiles/app/macos/*/install.sh; do
        source $install_sh
    done
fi
