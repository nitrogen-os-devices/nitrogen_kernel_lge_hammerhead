#!/bin/bash

nitrogen_dir=nitrogenEx
nitrogen_build_dir=nitrogenEx-builds
compiler_dir=../Linaro-4.9.4
compiler_prefix=bin/arm-eabi-
cross_compiler=$compiler_dir/$compiler_prefix

if ! [ -d ~/.ccache ]; then
	echo -e "${bldred}No ccache directory, creating...${txtrst}"
	mkdir ~/.ccache
fi
if ! [ -d ~/.ccache/$nitrogen_dir ]; then
	echo -e "${bldred}No ccache/$nitrogen_dir directory, creating...${txtrst}"
	mkdir ~/.ccache/$nitrogen_dir
fi
if ! [ -d ../$nitrogen_build_dir ]; then
	echo -e "${bldred}No $nitrogen_build_dir directory, creating...${txtrst}"
	mkdir ~/$nitrogen_build_dir
	mkdir ~/$nitrogen_build_dir/build_files
fi
if ! [ -d ../$compiler_dir ]; then
	echo -e "${bldred}No $compiler_dir directory, creating...${txtrst}"
	git clone https://github.com/nitrogen-devs/android_toolchain_linaro.git $compiler_dir
fi

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD=$(cat /proc/cpuinfo | grep 'model name' | sed -e 's/.*: //' | wc -l)
KERNEL="zImage-dtb"
DEFCONFIG="hammerhead_defconfig"

# Kernel Details
BASE_NEX_VER="NitrogenEX"
kversion="0.5";
VER=".$kversion"
NEX_VER="$BASE_NEX_VER$VER"

# Vars
export CCACHE_DIR=~/.ccache/nitrogenex
export LOCALVERSION=.`echo $NEX_VER`
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$cross_compiler

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="android/kernel-packer"
ZIP_MOVE=~/$nitrogen_build_dir/3.4.0.`echo $NEX_VER`.zip
ZIMAGE_DIR="arch/arm/boot"

# Functions
function clean_all {
		rm -rf $REPACK_DIR/kernel/$KERNEL
		rm -rf $REPACK_DIR/META-INF/com/google/android/updater-script
		make clean && make mrproper
}

function make_kernel {
		make $DEFCONFIG
		make -j$THREAD  2<&1 | tee builder.log
		if [ -f $ZIMAGE_DIR/$KERNEL ]; then
			cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/kernel/$KERNEL
		fi
}

function make_updater {
(cat << EOF) > $REPACK_DIR/META-INF/com/google/android/updater-script 
ui_print(" ");
ui_print(" ");
ui_print(" ");
ui_print("-----------------------------------------------");
ui_print("*  * *** *** **** **** **** *** *  *  *** *   *");
ui_print("** *  *   *  *  * *  * *    *   ** *  *    * *");
ui_print("* **  *   *  **** *  * * ** *** * **  ***   *");
ui_print("*  *  *   *  * *  *  * *  * *   *  *  *    * *");
ui_print("*  * ***  *  * *  **** **** *** *  *  *** *   *");
ui_print("- By Mr.MEX --------------------- Linux 3.4.0 -");
ui_print("- Extreme version: $kversion                        -");
ui_print("- For: Google Nexus 5 (HAMMERHEAD)            -");
ui_print("-----------------------------------------------");
ui_print(" ");
ui_print(" ");
ui_print(" ");
ui_print("- Installing... -------------------------------");
ui_print("- Mount /system                               -");
run_program("/sbin/busybox", "mount", "/system");
ui_print("-     Done!                                   -");
ui_print("- Mount /data                                 -");
run_program("/sbin/busybox", "mount", "/data");
ui_print("-     Done!                                   -");
ui_print("- Extract files to /tmp                       -");
package_extract_dir("kernel", "/tmp");
ui_print("-     Done!                                   -");
ui_print("- Extract files to /system                    -");
package_extract_dir("system", "/system");
ui_print("-     Done!         
ui_print("- Setting permirrions                         -");
set_perm(0, 0, 0777, "/tmp/makebootimg.sh");
set_perm(0, 0, 0777, "/tmp/mkbootimg");
set_perm(0, 0, 0777, "/tmp/unpackbootimg");
ui_print("-     Done!                                   -");
ui_print("- Copy boot.img to /tmp                       -");
run_program("/sbin/busybox", "dd", "if=/dev/block/platform/msm_sdcc.1/by-name/boot", "of=/tmp/boot.img");
ui_print("-     Done!                                   -");
ui_print("- Unpack boot.img                             -");
run_program("/tmp/unpackbootimg", "-i", "/tmp/boot.img", "-o", "/tmp/");
ui_print("-     Done!                                   -");
ui_print("- Install new zImage-dtb, pack boot.img       -");
run_program("/tmp/makebootimg.sh");
ui_print("-     Done!                                   -");
ui_print("- Flasing new boot.img                        -");
run_program("/sbin/busybox", "dd", "if=/tmp/newboot.img", "of=/dev/block/platform/msm_sdcc.1/by-name/boot");
ui_print("-     Done!                                   -");
ui_print("- Unmount /system                             -");
unmount("/data");
ui_print("-     Done!                                   -");
ui_print("- Unmount /data                               -");
unmount("/system");
ui_print("-     Done!                                   -");
ui_print("-----------------------------------------------");
ui_print(" ");
ui_print(" ");
ui_print(" ");
ui_print("- Nitrogen Extreme Kernel ---------------------");
ui_print("-                                             -");
ui_print("-            Installation complete!           -");
ui_print("-                                             -");
ui_print("-----------------------------------------------");
ui_print(" ");
ui_print(" ");
ui_print(" ");
EOF
}

function make_zip {
	cd $REPACK_DIR
	if [ -f kernel/$KERNEL ]; then
		zip -9 -r `echo $NEX_VER`.zip .
		if [ -f `echo $NEX_VER`.zip ]; then
			mv `echo $NEX_VER`.zip $ZIP_MOVE
		else
			echo -e "No zip!"
		fi
	else
		echo -e "No $KERNEL !"
	fi
	cd $KERNEL_DIR
}

function cleanup {
		rm -rf $REPACK_DIR/kernel/$KERNEL
		rm -rf $REPACK_DIR/META-INF/com/google/android/updater-script
		rm -rf `echo $NEX_VER`.zip
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "Kernel Creation Script:"
echo

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$NEX_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Please choose your option:
1. Clean build
2. Dirty build
3. Abort
:> " cchoice
do
case "$cchoice" in
	1 )
		echo -e "${green}"
		echo
		echo "[..........Cleaning up..........]"
		echo
		echo -e "${restore}"
		clean_all
		echo -e "${green}"
		echo
		echo "[....Building `echo $NEX_VER`....]"
		echo
		echo -e "${restore}"
		make_kernel
		make_updater
		echo -e "${green}"
		echo
		echo "[....Make `echo $NEX_VER`.zip....]"
		echo
		echo -e "${restore}"
		make_zip
		echo -e "${green}"
		echo
		echo "[.....Moving `echo $NEX_VER`.....]"
		echo
		echo -e "${restore}"
		cleanup
		break
		;;
	2 )
		echo -e "${green}"
		echo
		echo "[....Building `echo $NEX_VER`....]"
		echo
		echo -e "${restore}"
		make_kernel
		make_updater
		echo -e "${green}"
		echo
		echo "[....Make `echo $NEX_VER`.zip....]"
		echo
		echo -e "${restore}"
		make_zip
		echo -e "${green}"
		echo
		echo "[.....Moving `echo $NEX_VER`.....]"
		echo
		echo -e "${restore}"
		cleanup
		break
		;;
	3 )
		break
		;;
	* )
		echo -e "${red}"
		echo
		echo "Invalid try again!"
		echo
		echo -e "${restore}"
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
