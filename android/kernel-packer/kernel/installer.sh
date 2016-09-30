#!/sbin/sh
# Nitrogen Extreme Kernel installer script
# by Mr.MEX
# and good guys

mkdir /tmp/ramdisk
# Copy ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/

cd /tmp/ramdisk/

# Unpack ramdisk
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i

# Install initlogo
if [ -f /tmp/ramdisk/initlogo.rle888 ]; then
	echo "initlogo installed, skipping"
else
	cp /tmp/initlogo.rle888 /tmp/ramdisk/
fi

# Patching init
if grep -q "import init.nitrogen.rc" init.hammerhead.rc; then
	echo "Line: import init.nitrogen.rc is valid, skipping"
else
	insert_line init.hammerhead.rc "init.nitrogen" before "import init.hammerhead.usb.rc" "import init.nitrogen.rc";
fi

# Copy configs
rm /tmp/ramdisk/init.nitrogen.rc
rm /tmp/ramdisk/init.supolicy.sh
cp /tmp/init.nitrogen.rc /tmp/ramdisk/
cp /tmp/init.supolicy.sh /tmp/ramdisk/

# Remove ramdisk
rm /tmp/ramdisk/boot.img-ramdisk.gz

# Create new ramdisk
find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz

# Cleanup
rm -r /tmp/ramdisk

if [ -f /system/bin/thermal-engine-hh ]; then
	if [ -f /system/bin/thermal-engine-hh-bak ]; then
		rm /system/bin/thermal-engine-hh-bak
	fi
	mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak		
fi

if [ -f /system/bin/mpdecision ]; then
	if [ -f /system/bin/mpdecision-bak ]; then
		rm /system/bin/mpdecision-bak
	fi
	mv /system/bin/mpdecision /system/bin/mpdecision-bak		
fi

fstrim -v /cache
fstrim -v /data

# Create new boot image
echo \#!/sbin/sh > /tmp/createnewboot.sh
echo /tmp/mkbootimg --kernel /tmp/zImage-dtb --ramdisk /tmp/boot.img-ramdisk.gz --cmdline \"$(cat /tmp/boot.img-cmdline)\" --base 0x$(cat /tmp/boot.img-base) --pagesize $(cat /tmp/boot.img-pagesize) --ramdisk_offset 0x$(cat /tmp/boot.img-ramdiskoff) --tags_offset 0x$(cat /tmp/boot.img-tagsoff) --output /tmp/newboot.img >> /tmp/createnewboot.sh
chmod 777 /tmp/createnewboot.sh
/tmp/createnewboot.sh
return $?

