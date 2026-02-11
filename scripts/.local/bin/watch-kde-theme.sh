#!/bin/bash

# 1. The file to watch (Must match your Matugen config output)
WATCH_FILE="$HOME/.cache/dms-kde-sync/current_color.txt"

# 2. The script to run when that file changes
UPDATE_SCRIPT="$HOME/.local/bin/update-kde-theme"

echo "Monitoring $WATCH_FILE for changes..."

# 3. Ensure the directory exists so inotifywait doesn't error out
mkdir -p "$(dirname "$WATCH_FILE")"
touch "$WATCH_FILE"

# 4. The Loop: Wait for a 'close_write' event (file finished writing)
while inotifywait -e close_write "$WATCH_FILE"; do
    echo "Detected change! Updating KDE..."

    # Read the new color
    NEW_COLOR=$(cat "$WATCH_FILE")

    # Run your updater
    "$UPDATE_SCRIPT" "$NEW_COLOR"
done
