#!/bin/bash
# rclone_sync.sh

local_dir=$HOME/gdrive
remote_dir=gdrive:/
log_file="$HOME/.config/rclone/rclone.log"
filter_file="$HOME/.config/rclone/filters.txt"

# Needed for notifications to appear on your desktop from cron
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

echo "$(date +'%Y/%m/%d %H:%M:%S') Sync started" >>"$log_file"

# Run rclone and capture output to variable while ALSO appending to log file
# We remove --log-file from the command so output goes to stdout/stderr
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

# Capture the exit code of rclone, not the tee command
result=${PIPESTATUS[0]}

# 1. SILENT EXIT FOR LOCK FILES
# If rclone failed but the output mentions a "prior lock file", exit without notifying.
if [[ $result -ne 0 ]] && echo "$output" | grep -q "prior lock file found"; then
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync skipped: Lock file exists." >>"$log_file"
    exit 0
fi

# 2. NORMAL SUCCESS LOGIC
if [ $result -eq 0 ]; then
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync done" >>"$log_file"

    if echo "$output" | grep -Eq "Transferred:[[:space:]]+[1-9]|Deleted:[[:space:]]+[1-9]"; then
        notify-send "Google Drive" "Sync finished: Files were updated." -i drive
    else
        echo "$(date +'%Y/%m/%d %H:%M:%S') No changes detected." >>"$log_file"
    fi
# 3. ACTUAL FAILURE LOGIC
else
    echo "$(date +'%Y/%m/%d %H:%M:%S') Sync failed" >>"$log_file"
    notify-send "Google Drive" "Sync failed! Check logs." -i error
fi
