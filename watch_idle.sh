#!/bin/bash
username=""
while [ -z $username ]; do
    username=$(who|grep guest| tr -s " "| cut -d" " -f1)
    sleep 10
done
display=$(who|grep guest| tr -s " "| cut -d" " -f5| tr -d "()")
export DISPLAY=$display

idle_limit=$(expr 5 \* 60 \* 1000)

while true; do
    idletime=$(sudo -u $username xprintidle)
    echo $idletime
    if [ "$idletime" -gt "$idle_limit" ]; then
	echo "idle time reached, restarting lightdm";
	/etc/init.d/lightdm restart
	sleep 10
	username=""
	while [ -z $username ]; do
	    username=$(who|grep guest| tr -s " "| cut -d" " -f1)
	    sleep 10
	done
	display=$(who|grep guest| tr -s " "| cut -d" " -f5| tr -d "()")
	echo "got user $username at $display"
	export DISPLAY=$display
	echo "waiting for ui init"
	lastidle=$(sudo -u $username xprintidle)
	sleep 10
	while [ "$lastidle" -lt "$(sudo -u $username xprintidle)" ]; do
	    echo $lastidle
	    lastidle=$(sudo -u $username xprintidle)
	    sleep 10
	done
	echo "ui init finished, waiting for activity"
	lastidle=$(sudo -u $username xprintidle)
	sleep 10
	#$(sudo -u $username firefox)
	while [ "$lastidle" -lt "$(sudo -u $username xprintidle)" ]; do
	    echo $lastidle
	    lastidle=$(sudo -u $username xprintidle)
	    sleep 10
	done
	echo "activity!, back to main loop"
    fi
    sleep 10
done
