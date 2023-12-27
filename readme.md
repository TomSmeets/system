# My Linux System Setup

Everything should be as simple as possible. I want to be able to keep it all in my head.

## Current System
My system currently has the following disks.

| Disk   | Type |    Size | Speed | Linux Device Name |
|--------|------|--------:|-------|-------------------|
| Disk A |  SSD |  932 GB | Fast  | /dev/nvme0n1      |
| Disk B |  SSD | 1863 GB | Fast  | /dev/nvme1n1      |
| Disk C |  HDD |  932 GB | Slow  | /dev/sda          |

Note that if you buy a 1 TB disk you will get a disk with $1000 * 1000^3$ bytes.
But we count in multiples of 1024. Which means that the actual size is equal to
$932 * 1024^3$ or 932 bytes.

These disks are currently partitioned the following way.

|  Disk  | Part |   Size  |  Label  |  File system  |
|--------|-----:|--------:|---------|--------------|
| Disk A |    1 |    2 GB | Boot    | vfat         |
| Disk A |    2 |   16 MB | ?       | ?            |
| Disk A |    3 |  930 GB | Windows | NTFS         |
| Disk B |    1 | 1863 GB | Linux   | btrfs + LUKS |
| Disk C |    1 |  932 GB | Backup  | btrfs + LUKS |

This encrypted Linux partition on "Disk B" has a number of btrfs subvolumes.

- /tree - Actual important data (currently  87 GB)
- /data - Media and Downloads   (currently 616 GB)
- /root - Linux Root partitions (currently  35 GB)
- /snap - BTRFS Snapshots of /tree

Putting my Linux root on a btrfs volume allows me to create as many roots as I want.
However, in practice this was not very beneficial.

## Possible Future System

I am considering to go to the following layout.
The goal is to simplify the system as much as possible.
Configuring an encrypted btrfs as a Linux root is not trivial.
While I managed to configure it and have a running system, it is not simple and has multiple points of failure.

| Disk   | Part |  Size   |  Label  |  File system  |
|--------|------|---------|---------|--------------|
| Disk A |    1 |    2 GB | Boot    | vfat         |
|        |    2 |   16 MB | ?       | ?            |
|        |    3 |  930 GB | Windows | NTFS         |
|        |      |         |         |              |
| Disk B |    1 |  400 GB | Root 1  | ext4         |
|        |    2 |  400 GB | Root 2  | ext4         |
|        |    3 |  663 GB | Data    | ext4         |
|        |    4 |  400 GB | Tree    | btrfs + LUKS |
|        |      |         |         |              |
| Disk C |    1 | 1000 GB |  Backup | ext4         |

Maybe the naming of my tree and data partitions could be improved. Not sure yet however.

- Rename `/tree` to `/data`
- Rename `/data` to `/media`

### Migration To the future system

- Create a backup of `/data/tree` to the external HDD
- Partition Disk C like this:

| Disk   | Part |  Size   |  Label   |  File system  |
|--------|------|---------|----------|--------------|
| Disk C |    1 |  200 GB | HDD Root | ext4         |
|        |    2 |  730 GB | HDD Data | btrfs + LUKS |

- Move /data and /tree to HDD (btrfs send)
- Create a bootable system on Disk C
- Boot to "HDD Root"
- Partition Disk B
- Setup Root 1
- Configure auto mount for /tree and /data

## The Data Partition
I always try to keep my files separate from files that are not mine and generated. I don't care about preserving files I did not create.

As far as I know there are 3 types of data on my computer.
- `/root` - Operating system data. Everything needed to boot a Linux or Windows system. There is no need to preserve these files. Re-installing a Linux system is not difficult and something I do regularly.
- `/tree` -  Important personal files, everything from projects, notes, to photos. This is the only directory I actually care about. It should be backed up regularly. The current size is around 90 GB.
- `/data` -  Media files, movies, music, other stuff. I did not make these files, and they can be found again. I don't care if I loose it.

I encrypt the `/tree` partition to keep the integrity of these files. I don't want random windows programs modifying or reading this data.
If I want full system security I would have to encrypt everything and sign the boot image.

# Backup
Recovering from a backup should be as simple as possible.

If everything dies on me, I can:
1. boot from a USB with arch, And reinstall a root file-system
2. Extract the latest backup into the `/tree` partition

To recover everything I can boot from a USB and extract everything into a new file system.
To recover a single file I can extract a given sub folder or file using tar.

I would like these backup files to live on a simple unencrypted file system. This allows me to rescue some backup files when something gets corrupted on this backup disk.
A backup should be a single file that always contains all the data, and not require any other files.
I don't want multiple backups to share data on the disk.
The multiple copies allow for some data corruption to be recovered.
The encryption should be self contained per file, and not require an external key.

To perform a backup I create a zstd compressed tar archive encrypted with `age` using my long root password.
These files are tagged by their date `tree-yyyy-mm-dd.tar.zst.age`.
I choose zstd for its compression speed.

I am not using GPG because I would need to store the key somewhere.
So all I need is simple symmetric encryption with a good passphrase.
The salt should be stored in the file itself, so they are completely independent.

To perform the backup run the following:
```bash
tar -c --zstd /tree | age -e -p  -o "tree-$(date +'%F').tar.zst.age"
```

Recover data:
```bash
age -d "tree-yyyy-mm-dd.tar.zst.age" | tar -x --zstd
```

## Dual Root
I split my system into two symmetric root partitions.
This allows me to install the other root partition from the current one and then switch.
After a switch I can still access the files from the previous partition and copy them over.
This allows me to completely reinstall the system with little effort.
My goal is to achieve something similar as docker or vm images, but fast, simple and on bare metal.
The system configuration should be stored in `/tree` as bash scripts or direct configuration files.
This configuration can be applied on a lean root partition.

An alternative method could be to have a single big root partition and a smaller "Recovery" partition.
This wastes less space, but I cannot easily reinstall a system, as I might lose data that was not correctly stored in /data.
If something went wrong, I am stuck with the recovery system.
This is why I greatly prefer the symmetric system.

## Windows
The only reason I have windows installed is so that I can play some demanding games.
Most small games work fine on Linux, but more demanding games require Windows to perform well.
This does not mean that Windows is better or faster, not at all.
This means that these games are created, and optimized for Windows.
I don't want to deal with any issues when playing games, so I just directly boot Windows when needed.
Dual booting also allows me to keep "gaming" and "working on hobby projects" separate.

Dual booting Windows is not difficult at all with `systemd-bootd`. This bootloader automatically detects the Windows boot image and adds it to the menu.

A VM with GPU pass-through might be an option some day.

## Installing Linux

My preferred distribution is currently Arch Linux.
The simplicity of the distribution allows me to understand the entire system.

The very first time installing Arch requires creating a installation USB.
[Download the image](https://archlinux.org/download/) and write it directly to the USB.

Subsequent installations can be done directly from arch, due to the two root system we apply.

- <https://wiki.archlinux.org/title/installation_guide>
- <https://wiki.archlinux.org/title/User:Altercation/Bullet_Proof_Arch_Install>

Installation steps (simplified)
```bash

# Create the filesystem
mkfs.ext4 /dev/ROOT2
mount /dev/ROOT2 /mnt

# Mount
mount -m /dev/BOOT /mnt/boot

# Install the base archilniux filesystem
pacstrap -K /mnt base linux linux-firmware

# Set the root password
arch-chroot /mnt
passwd

> /etc/fstab
echo '/dev/nvme0n1p1 /boot vfat rw,noatime,iocharset=ascii,utf8	0 2' >> /etc/fstab
# TODO -> mount /data
```

## Install everything else
``` {.bash include="/tree/now/system/scripts/base.sh"}
```

```bash
arch-chroot /mnt

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

> /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'nl_NL.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

echo 'LANG=nl_NL.UTF-8' >> /etc/locale.conf
echo 'LC_MESSAGES=en_US.UTF-8' >> /etc/locale.conf
echo 'pctom' > /etc/hostname
```

## Bootloader

```bash
bootctl install
```

### `/boot/loader/loader.conf`

```
default arch.conf
timeout 2
console-mode keep
```


### `/boot/loader/entries/arch.conf`

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root="LABEL=ARCH_ROOT" rw
```

## Enable Network
`/etc/systemd/network/10-ether.network`
```ini
[Match]
Type=ether

[Network]
DHCP=yes
```

```bash
systemctl enable --now systemd-resolved systemd-networkd
```

```bash
pacman -Syy
```


# Extras

## Starting a QEMU emulator
The ovmf bios makes QEMU boot with uefi.

```bash
pacman -S qemu-img qemu-system-x86_64 edk2-ovmf
qemu-img create -f qcow2 root.qcow2 8G
qemu-system-x86_64 --enable-kvm --cpu host -bios /usr/share/ovmf/x64/OVMF.fd -boot d -m 2G -cdrom ./archlinux-2023.05.03-x86_64.iso -hda root0.qcow2 -display gtk -vga virtio
```

## Encrypted btrfs root
I played around with a LUKS encrypted btrfs root.


## Android

How do I sync my phone with my /tree?
What do I want to sync? Only Photos?
