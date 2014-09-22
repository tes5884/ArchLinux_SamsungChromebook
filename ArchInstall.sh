#!/bin/bash

umount /dev/mmcblk1*
parted /dev/mmcblk1 mklabel gpt

cgpt create -z /dev/mmcblk1
cgpt create /dev/mmcblk1
cgpt add -i 1 -t kernel -b 8192 -s 32768 -l U-Boot -S 1 -T 5 -P 10 /dev/mmcblk1
cgpt add -i 2 -t data -b 40960 -s 32768 -l Kernel /dev/mmcblk1
cgpt add -i 12 -t data -b 73728 -s 32768 -l Script /dev/mmcblk1
PARTSIZE=`cgpt show /dev/mmcblk1 | grep 'Sec GPT table' | egrep -o '[0-9]+' | head -n 1`
cgpt add -i 3 -t data -b 106496 -s `expr ${PARTSIZE} - 106496` -l Root /dev/mmcblk1
partprobe /dev/mmcblk1
mkfs.ext2 /dev/mmcblk1p2
mkfs.ext4 /dev/mmcblk1p3
mkfs.vfat -F 16 /dev/mmcblk1p12

cd /tmp
wget http://archlinuxarm.org/os/ArchLinuxARM-chromebook-latest.tar.gz
mkdir root
mount /dev/mmcblk1p3 root
tar -xf ArchLinuxARM-chromebook-latest.tar.gz -C root

mkdir mnt
mount /dev/mmcblk1p2 mnt
cp root/boot/vmlinux.uimg mnt
umount mnt

mount /dev/mmcblk1p12 mnt
mkdir mnt/u-boot
wget http://archlinuxarm.org/os/exynos/boot.scr.uimg
cp boot.scr.uimg mnt/u-boot
umount mnt

wget -O - http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nv_uboot-snow.kpart.bz2 | bunzip2 > nv_uboot-snow.kpart
dd if=nv_uboot-snow.kpart of=/dev/mmcblk1p1

umount root
sync
