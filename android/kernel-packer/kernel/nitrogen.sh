#!/sbin/sh

mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak
mv /system/bin/mpdecision /system/bin/mpdecision-bak

fstrim -v /cache
fstrim -v /data

