#!/bin/bash

echo "========"
pwd
echo "========"
ls -al .
echo "========"
ls -al ../
echo "========"
ls -al ../../
echo "========"
ls -al ../../stage3/
echo "========"

echo "==============================="
export _git_branch_=$(cat ../../stage3/_GIT_BRANCH_)
echo "GIT: current branch is:"
echo $_git_branch_
echo "==============================="

install -m 755 ../../stage3/_GIT_BRANCH_ "${ROOTFS_DIR}/_GIT_BRANCH_"
install -m 755 ../../stage3//_GIT_PROJECT_USERNAME_ "${ROOTFS_DIR}/_GIT_PROJECT_USERNAME_"
install -m 755 ../../stage3//_GIT_PROJECT_REPONAME_ "${ROOTFS_DIR}/_GIT_PROJECT_REPONAME_"
install -m 755 files/on_every_boot.sh "${ROOTFS_DIR}/on_every_boot.sh"
install -m 755 files/loop_update_os.sh "${ROOTFS_DIR}/loop_update_os.sh"
install -m 755 files/mount_tox_db.sh "${ROOTFS_DIR}/mount_tox_db.sh"

install -m 755 files/_compile_loop.sh "${ROOTFS_DIR}/home/pi/_compile_loop.sh"
install -m 755 files/comp.loop.sh "${ROOTFS_DIR}/home/pi/comp.loop.sh"
install -m 755 files/fill_fb.sh "${ROOTFS_DIR}/home/pi/fill_fb.sh"

on_chroot << EOF
chown pi:pi /home/pi/_compile_loop.sh
chown pi:pi /home/pi/comp.loop.sh
chown pi:pi /home/pi/fill_fb.sh
EOF


on_chroot << EOF

# disable swap
service dphys-swapfile stop
systemctl disable dphys-swapfile
apt-get --yes --force-yes purge dphys-swapfile

# backup alsa config
cp -av /usr/share/alsa/alsa.conf /usr/share/alsa/alsa.conf_ORIG

# enable imagemagick to read things from files
cp -av /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.BACKUP

# configure rc.local
echo "configure rc.local"
sed -i -e 's#exit 0##' /etc/rc.local
printf 'set +e\n' >> /etc/rc.local
printf 'systemctl restart systemd-udevd\n' >> /etc/rc.local
printf 'systemctl daemon-reload\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'sleep 3\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'tvservice -s\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'cat /proc/asound/cards\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'lsusb\n' >> /etc/rc.local
printf 'echo -n eth0:\n' >> /etc/rc.local
printf 'ip -4 addr show eth0|grep inet|awk "{print \\\$2}"\n' >> /etc/rc.local
printf 'echo -n wlan0:\n' >> /etc/rc.local
printf 'ip -4 addr show wlan0|grep inet|awk "{print \\\$2}"\n' >> /etc/rc.local
printf 'echo -n IP:\n' >> /etc/rc.local
printf 'hostname -I\n' >> /etc/rc.local
printf 'echo -n hostname:\n' >> /etc/rc.local
printf 'hostname\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'echo xxxxxxxxxx\n' >> /etc/rc.local
printf 'sleep 3\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'bash /on_every_boot.sh > /dev/null 2>/dev/null\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf '(sleep 5;/home/pi/ToxBlinkenwall/toxblinkenwall/detect_usb_audio.sh) &\n' >> /etc/rc.local
printf '\n' >> /etc/rc.local
printf 'bash /set_random_passwds.sh > /dev/null 2>/dev/null &\n' >> /etc/rc.local
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
  mkdir -p "/home/pi/inst/"
  chmod a+rwx "/home/pi/inst/"
  touch "/home/pi/inst/__xx__"
  chmod a+rwx "/home/pi/inst/__xx__"
  chown pi:pi -R "/home/pi/inst/"
  echo "build tbw *without* cache ..."
  su - pi bash -c "/home/pi/build_tbw.sh"
EOF

echo "enable SSHD"
on_chroot << EOF
  systemctl enable ssh
EOF

# set random passwords for "pi" and "root" user
echo "set random passwords on first boot [1]"
install -m 755 files/set_random_passwds.sh "${ROOTFS_DIR}/set_random_passwds.sh"
touch "${ROOTFS_DIR}/_first_start_"

echo "using UDEV rules:plug-usb-device.rules_default"
install -d                                 "${ROOTFS_DIR}/etc/udev/rules.d"
install -m 644 files/plug-usb-device.rules_default "${ROOTFS_DIR}/etc/udev/rules.d/80-plug-usb-device.rules"

# HINT: does not work here, needs to be run on the live system (was now moved to /etc/rc.local)
#echo "reload udevd rules"
#on_chroot << EOF
# systemctl restart systemd-udevd
# systemctl daemon-reload
#EOF

# fix udev service config to be able to automount USB devices
install -m 755 files/config_systemd_udev_srv.sh "${ROOTFS_DIR}/config_systemd_udev_srv.sh"
on_chroot << EOF
  bash /config_systemd_udev_srv.sh
EOF

# install bcmstat from github
on_chroot << EOF
cd /home/pi
mkdir -p bcmstat/
chown pi:pi bcmstat/
cd bcmstat/
wget -O bcmstat.sh https://raw.githubusercontent.com/MilhouseVH/bcmstat/0.5.3/bcmstat.sh
chmod a+rx bcmstat.sh
chown pi:pi bcmstat.sh
EOF

# activate more locales and generate files
on_chroot << EOF
echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT ISO-8859-1" >> /etc/locale.gen
echo "de_AT@euro ISO-8859-15" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE ISO-8859-1" >> /etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
locale-gen
locale -a
EOF


# activate pi camera
echo '' >> "${ROOTFS_DIR}/boot/config.txt"
echo 'start_x=1' >> "${ROOTFS_DIR}/boot/config.txt"
echo 'gpu_mem=384' >> "${ROOTFS_DIR}/boot/config.txt"
echo '' >> "${ROOTFS_DIR}/boot/config.txt"

# disable some stuff so that fbset (and framebuffer) works correctly
#sed -i -e 's_dtoverlay=vc4-fkms-v3d_#dtoverlay=vc4-fkms-v3d_' "${ROOTFS_DIR}/boot/config.txt"
#sed -i -e 's/max_framebuffers=.*/#max_framebuffers=2/' "${ROOTFS_DIR}/boot/config.txt"

# HINT: this change is gone in the final image, for some unknown reason
sed -i -e 's_dtparam=audio=on_#dtparam=audio=on_' "${ROOTFS_DIR}/boot/config.txt"


# set kernel commandline to get "proper" 32bit color depth framebuffer again
# see: https://github.com/raspberrypi/linux/issues/5049#issuecomment-1873982920
#      https://www.kernel.org/doc/html/latest/fb/modedb.html
cp -av "${ROOTFS_DIR}/boot/firmware/cmdline.txt" "${ROOTFS_DIR}/boot/firmware/cmdline.txt_"
cat "${ROOTFS_DIR}/boot/firmware/cmdline.txt" | awk '{ print $0 " video=HDMI-A-1:-32" }' > "${ROOTFS_DIR}/boot/firmware/cmdline.txt_"
mv -v "${ROOTFS_DIR}/boot/firmware/cmdline.txt_" "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

echo "contents of /boot/config.txt:"
echo "---------------------------------------"
cat "${ROOTFS_DIR}/boot/config.txt"
echo "---------------------------------------"


### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------
#echo "install tzupdate ..."
#on_chroot << EOF
#  # https://github.com/cdown/tzupdate
#  # util to autodetect timezone from IP address
#  pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate || pip install -U tzupdate
#EOF
#echo "... ready"

echo "install evdev ..."
on_chroot << EOF
  # install module used by "ext_keys_evdev.py" script to get keyboard input events
  # python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev || python3 -m pip install evdev
  apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" python3-evdev
  apt-get install -y --force-yes --no-install-recommends -o "Dpkg::Options::=--force-confdef" python3-libevdev
EOF
echo "... ready"
### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------
### ----- TODO: do those without pip !!!!! ---------


echo "enable reboot on kernel crash"
sed -i -e 's_.*CrashReboot.*__' "${ROOTFS_DIR}/etc/systemd/system.conf"
sed -i -e 's_.*RuntimeWatchdogSec.*__' "${ROOTFS_DIR}/etc/systemd/system.conf"
sed -i -e 's_.*ShutdownWatchdogSec.*__' "${ROOTFS_DIR}/etc/systemd/system.conf"
echo '
CrashReboot=yes
RuntimeWatchdogSec=10s
ShutdownWatchdogSec=5min
' >> "${ROOTFS_DIR}/etc/systemd/system.conf"

echo "contents of /etc/systemd/system.conf:"
echo "---------------------------------------"
cat "${ROOTFS_DIR}/etc/systemd/system.conf"
echo "---------------------------------------"


echo "user run dir size"
echo '
[Login]
RuntimeDirectorySize=2M
' > "${ROOTFS_DIR}/etc/systemd/logind.conf"

echo "contents of /etc/systemd/logind.conf:"
echo "---------------------------------------"
cat "${ROOTFS_DIR}/etc/systemd/logind.conf"
echo "---------------------------------------"


echo "removing some cron files"
on_chroot << EOF
  rm -f /etc/cron.daily/apt-compat
  rm -f /etc/cron.daily/aptitude
  rm -f /etc/cron.daily/man-db
  rm -f /etc/cron.weekly/man-db
EOF


echo "stop unwanted stuff from running on the Pi"
on_chroot << EOF

systemctl disable hciuart.service
systemctl stop hciuart.service

systemctl disable bluealsa.service || echo "ERROR"
systemctl stop bluealsa.service || echo "ERROR"

systemctl disable bluetooth.service || echo "ERROR"
systemctl stop bluetooth.service || echo "ERROR"

systemctl disable bluetooth || echo "ERROR"
systemctl stop bluetooth || echo "ERROR"

systemctl disable avahi-daemon || echo "ERROR"
systemctl stop avahi-daemon || echo "ERROR"

systemctl disable triggerhappy || echo "ERROR"
systemctl stop triggerhappy || echo "ERROR"

systemctl disable triggerhappy.socket || echo "ERROR"
systemctl stop triggerhappy.socket || echo "ERROR"

systemctl disable dbus
systemctl stop dbus || echo "ERROR"

systemctl disable dbus.socket
systemctl stop dbus.socket || echo "ERROR"

systemctl disable syslog
systemctl stop syslog || echo "ERROR"

systemctl disable syslog.socket
systemctl stop syslog.socket || echo "ERROR"

systemctl disable cron
systemctl stop cron || echo "ERROR"

systemctl disable systemd-timesyncd.service
systemctl stop systemd-timesyncd.service || echo "ERROR"

EOF

echo "enable predictable network interface names"
on_chroot << EOF
rm -f /etc/systemd/network/99-default.link
ln -sf /dev/null /etc/systemd/network/99-default.link
EOF

echo "disable more annonying things"
on_chroot << EOF
    rm -f /usr/lib/apt/apt.systemd.daily
    rm -f /lib/systemd/system/apt-daily-upgrade.timer
    rm -f /var/lib/systemd/deb-systemd-helper-enabled/timers.target.wants/apt-daily-upgrade.timer
    rm -f /etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer
    systemctl stop apt-daily.timer || echo "ERROR"
    systemctl disable apt-daily.timer || echo "ERROR"
    systemctl mask apt-daily.service || echo "ERROR"
    systemctl daemon-reload || echo "ERROR"
EOF

echo 'increase network buffers'
on_chroot << EOF
    echo '' >> /etc/sysctl.conf
    echo 'net.core.rmem_max=1048576' >> /etc/sysctl.conf
    echo 'net.core.wmem_max=1048576' >> /etc/sysctl.conf
EOF

echo 'blacklist bcm2835_codec module'
# this module creates /dev/video10 /dev/video11 /dev/video12
on_chroot << EOF
    echo 'blacklist bcm2835_codec' > /etc/modprobe.d/blacklist-bcm2835_codec.conf
EOF

echo 'blacklist snd_bcm2835 module'
# this module creates the audio device for the microphone jack on the pi4, pi3 etc.
on_chroot << EOF
    echo 'blacklist snd_bcm2835' > /etc/modprobe.d/blacklist-snd_bcm2835.conf
EOF

echo 'dont use debian ntp pool, !!metadataleak!!'
on_chroot << EOF
sed -i -e 's#debian\.pool#pool#g' /etc/ntp.conf
EOF

echo 'add some nice aliases to .bashrc'
on_chroot << EOF
    echo '' >> /home/pi/.bashrc
    echo "alias 'tu'='tail -F -n400 ~/ToxBlinkenwall/toxblinkenwall/toxblinkenwall.log'" >> /home/pi/.bashrc
    echo "alias 'nn'='speedometer  -l  -r wlan0 -t wlan0 -m \$(( 1024 * 1024 * 3 / 2 ))'" >> /home/pi/.bashrc
    echo "alias 'nn1'='speedometer  -l  -r eth0 -t eth0 -m \$(( 1024 * 1024 * 3 / 2 ))'" >> /home/pi/.bashrc
    chown pi:pi /home/pi/.bashrc
    # see the content
    cat /home/pi/.bashrc
EOF

