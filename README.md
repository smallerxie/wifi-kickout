# Introduction to kickout-wifi
The shell script for OpenWrt kicks out the wifi client(s) with a weak signal by fixing a threshold.
It can be periodically triggered by crontab or by sleep command, thus improves roaming performance.
The shell script works on original OpenWrt with no additional packages, the script is compatible with the original OpenWrt's ash shell (and bash shell).
This repository was inspired by [nikito7/kickout-wifi](https://github.com/nikito7/kickout-wifi), thanks for his/her original work :)
I modified some of the kick-out rules to meet my own requirements and thus opened a new repository to accept issues.

# Parameters
Before using it, you are suggested to fix the 4 parameters according to your own requirements.
**thr**=-75 is the threshold (dBm), always negative!
**mode** can be set to either "*white*" or "*black*" (always minuscule):
 - in "**black**list" mode, **only** the clients in the blacklist can be kicked out;
 - in "**white**list" mode, the script kicks out **all** the clients **except** those in the whitelist.
There are thus a **blacklist** and a **whitelist**, attention that the type is string other than array, a comma is used to seprate the different mac addresses.
By default, the "**white**list" mode is selected, and with an empty whitelist, any associated client might be kicked out by the router if its signal is too weak (< **thr**).

# Installation
Simply copy the script file kickout-wifi.sh to your router (e.g., using scp), in my case the location is /usr/kickout.sh.

I recommend triggering the script periodically by crontab, whose highest frequency is 1 run per minute. To do this, add the following line to your /etc/crontabs/root file:

*/1 * * * * /bin/sh /usr/kickout.sh

Otherwise, you may prefer a higher frequency to run the script by using the "sleep" command in the kickout-wifi.sh and then call itself again. Another way is to use a loop *while *true* - do - done* with the "sleep" command in the end of the loop.

# Log
The log file is located at /tmp/wifi-kickout.log.

