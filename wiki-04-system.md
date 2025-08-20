# 04. System Configuration

> **Configuring the base Arch Linux system for optimal performance**

## 🎯 Overview

After installing the base system, we need to:
- Configure locale and timezone
- Set up users and permissions
- Configure the bootloader
- Set up networking
- Enable essential services
- Configure system optimization

## 🌍 Locale and Timezone

### Set Timezone
```bash
# Find your timezone
timedatectl list-timezones | grep -i new_york

# Set timezone (adjust to your location)
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Sync hardware clock
hwclock --systohc
```

### Configure Locale
```bash
# Edit locale file
vim /etc/locale.gen

# Uncomment your locale (remove the # at the beginning):
# en_US.UTF-8 UTF-8
# And any other locales you need

# Generate locales
locale-gen

# Set system locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set console keyboard layout (if not US)
echo "KEYMAP=us" > /etc/vconsole.conf
```

## 🖥️ Hostname Configuration

```bash
# Set hostname (choose your own)
echo "archfast" > /etc/hostname

# Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archfast.localdomain archfast
EOF
```

## 👤 User Management

### Set Root Password
```bash
# Set a strong root password
passwd
# Enter password twice
```

### Create Your User
```bash
# Create user with home directory
useradd -m -G wheel -s /bin/bash yourusername

# Set password
passwd yourusername

# Add to additional groups
usermod -aG video,audio,storage,optical,power yourusername
```

### Configure Sudo
```bash
# Install sudo if not already installed
pacman -S sudo

# Edit sudoers file (use visudo for safety)
EDITOR=vim visudo

# Uncomment this line (remove the #):
# %wheel ALL=(ALL:ALL) ALL

# For no password sudo (optional, less secure):
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL
```

## 🔐 Configure mkinitcpio

```bash
# Edit mkinitcpio configuration
vim /etc/mkinitcpio.conf
```

Make these changes:
```bash
# Add to MODULES
MODULES=(btrfs)

# Modify HOOKS (ensure these are in order)
HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

Important: `encrypt` must come before `filesystems`!

```bash
# Regenerate initramfs
mkinitcpio -P
```

## 🚀 Bootloader Setup (systemd-boot)

### Install systemd-boot
```bash
# Install bootloader
bootctl --path=/boot install
```

### Configure Loader
```bash
# Create loader configuration
cat > /boot/loader/loader.conf << EOF
default  arch.conf
timeout  3
console-mode max
editor   no
EOF
```

### Create Boot Entry
```bash
# Get UUID of encrypted partition
blkid -s UUID -o value /dev/nvme0n1p2 > /tmp/uuid.txt

# Create Arch boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=$(cat /tmp/uuid.txt):cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 nowatchdog
EOF

# Create fallback entry
cat > /boot/loader/entries/arch-fallback.conf << EOF
title   Arch Linux (Fallback)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux-fallback.img
options cryptdevice=UUID=$(cat /tmp/uuid.txt):cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
EOF
```

### Update systemd-boot
```bash
# Update bootloader
bootctl update

# Verify configuration
bootctl status
```

## 🌐 Network Configuration

### Install NetworkManager
```bash
# Install NetworkManager and related tools
pacman -S networkmanager nm-connection-editor networkmanager-openvpn
```

### Enable NetworkManager
```bash
# Enable for automatic start
systemctl enable NetworkManager

# Disable conflicting services if they exist
systemctl disable dhcpcd 2>/dev/null
systemctl disable netctl 2>/dev/null
```

### Configure DNS (Optional)
```bash
# Use Cloudflare DNS
cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
EOF

# Make immutable to prevent NetworkManager from changing it
chattr +i /etc/resolv.conf
```

## ⚡ System Services

### Essential Services
```bash
# Enable essential services
systemctl enable sshd                  # SSH server
systemctl enable fstrim.timer          # Weekly TRIM for SSDs
systemctl enable systemd-timesyncd     # Time synchronization
systemctl enable reflector.timer       # Update mirrorlist weekly
```

### Power Management
```bash
# For laptops - install TLP
pacman -S tlp tlp-rdw

# Enable TLP
systemctl enable tlp
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

# For all systems - thermald
pacman -S thermald
systemctl enable thermald
```

## 🔧 System Optimization

### Pacman Configuration
```bash
# Edit pacman configuration
vim /etc/pacman.conf
```

Make these changes:
```ini
# Uncomment these lines:
Color
CheckSpace
VerbosePkgLists
ParallelDownloads = 5

# Under [options], add:
ILoveCandy

# Uncomment multilib repository (for 32-bit support):
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Update package database:
```bash
pacman -Syy
```

### Makepkg Optimization
```bash
# Edit makepkg configuration
vim /etc/makepkg.conf
```

Optimize for your CPU:
```bash
# Use all CPU cores for compilation
MAKEFLAGS="-j$(nproc)"

# Optimize for native CPU
CFLAGS="-march=native -O2 -pipe -fno-plt"
CXXFLAGS="${CFLAGS}"

# Use all cores for compression
COMPRESSZST=(zstd -c -z -q -T0 -)
COMPRESSXZ=(xz -c -z -T0 -)
```

### ZRAM Configuration
```bash
# Install zram-generator
pacman -S zram-generator

# Configure ZRAM
cat > /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# The service will start automatically on next boot
```

### Kernel Parameters
```bash
# Edit boot entry
vim /boot/loader/entries/arch.conf
```

Add these parameters to the options line:
```
mitigations=off              # Disable CPU vulnerability mitigations (faster but less secure)
nowatchdog                   # Disable watchdog
module_blacklist=iTCO_wdt    # Blacklist watchdog module
quiet                        # Less verbose boot
loglevel=3                   # Reduce kernel messages
```

## 📦 Install Essential Packages

```bash
# Development tools
pacman -S base-devel git wget curl

# Text editors
pacman -S vim nano

# File management
pacman -S unzip unrar p7zip rsync

# System monitoring
pacman -S htop btop neofetch

# Hardware info
pacman -S lshw pciutils usbutils

# Filesystem tools
pacman -S dosfstools ntfs-3g exfat-utils

# Manual pages
pacman -S man-db man-pages texinfo
```

## 🔊 Audio System Setup

```bash
# Install PipeWire (modern audio system)
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Enable PipeWire services (run as user after reboot)
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber
```

## 🖨️ Additional Hardware Support

### Bluetooth
```bash
# Install Bluetooth support
pacman -S bluez bluez-utils

# Enable Bluetooth
systemctl enable bluetooth
```

### Printing
```bash
# Install CUPS for printing
pacman -S cups cups-pdf

# Enable CUPS
systemctl enable cups
```

### Laptop Specific
```bash
# Battery management
pacman -S acpi acpid acpi_call

# Enable ACPI
systemctl enable acpid

# Touchpad support (will be configured in Hyprland)
pacman -S xf86-input-libinput
```

## 🛡️ Firewall Setup

```bash
# Install firewalld
pacman -S firewalld

# Enable firewall
systemctl enable firewalld

# Basic configuration (after reboot)
# firewall-cmd --set-default-zone=home
# firewall-cmd --permanent --zone=home --add-service=ssh
# firewall-cmd --reload
```

## 📝 Final System Check

Before rebooting, verify:

```bash
# Check for errors in configuration
mkinitcpio -P

# Verify bootloader
bootctl status

# Check fstab
cat /etc/fstab

# Verify user exists
id yourusername

# Check enabled services
systemctl list-unit-files --state=enabled
```

## 🔄 First Reboot

```bash
# Exit chroot
exit

# Unmount all partitions
umount -R /mnt

# Reboot
reboot
```

## 🎉 Post-Reboot Tasks

After successful reboot:

1. **Login as your user** (not root)
2. **Connect to network**:
   ```bash
   nmtui  # For WiFi setup
   ```
3. **Update system**:
   ```bash
   sudo pacman -Syu
   ```
4. **Install yay AUR helper**:
   ```bash
   git clone https://aur.archlinux.org/yay-bin.git
   cd yay-bin
   makepkg -si
   cd ..
   rm -rf yay-bin
   ```

---

<div align="center">

[← Previous: Disk Setup](03-Disk-Setup) • [Next: Hyprland Setup →](05-Hyprland-Setup)

</div>