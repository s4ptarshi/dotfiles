#!/usr/bin/env bash

LOGFILE="$HOME/gamescope_steam.log"

echo "========================================" >>"$LOGFILE"
echo "Starting Gamescope Session: $(date)" >>"$LOGFILE"
echo "========================================" >>"$LOGFILE"

# Force Gamescope to use the newly installed AMD Vulkan driver
# (Update this filename if your 'ls' output shows something slightly different)
# export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.json

export SDL_VIDEODRIVER=wayland
export XDG_CURRENT_DESKTOP=gamescope

gamescope --backend drm -W 1920 -H 1080 -r 60 -e -- flatpak run com.valvesoftware.Steam -gamepadui >>"$LOGFILE" 2>&1
