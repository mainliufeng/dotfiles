mkdir -p ~/.config
ln -svfn ~/dotfiles/linux/apps/chrome/chrome-flags.conf ~/.config/chrome-flags.conf

mkdir -p ~/.local/share/applications
ln -svfn ~/dotfiles/linux/apps/chrome/applications/google-chrome.desktop ~/.local/share/applications/google-chrome.desktop
ln -svfn ~/dotfiles/linux/apps/chrome/applications/google-chrome.xorg.desktop ~/.local/share/applications/google-chrome.xorg.desktop
