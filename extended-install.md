# Extended Install
## Disclaimer
This post-install guide is intended entirely for personal usage, as a memo for future installations, however the vast majority of the information here can be reused for your own personal installation.


## Preface
### Variables
Every line that contains `$variable` should be replaced to an appropriate value.

E.g.: If your user is "jonathan":

`usermod -aG wheel $user` becomes `usermod -aG wheel jonathan`.


## Index
 - [Preparing](#Preparing)
 - [Xorg](#Xorg)
   - [Xinit](#Xinit)
   - [Backlight](#Backlight)
 - [Fonts](#Fonts)
 - [Input Manager](#Input-Manager)
 - [Audio](#Audio)
 - [Bluetooth](#Bluetooth)
 - [Window Manager](#Window-Manager)
   - [Terminal](#Terminal)
   - [Background](#Background)
   - [Notifications](#Notifications)
   - [Launcher and Powermenu](#Launcher-and-Powermenu)
   - [Complementary Applications](#Complementary-Applications)
 - [Display Manager](#Display-Manager)
 - [File Manager](#File-Manager)
 - [Theming](#Theming)
 - [Keyring](#Keyring)
 - [GPG and SSH](#GPG-and-SSH)
 - [Git](#Git)
 - [CLI Tools](#CLI-Tools)
   - [Irssi](#Irssi)
   - [FFMPEG and ImageMagick](#FFMPEG-and-ImageMagic)
   - [Android Stuff](#Android-Stuff)
   - [PDS Kernel](#PDS-Kernel)
 - [GUI Tools](#GUI-Tools)
   - [Firefox](#Firefox)
 - [Gaming](#Gaming)


## Preparing
Before proceeding with the extended installation atop the base install, some steps need to be taken in order to make sure everything goes according to plan.

Create `~/Dotfiles` to store the majority of the system customization and move `.bashrc`, `.config/` to `~/Dotfiles/`


Then, set up some of the folders that will be repeatedly used in this co
nfiguration.
```bash
mkdir -p $HOME/{Documents,Downloads,Music,Pictures,Videos,Other/Desktop,Other/Share,Other/Templates, Programming, Games}
```

Then, install xdg-user-dirs with `pacman -S xdg-user-dirs` and set the appropriate user dirs with:
```bash
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


## Xorg
Xorg is a critical component for the system as it is the implementation of the X11 Window System.


Make sure to install the correct drivers for you GPU, as per mention in the [Arch Wiki](https://wiki.archlinux.org/title/Xorg#Driver_installation). So in my case:
```bash
pacman -S mesa lib32-mesa vulkan-intel
```


### Xinit
Install both xorg and its xinit with `pacman -S xorg xorg-xinit` and set it up with:
```bash
cp /etc/X11/xinit/xinitrc ~/Dotfiles/.xinitrc
ln -sf ~/Dotfiles/.xinitrc ~/.xinitrc
```
*Note: also check the [Arch Wiki](https://wiki.archlinux.org/title/Xinit#Switching_between_desktop_environments/window_managers) for more usable info.


### Backlight
This is mostly specific for my system, but the regular modesetting driver that is used does not automatically set up backlight support, so add the block below to `/etc/X11/xorg.conf.d/20-intel.conf`:
```bash
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "Backlight"  "intel_backlight"
EndSection
```


## Fonts
Install most of the necessary fonts with:
```bash
pacman -S noto-fonts{,-cjk,-emoji,-extra} ttf-jetbrains-mono adobe-source-han-{serif,sans}-otc-fonts {otf,ttf}-font-awesome otf-latinmodern{,-math} ttf-hanazono ttf-liberation
```

Also install from the aur the nerd fonts, personally, I prefer the bigger but complete package:
```bash
yay -S nerd-fonts-complete
```
*Note: you can also add `ttf-kanjistrokeorders` if you're planning on using Anki for Japanese

## Input Manager
The input manager I use is fcitx5, as it has better handling of asian languages. Install it with:
```bash
pacman -S fcitx5{-im,fcitx5-mozc,fcitx5-nord} qt5-tools
```

And configure it with `fcitx5-configtool`


## Audio
Install PipeWire with Wireplumber:
```bash
pacman -S wireplumber{,-docs} pipewire{,-pulse,-alsa,-jack,-docs} helvum xdg-desktop-portal-gnome pavucontrol
```

## Bluetooth
Install bluez and some tools with:
```bash
pacman -S bluez bluez-utils blueman
```

Check if the `btusb` module is loaded with `lsmod | grep -i "btusb"`. And set it up with:
```bash
usermod -aG lp $(whoami)
systemctl enable bluetooth
```

To configure it, follow the [Arch Wiki](https://wiki.archlinux.org/title/Bluetooth).


## Window Manager
### Terminal
```bash
pacman -S kitty{,-shell-integration,-terminfo}
```


### Background
If you plan on using images, you can use `feh` or `nitrogen`. For new users I recommend nitrogen, if you're using solid colors hsetroot is plenty.
```bash
pacman -S hsetroot feh nitrogen
```


### Notifications
```bash
pacman -S dunst
```


### Launcher and Powermenu
I use rofi, which can be installed with:
```bash
pacman -S rofi{,-calc}
```
*Note: `ulauncher` is also a great option.*


### Complementary Applications
Install some of gnome's utilities:
```bash
pacman -S gnome-{calculator,calendar,clocks,disk-utility,font-viewer,gnome-maps,gnome-music,usage,weather} mousepad engrampa
```


## Display Manager
Install lightdm and some of its themes
```bash
yay -S lightdm{,-settings,-slick-greeter}
```

Go to `/etc/lightdm` and customize `Xsession`, `lightdm.conf`, and any other specific theme. More info can be found on the [Arch Wiki](https://wiki.archlinux.org/title/LightDM).


## File Manager
Install Thunar and its addons alongside gvfs
```bash
pacman -S thunar{,-archive-plugin,-media-tags-plugin,-volman} gvfs{,-nfs,-smb,-afc,-google,-mtp,-goa,-gphoto2} mtpfs libgsf libwebp raw-thumbnailer tumbler ffmpegthumbnailer
```
*Note: you can customize it more with the guides shown on the [Arch Wiki](https://wiki.archlinux.org/title/thunar) 


## Theming
Install the gtk and qt theme managers:
```bash
pacman -S kvantum lxappearance
```

Install the gtk, qt and icon themes you'd like to use
```bash
yay -S nordic-theme-git nordic-kde-git kvantum-theme-nordic-git capitaine-cursors paper-icon-theme-git papirus-icon-theme-git
```
*Note: some of these packages are in the normal repos, but since the majority of them are in the AUR I run them with yay to unify the command.*


Now, apply them manually to user and root by running:
```bash
lxappearance
sudo lxappearance
kvantummanager
sudo kvantummanager
```


## Keyring
Install some of the packages to be used to set up the keyring:
```bash
pacman -S libsecret gnome-keyring seahorse
```

Set up PAM to start a keyring manually by editing `/etc/pam.d/login` and adding the ones marked with `--` *(without the `--` of course.)*:
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

Now to start it, either add this to `.bashrc` or `.zshrc` or some file sourced by them:
```bash
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi
```

If you're setting it up by the X session profile, add this to your session file:
```
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
```


## GPG and SSH
Before installing, export your keys with:
```bash
gpg --list-secret-keys user@example.com
gpg --export-secret-keys YOUR_ID_HERE > private.key
```

And to import it:
```bash
gpg --import private.key
gpg --edit-key user@example.com
gpg> trust
gpg> 5
gpg> save
```


For SSH, copy the keys to `~/.ssh` and set their permissions appropriately:
```bash
chmod 600 id_example
chmod 644 id_example.pub
```


## Git
Set up some basic settings with:
```bash
git config --global init.defaultBranch "$BRANCH_NAME"
git config --global user.name "$USER_NAME"
git config --global user.email "$USER_MAIL"
```

To set up GPG signing:
```bash
git config --global --unset gpg.program
git config --global user.signingkey "$GPG_KEY"
git config --global commit.gpgSign $ENABLE_GPG
```

And to add aliases, add this to `~/.gitconfig`
```
[url "https://github.com/"]
	insteadOf = gh:
[url "git@github.com:"]
	pushInsteadOf = "gh:"

[url "https://gitlab.com/"]
	insteadOf = gl:
[url "git@gitlab.com:"]
	pushInsteadOf = "gl:"

[url "https://aur.archlinux.org/"]
	insteadOf = aur:
[url "aur@aur.achlinux.org:"]
	pushInsteadOf = "aur:"
```


## CLI Tools
### Irssi
Configure it as the [Arch Wiki](https://wiki.archlinux.org/title/Irssi) and the [Documentation](https://irssi.org/documentation/settings/) says.

To set up DCC, do:
```bash
mkdir -p ~/Other/DCC
```
And add `dcc_download_path ~/Other/DCC` to the config file.

Inside of Irssi, this is how to use DCC:
```
/DCC CHAT mike
/DCC GET bob "summer vacation.mkv"
/DCC SEND sarah "summer vacation.mkv"
/DCC CLOSE get mike
/DCC CLOSE send bob "summer vacation.mkv"
```


### FFMPEG and ImageMagick
```bash
yay -S ffmpeg-git imagemagick
```


### Android Stuff
```
pacman -S android-tools scrpcy
```

### PDS Kernel
Receive the mainline kernel's key
```bash
gpg --keyserver "hkps://keys.openpgp.org" --recv-keys 3B94A80E50A477C7
```

Receive PDS's key:
```bash
# Receive mainline linux kernel keys
gpg --recv-keys 647F28654894E3BD457199BE38DBBDC86092693E
gpg --recv-keys A2FF3A36AAA56654109064AB19802F8B0D70FC30
gpg --recv-keys C7E7849466FE2358343588377258734B41C31549
gpg --recv-keys ABAF11C65A2970B130ABE3C479BE3E4300411886
```

And finally, install it:
```bash
yay -S linux-pds{,-headers,-docs}
```
*Note: a lot of warnings will pop up and the docs package may fail installation.* 


## GUI Tools
### Firefox
Install your preferred version (I use the esr one):
```bash
yay -S firefox-esr
```

Apply a custom theme if needed I use [EliverLara](https://github.com/EliverLara/firefox-nordic-theme)'s:
```bash
git clone https://github.com/EliverLara/firefox-nordic-theme && cd firefox-nordic-theme
./scripts/install.sh
cd ..
rm -rf firefox-nordic-theme
```
*Note: add `"#contentAreaContextMenu { margin: 10px 0px 0px 10px; }"` to `userChrome.css` to avoid right click action menu issues.


## Gaming
