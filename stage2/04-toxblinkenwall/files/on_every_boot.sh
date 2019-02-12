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
ifmetric wlan0 200

# set timezone automatically
tzupdate
dpkg-reconfigure -f noninteractive tzdata

# start the OS update script in the background
bash /loop_update_os.sh >/dev/null 2>/dev/null &

# mount tox db encrypted storage dir
bash /mount_tox_db.sh

