#!/bin/bash -e

echo "==============================="
ls -al ${ROOTFS_DIR}
echo "ROOTFS_DIR=${ROOTFS_DIR}"
ls -al /pi-gen/
ls -al /pi-gen/stage3/_GIT_BRANCH_
echo "==============================="

install -m 755 /pi-gen/stage3/_GIT_BRANCH_ "${ROOTFS_DIR}/_GIT_BRANCH_"
install -m 755 files/on_every_boot.sh "${ROOTFS_DIR}/on_every_boot.sh"

on_chroot << EOF

# disable swap
service dphys-swapfile stop
systemctl disable dphys-swapfile
apt-get --yes --force-yes purge dphys-swapfile

echo "-------------------------------"
echo "-------------------------------"
echo "GIT: current branch is:"
cat /_GIT_BRANCH_
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
printf 'bash /set_random_passwds.sh > /dev/null 2>/dev/null &\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'bash /on_every_boot.sh > /dev/null 2>/dev/null &\n' >> /etc/rc.local
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
  chown pi:pi /home/pi/build_tbw.sh
  chown pi:pi /home/pi/update_tbw.sh
EOF

on_chroot << EOF
  id -a
  su - pi bash -c "/home/pi/build_tbw.sh"
EOF

_git_branch_=$(cat /pi-gen/stage3/_GIT_BRANCH_)
echo $_git_branch_
if [ "$_git_branch_""x" == "toxphonev20x" ]; then

on_chroot << EOF
  alsa_template="/home/pi/ToxBlinkenwall/__first_install_on_pi/alsa_template.txt"
  cp "$alsa_template" "/home/pi/ToxBlinkenwall/toxblinkenwall/alsa_template.txt"
EOF

fi

# enable sshd on master branch
if [ "$_git_branch_""x" == "masterx" ]; then

on_chroot << EOF
  systemctl enable ssh
EOF

fi

# set random passwords for "pi" and "root" user
if [ "$_git_branch_""x" == "releasex" ]; then
    install -m 755 files/set_random_passwds.sh "${ROOTFS_DIR}/set_random_passwds.sh"
    touch "${ROOTFS_DIR}/_first_start_"
elif [ "$_git_branch_""x" == "toxphonev20x" ]; then
    install -m 755 files/set_random_passwds.sh "${ROOTFS_DIR}/set_random_passwds.sh"
    touch "${ROOTFS_DIR}/_first_start_"
fi

# save built libs and includes for caching (outside of docker)
cp -av "${ROOTFS_DIR}/home/pi/inst/" /pi-gen/work/

if [ "$_git_branch_""x" == "toxphonev20x" ]; then
  install -d                                 "${ROOTFS_DIR}/etc/udev/rules.d"
  install -m 644 files/plug-usb-device.rules_toxphonev20 "${ROOTFS_DIR}/etc/udev/rules.d/80-plug-usb-device.rules"
else
  install -d                                 "${ROOTFS_DIR}/etc/udev/rules.d"
  install -m 644 files/plug-usb-device.rules_default "${ROOTFS_DIR}/etc/udev/rules.d/80-plug-usb-device.rules"
fi

# fix udev service config to be able to automount USB devices
install -m 755 files/config_systemd_udev_srv.sh "${ROOTFS_DIR}/config_systemd_udev_srv.sh"
on_chroot << EOF
  bash /config_systemd_udev_srv.sh
EOF

on_chroot << EOF
  # https://github.com/cdown/tzupdate
  # util to autodetect timezone from IP address
  pip install -U tzupdate
EOF

on_chroot << EOF
  rm -f /etc/cron.daily/apt-compat
  rm -f /etc/cron.daily/aptitude
  rm -f /etc/cron.daily/man-db
  rm -f /etc/cron.weekly/man-db
EOF




