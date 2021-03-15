# Defined in - @ line 1
function indmirror --wraps=sudo\ reflector\ --verbose\ --country\ \'India\'\ -l\ 5\ --sort\ rate\ --save\ /etc/pacman.d/mirrorlist --wraps='sudo reflector --verbose --country India -l 5 --sort rate --save /etc/pacman.d/mirrorlist' --description 'alias indmirror=sudo reflector --verbose --country India -l 5 --sort rate --save /etc/pacman.d/mirrorlist'
  sudo reflector --verbose --country India -l 5 --sort rate --save /etc/pacman.d/mirrorlist $argv;
end
