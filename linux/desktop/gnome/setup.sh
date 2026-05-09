sudo pacman -S gnome
yay -S gnome-shell-extension-paperwm-git
yay -S gnome-shell-extension-tray-icons-reloaded
yay -S gnome-network-displays-git
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub

# add "--gtk-version=4" to chrome command(/usr/share/applications/google-chrome.desktop)
