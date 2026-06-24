#!/bin/bash

HOOK_NAME="$1"
HOOK_VALUE="$2"

case "$HOOK_NAME" in
"onMatugenCompleted")
    # Hook value is 'light' or 'dark'
    MODE="$HOOK_VALUE"

    if [ "$MODE" == "*dark:success*" ]; then
        # Dank shell (colorscheme) + Breezedark (if you want it as the base scheme)
        lookandfeeltool -a org.kde.breezedark.desktop 2>/dev/null
        plasma-apply-colorscheme Matugenb &>/dev/null
    else
        lookandfeeltool -a org.kde.breeze.desktop 2>/dev/null
        plasma-apply-colorscheme Matugena &>/dev/null
    fi
    # Blast the DBus signal to update icons instantly
    gdbus emit --session --object-path /KIconLoader --signal org.kde.KIconLoader.iconChanged 0
    ;;
esac
