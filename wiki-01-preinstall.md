# 01. Pre-Installation

> **Preparing for your Arch Linux Hyprland installation**

## 📋 Overview

Before we begin installing Arch Linux, we need to:
1. Check system requirements
2. Download and verify the ISO
3. Create bootable media
4. Configure BIOS/UEFI settings
5. Understand what we're building

## 🖥️ System Requirements

### Minimum Requirements
- **CPU**: Any x86_64 processor
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free space (50GB recommended)
- **Network**: Internet connection for installation
- **Boot Mode**: UEFI (required for this guide)

### Checking Your Current System
If you're installing on an existing system, check your specifications:

```bash
# On Linux
lscpu                    # CPU information
free -h                  # RAM information
lsblk                    # Disk information
ls /sys/firmware/efi     # Check for UEFI mode
```

```powershell
# On Windows
systeminfo               # System information
wmic cpu get name        # CPU information
wmic memorychip get capacity  # RAM information
```

## 💿 Downloading Arch Linux

### 1. Download the ISO
Visit the official Arch Linux download page:
```bash
# Download via terminal (if on Linux)
wget https://archlinux.org/iso/latest/archlinux-x86_64.iso
wget https://archlinux.org/iso/latest/archlinux-x86_64.iso.sig
```

Or download from: https://archlinux.org/download/

### 2. Verify the ISO
**Important**: Always verify your ISO to ensure it hasn't been tampered with.

```bash
# Import the Arch Linux signing key
gpg --keyserver keyserver.ubuntu.com --recv-keys 0x3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C

# Verify the signature
gpg --verify archlinux-x86_64.iso.sig archlinux-x86_64.iso
```

You should see "Good signature" in the output.

## 🔧 Creating Bootable Media

### Option 1: Using dd (Linux/macOS)
```bash
# Find your USB device
lsblk
# or
sudo fdisk -l

# Write the ISO (replace /dev/sdX with your USB device)
# WARNING: This will erase all data on the USB!
sudo dd bs=4M if=archlinux-x86_64.iso of=/dev/sdX status=progress oflag=sync

# Sync and safely remove
sync
```

### Option 2: Using Rufus (Windows)
1. Download Rufus from https://rufus.ie/
2. Insert your USB drive (8GB minimum)
3. Select the Arch Linux ISO
4. Choose:
   - Partition scheme: GPT
   - Target system: UEFI
   - File system: FAT32
4. Click "Start"

### Option 3: Using Ventoy (Multi-boot USB)
1. Download Ventoy from https://www.ventoy.net/
2. Install Ventoy to your USB
3. Copy the Arch ISO to the USB
4. Boot from the USB and select the Arch ISO

## ⚙️ BIOS/UEFI Configuration

### Enter BIOS/UEFI Settings
- **Common keys**: F2, F10, F12, DEL, ESC
- Press the key repeatedly during boot

### Required Settings

#### 1. Boot Mode
- **Enable**: UEFI Mode
- **Disable**: Legacy/CSM Mode
- **Disable**: Secure Boot (temporarily, we'll enable it later)

#### 2. Storage Configuration
- **SATA Mode**: AHCI (not RAID unless needed)
- **NVMe**: Ensure it's detected

#### 3. Security Settings
- **Secure Boot**: Disabled (for now)
- **TPM**: Can be enabled (optional)

#### 4. For Laptops
- **Battery Settings**: Optimal for installation
- **Graphics**: Use integrated if having issues

### Save and Exit
- Save changes (usually F10)
- System will reboot

## 📊 Understanding Our Setup

### What We're Building

```
┌─────────────────────────────────────┐
│         UEFI Firmware               │
├─────────────────────────────────────┤
│      systemd-boot (Bootloader)      │
├─────────────────────────────────────┤
│        LUKS2 Encryption             │
├─────────────────────────────────────┤
│         BTRFS Filesystem            │
│  ┌─────────────┬─────────────────┐  │
│  │  @ (root)   │  @home (home)   │  │
│  └─────────────┴─────────────────┘  │
├─────────────────────────────────────┤
│         Arch Linux Base             │
├─────────────────────────────────────┤
│      Hyprland (Wayland WM)          │
├─────────────────────────────────────┤
│    Applications & User Space        │
└─────────────────────────────────────┘
```

### Why These Choices?

#### BTRFS over EXT4
- **Snapshots**: Instant system backups
- **Compression**: Save disk space
- **Subvolumes**: Better organization
- **Copy-on-Write**: Data integrity

#### LUKS Encryption
- **Full disk encryption**: Everything is encrypted
- **Strong security**: AES-256 encryption
- **Performance**: Hardware acceleration on modern CPUs

#### Hyprland
- **Wayland**: Modern display protocol
- **Performance**: Extremely fast and efficient
- **Customizable**: Full control over everything
- **Active Development**: Regular updates

#### ZRAM over Swap
- **No disk writes**: Better for SSDs
- **Faster**: RAM is faster than disk
- **Dynamic**: Only uses what's needed
- **Compression**: Effectively increases RAM

## 📝 Pre-Installation Checklist

Before proceeding, ensure you have:

- [ ] **Backed up important data**
- [ ] Downloaded and verified Arch ISO
- [ ] Created bootable USB
- [ ] **Internet connection** ready (WiFi password or Ethernet)
- [ ] At least **1 hour** of uninterrupted time
- [ ] **Power adapter** connected (for laptops)
- [ ] Disabled Secure Boot in BIOS
- [ ] Enabled UEFI mode
- [ ] This guide accessible on another device

## 🌐 Network Preparation

### WiFi Networks
Know your WiFi credentials:
- Network name (SSID)
- Password
- Security type (usually WPA2)

### Ethernet
- Ensure cable is connected
- Should work automatically

### Mobile Hotspot (Backup)
- Can use phone as hotspot
- USB tethering also works

## 💡 Tips

### For Beginners
- **Read each step twice** before executing
- **Take photos** of any errors
- **Don't rush** - accuracy is more important than speed
- **Ask for help** if unsure about anything

### For Virtual Machines
If testing in a VM first:
- Allocate at least 20GB disk
- 4GB RAM minimum
- Enable EFI in VM settings
- Enable virtualization features

### Backup Installation Media
Consider creating a second USB with:
- SystemRescue CD
- Another Linux live USB
- Windows installation media (if dual-booting)

## ⚠️ Warnings

### Data Loss
**This installation will ERASE your entire disk!**
- Backup all important data
- Verify backups are accessible
- Consider using a spare drive for first attempt

### Hardware Compatibility
Most hardware works, but check:
- WiFi card compatibility
- Graphics card (NVIDIA may need extra steps)
- Special laptop features (fingerprint, etc.)

## 🚦 Ready to Proceed?

If you've completed all the preparation steps:
- ✅ ISO downloaded and verified
- ✅ Bootable USB created
- ✅ BIOS configured correctly
- ✅ Data backed up
- ✅ Network credentials ready

**You're ready to begin the installation!**

---

<div align="center">

[← Back to Home](Home) • [Next: Base Installation →](02-Base-Installation)

</div>