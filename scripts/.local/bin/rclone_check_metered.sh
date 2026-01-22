#!/bin/bash
# rclone_check_metered.sh

if nmcli -p -f GENERAL.CONNECTION,GENERAL.METERED dev show | grep -i "yes" >/dev/null; then
    echo "$(date) Metered connection detected. Skipping rclone bisync." >>"$HOME/.config/rclone/rclone.log"
    exit 0
else
    exit 1
fi
