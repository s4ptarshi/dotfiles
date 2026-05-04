function update --wraps='rate-mirrors --disable-comments-in-file --protocol=https arch --max-delay 7200 | sudo tee /etc/pacman.d/mirrorlist && yay -q -yy --noconfirm && flatpak update -y' --description 'alias update rate-mirrors --disable-comments-in-file --protocol=https arch --max-delay 7200 | sudo tee /etc/pacman.d/mirrorlist && yay -q -yy --noconfirm && flatpak update -y'
    rate-mirrors --disable-comments-in-file --protocol=https arch --max-delay 7200 | sudo tee /etc/pacman.d/mirrorlist && yay -q -yy --noconfirm && flatpak update -y $argv
end
