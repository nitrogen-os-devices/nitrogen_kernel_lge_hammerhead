#!/sbin/sh

mv /system/bin/thermal-engine-hh-bak /system/bin/thermal-engine-hh
mv /system/bin/mpdecision-bak /system/bin/mpdecision

fstrim -v /cache
fstrim -v /data

