# RaspberryPi SD CardImage for ToxProxy

### Build Status

**CircleCI** [![CircleCI](https://circleci.com/gh/zoff99/ToxBlinkenwall_raspi_lite_image/tree/toxproxy_01.svg?style=svg)](https://circleci.com/gh/zoff99/ToxBlinkenwall_raspi_lite_image/tree/toxproxy_01)<br>

## Operations manual

1) Download the SD CardImage from the link below.
2) put the Image on your SD Card
3) boot your Raspberry Pi with that SD Card
4) wait for the Raspberry Pi to fully boot up (the first boot can take a few minutes!)
5) plug an empty USB thumb drive into the Raspberry Pi's USB port
6) unplug the USB thumb drive from the Raspberry Pi's USB port
7) open the file ```backup/toxid.txt``` on the USB thumb drive and add this ToxID as friend on your TRIfA App
8) wait for the friend to come online in TRIfA
9) long click on the ToxProxy in TRIfA in the friendlist and select ```add as ToxProxy```
10) Your are **DONE**, you now have offline messages \*<br>
   \* (offline 1-on-1 messages between TRIfa <-> TRIfA)<br>
   \* (offline group messages for all Clients)<br>

## Latest Version (for Raspberry PI)

The latest version can be downloaded from CircleCI via [CircleCI](https://circleci.com/api/v1.1/project/github/zoff99/ToxBlinkenwall_raspi_lite_image/latest/artifacts/0/deploy/image-Raspbian-lite.zip?filter=successful&branch=toxproxy_01)

## Source for ToxProxy

https://github.com/zoff99/ToxProxy/tree/zoff99/tweaks_001/src
