#!/bin/bash
IS_PAUSED=$(dunstctl is-paused)

if [ "$IS_PAUSED" == "false" ]; then
	notify-send "Turning off notifications."
	dunstctl set-paused true
else
	notify-send "Turning on notifications."
	dunstctl set-paused false
fi
