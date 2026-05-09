mkdir -p ~/.config/hypr
ln -svfn ~/dotfiles/linux/desktop/hyprland/hyprland.conf ~/.config/hypr/hyprland.conf
ln -svfn ~/dotfiles/linux/desktop/hyprland/hyprpaper/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -svfn ~/dotfiles/linux/desktop/hyprland/scripts ~/.config/hypr/scripts

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
ln -svfn ~/dotfiles/linux/desktop/hyprland/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
ln -svfn ~/dotfiles/linux/desktop/hyprland/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini

ln -svfn ~/dotfiles/linux/desktop/hyprland/waybar ~/.config/waybar
ln -svfn ~/dotfiles/linux/desktop/hyprland/wofi ~/.config/wofi
ln -svfn ~/dotfiles/linux/desktop/hyprland/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -svfn ~/dotfiles/linux/desktop/hyprland/hypridle.conf ~/.config/hypr/hypridle.conf

# enable Howdy for hyprlock (PAM).
if command -v howdy >/dev/null 2>&1 && [[ -f /lib/security/pam_python3.so ]] && [[ -f /lib/security/howdy/pam.py ]]; then
  ~/dotfiles/linux/desktop/hyprland/scripts/install-hyprlock-pam.sh || true
else
  echo "skip: howdy/pam_python3 not found" >&2
fi
