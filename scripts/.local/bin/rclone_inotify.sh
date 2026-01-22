#!/bin/bash
# rclone_inotify.sh

inotifywait -q -m -r -e move,create,delete,modify $HOME/gdrive | while read file; do
    if ! "$(dirname "$0")/rclone_check_metered.sh"; then
        echo "$(date +'%Y/%m/%d %H:%M:%S') rclone_inotify triggered" >>"$HOME/.config/rclone/rclone.log"
        "$(dirname "$0")/rclone_sync.sh"
    fi
done
