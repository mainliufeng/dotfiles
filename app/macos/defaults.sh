# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string 'left'

defaults write com.apple.finder AppleShowAllFiles TRUE
defaults write com.apple.finder CreateDesktop -bool false
killall Finder
