# 📱 Post-Installation Application Guide

After your Arch Hyprland Bare installation, you'll want to install additional applications based on your needs. This guide follows the Omarchy "bare" philosophy - install only what you need.

## 🎯 Core Applications (Install These First)

### Development Tools
```bash
# Visual Studio Code
yay -S visual-studio-code-bin

# Alternative editors
yay -S cursor-bin          # AI-powered editor
yay -S sublime-text-4      # Fast text editor
```

### Productivity
```bash
# Note-taking and knowledge management
yay -S obsidian

# Office suite (if needed)
pacman -S libreoffice-fresh

# PDF viewer
pacman -S zathura zathura-pdf-mupdf
```

### Media & Entertainment
```bash
# Browsers
pacman -S firefox          # Already have Chromium

# Media player (already have mpv)
pacman -S vlc              # Alternative player

# Streaming & Recording
pacman -S obs-studio       # Video recording/streaming

# Music
yay -S spotify
# or
pacman -S rhythmbox        # GNOME music player
```

### Communication
```bash
# Messaging
pacman -S telegram-desktop
yay -S discord
yay -S element-desktop     # Matrix client

# Email (if not using web)
pacman -S thunderbird
```

## 🛠️ DevOps & Development

### Containers & Orchestration
```bash
# Docker
pacman -S docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Kubernetes tools
pacman -S kubectl
yay -S k9s               # Kubernetes TUI
yay -S helm              # Package manager

# Alternative: Podman (Docker alternative)
pacman -S podman podman-compose
```

### Cloud CLIs
```bash
# AWS CLI
pacman -S aws-cli-v2

# Azure CLI
yay -S azure-cli

# Google Cloud
yay -S google-cloud-cli

# DigitalOcean
yay -S doctl
```

### Infrastructure as Code
```bash
# Terraform
yay -S terraform

# Ansible
pacman -S ansible

# Packer
yay -S packer
```

### Programming Languages
```bash
# Go
pacman -S go

# Python (already installed, but add tools)
pacman -S python-pip python-pipenv
yay -S python-poetry

# Node.js
pacman -S nodejs npm
yay -S nvm              # Node version manager

# Rust
pacman -S rustup
rustup default stable

# Java
pacman -S jdk-openjdk

# PHP
pacman -S php composer
```

### Monitoring & Observability
```bash
# Prometheus & Grafana
yay -S prometheus grafana

# ELK Stack
yay -S elasticsearch kibana logstash

# System monitoring
pacman -S netdata       # Real-time monitoring
yay -S ctop             # Container monitoring
```

## 🎨 Graphics & Design

```bash
# Image editing
pacman -S gimp
yay -S figma-linux      # Design tool

# Vector graphics
pacman -S inkscape

# Photo management
pacman -S digikam

# Color picker
pacman -S gcolor3
```

## 🎮 Gaming (Optional)

```bash
# Steam
pacman -S steam

# Game launchers
yay -S lutris           # Wine gaming
yay -S heroic-games-launcher  # Epic Games

# Emulation
pacman -S retroarch
```

## 📚 Learning & Research

```bash
# Ebook reader
pacman -S foliate

# Research tools
yay -S zotero           # Reference manager
yay -S anki             # Flashcards

# Language learning
yay -S busuu
```

## 🔐 Security & Privacy

```bash
# Password manager
yay -S bitwarden       # or use browser extension

# VPN clients
yay -S protonvpn
pacman -S openvpn

# Encryption
pacman -S veracrypt

# Network security
pacman -S wireshark-qt nmap
```

## 🌐 Web Development

```bash
# Local development
yay -S laravel-installer
pacman -S apache php-apache mariadb

# API testing
yay -S insomnia-bin     # Alternative to Postman
yay -S httpie           # CLI HTTP client

# Database tools
yay -S dbeaver          # Universal database tool
pacman -S postgresql-client mysql-clients
```

## 📱 Mobile Development

```bash
# Android development
yay -S android-studio

# Flutter
yay -S flutter

# React Native
npm install -g @react-native-community/cli
```

## 🎵 Audio Production

```bash
# Digital Audio Workstation
pacman -S audacity ardour

# Audio editing
pacman -S lmms          # Music production
```

## 💡 Installation Tips

### Prioritize by Usage
1. **Daily Tools**: VSCode, Firefox, Telegram
2. **Work Tools**: Docker, kubectl, your language runtimes
3. **Media**: Spotify, OBS (if you stream/record)
4. **Optional**: Games, design tools, specialized software

### Package Sources Priority
1. **Official repos** (pacman) - Most stable
2. **AUR** (yay) - Community packages, usually safe
3. **Flatpak** - For apps not in AUR
4. **AppImage** - Last resort for proprietary software

### Memory Management
With your Hyprland setup being so efficient, you have more RAM for applications:
- Base system: ~600MB
- With VSCode + Firefox + Spotify: ~2-3GB
- Still plenty for development work

### Persian Language Apps
```bash
# Persian calendar
yay -S persian-calendar

# Persian fonts (already installed in base)
# Additional: yay -S ttf-iranian-fonts

# Persian input methods (already configured)
# fcitx5 is set up with us,ir layouts
```

## 🚀 Quick Install Scripts

Create these aliases in your `~/.bashrc`:

```bash
# Quick install common development stack
alias install-dev="yay -S visual-studio-code-bin docker docker-compose kubectl terraform ansible go nodejs npm python-poetry"

# Quick install media stack  
alias install-media="pacman -S firefox obs-studio && yay -S spotify discord"

# Quick install design stack
alias install-design="pacman -S gimp inkscape && yay -S figma-linux"
```

## 🔄 Maintenance

```bash
# Update everything
yay -Syu

# Clean package cache
yay -Sc

# Remove orphaned packages
pacman -Rns $(pacman -Qtdq)

# Check for config file changes
pacdiff
```

Remember: The beauty of Arch Hyprland Bare is its minimalism. Install only what you actively use. You can always add more later!