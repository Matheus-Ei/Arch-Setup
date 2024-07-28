#!/bin/bash

echo "Updating the system... "
pacman -Syu

# Development tools
echo "%%%% Development tools %%%%"
read -p "Install docker? (y/N)" iDocker
[ "$iDocker" == "y" ] && pacman -S docker
read -p "Install dbeaver? (y/N)" iDbeaver
[ "$iDbeaver" == "y" ] && pacman -S dbeaver
read -p "Install man? (y/N)" iMan
[ "$iMan" == "y" ] && pacman -S man
read -p "Install neovim? (y/N)" iNvim
[ "$iNvim" == "y" ] && pacman -S nvim
read -p "Install git? (y/N)" iGit
[ "$iGit" == "y" ] && pacman -S git

# Browsers
echo "%%%% Browsers %%%%"
read -p "Install firefox? (y/N)" iFirefox
[ "$iFirefox" == "y" ] && pacman -S firefox
read -p "Install tor? (y/N)" iTor
[ "$iTor" == "y" ] && pacman -S torbrowser-launcher

# Programming languages
echo "%%%% Programming languages %%%%"
read -p "Install python? (y/N)" iPython
[ "$iPython" == "y" ] && pacman -S python python3
read -p "Install nodejs? (y/N)" iNodejs
[ "$iNodejs" == "y" ] && pacman -S nodejs
read -p "Install java? (y/N)" iJava
[ "$iJava" == "y" ] && pacman -S jre-openjdk jdk-openjdk
read -p "Install C++? (y/N)" iCpp
[ "$iCpp" == "y" ] && pacman -S gcc
read -p "Install postgresql? (y/N)" iPostgresql
[ "$iPostgresql" == "y" ] && pacman -S postgresql

# Ultilities
echo "%%%% Ultilities %%%%"
read -p "Install libreoffice suit? (y/N)" iLibreoffice
[ "$iLibreoffice" == "y" ] && pacman -S libreoffice
read -p "Install audacity? (y/N)" iAudacity
[ "$iAudacity" == "y" ] && pacman -S audacity
