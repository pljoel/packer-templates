#!/usr/bin/env bash

#REFERENCES
# https://disconnected.systems/blog/archlinux-installer/#the-complete-installer-script
# https://wiki.archlinux.org/index.php/Installation_guide
# https://www.youtube.com/watch?v=DfC5hgdtbWY
# http://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html

######### Network #########
dhcpcd

######### Update the system clock #########
timedatectl set-ntp true

######### Partitioning #########
# Check UEFI/GPT
ls /sys/firmware/efi
# TODO: Need to look the output
sgdisk -Z /dev/sda
sgdisk -n 0:0:+256M -c 0:"EFI System Partition" -t 0:ef00 /dev/sda
#sgdisk -n 0:0:+8G -c 0:"SWAP Partition" -t 0:8200 /dev/sda
sgdisk -n 0:0:0 -c 0:"Data Partition" -t 0:8300 /dev/sda
sgdisk -p /dev/sda
partprobe /dev/sda

######### Filesystems creation #########
mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2

######### Mount the partitions #########
mount /dev/sda2 /mnt/
mkdir /mnt/boot/
mount /dev/sda1 /mnt/boot/

######### Install base packages #########
pacstrap /mnt base open-vm-tools intel-ucode openssh #base-devel

######### Configure the system #########
genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
echo "arch" > /mnt/etc/hostname
ln -sf /mnt/usr/share/zoneinfo/America/Toronto /mnt/etc/localtime
sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Wrap commands inside of "arch-chroot" that needs to be run inside the context
arch-chroot /mnt locale-gen
arch-chroot /mnt usermod --password $(openssl passwd -1 packer123!) root
arch-chroot /mnt systemctl enable vmtoolsd.service
arch-chroot /mnt systemctl enable vmware-vmblock-fuse.service
arch-chroot /mnt systemctl enable sshd.service
arch-chroot /mnt systemctl enable dhcpcd.service
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /mnt/etc/ssh/sshd_config

######### Install the bootloader #########
arch-chroot /mnt bootctl install
cat <<EOF > /mnt/boot/loader/loader.conf
default arch
timeout 3
EOF

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /intel-ucode.img
initrd   /initramfs-linux.img
options  root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2) rw
EOF

reboot