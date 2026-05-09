#! /bin/bash

# A better method; requires the acpi package

# Get percentage
VALUE=`acpi -b | sed s/%.*$// | sed 's/^.*\s//'`

# Get charging status ("C"=charging, "D"=dischaging)
CHARGING=`acpi | tail -c +12 | head -c 1`

# Calculate colour
if [ "$CHARGING" == "C" ]; then
    echo "<fc=gray>$VALUE%</fc><icon=battery_charching.xpm/>"
else
	if [ "$VALUE" -gt "80" ]; then
        echo "<fc=gray>$VALUE%</fc><icon=battery5.xpm/>"
    elif [ "$VALUE" -gt "60" ]; then
        echo "<fc=gray>$VALUE%</fc><icon=battery4.xpm/>"
    elif [ "$VALUE" -gt "40" ]; then
        echo "<fc=gray>$VALUE%</fc><icon=battery3.xpm/>"
    elif [ "$VALUE" -gt "20" ]; then
        echo "<fc=gray>$VALUE%</fc><icon=battery2.xpm/>"
    elif [ "$VALUE" -gt "07" ]; then
        echo "<fc=gray>$VALUE%</fc><icon=battery1.xpm/>"
	else
        echo "<fc=gray>$VALUE%</fc><icon=battery0.xpm/>"
	fi
fi
