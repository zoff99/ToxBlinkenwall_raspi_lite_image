#! /bin/bash

mountphrase="PASS"$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2)"PASS"
# echo $mountphrase
echo "passphrase_passwd=${mountphrase}" > /tmp/key.txt

# add tokens to user session keyring
printf "%s" "${mountphrase}" | ecryptfs-add-passphrase - > /tmp/tmp.txt

# get the signature from the output of the above command
sig=`tail -1 /tmp/tmp.txt | awk '{print $6}' | sed 's/\[//g' | sed 's/\]//g'`
# echo $sig

rm -f /tmp/tmp.txt

mkdir -p /home/pi/ToxBlinkenwall/toxblinkenwall/db/

# now mount
sudo mount -t ecryptfs /home/pi/ToxBlinkenwall/toxblinkenwall/db /home/pi/ToxBlinkenwall/toxblinkenwall/db -o key=passphrase:passphrase_passwd_file=/tmp/key.txt,ecryptfs_cipher=aes,ecryptfs_key_bytes=16,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,no_sig_cache,ecryptfs_fnek_sig=${sig},ecryptfs_sig=${sig},ecryptfs_unlink_sigs > /dev/null 2>&1
res=$?

if [ $res == 0 ]; then
    chown pi:pi /home/pi/ToxBlinkenwall/toxblinkenwall/db/
else
    echo "ERROR mounting encrypted storage dir"
fi

rm -rf /tmp/key.txt


