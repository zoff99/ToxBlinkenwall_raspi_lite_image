#!/bin/bash -e

ls -al /
df -ha
ls -al /pi-gen/work/_GIT_BRANCH_

install -m 755 /pi-gen/work/_GIT_BRANCH_ "${ROOTFS_DIR}/_GIT_BRANCH_"

on_chroot << EOF

# disable swap
service dphys-swapfile stop
sudo systemctl disable dphys-swapfile
apt-get --yes --force-yes purge dphys-swapfile

echo "-------------------------------"
echo "-------------------------------"
echo "GIT: current branch is:"
cat /_GIT_BRANCH_
echo "-------------------------------"
echo "-------------------------------"
echo "-------------------------------"

# backup alsa config
cp -av /usr/share/alsa/alsa.conf /usr/share/alsa/alsa.conf_ORIG

# enable imagemagick to read things from files
cp -av /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.BACKUP
## TODO:fixme ## sed -i -e 's#^.*<policy domain="path".*$#<!-- removed by ToxBlinkenwall -->#g' /etc/ImageMagick-6/policy.xml

# add tbw to rc.local
echo "add tbw to rc.local"
sed -i -e 's#exit 0##' /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'echo none > /sys/class/leds/led0/trigger\n' >> /etc/rc.local
printf 'su - pi bash -c "/home/pi/ToxBlinkenwall/toxblinkenwall/initscript.sh start" > /dev/null 2>/dev/null &\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'exit 0\n' >> /etc/rc.local

EOF

echo
echo
# just check the files contents
cat "${ROOTFS_DIR}/etc/rc.local"
ls -al "${ROOTFS_DIR}/home/pi/"
echo
echo

echo "build ToxBlinkenwall ..."
install -m 755 files/build_tbw.sh "${ROOTFS_DIR}/home/pi/"
install -m 755 files/update_tbw.sh "${ROOTFS_DIR}/home/pi/"

on_chroot << EOF
id -a
su - pi bash -c "/home/pi/build_tbw.sh"
EOF

# save built libs and includes for caching (outside of docker)
ls -al /pi-gen/
cp -av "${ROOTFS_DIR}/home/pi/inst/" /pi-gen/work/

# set root and pi password to random values for production branch
on_chroot << EOF

rand_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
echo "$rand_pass"
echo "pi:$rand_pass" | chpasswd

rand_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9\_\%' | fold -w 30 | head -n 1)
echo "root:$rand_pass" | chpasswd
echo "$rand_pass"

EOF
