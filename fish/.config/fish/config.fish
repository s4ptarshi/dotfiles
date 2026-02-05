function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    set -g fish_vi_force_cursor 1
    # Set the cursor shapes for the different vi modes.
    set fish_cursor_default block blink
    set fish_cursor_insert line blink
    set fish_cursor_replace_one underscore blink
    set fish_cursor_visual block

    # Vi mode
    #ctrl f keybind
    function fish_user_key_bindings
        # Initialize the default Vi bindings
        fish_vi_key_bindings
        # Visual Mode: press 'y' to copy selection
        bind -M visual y fish_clipboard_copy
        # Normal Mode: 'yy' to copy line, 'Y' to copy to end of line
        bind -M default yy fish_clipboard_copy
        bind -M default Y fish_clipboard_copy

        # Normal Mode: 'p' to paste
        bind -M default p fish_clipboard_paste
        for mode in insert default visual
            bind -M $mode \cf forward-char
        end
    end

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    #applications
    alias nnn='nnn -a'
    alias e='nvim'
    alias chrome='flatpak run com.google.Chrome'

    # navigation
    alias ..='cd ..'
    alias ...='cd ../..'
    alias .3='cd ../../..'
    alias .4='cd ../../../..'
    alias .5='cd ../../../../..'

    #windowinfo
    alias kwininfo="qdbus org.kde.KWin /KWin queryWindowInfo"

    #ls
    alias ls='lsd -A'
    alias la='lsd -A'
    alias ll='lsd -Al'
    alias lt='lsd -A --tree'

    #mkdir
    alias mkdir='mkdir -p'

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

end

zoxide init fish | source

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#
# Uses the first conda installation found in the following list
set -x CONDA_PATH /data/miniconda3/bin/conda $HOME/miniconda3/bin/conda

function conda
    echo "Lazy loading conda upon first invocation..."
    functions --erase conda
    for conda_path in $CONDA_PATH
        if test -f $conda_path
            echo "Using Conda installation found in $conda_path"
            eval $conda_path "shell.fish" hook | source
            conda $argv
            return
        end
    end
    echo "No conda installation found in $CONDA_PATH"
end
# <<< conda initialize <<<
