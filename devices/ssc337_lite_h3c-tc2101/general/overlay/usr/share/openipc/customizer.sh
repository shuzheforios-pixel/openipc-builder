#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc337_lite_h3c-tc2101-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.backlightPin 61
cli -s .audio.speakerPin 15
#
#
# Set wlan device and credentials if need
#
fw_setenv rootmtd 10240k
fw_setenv rootsize 0xA00000


fw_setenv wlandev rtl8188fu-generic
fw_setenv wlanssid @PHICOMM_10
fw_setenv wlanpass qweqwe123


ln -sf /usr/sbin/onvif_simple_server /var/www/cgi-bin/onvif_simple_server
chmod 755 /var/www/cgi-bin/live.cgi
chown root:root /var/www/cgi-bin/live.cgi
chmod 755 /etc/init.d/S40network
chmod 644 /etc/zerotier.conf

fw_setenv sensor jxq03

if [ -f /var/www/cgi-bin/p/footer.cgi ]; then
    if ! grep -q "ptz-inject.js" /var/www/cgi-bin/p/footer.cgi; then
        echo '<script src="/a/ptz-inject.js"></script>' >> /var/www/cgi-bin/p/footer.cgi
    fi
fi



exit 0
