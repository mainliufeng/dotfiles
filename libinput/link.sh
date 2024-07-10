#!/bin/sh
sudo cp ~/dotfiles/libinput/40-libinput.conf /etc/X11/xorg.conf.d/
ln -svfn ~/dotfiles/libinput/libinput-gestures.conf ~/.config/libinput-gestures.conf
sudo gpasswd -a $USER input
