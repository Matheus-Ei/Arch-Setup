# System basic instalation 
Here is a tutorial of how you can setup arch before you can run the setup script

## Test the internet conection
Before you start the instalation you should test if you have internet connection
`ping google.com`


## Setup the keyboard
Load the keyboard keys with
- Run `loadkeys br-abnt2`


## Partition the disk
Here are the steps to make the partitions in the instalation disk
1. Run `fdisk -l`
2. Run `fdisk /dev/disk-to-install-arch`


## Format the partitions
Now you need to format the disk partitions that you will use to install arch linux
- Efi: `mkfs.fat -F 32 /dev/efi-partition`
- Root: `mkfs.ext4 /dev/root-partition`
- Swap: `mkswap /dev/swap-partition`
or just run the script `partitions.sh`

## Mount the disks
And mount the disks with the following mounting table
- Root: `mount /dev/root-partition /mnt`
- Efi: `mount --mkdir /dev/efi-partition /mnt/boot`
- Swap: `swapon /dev/swap-partition`
or just run the script `partitions.sh`


## Install basic packages 
Install the packages to make just arch linux work by itself with this command
- `pacstrap -K /mnt base linux linux-firmware neovim dhcpcd networkmanager grub efibootmgr git`
we will install on the /mnt, where /root-partition is mounted
or just run the script `base-packages-install.sh`


## Generating fstab
Generate the fstab is important to the system know how mount the disks on the system boot 
- `genfstab -U /mnt >> /mnt/etc/fstab`
or just run the script `gen-fstab.sh`


## Go inside the system
To go inside the system just run
- `arch-chroot /mnt`


## File editions
You can run the script `file-settings.sh` or you can do it manually by doing some file editions
### Generate the locale.gen
1. Edit `/etc/locale.gen`
2. Uncomment `en_US.UTF-8 UTF-8`
3. Run `locale-gen`

### Locale.conf
1. Edit `/etc/locale.conf`
2. Add `LANG=en_US.UTF-8` to the file

### Fix permanently the keyboard
1. Edit the file `/etc/vconsole.conf`
2. Add `KEYMAP=br-abnt2` and save it

### Hostname
1. Edit `/etc/hostname`
2. Set your hostname there like `linus`

### Set the initramfs
We should run `mkinitcpio -P` to set the initramfs


## Set the password for root
Set the root password with this command `passwd`

## Enable the network
To enable the network you should run this command
- `systemctl enable NetworkManager dhcpcd`
or you can just run the script `enable-services.sh`

## Setup the boot loader
Now there are two commands that you should run to set the bootloader
1. `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB`
2. `grub-mkconfig -o /boot/grub/grub.cfg`
or you can just run the script `grub-install.sh`


## Reboot the system
Now just exit the chroot with the command `exit` and reboot the system with `reboot`
