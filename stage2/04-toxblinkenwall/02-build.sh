#!/bin/bash -e

install -m 755 files/build_tbw.sh "${ROOTFS_DIR}/home/pi/"

on_chroot << EOF
id -a
su - pi bash -c "/home/pi/build_tbw.sh"
EOF
