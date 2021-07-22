# Antimony2k's zshrc
# history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

#vi mode
bindkey -v
export KEYTIMEOUT=1
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/antimony2k/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#random greeter at start of terminal
colorscript random

#plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#aliases
alias config='/usr/bin/git --git-dir=/home/antimony2k/dotfiles/ --work-tree=/home/antimony2k'

#completion
autoload -U compinit; compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)
#bindings

    #autosuggestions
    autoload -U up-line-or-beginning-search
    autoload -U down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey "^[[A" up-line-or-beginning-search
    bindkey -M emacs '^P' up-line-or-beginning-search
    bindkey -M vicmd 'j' up-line-or-beginning-search
    bindkey "^[[B" down-line-or-beginning-search
    bindkey -M emacs '^N' down-line-or-beginning-search
    bindkey -M vicmd 'k' down-line-or-beginning-search
    
    # Use vim keys in tab complete menu:
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -v '^?' backward-delete-char
        
    #fzf
    source /usr/share/fzf/completion.zsh
    source /usr/share/fzf/key-bindings.zsh

    #lsd
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -A'
    alias lla='ls -lA'
    alias lt='ls --tree'

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

#use starship prompt
eval "$(starship init zsh)"

