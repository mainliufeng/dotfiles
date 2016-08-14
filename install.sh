# install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
curl -o $HOME/.oh-my-zsh/themes/cobalt2.zsh-theme https://raw.githubusercontent.com/wesbos/Cobalt2-iterm/master/cobalt2.zsh-theme
 
# clone my dotfiles
cd $HOME
git clone https://github.com/Liu-Feng/dotfiles.git

# install apps
cd $HOME/dotfiles
brew bundle
sudo softwareupdate -i -a

# create links
cd $HOME/dotfiles
stow git
stow vim
stow zsh
stow tmux

# macos defaults
sh $HOME/dotfiles/macos_defaults.sh

mkdir -p $HOME/Code/github/

# Menlo for Powerline font
cd $HOME/Code/github/
git clone git@github.com:abertsch/Menlo-for-Powerline.git
mkdir -p $HOME/.fonts/
cd $HOME/Code/github/Menlo-for-Powerline/*.ttf $HOME/.fonts/
fc-cache -vf ~/.fonts

# Solarized color
cd $HOME/Code/github/
git clone git@github.com:altercation/solarized.git

# socks5 to http
mkdir -p /usr/local/opt/polipo/
cp $HOME/dotfiles/config/homebrew.mxcl.polipo.plist /usr/local/opt/polipo/
