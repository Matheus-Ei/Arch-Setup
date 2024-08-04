# Grub instalation and configuration
echo "+++++ Grub installation and configuration +++++"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

