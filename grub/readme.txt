sudo vi /etc/default/grub

1. change GRUB_TIMEOUT to 5
2. comment out GRUB_HIDDEN_TIMEOUT
3. change GRUB_TIMEOUT_STYLE to menu

sudo grub-mkconfig -o /boot/grub/grub.cfg
