mkdir -p ~/.local/share/applications
# Same filename as the packaged entry, so this one wins (XDG user dir first).
ln -svfn ~/dotfiles/linux/apps/paseo/applications/paseo.desktop ~/.local/share/applications/paseo.desktop
mkdir -p ~/.config/systemd/user/paseo.service.d
ln -svfn ~/dotfiles/linux/apps/paseo/systemd/95-schedule-fix.conf ~/.config/systemd/user/paseo.service.d/95-schedule-fix.conf
