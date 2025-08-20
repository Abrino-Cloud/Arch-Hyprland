# 08. Dotfiles Management

> **Managing your configuration files with Chezmoi for easy backup and deployment**

## 🎯 Overview

Chezmoi helps you:
- Manage dotfiles across multiple machines
- Keep sensitive data secure
- Version control your configurations
- Easily deploy to new systems
- Handle machine-specific differences

## 📦 Install Chezmoi

```bash
# Install chezmoi
sudo pacman -S chezmoi

# Or install latest version
sh -c "$(curl -fsLS get.chezmoi.io)"
```

## 🚀 Initialize Chezmoi

### First Time Setup
```bash
# Initialize chezmoi with a new repo
chezmoi init

# This creates:
# ~/.local/share/chezmoi/ (source directory)
# ~/.config/chezmoi/chezmoi.toml (config file)
```

### Initialize with GitHub
```bash
# Create a new GitHub repository for your dotfiles
# Then initialize with it
chezmoi init --apply https://github.com/yourusername/dotfiles.git

# Or if you already have a repo
chezmoi init yourusername/dotfiles
```

## 📁 Adding Files to Chezmoi

### Add Configuration Files
```bash
# Add individual files
chezmoi add ~/.config/hypr/hyprland.conf
chezmoi add ~/.config/waybar/config
chezmoi add ~/.config/waybar/style.css
chezmoi add ~/.config/alacritty/alacritty.toml
chezmoi add ~/.config/rofi/catppuccin-mocha.rasi
chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig

# Add entire directories
chezmoi add ~/.config/nvim
chezmoi add ~/.config/dunst
```

### View Managed Files
```bash
# List all managed files
chezmoi managed

# See what would change
chezmoi diff

# Edit a file
chezmoi edit ~/.config/hypr/hyprland.conf
```

## 🔧 Chezmoi Configuration

```bash
# Edit chezmoi config
chezmoi edit-config

# Or manually edit
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[data]
    name = "Your Name"
    email = "your.email@example.com"
    
[edit]
    command = "code"
    args = ["--wait"]
    
[git]
    autoCommit = true
    autoPush = true
    
[merge]
    command = "code"
    args = ["--wait", "--diff"]
EOF
```

## 🔐 Managing Secrets

### Using Bitwarden
```bash
# Install Bitwarden CLI
yay -S bitwarden-cli

# Login to Bitwarden
bw login

# Configure chezmoi to use Bitwarden
cat >> ~/.config/chezmoi/chezmoi.toml << 'EOF'

[data.bitwarden]
    email = "your.email@example.com"
EOF
```

### Template Example with Secrets
```bash
# Create a template file
chezmoi add --template ~/.ssh/config

# Edit the template
chezmoi edit ~/.ssh/config

# Example template content:
cat > ~/.local/share/chezmoi/dot_ssh/config.tmpl << 'EOF'
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    
Host myserver
    HostName {{ (bitwarden "item" "myserver").login.uri }}
    User {{ (bitwarden "item" "myserver").login.username }}
    Port 22
    IdentityFile ~/.ssh/id_ed25519
EOF
```

### Using Pass (Password Store)
```bash
# Install pass
sudo pacman -S pass

# Initialize pass
pass init your-gpg-id

# Use in templates
# {{ (pass "path/to/secret") }}
```

## 📝 Templates

### Machine-Specific Configuration
```bash
# Create a template for machine-specific configs
chezmoi add --template ~/.config/hypr/hyprland.conf

# Edit the template
cat > ~/.local/share/chezmoi/dot_config/hypr/hyprland.conf.tmpl << 'EOF'
# Monitor configuration
{{ if eq .chezmoi.hostname "laptop" }}
monitor=eDP-1,1920x1080@60,0x0,1
{{ else if eq .chezmoi.hostname "desktop" }}
monitor=DP-1,2560x1440@144,0x0,1
{{ else }}
monitor=,preferred,auto,1
{{ end }}

# Rest of configuration...
EOF
```

### OS-Specific Configuration
```bash
# Template for different operating systems
cat > ~/.local/share/chezmoi/dot_zshrc.tmpl << 'EOF'
# Common configuration
export EDITOR=vim
export PATH=$HOME/bin:$PATH

# OS-specific settings
{{ if eq .chezmoi.os "linux" }}
alias ls='eza --icons'
alias update='yay -Syu'
{{ else if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
alias update='brew upgrade'
{{ end }}

# Machine-specific
{{ if eq .chezmoi.hostname "work-laptop" }}
export WORK_ENV=true
source ~/.work-config
{{ end }}
EOF
```

## 🔄 Daily Workflow

### Update Configurations
```bash
# See what changed in your home directory
chezmoi diff

# Add changed files
chezmoi add ~/.config/file-that-changed

# Or re-add to update
chezmoi re-add

# Apply changes from source to home
chezmoi apply

# Update and apply in one command
chezmoi update
```

### Push Changes
```bash
# Go to source directory
chezmoi cd

# Commit and push
git add .
git commit -m "Update configurations"
git push

# Or use automatic git
chezmoi git add .
chezmoi git commit -- -m "Update"
chezmoi git push
```

## 🖥️ Deploy to New Machine

### Quick Setup
```bash
# One-liner to install and apply
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yourusername/dotfiles

# Or if chezmoi is installed
chezmoi init --apply yourusername/dotfiles
```

### Step by Step
```bash
# Install chezmoi
sudo pacman -S chezmoi

# Initialize from GitHub
chezmoi init https://github.com/yourusername/dotfiles.git

# See what would be changed
chezmoi diff

# Apply the changes
chezmoi apply -v
```

## 📂 Repository Structure

```bash
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # Chezmoi config template
├── .chezmoiignore              # Files to ignore
├── .chezmoiscripts/            # Scripts to run
│   ├── run_once_10-install-packages.sh
│   └── run_onchange_20-configure-system.sh
├── dot_config/
│   ├── hypr/
│   │   └── hyprland.conf.tmpl
│   ├── waybar/
│   │   ├── config
│   │   └── style.css
│   ├── alacritty/
│   │   └── alacritty.toml
│   └── rofi/
│       └── catppuccin-mocha.rasi
├── dot_zshrc.tmpl
├── dot_gitconfig.tmpl
└── private_dot_ssh/
    └── config.tmpl
```

## 🛠️ Automation Scripts

### Install Packages Script
```bash
# Create install script
cat > ~/.local/share/chezmoi/.chezmoiscripts/run_once_10-install-packages.sh.tmpl << 'EOF'
#!/bin/bash
set -eu

echo "Installing packages..."

{{ if eq .chezmoi.os "linux" -}}
{{ if eq .chezmoi.osRelease.id "arch" -}}
# Arch Linux packages
packages=(
    hyprland
    waybar
    rofi-wayland
    dunst
    alacritty
    firefox
    code
    git
    chezmoi
    zsh
    starship
)

# Install packages
sudo pacman -S --needed --noconfirm "${packages[@]}"

# Install AUR helper if not present
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-bin
fi

# AUR packages
yay -S --needed --noconfirm \
    catppuccin-gtk-theme-mocha \
    catppuccin-cursors-mocha
{{ end -}}
{{ end -}}

echo "Package installation complete!"
EOF

chmod +x ~/.local/share/chezmoi/.chezmoiscripts/run_once_10-install-packages.sh.tmpl
```

### Configuration Script
```bash
cat > ~/.local/share/chezmoi/.chezmoiscripts/run_onchange_20-configure-system.sh << 'EOF'
#!/bin/bash
set -eu

echo "Configuring system..."

# Set default shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Enable services
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service

echo "System configuration complete!"
EOF
```

## 🔍 Ignore Files

```bash
# Create .chezmoiignore
cat > ~/.local/share/chezmoi/.chezmoiignore << 'EOF'
README.md
LICENSE
.git
.gitignore
*.swp
*~
.DS_Store
Thumbs.db

# Cache directories
.cache/
**/cache/

# Sensitive files that shouldn't be managed
.ssh/id_*
.ssh/known_hosts
.gnupg/
EOF
```

## 🎯 Advanced Features

### Encrypted Files
```bash
# Add an encrypted file
chezmoi add --encrypt ~/.ssh/config

# Files are encrypted with age or gpg
# Configure encryption
chezmoi edit-config
# Add:
# encryption = "age"
# [age]
#   identity = "~/.config/age/key.txt"
#   recipient = "age1..."
```

### External Files
```bash
# Add external files to .chezmoiexternal.toml
cat > ~/.local/share/chezmoi/.chezmoiexternal.toml << 'EOF'
[".config/nvim/autoload/plug.vim"]
    type = "file"
    url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    refreshPeriod = "168h"

[".themes/catppuccin-gtk"]
    type = "archive"
    url = "https://github.com/catppuccin/gtk/releases/latest/download/catppuccin-gtk.tar.gz"
    stripComponents = 1
    refreshPeriod = "672h"
EOF
```

### Data Sources
```bash
# Use external data in templates
cat >> ~/.config/chezmoi/chezmoi.toml << 'EOF'
[data.github]
    user = "yourusername"
    
[data.work]
    email = "you@company.com"
    vpn_server = "vpn.company.com"
EOF

# Use in templates:
# {{ .github.user }}
# {{ .work.email }}
```

## 📱 Multiple Machines

### Machine-Specific Data
```bash
# Create machine-specific config
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[data]
    machine_type = "laptop"  # or "desktop", "work"
    has_nvidia = false
    monitor_count = 1
    
[data.monitors]
    primary = "eDP-1"
    resolution = "1920x1080"
    refresh = "60"
EOF
```

### Conditional Installation
```bash
# In template files
cat > ~/.local/share/chezmoi/dot_config/hypr/hyprland.conf.tmpl << 'EOF'
# Graphics configuration
{{ if .has_nvidia }}
env = WLR_NO_HARDWARE_CURSORS,1
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
{{ end }}

# Monitor setup
{{ if eq .machine_type "laptop" }}
monitor=eDP-1,1920x1080@60,0x0,1
bindl = , switch:Lid Switch, exec, systemctl suspend
{{ else if eq .machine_type "desktop" }}
monitor={{ .monitors.primary }},{{ .monitors.resolution }}@{{ .monitors.refresh }},0x0,1
{{ end }}
EOF
```

## 🚀 Best Practices

### 1. Regular Updates
```bash
# Daily routine
chezmoi diff        # Check changes
chezmoi add -r      # Re-add changed files
chezmoi cd          # Go to repo
git commit -am "Daily update"
git push
```

### 2. Backup Before Major Changes
```bash
# Create backup branch
chezmoi cd
git checkout -b backup-$(date +%Y%m%d)
git checkout main
```

### 3. Test Changes
```bash
# Test in temporary directory
chezmoi apply --dry-run
chezmoi apply --verbose --dry-run
```

### 4. Document Your Setup
```bash
# Create README
cat > ~/.local/share/chezmoi/README.md << 'EOF'
# My Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/)

## Installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yourusername/dotfiles
```

## Contents

- Hyprland configuration
- Waybar setup
- Terminal configs
- Development environment

## Machine-specific settings

Edit `~/.config/chezmoi/chezmoi.toml` after installation.
EOF
```

## 📊 Useful Commands

```bash
# Common chezmoi commands
chezmoi status          # Show status
chezmoi managed         # List managed files
chezmoi unmanaged       # Show unmanaged files
chezmoi doctor          # Check for problems
chezmoi merge           # Merge changes
chezmoi forget          # Stop managing a file
chezmoi chattr +x       # Make executable
chezmoi archive         # Create archive
chezmoi data            # Show template data
```

---

<div align="center">

[← Previous: Theming](07-Theming) • [Next: Performance Tuning →](09-Performance-Tuning)

</div>