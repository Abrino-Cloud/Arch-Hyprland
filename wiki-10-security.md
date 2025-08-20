# 10. Security Hardening

> **Securing your Arch Linux system with encryption, Secure Boot, and best practices**

## 🎯 Overview

Security measures covered:
- Secure Boot configuration
- Firewall setup
- AppArmor/SELinux
- System hardening
- Network security
- User security
- Audit and monitoring

## 🔐 Secure Boot

### Prerequisites
```bash
# Check Secure Boot status
bootctl status

# Install required packages
sudo pacman -S sbctl
```

### Generate and Enroll Keys
```bash
# Create custom Secure Boot keys
sudo sbctl create-keys

# Enroll keys (will clear existing keys!)
sudo sbctl enroll-keys --microsoft

# If dual-booting with Windows, include Microsoft keys
sudo sbctl enroll-keys --microsoft --append
```

### Sign Boot Files
```bash
# Sign kernel and bootloader
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi

# Verify signatures
sudo sbctl verify
```

### Automatic Signing Hook
```bash
# Create pacman hook for automatic signing
sudo mkdir -p /etc/pacman.d/hooks
sudo cat > /etc/pacman.d/hooks/99-secureboot.hook << 'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = linux-lts
Target = linux-zen

[Action]
Description = Signing kernel with Machine Owner Key for Secure Boot
When = PostTransaction
Exec = /usr/bin/sbctl sign-all
Depends = sbctl
EOF
```

### Enable Secure Boot
1. Reboot into UEFI/BIOS
2. Enable Secure Boot
3. Set Secure Boot to "Custom" or "User" mode
4. Save and reboot

## 🛡️ Firewall Configuration

### UFW (Uncomplicated Firewall)
```bash
# Install UFW
sudo pacman -S ufw

# Basic configuration
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
sudo systemctl enable ufw
```

### Firewalld (Advanced)
```bash
# Install firewalld
sudo pacman -S firewalld

# Start and enable
sudo systemctl enable --now firewalld

# Configure zones
sudo firewall-cmd --set-default-zone=home
sudo firewall-cmd --zone=home --add-service=ssh --permanent
sudo firewall-cmd --zone=home --add-service=mdns --permanent
sudo firewall-cmd --reload

# Check status
sudo firewall-cmd --list-all
```

## 🔒 AppArmor

### Installation
```bash
# Install AppArmor
sudo pacman -S apparmor

# Enable AppArmor
sudo systemctl enable --now apparmor

# Add to kernel parameters
sudo sed -i 's/options/& apparmor=1 security=apparmor/' /boot/loader/entries/arch.conf
```

### Profile Management
```bash
# Check status
sudo aa-status

# Set profiles to enforce mode
sudo aa-enforce /etc/apparmor.d/*

# Create custom profile
sudo aa-genprof /usr/bin/firefox

# Update profiles
sudo aa-logprof
```

## 🚨 System Hardening

### Kernel Hardening
```bash
# Sysctl hardening
sudo cat > /etc/sysctl.d/99-security.conf << 'EOF'
# Kernel hardening
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 2
kernel.unprivileged_bpf_disabled = 1
kernel.unprivileged_userns_clone = 0

# Network hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.