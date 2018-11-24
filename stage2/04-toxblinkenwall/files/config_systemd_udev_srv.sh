#! /bin/bash

config_file="/lib/systemd/system/systemd-udevd.service"

# cp -a "$config_file" "$config_file"_ORIG

sed -i -e 's_^KillMode=_#KillMode=_' "$config_file"
sed -i -e 's_^RestrictRealtime=_#RestrictRealtime=_' "$config_file"
