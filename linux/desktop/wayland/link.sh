mkdir -p ~/.config/environment.d
mkdir -p ~/.config/autostart

ln -svfn ~/dotfiles/linux/desktop/wayland/environment.d/90-fcitx5.conf ~/.config/environment.d/90-fcitx5.conf
ln -svfn ~/dotfiles/linux/desktop/wayland/autostart/org.fcitx.Fcitx5.desktop ~/.config/autostart/org.fcitx.Fcitx5.desktop
