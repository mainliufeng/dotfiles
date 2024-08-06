# base
sudo pacman -S base-devel acpilight patch clash-verge yay gcc make automake pkg-config fasd the_silver_searcher dmenu fasd htop pass browserpass pinyin-completion alsa-utils vulkan-intel feh ripgrep xclip downgrade libinput-gestures xdotool wmctrl the_silver_searcher ripgrep
yay -S batterymon-clone nerd-fonts-hack

# git
sudo pacman -S git python-pre-commit

# fzf
sudo pacman -S fzf

# input method
sudo pacman -S fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-chinese-addons fcitx5
yay -S fcitx5-pinyin-zhwiki rime-ice-git fcitx5-rime
# rime-ice-git配置
# https://github.com/iDvel/rime-ice?tab=readme-ov-file#arch-linux
# rime选择输入法快捷键“ctrl+`”

# font
sudo pacman -S adobe-source-han-serif-cn-fonts noto-fonts-cjk

# golang
sudo pacman -S delve graphviz
# node
sudo pacman -S npm

# application
sudo pacman -S clash-verge volumeicon blueman libinput-gestures network-manager-applet flameshot xautolock slock nitrogen
yay -S google-chrome
