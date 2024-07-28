#!/bin/bash

echo "Updating the system... "
pacman -Syu

# Development tools
echo "%%%% Development tools %%%%"
read -p "Install docker? (y/N)" iDocker
pacman -S docker
read -p "Install dbeaver? (y/N)" iDbeaver
pacman -S dbeaver
read -p "Install man? (y/N)" iMan
pacman -S man
read -p "Install neovim? (y/N)" iNvim
pacman -S nvim
read -p "Install git? (y/N)" iGit
pacman -S git

# Browsers
echo "%%%% Browsers %%%%"
read -p "Install firefox? (y/N)" iFirefox
pacman -S firefox
read -p "Install tor? (y/N)" iTor
pacman -S torbrowser-launcher

# Programming languages
echo "%%%% Programming languages %%%%"
read -p "Install python? (y/N)" iPython
pacman -S python python3
read -p "Install nodejs? (y/N)" iNodejs
pacman -S nodejs
read -p "Install java? (y/N)" iJava
pacman -S jre-openjdk jdk-openjdk
read -p "Install C++? (y/N)" iCpp
pacman -S gcc
read -p "Install postgresql?" iPostgresql
pacman -S postgresql

# Ultilities
echo "%%%% Ultilities %%%%"
read -p "Install libreoffice suit? (y/N)" iLibreoffice
pacman -S libreoffice
read -p "Install audacity? (y/N)" iAudacity
pacman -S audacity
