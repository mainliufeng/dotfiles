mkdir -p ~/.config/hypr
ln -svfn ~/dotfiles/hyprland/hyprland.conf ~/.config/hypr/hyprland.conf
ln -svfn ~/dotfiles/hyprland/hyprpaper/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -svfn ~/dotfiles/hyprland/scripts ~/.config/hypr/scripts

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
ln -svfn ~/dotfiles/hyprland/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
ln -svfn ~/dotfiles/hyprland/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini

ln -svfn ~/dotfiles/hyprland/waybar ~/.config/waybar
ln -svfn ~/dotfiles/hyprland/wofi ~/.config/wofi
ln -svfn ~/dotfiles/hyprland/swaylock ~/.config/swaylock
