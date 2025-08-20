# 09. Performance Tuning

> **Optimizing your Arch Linux system for maximum speed and efficiency**

## 🎯 Overview

Performance optimizations for:
- CPU performance
- Memory management
- Disk I/O
- Graphics acceleration
- Network optimization
- Boot time reduction
- Power efficiency

## ⚡ CPU Optimization

### CPU Governor
```bash
# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Install cpupower
sudo pacman -S cpupower

# Set performance mode
sudo cpupower frequency-set -g performance

# Make permanent
sudo systemctl enable cpupower
sudo cat > /etc/default/cpupower << 'EOF'
governor='performance'
EOF
```

### CPU Frequency Scaling
```bash
# Install auto-cpufreq for laptops
yay -S auto-cpufreq
sudo systemctl enable --now auto-cpufreq

# Configure
sudo auto-cpufreq --config
cat > /etc/auto-cpufreq.conf << 'EOF'
[charger]
governor = performance
scaling_min_freq = 1400000
scaling_max_freq = 3500000
turbo = auto

[battery]
governor = powersave
scaling_min_freq = 1400000
scaling_max_freq = 1800000
turbo = never
enable_thresholds = true
start_threshold = 20
stop_threshold = 80
EOF
```

### Process Priority
```bash
# Set nice values for processes
cat > ~/.config/hypr/exec-priority.sh << 'EOF'
#!/bin/bash
# High priority for Hyprland
renice -n -10 -p $(pgrep Hyprland)

# Low priority for background services
renice -n 10 -p $(pgrep dropbox)
renice -n 10 -p $(pgrep syncthing)
EOF
chmod +x ~/.config/hypr/exec-priority.sh

# Add to hyprland.conf
echo "exec-once = ~/.config/hypr/exec-priority.sh" >> ~/.config/hypr/hyprland.conf
```

## 💾 Memory Optimization

### ZRAM Configuration
```bash
# Optimize ZRAM
sudo cat > /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap

[zram1]
mount-point = /var/tmp
zram-size = 2048
compression-algorithm = zstd
fs-type = ext4
EOF

# Restart service
sudo systemctl restart systemd-zram-setup@zram0.service
```

### Swappiness
```bash
# Reduce swappiness
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-swappiness.conf

# Apply immediately
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

### Memory Management
```bash
# Enable memory compression
echo "vm.page-cluster=0" | sudo tee /etc/sysctl.d/99-memory.conf
echo "vm.dirty_ratio=5" | sudo tee -a /etc/sysctl.d/99-memory.conf
echo "vm.dirty_background_ratio=2" | sudo tee -a /etc/sysctl.d/99-memory.conf
```

## 💿 Disk I/O Optimization

### I/O Scheduler
```bash
# Check current scheduler
cat /sys/block/nvme0n1/queue/scheduler

# Set for NVMe (none is best)
echo "none" | sudo tee /sys/block/nvme0n1/queue/scheduler

# Set for SATA SSD
echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler

# Make permanent
cat > /etc/udev/rules.d/60-ioschedulers.rules << 'EOF'
# NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# SATA SSD
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
```

### BTRFS Optimization
```bash
# Mount options in /etc/fstab
# Already optimized: noatime,compress=zstd:1,space_cache=v2,discard=async

# Additional optimizations
sudo btrfs property set / compression zstd:1
sudo btrfs filesystem defragment -r -czstd /

# Disable CoW for databases/VMs
chattr +C /var/lib/mysql
chattr +C /var/lib/docker
```

### Preload
```bash
# Install preload for frequently used apps
yay -S preload
sudo systemctl enable --now preload
```

## 🎮 Graphics Optimization

### Intel Graphics
```bash
# Enable GuC/HuC firmware
cat > /etc/modprobe.d/i915.conf << 'EOF'
options i915 enable_guc=3
options i915 enable_fbc=1
options i915 fastboot=1
options i915 enable_psr=2
EOF

# Rebuild initramfs
sudo mkinitcpio -P
```

### AMD Graphics
```bash
# Enable Variable Rate Shading
cat > /etc/modprobe.d/amdgpu.conf << 'EOF'
options amdgpu ppfeaturemask=0xffffffff
options amdgpu gpu_recovery=1
options amdgpu deep_color=1
options amdgpu exp_hw_support=1
EOF
```

### NVIDIA Graphics
```bash
# Performance mode
sudo nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1"

# Force Composition Pipeline
cat > /etc/X11/xorg.conf.d/20-nvidia.conf << 'EOF'
Section "Device"
    Identifier "NVIDIA"
    Driver "nvidia"
    Option "NoLogo" "1"
    Option "UseNvKmsCompositionPipeline" "false"
    Option "TripleBuffer" "On"
    Option "AllowIndirectGLXProtocol" "off"
EndSection
EOF
```

### Vulkan Performance
```bash
# Environment variables for Vulkan
cat >> ~/.config/hypr/hyprland.conf << 'EOF'
env = VK_ICD_FILENAMES,/usr/share/vulkan/icd.d/radeon_icd.i686.json:/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
env = RADV_PERFTEST,aco
env = RADV_DEBUG,novrsflatshading
EOF
```

## 🌐 Network Optimization

### TCP Optimization
```bash
cat > /etc/sysctl.d/99-network.conf << 'EOF'
# TCP Fast Open
net.ipv4.tcp_fastopen = 3

# BBR congestion control
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr2

# Buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# Connection handling
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
EOF

sudo sysctl -p /etc/sysctl.d/99-network.conf
```

### DNS Performance
```bash
# Use systemd-resolved with cache
sudo systemctl enable --now systemd-resolved

# Configure
cat > /etc/systemd/resolved.conf << 'EOF'
[Resolve]
DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111
FallbackDNS=8.8.8.8 8.8.4.4
Domains=~.
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
Cache=yes
CacheFromLocalhost=yes
EOF

sudo systemctl restart systemd-resolved
```

## 🚀 Boot Optimization

### Bootloader Timeout
```bash
# Reduce timeout
sudo sed -i 's/timeout 5/timeout 0/' /boot/loader/loader.conf
```

### Parallel Boot
```bash
# Already enabled by default in systemd
# Check boot time
systemd-analyze
systemd-analyze blame
systemd-analyze critical-chain
```

### Disable Unnecessary Services
```bash
# List all services
systemctl list-unit-files --state=enabled

# Disable unnecessary ones
sudo systemctl disable bluetooth.service  # If not using Bluetooth
sudo systemctl disable cups.service      # If not printing
sudo systemctl disable avahi-daemon      # If not using mDNS
```

### Plymouth (Boot Screen) Removal
```bash
# Remove plymouth if installed (saves boot time)
sudo pacman -Rns plymouth

# Remove from mkinitcpio
sudo sed -i 's/plymouth //' /etc/mkinitcpio.conf
sudo mkinitcpio -P
```

## 🔋 Power Management

### TLP Configuration
```bash
# Install TLP
sudo pacman -S tlp tlp-rdw

# Configure for performance
sudo cat > /etc/tlp.conf << 'EOF'
# Performance on AC
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_BOOST_ON_AC=1

# Balanced on battery
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=60
CPU_BOOST_ON_BAT=0

# GPU power management
RADEON_DPM_STATE_ON_AC=performance
RADEON_DPM_STATE_ON_BAT=battery
RADEON_POWER_PROFILE_ON_AC=high
RADEON_POWER_PROFILE_ON_BAT=low

# PCIe power
PCIE_ASPM_ON_AC=performance
PCIE_ASPM_ON_BAT=powersupersave

# USB autosuspend
USB_AUTOSUSPEND=1
USB_EXCLUDE_AUDIO=1
USB_EXCLUDE_BTUSB=0
USB_EXCLUDE_PHONE=0

# Disk
DISK_IDLE_SECS_ON_AC=0
DISK_IDLE_SECS_ON_BAT=2
DISK_APM_LEVEL_ON_AC=254
DISK_APM_LEVEL_ON_BAT=128
EOF

sudo systemctl enable --now tlp
```

## 📊 Monitoring Tools

### Performance Monitoring
```bash
# Install monitoring tools
sudo pacman -S htop btop iotop nethogs

# GPU monitoring
sudo pacman -S nvtop  # NVIDIA
sudo pacman -S radeontop  # AMD
```

### System Benchmarks
```bash
# Install benchmark tools
sudo pacman -S sysbench stress-ng

# CPU benchmark
sysbench cpu --cpu-max-prime=20000 run

# Memory benchmark
sysbench memory run

# Disk benchmark
sysbench fileio --file-test-mode=seqwr run
```

## 🎯 Application-Specific

### Firefox Performance
```bash
# In about:config
gfx.webrender.all = true
gfx.webrender.enabled = true
layers.acceleration.force-enabled = true
layers.gpu-process.enabled = true
media.ffmpeg.vaapi.enabled = true
media.hardware-video-decoding.force-enabled = true
widget.wayland.use-vaapi = true
```

### VS Code Performance
```json
{
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/**": true,
        "**/.cache/**": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true,
        "**/*.code-search": true
    },
    "extensions.experimental.affinity": {
        "vscodevim.vim": 1
    },
    "files.maxMemoryForLargeFilesMB": 4096,
    "editor.largeFileOptimizations": true
}
```

## 🚄 Quick Performance Script

```bash
cat > ~/optimize-performance.sh << 'EOF'
#!/bin/bash

echo "Applying performance optimizations..."

# CPU Performance
sudo cpupower frequency-set -g performance

# Clear caches
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Disable CPU mitigations (less secure but faster)
# Add mitigations=off to kernel parameters if acceptable

# Process priorities
renice -n -10 -p $(pgrep Hyprland) 2>/dev/null
renice -n -5 -p $(pgrep waybar) 2>/dev/null

# I/O scheduler
echo "none" | sudo tee /sys/block/nvme*/queue/scheduler 2>/dev/null
echo "mq-deadline" | sudo tee /sys/block/sd*/queue/scheduler 2>/dev/null

echo "Performance optimizations applied!"
EOF
chmod +x ~/optimize-performance.sh
```

---

<div align="center">

[← Previous: Dotfiles Management](08-Dotfiles-Management) • [Next: Security Hardening →](10-Security-Hardening)

</div>