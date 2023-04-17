sudo cp -rf ~/dotfiles/pacman/mirrorlist /etc/pacman.d/
sudo cp -rf ~/dotfiles/pacman/pacman.conf /etc/
sudo pacman -Syyu
sudo pacman -Sy archlinuxcn-keyring
sudo pacman -Syyu
