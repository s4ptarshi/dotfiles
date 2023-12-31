### EXPORT ###
set fish_greeting # Supresses fish's intro message
# fortune | cowsay | lolcat
set -gx LANG en_IN.UTF-8 # Adjust this to your language!
set -gx LC_ALL en_IN.UTF-8 # Adjust this to your locale!

#colorscheme
source $HOME/.config/fish/themes/tokyonight_night.fish
source $HOME/.config/fish/scripts/timer.fish

# Vi mode
set -g fish_vi_force_cursor 1
function fish_user_key_bindings
    # fish_default_key_bindings
    fish_vi_key_bindings
    bind yy fish_clipboard_copy
    bind Y fish_clipboard_copy
    bind p fish_clipboard_paste
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
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

### ALIASES ###

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# editor
alias e='nvim'

#windowinfo
alias kwininfo="qdbus org.kde.KWin /KWin queryWindowInfo"

#ls
alias ls='lsd -A'
alias la='lsd -A'
alias ll='lsd -Al'
alias lt='lsd -A --tree'

#mkdir
alias mkdir='mkdir -p'

#chrome
alias chrome='flatpak run com.google.Chrome'

#aliases (distro specific)
set distro (cat /etc/os-release | grep "^ID=" | cut -d= -f2 | tr -d '"')
switch (uname)
    case Linux
        switch $distro
            case opensuse-tumbleweed
                # openSUSE aliases
                alias install='sudo zypper in -y'
                alias remove='sudo zypper rm'
                alias update='sudo zypper dup -y && flatpak update -y'
                alias clean="zypper packages --unneeded | awk -F' | ' 'NR==0 || NR==1 || NR==2 || NR==3 || NR==4 {next} {print $3}' | grep -v Name | sudo xargs zypper remove --clean-deps"
                alias search='zypper search'
            case fedora
                # Fedora aliases
                alias install='sudo dnf install -y'
                alias remove='sudo dnf remove -y'
                alias update='sudo dnf upgrade -y && flatpak update -y'
                alias clean='sudo dnf autoremove'
                alias search='sudo dnf search'
            case arch
                # Arch Linux aliases
                alias install='yay -Sy'
                alias remove='yay -Rns'
                alias update='yay -Syu && flatpak update -y'
                alias clean='pacman -Qtdq | pacman -Rns -'
                alias search='search'
                alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
        end
    case "*"
        echo "Unsupported operating system."
end

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
alias mkdir='mkdir -p'


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
