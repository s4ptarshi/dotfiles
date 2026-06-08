function ssh-unlock --wraps='eval (ssh-agent -c) && ssh-add ~/.ssh/id_ed25519' --description 'alias ssh-unlock=eval (ssh-agent -c) && ssh-add ~/.ssh/id_ed25519'
    eval (ssh-agent -c) && ssh-add ~/.ssh/id_ed25519 $argv
    ssh -T git@github.com
end
