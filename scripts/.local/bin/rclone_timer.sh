#!/bin/bash
# rclone_timer.sh

if ! "$(dirname "$0")/rclone_check_metered.sh"; then
    echo "$(date +'%Y/%m/%d %H:%M:%S') rclone_timer triggered" >>"$HOME/.config/rclone/rclone.log"
    "$(dirname "$0")/rclone_sync.sh"
fi
