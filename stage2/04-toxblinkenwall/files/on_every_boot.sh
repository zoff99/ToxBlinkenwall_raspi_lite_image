#!/bin/bash

##############################################
# this script is run on every boot (as root) #
##############################################

touch /tmp/on_every_boot_lastrun.txt

# remove some cron files
rm -f /etc/cron.daily/apt-compat
rm -f /etc/cron.daily/aptitude
rm -f /etc/cron.daily/man-db
rm -f /etc/cron.weekly/man-db

# mount tmpfs dir
rm -Rf /home/pi/ToxBlinkenwall/toxblinkenwall/share/
mkdir -p /home/pi/ToxBlinkenwall/toxblinkenwall/share/
mount -t tmpfs -o size=1M tmpfs /home/pi/ToxBlinkenwall/toxblinkenwall/share/
chmod a+rwx /home/pi/ToxBlinkenwall/toxblinkenwall/share/

# call on_boot script
su - pi bash -c '/home/pi/ToxBlinkenwall/toxblinkenwall/scripts/on_boot.sh' > /dev/null 2>&1 &

# higher priority to eth0 (over wlan0)
# this may cause issues ??
## ifmetric wlan0 404

# set timezone automatically
tzupdate
dpkg-reconfigure -f noninteractive tzdata

# start the OS update script in the background
bash /loop_update_os.sh >/dev/null 2>/dev/null &

# start the dev-build script in the background
su - pi bash -c '/home/pi/comp.loop.sh' > /dev/null 2>&1 &

# mount tox db encrypted storage dir
bash /mount_tox_db.sh


if [ 1 == 2 ]; then

systemctl stop tor
systemctl disable tor

#### if using bluetooth ------------
#systemctl enable dbus.socket
#systemctl enable dbus
#systemctl enable bluealsa.service
#systemctl enable hciuart.service
#systemctl enable bluetooth.service
#systemctl enable bluetooth
#
#systemctl start dbus.socket
#systemctl start dbus
#systemctl start bluetooth
#systemctl start bluetooth.service
#systemctl start bluealsa.service

systemctl stop tor
systemctl disable tor

systemctl start dbus
systemctl start dbus.socket
sleep 2
systemctl start hciuart.service
sleep 2
systemctl start bluealsa.service

# add to /boot/config.txt
# dtoverlay=pi3-disable-bt


sleep 30
echo -e "power up\nconnect AB:EF:AB:EF:EF:AB\n quit"|bluetoothctl
#### if using bluetooth ------------

else

# disable some unused stuff
systemctl stop tor
systemctl disable tor
systemctl stop dbus
systemctl stop dbus.socket
systemctl disable dbus.socket
systemctl disable dbus

fi

echo '#! /bin/bash' > /home/pi/ToxBlinkenwall/toxblinkenwall/ext_keys_scripts/ext_keys.py
echo '#! /bin/bash' > /home/pi/ToxBlinkenwall/toxblinkenwall/ext_keys_scripts/ext_keys_evdev.py
echo '#! /bin/bash' > /home/pi/ToxBlinkenwall/toxblinkenwall/scripts/create_gfx.sh
