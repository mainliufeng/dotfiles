mkdir -p ~/.local/share/applications
mkdir -p ~/.local/bin
mkdir -p ~/.local/lib/dingtalk-wayland-screenshare

ln -svfn ~/dotfiles/linux/apps/dingtalk/bin/dingtalk-wayland-hook ~/.local/bin/dingtalk-wayland-hook
ln -svfn ~/dotfiles/linux/apps/dingtalk/lib/dingtalk-wayland-screenshare/libdingtalkhook.so ~/.local/lib/dingtalk-wayland-screenshare/libdingtalkhook.so
ln -svfn ~/dotfiles/linux/apps/dingtalk/applications/com.alibabainc.dingtalk.desktop ~/.local/share/applications/com.alibabainc.dingtalk.desktop
