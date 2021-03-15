# Defined in - @ line 1
function gaming --wraps='asusctl profile -p boost && asusctl graphics -m nvidia' --description 'alias gaming=asusctl profile -p boost && asusctl graphics -m nvidia'
  asusctl profile -p boost && asusctl graphics -m nvidia $argv;
end
