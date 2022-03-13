# Manual Arch Linux Installation - Base Install
## Disclaimer
This installation is intended for UEFI with BTRFS, if you're using different motherboard settings and/or other filesystems, please adapt them to the appropriate commands/settings.


## Preface
### Variables
Every line that contains `$variable` should be replaced to an appropriate value.

E.g.: If your user is "jonathan"
`usermod -aG wheel $user` becomes `usermod -aG wheel jonathan`


## Index
 - 1: [Before Installing](#Before-Installing)
 - 2: [Disk Preparation](#Disk-Preparation)
 - 3: [Installation](#Installation)
   - 3.1: [Pacstrap](#Pacstrap)
   - 3.2: [FSTAB](#FSTAB)
   - 3.3: [Chroot](#Chroot)
     - 3.3. 1: [Time and Clock](#Time-and-Clock)
     - 3.3. 2: [Pacman](#Pacman)
     - 3.3. 3: [Sudo](#Sudo)
     - 3.3. 4: [Locale](#Locale)
     - 3.3. 5: [Hostname](#Hostname-and-Hosts)
     - 3.3. 6: [Users](#Users)
     - 3.3. 7: [AUR](#AUR)
     - 3.3. 8: [Initcpio](#Initcpio)
     - 3.3. 9: [Networking](#Networking)
     - 3.3.10: [Bootloader](#Bootloader)
     - 3.3.11: [Misc Services](#Misc-Services)
 - 4: [Finishing](#Finishing)
 - 5: [After Installing](#After-Installing)


## Before Installing
Before the system is installed and before any permanent change is done to the disk, assertain that you have both networking and the correct keyboard layout.


If the keyboard layout isn't appropriate, list all keymaps and load the correct one.
```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
loadkeys $keymap
```

Test network connectivity with `ping archlinux.org`, if this does not yield multiple lines of output or you're using wi-fi, you'll need to set it up manually with `iwctl`.
 - `device list`:
    List all networking devices;
 - `station $device scan`:
    Scan all networks on $device;
 - `station $device get-networks`:
    List all available networks on $device;
 - `station $device connect $ssid`:
    Connect to $ssid on $device.


## Disk Preparation
Prepare the preferred disk to install the system.

*Note: I have a 240G SSD, so I partition it as such:*
 - 2G: ESP (If you don't plan on customizing your bootloader, 550M is plenty)
 - 4G: Swap (At least 2-4G - Match machine RAM is hibernation will be used)
 - 200G: ROOT (Where the system is mostly located.)
 Remaining space is reserved for other systems.


Use `fdisk /dev/$sdx` to format your partition with these commmands:
 - (n): New partition;
 - (d): Delete partition;
 - (p): Print partition scheme;
 - (m): help Manual;
 - (g): create Gpt partition table;
 - (t): change partition Type:
   -  1: EFI System
   - 19: Linux swap
   - 20: Linux filesystem
 - (w): Write changes to disk;
 - (q): Quit without saving;


After partitioning is done, create the filesystems to be used
 - FAT32 - ESP
    ```bash
    mkfs.fat -F32 -n $label /dev/$esp
    ```
 - SWAP
    ```bash
    mkswap -L $label /dev/$swap
    swapon /dev/$swap
    ```
 - EXT4
    ```bash
    mkfs.ext4 -L $label /dev/$root
    ```
 - BTRFS
    ```bash
    mkfs.btrfs -L $label /dev/$root
    mount /dev/$root /mnt && cd /mnt
    btrfs subvolume create @
    btrfs subvolume create @home
    umount /mnt
    ```
    *Reminder: In this installation, btrfs will be used, so certain packages or steps may not be necessary if you're using ext4.*


Then, mount the filesystems to their mountpoints:
```bash
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/$root /mnt
mkdir -p /mnt/{boot/esp,home}
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/$root /mnt/home
mount /dev/$esp /mnt/boot/esp
```
*Note: the `-o noatime,...,subvol=@` section is not present on ext4*


## Installation
### Pacstrap
Install the base system with `pacstrap`
```bash
picstrap /mnt $kernel_pkg linux-firmware linux-utils ufw tlp $cpu_microcode_pkg base base-devel btrfs-progs polkit go wget curl git openssh man-db sudo $editor_pkg $network_pkg $bootloader_pkg
```

The kernel is up to personal choice - you can even install multiple, but the documentation is optional - here's a list of kernel packages:
 - (linux): `linux linux-headers linux-docs`
    The regular linux kernel, packaged for Arch Linux.
 - (linux-zen): `linux-zen linux-zen-headers linux-zen-docs`
    An optimized version of the regular kernel, my personal preference.
 - (linux-lts):
    The long term support version of the regular kernel.
 - (linux-hardened):
    A security-hardened version of the regular kernel.
*Note: some packages may require specific versions to work with custom kernels.*


The cpu microcode is very important, choose `intel-ucode` or `amd-ucode` according to your CPU vendor.


Network tools are also up to choice, here's two I recommend:
 - (Network Manager): `networkmanager network-manager-applet`
    A commonly used network connection manager. `network-manager-applet` is optional is you're not using trays on the final system.
 - (iwctl): `iwd`
    The Internet Wireless Daemon


Bootloader is also up to choice, here's two I use:
 - (grub): `grub efibootmgr dosfstools os-prober mtools
    The GNU Grand Unified Bootloader.
 - (rEFInd): `refind dofstools efibootmgr`
    A fork of `rEFIt`, my preferred bootloader.


### FSTAB
Set up fstab with the flag `-U`to enable mounting by UUID (safer)
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```


### Chroot
Change root to the new installation to setup system internally
```bash
arch-chroot /mnt
```


#### Time and Clock
Change the timezone and clock settings to match your location.
```bash
ln -sf /usr/share/zoneinfo/$country/$zone /etc/localtime
timedatectl set-ntp true
hwclock --systohc
```


#### Pacman
Modify pacman's configuration on `/etc/pacman.conf` to your liking.
My preferred settings are:
 - Uncomment lines containing:
   - `Color`
   - `CheckSpace`
   - `VerbosePkgLists`
   - `ParallelDownloads = 5`
 - Replace `ParallelDownloads = 5 ParallelDownloads = $cpu_ncore`
 - Enable multilib repository by uncommenting `[multilib]` and the line below it


#### Sudo
Change sudo configuration with `EDITOR=$editor visudo` and:
 - Uncomment and remove the additional space `# %wheel ALL=(ALL) ALL` on line 82.


#### Locale
Modify locales on `/etc/locale.gen` to match your languages, this is my setup:
 - Uncomment `en_US.UTF-8 UTF-8` on line 178 (Recommended);
 - Uncomment `ja_JP.UTF-8 UTF-8` on line 303;
 - Uncomment `pt_BR.UTF-8 UTF-8` on line 393;
Now run these commands, with `$locale` being the first part of your preferred locale previously uncommented. Example: `en_US.UTF-8`
```bash
locale-gen
echo "LANG=$locale" >> /etc/locale.conf
```

If you changed your keyboard layout on [Before Install](#Before-Install) make sure to make it permanent with:
```bash
echo "KEYMAP=$keymap" >> /etc/vconsole.conf
```


#### Hostname and Hosts
Create your machine hostname with:
```bash
echo "$hostname" >> /etc/hostname
```

And create your hosts:
```bash
$hostname=$(cat /etc/hostname); echo -e "127.0.0.1\tlocaldomain\n::1\t\tlocaldomain\n127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts
```


#### Users
Create user and their password:
```bash
useradd -m $username
usermod -aG wheel,audio,video,optical,storage,games,users,input $username
passwd $username
```
Set up root password with
```bash
passwd
```


#### AUR
There are multiple AUR helpers, like `aura` or `paru` for example, but the only one I've had experience with is `yay`.
```bash
su $username
cd ~ && git clone "https://aur.archlinux.org/yay-git.git" && cd yay-git
makepkg -si && cd .. && rm -rf yay-git/
yay --sudoloop --save
exit
```
*Note: it is also recommended that you install any major AUR package before exiting the `su` command.*


#### Initcpio
*Note: this step is entirely optional on EXT4*
*Note 2: Install `mkinitcpio-firmware` (aur) to add missing firmware.*


Edit `/etc/mkinitcpio.conf` and:
 - Add `btrfs` to `MODULES=()`

After that, rebuild mkinitcpio with:
```bash
mkinitcpio -P
```


#### Networking
Set up networks on the new system with the previously installed network toolset.
 - (Network Manager): `systemctl enable NetworkManager`
 - (iwctl): `systemctl enable iwd.service`


#### Bootloader
Set up your bootloader with your previously installed packages.
 - (grub):
    `grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck`
    `grub-mkdconfig -o /boot/grub/grub.cfg`
 - (refind):
    `refind-install --usedefault /dev/$esp`

If you're using BTRFS, then refind needs to be set up as such:
```bash
refind-install --alldrivers --usedefault /dev/$esp
```

And then, create the file `/boot/refind_linux.conf` with:
```
"Boot using default options" "root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw add_efi_menmap rootflags=subvol=@ initrd=@\boot\intel-ucode.img initrd=@\boot\initramfs-%v.img quiet"

"Boot with multiuser.target" "root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw add_efi_menmap rootflags=subvol=@ initrd=@\boot\intel-ucode.img initrd=@\boot\initramfs-%v.img systemd.unit=multi-user.target"
```

#### Misc Services
```
systemctl enable ufw
systemctl enable sshd
systemctl enable fstrim.timer
systemctl enable tlp
sysctl -w vm.swappiness=10
```

## Finishing
Make sure everything is correct, exit the chroot with `exit`.
Unmount all filesystems with `umount` and `swapoff`, and your system should be complete.


## After Installing
After the base minimal install is over, you may want to follow my way of installing the desktop environments and other things like that.
If that is the case, read:
 - [Extended Install](extended-install.md)


