#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    echo "support only macos"
    exit 1
fi

echo_install () {
    echo "install $1"
}

echo_skip () {
    echo "skip    $1 ($2)"
}

echo_set () {
    echo "set     $1"
}

LOG=./install.log

if ! type brew > /dev/null; then
    echo_install "homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> $LOG
else
    echo_skip "homebrew" "brew command exist"
fi

echo_install "brew apps"
brew bundle --file ~/dotfiles/app/brewfiles/Brewfile.base &> $LOG
brew bundle --file ~/dotfiles/app/brewfiles/Brewfile.home &> $LOG
brew bundle --file ~/dotfiles/app/brewfiles/Brewfile.develop &> $LOG
brew bundle --file ~/dotfiles/app/brewfiles/Brewfile.design &> $LOG
sudo softwareupdate -i -a &> $LOG

echo_set "macos defaults"
sh ~/dotfiles/app/defaults.sh &> $LOG

if [ ! -d "$HOME/.zgen" ]; then
    echo_install "zgen"
    sh -c "git clone https://github.com/tarjoilija/zgen.git \"${HOME}/.zgen\"" &> $LOG
else
    echo_skip "zgen" "$HOME/.zgen exist"
fi

if [ ! -f "$HOME/.zgen/robbyrussell/oh-my-zsh-master/themes/cobalt2.zsh-theme" ]; then
    echo_install "cobalt2 theme"
    curl -o $HOME/.zgen/robbyrussell/oh-my-zsh-master/themes/cobalt2.zsh-theme https://raw.githubusercontent.com/wesbos/Cobalt2-iterm/master/cobalt2.zsh-theme &> $LOG
else
    echo_skip "cobalt2" "($HOME/.zgen/robbyrussell/oh-my-zsh-master/themes/cobalt2.zsh-theme exist)"
fi

# resources
RESOURCES=$HOME/dotfiles/.resources
if [ ! -d "$RESOURCES" ]; then
    echo "\nresources is in $RESOURCES"
    mkdir -p $RESOURCES
    
    echo_install "solarized"
    git clone https://github.com/altercation/solarized $RESOURCES/solarized &> $LOG
    
    echo_install "menlo for powerline"
    git clone https://github.com/abertsch/Menlo-for-Powerline $RESOURCES/menlo-for-powerline &> $LOG && mkdir -p ~/.fonts &> $LOG && cp -f $RESOURCES/menlo-for-powerline/*.ttf ~/.fonts/ &> $LOG && fc-cache -vf ~/.fonts &> $LOG
    
    echo_install "polipo"
    cp ~/dotfiles/app/resources/homebrew.mxcl.polipo.plist /usr/local/opt/polipo/ &> $LOG
else
    echo_skip "solarized" "$RESOURCES exist"
    echo_skip "menlo for powerline" "$RESOURCES exist"
fi
