#! /bin/bash

if [ -e /_first_start_ ]; then
    # set random passwords for "pi" and "root" user
    rand_pass=$(dd if=/dev/urandom bs=100 count=10240 | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "pi:$rand_pass" | chpasswd
    echo "$rand_pass" > /etc/pipa.txt
    chmod og-rwx /etc/pipa.txt

    rand_pass=$(dd if=/dev/urandom bs=100 count=10240 | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "root:$rand_pass" | chpasswd

    touch /tmp/set_random_passwds_lastrun.txt

    # set better hostname with some random bits at the end
    rand_chars=$(dd if=/dev/urandom bs=100 count=10240 | tr -dc 'A-F0-9' | fold -w 5 | head -n 1)
    echo $rand_chars
    echo 'rpi-'"$rand_chars" > /etc/hostname
    echo '127.0.1.1   rpi-'"$rand_chars" >> /etc/hosts
    cat /etc/hostname
    cat /etc/hosts | tail -2

    rm -f /_first_start_
fi
