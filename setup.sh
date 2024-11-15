#!/bin/bash
echo "Run this program as root"
read -p "Start the instalation? (Y/n) " startInstall
if [ "$startInstall" == "n" ]; then
    exit
fi

## Has nvidia GPU
read -p "Do you have a nvidia GPU? (y/N) " hasNvidia
clear



# Enable processes
echo "+++++ Enable Processes +++++"
processesToEnable=(
    "bluetooth"
    "NetworkManager"
    "dhcpcd"
)
lengthProcesses=${#processesToEnable[@]}

for ((i=0; i<$lengthProcesses; i++)) do
    systemctl enable --now ${processesToEnable[$i]} 1> /dev/null 2>&1
    echo "${processesToEnable[$i]} enabled... "
    sleep 1
done
clear

# Setup basic settings
echo -e "+++++ Setup basic settings +++++"
echo "Setting up the time... \n"
timedatectl set-timezone America/Sao_Paulo



# Packages setup
## Pacman
echo "+++++ Setup pacman +++++"
echo "Edit the /etc/pacman.conf and uncomment the line"
echo "====----------------------===="
echo "ParallelDownloads = 5"
echo "Edit the lines to include multilib repository"
echo -e "====----------------------====\n"
read -p "Press enter to go to the file... "
nvim /etc/pacman.conf
clear

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
echo "" | pacman -S pulseaudio pulseaudio-alsa alsa-utils sudo networkmanager dhcpcd bluez wget curl go 1> /dev/null 2>&1
echo "System base packages installed... " ## Theme
echo -e "\n" | pacman -S gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty egl-wayland pavucontrol hyprlock 1> /dev/null 2>&1
echo "Theme packages installed... "

## Basic tools 
echo "" | pacman -S wl-clipboard openssh base-devel zip unzip 1> /dev/null 2>&1
echo "Basic tools installed... "
sleep 1
clear

## User preference tools
read -p "Start user preference tool installer? (Y'es/n'o/a'll) " installUserPreference
packagesToInstall=(
    "tmux" "yazi" "bashtop"
    "docker" "dbeaver" "man" "neovim" "git" "qbittorrent"
    "firefox" "torbrowser-launcher"
    "python" "python3" "nodejs" "jdk-openjdk" "gcc" "postgresql"
    "libreoffice" "audacity" "gimp" "obs-studio" "vlc" "loupe"
)
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
    clear

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
    clear
fi



# System user setup
echo "+++++ Setup system user +++++"
read -p "What is your username? " systemUsername

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

## Sudo Setup
echo -e "+++++ Sudo settings +++++"
echo "Now open /etc/sudoers and edit the line and remove the # before the line"
echo "====----------------------===="
echo "#%wheel ALL=(ALL:ALL) ALL"
echo -e "====----------------------====\n"
read -p "Press enter when ready... "
nvim /etc/sudoers
clear

## Basic directiories
echo -e "+++++ Setup basic directiories +++++"
cd /home/$systemUsername
sudo -u $systemUsername mkdir Downloads Documents Pictures Commands Code .ssh .config
clear



## Setup nerd fonts
echo "Setting up the nerdfonts... "
cd /home/$systemUsername/Downloads
sudo -u $systemUsername wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/3270.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/NerdFontsSymbolsOnly.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Ubuntu.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" 1> /dev/null 2>&1
for fileToUnzip in *.zip; do
    unzip -o "$fileToUnzip" -d /usr/share/fonts/ 1> /dev/null 2>&1
    rm "$fileToUnzip"
done
echo -e "NerdFonts installed... \n"


## Setup .bashrc
echo "Setting up .bashrc... "
cd /home/$systemUsername
commandList=(
    "alias mountEx='sudo mount /dev/sda1 /mnt/Extra'"
    "alias vma='virsh snapshot-revert ArchLinux Clean; virsh start ArchLinux; sleep 1; remote-viewer -f spice://localhost:5900'"
    "alias ls='ls --color=auto'"
    "alias grep='grep --color=auto'"
    "alias cl='clear'"

    "alias ..='cd ..'"
    "alias ...='cd ../..'"
    "alias ....='cd ../../..'"
    "alias config='cd ~/.config/'"
    "alias bashrc='nvim ~/.bashrc'"
    "alias code='cd ~/Code'"

    "alias gs='git status'"
    "alias ga='git add .'"
    "alias gc='git commit -m'"
    "alias gp='git push'"
    "alias gpl='git pull'"
    "alias gw='git switch'"
    "alias gwm='git switch main'"
    "alias gl='git log --oneline --graph --decorate'"
    "alias gd='git diff'"
    "alias gds='git diff --staged'"

    "alias dkc='docker system prune -a'"
    "alias dcu='docker compose up'"
    "alias dcd='docker compose down'"
    "alias db='docker build .'"

    "alias update='sudo pacman -Syu && yay -Syu --devel'"
    "alias refresh='source ~/.bashrc'"

    "export EDITOR=/usr/bin/nvim"
    "PS1='\[\e[32m\]>> \[\e[34m\]\w \[\e[31m\]$\[\e[0m\] '"

    "source /usr/share/git/completion/git-completion.bash"
)
lengthCommandList=${#commandList[@]}

for ((i=0; i<$lengthCommandList; i++)) do
    echo ${commandList[$i]} >> .bashrc
    echo "${commandList[$i]} - was installed... "
done
echo ""


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


    ## Aur packages installer
    read -p "Start aur packages installer? (Y/n) " installAurPackages
    aurPackagesToInstall=(
        "google-chrome"
    )
    lengthPackagesAur=${#aurPackagesToInstall[@]}

    if [ "$installAurPackages" == "n" ]; then
        echo -e "Skipping the aur packages installer... \n"

    else
        for ((i=0; i<$lengthPackagesAur; i++)); do
            read -p "Install ${aurPackagesToInstall[$i]}? (y/N) " temp
            if [ "$temp" == "y" ]; then
                sudo -u systemUsername yay -S ${aurPackagesToInstall[$i]}
                sleep 1
                clear
    
                echo "${aurPackagesToInstall[$i]} Installed... "
                sleep 1
                clear
            fi 
        done
        clear
    fi
fi


## Setup git
echo "+++++ Setup git +++++"
read -p "What is your git user? " gituser
sudo -u $systemUsername git config --global user.name "$gituser"
echo -e "Git username setup was successful... \n"

read -p "What is your git email? " gitmail
sudo -u $systemUsername git config --global user.email "$gitmail"
echo -e "Git mail setup was successful... \n"

### Setup ssh key
read -p "Setup ssh key on git? (Y/n) " setupSshKey
if [ "$setupSshKey" == "n" ]; then
    echo -e "Skipping the setup of the ssh key on git... \n"
else
    sudo -u $systemUsername ssh-keygen -t ed25519 -C "$gitmail" -f /home/$systemUsername/.ssh/id_ed25519 -N "" 1> /dev/null 2>&1
    echo -e "The generation of the ssh key was a success... \n"

    echo "Copy the following key to your git and add this to the ssh keys"
    cat /home/$systemUsername/.ssh/id_ed25519.pub
    read -p "Press enter when you finished... "
fi
clear


## Workspace setup
echo -e "+++++ Setup workspace +++++\n"
cd /home/$systemUsername/Downloads
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Hyprland-Settings.git 1> /dev/null 2>&1
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Wofi-Settings.git 1> /dev/null 2>&1
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Waybar-Settings.git 1> /dev/null 2>&1
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Yazi-Settings.git 1> /dev/null 2>&1
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Kitty-Settings.git 1> /dev/null 2>&1
sudo -u $systemUsername git clone https://github.com/Matheus-Ei/Nvim-Settings.git 1> /dev/null 2>&1
echo "Cloning settings repository... "

mv Hyprland-Settings /home/$systemUsername/.config/hypr
mv Wofi-Settings /home/$systemUsername/.config/wofi
mv Waybar-Settings /home/$systemUsername/.config/waybar
mv Yazi-Settings /home/$systemUsername/.config/yazi
mv Kitty-Settings /home/$systemUsername/.config/kitty
mv Nvim-Settings /home/$systemUsername/.config/nvim
echo "The setup of the settings repos was a success... "
clear

### Monitor setup
cd /home/$systemUsername/.config/
export DISPLAY=:0
echo "+++++ Setup hyprland monitors +++++"
echo "Edit the hypr/hyprland.conf file and change this line there with your monitors: "
echo "====----------------------===="
echo "monitor=MONITORPORT,preferred,0x0,auto"
echo -e "====----------------------====\n"
echo "You can find your monitor or monitors ports here" 
sleep 1
xrandr --listmonitors
read -p "press enter when you are ready... "
nvim hypr/hyprland.conf
clear
   
echo "Edit the waybar/config file and change this to set the width of your bar: "
echo "====----------------------===="
echo '"width": the_width_of_your_monitor'
echo -e "====----------------------====\n"
echo "You can find the width of your monitor here" 
sleep 1
xrandr --listmonitors
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
clear



# Setup virtual machine manager KVM
read -p "Setup the virtual machine manager KVM? (y/N) " setupKvm
if [ "$setupKvm" == "y" ]; then
    ## Install QEMU, libvirt, viewers and tools
    echo "Installing QEMU, libvirt viewers and tools... "
    echo -e "\n" | pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf swtpm guestfs-tools libosinfo firewalld dnsmasq

    echo -e "\nInstalling tuned with yay... "
    sudo -u $systemUsername yay -S tuned
    clear
    
    ## Enable monolithic daemon
    systemctl enable --now libvirtd.service firewalld
    virsh net-autostart --network default

    ## Enable Iommu
    echo "Now edit the /etc/default/grub and add these words in the GRUB_CMDLINE_LINUX: "
    echo -e "====----------------------===="
    echo "GRUB_CMDLINE_LINUX='... amd_iommu=on iommu=pt'"
    echo -e "====----------------------====\n"
    read -p "Press enter when you are ready... "
    nvim /etc/default/grub
    clear

    grub-mkconfig -o /boot/grub/grub.cfg
    clear

    ## Enable SEV using GRUB
    echo "options kvm_amd sev=1" >> /etc/modprobe.d/amd-sev.conf

    ## Enable host with tuned
    systemctl enable --now tuned.service
    tuned-adm profile virtual-host

    ## Add user to the libvirt group
    usermod -aG libvirt $systemUsername

    ## Set libvirt default uri
    echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc
    virsh uri

    ## Change ACL permissions to the current user
    setfacl -R -b /var/lib/libvirt/images/
    setfacl -R -m u:${systemUsername}:rwX /var/lib/libvirt/images/
    setfacl -m d:u:${systemUsername}:rwx /var/lib/libvirt/images/

    echo -e "KVM virtual machine manager was installed... \n"
    sleep 1
    clear
else
    echo -e "Skipping KVM vitual machine setup... \n"
fi



read -p "Press enter to reboot the system... "
reboot
