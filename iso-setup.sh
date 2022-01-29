#!/bin/bash
###--- CONSTANTS ---###
repo_name="kalos"
repo_url="https://github.com/kenielf/$repo_name"
cpu_count=$(lscpu | grep -E "(^CPU\(s\):.*)" | grep -oP "(\d*)$")

###--- SCRIPT ---###
# Configure pacman
#sed -i "/aaa=/c\aaa=xxx" your_file_here
echo "Configuring pacman."
sed -i "/^#Color/c\Color" /etc/pacman.conf
sed -i "/^#VerbosePkgLists/c\VerbosePkgLists" /etc/pacman.conf
sed -i "/^#ParallelDownloads = 5/c\ParallelDownloads = $cpu_count" /etc/pacman.conf

# Install git on ISO
echo "Installing git"
pacman -Sy git

# Download repository and cd into it
echo "Cloning repo"
git clone "$repo_url"
cd $repo_name

