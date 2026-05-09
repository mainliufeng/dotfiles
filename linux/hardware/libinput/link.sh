#!/bin/sh
sudo cp ~/dotfiles/linux/hardware/libinput/40-libinput.conf /etc/X11/xorg.conf.d/
ln -svfn ~/dotfiles/linux/hardware/libinput/libinput-gestures.conf ~/.config/libinput-gestures.conf
sudo gpasswd -a $USER input
