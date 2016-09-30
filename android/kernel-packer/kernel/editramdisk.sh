#!/sbin/sh

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
cp /tmp/initlogo.rle888 /tmp/ramdisk/
insert_line init.hammerhead.rc "init.nitrogen" before "import init.hammerhead.usb.rc" "import init.nitrogen.rc";
cp /tmp/init.nitrogen.rc /tmp/ramdisk/
cp /tmp/init.supolicy.sh /tmp/ramdisk/
find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk
