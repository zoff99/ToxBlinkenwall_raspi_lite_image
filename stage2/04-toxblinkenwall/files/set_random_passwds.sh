#! /bin/bash

if [ -e /_first_start_ ]; then
    rand_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "pi:$rand_pass" | chpasswd

    rand_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
    echo "root:$rand_pass" | chpasswd

    rm -f /_first_start_
fi