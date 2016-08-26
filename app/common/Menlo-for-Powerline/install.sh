git clone https://github.com/abertsch/Menlo-for-Powerline $MENLO_FOR_POWERLINE_HOME
mkdir ~/.fonts
cp -f $MENLO_FOR_POWERLINE_HOME/*.ttf ~/.fonts/
fc-cache -vf ~/.fonts
