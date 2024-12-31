#!/bin/bash

file="$1"

# Give write permissions to printer
sudo chmod 666 /dev/usb/lp0

# Print file
OLD_IFS="$IFS"
IFS=
while read -r line; do
  echo -e "$line" > /dev/usb/lp0
done < $file
IFS="$OLD_IFS"
