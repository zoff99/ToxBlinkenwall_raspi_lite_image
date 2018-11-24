#!/bin/bash -e

install -m 755 /pi-gen/stage3/_GIT_BRANCH_ "${ROOTFS_DIR}/_GIT_BRANCH_"

on_chroot << EOF

# disable swap
service dphys-swapfile stop
sudo systemctl disable dphys-swapfile
apt-get --yes --force-yes purge dphys-swapfile

echo "-------------------------------"
echo "-------------------------------"
echo "GIT: current branch is:"
_git_branch_=$(cat /_GIT_BRANCH_)
echo $_git_branch_
echo "-------------------------------"
echo "-------------------------------"
echo "-------------------------------"

# backup alsa config
cp -av /usr/share/alsa/alsa.conf /usr/share/alsa/alsa.conf_ORIG

# enable imagemagick to read things from files
cp -av /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.BACKUP

# add tbw to rc.local
echo "add tbw to rc.local"
sed -i -e 's#exit 0##' /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'echo none > /sys/class/leds/led0/trigger\n' >> /etc/rc.local
printf 'su - pi bash -c "/home/pi/ToxBlinkenwall/toxblinkenwall/initscript.sh start" > /dev/null 2>/dev/null &\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'exit 0\n' >> /etc/rc.local

# check contents of file:
echo "----------------------"
cat /lib/systemd/system/systemd-udevd.service
echo "----------------------"

EOF

/bin/bash files/patch_imagemagick_config.sh

echo
echo
# just check the files contents
cat "${ROOTFS_DIR}/etc/rc.local"
echo
echo
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

_git_branch_=$(cat /pi-gen/stage3/_GIT_BRANCH_)
if [ "$_git_branch_""x" == "toxphonev20x" ]; then
  alsa_template="/home/pi/ToxBlinkenwall/__first_install_on_pi/alsa_template.txt"
  cp "$alsa_template" "/home/pi/ToxBlinkenwall/toxblinkenwall/alsa_template.txt"
fi

# save built libs and includes for caching (outside of docker)
cp -av "${ROOTFS_DIR}/home/pi/inst/" /pi-gen/work/

_git_branch_=$(cat /pi-gen/stage3/_GIT_BRANCH_)
if [ "$_git_branch_""x" == "toxphonev20x" ]; then
  install -d                                 "${ROOTFS_DIR}/etc/udev/rules.d"
  install -m 644 files/plug-usb-device.rules "${ROOTFS_DIR}/etc/udev/rules.d/80-plug-usb-device.rules"
fi


