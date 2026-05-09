#! /bin/bash
MUTE=`pacmd list-sinks | awk '/muted/ { print $2 }' | grep yes`
if [ "$MUTE" ]; then
    echo "<icon=off_volume.xpm/>"
else
    echo "<icon=volume.xpm/>"
fi

