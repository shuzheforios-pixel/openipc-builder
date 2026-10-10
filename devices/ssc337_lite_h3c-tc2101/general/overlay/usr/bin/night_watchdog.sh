#!/bin/sh
MAX_GAIN=8192     
MIN_GAIN=2100     
INTERVAL=3        
TMP_METRICS="/tmp/.metrics_cache"


ZT_NETWORK_ID="8d1c312afa5243c4"
ZT_CHECK=30
ZT_COUNTER=0
# =========================

if [ -f /var/www/cgi-bin/p/footer.cgi ]; then
    if ! grep -q "ptz-inject.js" /var/www/cgi-bin/p/footer.cgi; then
        echo '<script src="/a/ptz-inject.js"></script>' >> /var/www/cgi-bin/p/footer.cgi
    fi
fi
echo "CST-8" > /etc/TZ

while true; do
    wget -q -O "$TMP_METRICS" "http://127.0.0.1/metrics" 2>/dev/null
    GAIN=$(awk '/^isp_again/{print $2}' "$TMP_METRICS")
    STATE=$(awk '/^night_enabled/{print $2}' "$TMP_METRICS")

    if [ -z "$GAIN" ] || [ -z "$STATE" ]; then
        sleep "$INTERVAL"
        continue
    fi

    if [ "$STATE" = "0" ] && [ "$GAIN" -gt "$MAX_GAIN" ]; then
        wget -q -O - "http://127.0.0.1/night/on" >/dev/null 2>&1
    elif [ "$STATE" = "1" ] && [ "$GAIN" -lt "$MIN_GAIN" ]; then
        wget -q -O - "http://127.0.0.1/night/off" >/dev/null 2>&1
    fi


    ZT_COUNTER=$((ZT_COUNTER + 1))
    if [ "$ZT_COUNTER" -ge "$ZT_CHECK" ]; then
        ZT_COUNTER=0
        if ! zerotier-cli info 2>/dev/null | grep -q ONLINE; then
            killall -9 zerotier-one 2>/dev/null
            killall -9 zerotier-cli 2>/dev/null
            sleep 2
            /etc/init.d/S90zerotier start
            sleep 5
            if ! zerotier-cli listnetworks 2>/dev/null | grep -q "$ZT_NETWORK_ID"; then
                zerotier-cli join "$ZT_NETWORK_ID" 2>/dev/null
            fi
        fi
    fi
    # =============================

    sleep "$INTERVAL"
done