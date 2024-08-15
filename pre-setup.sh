#!/bin/bash
echo "+++++ Load keys +++++" 
loadkeys br-abnt2


echo "Setup disk partitions... "
fdisk -l
read -p "What is the disk that you want install the system? " disk

echo "Setup disk partitions... "
parted $disk mklabel gpt
sleep 3
clear

echo "Setup efi partition... "
parted $disk mkpart primary fat32 1MiB 1GiB
parted $disk set 1 esp on
sleep 3
clear

echo "Setup swap partition... "
parted $disk mkpart primary linux-swap 1GiB 17GiB
sleep 3
clear

echo "Setup linux partition... "
parted $disk mkpart primary ext4 17GiB 100%
sleep 3
clear

if ( $disk == '/dev/nvme0n1' ); then
    echo "Format the partitions... "
    mkfs.ext4 ${disk}p3
    mkfs.fat -F 32 ${disk}p1
    mkswap ${disk}p2
    sleep 5
    clear

    echo "Mount the partitions... " 
    mount ${disk}p3 /mnt
    mount --mkdir ${disk}p1 /mnt/boot
    swapon ${disk}p2
    sleep 5
    clear
else
    echo "Format the partitions... "
    mkfs.ext4 ${disk}3
    mkfs.fat -F 32 ${disk}1
    mkswap ${disk}2
    sleep 5
    clear

    echo "Mount the partitions... " 
    mount ${disk}3 /mnt
    mount --mkdir ${disk}1 /mnt/boot
    swapon ${disk}2
    sleep 5
    clear
fi
clear


echo "Install base packages... "
pacstrap -K /mnt base linux linux-firmware neovim dhcpcd networkmanager grub efibootmgr git
sleep 2
clear

echo "Generate fstab... "
genfstab -U /mnt >> /mnt/etc/fstab
sleep 2
clear


arch-chroot /mnt /bin/bash -c '
## Locale generation
echo "Locale Generation... "
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

## Setup of locale
echo "Setup locale... "
echo "LANG=en_US.UTF-8" > /etc/locale.conf

## Generate locale
locale-gen
sleep 2
clear

## Setup keyboard
echo "Setup keyboard... "
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

## Setup hostname
echo "Setup hostname... "
read -p "What hostname do you want to set? " hostname
echo $hostname > /etc/hostname

## Make the mkinitcipio
mkinitcpio -P
sleep 2
clear

## Set root password
echo "Root password definition... "
passwd
sleep 1
clear

echo "Grub installation and configuration... "
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sleep 2
clear

grub-mkconfig -o /boot/grub/grub.cfg
sleep 2
clear
'

sleep 2
reboot
