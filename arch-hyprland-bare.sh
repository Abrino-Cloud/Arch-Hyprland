echo -e "${RED}⚠ WARNING: This will ERASE ALL DATA on $DISK_DEVICE!${NC}"
    echo ""
    read -p "$(echo -e ${WHITE}Continue with installation? [y/N]: ${NC})" CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

# Configure Iranian DNS and mirrors
configure_iranian_network() {
    log "Configuring Iranian network optimizations..."
    
    # Set Iranian DNS
    cat > /etc/resolv.conf << EOF
# Iranian Anti-Sanctions DNS
nameserver $IRANIAN_DNS_PRIMARY
nameserver $IRANIAN_DNS_SECONDARY
nameserver $FALLBACK_DNS
EOF
    
    # Backup original mirrorlist
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    
    # Configure Iranian mirrors
    cat > /etc/pacman.d/mirrorlist << 'EOF'
# Iranian mirrors optimized for speed
Server = https://repo.iut.ac.ir/repo/archlinux/$repo/os/$arch
Server = https://mirror.yazd.ac.ir/arch/$repo/os/$arch
# Fast regional mirrors
Server = https://mirror.surf/archlinux/$repo/os/$arch
Server = https://mirrors.edge.kernel.org/archlinux/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
EOF
    
    # Update package databases
    pacman -Sy --noconfirm
    
    success "Iranian network configuration completed"
}

# Disk partitioning and encryption
setup_disk() {
    log "Setting up disk partitioning and encryption..."
    
    # Unmount any existing mounts
    umount -A --recursive /mnt 2>/dev/null || true
    
    # Partition the disk
    parted --script "${DISK_DEVICE}" -- mklabel gpt
    parted --script "${DISK_DEVICE}" -- mkpart ESP fat32 1MiB 512MiB
    parted --script "${DISK_DEVICE}" -- set 1 esp on
    parted --script "${DISK_DEVICE}" -- mkpart primary 512MiB 100%
    
    # Get partition names
    if [[ "${DISK_DEVICE}" =~ nvme ]]; then
        BOOT_PARTITION="${DISK_DEVICE}p1"
        ROOT_PARTITION="${DISK_DEVICE}p2"
    else
        BOOT_PARTITION="${DISK_DEVICE}1"
        ROOT_PARTITION="${DISK_DEVICE}2"
    fi
    
    # Format boot partition
    mkfs.fat -F32 "$BOOT_PARTITION"
    
    # Setup LUKS encryption
    echo -e "$USER_PASSWORD\n$USER_PASSWORD" | cryptsetup luksFormat --type luks2 "$ROOT_PARTITION"
    echo "$USER_PASSWORD" | cryptsetup open "$ROOT_PARTITION" cryptroot
    
    # Format with BTRFS
    mkfs.btrfs -L arch /dev/mapper/cryptroot
    
    # Mount and create subvolumes
    mount /dev/mapper/cryptroot /mnt
    
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    btrfs subvolume create /mnt/@var_log
    
    umount /mnt
    
    # Mount with optimized options
    mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
    
    mkdir -p /mnt/{boot,home,.snapshots,var/log}
    mount "$BOOT_PARTITION" /mnt/boot
    mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
    mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
    mount -o noatime,compress=zstd:1,space_cache=v2,discard=async,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log
    
    success "Disk setup completed"
}

# Install base system
install_base_system() {
    log "Installing base Arch Linux system..."
    
    # Essential packages
    local base_packages=(
        "base" "linux" "linux-firmware" "linux-headers"
        "base-devel" "btrfs-progs" "cryptsetup"
        "networkmanager" "wireless-tools" "wpa_supplicant"
        "sudo" "git" "vim" "tmux" "curl" "wget"
    )
    
    # Add CPU microcode
    if [[ "$CPU_VENDOR" == "intel" ]]; then
        base_packages+=("intel-ucode")
    elif [[ "$CPU_VENDOR" == "amd" ]]; then
        base_packages+=("amd-ucode")
    fi
    
    # Install packages
    pacstrap -K /mnt "${base_packages[@]}"
    
    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    
    success "Base system installation completed"
}

# Configure base system
configure_base_system() {
    log "Configuring base system..."
    
    # Chroot and configure
    arch-chroot /mnt /bin/bash << EOF
# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Set locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Set keymap
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname

# Configure hosts
cat > /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

# Set passwords
echo "root:$ROOT_PASSWORD" | chpasswd

# Create user
useradd -m -G wheel,video,audio,storage,optical,power -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd

# Configure sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Configure mkinitcpio for encryption
sed -i 's/MODULES=(/MODULES=(btrfs /' /etc/mkinitcpio.conf
sed -i 's/HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Install systemd-boot
bootctl --path=/boot install

# Configure loader
cat > /boot/loader/loader.conf << LOADER_EOF
default  arch.conf
timeout  3
console-mode max
editor   no
LOADER_EOF

# Get UUID and create boot entry
ROOT_UUID=\$(blkid -s UUID -o value $ROOT_PARTITION)
cat > /boot/loader/entries/arch.conf << BOOT_EOF
title   Arch Linux Hyprland
linux   /vmlinuz-linux
initrd  /${CPU_VENDOR}-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=\$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 nowatchdog
BOOT_EOF

# Enable essential services
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Iranian DNS configuration
cat > /etc/resolv.conf << DNS_EOF
nameserver $IRANIAN_DNS_PRIMARY
nameserver $IRANIAN_DNS_SECONDARY
nameserver $FALLBACK_DNS
DNS_EOF
chattr +i /etc/resolv.conf

EOF
    
    success "Base system configuration completed"
}

# Install AUR helper
install_aur_helper() {
    log "Installing AUR helper (yay)..."
    
    arch-chroot /mnt /bin/bash << EOF
# Switch to user for AUR installation
sudo -u $USERNAME bash << 'AUR_EOF'
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin
AUR_EOF
EOF
    
    success "AUR helper installed"
}

# Install graphics drivers
install_graphics_drivers() {
    log "Installing graphics drivers for $GPU_VENDOR..."
    
    arch-chroot /mnt /bin/bash << EOF
case "$GPU_VENDOR" in
    "nvidia")
        pacman -S --noconfirm nvidia nvidia-utils nvidia-settings lib32-nvidia-utils
        # Add nvidia modules to mkinitcpio
        sed -i 's/MODULES=(btrfs/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf
        mkinitcpio -P
        ;;
    "amd")
        pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver xf86-video-amdgpu
        ;;
    "intel")
        pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
        ;;
    *)
        pacman -S --noconfirm mesa lib32-mesa vulkan-icd-loader
        ;;
esac
EOF
    
    success "Graphics drivers installed"
}

# Install Hyprland and ecosystem
install_hyprland() {
    log "Installing Hyprland and ecosystem..."
    
    arch-chroot /mnt /bin/bash << EOF
# Core Hyprland packages
pacman -S --noconfirm \
    hyprland xdg-desktop-portal-hyprland \
    waybar rofi-wayland dunst \
    thunar grim slurp wl-clipboard cliphist \
    brightnessctl pamixer playerctl \
    network-manager-applet polkit-kde-agent \
    pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-liberation \
    sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Enable services
systemctl enable sddm
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

# Hardware-specific packages
if [[ "$HAS_WIFI" == "yes" ]]; then
    pacman -S --noconfirm iwd wireless-tools
fi

if [[ "$HAS_BLUETOOTH" == "yes" ]]; then
    pacman -S --noconfirm bluez bluez-utils blueman
    systemctl enable bluetooth
fi

if [[ "$IS_LAPTOP" == "yes" ]]; then
    pacman -S --noconfirm tlp tlp-rdw acpi acpi_call thermald
    systemctl enable tlp
    systemctl enable thermald
fi
EOF
    
    success "Hyprland installation completed"
}

# Install applications
install_applications() {
    log "Installing essential applications..."
    
    arch-chroot /mnt /bin/bash << EOF
# Install from official repos
pacman -S --noconfirm \
    firefox chromium \
    mpv obs-studio \
    telegram-desktop \
    btop htop neofetch fastfetch \
    eza fzf ripgrep fd bat zoxide \
    lazygit \
    file-roller timeshift \
    chezmoi

# Install from AUR as user
sudo -u $USERNAME bash << 'AUR_EOF'
# Essential AUR packages
yay -S --noconfirm \
    visual-studio-code-bin \
    ghostty-git \
    obsidian \
    spotify \
    lazydocker

# Clipboard manager
yay -S --noconfirm copyq
AUR_EOF
EOF
    
    success "Applications installation completed"
}

# Configure Hyprland with Catppuccin theme
configure_hyprland() {
    log "Configuring Hyprland with Catppuccin theme..."
    
    arch-chroot /mnt /bin/bash << EOF
# Create config directory
sudo -u $USERNAME mkdir -p /home/$USERNAME/.config/hypr

# Create Hyprland configuration
sudo -u $USERNAME tee /home/$USERNAME/.config/hypr/hyprland.conf > /dev/null << 'HYPR_EOF'
# Arch Hyprland - Zero Animation Configuration
# Catppuccin Mocha Theme

# Monitor configuration
monitor=,preferred,auto,1

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland
env = MOZ_ENABLE_WAYLAND,1

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
    accel_profile = flat
    
    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
    }
}

# General settings - Catppuccin Mocha
general {
    gaps_in = 4
    gaps_out = 8
    border_size = 2
    
    # Catppuccin Mocha colors
    col.active_border = rgba(cba6f7ff) rgba(89b4faff) 45deg
    col.inactive_border = rgba(313244ff)
    
    layout = dwindle
    no_cursor_warps = true
    resize_on_border = true
}

# Zero animations for performance
animations {
    enabled = false
}

# Minimal decoration
decoration {
    rounding = 0
    blur { enabled = false }
    drop_shadow = false
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Performance optimizations
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    vfr = true
    vrr = 1
}

# Window rules
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(copyq)$

# Keybindings
\$mainMod = SUPER

# Core applications
bind = \$mainMod, Return, exec, ghostty
bind = \$mainMod, Q, killactive,
bind = \$mainMod SHIFT, M, exit,
bind = \$mainMod, E, exec, thunar
bind = \$mainMod, W, exec, firefox
bind = \$mainMod, C, exec, code
bind = \$mainMod, Space, exec, rofi -show drun
bind = \$mainMod, V, togglefloating,
bind = \$mainMod, F, fullscreen, 0

# Screenshots
bind = , Print, exec, grim -g "\$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

# Audio controls
binde = , XF86AudioRaiseVolume, exec, pamixer -i 5
binde = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t

# Brightness (for laptops)
binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Movement
bind = \$mainMod, H, movefocus, l
bind = \$mainMod, L, movefocus, r
bind = \$mainMod, K, movefocus, u
bind = \$mainMod, J, movefocus, d

# Workspaces
bind = \$mainMod, 1, workspace, 1
bind = \$mainMod, 2, workspace, 2
bind = \$mainMod, 3, workspace, 3
bind = \$mainMod, 4, workspace, 4
bind = \$mainMod, 5, workspace, 5

# Move to workspace
bind = \$mainMod SHIFT, 1, movetoworkspace, 1
bind = \$mainMod SHIFT, 2, movetoworkspace, 2
bind = \$mainMod SHIFT, 3, movetoworkspace, 3
bind = \$mainMod SHIFT, 4, movetoworkspace, 4
bind = \$mainMod SHIFT, 5, movetoworkspace, 5

# Autostart
exec-once = waybar
exec-once = dunst
exec-once = copyq --start-server
exec-once = wl-paste --watch cliphist store
exec-once = nm-applet --indicator
exec-once = /usr/lib/polkit-kde-authentication-agent-1
HYPR_EOF

# GPU-specific configuration
if [[ "$GPU_VENDOR" == "nvidia" ]]; then
    sudo -u $USERNAME tee -a /home/$USERNAME/.config/hypr/hyprland.conf > /dev/null << 'NVIDIA_EOF'

# NVIDIA specific
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
NVIDIA_EOF
fi

EOF
    
    success "Hyprland configuration completed"
}

# Configure Waybar
configure_waybar() {
    log "Configuring Waybar with Catppuccin theme..."
    
    arch-chroot /mnt /bin/bash << EOF
sudo -u $USERNAME mkdir -p /home/$USERNAME/.config/waybar

# Waybar config
sudo -u $USERNAME tee /home/$USERNAME/.config/waybar/config > /dev/null << 'WAYBAR_CONFIG'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": [
        "cpu", "memory", "network", 
        "pulseaudio", "battery", "clock", "tray"
    ],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "clock": {
        "timezone": "$TIMEZONE",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}",
        "tooltip-format": "<big>{:%Y %B}</big>\\n<tt><small>{calendar}</small></tt>"
    },
    
    "cpu": {
        "format": " {usage}%",
        "tooltip": false
    },
    
    "memory": {
        "format": " {}%"
    },
    
    "network": {
        "format-wifi": " {essid} ({signalStrength}%)",
        "format-ethernet": " {ipaddr}/{cidr}",
        "format-linked": " {ifname} (No IP)",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{ifname} via {gwaddr}"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-bluetooth": "{icon} {volume}%",
        "format-bluetooth-muted": " {icon}",
        "format-muted": " ",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    }
}
WAYBAR_CONFIG

# Waybar Catppuccin style
sudo -u $USERNAME tee /home/$USERNAME/.config/waybar/style.css > /dev/null << 'WAYBAR_STYLE'
/* Catppuccin Mocha theme for Waybar */
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.9);
    color: #cdd6f4;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: #6c7086;
    border-bottom: 3px solid transparent;
}

#workspaces button:hover {
    background: rgba(203, 166, 247, 0.2);
}

#workspaces button.active {
    background-color: #89b4fa;
    color: #1e1e2e;
    border-bottom: 3px solid #cba6f7;
}

#cpu, #memory, #clock, #battery, #network, #pulseaudio, #tray {
    padding: 0 10px;
    color: #cdd6f4;
}

#cpu {
    background-color: #f38ba8;
    color: #1e1e2e;
}

#memory {
    background-color: #a6e3a1;
    color: #1e1e2e;
}

#network {
    background-color: #94e2d5;
    color: #1e1e2e;
}

#pulseaudio {
    background-color: #cba6f7;
    color: #1e1e2e;
}

#battery {
    background-color: #f9e2af;
    color: #1e1e2e;
}

#battery.charging {
    background-color: #a6e3a1;
}

#battery.warning:not(.charging) {
    background-color: #fab387;
}

#battery.critical:not(.charging) {
    background-color: #f38ba8;
    animation: blink 0.5s linear infinite alternate;
}

@keyframes blink {
    to {
        background-color: #f38ba8;
        color: #1e1e2e;
    }
}

#clock {
    background-color: #89b4fa;
    color: #1e1e2e;
}

#tray {
    background-color: #313244;
}
WAYBAR_STYLE

EOF
    
    success "Waybar configuration completed"
}

# Configure applications
configure_applications() {
    log "Configuring applications..."
    
    arch-chroot /mnt /bin/bash << EOF
# Configure tmux
sudo -u $USERNAME tee /home/$USERNAME/.tmux.conf > /dev/null << 'TMUX_EOF'
# Arch Hyprland tmux configuration
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 10000

# Vi mode
setw -g mode-keys vi

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Catppuccin theme
set -g status-position top
set -g status-bg "#1e1e2e"
set -g status-fg "#cdd6f4"
set -g status-left "#[fg=#1e1e2e,bg=#89b4fa,bold] #S "
set -g status-right "#[fg=#1e1e2e,bg=#cba6f7,bold] %H:%M "
setw -g window-status-current-format "#[fg=#1e1e2e,bg=#f38ba8] #I:#W "
setw -g window-status-format "#[fg=#6c7086] #I:#W "

# Copy mode
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

bind r source-file ~/.tmux.conf \\; display-message "Config reloaded!"
TMUX_EOF

# Configure shell aliases
sudo -u $USERNAME tee -a /home/$USERNAME/.bashrc > /dev/null << 'BASH_EOF'

# Arch Hyprland aliases
alias ls='eza --icons'
alias ll='eza -la --icons'
alias tree='eza --tree --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# System shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo pacman -Syu && yay -Syu'
alias cleanup='sudo pacman -Sc && yay -Sc'

# tmux shortcuts
alias tm='tmux'
alias tma='tmux attach'
alias tmn='tmux new-session'

# Iranian DNS shortcut
alias iran-dns='echo "nameserver $IRANIAN_DNS_PRIMARY" | sudo tee /etc/resolv.conf && echo "nameserver $IRANIAN_DNS_SECONDARY" | sudo tee -a /etc/resolv.conf'
BASH_EOF

# Configure Ghostty
sudo -u $USERNAME mkdir -p /home/$USERNAME/.config/ghostty
sudo -u $USERNAME tee /home/$USERNAME/.config/ghostty/config > /dev/null << 'GHOSTTY_EOF'
# Catppuccin Mocha theme
background = 1e1e2e
foreground = cdd6f4
cursor-color = f5e0dc
selection-background = 313244
selection-foreground = cdd6f4

# Colors
palette = 0=#45475a
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#bac2de
palette = 8=#585b70
palette = 9=#f38ba8
palette = 10=#a6e3a1
palette = 11=#f9e2af
palette = 12=#89b4fa
palette = 13=#f5c2e7
palette = 14=#94e2d5
palette = 15=#a6adc8

# Font
font-family = JetBrainsMono Nerd Font
font-size = 12

# Performance
shell-integration = true
copy-on-select = true
GHOSTTY_EOF

EOF
    
    success "Application configuration completed"
}

# Setup dotfiles if requested
setup_dotfiles() {
    if [[ "$INSTALL_DOTFILES" == "yes" && -n "$DOTFILES_REPO" ]]; then
        log "Setting up dotfiles with chezmoi..."
        
        arch-chroot /mnt /bin/bash << EOF
sudo -u $USERNAME bash << 'DOTFILES_EOF'
cd /home/$USERNAME
chezmoi init --apply "$DOTFILES_REPO" || true
DOTFILES_EOF
EOF
        
        success "Dotfiles setup completed"
    fi
}

# Final system optimizations
final_optimizations() {
    log "Applying final system optimizations..."
    
    arch-chroot /mnt /bin/bash << EOF
# ZRAM configuration
tee /etc/systemd/zram-generator.conf > /dev/null << 'ZRAM_EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
ZRAM_EOF

# System optimizations
tee /etc/sysctl.d/99-optimizations.conf > /dev/null << 'SYSCTL_EOF'
# Performance optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50

# Network optimizations for Iranian connections
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
SYSCTL_EOF

# Pacman optimizations
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

# Create useful scripts
sudo -u $USERNAME mkdir -p /home/$USERNAME/bin

# System update script
sudo -u $USERNAME tee /home/$USERNAME/bin/update-system > /dev/null << 'UPDATE_EOF'
#!/bin/bash
echo "🔄 Updating Arch Hyprland system..."
sudo pacman -Syu
yay -Syu
if command -v chezmoi >/dev/null; then
    chezmoi update
fi
echo "✅ System updated!"
UPDATE_EOF

chmod +x /home/$USERNAME/bin/update-system
EOF
    
    success "Final optimizations completed"
}

# Installation completion
installation_complete() {
    clear
    echo -e "${GREEN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                    🎉 INSTALLATION COMPLETE!                 ║
║                                                               ║
║               🏛️  Arch Hyprland is ready!                   ║
║                                                               ║
║  ✓ Zero-animation Hyprland with Catppuccin theme            ║
║  ✓ Iranian DNS and mirror optimization                       ║
║  ✓ Hardware-specific drivers installed                       ║
║  ✓ Essential applications configured                         ║
║  ✓ tmux and modern shell tools ready                         ║
║  ✓ Full disk encryption with BTRFS                          ║
║                                                               ║
║  Next steps:                                                  ║
║  1. Remove the USB drive                                      ║
║  2. Reboot your system                                        ║
║  3. Login with your credentials                               ║
║  4. Enjoy your blazing-fast setup!                           ║
║                                                               ║
║  Useful commands:                                             ║
║  • Super+Return: Open Ghostty terminal                       ║
║  • Super+Space: Application launcher                         ║
║  • Super+W: Firefox browser                                  ║
║  • Super+C: VS Code editor                                   ║
║  • tm: Start tmux session                                     ║
║  • update-system: Update everything                          ║
║                                                               ║
║  Community: https://t.me/archlinux_ir                        ║
║  Repository: github.com/Abrino-Cloud/Arch-Hyprland          ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    echo -e "${CYAN}Installation Summary:${NC}"
    echo "• Hostname: $HOSTNAME"
    echo "• Username: $USERNAME"
    echo "• Hardware: $CPU_VENDOR CPU, $GPU_VENDOR GPU"
    echo "• Type: $([ "$IS_LAPTOP" = "yes" ] && echo "Laptop" || echo "Desktop") with ${TOTAL_RAM}GB RAM"
    echo "• Dotfiles: $([ "$INSTALL_DOTFILES" = "yes" ] && echo "Configured" || echo "Not configured")"
    echo ""
    
    info "Installation log saved to: $LOG_FILE"
    
    read -p "$(echo -e ${WHITE}Reboot now? [Y/n]: ${NC})" REBOOT_NOW
    if [[ ! "$REBOOT_NOW" =~ ^[Nn]$ ]]; then
        log "Rebooting system..."
        reboot
    else
        log "Installation completed. Please reboot when ready."
    fi
}

# Main installation function
main() {
    show_header
    
    log "Starting Arch Hyprland installation..."
    
    # Pre-installation checks
    check_environment
    
    # Hardware detection
    detect_hardware
    
    # Get user input
    get_user_input
    
    # Configure Iranian network
    configure_iranian_network
    
    # Disk setup
    setup_disk
    
    # Install base system
    install_base_system
    
    # Configure base system
    configure_base_system
    
    # Install AUR helper
    install_aur_helper
    
    # Install graphics drivers
    install_graphics_drivers
    
    # Install Hyprland
    install_hyprland
    
    # Install applications
    install_applications
    
    # Configure Hyprland
    configure_hyprland
    
    # Configure Waybar
    configure_waybar
    
    # Configure applications
    configure_applications
    
    # Setup dotfiles
    setup_dotfiles
    
    # Final optimizations
    final_optimizations
    
    # Show completion
    installation_complete
}

# Error handling
trap 'error "Installation failed at line $LINENO. Check $LOG_FILE for details."' ERR

# Help function
show_help() {
    cat << 'EOF'
Arch Hyprland Bare - Complete Installation Script

Usage: ./arch-hyprland-bare.sh [OPTIONS]

This script will install a complete Arch Linux system with:
• Zero-animation Hyprland compositor
• Catppuccin Mocha theme
• Iranian DNS and mirror optimization
• Essential development applications
• Hardware-specific drivers
• Full disk encryption with BTRFS

Prerequisites:
• Boot from Arch Linux ISO
• Connect to internet (WiFi or Ethernet)
• Have at least 25GB free disk space

The script will ask for:
• Hostname and username
• User and root passwords
• Timezone (defaults to Asia/Tehran)
• Optional dotfiles repository

Options:
  -h, --help     Show this help message
  --debug        Enable debug output

Examples:
  ./arch-hyprland-bare.sh
  curl -L https://raw.githubusercontent.com/Abrino-Cloud/Arch-Hyprland/main/arch-hyprland-bare.sh | bash

For more information:
  GitHub: https://github.com/Abrino-Cloud/Arch-Hyprland
  Community: https://t.me/archlinux_ir
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --debug)
            set -x
            shift
            ;;
        *)
            error "Unknown option: $1. Use -h for help."
            ;;
    esac
done

# Initialize log file
echo "Arch Hyprland installation started at $(date)" > "$LOG_FILE"

# Run main installation
main "$@"
║  #!/bin/bash
# Arch Hyprland Bare - Complete Installation Script
# Repository: https://github.com/Abrino-Cloud/Arch-Hyprland
# Inspired by Omarchy but optimized for Iranian developers
# Version: 1.0

set -euo pipefail

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/arch-hyprland-install.log"
REPO_URL="https://github.com/Abrino-Cloud/Arch-Hyprland"
REPO_RAW="https://raw.githubusercontent.com/Abrino-Cloud/Arch-Hyprland/main"

# System variables (will be set by user input)
HOSTNAME=""
USERNAME=""
USER_PASSWORD=""
ROOT_PASSWORD=""
TIMEZONE="Asia/Tehran"
LOCALE="en_US.UTF-8"
KEYMAP="us"

# Hardware detection variables
CPU_VENDOR=""
GPU_VENDOR=""
HAS_WIFI=""
HAS_BLUETOOTH=""
IS_LAPTOP=""
TOTAL_RAM=""
DISK_DEVICE=""

# Installation options
INSTALL_DOTFILES=""
DOTFILES_REPO=""

# Iranian DNS servers
IRANIAN_DNS_PRIMARY="10.70.95.150"
IRANIAN_DNS_SECONDARY="10.70.95.162"
FALLBACK_DNS="1.1.1.1"

# Core functions
log() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗ ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$LOG_FILE"
}

# Beautiful header
show_header() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                   🏛️  ARCH HYPRLAND BARE                     ║
║                                                               ║
║           Zero-animation perfection for developers           ║
║              Optimized for Iranian networks                  ║
║                                                               ║
║                 Inspired by Omarchy                          ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# Check if running from Arch ISO
check_environment() {
    if [[ ! -f /etc/arch-release ]]; then
        error "This script must be run from an Arch Linux ISO"
    fi
    
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        error "No internet connection. Please connect to WiFi/Ethernet first"
    fi
    
    success "Environment checks passed"
}

# Hardware detection
detect_hardware() {
    log "Detecting hardware configuration..."
    
    # CPU detection
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        CPU_VENDOR="intel"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        CPU_VENDOR="amd"
    else
        CPU_VENDOR="unknown"
    fi
    
    # GPU detection
    local gpu_info=$(lspci | grep -E "VGA|3D|Display" | head -1)
    if echo "$gpu_info" | grep -i nvidia >/dev/null; then
        GPU_VENDOR="nvidia"
    elif echo "$gpu_info" | grep -i amd >/dev/null; then
        GPU_VENDOR="amd"
    elif echo "$gpu_info" | grep -i intel >/dev/null; then
        GPU_VENDOR="intel"
    else
        GPU_VENDOR="unknown"
    fi
    
    # WiFi detection
    if lspci | grep -i wireless >/dev/null || lsusb | grep -i wireless >/dev/null; then
        HAS_WIFI="yes"
    else
        HAS_WIFI="no"
    fi
    
    # Bluetooth detection
    if lsusb | grep -i bluetooth >/dev/null || dmesg | grep -i bluetooth >/dev/null 2>&1; then
        HAS_BLUETOOTH="yes"
    else
        HAS_BLUETOOTH="no"
    fi
    
    # Laptop detection
    if ls /sys/class/power_supply/ 2>/dev/null | grep -i bat >/dev/null; then
        IS_LAPTOP="yes"
    else
        IS_LAPTOP="no"
    fi
    
    # RAM detection
    TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
    
    # Disk detection
    DISK_DEVICE=$(lsblk -d -n -o NAME,SIZE,TYPE | awk '$3=="disk" {print "/dev/"$1; exit}')
    
    info "Hardware detected: CPU=$CPU_VENDOR, GPU=$GPU_VENDOR, RAM=${TOTAL_RAM}GB, Laptop=$IS_LAPTOP"
    success "Hardware detection completed"
}

# Beautiful TUI input functions
get_user_input() {
    show_header
    echo -e "${WHITE}Welcome to Arch Hyprland installation!${NC}"
    echo "This will install a complete Arch Linux system with Hyprland."
    echo -e "${YELLOW}⚠ This will FORMAT your entire disk!${NC}\n"
    
    # Show detected hardware
    echo -e "${CYAN}Detected Hardware:${NC}"
    echo "• CPU: $CPU_VENDOR"
    echo "• GPU: $GPU_VENDOR"
    echo "• RAM: ${TOTAL_RAM}GB"
    echo "• Device Type: $([ "$IS_LAPTOP" = "yes" ] && echo "Laptop" || echo "Desktop")"
    echo "• WiFi: $HAS_WIFI"
    echo "• Target Disk: $DISK_DEVICE"
    echo ""
    
    # Get hostname
    while [[ -z "$HOSTNAME" ]]; do
        read -p "$(echo -e ${BLUE}🖥️  Enter hostname [arch-dev]: ${NC})" HOSTNAME
        HOSTNAME=${HOSTNAME:-arch-dev}
        if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9-]+$ ]]; then
            echo -e "${RED}Invalid hostname. Use only letters, numbers, and hyphens.${NC}"
            HOSTNAME=""
        fi
    done
    
    # Get username
    while [[ -z "$USERNAME" ]]; do
        read -p "$(echo -e ${BLUE}👤 Enter username: ${NC})" USERNAME
        if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            echo -e "${RED}Invalid username. Must start with letter, use lowercase.${NC}"
            USERNAME=""
        fi
    done
    
    # Get user password
    while [[ -z "$USER_PASSWORD" ]]; do
        read -s -p "$(echo -e ${BLUE}🔑 Enter password for $USERNAME: ${NC})" USER_PASSWORD
        echo
        if [[ ${#USER_PASSWORD} -lt 6 ]]; then
            echo -e "${RED}Password must be at least 6 characters.${NC}"
            USER_PASSWORD=""
            continue
        fi
        read -s -p "$(echo -e ${BLUE}🔑 Confirm password: ${NC})" USER_PASSWORD_CONFIRM
        echo
        if [[ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]]; then
            echo -e "${RED}Passwords do not match.${NC}"
            USER_PASSWORD=""
        fi
    done
    
    # Get root password
    while [[ -z "$ROOT_PASSWORD" ]]; do
        read -s -p "$(echo -e ${BLUE}🔐 Enter root password: ${NC})" ROOT_PASSWORD
        echo
        if [[ ${#ROOT_PASSWORD} -lt 6 ]]; then
            echo -e "${RED}Root password must be at least 6 characters.${NC}"
            ROOT_PASSWORD=""
            continue
        fi
        read -s -p "$(echo -e ${BLUE}🔐 Confirm root password: ${NC})" ROOT_PASSWORD_CONFIRM
        echo
        if [[ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]]; then
            echo -e "${RED}Passwords do not match.${NC}"
            ROOT_PASSWORD=""
        fi
    done
    
    # Timezone selection
    echo ""
    read -p "$(echo -e ${BLUE}🌍 Timezone [Asia/Tehran]: ${NC})" TIMEZONE_INPUT
    TIMEZONE=${TIMEZONE_INPUT:-Asia/Tehran}
    
    # Dotfiles option
    echo ""
    read -p "$(echo -e ${BLUE}📁 Do you want to setup dotfiles with chezmoi? [y/N]: ${NC})" SETUP_DOTFILES
    if [[ "$SETUP_DOTFILES" =~ ^[Yy]$ ]]; then
        read -p "$(echo -e ${BLUE}📦 Enter your dotfiles repository URL: ${NC})" DOTFILES_REPO
        INSTALL_DOTFILES="yes"
    fi
    
    # Final confirmation
    echo ""
    echo -e "${YELLOW}═══ INSTALLATION SUMMARY ═══${NC}"
    echo "Hostname: $HOSTNAME"
    echo "Username: $USERNAME"
    echo "Timezone: $TIMEZONE"
    echo "Target Disk: $DISK_DEVICE (${TOTAL_RAM}GB RAM detected)"
    echo "Hardware: $CPU_VENDOR CPU, $GPU_VENDOR GPU"
    echo "Device Type: $([ "$IS_LAPTOP" = "yes" ] && echo "Laptop" || echo "Desktop")"
    if [[ "$INSTALL_DOTFILES" = "yes" ]]; then
        echo "Dotfiles: $DOTFILES_REPO"
    fi
    echo ""
    echo -e "${RED}⚠ WARNING: This will ERASE ALL DATA on $DISK_DEVICE!${