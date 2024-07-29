#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? (Y/n) " startInstall
if [ "$startInstall" == "n" ]; then
    exit
fi

# Packages setup
sh ./scripts/packages-setup.sh


# System User Setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

read -p "Setup new user? (Y/n) " setupUser
if [ "$setupUser" == "n" ]; then
    echo "Skipping the user setup... "
else
    useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername

    echo "Now set a password"
    passwd $systemUsername
fi

## Sudo Setup
read -p "" setupSudo
if [ "$setupSudo" == "n" ]; then
    echo "Skipping sudo setup... "
else
    echo "Now open /etc/sudoers and edit the line and remove the # before the line"
    echo "====----------------------===="
    echo "#%wheel ALL=(ALL:ALL) ALL"
    echo "====----------------------===="
    read -p "Press enter when ready... "
    nvim /etc/sudoers
fi

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
    sudo -u $systemUsername sh ./scripts/yay-setup.sh
    cd /home/$systemUsername/Downloads
    rm -r yay
    cd -
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
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Nvim-Settings.git
    mv Nvim-Settings /home/$systemUsername/.config/nvim
fi


## Hyprland
echo "+++++ Setup hyprland +++++"
read -p "Setup hyprland? (Y/n) " setupHyrland
if [ "$setupHyrland" == "n" ]; then
    echo "Skipping hyprland setup... "
else
    cd /home/$systemUsername/Downloads
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Hyprland-Settings.git
    cd -
    cd Hyprland-Settings
    mv hypr waybar wofi /home/$systemUsername/.config/
    cd -
    cd /home/$systemUsername/Downloads
    rm -r Hyrland-Settings
    cd -
    clear

    ### Nvidia
    read -p "Do you have a nvidia GPU? (Y/n) " hasNvidia
    if [ "$hasNvidia" == "n" ]; then
        echo "Skipping wayland nvidia setup... "
    else
        echo "+++++ Setup nvidia for hyprland +++++"
        echo "Edit the /etc/mkinitcpio.conf file and add this line there: "
        echo "====----------------------===="
        echo "MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)"
        echo "====----------------------===="
        read -p "Press enter when you are ready... "
        nvim /etc/mkinitcpio.conf

        echo "Now edit the /etc/modprobe.d/nvidia.conf and add this line there: "
        echo "====----------------------===="
        echo "options nvidia_drm modeset=1 fbdev=1"
        echo "====----------------------===="
        read -p "Press enter when you are ready... "
        nvim /etc/modprobe.d/nvidia.conf

        mkinitcpio -P
    fi
fi
clear

read -p "Press enter to reboot the system... "
reboot
