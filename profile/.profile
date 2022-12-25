# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/go:$HOME/.local/share/bin/:$HOME/.local/bin/"
export XKB_DEFAULT_OPTIONS=caps:escape_shifted_capslock

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR="/home/s4ptarshi/.local/bin/lvim"

if [[ "$(tty)" == "/dev/tty1" ]]
	then
		wrappedhl
fi
