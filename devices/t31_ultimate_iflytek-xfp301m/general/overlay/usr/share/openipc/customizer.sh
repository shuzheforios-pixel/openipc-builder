#!/bin/sh
#
# Perform basic settings on iFlytek XFP301-M (T31X, JXQ03, RTL8188FU, 128MB)
#

#
# WiFi (RTL8188FU USB) power enable - GPIO 10
#
echo 10 > /sys/class/gpio/export 2>/dev/null
echo out > /sys/class/gpio/gpio10/direction
echo 1 > /sys/class/gpio/gpio10/value

#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_ultimate_iflytek-xfp301m-nor.tgz'

#
# Set custom majestic settings
#   irCutPin1/2 <- Thingino ircut "57 58"
#   backlightPin <- Thingino ir850 59
#
cli -s .nightMode.irCutPin1 57
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.backlightPin 59
cli -s .video0.codec h264

#
# Set wlan device
#   Thingino: BR2_PACKAGE_WIFI_RTL8188FU=y
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

#
# Set osmem and rmem for 128MB RAM
#
fw_setenv osmem 64M
fw_setenv rmem 64M@0x4000000

exit 0