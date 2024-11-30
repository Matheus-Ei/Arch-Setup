#!/bin/bash

clear
echo -e "\e[1;32mRun this program as root\e[0m"
read -p "Start the installation? (Y/n) " startInstall
if [[ "$startInstall" == "n" || "$startInstall" == "N" ]]; then
    exit
fi

## Has Nvidia GPU
read -p "Do you have a nvidia GPU? (y/N) " hasNvidia
clear

# Enable processes
echo -e "\n\e[1;34m+++++ Enable Processes +++++\e[0m"
processesToEnable=(
    "NetworkManager"
    "dhcpcd"
)
for process in "${processesToEnable[@]}"; do
    systemctl enable --now "$process" 1> /dev/null 2>&1
    echo -e "\e[1;32m$process enabled...\e[0m"
    sleep 1
done
clear

# Setup basic settings
echo -e "\n\e[1;34m+++++ Setup basic settings +++++\e[0m"
echo "Setting up the time... \n"
timedatectl set-timezone America/Sao_Paulo
clear

# Packages setup
## Pacman
echo -e "\n\e[1;34m+++++ Setup pacman +++++\e[0m"
echo "Edit the /etc/pacman.conf and uncomment the line"
echo "====----------------------===="
echo "ParallelDownloads = 5"
echo "Edit the lines to include multilib repository"
echo -e "====----------------------====\n"
read -p "Press enter to go to the file... "
nvim /etc/pacman.conf
clear

## Update the system
pacman -Sy --noconfirm 1> /dev/null 2>&1
echo -e "\e[1;32mRepository updated...\e[0m"
pacman -Su --noconfirm 1> /dev/null 2>&1
echo -e "\e[1;32mSystem upgraded...\e[0m\n"

sleep 1
clear

## Nvidia GPU
if [[ "$hasNvidia" == "y" || "$hasNvidia" == "Y" ]]; then
    echo -e "\n" | pacman -S nvidia nvidia-utils lib32-nvidia-utils 1> /dev/null 2>&1
    echo -e "\e[1;32mNvidia packages installed...\e[0m"
fi

## System base packages
pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-utils sudo networkmanager dhcpcd bluez wget curl go ifuse 1> /dev/null 2>&1
echo -e "\e[1;32mSystem base packages installed...\e[0m"

## Theme
pacman -S --noconfirm gnome-themes-extra hyprland gtk4 hyprpaper waybar wofi kitty egl-wayland pavucontrol hyprlock 1> /dev/null 2>&1
echo -e "\e[1;32mTheme packages installed...\e[0m"

## Basic tools
pacman -S --noconfirm wl-clipboard openssh base-devel zip unzip 1> /dev/null 2>&1
echo -e "\e[1;32mBasic tools installed...\e[0m"

sleep 1
clear

## User preference tools
read -p "Start user preference tool installer? (Y'es/n'o/a'll) " installUserPreference
packagesToInstall=(
    "tmux" "yazi" "bashtop"
    "docker" "dbeaver" "man" "neovim" "git" "qbittorrent"
    "firefox" "torbrowser-launcher"
    "python3" "python-pip" "nodejs" "npm" "jdk-openjdk" "gcc" "postgresql"
    "libreoffice" "audacity" "gimp" "obs-studio" "vlc" "loupe"
)
if [[ "$installUserPreference" == "n" || "$installUserPreference" == "N" ]]; then
    echo -e "\e[1;33mSkipping the user preference tool installer...\e[0m\n"
elif [[ "$installUserPreference" == "a" || "$installUserPreference" == "A" ]]; then
    echo -e "\e[1;32mInstalling all default packages...\e[0m\n"
    pacman -S --noconfirm "${packagesToInstall[@]}" 1> /dev/null 2>&1
    clear
    echo -e "\e[1;32mAll user preference packages installed...\e[0m"
else
    for pkg in "${packagesToInstall[@]}"; do
        read -p "Install $pkg? (y/N) " temp
        if [[ "$temp" == "y" || "$temp" == "Y" ]]; then
            pacman -S --noconfirm "$pkg" 1> /dev/null 2>&1
            echo -e "\e[1;32m$pkg Installed...\e[0m"
            sleep 1
        fi
    done
    clear
fi

# System user setup
echo -e "\n\e[1;34m+++++ Setup system user +++++\e[0m"
read -p "What is your username? " systemUsername

useradd -m -g users -G wheel,storage,power -s /bin/bash "$systemUsername" 1> /dev/null 2>&1
echo -e "\e[1;32mUser setup was concluded...\e[0m\n"

read -p "Now set a password: " -s userPassword
echo ""
read -p "Repeat the password: " -s repeatPassword
echo ""

while [[ "$userPassword" != "$repeatPassword" ]]; do
    echo -e "\e[1;31mThe passwords don't match... try again...\e[0m"
    read -p "Set a password: " -s userPassword
    echo ""
    read -p "Repeat the password: " -s repeatPassword
    echo ""
done

echo "$systemUsername:$userPassword" | sudo chpasswd
echo -e "\e[1;32mPassword setup was a success...\e[0m\n"

read -p "Press enter when ready... "

## Sudo Setup
echo -e "\n\e[1;34m+++++ Sudo settings +++++\e[0m"
echo "Now open /etc/sudoers and edit the line and remove the # before the line"
echo "====----------------------===="
echo "#%wheel ALL=(ALL:ALL) ALL"
echo -e "====----------------------====\n"
read -p "Press enter when ready... "
nvim /etc/sudoers
clear

## Basic directories
echo -e "\n\e[1;34m+++++ Setup basic directories +++++\e[0m"
cd /home/"$systemUsername"
sudo -u "$systemUsername" mkdir Downloads Documents Pictures Commands Code .ssh .config

## Setup nerd fonts
echo -e "\n\e[1;34mSetting up the nerd fonts... \e[0m"
cd /home/"$systemUsername"/Downloads
sudo -u "$systemUsername" wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/3270.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/NerdFontsSymbolsOnly.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Ubuntu.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
for fileToUnzip in *.zip; do
    unzip -o "$fileToUnzip" -d /usr/share/fonts/ 1> /dev/null 2>&1
    rm "$fileToUnzip"
done
echo -e "\e[1;32mNerdFonts installed...\e[0m\n"
clear

## Setup .bashrc
echo -e "\n\e[1;34mSetting up .bashrc... \e[0m"
cd /home/"$systemUsername"
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
    "alias update='sudo pacman -Syu --noconfirm && yay -Syu --noconfirm --devel'"
    "alias refresh='source ~/.bashrc'"
    "export EDITOR=/usr/bin/nvim"
    "PS1='\[\e[32m\]>> \[\e[34m\]\w \[\e[31m\]$\[\e[0m\] '"
    "source /usr/share/git/completion/git-completion.bash"
)

for cmd in "${commandList[@]}"; do
    echo "$cmd" >> .bashrc
    echo -e "\e[1;32m$cmd - was installed...\e[0m"
done
sleep 1
clear

## Setup yay
read -p "Start yay installer? (Y/n) " installYay
if [[ "$installYay" == "n" || "$installYay" == "N" ]]; then
    echo -e "\e[1;33mSkipping the yay setup...\e[0m\n"
else
    echo -e "\n\e[1;34mSetting up yay... \e[0m"
    cd /home/"$systemUsername"/Downloads
    sudo -u "$systemUsername" git clone https://aur.archlinux.org/yay.git 1> /dev/null 2>&1
    clear
    echo -e "\e[1;32mYay repository cloned...\e[0m "

    cd yay
    sudo -u "$systemUsername" makepkg -si 1> /dev/null 2>&1
    clear
    echo -e "\e[1;32mYay installed...\e[0m"
    sleep 1

    cd /home/"$systemUsername"/Downloads
    rm -r yay

    ## Aur packages installer
    read -p "Start aur packages installer? (Y/n) " installAurPackages
    aurPackagesToInstall=(
        "google-chrome"
    )

    if [[ "$installAurPackages" == "n" || "$installAurPackages" == "N" ]]; then
        echo -e "\e[1;33mSkipping the aur packages installer...\e[0m\n"
    else
        for pkg in "${aurPackagesToInstall[@]}"; do
            read -p "Install $pkg? (y/N) " temp
            if [[ "$temp" == "y" || "$temp" == "Y" ]]; then
                sudo -u "$systemUsername" yay -S --noconfirm "$pkg" 1> /dev/null 2>&1
                echo -e "\e[1;32m$pkg Installed...\e[0m"
                sleep 1
                clear
            fi
        done
    fi
fi
clear

## Setup flatpak
read -p "Start flatpak installer? (Y/n) " installFlatpak

if [[ "$installFlatpak" == "n" || "$installFlatpak" == "N" ]]; then
    echo -e "\e[1;33mSkipping the flatpak setup...\e[0m\n"
else
    echo -e "\n\e[1;34mSetting up flatpak... \e[0m"
    
    pacman -S --noconfirm flatpak 1> /dev/null 2>&1
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "\e[1;32mFlatpak installed...\e[0m\n"

    read -p "Start flatpak packages installer? (Y/n) " installFlatpakPackages

    flatpakPackagesToInstall=(
        "com.getpostman.Postman"
    )

    if [[ "$installFlatpakPackages" == "n" || "$installFlatpakPackages" == "N" ]]; then
        echo -e "\e[1;33mSkipping the flatpak packages installer...\e[0m\n"
    else
        for pkg in "${flatpakPackagesToInstall[@]}"; do
            read -p "Install $pkg? (y/N) " temp
            if [[ "$temp" == "y" || "$temp" == "Y" ]]; then
                echo -e "\nInstalling $pkg..."
                flatpak install -y flathub "$pkg" 1> /dev/null 2>&1
                echo -e "\e[1;32m$pkg Installed...\e[0m\n"
            else
                echo -e "\e[1;33mSkipping $pkg...\e[0m\n"
            fi
        done
    fi
fi

## Setup docker
read -p "Start docker setup? (Y/n) " setupDocker
if [[ "$setupDocker" == "n" || "$setupDocker" == "N" ]]; then
    echo -e "\e[1;33mSkipping the docker setup...\e[0m\n"
else
    echo -e "\n\e[1;34mSetting up docker... \e[0m"
    pacman -S --noconfirm docker 1> /dev/null 2>&1
    systemctl enable --now docker.service
    usermod -aG docker "$systemUsername"
    echo -e "\e[1;32mDocker installed...\e[0m\n"

    sleep 1
    clear
fi

## Setup Wine
read -p "Start wine setup? (Y/n) " setupWine
if [[ "$setupWine" == "n" || "$setupWine" == "N" ]]; then
    echo -e "\e[1;33mSkipping the wine setup...\e[0m\n"
else
    echo -e "\n\e[1;34mSetting up wine... \e[0m"
    pacman -S --noconfirm wine wine-mono wine_gecko winetricks 1> /dev/null 2>&1
    winecfg
    echo -e "\e[1;32mWine installed...\e[0m\n"

    sleep 1
    clear
fi

## Setup games
read -p "Start games setup? (Y/n) " setupGames
if [[ "$setupGames" == "n" || "$setupGames" == "N" ]]; then
    echo -e "\e[1;33mSkipping the games setup...\e[0m\n"
else
    echo -e "\n\e[1;34mSetting up games... \e[0m"
    pacman -S --noconfirm steam 1> /dev/null 2>&1

    # CurseForge
    sudo -u "$systemUsername" wget -q "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip" 1> /dev/null 2>&1
    unzip -o curseforge-latest-linux.zip -d /home/"$systemUsername"/Documents/
    rm curseforge-latest-linux.zip
    mv /home/"$systemUsername"/Documents/build/* /home/"$systemUsername"/Documents/CurseForge
    rmdir /home/"$systemUsername"/Documents/build
    echo -e "\e[1;32mGames installed...\e[0m\n"

    sleep 1
    clear
fi

## Setup git
echo -e "\n\e[1;34m+++++ Setup git +++++\e[0m"
read -p "What is your git user? " gituser
sudo -u "$systemUsername" git config --global user.name "$gituser"
echo -e "\e[1;32mGit username setup was successful...\e[0m\n"

read -p "What is your git email? " gitmail
sudo -u "$systemUsername" git config --global user.email "$gitmail"
echo -e "\e[1;32mGit mail setup was successful...\e[0m\n"

### Setup ssh key
read -p "Setup ssh key on git? (Y/n) " setupSshKey
if [[ "$setupSshKey" == "n" || "$setupSshKey" == "N" ]]; then
    echo -e "\e[1;33mSkipping the setup of the ssh key on git...\e[0m\n"
else
    sudo -u "$systemUsername" ssh-keygen -t ed25519 -C "$gitmail" -f /home/"$systemUsername"/.ssh/id_ed25519 -N "" 1> /dev/null
    echo -e "\e[1;32mThe generation of the ssh key was a success...\e[0m\n"

    echo "Copy the following key to your git and add this to the ssh keys"
    cat /home/"$systemUsername"/.ssh/id_ed25519.pub
    read -p "Press enter when you finished... "
    clear
fi

## Workspace setup
echo -e "\n\e[1;34m+++++ Setup workspace +++++\e[0m\n"
cd /home/"$systemUsername"/Downloads
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Hyprland-Settings.git 1> /dev/null 2>&1
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Wofi-Settings.git 1> /dev/null 2>&1
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Waybar-Settings.git 1> /dev/null 2>&1
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Yazi-Settings.git 1> /dev/null 2>&1
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Kitty-Settings.git 1> /dev/null 2>&1
sudo -u "$systemUsername" git clone https://github.com/Matheus-Ei/Nvim-Settings.git 1> /dev/null 2>&1
echo -e "\e[1;32mCloning settings repository...\e[0m"
sleep 1
clear

mv Hyprland-Settings /home/"$systemUsername"/.config/hypr
mv Wofi-Settings /home/"$systemUsername"/.config/wofi
mv Waybar-Settings /home/"$systemUsername"/.config/waybar
mv Yazi-Settings /home/"$systemUsername"/.config/yazi
mv Kitty-Settings /home/"$systemUsername"/.config/kitty
mv Nvim-Settings /home/"$systemUsername"/.config/nvim
echo -e "\e[1;32mThe setup of the settings repos was a success...\e[0m"
sleep 1
clear

### Monitor setup
cd /home/"$systemUsername"/.config/
export DISPLAY=:0
echo -e "\n\e[1;34m+++++ Setup hyprland monitors +++++\e[0m"
echo "Edit the hypr/hyprland.conf file and change this line there with your monitors: "
echo "====----------------------===="
echo "monitor=MONITORPORT,preferred,0x0,auto"
echo -e "====----------------------====\n"
echo "You can find your monitor or monitors ports here" 
sleep 1
xrandr --listmonitors
read -p "Press enter when you are ready... "
nvim hypr/hyprland.conf
clear

echo "Edit the waybar/config file and change this to set the width of your bar: "
echo "====----------------------===="
echo '"width": the_width_of_your_monitor'
echo -e "====----------------------====\n"
echo "You can find the width of your monitor here" 
sleep 1
xrandr --listmonitors
read -p "Press enter when you are ready... "
nvim waybar/config
clear

### Nvidia setup
if [[ "$hasNvidia" == "y" || "$hasNvidia" == "Y" ]]; then
    echo -e "\n\e[1;34m+++++ Setup nvidia for hyprland +++++\e[0m"
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
else
    echo -e "Skipping wayland nvidia setup... \n"
fi

# Setup virtual machine manager KVM
read -p "Setup the virtual machine manager KVM? (y/N) " setupKvm
if [[ "$setupKvm" == "y" || "$setupKvm" == "Y" ]]; then
    ## Install QEMU, libvirt, viewers and tools
    echo -e "\n\e[1;34mInstalling QEMU, libvirt viewers and tools... \e[0m"
    pacman -S --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf swtpm guestfs-tools libosinfo firewalld dnsmasq 1> /dev/null 2>&1
    clear

    echo -e "\nInstalling tuned with yay... "
    sudo -u "$systemUsername" yay --noconfirm -S tuned 1> /dev/null 2>&1
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
    usermod -aG libvirt "$systemUsername"

    ## Set libvirt default uri
    echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc
    virsh uri

    ## Change ACL permissions to the current user
    setfacl -R -b /var/lib/libvirt/images/
    setfacl -R -m u:"$systemUsername":rwX /var/lib/libvirt/images/
    setfacl -m d:u:"$systemUsername":rwx /var/lib/libvirt/images/

    clear
    echo -e "\e[1;32mKVM virtual machine manager was installed...\e[0m\n"
    sleep 1
else
    echo -e "\e[1;33mSkipping KVM virtual machine setup...\e[0m\n"
fi

read -p "Press enter to reboot the system... "
reboot
