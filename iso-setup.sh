#!/bin/bash
# curl -L "https://raw.githubusercontent.com/kenielf/kalos/development/iso-setup.sh" >> iso-setup.sh && chmod +x iso-setup.sh
###--- CONSTANTS ---###
repo_name="kalos"
repo_url="https://github.com/kenielf/$repo_name"
cpu_count=$(lscpu | grep -E "(^CPU\(s\):.*)" | grep -oP "(\d*)$")

###--- SCRIPT ---###
# Configure pacman
echo "Configuring pacman."
## Enable Color, Verbose Package List, Parallel Downloads and Pacman Easter Egg
sed -i "/^#Color/c\Color" /etc/pacman.conf
sed -i "/^#VerbosePkgLists/c\VerbosePkgLists" /etc/pacman.conf
sed -i "/^#ParallelDownloads = .*/c\ParallelDownloads = $cpu_count" /etc/pacman.conf
sed -i "/^ParallelDownloads = .*/a ILoveCandy" /etc/pacman.conf
## Enable Multilib Repository
sed -i '/^#\[multilib\]$/c\\[multilib\]' /etc/pacman.conf
sed -i '/^\[multilib\]$/!b;n;cInclude = \/etc\/pacman\.d\/mirrorlist' /etc/pacman.conf
# Sync repos
pacman -Syy

# Install git on ISO
echo "Installing git"
pacman -S --needed --noconfirm git

# Download repository and cd into it
if [ ! -d $repo_name ]; then
	echo "Cloning repo"
	git clone "$repo_url"
	cd $repo_name
fi

echo "Finished"

