#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? (Y/n) " startInstall
if [ "$startInstall" == "n" ]; then
    exit
fi

## Has nvidia GPU
read -p "Do you have a nvidia GPU? (y/N) " hasNvidia




# Packages setup
## Pacman
echo "+++++ Setup pacman +++++"
echo "Edit the /etc/pacman.conf and uncomment the line"
echo "====----------------------===="
echo "ParallelDownloads = 5"
echo "Edit the lines to include multilib repository"
echo "====----------------------===="
read -p "Press enter to go to the file... "
nvim /etc/pacman.conf
clear

## Update the system
echo "" | pacman -Syu  1> /dev/null 2>&1
echo "Repository updated... "
echo "System upgraded"

## Nvidia GPU
[ "$hasNvidia" == "y" ] && ( echo "" | pacman -S nvidia nvidia-utils lib32-nvidia-utils 1> /dev/null 2>&1 ) && echo "Nvidia packages installed... "
## System base packages
echo "" | pacman -S pulseaudio pulseaudio-alsa alsa-utils sudo networkmanager dhcpcd 1> /dev/null 2>&1 && echo "System base packages installed... "
## Theme
echo "" | pacman -S gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty egl-wayland 1> /dev/null 2>&1 && echo "Theme packages installed... "
## Basic tools 
echo "" | pacman -S git neovim openssh base-devel 1> /dev/null 2>&1 && echo "Basic tools installed... "



## User preference tools
read -p "Start user preference tool installer? (Y/n) " installUserPreference
if [ "$installUserPreference" == "n" ]; then
    echo "Skipping the user preference tool installer... "
else
    # Development tools
    echo "%%%% Development tools %%%%"
    read -p "Install docker? (y/N) " iDocker
    [ "$iDocker" == "y" ] && ( echo "" | pacman -S docker 1> /dev/null 2>&1 ) && echo "Docker installed... "
    read -p "Install dbeaver? (y/N) " iDbeaver
    [ "$iDbeaver" == "y" ] && ( echo "" | pacman -S dbeaver 1> /dev/null 2>&1 ) && echo "Dbeaver installed... "
    read -p "Install man? (y/N) " iMan
    [ "$iMan" == "y" ] && ( echo "" | pacman -S man 1> /dev/null 2>&1 ) && echo "Man installed... "
    read -p "Install neovim? (y/N) " iNvim
    [ "$iNvim" == "y" ] && ( echo "" | pacman -S neovim 1> /dev/null 2>&1 ) && echo "Neovim installed... "
    read -p "Install git? (y/N) " iGit
    [ "$iGit" == "y" ] && ( echo "" | pacman -S git 1> /dev/null 2>&1 ) && echo "Git installed... "

    # Browsers
    echo "%%%% Browsers %%%%"
    read -p "Install firefox? (y/N) " iFirefox
    [ "$iFirefox" == "y" ] && ( echo "" | pacman -S firefox 1> /dev/null 2>&1 ) && echo "Firefox installed... "
    read -p "Install tor? (y/N) " iTor
    [ "$iTor" == "y" ] && ( echo "" | pacman -S torbrowser-launcher 1> /dev/null 2>&1 ) && echo "Tor installed... "

    # Programming languages
    echo "%%%% Programming languages %%%%"
    read -p "Install python? (y/N) " iPython
    [ "$iPython" == "y" ] && ( echo "" | pacman -S python python3 1> /dev/null 2>&1 ) && echo "Python installed... "
    read -p "Install nodejs? (y/N) " iNodejs
    [ "$iNodejs" == "y" ] && ( echo "" | pacman -S nodejs 1> /dev/null 2>&1 ) && echo "Nodejs installed... "
    read -p "Install java? (y/N) " iJava
    [ "$iJava" == "y" ] && ( echo "" | pacman -S jre-openjdk jdk-openjdk 1> /dev/null 2>&1 ) && echo "Java installed... "
    read -p "Install C++? (y/N) " iCpp
    [ "$iCpp" == "y" ] && ( echo "" | pacman -S gcc 1> /dev/null 2>&1 ) && echo "C++ installed... "
    read -p "Install postgresql? (y/N) " iPostgresql
    [ "$iPostgresql" == "y" ] && ( echo "" | pacman -S postgresql 1> /dev/null 2>&1 ) && echo "PostgreSql installed... "

    # Ultilities
    echo "%%%% Ultilities %%%%"
    read -p "Install libreoffice suit? (y/N) " iLibreoffice
    [ "$iLibreoffice" == "y" ] && ( echo "" | pacman -S libreoffice 1> /dev/null 2>&1 ) && echo "Libreoffice installed... "
    read -p "Install audacity? (y/N) " iAudacity
    [ "$iAudacity" == "y" ] && ( echo "" | pacman -S audacity 1> /dev/null 2>&1 ) && echo "Audacity installed... "
fi
clear




# System User Setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

read -p "Setup new user? (Y/n) " setupUser
if [ "$setupUser" == "n" ]; then
    echo "Skipping the user setup... "
else
    useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername 1> /dev/null 2>&1 && echo "User setup was concluded... " 

    echo "Now set a password"
    passwd $systemUsername 1> /dev/null 2>&1 && echo "Password for the user was setted... "
    read -p "Press enter when ready... "
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
    clear
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
    echo "Setting up yay... "
    cd /home/$systemUsername/Downloads
    sudo -u $systemUsername git clone https://aur.archlinux.org/yay.git 1> /dev/null 2>&1 && echo "Yay repository cloned... "
    cd yay
    sudo -u $systemUsername ( echo "" | makepkg -si )#1> /dev/null 2>&1 ) && echo "Yay installed... "

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
    sudo -u $systemUsername ( echo "" | ssh-keygen -t ed25519 -C "$gitmail" -f /home/$systemUsername/.ssh/id_ed25519 ) # 1> /dev/null 2>&1 ) && echo "The generation of the ssh key was a success... "
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
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Nvim-Settings.git 1> /dev/null 2>&1 && echo "Cloning neovim settings repository... "
    mv Nvim-Settings /home/$systemUsername/.config/nvim 1> /dev/null 2>&1 && echo "Neovim installed... "
fi

## Hyprland
echo "+++++ Setup hyprland +++++"
read -p "Setup hyprland? (Y/n) " setupHyrland
if [ "$setupHyrland" == "n" ]; then
    echo "Skipping hyprland setup... "
else
    cd /home/$systemUsername/Downloads
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Hyprland-Settings.git 1> /dev/null 2>&1 && echo "Cloning the hyprland settings repository... "
    cd -
    cd Hyprland-Settings
    mv hypr waybar wofi /home/$systemUsername/.config/ 1> /dev/null 2>&1 && echo "The setup of hyprland settings was a success... "
    cd -
    cd /home/$systemUsername/Downloads
    rm -r Hyrland-Settings
    cd -
    clear

    ### Nvidia
    if [ "$hasNvidia" == "y" ]; then
        echo "+++++ Setup nvidia for hyprland +++++"
        echo "Edit the /etc/mkinitcpio.conf file and add this line there: "
        echo "====----------------------===="
        echo "MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)"
        echo "====----------------------===="
        read -p "Press enter when you are ready... "
        nvim /etc/mkinitcpio.conf
        clear

        echo "Now edit the /etc/modprobe.d/nvidia.conf and add this line there: "
        echo "====----------------------===="
        echo "options nvidia_drm modeset=1 fbdev=1"
        echo "====----------------------===="
        read -p "Press enter when you are ready... "
        nvim /etc/modprobe.d/nvidia.conf
        clear

        mkinitcpio -P
        
    else
        echo "Skipping wayland nvidia setup... "
    fi
fi
clear

read -p "Press enter to reboot the system... "
reboot
