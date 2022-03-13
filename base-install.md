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
     - 3.3. 5: [Hostname](#Hostname)
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


## Installation


### Pacstrap


### FSTAB


### Chroot


#### Time and Clock


#### Pacman


#### Sudo


#### Locale


#### Hostname


#### Users


#### AUR


#### Initcpio


#### Networking


#### Bootloader


#### Misc Services


## Finishing


## After Installing


