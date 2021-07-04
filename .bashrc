#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


#run pfetch on terminal launch
pfetch
#export PATH=/home/antimony2k/bin:$PATH
#export ICON=/home/antimony2k/.icons:$ICON
#export EDITOR="nvim"
#export TERMINAL="alacritty"
#export BROWSER="brave" 
alias config='/usr/bin/git --git-dir=/home/antimony2k/dotfiles/ --work-tree=/home/antimony2k'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/antimony2k/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/antimony2k/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/antimony2k/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/antimony2k/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

