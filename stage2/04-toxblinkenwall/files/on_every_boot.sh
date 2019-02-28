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

