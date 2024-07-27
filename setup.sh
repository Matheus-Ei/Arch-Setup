#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? if yes press enter, else press <Contol+C>" start_install


# Instalations
## Update the system
pacman -Syu

## System base packages
pacman -S pulseaudio sudo networkmanager dhcpcd

## Theme
pacman -S gnome-themes-extra hyprland gtk4 hyprpaper wofi kitty nvidia nvidia-utils lib32-nvidia-utils egl-wayland

## Basic tools 
pacman -S git neovim openssh base-devel firefox

# User preference tools
pacman -S dbeaver docker

clear



# System User Setup
echo "Setting up the system user... "
echo "What is your username?"
read systemUsername
useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername

echo "Set a password:"
passwd $systemUsername

echo "Now open /etc/sudoers and edit the line: "
echo "#%wheel ALL=(ALL:ALL) ALL"
echo "Delete the # before the line"
read -p "Press enter when ready... " temp
nvim /etc/sudoers

clear


# Setup basic settings
## Pacman
echo "Setting up pacman... "
echo "Edit the /etc/pacman.conf and uncomment the line: "
echo "ParallelDownloads = 5"
echo "And edit the lines to include multilib repository"
read -p "Press enter to go to the file... "
nvim /etc/pacman.conf

## Setup git
echo "Setting up git... "
read -p "Tell your git username: " gituser
git config --global user.name "$gituser"

read -p "Tell your git email: " gitmail
git config --global user.email "$gitmail"

ssh-keygen -t ed25519 -C "$gitmail"
echo "Copy the following key to your git and add this to the ssh keys"
cat /home/$system_username/.ssh/id_ed25519.pub
read -p "Press enter when you finished... " temp

## Basic directiories
echo "Setting up the basic directiories... "
cd
mkdir Downloads Documents Pictures Commands Code

## Nvim 
echo "Setting up neovim... "
git clone git@github.com:Matheus-Ei/Nvim-Settings.git
mv Nvim-Settings /home/$system_username/.config/nvim

## Hyprland
echo "Setting up hyprland... "
cd /home/$system_username/Downloads
git clone git@github.com:Matheus-Ei/Hyprland-Settings.git
cd Hyprland-Settings
rm readme.md
mv hypr waybar wofi /home/$system_username/.config/
cd /home/$system_username/Downloads
rm -r Hyrland-Settings

## Yay
echo "Setting up yay... "
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$system_username/Downloads
rm -r yay

## Nvidia
echo "Start the settings of nvidia... "
echo "Edit the /etc/mkinitcpio.conf file and add this line there: "
echo "MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)"
read -p "Press enter when you are ready... " temp
nvim /etc/mkinitcpio.conf

echo "Now edit the /etc/modprobe.d/nvidia.conf and add this line there: "
echo "options nvidia_drm modeset=1 fbdev=1"
read -p "Press enter when you are ready... " temp
nvim /etc/modprobe.d/nvidia.conf

mkinitcpio -P

read -p "Press enter to reboot the system... " temp
reboot



