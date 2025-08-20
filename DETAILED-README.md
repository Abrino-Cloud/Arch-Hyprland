# 🛡️ Arch Hyprland Bare - Complete Installation Guide

**Zero-animation Hyprland perfection for Iranian developers**

This guide provides complete step-by-step instructions for installing Arch Linux with Hyprland, optimized for Persian users and inspired by Omarchy's bare philosophy.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Installation](#pre-installation)
- [Installation Methods](#installation-methods)
- [Post-Installation](#post-installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## 🔧 Prerequisites

### Hardware Requirements
- **Minimum**: 4GB RAM, 25GB storage
- **Recommended**: 8GB+ RAM, 50GB+ storage, SSD
- **Supported**: Intel/AMD CPUs, NVIDIA/AMD/Intel GPUs
- **Device Types**: Laptops, desktops, virtual machines

### What You'll Need
- USB stick (4GB+)
- Stable internet connection
- Keyboard with cable/2.4GHz dongle (for disk encryption)
- Backup of important data (installation wipes disk)

## 🚀 Pre-Installation

### 1. Download Arch Linux ISO
```bash
# Download latest ISO from:
https://archlinux.org/download/

# Verify checksum (recommended)
sha256sum archlinux-YYYY.MM.DD-x86_64.iso
```

### 2. Create Bootable USB
**Windows/macOS**: Use [balenaEtcher](https://etcher.balena.io/)  
**Linux**: 
```bash
sudo dd if=archlinux-YYYY.MM.DD-x86_64.iso of=/dev/sdX bs=4M status=progress
```

### 3. BIOS/UEFI Settings
- **Disable Secure Boot**
- **Enable UEFI mode** (recommended)
- **Set USB as first boot device**

### 4. Boot from USB
- Insert USB and restart
- Press F12/F8/Delete (varies by manufacturer) for boot menu
- Select USB device

## 🌐 Network Setup

### WiFi Connection
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "Your-Network-Name"
# Enter password when prompted
exit
```

### Ethernet
Should work automatically. Verify with:
```bash
ping google.com
```

## 🎯 Installation Methods

### Method 1: Quick Install (Recommended)
```bash
# Single command installation
curl -L https://sh.abrino.cloud/arch-1 | bash

# Or use full URL:
curl -L https://raw.githubusercontent.com/Abrino-Cloud/Arch-Hyprland/main/arch-hyprland-bare.sh | bash
```

### Method 2: Manual Arch Install + Script
If you prefer to install base Arch manually first:

#### Step 1: Manual Arch Installation
```bash
# Run Arch installer
archinstall
```

**archinstall settings:**
- **Mirrors**: Select your region (Iran recommended)
- **Disk configuration**: 
  - Partitioning → Default partitioning layout
  - Select disk → Your target disk
  - Filesystem → btrfs (enable compression)
  - **Disk encryption**: LUKS → Set password → Apply to partition
- **Hostname**: Your choice
- **Root password**: Set secure password
- **User account**: Add user → Set as superuser
- **Audio**: pipewire
- **Network**: Copy ISO network config
- **Additional packages**: Add `wget git`
- **Timezone**: Asia/Tehran (or your preference)

#### Step 2: Run Hyprland Script
After archinstall completes and you reboot:
```bash
# Login with your user account
curl -L https://sh.abrino.cloud/arch-1 | bash
```

## 🔧 Installation Process Walkthrough

### Script Prompts
The installer will ask for:

1. **Hostname** (default: arch-dev)
2. **Username** (lowercase, no spaces)
3. **User Password** (6+ characters)
4. **Root Password** (6+ characters)
5. **Timezone** (default: Asia/Tehran)
6. **DNS Configuration**:
   - Iranian Anti-Sanctions DNS (recommended)
   - Or country-based with reflector
7. **Mirror Configuration**:
   - Iranian mirrors (IUT, Yazd + fast regionals)
   - Or country-based with reflector
8. **Dotfiles Setup** (optional):
   - Repository URL (SSH format preferred)
   - Git username and email

### Hardware Detection
Script automatically detects and configures:
- **CPU**: Intel/AMD microcode
- **GPU**: NVIDIA/AMD/Intel drivers
- **Device Type**: Laptop (power management) vs Desktop
- **Peripherals**: WiFi, Bluetooth, battery

### Installation Steps
1. **Disk Setup**: LUKS encryption + BTRFS with compression
2. **Base System**: Essential Arch packages + drivers
3. **Bootloader**: systemd-boot with encryption support
4. **Display Manager**: Ly (minimal TUI)
5. **Desktop Environment**: Hyprland with zero animations
6. **Applications**: Bare essentials (Chromium, Ghostty, TUI tools)
7. **Theming**: Catppuccin Mocha everywhere
8. **Persian Support**: Fonts, input methods, RTL
9. **Optimization**: Iranian DNS, mirrors, performance tweaks

## 🎨 Post-Installation

### First Boot
1. **Remove USB drive**
2. **Reboot system**
3. **Enter disk encryption password**
4. **Login with Ly display manager**
5. **Launch Ghostty terminal** (Super+Return)

### Essential Commands
```bash
# Update system
yay -Syu

# Install additional applications
yay -S visual-studio-code-bin obsidian spotify
pacman -S firefox mpv obs-studio telegram-desktop

# Check system info
fastfetch

# Start tmux session
tm

# Open file manager
thunar

# Toggle Persian keyboard
# Alt+Shift (quick) or Super+I (manual)
```

### Network Configuration
```bash
# Check current DNS
cat /etc/resolv.conf

# Switch to Iranian DNS manually
iran-dns

# Connect to WiFi graphically
nm-applet
```

## ⚙️ Configuration

### Persian Language Setup
The system comes pre-configured with:
- **Fonts**: Vazirmatn, Noto fonts with Persian support
- **Input Method**: fcitx5 with us,ir layouts
- **Keyboard Toggle**: Alt+Shift or Super+I
- **RTL Support**: Proper text rendering

### Hyprland Keybindings
```bash
# Essential bindings
Super + Return      → Ghostty terminal
Super + Space       → Application launcher (rofi)
Super + W           → Chromium browser
Super + E           → File manager (thunar)
Super + Q           → Close window
Super + F           → Fullscreen
Super + V           → Toggle floating
Super + I           → Toggle Persian keyboard

# Workspaces
Super + 1-5         → Switch workspace
Super + Shift + 1-5 → Move window to workspace

# Screenshots
Print               → Screenshot selection
Shift + Print       → Screenshot full screen

# Audio/Brightness (laptops)
XF86AudioRaiseVolume/LowerVolume/Mute
XF86MonBrightnessUp/Down
```

### tmux Workflow
```bash
# Start new session
tmux

# Common tmux commands (prefix: Ctrl+A)
Ctrl+A + |          → Split vertically
Ctrl+A + -          → Split horizontally
Ctrl+A + h/j/k/l    → Navigate panes
Ctrl+A + c          → New window
Ctrl+A + r          → Reload config
```

### Dotfiles Management
```bash
# Initialize dotfiles (if not done during install)
chezmoi init --apply git@github.com:YOUR-USERNAME/dotfiles.git

# Update dotfiles
chezmoi update

# Check status
chezmoi status

# Apply changes
chezmoi apply
```

## 🔍 Troubleshooting

### Common Issues

#### Boot Issues
**Problem**: System doesn't boot after installation
```bash
# Check if systemd-boot is installed
bootctl status

# Reinstall bootloader
bootctl install --path=/boot
```

#### Display Issues
**Problem**: Black screen or no display
```bash
# Check GPU drivers
lspci | grep VGA
pacman -Qs nvidia  # or amd, intel

# Reinstall drivers
pacman -S nvidia nvidia-utils  # For NVIDIA
```

#### Network Issues
**Problem**: No internet connection
```bash
# Check network status
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Manual DNS configuration
echo "nameserver 10.70.95.150" | sudo tee /etc/resolv.conf
```

#### Persian Input Issues
**Problem**: Can't type Persian
```bash
# Check fcitx5 status
fcitx5-remote

# Start fcitx5
fcitx5 -d

# Check input method
fcitx5-configtool
```

#### Performance Issues
**Problem**: System feels slow
```bash
# Check running processes
btop

# Check systemd services
systemctl --failed
systemctl list-units --type=service --state=running

# Clean package cache
yay -Sc
```

### Log Files
```bash
# System logs
journalctl -b          # Current boot
journalctl -f          # Follow logs
journalctl -u service  # Specific service

# Installation log
/tmp/arch-hyprland-install.log

# Hyprland logs
~/.local/share/hyprland/hyprland.log
```

## 🎯 Advanced Usage

### Multi-Monitor Setup
```bash
# List available monitors
hyprctl monitors

# Configure in hyprland.conf
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1
```

### Performance Tuning
```bash
# CPU governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Swappiness (already optimized in script)
cat /proc/sys/vm/swappiness  # Should be 10

# Check ZRAM
zramctl
```

### Security Hardening
```bash
# Enable firewall
sudo ufw enable

# Check systemd security
systemd-analyze security

# Audit failed login attempts
journalctl _SYSTEMD_UNIT=systemd-logind.service
```

### Backup Strategy
```bash
# System backup with timeshift
sudo timeshift --create --comments "Pre-update backup"

# Dotfiles backup
chezmoi archive > dotfiles-backup.tar.gz

# Config backup
tar -czf configs-backup.tar.gz ~/.config
```

### Custom Themes
```bash
# Wallpaper
cp your-wallpaper.jpg ~/.local/share/backgrounds/
# Update in hyprland.conf

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha"

# Icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
```

## 📚 Additional Resources

### Documentation
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Catppuccin Theme](https://catppuccin.com/)
- [Omarchy Manual](https://manuals.omamix.org/2/the-omarchy-manual)

### Persian Community
- **Telegram**: [@archlinux_ir](https://t.me/archlinux_ir)
- **IRC**: #archlinux-ir on libera.chat
- **Forum**: [Persian Arch Users](https://bbs.archlinux.org/)

### Support
- **GitHub Issues**: [Abrino-Cloud/Arch-Hyprland](https://github.com/Abrino-Cloud/Arch-Hyprland/issues)
- **Email**: support@abrino.cloud
- **Telegram**: [@abrino_support](https://t.me/abrino_support)

---

*This guide is maintained by [Abrino Cloud](https://abrino.cloud) and the Persian Arch Linux community.*