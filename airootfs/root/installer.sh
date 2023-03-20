#!/bin/bash
# Thanks to CalimeroTeknik on #archlinux-fr, FFY00 on #archlinux-projects, JohnDoe2 on #regex
# Thanks to original author of this script eoli3n - https://github.com/eoli3n/arch-config/tree/master/scripts/zfs/install

# Uncomment for debugging
set -x

exec &> >(tee "debug.log")

### Vars

verbose=0
read -r -p "> ZFS passphrase: " -s pass
read -r -p 'Please enter hostname : ' hostname
read -r -p "Enter your keymap: " keymap
read -r -p "Enter your locale: " locale
### Configure username
print 'Set your username'
read -r -p "Username: " user

### Functions
usage () {
    cat << EOF
Usage: ${0##*/} [-v]
    -v    increase verbosity
    -h    show this usage
EOF
}

print () {
    echo -e "\n\033[1m> $1\033[0m"
}

get_running_kernel_version () {
# Returns running kernel version
    # Get running kernel version
    kernel_version=$(uname -r)
    print "Current kernel version is $kernel_version"
}

init_archzfs () {
    if pacman -Sl archzfs >&3; then
        print "archzfs repo was already added"
        return 0
    fi
    print "Add archzfs repo"
    
    # Disable Sig check
    pacman -Syy archlinux-keyring --noconfirm >&3 || return 1
    pacman-key --populate archlinux >&3 || return 1
    pacman-key --recv-keys F75D9D76 >&3 || return 1
    pacman-key --lsign-key F75D9D76 >&3 || return 1
    cat >> /etc/pacman.conf <<"EOF"
[archzfs]
Server = http://archzfs.com/archzfs/x86_64
Server = http://mirror.sum7.eu/archlinux/archzfs/archzfs/x86_64
Server = https://mirror.biocrafting.net/archlinux/archzfs/archzfs/x86_64
EOF
    pacman -Sy >&3 || return 1
    return 0
}

init_archlinux_archive () {
# $1 is date formated as 'YYYY/MM/DD'
# Returns 1 if repo does not exists

    # Archlinux Archive workaround for 2022/02/01
    if [[ "$1" == "2022/02/01" ]]
    then
        version="2022/02/02"
    else
        version="$1"
    fi

    # Set repo
    repo="https://archive.archlinux.org/repos/$version/"

    # If repo exists, set it
    if curl -s "$repo" >&3
    then
        echo "Server=$repo\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
    else
        print "Repository $repo is not reachable or doesn't exist."
        return 1
    fi

    return 0
}

search_package () {
# $1 is package name to search
# $2 is version to match

    # Set regex to match package
    local regex='href="\K(?![^"]*\.sig)'"$1"'-(?=\d)[^"]*'"$2"'[^"]*x86_64[^"]*'
    # href="               # match href="
    # \K                   # don't return anything matched prior to this point
    # (?![^"]*\.sig)       # remove .sig matches
    # '"$1"'-(?=\d)        # find me '$package-' escaped by shell and ensure that after "-" is a digit
    # [^"]*                # match anything between '"'
    # '"$2"'               # match version escaped by shell
    # [^"]*                # match anything between '"'
    # x86_64               # now match architecture
    # [^"]*                # match anything between '"'
    
    # Set archzfs URLs list
    local urls="http://archzfs.com/archzfs/x86_64/ http://archzfs.com/archive_archzfs/"
    
    # Loop search
    for url in $urls
    do
    
        print "Searching $1 on $url..."
    
        # Query url and try to match package
        local package=$(curl -s "$url" | grep -Po "$regex" | tail -n 1)
    
        # If a package is found
        if [[ -n $package ]]
        then
    
            print "Package \"$package\" found"
    
            # Build package url
            package_url="$url$package"
            return 0
        fi
    done

    # If no package found
    return 1
}

download_package () {
# $1 is package url to download in tmp

    print "Download to $package_file ..."

    local filename="${1##*/}"

    # Download package in tmp
    cd /tmp
    curl -sO "$1" || return 1
    cd -

    # Set out file
    package_file="/tmp/$filename"

    return 0
}

dkms_init () {
# Init everything to be able to install zfs-dkms

    print "Init Archlinux Archive repository"
    archiso_version=$(sed 's-\.-/-g' /version)
    init_archlinux_archive "$archiso_version" || return 1

    print "Download Archlinux Archives package lists and upgrade"
    pacman -Syyuu --noconfirm >&3 || return 1

    print "Install base-devel"
    pacman -S --needed --noconfirm base-devel linux-headers git >&3 || return 1

    return 0
}

### Getopts

while getopts "vh" option; do
    case "${option}" in
        v)
            verbose=$((verbose + 1))
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

### Verbose mode

if [[ "$verbose" -gt 0 ]]
then
    exec 3>&1
else
    exec 3>/dev/null
fi

### Main

# Test if archiso is running

if ! grep 'arch.*iso' /proc/cmdline >&3
then
    print "You are not running archiso, exiting."
    exit 1
fi
print "Increase cowspace to half of RAM"

mount -o remount,size=50% /run/archiso/cowspace >&3

# Init archzfs repository
init_archzfs || exit 1

# Search kernel package
# https://github.com/archzfs/archzfs/issues/337#issuecomment-624312576
get_running_kernel_version
kernel_version_fixed="${kernel_version//-/\.}"

# Search zfs-linux package matching running kernel version
if search_package "zfs-linux" "$kernel_version_fixed"
then

    zfs_linux_url="$package_url"

    # Download package
    download_package "$zfs_linux_url" || exit 1
    zfs_linux_package="$package_file"

    print "Extracting zfs-utils version from zfs-linux PKGINFO"

    # Extract zfs-utils version from zfs-linux PKGINFO
    zfs_utils_version=$(bsdtar -qxO -f "$zfs_linux_package" .PKGINFO | grep -Po 'depend = zfs-utils=\K.*')

    # Search zfs-utils package matching zfs-linux package dependency
    if search_package "zfs-utils" "$zfs_utils_version"
    then
        zfs_utils_url="$package_url"

        print "Installing zfs-utils and zfs-linux"

        # Install packages
        if pacman -U "$zfs_utils_url" --noconfirm >&3 && pacman -U "$zfs_linux_package" --noconfirm >&3
        then
            zfs=1
        fi
    fi
else

    # DKMS fallback
    print "No zfs-linux package was found for current running kernel, fallback on DKMS method"
    dkms_init

    print "Install zfs-dkms"
    
    # Install package
    if pacman -S zfs-dkms --needed --noconfirm >&3
    then
        zfs=1
    fi
fi

# Load kernel module
if [[ "$zfs" == "1" ]]
then

    modprobe zfs && echo -e "\n\e[32mZFS is ready\n"

else
    print "No ZFS module found"
fi


set -e

exec &> >(tee "configure.log")

print () {
    echo -e "\n\033[1m> $1\033[0m\n"
}

ask () {
    read -p "> $1 " -r
    echo
}

menu () {
    PS3="> Choose a number: "
    select i in "$@"
    do 
        echo "$i"
        break
    done
}

# Tests
tests () {
    ls /sys/firmware/efi/efivars > /dev/null &&   \
        ping archlinux.org -c 1 > /dev/null &&    \
        timedatectl set-ntp true > /dev/null &&   \
        modprobe zfs &&                           \
        print "Tests ok"
}

select_disk () {
    # Set DISK
    select ENTRY in $(ls /dev/disk/by-id/);
    do
        DISK="/dev/disk/by-id/$ENTRY"
        echo "$DISK" > /tmp/disk
        echo "Installing on $ENTRY."
        break
    done
}

wipe () {
    ask "Do you want to wipe all datas on $ENTRY ?"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Clear disk
        dd if=/dev/zero of="$DISK" bs=512 count=1
        wipefs -af "$DISK"
        sgdisk -Zo "$DISK"
    fi
}

partition () {
    # EFI part
    print "Creating EFI part"
    sgdisk -n1:1M:+512M -t1:EF00 "$DISK"
    EFI="$DISK-part1"
    
    # ZFS part
    print "Creating ZFS part"
    sgdisk -n3:0:0 -t3:bf01 "$DISK"
    
    # Inform kernel
    partprobe "$DISK"
    
    # Format efi part
    sleep 1
    print "Format EFI part"
    mkfs.vfat "$EFI"
}

zfs_passphrase () {
    # Generate key
    print "Set ZFS passphrase"
    echo "$pass" > /etc/zfs/zroot.key
    chmod 000 /etc/zfs/zroot.key
}

create_pool () {
    # ZFS part
    ZFS="$DISK-part3"
    
    # Create ZFS pool
    print "Create ZFS pool"
    zpool create -f -o ashift=12                          \
                 -o autotrim=on                           \
                 -O acltype=posixacl                      \
                 -O compression=zstd                      \
                 -O relatime=on                           \
                 -O xattr=sa                              \
                 -O dnodesize=legacy                      \
                 -O encryption=aes-256-gcm                \
                 -O keyformat=passphrase                  \
                 -O keylocation=file:///etc/zfs/zroot.key \
                 -O normalization=formD                   \
                 -O mountpoint=none                       \
                 -O canmount=off                          \
                 -O devices=off                           \
                 -R /mnt                                  \
                 zroot "$ZFS"
}

create_root_dataset () {
    # Slash dataset
    print "Create root dataset"
    zfs create -o mountpoint=none                 zroot/ROOT

    # Set cmdline
    zfs set org.zfsbootmenu:commandline="ro quiet" zroot/ROOT
}

create_system_dataset () {
    #'print "Create slash dataset"
    zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/"$1"

    # Generate zfs hostid
    print "Generate hostid"
    zgenhostid
    
    # Set bootfs 
    print "Set ZFS bootfs"
    zpool set bootfs="zroot/ROOT/$1" zroot

    # Manually mount slash dataset
    zfs mount zroot/ROOT/"$1"
}

create_home_dataset () {
    print "Create home dataset"
    zfs create -o mountpoint=/ -o canmount=off zroot/data
    zfs create zroot/data/home
}

export_pool () {
    print "Export zpool"
    zpool export zroot
}

import_pool () {
    print "Import zpool"
    zpool import -d /dev/disk/by-id -R /mnt zroot -N -f
    zfs load-key zroot
}

mount_system () {
    print "Mount slash dataset"
    zfs mount zroot/ROOT/"$1"
    zfs mount -a
    
    # Mount EFI part
    print "Mount EFI part"
    EFI="$DISK-part1"
    mkdir -p /mnt/efi
    mount "$EFI" /mnt/efi
}

copy_zpool_cache () {
    # Copy ZFS cache
    print "Generate and copy zfs cache"
    mkdir -p /mnt/etc/zfs
    zpool set cachefile=/etc/zfs/zpool.cache zroot
}

# Main

tests

print "Is this the first install or a second install to dualboot ?"
install_reply=$(menu first dualboot)

select_disk
zfs_passphrase

# If first install
if [[ $install_reply == "first" ]]
then
    # Wipe the disk
    wipe
    # Create partition table
    partition
    # Create ZFS pool
    create_pool
    # Create root dataset
    create_root_dataset
fi

ask "Name of the slash dataset ?"
name_reply="$REPLY"
echo "$name_reply" > /tmp/root_dataset

if [[ $install_reply == "dualboot" ]]
then
    import_pool
fi

create_system_dataset "$name_reply"

if [[ $install_reply == "first" ]]
then
    create_home_dataset
fi

export_pool
import_pool
mount_system "$name_reply"
copy_zpool_cache

# Finish
echo -e "\e[32mAll OK"

#!/usr/bin/env bash

set -e

exec &> >(tee "install.log")

# Debug
if [[ "$1" == "debug" ]]
then
    set -x
    debug=1
fi

print () {
    echo -e "\n\033[1m> $1\033[0m\n"
    if [[ -n "$debug" ]]
    then
      read -rp "press enter to continue"
    fi
}

# Root dataset
root_dataset=$(cat /tmp/root_dataset)

# Sort mirrors
print "Sort mirrors"
systemctl start reflector

# Install
print "Install Arch Linux"
pacstrap /mnt       \
  base              \
  base-devel        \
  linux-lts         \
  linux-lts-headers \
  linux-firmware    \
  intel-ucode       \
  efibootmgr        \
  vim               \
  git               \
  ansible           \
  iwd               \
  wpa_supplicant    \
  rsync             \
  arse-desktop      

# Generate fstab excluding ZFS entries
print "Generate fstab excluding ZFS entries"
genfstab -U /mnt | grep -v "zroot" | tr -s '\n' | sed 's/\/mnt//'  > /mnt/etc/fstab

# Set hostname
echo "$hostname" > /mnt/etc/hostname

# Configure /etc/hosts
print "Configure hosts file"
cat > /mnt/etc/hosts <<EOF
#<ip-address>	<hostname.domain.org>	<hostname>
127.0.0.1	    localhost   	        $hostname
::1   		    localhost              	$hostname
EOF

# Prepare locales and keymap

print "Prepare locales and keymap"
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf
echo "$locale" >> /mnt/etc/locale.gen
echo "LANG=$locale" >> /mnt/etc/locale.conf

# Prepare initramfs
print "Prepare initramfs"
cat > /mnt/etc/mkinitcpio.conf <<"EOF"
MODULES=(i915 intel_agp)
BINARIES=()
FILES=(/etc/zfs/zroot.key)
HOOKS=(base udev autodetect modconf block keyboard keymap zfs filesystems)
COMPRESSION="zstd"
EOF

cat > /mnt/etc/mkinitcpio.d/linux-lts.preset <<"EOF"
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-lts"
PRESETS=('default')
default_image="/boot/initramfs-linux-lts.img"
EOF

print "Copy ZFS files"
cp /etc/hostid /mnt/etc/hostid
cp /etc/zfs/zpool.cache /mnt/etc/zfs/zpool.cache
cp /etc/zfs/zroot.key /mnt/etc/zfs

# Chroot and configure
print "Chroot and configure system"

arch-chroot /mnt /bin/bash -xe <<EOF

  ### Reinit keyring
  # As keyring is initialized at boot, and copied to the install dir with pacstrap, and ntp is running
  # Time changed after keyring initialization, it leads to malfunction
  # Keyring needs to be reinitialised properly to be able to sign archzfs key.
  rm -Rf /etc/pacman.d/gnupg
  pacman-key --init
  pacman-key --populate archlinux
  pacman-key --recv-keys F75D9D76 --keyserver keyserver.ubuntu.com
  pacman-key --lsign-key F75D9D76
  pacman -S archlinux-keyring --noconfirm
  cat >> /etc/pacman.conf <<"EOSF"
[archzfs]
Server = http://archzfs.com/archzfs/x86_64
Server = http://mirror.sum7.eu/archlinux/archzfs/archzfs/x86_64
Server = https://mirror.biocrafting.net/archlinux/archzfs/archzfs/x86_64
[arse-repo]
SigLevel = Never
Server = http://repo.arselinux.org/repo/arselinux/x86_64/
EOSF
  pacman -Syu --noconfirm zfs-dkms zfs-utils
  # Sync clock
  hwclock --systohc
  # Generate locale
  locale-gen
  source /etc/locale.conf
  # Generate Initramfs
  mkinitcpio -P
  # Install ZFSBootMenu and deps
  git clone --depth=1 https://github.com/zbm-dev/zfsbootmenu/ /tmp/zfsbootmenu
  pacman -S cpanminus kexec-tools fzf util-linux --noconfirm
  cd /tmp/zfsbootmenu
  make
  make install
  cpanm --notest --installdeps .

  # Create user
  #zfs create zroot/data/home
  useradd -m ${user} -G wheel
  chown -R ${user}:${user} /home/${user}

EOF

# Set root passwd
print "Set root password"
arch-chroot /mnt /bin/passwd

# Set user passwd
print "Set user password"
arch-chroot /mnt /bin/passwd "$user"

# Configure sudo
print "Configure sudo"
cat > /mnt/etc/sudoers <<EOF
root ALL=(ALL) ALL
$user ALL=(ALL) ALL
Defaults rootpw
EOF

pacstrap /mnt i3-wm i3lock rofi polybar xorg xorg-xdm xorg-xinit xorg-fonts ttf-dejavu rsync alacritty python-pip arse-hooks picom python-pywal bat exa lsd dust duf broot fd ripgrep choose sd zoxide fzf mcfly 
arch-chroot /mnt /bin/pip install --no-input hyfetch

# Configure network
print "Configure networking"
cat > /mnt/etc/systemd/network/enoX.network <<"EOF"
[Match]
Name=en*

[Network]
DHCP=ipv4
IPForward=yes

[DHCP]
UseDNS=no
RouteMetric=10
EOF
cat > /mnt/etc/systemd/network/wlX.network <<"EOF"
[Match]
Name=wl*

[Network]
DHCP=ipv4
IPForward=yes

[DHCP]
UseDNS=no
RouteMetric=20
EOF
systemctl enable systemd-networkd --root=/mnt
systemctl disable systemd-networkd-wait-online --root=/mnt

mkdir /mnt/etc/iwd
cat > /mnt/etc/iwd/main.conf <<"EOF"
[General]
UseDefaultInterface=true
EnableNetworkConfiguration=true
EOF
systemctl enable iwd --root=/mnt

# Configure DNS
print "Configure DNS"
rm /mnt/etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /mnt/etc/resolv.conf
sed -i 's/^#DNS=.*/DNS=1.1.1.1/' /mnt/etc/systemd/resolved.conf
systemctl enable systemd-resolved --root=/mnt

# Activate zfs
print "Configure ZFS"
systemctl enable zfs-import-cache --root=/mnt
systemctl enable zfs-mount --root=/mnt
systemctl enable zfs-import.target --root=/mnt
systemctl enable zfs.target --root=/mnt

# Configure zfs-mount-generator
print "Configure zfs-mount-generator"
mkdir -p /mnt/etc/zfs/zfs-list.cache
touch /mnt/etc/zfs/zfs-list.cache/zroot
zfs list -H -o name,mountpoint,canmount,atime,relatime,devices,exec,readonly,setuid,nbmand | sed 's/\/mnt//' > /mnt/etc/zfs/zfs-list.cache/zroot
systemctl enable zfs-zed.service --root=/mnt

# Configure zfsbootmenu
mkdir -p /mnt/efi/EFI/ZBM

# Generate zfsbootmenu efi
print 'Configure zfsbootmenu'
# https://github.com/zbm-dev/zfsbootmenu/blob/master/etc/zfsbootmenu/mkinitcpio.conf

cat > /mnt/etc/zfsbootmenu/mkinitcpio.conf <<"EOF"
MODULES=()
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf block keyboard keymap)
COMPRESSION="zstd"
EOF

cat > /mnt/etc/zfsbootmenu/config.yaml <<EOF
Global:
  ManageImages: true
  BootMountPoint: /efi
  InitCPIO: true

Components:
  Enabled: false
EFI:
  ImageDir: /efi/EFI/ZBM
  Versions: false
  Enabled: true
Kernel:
  CommandLine: ro quiet loglevel=0 zbm.import_policy=hostid
  Prefix: vmlinuz
EOF

# Set cmdline
zfs set org.zfsbootmenu:commandline="rw quiet nowatchdog rd.vconsole.keymap=fr" zroot/ROOT/"$root_dataset"

# Generate ZBM
print 'Generate zbm'
arch-chroot /mnt /bin/bash -xe <<"EOF"

  # Export locale
  export LANG="$locale"

  # Generate zfsbootmenu
  generate-zbm
EOF

# Set DISK
if [[ -f /tmp/disk ]]
then
  DISK=$(cat /tmp/disk)
else
  print 'Select the disk you installed on:'
  select ENTRY in $(ls /dev/disk/by-id/);
  do
      DISK="/dev/disk/by-id/$ENTRY"
      echo "Creating boot entries on $ENTRY."
      break
  done
fi

# Create UEFI entries
print 'Create efi boot entries'
if ! efibootmgr | grep ZFSBootMenu
then
    efibootmgr --disk "$DISK" \
      --part 1 \
      --create \
      --label "ZFSBootMenu Backup" \
      --loader "\EFI\ZBM\vmlinuz-backup.efi" \
      --verbose
    efibootmgr --disk "$DISK" \
      --part 1 \
      --create \
      --label "ZFSBootMenu" \
      --loader "\EFI\ZBM\vmlinuz.efi" \
      --verbose
else
    print 'Boot entries already created'
fi

# Umount all parts
print "Umount all parts"
umount /mnt/efi
zfs umount -a

# Export zpool
print "Export zpool"
zpool export zroot

# Finish
echo -e "\e[32mAll OK"
