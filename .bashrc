#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
export PATH=/home/antimony2k/.local/bin:$PATH
export ICON=/home/antimony2k/.icons:$ICON
#exec fish
alias config='/usr/bin/git --git-dir=/home/antimony2k/dotfiles/ --work-tree=/home/antimony2k'
