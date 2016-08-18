mkdir ~/.fonts
cp -f $MENLO_FOR_POWERLINE_HOME/*.ttf ~/.fonts/
fc-cache -vf ~/.fonts
