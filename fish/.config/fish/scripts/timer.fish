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
alias wo="pomodoro work 25"
alias sbr="pomodoro 'short break' 5"
alias lbr="pomodoro 'long break' 20"
