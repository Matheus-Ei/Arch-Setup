#!/bin/bash
echo "+++++ Load keys +++++" loadkeys br-abnt2


echo "+++++ Setup disk partitions +++++"
fdisk -l
read -p "What is the disk that you want install the system?" disk
parted $disk mklabel gpt

parted $disk mkpart primary fat32 1MiB 1GiB
parted $disk set 1 esp on

parted $disk mkpart primary linux-swap 1GiB 17GiB

parted $disk mkpart primary ext4 17GiB 100%

if ( $disk == '/dev/nvme0n1' ); then
    echo "+++++ Format the disk +++++"
    mkfs.ext4 ${disk}p3
    mkfs.fat -F 32 ${disk}p1
    mkswap ${disk}p2

    echo "+++++ Mount the partitions +++++"
    mount ${disk}p3 /mnt
    mount --mkdir ${disk}p1 /mnt/boot
    swapon ${disk}p2
else
    echo "+++++ Format the disk +++++"
    mkfs.ext4 ${disk}3
    mkfs.fat -F 32 ${disk}1
    mkswap ${disk}2

    echo "+++++ Mount the partitions +++++"
    mount ${disk}3 /mnt
    mount --mkdir ${disk}1 /mnt/boot
    swapon ${disk}2
fi


echo "+++++ Install base packages +++++"
pacstrap -K /mnt base linux linux-firmware neovim dhcpcd networkmanager grub efibootmgr git

echo "+++++ Generate fstab +++++"
genfstab -U /mnt >> /mnt/etc/fstab


arch-chroot /mnt /bin/bash -c '
## Locale generation
echo "+++++ Locale Generation +++++"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

## Setup of locale
echo "+++++ Setup locale +++++"
echo "LANG=en_US.UTF-8" > /etc/locale.conf

## Setup keyboard
echo "+++++ Setup keyboard +++++"
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

## Setup hostname
echo "+++++ Setup hostname +++++"
read -p "What hostname do you want to set? " hostname
echo $hostname > /etc/hostname

echo "+++++ Root password definition +++++"
passwd

echo "+++++ Grub installation and configuration +++++"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
'

reboot
