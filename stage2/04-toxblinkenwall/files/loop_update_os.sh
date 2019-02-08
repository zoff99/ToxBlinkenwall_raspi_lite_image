#!/bin/bash

############################################################
# this script runs in the background to install OS updates #
############################################################

# limit bandwidth to X kbytes/s
bw_kbytes_s=150
cpu_nice=19
# io_level=7
io_class=3

# initial sleep for 10 minutes
sleep 10m

while [ 1 == 1 ]; do

    # sudo nice -n $cpu_nice \
    #    ionice -c $io_class \
    #    rm -rf /var/lib/dpkg/updates/*

    # sudo nice -n $cpu_nice \
    #    ionice -c $io_class \
    #    rm -rf /var/lib/apt/lists/*

    # sudo nice -n $cpu_nice \
    #    ionice -c $io_class \
    #    rm /var/cache/apt/*.bin

    sudo nice -n $cpu_nice \
        ionice -c $io_class \
        rm /var/lib/dpkg/lock

    sudo nice -n $cpu_nice \
        ionice -c $io_class \
        rm /var/lib/apt/lists/lock

    sudo nice -n $cpu_nice \
        ionice -c $io_class \
        rm /var/cache/apt/archives/lock

    # sudo nice -n $cpu_nice \
    #    ionice -c $io_class \
    #    sudo apt-get clean

    # sudo nice -n $cpu_nice \
    #    ionice -c $io_class \
    #    sudo apt-get autoclean

    sudo nice -n $cpu_nice \
        ionice -c $io_class \
        apt-get \
        -o Acquire::http::Dl-Limit=$bw_kbytes_s \
        -o Acquire::https::Dl-Limit=$bw_kbytes_s \
        update

    sudo nice -n $cpu_nice \
        ionice -c $io_class \
        apt-get \
        -o Acquire::http::Dl-Limit=$bw_kbytes_s \
        -o Acquire::https::Dl-Limit=$bw_kbytes_s \
        upgrade -y --force-yes

    # sleep somewhere between 19 and 29 hours between OS automated updates
    how_long=$[ ( $RANDOM % 10 )  + 1 ]
    how_long=$[ $how_long + 18 ]
    sleep "$how_long"h

    # sleep some random seconds to make it less predictable
    random_seconds=$[ ( $RANDOM % 320 )  + 1 ]
    sleep "$random_seconds"s

done
