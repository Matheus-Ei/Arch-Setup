# Requirements
Here is a tutorial of how you can setup arch before you can run the setup script


## Test the internet conection
`ping google.com`


## Setup the keyboard
`loadkeys br-abnt2`


## Partition the disk
- `fdisk -l`
- `fdisk /dev/disk-to-install-arch`


## Format the partitions
- `mkfs.fat -F 32 /dev/efi-partition`
- `mkfs.ext4 /dev/root-partition`
- `mkswap /dev/swap-partition`


## Mount the disks
- `mount /dev/root-partition /mnt`
- `mount --mkdir /dev/efi-partition /mnt/boot`
- `swapon /dev/swap-partition`


## Install basic packages 
`pacstrap -K /mnt base linux linux-firmware neovim dhcpcd networkmanager grub efibootmgr`


## Generating fstab
`genfstab -U /mnt >> /mnt/etc/fstab`


## Go inside the system
`arch-chroot /mnt`


## File editions
### Generate the locale.gen
- `nvim /etc/locale.gen`
- uncomment `en_US.UTF-8 UTF-8`
- `locale-gen`

### Locale.conf
- edit `/etc/locale.conf`
- add `LANG=en_US.UTF-8` to the file

### Fix permanently the keyboard
- edit the file `/etc/vconsole.conf`
- add `KEYMAP=br-abnt2` and save it

### Hostname
- edit `/etc/hostname`
- set your hostname there like `linus`


## Set the initramfs
run `mkinitcpio -P`


## Set the password for root
`passwd`


## Setup the boot loader
`grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB`
`grub-mkconfig -o /boot/grub/grub.cfg`


## Reboot the system
