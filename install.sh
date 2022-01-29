#!/bin/bash
# Install script for Arch Linux

###--- CONSTANTS ---###
# Installer
space_l="--------------------------------------------------"
kalos_l="-        Kenielf's Arch Linux Open Setup         -"
# System
swappiness=5
pkg_kernel="linux-zen linux-zen-headers linux-zen-docs linux-firmware"
pkg_ucode="intel-ucode"
pkg_essential="base base-devel go wget curl git openssh man-db vim sudo"
pkg_network="networkmanager"
pkg_bootloader="refind"

###--- PRE-INSTALL ---###
clear
echo -e "$space_l\n$kalos_l\n$space_l\n"

###--- DISK SETUP ---###
# Display disks and partitions.
echo "This is the current partition scheme"
lsblk -pT
echo -e "$space_l"
# Format disk
echo "Would you like to format disks with fdisk? [y/N]"
read -p ">>> " ans
if [ "$ans" == "Y" ] || [ "$ans" == "y" ]; then
	echo "Must have an ESP, SWAP and ROOT partition."
	echo "Choose a disk to partition. (eg /dev/sdb)"
	read -p ">>> " format_disk
	echo "Opening fdisk in 3 seconds..."
	sleep 3
	echo "$format_disk"
	tput smcup
	fdisk "$format_disk"
	sleep 1
	tput rmcup
fi
echo -e "$space_l"
# Get partitions to be used in the installation
echo "Choose EFI, SWAP and ROOT partitions, respectively."
read -p "EFI:  /dev/" efi_part
read -p "SWAP: /dev/" swap_part
read -p "ROOT: /dev/" root_part
echo "Creating Filesystems..."
sleep 2
mkfs.fat -F 32 /dev/$efi_part
mkswap /dev/$swap_part && sleep 3 && swapon /dev/$swap_part
mkfs.ext4 /dev/$root_part
# Mount filesystems
mount /dev/$root_part /mnt
mkdir -p /mnt/boot/efi
mount /dev/$efi_part /mnt/boot/efi
echo -e "$space_l"
###--- USER PREFERENCES
#set_username, set_upasswd, set_rpasswd, hostname, country, region, 
read -p "Username: " set_username
read -p "$set_uname's Password: " -s set_upasswd
echo "\n"
read -p "Root Password: " -s set_rpasswd
echo "\n"
read -p "Hostname: " hostname
read -p "Country: " country
read -p "Region: " region
read -p "Keymap: " keymap
echo -e "$space_l"
###--- GENERAL SYS CONFIG ---###
# Install packages
echo "Installing Packages..."
pacman -S --noconfirm $pkg_kernel $pkg_ucode $pkg_essential $pkg_network $pkg_bootloader
# Fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "$space_l"
# Pacman
cpu_count=$(lscpu | grep -E "(^CPU\(s\):.*)" | grep -oP "(\d*)$");
sed -i "/^#Color/c\Color" /mnt/etc/pacman.conf;
sed -i "/^#VerbosePkgLists/c\VerbosePkgLists" /mnt/etc/pacman.conf;
sed -i "/^#ParallelDownloads = .*/c\ParallelDownloads = $cpu_count" /mnt/etc/pacman.conf;
sed -i "/^ParallelDownloads = .*/a ILoveCandy" /mnt/etc/pacman.conf;
## Enable Multilib Repository
sed -i '/^#\[multilib\]$/c\\[multilib\]' /mnt/etc/pacman.conf;
sed -i '/^\[multilib\]$/!b;n;cInclude = \/etc\/pacman\.d\/mirrorlist' /mnt/etc/pacman.conf;
###--- CHROOT ---#
arch-chroot /mnt /usr/bin/bash <<CHR
ln -sf /usr/share/zoneinfo/$country/$region /etc/localtime;
timedatectl set-ntp true;
hwclock --systohc;
sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" /etc/locale.gen;
sed -i "/^#ja_JP.UTF-8 UTF-8/c\ja_JP.UTF-8 UTF-8" /etc/locale.gen;
sed -i "/^#pt_BR.UTF-8 UTF-8/c\pt_BR.UTF-8 UTF-8" /etc/locale.gen;
locale-gen;
echo "LANG=en_US.UTF-8" >> /etc/locale.conf;
echo "KEYMAP=$keymap" >> /etc/vconsole.conf
echo "$hostname" >> /etc/hostname
useradd -m $set_uname
usermod -aG wheel,audio,video,optical,storage,games,users,input $set_uname
echo "$set_upasswd\n$set_upasswd" | passwd $set_uname
echo "$set_rpasswd\n$set_rpasswd" | passwd
# echo -e "127.0.0.1\tlocaldomain\n::1\t\tlocaldomain\n127.0.1.1\thostname.localdomain\thostname" >> /etc/hosts
su $set_username -c <<EOF
cd ~
git clone "https://aur.archlinux.org/yay-git.git"
cd yay-git
makepkg -si
cd ..
rm -rf yay-git/
exit
EOF;
if [ "$pkg_network" == "networkmanager" ]; then;
systemctl enable NetworkManager;
elif [ "$pkg_network" == "iwd" ]; then;
systemctl enable iwd.service;
fi;
if [ "$pkg_bootloader" == "grub efibootmgr dosfstools os-prober mtools" ]; then;
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck && grub-mkconfig -o /boot/grub/grub.cfg;
elif [ "$pkg_bootloader" == "refind" ]; then;
refind-install --usedefault /dev/$efi_part;
fi;
exit
CHR
echo "$space_l"
###--- FINISHING ---###
umount -l /dev/$efi_part && umount -l /dev/$root_part
echo "Finished"
