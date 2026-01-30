#!/bin/sh
sh ~/dotfiles/macos/defaults.sh
sudo cp -f ~/dotfiles/macos/limit.maxfiles.plist /Library/LaunchDaemons/ && sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist && sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
