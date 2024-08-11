#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? (Y/n) " startInstall
if [ "$startInstall" == "n" ]; then
    exit
fi

## Has nvidia GPU
read -p "Do you have a nvidia GPU? (y/N) " hasNvidia
clear

# Packages setup
## Pacman
echo "The pacman setup is needed for the rest of the system to work! just skip if you already had done!"
read -p "Start pacman setup? (Y/n)" pacmanSetup
if [ "$pacmanSetup" == "n" ]; then
    echo -e "Skipping pacman setup... \n"
else
    echo "+++++ Setup pacman +++++"
    echo "Edit the /etc/pacman.conf and uncomment the line"
    echo "====----------------------===="
    echo "ParallelDownloads = 5"
    echo "Edit the lines to include multilib repository"
    echo -e "====----------------------====\n"
    read -p "Press enter to go to the file... "
    nvim /etc/pacman.conf
    clear
fi

## Update the system
echo "" | pacman -Sy  1> /dev/null 2>&1
echo "Repository updated... "
echo "" | pacman -Su  1> /dev/null 2>&1
echo -e "System upgraded...\n"

## Nvidia GPU
if [ "$hasNvidia" == "y" ]; then
    echo -e "\n" | pacman -S nvidia nvidia-utils lib32-nvidia-utils 1> /dev/null 2>&1
    echo "Nvidia packages installed... "
fi

## System base packages
echo "" | pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluez alsa-utils sudo networkmanager dhcpcd bluez 1> /dev/null 2>&1
echo "System base packages installed... "

## Theme
echo -e "\n" | pacman -S gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty egl-wayland 1> /dev/null 2>&1
echo "Theme packages installed... "

## Basic tools 
echo "" | pacman -S git neovim wl-clipboard openssh base-devel 1> /dev/null 2>&1
echo "Basic tools installed... "
sleep 1
clear

## User preference tools
read -p "Start user preference tool installer? (Y'es/n'o/a'll) " installUserPreference
packagesToInstall=("tmux" "yazi" "bashtop" "docker" "dbeaver" "man" "neovim" "git" "firefox" "torbrowser-launcher" "python" "python3" "nodejs" "jdk-openjdk" "gcc" "postgresql" "libreoffice" "audacity" "gimp" "obs-studio")
lengthPackages=${#packagesToInstall[@]}

if [ "$installUserPreference" == "n" ]; then
    echo -e "Skipping the user preference tool installer... \n"

elif [ "$installUserPreference" == 'a' ]; then
    echo -e "Installing all default packages... \n"
    for ((i=0; i<$lengthPackages; i++)); do
        echo -e "\n" | pacman -S ${packagesToInstall[$i]}
        sleep 1
        clear

        echo "${packagesToInstall[$i]} Installed... "
        sleep 1
        clear
    done

else
    for ((i=0; i<$lengthPackages; i++)); do
        read -p "Install ${packagesToInstall[$i]}? (y/N) " temp
        if [ "$temp" == "y" ]; then
            echo -e "\n" | pacman -S ${packagesToInstall[$i]}
            sleep 1
            clear

            echo "${packagesToInstall[$i]} Installed... "
            sleep 1
            clear
        fi 
    done
fi



# Enable processes
systemctl enable --now bluetooth NetworkManager dhcpcd 1> /dev/null 2>&1
echo -e "Bluetooth and network enabled... \n"
sleep 1



# System user setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

read -p "Setup new user? (Y/n) " setupUser
if [ "$setupUser" == "n" ]; then
    echo -e "Skipping the user setup... \n"
else
    useradd -m -g users -G wheel,storage,power -s /bin/bash $systemUsername 1> /dev/null 2>&1
    echo -e "User setup was concluded... \n"

    read -p "Now set a password: " -s userPassword
    echo ""
    read -p "Repeat the password: " -s repeatPassword
    echo ""

    while [ $userPassword != $repeatPassword ]
    do
        echo "The passwords don't match... try again... "
        read -p "Set a password: " -s userPassword
        echo ""
        read -p "Repeat the password: " -s repeatPassword
        echo ""
    done

    echo "$systemUsername:$userPassword" | sudo chpasswd
    echo -e "Password setup was a success... \n"

    read -p "Press enter when ready... "
    clear
fi

## Sudo Setup
read -p "Setup sudo? (Y/n) " setupSudo
if [ "$setupSudo" == "n" ]; then
    echo -e "Skipping sudo setup... \n"
else
    echo "Now open /etc/sudoers and edit the line and remove the # before the line"
    echo "====----------------------===="
    echo "#%wheel ALL=(ALL:ALL) ALL"
    echo -e "====----------------------====\n"
    read -p "Press enter when ready... "
    nvim /etc/sudoers
    clear
fi

## Basic directiories
echo -e "+++++ Setup basic directiories +++++"
read -p "Setup basic directiories? (Y/n) " setupBasicDirectories
if [ "$setupBasicDirectories" == "n" ]; then
    echo -e "Skipping basic directories setup... \n"
else 
    cd /home/$systemUsername
    sudo -u $systemUsername mkdir Downloads Documents Pictures Commands Code .ssh .config
    clear
fi



# Setup basic settings
## TODO SETUP FONTS

## TODO SETUP SCRIPTS IN THE COMMANDS FOLDER IN THE ".bashrc" with easy call

## Setup yay
read -p "Start yay installer? (Y/n) " installYay
if [ "$installYay" == "n" ]; then
    echo -e "Skipping the yay setup... \n"
else 
    echo "Setting up yay... "
    cd /home/$systemUsername/Downloads
    sudo -u $systemUsername git clone https://aur.archlinux.org/yay.git 1> /dev/null 2>&1
    echo "Yay repository cloned... "

    cd yay
    sudo -u $systemUsername makepkg -si
    clear
    echo "Yay installed... "
    sleep 1

    cd /home/$systemUsername/Downloads
    rm -r yay
    clear
fi


## Setup git
echo "+++++ Setup git +++++"
read -p "Setup git config? (Y/n) " setupGit
if [ "$setupGit" == "n" ]; then
    echo -e "Skipping git config setup... \n"
else
    read -p "What is your git user? " gituser
    sudo -u $systemUsername git config --global user.name "$gituser"
    echo -e "Git username setup was successful... \n"

    read -p "What is your git email? " gitmail
    sudo -u $systemUsername git config --global user.email "$gitmail"
    echo -e "Git mail setup was successful... \n"
fi

read -p "Setup ssh key on git? (Y/n) " setupSshKey
if [ "$setupSshKey" == "n" ]; then
    echo -e "Skipping the setup of the ssh key on git... \n"
else
    sudo -u $systemUsername ssh-keygen -t ed25519 -C "$gitmail" -f /home/$systemUsername/.ssh/id_ed25519 -N "" 1> /dev/null 2>&1
    echo -e "The generation of the ssh key was a success... \n"

    echo "Copy the following key to your git and add this to the ssh keys"
    cat /home/$systemUsername/.ssh/id_ed25519.pub
    read -p "Press enter when you finished... "
    clear
fi


## Nvim 
echo "+++++ Setup neovim +++++"
read -p "Setup neovim? (Y/n) " setupNeovim
if [ "$setupNeovim" == "n" ]; then 
    echo -e "Skipping neovim setup... \n"
else 
    sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Nvim-Settings.git 1> /dev/null 2>&1
    echo "Cloning neovim settings repository... "

    mv Nvim-Settings /home/$systemUsername/.config/nvim
    echo "Neovim installed... "
    sleep 1
    clear
fi


## Hyprland
echo -e "+++++ Setup hyprland +++++\n"
read -p "Setup hyprland? (Y/n) " setupHyrland
if [ "$setupHyrland" == "n" ]; then
    echo -e "Skipping hyprland setup... \n"
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

    ### Hyprland, waybar and hyprpaper setup
    cd /home/$systemUsername/.config/
    echo "+++++ Setup hyprland monitors +++++"
    echo "Edit the hypr/hyprland.conf file and change this line there with your monitors: "
    echo "====----------------------===="
    echo "monitor=MONITORPORT,preferred,0x0,auto"
    echo -e "====----------------------====\n"
    echo "You can find your monitor or monitors ports here" 
    sleep 1
    xrandr
    read -p "press enter when you are ready... "
    nvim hypr/hyprland.conf
    clear
   
    echo "Edit the hypr/hyprpaper.conf file and change this line to set your wallpaper: "
    echo "====----------------------===="
    echo "wallpaper = MONITORPORT,~/.config/hypr/wallpaper/wallpaper1.jpg"
    echo -e "====----------------------====\n"
    echo "You can find your monitor or monitors ports here" 
    sleep 1
    xrandr
    read -p "press enter when you are ready... "
    nvim hypr/hyprpaper.conf
    clear

    echo "Edit the waybar/config file and change this to set the width of your bar: "
    echo "====----------------------===="
    echo '"width": the_width_of_your_monitor'
    echo -e "====----------------------====\n"
    echo "You can find the width of your monitor here" 
    sleep 1
    xrandr
    read -p "press enter when you are ready... "
    nvim waybar/config
    clear

    ### Nvidia
    if [ "$hasNvidia" == "y" ]; then
        echo "+++++ Setup nvidia for hyprland +++++"
        echo "Edit the /etc/mkinitcpio.conf file and add this line there: "
        echo "====----------------------===="
        echo "MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)"
        echo -e "====----------------------====\n"
        read -p "Press enter when you are ready... "
        nvim /etc/mkinitcpio.conf
        clear

        echo "Now edit the /etc/modprobe.d/nvidia.conf and add this line there: "
        echo "====----------------------===="
        echo "options nvidia_drm modeset=1 fbdev=1"
        echo -e "====----------------------====\n"
        read -p "Press enter when you are ready... "
        nvim /etc/modprobe.d/nvidia.conf
        clear

        mkinitcpio -P
        clear
    else
        echo -e "Skipping wayland nvidia setup... \n"
    fi
fi
clear



read -p "Press enter to reboot the system... "
reboot
