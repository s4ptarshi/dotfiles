#!/bin/bash

LEVEL=$(xbacklight -get | xargs printf "%.f")

case "$1" in
  "up")
    [[ "$LEVEL" -eq 100 ]]
    xbacklight -inc 5
    ;;
  "down")
    xbacklight -dec 10
    ;;
esac

LEVEL=$(xbacklight -get | xargs printf "%.f")
# notification
volnoti-show -s /usr/share/pixmaps/volnoti/display-brightness-symbolic.svg $LEVEL
