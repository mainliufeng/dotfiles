## https://wiki.archlinux.org/title/Lenovo_Yoga_14s_2021
yay -S cpupower-gui

## 睡眠无法唤醒
联想yoga pro 14s，archlinux系统，有时睡眠无法唤醒，怎么解决

FL
对于Yoga Pro 14s在Arch Linux下睡眠唤醒有问题,可以尝试以下几点:

更新系统内核到最新版本,并确保安装了最新的芯片组和电源管理驱动。新的内核和驱动可能解决了睡眠唤醒的问题。
检查是否在BIOS中启用了快速启动或混合睡眠。如果启用了,尝试关闭快速启动和仅使用S3普通睡眠。
修改内核参数,添加 mem_sleep_default=deep 来使用深度睡眠而不是浅睡眠。
禁用独立显卡的runtime pm,添加内核参数 nvidia-drm.modeset=1。
尝试不同的睡眠状态,如suspend、hibernate,看哪种状态唤醒更稳定。
检查是否存在冲突的内核模块,尝试在睡眠前卸载不需要的模块。
分析日志文件如dmesg,看看唤醒失败的时候有何报错信息,进一步定位问题所在。
在尝试各种方法确定问题原因后,选择合适的解决方案,应该可以提高Yoga Pro 14s在Arch Linux下的睡眠唤醒稳定性。

Copy

mem_sleep_default=deep怎么配

FL
在Arch Linux下设置内核参数mem_sleep_default=deep的方法如下:

创建/etc/default/grub.d/sleep.cfg文件
在文件中添加如下内容:
<!---->
Copy code

GRUB_CMDLINE_LINUX_DEFAULT="mem_sleep_default=deep"
3.  保存退出后更新GRUB配置

<!---->
Copy code

sudo grub-mkconfig -o /boot/grub/grub.cfg
4.  重启电脑

这样在内核启动参数中就会加入mem_sleep_default=deep。

另一种方法是直接编辑/etc/default/grub文件,在GRUB_CMDLINE_LINUX_DEFAULT一行添加mem_sleep_default=deep,然后运行grub-mkconfig命令更新即可。

这个参数修改后,系统会默认使用深度睡眠而不是浅睡眠,有些电脑的睡眠唤醒问题可以通过这种方式解决。你可以试试这个方法,看是否能改善Yoga Pro 14s的睡眠唤醒情况。

Copy

mem_sleep_default=deep是s3普通睡眠吗

FL
是的,mem_sleep_default=deep设置的是S3普通睡眠状态,也称为挂起到RAM。

Linux系统的睡眠状态主要有:

S1 - 浅睡眠(Standby) ,系统处于低功耗状态,可以快速唤醒
S3 - 普通睡眠(Suspend to RAM),系统状态写入内存,电源关闭,可以唤醒并恢复状态
S4 - 深度睡眠(Hibernate),系统状态写入硬盘,机器完全关闭,唤醒后从硬盘恢复状态
mem_sleep_default参数的默认值是s2idle,即浅睡眠S1状态。

将其设置为deep时,表示使用S3普通睡眠状态,系统会写内存并切断电源。

这个状态切换时间略长于浅睡眠,但可以正确保存系统状态。有些电脑的睡眠问题就是S1状态下无法正确恢复,而S3可以避免该问题。

所以使用mem_sleep_default=deep可以尝试切换到S3睡眠,看是否可以解决Yoga Pro 14s的睡眠唤醒问题。

Copy

linux如何触发s2idle sleep

FL
在 Linux 系统中触发 s2idle 浅睡眠的方法主要有以下几种:

通过suspend命令:
<!---->
Copy code

sudo suspend
以root权限运行suspend命令,默认会使系统进入浅睡眠s2idle状态。

通过pm-suspend命令:
<!---->
Copy code

sudo pm-suspend
pm-suspend也可以让系统进入浅睡眠。

通过systemctl suspend :
<!---->
Copy code

systemctl suspend
使用systemd的suspend单元可以进入浅睡眠。

关闭笔记本盖子:
大多数笔记本在盖子关闭时会自动触发浅睡眠。可以配置合盖时的动作为suspend进而达到s2idle。

运行echo命令:
<!---->
Copy code

echo mem > /sys/power/state
向/sys/power/state写入mem可以使系统浅睡眠。

按电源按钮:
笔记本电源按钮也通常会让系统睡眠,根据配置可以是深睡眠或浅睡眠。

所以通过这些方法都可以让 Linux 系统进入 s2idle 浅睡眠状态。你可以根据自己的使用习惯选择合适的触发浅睡眠的方法。
