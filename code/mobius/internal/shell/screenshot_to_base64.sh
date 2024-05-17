#!/bin/sh

ts=$(date +%s)
picfile="$HOME/Pictures/ocr.${ts}.png"
textfile="$HOME/Pictures/ocr.${ts}.text"
flameshot gui -p ${picfile} > /dev/null 2>&1
base64 ${picfile} > ${textfile}
cat ${textfile} 
rm ${picfile}
rm ${textfile}
