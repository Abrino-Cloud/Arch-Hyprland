# 🏛️ Arch Hyprland - Complete Guide

> **Zero-animation Arch Linux with Hyprland, optimized for Iranian developers and DevOps professionals**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=fff)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?logo=wayland&logoColor=white)](https://hyprland.org/)
[![Catppuccin](https://img.shields.io/badge/Catppuccin-F5E0DC?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iIzMwMjQ0NiIgZD0iTTEyIDJDNi40OCAyIDIgNi40OCAyIDEyczQuNDggMTAgMTAgMTAgMTAtNC40OCAxMC0xMFMxNy41MiAyIDEyIDJ6Ii8+PC9zdmc+)](https://github.com/catppuccin)

Inspired by [Omarchy](https://omarchy.org/) but tailored for **Iranian developers** with proper DNS configuration, DevOps tools, and intelligent hardware detection.

## 🎯 Philosophy

This setup follows the **Omarchy philosophy** of speed and simplicity while adding:

- **🇮🇷 Iranian optimization** - Anti-sanctions DNS, fast local mirrors
- **⚡ Zero animations** - Instant response, no visual fluff  
- **🛠️ DevOps focus** - Terminal-first workflow for cloud professionals
- **🎨 Catppuccin everywhere** - Consistent, beautiful theming
- **📱 Modern tooling** - Latest CLI tools and applications

## 🚀 Quick Installation

### One-Command Install
Boot from Arch ISO, connect to internet, then:

```bash
curl -L https://raw.githubusercontent.com/Abrino-Cloud/Arch-Hyprland/main/arch-hyprland-bare.sh | bash
```

The script will:
1. **Ask for basic info** (hostname, username, password)
2. **Detect your hardware** (GPU, laptop/desktop, WiFi)
3. **Install everything** (base system, Hyprland, applications)
4. **Configure optimally** (Iranian DNS, mirrors, drivers)
5. **Setup dotfiles** (Chezmoi integration)

### Manual Installation
```bash
# Download and inspect
git clone https://github.com/Abrino-Cloud/Arch-Hyprland.git
cd Arch-Hyprland
chmod +x arch-hyprland-bare.sh
./arch-hyprland-bare.sh
```

## ✨ What Gets Installed

### 🎨 Core System
- **Hyprland** - Zero-animation Wayland compositor
- **Catppuccin Mocha** - Beautiful dark theme
- **Waybar** - Minimal status bar
- **Rofi** - Application launcher
- **Dunst** - Lightweight notifications
- **SDDM** - Display manager

### 💻 Development Environment
- **Ghostty** - Modern GPU-accelerated terminal
- **VSCode** - Microsoft's popular editor
- **tmux** - Terminal multiplexer (fully configured)
- **Chezmoi** - Dotfiles management
- **lazygit** - Beautiful git TUI
- **lazydocker** - Docker management TUI

### 🌐 Applications
- **Firefox** - Primary browser
- **Chromium** - Secondary browser
- **Obsidian** - Knowledge management
- **mpv** - Video player
- **OBS Studio** - Streaming/recording
- **Spotify** - Music streaming
- **Telegram** - Messaging

### 🛠️ Shell Tools (Omarchy-inspired)
- **eza** - Modern `ls` replacement
- **fzf** - Fuzzy finder
- **ripgrep** - Fast text search
- **fd** - Better `find`
- **zoxide** - Smart `cd`
- **btop** - Resource monitor
- **fastfetch** - System information

### 🗂️ File Management
- **Thunar** - GUI file manager
- **ranger** - Terminal file manager
- **Clipboard manager** - Integrated with Ghostty/tmux/Hyprland

### 🔧 DevOps Tools Overview
Perfect foundation for cloud/DevOps professionals (install later):

**Container & Orchestration:**
- Docker & Docker Compose
- Kubernetes (kubectl, k9s, helm)
- Podman & Buildah

**Cloud Providers:**
- AWS CLI v2
- Azure CLI
- Google Cloud SDK
- Terraform
- Ansible

**Monitoring & Observability:**
- Prometheus tools
- Grafana
- ELK stack clients
- OpenTelemetry

**Infrastructure as Code:**
- Terraform
- Pulumi
- CloudFormation tools
- Ansible

**CI/CD Tools:**
- GitHub CLI
- GitLab CLI
- Jenkins tools
- ArgoCD CLI

## 🇮🇷 Iranian Optimizations

### Network Configuration
- **Anti-Sanctions DNS**: `10.70.95.150`, `10.70.95.162`
- **Fast Iranian mirrors**: IUT Tehran, Yazd University
- **Optimized TCP settings** for Iranian connections
- **VPN-ready** configuration

### Regional Support
- **Persian fonts** included
- **Right-to-left** text support
- **Iranian timezone** (Asia/Tehran)
- **Local community** links and resources

## 🖥️ Hardware Support

### Automatic Detection
- **Intel/AMD CPUs** - Microcode installation
- **NVIDIA/AMD/Intel GPUs** - Driver auto-installation
- **Laptops** - Power management, brightness controls
- **WiFi/Bluetooth** - Service configuration
- **Multi-monitor** - Intelligent setup

### Performance Optimization
- **ZRAM** instead of swap
- **BTRFS compression** for storage efficiency
- **CPU governors** optimized per device type
- **Graphics acceleration** properly configured

## 🎨 Catppuccin Theme Details

### Color Palette (Mocha)
```
Base:     #1e1e2e    Surface0: #313244
Mantle:   #181825    Surface1: #45475a  
Crust:    #11111b    Surface2: #585b70

Text:     #cdd6f4    Blue:     #89b4fa
Subtext1: #bac2de    Lavender: #b4befe
Subtext0: #a6adc8    Sapphire: #74c7ec
Overlay2: #9399b2    Sky:      #89dceb
Overlay1: #7f849c    Teal:     #94e2d5
Overlay0: #6c7086    Green:    #a6e3a1
```

### Themed Applications
- **Hyprland** - Window borders, gaps
- **Waybar** - Status bar colors
- **Rofi** - Launcher theme
- **Ghostty** - Terminal colors
- **VSCode** - Editor theme
- **tmux** - Status line colors
- **Dunst** - Notification styling

## 🔧 Configuration Highlights

### Zero-Animation Hyprland
```ini
animations {
    enabled = false
}

decoration {
    rounding = 0
    blur { enabled = false }
    drop_shadow = false
}

misc {
    disable_hyprland_logo = true
    vfr = true
    vrr = 1
}
```

### tmux Configuration
- **Prefix**: `Ctrl-a` (easier than `Ctrl-b`)
- **Vi mode** for copy/paste
- **Mouse support** enabled
- **Catppuccin theme** applied
- **Smart pane switching** with vim-like navigation
- **Session resurrection** for persistent workflows

### Ghostty Terminal
- **GPU acceleration** for smooth performance
- **Catppuccin colors** integrated
- **Font**: JetBrains Mono Nerd Font
- **Clipboard integration** with Wayland
- **tmux integration** optimized

## 📦 Package Categories

### Essential (Always Installed)
- Base system with encryption
- Hyprland compositor
- Core applications
- Development tools
- Shell utilities

### Optional DevOps Extensions
Install later based on your needs:

```bash
# Container platforms
yay -S docker docker-compose podman buildah

# Kubernetes tools  
yay -S kubectl k9s helm

# Cloud CLIs
yay -S aws-cli-v2 azure-cli google-cloud-sdk

# Infrastructure tools
yay -S terraform ansible packer vault

# Monitoring
yay -S prometheus grafana-cli

# Programming languages
yay -S go rust nodejs python

# Additional shells
yay -S fish zsh starship
```

## 🗂️ Directory Structure

```
/home/username/
├── .config/
│   ├── hypr/           # Hyprland configuration
│   ├── waybar/         # Status bar config
│   ├── ghostty/        # Terminal settings
│   ├── rofi/           # Launcher themes
│   └── chezmoi/        # Dotfiles management
├── .local/
│   ├── bin/            # Custom scripts
│   └── share/          # Application data
├── projects/           # Development workspace
├── .dotfiles/          # Chezmoi source
└── bin/                # Personal scripts
```

## 🔐 Security Features

### Disk Encryption
- **LUKS2** full disk encryption
- **Secure Boot** preparation
- **BTRFS** with compression
- **Automatic snapshots** via Timeshift

### Network Security
- **Firewall** (UFW) configured
- **VPN-ready** setup
- **Secure DNS** configuration
- **Anti-tracking** browser settings

## 🚀 Performance Benchmarks

### Boot Time (NVMe SSD)
- **GRUB to login**: ~6 seconds
- **Login to desktop**: ~2 seconds  
- **Application launch**: Instant

### Resource Usage (Idle)
- **RAM usage**: ~600MB total
- **Hyprland**: ~40MB
- **Waybar**: ~12MB
- **Background services**: ~150MB

## 🔧 Customization

### Adding Your Dotfiles
```bash
# Initialize chezmoi with your repo
chezmoi init git@github.com:yourusername/dotfiles.git

# Apply configurations
chezmoi apply

# Keep updated
chezmoi update
```

### Monitor Configuration
```bash
# List available monitors
hyprctl monitors

# Configure in hyprland.conf
monitor = DP-1,2560x1440@144,0x0,1
monitor = HDMI-A-1,1920x1080@60,2560x0,1
```

### Adding Applications
```bash
# Official repository
sudo pacman -S package-name

# AUR packages
yay -S aur-package

# Flatpak applications
flatpak install app-name
```

## 🛠️ Daily Workflow

### Terminal-Centric
1. **Boot** → Auto-login to Hyprland
2. **Super+Return** → Open Ghostty terminal
3. **tmux** → Start multiplexed session
4. **cd projects/myproject** → Navigate to work
5. **code .** → Open VSCode
6. **lazygit** → Git management
7. **Super+Space** → Launch applications as needed

### DevOps Tasks
```bash
# Container management
lazydocker                    # Visual Docker management
docker ps                     # List containers
kubectl get pods             # K8s pod status

# Infrastructure
terraform plan               # Plan infrastructure changes
ansible-playbook deploy.yml  # Run deployments

# Monitoring
btop                         # System resources
htop                         # Process management
```

## 🌍 Community & Support

### Iranian Community
- [Arch Linux Iran](https://t.me/archlinux_ir) - Persian Arch community
- [Linux Iran](https://t.me/linuxir) - General Linux support
- [DevOps Iran](https://t.me/devops_ir) - DevOps professionals

### Global Resources
- [Hyprland Discord](https://discord.gg/hQ9XvMUjjr)
- [Arch Linux Forums](https://bbs.archlinux.org/)
- [r/hyprland](https://reddit.com/r/hyprland)

### Getting Help
1. **Check documentation** first
2. **Search issues** on GitHub
3. **Join Telegram groups** for real-time help
4. **Create detailed issues** with logs

## 📊 Compatibility Matrix

| Component | Support | Notes |
|-----------|---------|--------|
| **Intel GPU** | ✅ Full | All generations |
| **AMD GPU** | ✅ Full | RDNA+ recommended |
| **NVIDIA GPU** | ✅ Full | GTX 900+ optimal |
| **WiFi Intel** | ✅ Full | Out of box |
| **WiFi Realtek** | ✅ Full | Auto-configured |
| **Bluetooth** | ✅ Full | All major chips |
| **Laptops** | ✅ Full | Power management |
| **Multi-monitor** | ✅ Full | Auto-detection |
| **HiDPI** | ✅ Full | Fractional scaling |

## 🔄 Maintenance

### Daily Commands
```bash
# Update system
yay -Syu

# Update dotfiles  
chezmoi update

# Clean package cache
yay -Sc
```

### Weekly Tasks
- Review system logs: `journalctl -p 3`
- Clean orphaned packages: `yay -Rns $(yay -Qtdq)`
- Create system snapshot: `sudo timeshift --create`

### Monthly Tasks
- Update mirrors: `sudo reflector --country Iran --save /etc/pacman.d/mirrorlist`
- Check disk health: `sudo smartctl -a /dev/nvme0n1`
- Review security: `arch-audit`

## 🎓 Learning Path

### For Beginners
1. **Learn Hyprland basics** - Window management, workspaces
2. **Master tmux** - Session management, pane splitting
3. **Explore CLI tools** - eza, fzf, ripgrep workflow
4. **Customize configs** - Colors, keybindings, layouts

### For Advanced Users
1. **Custom Hyprland scripts** - Window rules, automation
2. **Advanced tmux** - Custom layouts, scripting
3. **DevOps integration** - Container workflows, CI/CD
4. **Performance tuning** - Kernel parameters, hardware optimization

## 🤝 Contributing

### How to Contribute
1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Test thoroughly** on fresh Arch installation
4. **Submit pull request** with detailed description

### Areas for Contribution
- **Hardware support** improvements
- **Performance optimizations** 
- **Application integrations**
- **Documentation** updates
- **Persian translations**
- **Video tutorials**

### Reporting Issues
Include:
- System information (`neofetch`)
- Hardware details (`lspci`, `lscpu`)
- Error logs (`journalctl -b`)
- Steps to reproduce

## 📜 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) for details.

### What This Means
- ✅ Free to use, modify, distribute
- ✅ Commercial use allowed
- ✅ Private use allowed
- ❗ No warranty provided
- ❗ Must include license notice

## 🙏 Acknowledgments

### Inspiration & Thanks
- **[Omarchy](https://omarchy.org/)** - Original inspiration and methodology
- **[Arch Linux](https://archlinux.org/)** - The amazing distribution
- **[Hyprland](https://hyprland.org/)** - Modern Wayland compositor
- **[Catppuccin](https://github.com/catppuccin)** - Beautiful color scheme
- **[Iranian Arch Community](https://t.me/archlinux_ir)** - Local support

### Technologies Used
- [Arch Linux](https://archlinux.org/) - Base distribution
- [Hyprland](https://hyprland.org/) - Wayland compositor
- [Catppuccin](https://github.com/catppuccin) - Color scheme
- [Chezmoi](https://chezmoi.io/) - Dotfiles management
- [Ghostty](https://ghostty.org/) - Terminal emulator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

---

<div align="center">

**🏛️ Arch Hyprland - Zero-animation perfection for Iranian developers**

[📖 Installation Guide](./docs/INSTALLATION.md) • [🔧 Post-Install](./docs/POST-INSTALL.md) • [🐛 Report Issue](../../issues) • [💬 Community](https://t.me/archlinux_ir)

*"Performance, simplicity, beauty - optimized for Iran"*

</div>