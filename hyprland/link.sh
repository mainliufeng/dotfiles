mkdir -p ~/.config/hypr
ln -svfn ~/dotfiles/hyprland/hyprland.conf ~/.config/hypr/hyprland.conf
ln -svfn ~/dotfiles/hyprland/hyprpaper/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -svfn ~/dotfiles/hyprland/scripts ~/.config/hypr/scripts

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
ln -svfn ~/dotfiles/hyprland/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
ln -svfn ~/dotfiles/hyprland/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini

ln -svfn ~/dotfiles/hyprland/waybar ~/.config/waybar
ln -svfn ~/dotfiles/hyprland/wofi ~/.config/wofi
ln -svfn ~/dotfiles/hyprland/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -svfn ~/dotfiles/hyprland/hypridle.conf ~/.config/hypr/hypridle.conf

# Optional: enable Howdy for hyprlock (PAM).
# Opt-in to avoid breaking unlock when howdy/pam_python3 isn't installed yet.
if [[ "${INSTALL_HYPRLOCK_PAM:-0}" == "1" ]]; then
  if command -v howdy >/dev/null 2>&1 && [[ -f /lib/security/pam_python3.so ]] && [[ -f /lib/security/howdy/pam.py ]]; then
    ~/dotfiles/hyprland/scripts/install-hyprlock-pam.sh || true
  else
    echo "skip: INSTALL_HYPRLOCK_PAM=1 but howdy/pam_python3 not found" >&2
  fi
else
  echo "tip: run INSTALL_HYPRLOCK_PAM=1 ./hyprland/link.sh to install /etc/pam.d/hyprlock (Howdy)" >&2
fi
