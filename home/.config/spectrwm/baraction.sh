#!/bin/sh

trap 'update' 5

net() {
	essid=$(nmcli | grep -v "disconnected" | grep "connected" | awk '{print $4}')
wstatus=$(nmcli | grep -v "disconnected" | grep connected | awk '{print $2}')

if [ "$wstatus" = "connected" ]
then
  icon=" "
else
  icon="睊"
  essid="disconnected"
fi

#printf "%s\n" "$icon $essid"
printf "%s\n" "$icon"

}


bat() {
	battery="/sys/class/power_supply/BAT0/"

capacity=$(cat "$battery"/capacity)
bstatus=$(cat "$battery"/status)

if [ "$bstatus" = "Charging" ]; then
    if [ $capacity -eq 100 ]; then
        icon=""
    elif [ $capacity -gt 85 ]; then
        icon=""
    elif [ $capacity -gt 70 ]; then
        icon=""
    elif [ $capacity -lt 30 ]; then
        icon=""
    elif [ $capacity -lt 10 ]; then
        icon=""
    else                                                                                                                                                                                                                                       
        icon=""                                                                                                                                                                                                                               
    fi                                                                                                                                                                                                                                         
elif [ "$bstatus" = "Unknown" ]; then                                                                                                                                                                                                          
    icon=""                                                                                                                                                                                                                                   
elif [ "$bstatus" = "Full" ]; then                                                                                                                                                                                                             
    icon=""                                                                                                                                                                                                                                   
elif [ "$bstatus" = "Discharging" ]; then                                                                                                                                                                                                      
    if [ $capacity -eq 100 ]; then                                                                                                                                                                                                             
        icon=""                                                                                                                                                                                                                               
    elif [ $capacity -gt 85 ]; then                                                                                                                                                                                                            
        icon=""                                                                                                                                                                                                                               
    elif [ $capacity -gt 70 ]; then                                                                                                                                                                                                            
        icon=""                                                                                                                                                                                                                               
    elif [ $capacity -lt 40 ]; then                                                                                                                                                                                                            
        icon=""                                                                                                                                                                                                                               
    elif [ $capacity -lt 10 ]; then                                                                                                                                                                                                            
        icon=""                                                                                                                                                                                                                               
    else                                                                                                                                                                                                                                       
        icon=""                                                                                                                                                                                                                               
    fi                                                                                                                                                                                                                                         
else                                                                                                                                                                                                                                           
    icon=""                                                                                                                                                                                                                                   
fi                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                               
printf "%s%% \n" "$icon $capacity"
}

bri() {
	bri=$(light -G | sed 's/\..*//g')

if [ "$bri" -gt "90" ]; then
	icon=" "
elif [ "$bri" -gt "70" ]; then
	icon=" "
elif [ "$bri" -eq "0" ]; then
    icon=" "
elif [ "$bri" -lt "30" ]; then
	icon=" "

else
	icon=""
fi

printf "%s%% \n" "$icon $bri"
}



## RAM
mem() {
  mem=`free | awk '/Mem/ {printf "%dM/%dM\n", $3 / 1024.0, $2 / 1024.0 }'`
  echo -e "$mem"
}

## CPU
cpu() {
  read cpu a b c previdle rest < /proc/stat
  prevtotal=$((a+b+c+previdle))                                                                                                                                                                                                                
  sleep 0.5                                                                                                                                                                                                                                    
  read cpu a b c idle rest < /proc/stat                                                                                                                                                                                                        
  total=$((a+b+c+idle))                                                                                                                                                                                                                        
  cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))                                                                                                                                                                    
  echo -e "CPU: $cpu%"                                                                                                                                                                                                                         
}

## VOLUME
volume() {
volstat=$(pamixer --get-volume)

vol=$(echo "$volstat")


if [ "$vol" -gt "70" ]; then
	icon=" "
elif [ "$vol" -eq "0" ]; then
    icon="婢"
elif [ "$vol" -lt "30" ]; then
	icon=""

else
	icon="墳"
fi

printf "%s%% \n" "$icon $volstat"
}

update() {
#    echo "$(wthr)| $(kbd)| $(bri)| $(volume)| $(bat)| $(ctime)| $(net)" &
echo "+@fg=1;$(cpu) +@fg=0;|+@fg=2; $(mem) +@fg=0;|+@fg=3; $(bri)+@fg=0;|+@fg=4; $(volume)+@fg=0;|+@fg=5; $(bat)+@fg=0;|+@fg=6; $(net)" &
    wait
}

while :; do
    update
    sleep 10 &
    wait
done
