read -p "What is your username? " systemUsername

## Yay
echo "Setting up yay... "
cd /home/$systemUsername/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
