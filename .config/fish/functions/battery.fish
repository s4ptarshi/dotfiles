# Defined in - @ line 1
function battery --wraps='asusctl profile -p silent && asusctl graphics -m hybrid' --description 'alias battery=asusctl profile -p silent && asusctl graphics -m hybrid'
  asusctl profile -p silent && asusctl graphics -m hybrid $argv;
end
