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

# set timezone automatically
tzupdate
dpkg-reconfigure -f noninteractive tzdata

