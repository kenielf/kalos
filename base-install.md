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
     - 3.3. 5: [Hostname]
     - 3.3. 6: [Users](#Users)
     - 3.3. 7: [AUR](#AUR)
     - 3.3. 8: [Initcpio](#Initcpio)
     - 3.3. 9: [Networking](#Networking)
     - 3.3.10: [Bootloader](#Bootloader)
     - 3.3.11: [Misc Services](#Misc-Services)
 - 4: [Finishing](#Finishing)
 - 5: [After Installing](#After-Installing)

## Step 1: Pre-install
Load keymaps, test network status, check dependencies, et cetera..
If everything is correct you should proceed to the next step.

```
# loadkeys <layout>
# ping -c www.archlinux.org
```

If you're using a wireless connection, you'll need to set it up manually with `iwctl`.
 - (device list): List all networking devices;
 - (station <DEVICE> scan): Scan all networks on <DEVICE>;
 - (station <DEVICE> get-networks): List all available networks on <DEVICE>;
 - (station <DEVICE> connect <SSID>): Connect to <SSID> on <DEVICE>;

## Step 2: Disk Setup
Set and prepare preferred disk to install the system.

I have a 240G SSD, so the way I partition it is:
 - 2G: Boot (If you don't plan on customizing your bootloader 550M is plenty)
 - 4G: Swap (At least 2-4G - Match system RAM if hibernation will be used)
 - 200G: Root (Where the system is generally located)
Remaining space is for other systems (their swap and root partition.)

Using `fdisk`, you can format and partition your disk with:
 - (n): New partition;
 - (d): Delete partition;
 - (p): Print partition scheme;
 - (m): help Menu;
 - (g): create Gpt partition table;
 - (t): change partition Type;
   -  1: efi
   - 19: swap
   - 20: Linux Filesystem
 - (w): Write changes to disk;
 - (q): Quit without saving;

After partitioning, you must create filesystems and enable swap. List partitions with `lsblk`:
```
# mkfs.fat -F 32 /dev/<boot_partition>
# mkswap /dev/<swap_partition>
# swapon /dev/<swap_partition>
# mkfs.ext4 /dev/<root_partition>
```

And then, mount the filesystems for them to be used.
```
# mount /dev/<root_partition> /mnt
# mkdir -p /mnt/boot/efi
# mount /dev/<boot_partition> /mnt/boot/efi
```

## Step 3: General System Setup
### Pacstrap
Install necessary packages for a minimal installation with `pacstrap`.
```
# pacstrap /mnt <kernel_packages> linux-firmware <cpu-microcode> base base-devel go wget curl git openssh man-db vim sudo <network_packages> <bootloader_packages>
```

The kernel is up to your choice - and you can even install multiple, and the docs are optional - here's a list of kernel packages:
 - (linux kernel): `linux linux-headers linux-docs`
   - The regular linux kernel, packaged for Arch Linux.
 - (zen kernel): `linux-zen linux-zen-headers linux-zen-docs`
   - A optimized version of the regular kernel, the one I prefer to run on a minimal install. Some packages may require specific versions for this kernel.
 - (linux lts): `linux-lts linux-lts-headers linux-lts-docs`
   - The Long Term Support version of the regular kernel. Some packages may require specific versions for this kernel.
 - (linux hardened): `linux-hardened linux-hardened-headers linux-hardened-docs`
   - A security-hardened version of the regular kernel. Some packages may require specific versions for this kernel.

The cpu microcode is very important, choose `intel-ucode` or `amd-ucode` according to CPU vendor

The network tools are also to your choice, here's a list of ones I recommend:
 - (network manager): `networkmanager network-manager-applet`
   - A commonly used network connection manager.
 - (iwctl): `iwd`
   - The Internet Wireless Daemon.

The bootloader is also up to you:
 - (grub): `grub efibootmgr dosfstools os-prober mtools`
   - The GNU Grand Unified Bootloader.
 - (refind): `refind`
   - An EFI boot manager.

### FSTAB
Set up fstab with the flag `-U` to enable mounting by UUID (safer)
```
# genfstab -U /mnt >> /mnt/etc/fstab
```

## CHROOT
Change root to the new installation with to setup the system internally
```
# arch-chroot /mnt
```

### Timezone and Clock Settings
Change your system's timezone and clock settings to match your location.
```
# ln -sf /usr/share/zoneinfo/<country>/<zone> /etc/localtime
# timedatectl set-ntp true
# hwclock --systohc
```

### Step 4: General System Configuration
#### Pacman
Modify pacman's configuration on `/etc/pacman.conf` to your liking, this is my setup:
 - Uncomment lines containing:
  - `Color`
  - `CheckSpace`
  - `VerbosePkgLists`
  - `ParallelDownloads = 5`
 - Replace `ParallelDownloads = 5` to `ParallelDownloads = <CPU Core Count>`.
 - Enable `multilib` repository:
  - Uncomment `[multilib]` and the line below it.

#### Sudo
Change sudo configuration with `EDITOR=vim visudo` and:
 - Uncomment and remove the additional space `# %wheel ALL=(ALL) ALL` on line 82;

#### Locale and Keymap
Modify locales on `/etc/locale.gen` to match your languages, this is my setup:
 - Uncomment `en_US.UTF-8 UTF-8` on line 177 (Recommended);
 - Uncomment `ja_JP.UTF-8 UTF-8` on line 302;
 - Uncommnet `pt_BR.UTF-8 UTF-8` on line 393;
Now run these commands, with `<locale>` being the first part of your preferred locale previously uncommented. Example: `en_US.UTF-8`
```
# locale-gen
# echo "LANG=<locale>" >> /etc/locale.conf
```
If you changed your keyboard layout on Pre-install make sure to make it permanent with:
```
echo "KEYMAP=<keymap>" >> /etc/vconsole.conf
```

#### Hostname
Create your machine hostname with:
```
echo "<hostname>" >> /etc/hostname
```

#### Users
Create user and their password: 
```
# useradd -m <username>
# usermod -aG wheel,audio,video,optical,storage,games,users,input <username>
# passwd <username>
```
Set up root password:
```
# passwd 
```

#### Hosts
Create the basic host configuration with:
```
# echo -e "127.0.0.1\tlocaldomain\n::1\t\tlocaldomain\n127.0.1.1\t<hostname>.localdomain\t<hostname>" >> /etc/hosts
```

#### AUR
There are multiple AUR managers, like aura or paru for example, but I only recommend yay as it is the one I've always used.
```
# su <username>
$ cd ~
$ git clone "https://aur.archlinux.org/yay-git.git"
$ cd yay-git
$ makepkg -si
$ cd ..
$ rm -rf yay-git/
$ exit
```

#### Step 5: Networking
Set up network on the new system with your previously installed network manager.
 - (network manager)
  - `systemctl enable NetworkManager`
 - (iwctl)
  - `systemctl enable iwd.service`

#### Step 6: Bootloader
Set up your bootloader with your previously installed bootloader.
 - (grub)
  - `grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck`
  - `grub-mkconfig -o /boot/grub/grub.cfg`
 - (refind)
  - `refind-install --usedefault /dev/<boot_partition>`


Exit chroot with `exit`

## Step 7: Finishing Minimal Install
Unmount filesystems with
```
# umount -l /dev/<boot_partition>
# umount -l /dev/<root_partition>
```
And then, reboot.
```
# reboot
```

## Step 8: Post Install
