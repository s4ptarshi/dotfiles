fish_add_path "$HOME/.ghcup/bin"
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.local/bin/nvim-linux-x86_64/bin
# Check for and source vars.fish from the fish config directory
if test -f $__fish_config_dir/vars.fish
    source $__fish_config_dir/vars.fish
end
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

    # alias file-manager='app2unit-open -S both . &'
    function file-manager
        nohup app2unit-open -S both . $argv >/dev/null 2>&1 &
        disown
    end
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
    if command -sq lsd
        abbr -a ls 'lsd -A'
        abbr -a la 'lsd -A'
        abbr -a ll 'lsd -Al'
        abbr -a lt 'lsd -A --tree'
    else
        abbr -a ls 'ls -A'
        abbr -a la 'ls -A'
        abbr -a ll 'ls -Al'
    end

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

    if string match -q -r 'chadbook|vivobook' $hostname
        set --global hydro_symbol_prompt "❱"
        direnv hook fish | source
    else if string match -q -r 'login1|login2|login3' $hostname
        set --global hydro_symbol_prompt "dfki ❱"
    else
        ssh-unlock
        set --global hydro_symbol_prompt "$hostname ❱"
    end
end

set -x CONDA_PATH /data/miniconda3/bin/conda $HOME/miniconda3/bin/conda /netscratch/bhattach/miniconda3/bin/conda

# 1. VSCodium/VSCode behavior: Silent, instant initialization
if set -q TERM_PROGRAM; and string match -q -r '(vscode|VSCodium)' "$TERM_PROGRAM"
    for c_path in $CONDA_PATH
        if test -f $c_path
            eval $c_path "shell.fish" hook | source
            break
        end
    end
    # 2. Normal terminal behavior: Lazy loading for fast startup
else
    function conda
        functions --erase conda
        for c_path in $CONDA_PATH
            if test -f $c_path
                echo "Lazy loading conda..."
                eval $c_path "shell.fish" hook | source
                conda $argv
                return
            end
        end
        echo "No conda installation found."
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/s4ptarshi/.local/bin" $PATH
