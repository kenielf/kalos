#!/bin/bash
# Install script for Arch Linux
# TODO: Remove sudo

###--- CONSTANTS ---###
# Installer
space_l="--------------------------------------------------"
kalos_l="-        Kenielf's Arch Linux Open Setup         -"
# System
swappiness=5

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
	sudo fdisk "$format_disk"
	tput rmcup
fi
echo -e "$space_l"
# Get partitions to be used in the installation
echo "Choose EFI, SWAP and ROOT partitions, respectively."
read -p "EFI:  /dev/" efi_part
read -p "SWAP: /dev/" swap_part
read -p "ROOT: /dev/" root_part
echo "Creating Filesystems..."
mkfs.fat -F 32 /dev/$efi_part
mkswap /dev/$swap_part
swapon /dev/$swap_part
mkfs.ext4 /dev/$swap_part
echo -e "$space_l"
###--- GENERAL SYS CONFIG ---###
###--- FINISHING ---###
echo "Finished"
