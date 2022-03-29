Synchronize Pacman and Yay
`yay -Syyuu`

Create directories
`mkdir -p $HOME/{Documents,Downloads,Music,Pictures,Videos,Other/Desktop,Other/Share,Other/Templates,Other/Docker,Programming,Games}`

Install xdg-user-dirs and set the user dirs
```bash
yay -S --noconfirm --needed xdg-user-dirs xdg-desktop-portal-gnome
xdg-user-dirs-update --set DESKTOP ~/Other/Desktop
xdg-user-dirs-update --set DOCUMENTS ~/Documents
xdg-user-dirs-update --set DOWNLOAD ~/Downloads
xdg-user-dirs-update --set MUSIC ~/Music
xdg-user-dirs-update --set PICTURES ~/Pictures
xdg-user-dirs-update --set PUBLICSHARE ~/Other/Share
xdg-user-dirs-update --set TEMPLATES ~/Other/Templates
xdg-user-dirs-update --set VIDEOS ~/Videos
xdg-user-dirs-update --set PROGRAMMING ~/Programming
xdg-user-dirs-update --set GAMES ~/Games
```

Install xorg and graphics drivers
`yay -S --noconfirm --needed mesa lib32-mesa vulkan-intel xorg xorg-xinit`

Edit `/etc/udev/rules.d/backlight.rules` and add:
```
RUN+="/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"
RUN+="/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
```

Install some necessary fonts with
```bash
yay -S --noconfirm --needed noto-fonts{,-cjk,-emoji,-extra} ttf-jetbrains-mono adobe-source-han-{serif,sans}-otc-fonts {otf,ttf}-font-awesome otf-latinmodern-math ttf-hanazono ttf-liberation nerd-fonts-complete ttf-kanjistrokeorders
```

Install fcitx and its tools
```bash
yay -S --noconfirm --needed fcitx5{-im,-mozc,-nord} qt5-tools
```

Install PipeWire with WirePlumber
```bash
yay -S --noconfirm --needed wireplumber{,-docs} pipewire{,-pulse,-alsa,-jack,-docs} helvum pavucontrol alsamixer pulseaudioctl
```

Install some bluetooth utilities
```bash
yay -S --noconfirm --needed bluez bluez-utils blueman
sudo usermod -aG lp $(whoami)
sudo systemctl enable bluetooth
```

Install window manager and its utilities
```bash
yay -S --noconfirm --needed i3-gaps i3blocks i3lock-color i3status kitty{,-shell-integration,-terminfo} hsetroot feh nitrogen dunst rofi{,-calc} gnome-{calculator,calendar,clocks,disk-utility,maps,weather} mousepad engrampa gparted lightdm{,-settings-slick-greeter} thunar{,-archive-plugin,-media-tags-plugin,-volman} gvfs{,-nfs,-smb,-afc,-google,-mtp,-goa,-gphoto2} mtpfs libgsf libwebp raw-thumbnailer tumbler ffmpegthumbnailer kvantum lxappearance arc-kde arc-gtk-theme arc-icon-theme kvantum-theme-arc capitaine-cursors paper-icon-theme-git
sudo systemctl enable lightdm
```

Install extra applications
```bash
yay -S --noconfirm --needed android-tools scrcpy ffmpeg imagemagick irssi librewolf-bin chromium mpv vlc eog{,-plugins} codeblocks pycharm-community-edition code elixir rustup xpad libreoffice-still zathura{,-ps,-cb,-pdf-mupdf,-djvu} scrot flameshot picom-ibhagwan-git anki-official-binary-bundle telegram-desktop gimp kdenlive-release-git krita inkscape blender audacity obs-studio discord thunderbird pomotroid-bin numlockx tmux fzf gst-libav openssh yt-dlp cups unzip zip unrar dialog btop htop
```

Install some games
```bash
yay -S --noconfirm --needed retroarch{,-assets-xmb,-assets-ozone} libretro{-core-info,-beetle-pce,-beetle-pce-fast,-beetle-psx,-beetle-psx-hw,-beetle-supergrafx,-blastem,-bsnes,-bsnes-hd,-bsnes2014,-citra,-core-info,-desmume,-dolphin,-duckstation,-flycast,-gambatte,-genesis-plus-gx,-kronos,-melonds,-mesen,-mesen-s,-mgba,-mupen64plus-next,-nestopia,-overlays,-parallel-n64,-pcsx2,-picodrive,-play,-ppsspp,-retrodream,-sameboy,-scummvm,-shaders-slang,-snes9x,-yabause} steam wine winetricks vkd3d spacecadetpinball-git minecraft-launcher
```

Setup keyring
```bash
yay -S --noconfirm --needed libsecret gnome-keyring seahorse
```

Modify `/etc/pam.d/login` and add the ones marked with `--` *(without the `--` of course.)*:
```
#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
--auth       optional     pam_gnome_keyring.so--
account    include      system-local-login
session    include      system-local-login
--session    optional     pam_gnome_keyring.so auto_start--
```

Finalize by downloading the dotfiles repo and clearing pacman cache
```bash
git clone https://github.com/kenielf/dotfiles ~/Dotfiles
cd ~/Dotfiles
./apply-dots.sh
yay -Scc
```
