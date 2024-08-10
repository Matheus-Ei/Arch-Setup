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
echo "" | pacman -Sy  1> /dev/null 2>&1
echo "Repository updated... "
echo "" | pacman -Su  1> /dev/null 2>&1
echo "System upgraded..."

## Nvidia GPU
if [ "$hasNvidia" == "y" ]; then
    echo -e "\n" | pacman -S nvidia nvidia-utils lib32-nvidia-utils 1> /dev/null 2>&1
    echo "Nvidia packages installed... "
fi

## System base packages
echo "" | pacman -S pulseaudio pulseaudio-alsa alsa-utils sudo networkmanager dhcpcd 1> /dev/null 2>&1
echo "System base packages installed... "

## Theme
echo -e "\n\n" | pacman -S gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty egl-wayland 1> /dev/null 2>&1
echo "Theme packages installed... "

## Basic tools 
echo "" | pacman -S git neovim wl-clipboard openssh base-devel 1> /dev/null 2>&1
echo "Basic tools installed... "
clear

## User preference tools
read -p "Start user preference tool installer? (Y/n) " installUserPreference
if [ "$installUserPreference" == "n" ]; then
    echo "Skipping the user preference tool installer... "
else
    # Development tools
    echo "%%%% Development tools %%%%"
    read -p "Install docker? (y/N) " iDocker 
    if [ "$iDocker" == "y" ]; then 
       echo "" | pacman -S docker
       clear
       echo "Docker installed... "
    fi

    read -p "Install dbeaver? (y/N) " iDbeaver
    if [ "$iDbeaver" == "y" ]; then
        echo "" | pacman -S dbeaver
        clear
        echo "Dbeaver installed... "
    fi

    read -p "Install man? (y/N) " iMan
    if [ "$iMan" == "y" ]; then
        echo "" | pacman -S man
        clear
        echo "Man installed... "
    fi

    read -p "Install neovim? (y/N) " iNvim
    if [ "$iNvim" == "y" ]; then
        echo "" | pacman -S neovim
        clear
        echo "Neovim installed... "
    fi

    read -p "Install git? (y/N) " iGit
    if [ "$iGit" == "y" ]; then
        echo "" | pacman -S git
        clear
        echo "Git installed... "
    fi

    # Browsers
    echo "%%%% Browsers %%%%"
    read -p "Install firefox? (y/N) " iFirefox
    if [ "$iFirefox" == "y" ]; then
        echo "" | pacman -S firefox
        clear
        echo "Firefox installed... "
    fi

    read -p "Install tor? (y/N) " iTor
    if [ "$iTor" == "y" ]; then
        echo "" | pacman -S torbrowser-launcher
        clear
        echo "Tor installed... "
    fi

    # Programming languages
    echo "%%%% Programming languages %%%%"
    read -p "Install python? (y/N) " iPython
    if [ "$iPython" == "y" ]; then
        echo "" | pacman -S python python3
        clear
        echo "Python installed... "
    fi
    read -p "Install nodejs? (y/N) " iNodejs
    if [ "$iNodejs" == "y" ]; then
        echo "" | pacman -S nodejs
        clear
        echo "Nodejs installed... "
    fi

    read -p "Install java? (y/N) " iJava
    if [ "$iJava" == "y" ]; then
        echo "" | pacman -S jre-openjdk jdk-openjdk
        clear
        echo "Java installed... "
    fi

    read -p "Install C++? (y/N) " iCpp
    if [ "$iCpp" == "y" ]; then
        echo "" | pacman -S gcc
        clear
        echo "C++ installed... "
    fi

    read -p "Install postgresql? (y/N) " iPostgresql
    if [ "$iPostgresql" == "y" ]; then
        echo "" | pacman -S postgresql
        clear
        echo "PostgreSql installed... "
    fi

    # Ultilities
    echo "%%%% Ultilities %%%%"
    read -p "Install libreoffice suit? (y/N) " iLibreoffice
    if [ "$iLibreoffice" == "y" ]; then
        echo "" | pacman -S libreoffice
        clear
        echo "Libreoffice installed... "
    fi

    read -p "Install audacity? (y/N) " iAudacity
    if [ "$iAudacity" == "y" ]; then
        echo "" | pacman -S audacity
        clear
        echo "Audacity installed... "
    fi
fi
clear



# System User Setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

read -p "Setup new user? (Y/n) " setupUser
if [ "$setupUser" == "n" ]; then
    echo "Skipping the user setup... "
else
    useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername 1> /dev/null 2>&1
    echo "User setup was concluded... " 

    echo "Now set a password"
    passwd $systemUsername
    echo "Password setup was a success... "

    read -p "Press enter when ready... "
    clear
fi

## Sudo Setup
read -p "Setup sudo? (Y/n) " setupSudo
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
    clear
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
    sudo -u $systemUsername git clone https://aur.archlinux.org/yay.git 1> /dev/null 2>&1
    echo "Yay repository cloned... "

    cd yay
    echo -e "\n" | sudo -u $systemUsername makepkg -si 1> /dev/null 2>&1
    echo "Yay installed... "

    cd /home/$systemUsername/Downloads
    rm -r yay
    clear
fi
clear


## Setup git
echo "+++++ Setup git +++++"
read -p "Setup git config? (Y/n) " setupGit
if [ "$setupGit" == "n" ]; then
    echo "Skipping git config setup... "
else
    read -p "What is your git user? " gituser
    sudo -u $systemUsername git config --global user.name "$gituser"
    echo "Git username setup was successful... "

    read -p "What is your git email? " gitmail
    sudo -u $systemUsername git config --global user.email "$gitmail"
    echo "Git mail setup was successful... "
fi

read -p "Setup ssh key on git? (Y/n) " setupSshKey
if [ "$setupSshKey" == "n" ]; then
    echo "Skipping the setup of the ssh key on git... "
else
    sudo -u $systemUsername ssh-keygen -t ed25519 -C "$gitmail" -f /home/$systemUsername/.ssh/id_ed25519 -N "" 1> /dev/null 2>&1
    echo "The generation of the ssh key was a success... "

    echo "Copy the following key to your git and add this to the ssh keys"
    cat /home/$systemUsername/.ssh/id_ed25519.pub
    read -p "Press enter when you finished... "
    clear
fi


## Nvim 
echo "+++++ Setup neovim +++++"
read -p "Setup neovim? (Y/n) " setupNeovim
if [ "$setupNeovim" == "n" ]; then echo "Skipping neovim setup... "
else 
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Nvim-Settings.git 1> /dev/null 2>&1
    echo "Cloning neovim settings repository... "

    mv Nvim-Settings /home/$systemUsername/.config/nvim
    echo "Neovim installed... "
fi


## Hyprland
echo "+++++ Setup hyprland +++++"
read -p "Setup hyprland? (Y/n) " setupHyrland
if [ "$setupHyrland" == "n" ]; then
    echo "Skipping hyprland setup... "
else
    cd /home/$systemUsername/Downloads
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Hyprland-Settings.git 1> /dev/null 2>&1
    echo "Cloning the hyprland settings repository... "

    cd Hyprland-Settings
    mv hypr waybar wofi /home/$systemUsername/.config/
    echo "The setup of hyprland settings was a success... "

    cd /home/$systemUsername/Downloads
    rm -r Hyrland-Settings
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
        clear
    else
        echo "Skipping wayland nvidia setup... "
    fi
fi
clear



read -p "Press enter to reboot the system... "
reboot
