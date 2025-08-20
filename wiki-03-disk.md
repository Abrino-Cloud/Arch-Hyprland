# 03. Disk Setup

> **Advanced disk configuration with BTRFS, encryption, and optimization**

## 🎯 Overview

This section covers the detailed disk setup including:
- Understanding partition layout
- LUKS2 encryption configuration
- BTRFS advanced features
- Optimization for SSDs
- Snapshot configuration

## 📊 Partition Layout Explained

### Our Partition Scheme
```
Physical Disk (/dev/nvme0n1)
├── nvme0n1p1 (512MB) - EFI System Partition
│   └── FAT32 - /boot
└── nvme0n1p2 (Rest) - Linux Filesystem
    └── LUKS2 Encrypted Container
        └── BTRFS with subvolumes
            ├── @ (root)
            ├── @home
            ├── @snapshots
            ├── @var_log
            └── @cache
```

### Why This Layout?

#### Single BTRFS Partition
- **Flexibility**: Subvolumes share space dynamically
- **Simplicity**: No need to guess partition sizes
- **Snapshots**: Can snapshot entire system easily
- **Efficiency**: Better space utilization

#### Separate Subvolumes
- **@**: Root filesystem
- **@home**: User data (excluded from root snapshots)
- **@snapshots**: Timeshift snapshots location
- **@var_log**: Logs (excluded from snapshots)
- **@cache**: Cache files (excluded from snapshots)

## 🔐 LUKS2 Encryption Details

### Understanding LUKS2
LUKS (Linux Unified Key Setup) version 2 provides:
- **AES-256 encryption** by default
- **Argon2id** key derivation (memory-hard)
- **Multiple key slots** (up to 32)
- **Header backup** capability

### Advanced LUKS Configuration
```bash
# View LUKS header information
cryptsetup luksDump /dev/nvme0n1p2

# Add additional key slot (backup password)
cryptsetup luksAddKey /dev/nvme0n1p2

# Backup LUKS header (CRITICAL - save this externally!)
cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /root/luks-header-backup.img

# Test header backup
cryptsetup luksDump /root/luks-header-backup.img
```

### Performance Optimization for Encryption
```bash
# Check if hardware acceleration is available
cryptsetup benchmark

# For SSDs, enable TRIM/discard support
# Edit /etc/crypttab (we'll create this later)
echo "cryptroot UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) none discard" > /etc/crypttab
```

## 🗂️ BTRFS Configuration

### BTRFS Mount Options Explained
```bash
# Our mount options:
noatime         # Don't update access times (performance)
compress=zstd:1 # Fast compression algorithm
space_cache=v2  # Improved performance for free space tracking
discard=async   # Asynchronous TRIM for SSDs
subvol=@        # Specify which subvolume to mount
```

### BTRFS Maintenance Commands
```bash
# Check filesystem health
btrfs filesystem show /
btrfs filesystem df /

# Check for errors
btrfs scrub start /
btrfs scrub status /

# Balance filesystem (defragmentation)
btrfs balance start -dusage=50 /

# Compression statistics
btrfs filesystem usage /
```

### Creating Additional Subvolumes
```bash
# Example: Create a subvolume for Docker
btrfs subvolume create /var/lib/docker

# Example: Create a subvolume for VMs
btrfs subvolume create /var/lib/libvirt
```

## 💾 SSD Optimization

### Enable TRIM
```bash
# Check if SSD supports TRIM
lsblk --discard

# Enable periodic TRIM (weekly)
systemctl enable fstrim.timer
systemctl start fstrim.timer

# Manual TRIM
fstrim -v /
```

### Reduce Writes
```bash
# Move temporary files to RAM
# Add to /etc/fstab:
echo "tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0" >> /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0" >> /etc/fstab
```

### Swappiness Configuration
```bash
# Reduce swappiness (we're using ZRAM anyway)
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
```

## 📸 Snapshot Strategy

### Timeshift Configuration
```bash
# Install Timeshift (after base install)
pacman -S timeshift

# Configure for BTRFS mode
timeshift --btrfs

# Set snapshot location
timeshift --snapshot-device /dev/mapper/cryptroot --scripted
```

### Snapshot Schedule
Recommended settings:
- **Boot**: Create snapshot on boot
- **Daily**: Keep 5 daily snapshots
- **Weekly**: Keep 3 weekly snapshots
- **Monthly**: Keep 2 monthly snapshots

### Manual Snapshots
```bash
# Before system updates
timeshift --create --comments "Before system update"

# List snapshots
timeshift --list

# Restore snapshot (from live USB if needed)
timeshift --restore --snapshot '2024-01-15_10-00-00'
```

## 🔧 Advanced Disk Features

### BTRFS RAID (Multiple Disks)
```bash
# For RAID1 (mirror) with two disks
mkfs.btrfs -m raid1 -d raid1 /dev/sda /dev/sdb

# Add a disk to existing BTRFS
btrfs device add /dev/sdc /
btrfs balance start -dconvert=raid1 -mconvert=raid1 /
```

### Compression Comparison
```bash
# Test different compression levels
# zstd:1 (fastest, less compression)
# zstd:3 (default)
# zstd:15 (maximum compression, slower)

# Change compression for existing files
btrfs filesystem defragment -r -czstd:3 /
```

### Quota Management
```bash
# Enable quotas
btrfs quota enable /

# Create quota group
btrfs subvolume create /home/user/documents
btrfs qgroup create 1/0 /
btrfs qgroup assign 0/256 1/0 /

# Set limits (10GB limit)
btrfs qgroup limit 10G 1/0 /
```

## 📈 Monitoring Disk Health

### SMART Monitoring
```bash
# Install smartmontools
pacman -S smartmontools

# Check drive health
smartctl -a /dev/nvme0n1

# Enable monitoring
systemctl enable smartd
systemctl start smartd
```

### BTRFS Statistics
```bash
# Show device statistics
btrfs device stats /

# Monitor in real-time
watch -n 1 'btrfs filesystem show /'
```

## 🚨 Recovery Procedures

### LUKS Header Recovery
```bash
# If LUKS header is damaged
cryptsetup luksHeaderRestore /dev/nvme0n1p2 --header-backup-file /path/to/backup
```

### BTRFS Recovery
```bash
# Mount with recovery options
mount -o recovery,ro /dev/mapper/cryptroot /mnt

# Check and repair
btrfs check --repair /dev/mapper/cryptroot

# Recover from backup superblock
btrfs restore -s 1 /dev/mapper/cryptroot /recovery/
```

### Emergency Access
```bash
# Boot from live USB
cryptsetup open /dev/nvme0n1p2 cryptroot
mount -o subvol=@ /dev/mapper/cryptroot /mnt
mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
arch-chroot /mnt
```

## 🎯 Best Practices

### Regular Maintenance
1. **Weekly**: Run `fstrim` (automated via timer)
2. **Monthly**: Check SMART status
3. **Quarterly**: Run `btrfs scrub`
4. **Before updates**: Create Timeshift snapshot

### Backup Strategy
1. **LUKS header**: External backup (USB/Cloud)
2. **Important data**: Regular backups to external drive
3. **System snapshots**: Automated via Timeshift
4. **Configuration**: Git repository (via Chezmoi)

### Security Considerations
- Use strong LUKS password (20+ characters)
- Consider key file on separate USB for automation
- Enable Secure Boot after installation
- Regularly update system

## 📝 Configuration Files Reference

### /etc/fstab Example
```fstab
# <file system> <mount point> <type> <options> <dump> <pass>
UUID=XXXX-XXXX /boot vfat defaults,noatime 0 2
/dev/mapper/cryptroot / btrfs noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@ 0 0
/dev/mapper/cryptroot /home btrfs noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@home 0 0
/dev/mapper/cryptroot /.snapshots btrfs noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@snapshots 0 0
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
```

### /etc/crypttab Example
```
cryptroot UUID=your-uuid-here none discard
```

## ⚡ Performance Benchmarks

Test your disk performance:
```bash
# Sequential read/write
hdparm -tT /dev/nvme0n1

# Random I/O
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=1g --numjobs=1 --runtime=60 --time_based --end_fsync=1

# BTRFS specific
btrfs filesystem df /
compsize /
```

---

<div align="center">

[← Previous: Base Installation](02-Base-Installation) • [Next: System Configuration →](04-System-Configuration)

</div>