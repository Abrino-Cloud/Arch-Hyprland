# 02. Base Installation

> **Installing the Arch Linux base system**

## 🚀 Booting the Installation Media

### 1. Insert USB and Boot
- Insert your Arch Linux USB
- Power on/restart your computer
- Press boot menu key (F12, F11, ESC - varies by manufacturer)
- Select your USB device (UEFI mode)

### 2. Arch Boot Menu
You'll see the Arch boot menu. Select:
```
Arch Linux install medium (x86_64, UEFI)
```

Wait for the system to boot. You'll see lots of text scrolling - this is normal.

### 3. Welcome Screen
You should see:
```
root@archiso ~ #
```

Congratulations! You're in the Arch Linux live environment.

## 🔧 Initial Setup

### 1. Set Larger Font (Optional)
For high-DPI displays or better readability:
```bash
setfont ter-132b
```

### 2. Verify Boot Mode
Ensure you're in UEFI mode:
```bash
cat /sys/firmware/efi/fw_platform_size
```
Should output: `64` (for 64-bit UEFI)

If file doesn't exist, you're in BIOS mode - restart and check BIOS settings.

### 3. Check System Date/Time
```bash
timedatectl status
```

## 🌐 Connect to Internet

### Option 1: Ethernet (Easiest)
```bash
# Should work automatically, test with:
ping -c 3 archlinux.org
```

### Option 2: WiFi
```bash
# Enter the interactive WiFi setup
iwctl

# Inside iwctl, run these commands:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "Your-WiFi-Name"
# Enter password when prompted
exit

# Verify connection
ping -c 3 archlinux.org
```

### Option 3: Mobile Hotspot (USB Tethering)
```bash
# Connect phone via USB, enable USB tethering
# Check for new interface
ip link
# Should show something like 'enp0s20f0u1'
```

### Troubleshooting Connection
```bash
# Check interfaces
ip link

# Check IP address
ip addr

# Restart networking
systemctl restart systemd-networkd
systemctl restart systemd-resolved
```

## 🕒 Update System Clock
```bash
# Enable NTP
timedatectl set-ntp true

# Set timezone (adjust to your location)
timedatectl set-timezone America/New_York
# Or find your timezone:
timedatectl list-timezones | grep -i york

# Verify
timedatectl status
```

## 💾 Disk Partitioning

### 1. Identify Your Disk
```bash
# List all disks
lsblk

# Or more detailed
fdisk -l
```

Common disk names:
- **NVMe SSD**: `/dev/nvme0n1`
- **SATA SSD/HDD**: `/dev/sda`
- **Second disk**: `/dev/sdb`

⚠️ **WARNING**: The next steps will ERASE your disk!

### 2. Partition the Disk
We'll create two partitions:
- **EFI**: 512MB for boot files
- **Main**: Rest of disk for encrypted system

```bash
# Replace /dev/nvme0n1 with your disk
gdisk /dev/nvme0n1
```

Inside gdisk:
```
Command: o
This option deletes all partitions. Proceed? (Y/N): y

Command: n
Partition number: 1
First sector: (press Enter for default)
Last sector: +512M
Hex code: ef00

Command: n
Partition number: 2
First sector: (press Enter for default)
Last sector: (press Enter for default - use rest of disk)
Hex code: 8300

Command: p  (to verify partitions)

Command: w
Do you want to proceed? (Y/N): y
```

### 3. Verify Partitions
```bash
lsblk
```
You should see:
- `/dev/nvme0n1p1` - 512M EFI partition
- `/dev/nvme0n1p2` - Main partition

## 🔐 Setup Encryption

### 1. Encrypt Main Partition
```bash
# Setup LUKS encryption (you'll create a password)
cryptsetup luksFormat --type luks2 /dev/nvme0n1p2

# Confirm with YES (capital letters)
# Enter a strong password (you'll need this every boot!)
# Confirm password
```

### 2. Open Encrypted Partition
```bash
# Open the encrypted partition
cryptsetup open /dev/nvme0n1p2 cryptroot
# Enter the password you just created
```

## 📁 Create Filesystem

### 1. Format Partitions
```bash
# Format EFI partition
mkfs.fat -F32 /dev/nvme0n1p1

# Format main partition with BTRFS
mkfs.btrfs /dev/mapper/cryptroot
```

### 2. Create BTRFS Subvolumes
```bash
# Mount the BTRFS partition
mount /dev/mapper/cryptroot /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@cache

# List subvolumes to verify
btrfs subvolume list /mnt

# Unmount
umount /mnt
```

### 3. Mount with Proper Options
```bash
# Mount root subvolume
mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt

# Create directories
mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache}

# Mount boot partition
mount /dev/nvme0n1p1 /mnt/boot

# Mount other subvolumes
mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@cache /dev/mapper/cryptroot /mnt/var/cache
```

### 4. Verify Mounts
```bash
# Check everything is mounted correctly
lsblk
mount | grep /mnt
```

## 📦 Install Base System

### 1. Update Mirrorlist (Optional but Recommended)
```bash
# Backup original
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Update to fastest mirrors (adjust country to yours)
reflector --country "United States" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### 2. Install Essential Packages
```bash
pacstrap -K /mnt \
  base \
  linux \
  linux-firmware \
  linux-headers \
  base-devel \
  btrfs-progs \
  intel-ucode \
  amd-ucode \
  networkmanager \
  vim \
  nano \
  git \
  sudo
```

Note: Both intel-ucode and amd-ucode are installed; the system will use the appropriate one.

## 📝 Generate Fstab

```bash
# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Verify it looks correct
cat /mnt/etc/fstab
```

You should see entries for all your mounted partitions.

## 🔄 Chroot into New System

```bash
# Change root into the new system
arch-chroot /mnt
```

Your prompt should change to show you're in the new system.

## ⚡ Quick Progress Check

At this point, you have:
- ✅ Booted the live environment
- ✅ Connected to internet
- ✅ Partitioned the disk
- ✅ Set up encryption
- ✅ Created BTRFS filesystem with subvolumes
- ✅ Installed base system
- ✅ Generated fstab
- ✅ Chrooted into new system

## 🚨 Common Issues & Solutions

### Can't connect to WiFi
```bash
# Check if interface is up
ip link set wlan0 up

# Restart iwd service
systemctl restart iwd

# Try manual connection
iwctl station wlan0 connect "SSID" --passphrase "password"
```

### Slow download speeds