# Instalations
## Pacman
echo "+++++ Setup pacman +++++"
echo "Edit the /etc/pacman.conf and uncomment the line"
echo "====----------------------===="
echo "ParallelDownloads = 5"
echo "Edit the lines to include multilib repository"
echo "====----------------------===="
read -p "Press enter to go to the file... "
nvim /etc/pacman.conf

## Update the system
pacman -Syu

## System base packages
pacman -S pulseaudio pulseaudio-alsa alsa-utils sudo networkmanager dhcpcd

## Theme
pacman -S gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty nvidia nvidia-utils lib32-nvidia-utils egl-wayland

## Basic tools 
pacman -S git neovim openssh base-devel 

## User preference tools
read -p "Start user preference tool installer? (Y/n) " installUserPreference
if [ "$installUserPreference" == "n" ]; then
    echo "Skipping the user preference tool installer... "
else
    sh ./scripts/tools-setup.sh
fi
clear

