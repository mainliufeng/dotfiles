sudo cp -rf ~/dotfiles/pacman/mirrorlist /etc/pacman.d/
sudo cp -rf ~/dotfiles/pacman/pacman.conf /etc/
sudo pacman -Sy archlinuxcn-keyring archlinux-keyring
sudo pacman-key --lsign-key "lilac@build.archlinuxcn.org"
sudo pacman -Syyu
