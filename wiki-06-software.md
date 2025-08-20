# 06. Essential Software

> **Installing and configuring essential applications for daily use**

## 🎯 Overview

Essential software categories:
- Web browsers
- Development tools
- Media applications
- Office suite
- System utilities
- Communication tools
- File management

## 🌐 Web Browsers

### Firefox (Wayland Optimized)
```bash
# Install Firefox
sudo pacman -S firefox

# Create desktop entry for Wayland
cat > ~/.local/share/applications/firefox-wayland.desktop << 'EOF'
[Desktop Entry]
Name=Firefox (Wayland)
Exec=MOZ_ENABLE_WAYLAND=1 firefox %u
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF

# Set as default browser
xdg-settings set default-web-browser firefox-wayland.desktop
```

### Brave Browser
```bash
# Install Brave
yay -S brave-bin

# Wayland flags for Brave
cat > ~/.config/brave-flags.conf << 'EOF'
--enable-features=UseOzonePlatform
--ozone-platform=wayland
--enable-wayland-ime
EOF
```

### Chromium
```bash
# Install Chromium
sudo pacman -S chromium

# Wayland flags
cat > ~/.config/chromium-flags.conf << 'EOF'
--enable-features=UseOzonePlatform
--ozone-platform=wayland
EOF
```

## 💻 Development Environment

### VS Code
```bash
# Install VS Code
yay -S visual-studio-code-bin

# Install extensions via command line
code --install-extension catppuccin.catppuccin-vsc
code --install-extension catppuccin.catppuccin-vsc-icons
code --install-extension ms-python.python
code --install-extension golang.go
code --install-extension rust-lang.rust-analyzer
code --install-extension bradlc.vscode-tailwindcss
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension eamodio.gitlens
code --install-extension github.copilot
```

### Terminal Tools
```bash
# Modern CLI tools
sudo pacman -S \
  zsh zsh-completions \
  fish \
  tmux \
  ranger \
  lf \
  fzf \
  ripgrep \
  fd \
  bat \
  eza \
  zoxide \
  starship

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Programming Languages
```bash
# Python
sudo pacman -S python python-pip python-virtualenv

# Node.js
sudo pacman -S nodejs npm yarn

# Go
sudo pacman -S go

# Rust
sudo pacman -S rust rust-analyzer

# Java
sudo pacman -S jdk-openjdk

# Docker
sudo pacman -S docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Git Configuration
```bash
# Install Git tools
sudo pacman -S git github-cli lazygit

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global core.editor "code --wait"

# Git credentials
git config --global credential.helper store
```

## 🎵 Media Applications

### Audio/Video Players
```bash
# Media players
sudo pacman -S mpv vlc spotify-launcher

# MPV configuration for performance
mkdir -p ~/.config/mpv
cat > ~/.config/mpv/mpv.conf << 'EOF'
# Performance
vo=gpu
hwdec=auto
gpu-api=vulkan

# Quality
profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp

# Cache
cache=yes
cache-secs=300
demuxer-max-bytes=150M
demuxer-max-back-bytes=75M

# YouTube
ytdl-format=bestvideo[height<=?1080]+bestaudio/best
EOF
```

### Image Tools
```bash
# Image viewers and editors
sudo pacman -S \
  feh \
  imv \
  gimp \
  inkscape \
  krita

# Screenshots
yay -S flameshot-git
```

### YouTube Download
```bash
# Install yt-dlp
sudo pacman -S yt-dlp

# Create alias for common use
echo "alias yt='yt-dlp -f \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best\"'" >> ~/.zshrc
echo "alias yt-mp3='yt-dlp -x --audio-format mp3'" >> ~/.zshrc
```

## 📄 Office & Productivity

### LibreOffice
```bash
# Install LibreOffice
sudo pacman -S libreoffice-fresh libreoffice-fresh-en-us

# Optional: OnlyOffice (better MS Office compatibility)
yay -S onlyoffice-bin
```

### Note Taking
```bash
# Obsidian (Markdown notes)
yay -S obsidian-bin

# Joplin (Open source alternative)
yay -S joplin-desktop

# Simple note taking
sudo pacman -S xournalpp
```

### PDF Tools
```bash
# PDF viewers and tools
sudo pacman -S \
  zathura zathura-pdf-poppler \
  evince \
  okular \
  pdfarranger

# Zathura configuration
mkdir -p ~/.config/zathura
cat > ~/.config/zathura/zathurarc << 'EOF'
# Catppuccin Mocha theme
set default-bg "#1e1e2e"
set default-fg "#cdd6f4"
set statusbar-bg "#313244"
set statusbar-fg "#cdd6f4"
set inputbar-bg "#313244"
set inputbar-fg "#cdd6f4"
set recolor true
set recolor-lightcolor "#1e1e2e"
set recolor-darkcolor "#cdd6f4"
EOF
```

## 💬 Communication

### Discord
```bash
# Install Discord with Wayland support
yay -S discord_arch_electron

# Or WebCord (lighter alternative)
yay -S webcord-bin
```

### Slack
```bash
# Install Slack
yay -S slack-desktop-wayland
```

### Telegram
```bash
# Install Telegram
sudo pacman -S telegram-desktop
```

### Email Client
```bash
# Thunderbird
sudo pacman -S thunderbird

# Or Geary (simpler)
sudo pacman -S geary
```

## 🗂️ File Management

### GUI File Managers
```bash
# Already installed: Thunar
# Additional options:

# Nautilus (GNOME)
sudo pacman -S nautilus

# Dolphin (KDE)
sudo pacman -S dolphin

# PCManFM (Lightweight)
sudo pacman -S pcmanfm-gtk3
```

### Cloud Storage
```bash
# Dropbox
yay -S dropbox

# Google Drive
yay -S google-drive-ocamlfuse-opam

# Rclone (multiple clouds)
sudo pacman -S rclone

# Syncthing (P2P sync)
sudo pacman -S syncthing
sudo systemctl enable syncthing@$USER
```

### Archive Tools
```bash
# GUI archive manager
sudo pacman -S file-roller

# CLI tools
sudo pacman -S \
  zip unzip \
  rar unrar \
  p7zip \
  tar \
  xz
```

## 🛠️ System Utilities

### System Monitoring
```bash
# System monitors
sudo pacman -S \
  htop \
  btop \
  gtop \
  iotop \
  nethogs \
  ncdu

# GUI system monitor
sudo pacman -S gnome-system-monitor
```

### Package Management GUI
```bash
# Pamac (GUI for pacman/AUR)
yay -S pamac-aur

# Enable AUR in Pamac
sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf
```

### Backup Tools
```bash
# Timeshift (already configured)
sudo pacman -S timeshift

# Deja Dup (simple backups)
sudo pacman -S deja-dup

# rsync (for scripts)
sudo pacman -S rsync

# Create backup script
cat > ~/bin/backup.sh << 'EOF'
#!/bin/bash
rsync -avzP --delete \
  --exclude='.cache' \
  --exclude='.local/share/Trash' \
  --exclude='Downloads' \
  $HOME/ /path/to/backup/
EOF
chmod +x ~/bin/backup.sh
```

### Security Tools
```bash
# Firewall GUI
sudo pacman -S firewalld
yay -S firewall-config

# Password manager
sudo pacman -S keepassxc

# Or Bitwarden
yay -S bitwarden-bin

# VPN
yay -S mullvad-vpn-bin
# Or
sudo pacman -S openvpn networkmanager-openvpn
```

## 🎮 Gaming (Optional)

### Steam
```bash
# Enable multilib repository first (in /etc/pacman.conf)
sudo pacman -S steam

# Steam dependencies
sudo pacman -S lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader
```

### Lutris
```bash
# Gaming platform
sudo pacman -S lutris

# Wine dependencies
sudo pacman -S wine-staging wine-gecko wine-mono
```

### Gaming Tools
```bash
# MangoHud (performance overlay)
sudo pacman -S mangohud lib32-mangohud

# GameMode (performance optimization)
sudo pacman -S gamemode lib32-gamemode
```

## 🔌 Hardware Support

### Printing
```bash
# CUPS and drivers
sudo pacman -S cups cups-pdf system-config-printer
sudo pacman -S gutenprint foomatic-db-gutenprint-ppds

# Enable service
sudo systemctl enable cups.service
```

### Scanning
```bash
# SANE and frontends
sudo pacman -S sane simple-scan

# For HP devices
sudo pacman -S hplip
```

### Webcam
```bash
# Webcam tools
sudo pacman -S v4l-utils guvcview cheese

# Test webcam
mpv av://v4l2:/dev/video0
```

## 📱 Mobile Device Support

### Android
```bash
# MTP support (already installed with gvfs-mtp)
# ADB and Fastboot
sudo pacman -S android-tools

# Scrcpy (screen mirroring)
sudo pacman -S scrcpy
```

### iOS
```bash
# iOS support
sudo pacman -S libimobiledevice ifuse

# Mount iOS device
# Connect device, trust computer on device
idevicepair pair
mkdir ~/iPhone
ifuse ~/iPhone
```

## 🎬 Streaming & Recording

### OBS Studio
```bash
# Install OBS
sudo pacman -S obs-studio

# Plugins
yay -S obs-plugin-input-overlay-bin obs-streamfx
```

### SimpleScreenRecorder
```bash
# Simpler alternative to OBS
sudo pacman -S simplescreenrecorder
```

## 🔧 System Optimization Scripts

### Create useful aliases
```bash
cat >> ~/.zshrc << 'EOF'

# System aliases
alias update='yay -Syu'
alias cleanup='yay -Sc && yay -Yc'
alias mirrors='sudo reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='eza -la --icons'
alias ls='eza --icons'
alias tree='eza --tree --icons'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias g='git'
alias v='nvim'
alias c='code'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias cd='z'

# System info
alias fetch='neofetch'
alias df='df -h'
alias free='free -h'
EOF
```

### Auto-start applications
```bash
# Create autostart directory
mkdir -p ~/.config/autostart

# Example: Start Dropbox
cat > ~/.config/autostart/dropbox.desktop << 'EOF'
[Desktop Entry]
Type=Application
Exec=dropbox
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Dropbox
EOF
```

## 📋 Quick Software Installation Script

```bash
# Create a quick install script for all essentials
cat > ~/install-software.sh << 'EOF'
#!/bin/bash

# Update system
sudo pacman -Syu

# Essential packages
PACKAGES=(
    # Browsers
    firefox chromium
    
    # Development
    git github-cli vim neovim code
    nodejs npm python python-pip go rust
    docker docker-compose
    
    # Terminal
    zsh tmux ranger fzf ripgrep fd bat eza zoxide starship
    
    # Media
    mpv vlc spotify-launcher yt-dlp
    gimp inkscape
    
    # Office
    libreoffice-fresh zathura evince
    
    # Communication
    telegram-desktop thunderbird
    
    # System
    htop btop ncdu nethogs
    timeshift rsync
    keepassxc
    
    # File management
    thunar file-roller
    
    # Utilities
    curl wget unzip p7zip
)

sudo pacman -S --needed "${PACKAGES[@]}"

# AUR packages
AUR_PACKAGES=(
    yay-bin
    brave-bin
    visual-studio-code-bin
    discord_arch_electron
    obsidian-bin
    bitwarden-bin
)

for package in "${AUR_PACKAGES[@]}"; do
    yay -S --needed "$package"
done

echo "Software installation complete!"
EOF

chmod +x ~/install-software.sh
```

---

<div align="center">

[← Previous: Hyprland Setup](05-Hyprland-Setup) • [Next: Theming →](07-Theming)

</div>