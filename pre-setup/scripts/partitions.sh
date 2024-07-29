echo "+++++ Partition formatter and mounter +++++"

read -p "What is your efi partition? " efiPartition
read -p "What is your root partition? " rootPartition
read -p "What is your swap partition? " swapPartition

read -p "Press enter to format the partitions... "
mkfs.ext4 $rootPartition 
mkfs.fat -F 32 $efiPartition
mkswap $swapPartition

read -p "Press enter to mount the partitions... "
mount $rootPartition /mnt
mount --mkdir $efiPartition /mnt/boot
swapon $swapPartition
