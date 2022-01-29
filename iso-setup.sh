#!/bin/bash
###--- CONSTANTS ---###
repo_name="kalos"
repo_url="https://github.com/kenielf/$repo_name"

###--- SCRIPT ---###
# Configure pacman
#sed -i "/aaa=/c\aaa=xxx" your_file_here
sed -i "/^#Color=/c\Color" /etc/pacman.conf

# Install git on ISO
pacman -Sy git

# Download repository and cd into it
git clone "$repo_url"
cd $repo_name

