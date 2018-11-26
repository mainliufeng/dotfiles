git submodule init
git submodule update
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install python
brew tap caskroom/versions
/usr/local/bin/pip3 install -r ~/dotfiles/external/inquirer/requirements.txt
/usr/local/bin/pip3 install pyyaml
