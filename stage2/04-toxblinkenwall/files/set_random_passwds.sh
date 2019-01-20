#! /bin/bash

if [ -e /_first_start_ ]; then
    rand_pass=$(dd if=/dev/urandom bs=100 count=10240 | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "pi:$rand_pass" | chpasswd
    echo "$rand_pass" > /etc/pipa.txt
    chmod og-rwx /etc/pipa.txt

    rand_pass=$(dd if=/dev/urandom bs=100 count=10240 | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "root:$rand_pass" | chpasswd

    touch /tmp/set_random_passwds_lastrun.txt
    rm -f /_first_start_
fi
