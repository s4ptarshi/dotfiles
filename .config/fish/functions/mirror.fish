# Defined in - @ line 1
function mirror --wraps='reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist' --wraps='sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist' --description 'alias mirror=sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist'
  sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist $argv;
end
