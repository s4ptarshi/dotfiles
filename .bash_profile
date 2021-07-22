#
# ~/.bash_profile
#

#startx

#if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
#  exec startx
#fi


# xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto &
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox" 
export CM_LAUNCHER="rofi" 
export RANGER_LOAD_DEFAULT_RC="FALSE" 
export PATH=$PATH:/home/antimony2k/.local/share/bin:~/.emacs.d/bin

# cdm

# To avoid potential situation where cdm(1) crashes on every TTY, here we
# default to execute cdm(1) on tty1 only, and leave other TTYs untouched.

if [[ "$(tty)" == '/dev/tty1' ]]; then
    [[ -n "$CDM_SPAWN" ]] && return
    # Avoid executing cdm(1) when X11 has already been started.
    [[ -z "$DISPLAY$SSH_TTY$(pgrep xinit)" ]] && exec cdm
fi


[[ -f ~/.bashrc ]] && . ~/.bashrc
