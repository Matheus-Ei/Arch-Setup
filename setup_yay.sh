read -p "System User: " systemUsername

## Yay
echo "Setting up yay... "
cd /home/$systemUsername/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$systemUsername/Downloads
rm -r yay
