#!/bin/fish
# deps 
# timer-bin from aur (https://github.com/caarlos0/timer)
# notify-send

function pomodoro 
  echo $argv[1]
  timer "$argv[2]"m 
  notify-send "'$argv[1]' session done" -i $HOME/Pictures/pomodoro_icon.png
end

alias po="pomodoro"
alias wo="pomodoro work 45"
alias br="pomodoro break 10"
