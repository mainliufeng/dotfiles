#! /bin/bash
VALUE=`amixer get Master | sed s/%.*$// | sed 's/^.*\[//' | tail -n 1`
echo "$VALUE%"
