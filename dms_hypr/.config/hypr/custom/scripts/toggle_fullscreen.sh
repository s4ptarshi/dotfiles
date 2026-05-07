#!/usr/bin/env bash
# Toggle focused column full-width, tracked per window address
# Includes Gap-Shrinkage prevention (snapping to common widths)

STATE_DIR="/tmp/hypr_fullcol"
mkdir -p "$STATE_DIR"

# Get all info about the currently active window
ACTIVE_WIN=$(hyprctl activewindow -j)
ADDR=$(echo "$ACTIVE_WIN" | jq -r '.address')

if [ -z "$ADDR" ] || [ "$ADDR" = "null" ]; then
    exit 1
fi

STATE_FILE="$STATE_DIR/$ADDR"

if [ -f "$STATE_FILE" ]; then
    # --- TOGGLE OFF ---
    PREV_WIDTH=$(cat "$STATE_FILE")

    hyprctl dispatch layoutmsg "colresize $PREV_WIDTH"
    hyprctl dispatch layoutmsg "move -col"

    rm "$STATE_FILE"
else
    # --- TOGGLE ON ---
    WIN_WIDTH=$(echo "$ACTIVE_WIN" | jq -r '.size[0]')
    MON_ID=$(echo "$ACTIVE_WIN" | jq -r '.monitor')
    MON_WIDTH=$(hyprctl monitors -j | jq -r --argjson id "$MON_ID" '.[] | select(.id == $id) | .width')

    # 1. Calculate the exact, raw ratio (e.g., 0.4912)
    RAW_RATIO=$(awk -v ww="$WIN_WIDTH" -v mw="$MON_WIDTH" 'BEGIN { print ww/mw }')

    # 2. Snap to the nearest standard fraction to prevent gap drift
    SNAP_RATIO=$(awk -v r="$RAW_RATIO" '
        function abs(x) { return x < 0 ? -x : x }
        BEGIN {
            # The standard column sizes you normally use
            split("0.33 0.50 0.66 0.75", arr, " ")
            
            closest = r
            for (i in arr) {
                diff = abs(r - arr[i])
                # If the raw ratio is within 5% of a standard size, snap it to that size
                if (diff < 0.05) { 
                    closest = arr[i]
                    break
                }
            }
            # Output the safely snapped ratio, rounded to 2 decimals
            printf "%.2f", closest
        }
    ')

    # 3. Save the SNAPPED ratio instead of the raw one
    echo "$SNAP_RATIO" >"$STATE_FILE"

    hyprctl dispatch layoutmsg "colresize 1.0"
fi
