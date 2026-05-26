#!/bin/bash
# rclone_sync.sh

# 1. Environment Setup for Cron
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=${XDG_RUNTIME_DIR}/bus
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-1

# 2. Script Variables
local_dir=$HOME/gdrive
remote_dir=gdrive:/
log_file="$HOME/.config/rclone/rclone.log"
filter_file="$HOME/.config/rclone/filters.txt"

echo "$(date +'%Y/%m/%d %H:%M:%S') Sync started" >>"$log_file"

# Run rclone and capture output
output=$(rclone bisync \
    "$remote_dir" "$local_dir" \
    --filters-file "$filter_file" \
    --fast-list \
    --transfers 16 \
    --checkers 32 \
    --drive-chunk-size 64M \
    --compare size,modtime \
    --modify-window 1s \
    --create-empty-src-dirs \
    --drive-skip-gdocs \
    --drive-skip-shortcuts \
    --drive-skip-dangling-shortcuts \
    --metadata \
    --track-renames \
    --fix-case \
    --resilient \
    --recover \
    --max-lock 2m \
    --check-access \
    --stats-one-line 2>&1 | tee -a "$log_file")

# Capture the exit code of rclone
result=${PIPESTATUS[0]}

# 1. SILENT EXIT FOR LOCK FILES
if [[ $result -ne 0 ]] && echo "$output" | grep -q "prior lock file found"; then
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync skipped: Lock file exists." >>"$log_file"
    exit 0
fi

# 2. NORMAL SUCCESS LOGIC
if [ $result -eq 0 ]; then
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync done" >>"$log_file"

    if echo "$output" | grep -Eq "Transferred:[[:space:]]+[1-9]|Deleted:[[:space:]]+[1-9]"; then
        notify-send -u normal -t 10000 "Rclone Sync" "Files were updated." >>"$log_file" 2>&1
    else
        echo "$(date +'%Y/%m/%d %H:%M:%S') No changes detected." >>"$log_file"
    fi
# 3. ACTUAL FAILURE LOGIC
else
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync failed" >>"$log_file"
    notify-send -u critical -t 10000 "Rclone Sync" "Sync failed! Check logs." >>"$log_file" 2>&1
fi
