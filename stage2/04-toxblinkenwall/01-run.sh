#!/bin/bash -e

on_chroot << EOF

# disable swap
service dphys-swapfile stop
sudo systemctl disable dphys-swapfile
apt-get --yes --force-yes purge dphys-swapfile

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

on_chroot << EOF
id -a
su - pi bash -c "/home/pi/build_tbw.sh"
EOF

