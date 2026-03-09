if status is-interactive # Commands to run in interactive sessions can go here

    set -g fish_vi_force_cursor 1
    # Set the cursor shapes for the different vi modes.
    set fish_cursor_default block blink
    set fish_cursor_insert line blink
    set fish_cursor_replace_one underscore blink
    set fish_cursor_visual block

    # No greeting
    set fish_greeting
    # function fish_greeting
    #     krabby random -i
    # end
    set --global hydro_fetch true
    set --global hydro_multiline true

    zoxide init fish | source
    # Use starship
    # if type -q starship
    #     starship init fish | source
    # end

    alias file-manager='app2unit-open -S both . &'
    # Abbreviations (Space separated, no equals sign)
    abbr -a pamcan pacman
    abbr -a clear "printf '\033[2J\033[3J\033[1;1H'"
    abbr -a q 'qs -c ii'
    # Applications
    abbr -a nnn 'nnn -a'
    abbr -a e nvim
    abbr -a chrome 'flatpak run com.google.Chrome'

    # Navigation
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a .3 'cd ../../..'
    abbr -a .4 'cd ../../../..'
    abbr -a .5 'cd ../../../../..'

    # Window info
    abbr -a kwininfo "qdbus org.kde.KWin /KWin queryWindowInfo"

    # File listing (lsd)
    abbr -a ls 'lsd -A'
    abbr -a la 'lsd -A'
    abbr -a ll 'lsd -Al'
    abbr -a lt 'lsd -A --tree'

    # System utilities
    abbr -a grep 'grep --color=auto'
    abbr -a egrep 'egrep --color=auto'
    abbr -a fgrep 'fgrep --color=auto'
    abbr -a cp "cp -i"
    abbr -a mv 'mv -i'
    abbr -a rm 'rm -i'
    abbr -a mkdir 'mkdir -p'

    # Git
    abbr -a addup 'git add -u'
    abbr -a addall 'git add .'
    abbr -a branch 'git branch'
    abbr -a checkout 'git checkout'
    abbr -a clone 'git clone'
    abbr -a commit 'git commit -m'
    abbr -a fetch 'git fetch'
    abbr -a pull 'git pull origin'
    abbr -a push 'git push origin'
    abbr -a tag 'git tag'
    abbr -a newtag 'git tag -a'

    # Logs
    abbr -a jctl "journalctl -p 3 -xb"

end

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
