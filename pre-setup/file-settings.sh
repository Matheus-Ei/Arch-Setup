# General settings
echo "+++++ General settings +++++"

## Locale generation
echo "Go the the file /etc/locale.gen and uncomment the line"
echo "===-------------==="
echo "en_US.UTF-8 UTF-8"
echo "===-------------==="
read -p "Press enter when you are ready... "
nvim /etc/locale.gen
locale-gen

##Setup timeset
echo "+++++ Setup timeset +++++"
timedatectl set-timezone America/Sao_Paulo

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

echo "+++++ Initramfs setup +++++"
mkinitcpio -P

echo "+++++ Root password definition +++++"
passwd
