### EXPORT ###
set fish_greeting                                 # Supresses fish's intro message
# set TERM "linux"                         # Sets the terminal type
set PATH $HOME/.local/bin/ $PATH

# fetch
afetch

#colorscheme
source $HOME/.config/fish/themes/tokyonight_night.fish
source $HOME/.config/fish/scripts/timer.fish

# Vi mode
function fish_user_key_bindings
  # fish_default_key_bindings
  fish_vi_key_bindings
end

# pure prompt
set --universal pure_color_success green

#ctrl f keybind
function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cf forward-char
    end
end

# Set the cursor shapes for the different vi modes.
set fish_cursor_default     block      blink
set fish_cursor_insert      line       blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual      block

### ALIASES ###

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# editor
alias e='lvim'

#windowinfo
alias wininfo="qdbus org.kde.KWin /KWin queryWindowInfo"

# TODO:change to lsd
alias ls='lsd -A'
alias la='lsd -A'
alias ll='lsd -Al'
alias lt='lsd -A --tree'

# # pacman and yay
# # alias pacsyu='sudo pacman -Syu'                 # update only standard pkgs
# # alias pacsyyu='sudo pacman -Syyu'                # Refresh pkglist & update standard pkgs
# # alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
# # alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
# # alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
# # alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
# alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
# alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

#fedora aliases
# alias install='sudo dnf install -y'
# alias remove='sudo dnf remove -y'
# alias update='sudo dnf upgrade -y && flatpak update -y'
# alias clean='sudo dnf autoremove'
# alias search='sudo dnf search'

alias install='yay -Sy'
alias remove='yay -Rns'
alias update='yay -Syu && flatpak update -y'
alias clean='pacman -Qtdq | pacman -Rns -'

#reload waybar
alias reload_waybar='killall -SIGUSR2 waybar'


# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'


# Merge Xresources
alias merge='xrdb -merge ~/.Xresources'

# git
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias tag='git tag'
alias newtag='git tag -a'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"
