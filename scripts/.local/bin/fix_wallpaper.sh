#!/usr/bin/env bash

# Default to vertical if no argument is provided
ORIENTATION="vertical"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --horizontal)
        ORIENTATION="horizontal"
        shift
        ;;
    -v | --vertical)
        ORIENTATION="vertical"
        shift
        ;;
    *)
        echo "Unknown option: $1"
        echo "Usage: $0 [-h|--horizontal] [-v|--vertical]"
        exit 1
        ;;
    esac
done

# Get the current theme mode and trim whitespace
MODE=$(dms ipc theme getMode | tr -d '[:space:]')
echo $MODE

if [ "$MODE" = "light" ]; then
    # It's currently light: set light wallpaper based on orientation, then switch to dark
    if [ "$ORIENTATION" = "horizontal" ]; then
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/Goldy.jpg
    else
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/goldy_portrait.png
    fi
    dms ipc theme toggle
    sleep 2
    if [ "$ORIENTATION" = "horizontal" ]; then
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/Goldy_dark.jpg
    else
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/goldy_portrait_dark.png
    fi
    dms ipc theme toggle
else
    # It's currently dark: set dark wallpaper based on orientation, then switch to light
    if [ "$ORIENTATION" = "horizontal" ]; then
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/Goldy_dark.jpg
    else
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/goldy_portrait_dark.png
    fi
    dms ipc theme toggle
    sleep 2
    if [ "$ORIENTATION" = "horizontal" ]; then
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/Goldy.jpg
    else
        dms ipc call wallpaper setFor DP-1 ~/Pictures/goldy/goldy_portrait.png
    fi
    dms ipc theme toggle
fi
