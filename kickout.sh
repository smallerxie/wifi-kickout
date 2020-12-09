#!/bin/sh

### kickout.sh #####

# threshold (dBm), always negative 
thr=-75

# mode (string) = "white" or "black", always minuscule !
# black: only the clients in the blacklist can be kicked out.
# white: kick out all the clients except those in the whitelist.
mode="white"

# In "black" mode, only the clients in the blacklist can be kicked out.
blacklist="00:00:00:00:00:00 00:00:00:00:00:00"

# In "white" mode, the clients in the whitelist will not be kicked out.
whitelist="00:00:00:00:00:00 00:00:00:00:00:00"

# Specified logfile
logfile="/tmp/kickout-wifi.log"
datetime=`date +%Y-%m-%d_%H:%M:%S`
if [[ ! -f "$logfile" ]]; then
	echo "creating kickout-wifi logfile: $logfile"
	echo "$datetime: kickout-wifi log file created." > $logfile
fi

# function deauth
function deauth () 
{
	mac=$1
	wlan=$2
	echo "kicking $1 with $3 dBm (thr=$thr) at $2" | logger
	echo "$datetime: kicking $1 with $3 dBm (thr=$thr) at $2" >> $logfile
	ubus call hostapd.$wlan del_client \
	"{'addr':'$mac', 'reason':5, 'deauth':true, 'ban_time':3000}"
# "ban_time" prohibits the client to reassociate for the given amount of milliseconds.


}

# wlanlist for multiple wlans (e.g., 5GHz/2.4GHz)
wlanlist=$(ifconfig | grep wlan | grep -v sta | awk '{ print $1 }')

#loop for each wlan
for wlan in $wlanlist
do
	maclist=""; maclist=$(iw $wlan station dump | grep Station | awk '{ print $2 }')
	#loop for each associated client (station)
	for mac in $maclist
	do
		echo "$blacklist" | grep -q -e $mac
		inBlack=$?	#0 for in Blacklist!
		echo "$whitelist" | grep -q -e $mac
		inWhite=$?	#0 for in Whitelist!

		if [ $mode = "black" -a $inBlack -eq 0 ] || [ $mode = "white" -a $inWhite -ne 0 ]
			then
				rssi=""; rssi=$(iw $wlan station get $mac | \
				grep "signal avg" | awk '{ print $3 }')
				if [ $rssi -lt $thr ]
					then
						##skip wlan if necessary
						#if [ $wlan = wlan0 ];then
						#	echo "ignored $1 with $3 dBm (thr=$thr) at $2" | logger
						#	echo "$datetime: ignored $1 with $3 dBm (thr=$thr) at $2" >> $logfile
						#	continue
						#fi
						##
						deauth $mac $wlan $rssi
				fi
		fi
####
	done
done
####

# sleep 10s and call itself.
#sleep 10; /bin/sh $0 &

###
