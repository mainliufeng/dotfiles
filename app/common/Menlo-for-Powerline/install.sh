git clone git@github.com:abertsch/Menlo-for-Powerline.git $MENLO_FOR_POWERLINE_HOME
mkdir ~/.fonts
cp -f $MENLO_FOR_POWERLINE_HOME/*.ttf ~/.fonts/
fc-cache -vf ~/.fonts
