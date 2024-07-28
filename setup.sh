#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? (Y/n) " startInstall
if [ "$startInstall" == "n" ]; then
    exit
fi


# Instalations
## Pacman
echo "+++++ Setup pacman +++++"
echo "Edit the /etc/pacman.conf and uncomment the line"
echo "ParallelDownloads = 5"
echo "And edit the lines to include multilib repository"
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
if [ "$installUserPreference" == "n"]; then
    echo "Skipping the user preference tool installer... "
else
    sh ./tools.sh
fi
clear


# System User Setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

read -p "Setup new user? (Y/n) " setupUser
if [ "$setupUser" == "n" ]; then
    echo "Skiping the user setup... "
else
    useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername

    echo "Now set a password"
    passwd $systemUsername
fi

echo "Now open /etc/sudoers and edit the line"
echo "#%wheel ALL=(ALL:ALL) ALL"
echo "Delete the # before the line"
read -p "Press enter when ready... "
nvim /etc/sudoers

## Basic directiories
echo "+++++ Setup basic directiories +++++"
read -p "Setup basic directiories? (Y/n) " setupBasicDirectories
if [ "$setupBasicDirectories" == "n" ]; then
    echo "Skipping basic directories setup... "
else 
    cd /home/$systemUsername
    sudo -u $systemUsername mkdir Downloads Documents Pictures Commands Code .ssh .config
    cd -
fi
clear


# Setup basic settings
## Setup yay
read -p "Start yay installer? (Y/n) " installYay
if [ "$installYay" == "n" ]; then
    echo "Skipping the yay setup... "
else 
    sudo -u $systemUsername sh ./yay.sh
    cd /home/$systemUsername/Downloads
    rm -r yay
fi

## Setup git
echo "+++++ Setup git +++++"
read -p "Setup git config? (Y/n) " setupGit
if [ "$setupGit" == "n" ]; then
    echo "Skipping git config setup... "
else
    read -p "What is your git user? " gituser
    sudo -u $systemUsername git config --global user.name "$gituser"

    read -p "What is your git email? " gitmail
    sudo -u $systemUsername git config --global user.email "$gitmail"

fi

read -p "Setup ssh key on git? (Y/n) " setupSshKey
if [ "$setupSshKey" == "n" ]; then
    echo "Skipping the setup of the ssh key on git... "
else
    sudo -u $systemUsername ssh-keygen -t ed25519 -C "$gitmail" -f /home/$systemUsername/.ssh/id_ed25519
    echo "Copy the following key to your git and add this to the ssh keys"
    cat /home/$systemUsername/.ssh/id_ed25519.pub
    read -p "Press enter when you finished... "
fi
clear

## Nvim 
echo "+++++ Setup neovim +++++"
read -p "Setup neovim? (Y/n) " setupNeovim
if [ "$setupNeovim" == "n" ]; then
    echo "Skipping neovim setup... "
else 
    git clone https://github.com/Matheus-Ei/Nvim-Settings.git
    mv Nvim-Settings /home/$systemUsername/.config/nvim
fi

## Hyprland
echo "+++++ Setup hyprland +++++"
read -p "Setup hyprland? (Y/n) " setupHyrland
if [ "$setupHyrland" == "n" ]; then
    echo "Skipping hyprland setup... "
else
    cd /home/$systemUsername/Downloads
    git clone https://github.com/Matheus-Ei/Hyprland-Settings.git
    cd Hyprland-Settings
    mv hypr waybar wofi /home/$systemUsername/.config/
    cd /home/$systemUsername/Downloads
    rm -r Hyrland-Settings
    clear

    ### Nvidia
    echo "+++++ Setup nvidia for hyprland +++++"
    echo "Edit the /etc/mkinitcpio.conf file and add this line there: "
    echo "MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)"
    read -p "Press enter when you are ready... "
    nvim /etc/mkinitcpio.conf

    echo "Now edit the /etc/modprobe.d/nvidia.conf and add this line there: "
    echo "options nvidia_drm modeset=1 fbdev=1"
    read -p "Press enter when you are ready... "
    nvim /etc/modprobe.d/nvidia.conf

    mkinitcpio -P
fi
clear

read -p "Press enter to reboot the system... "
reboot



