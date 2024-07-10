## 下载pkgbuild
# yay -G dingtalk-bin
## reset到543a8ccb4ad5704312db3ce27ca3054ec515dec5
# git reset --hard 543a8ccb4ad5704312db3ce27ca3054ec515dec5
## 安装
# makepkg -si

# 编辑钉钉启动程序
# 
# sudo vim /usr/bin/dingtalk
# 添加下面一行
# 
# export QT_IM_MODULE=fcitx
# export QT_QPA_PLATFORM="wayland;xcb"

yay -S lib32-libxcrypt-compat libxcrypt-compat
