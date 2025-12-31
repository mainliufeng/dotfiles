mkdir -p ~/.local/share/applications
ln -svfn ~/dotfiles/alma/applications/alma.desktop ~/.local/share/applications/alma.desktop
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/hypr-launcher/apps.tsv"
