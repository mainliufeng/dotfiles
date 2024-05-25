#!/bin/sh

ts=$(date +%s)
picfile="$HOME/Pictures/ocr.${ts}.png"
flameshot gui -p "${picfile}" > /dev/null 2>&1
python "$(dirname "$0")/ocr.py" "${picfile}"
rm "${picfile}"

