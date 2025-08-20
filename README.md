# 🛡️ Arch Hyprland Bare

**Zero-animation Hyprland perfection for Iranian developers**

Inspired by Omarchy but optimized for Persian users with anti-sanctions DNS, Catppuccin theming, and blazing-fast performance.

## ⚡ Quick Install

```bash
# Boot from Arch ISO, connect to internet, then:
curl -L https://sh.abrino.cloud/arch-1 | bash

# Or use the full URL:
curl -L https://raw.githubusercontent.com/Abrino-Cloud/Arch-Hyprland/main/arch-hyprland-bare.sh | bash
```

## 🎯 What You Get

- **🎨 Catppuccin Mocha** - Beautiful dark theme everywhere
- **⚡ Zero Animations** - Maximum performance, instant response
- **🇮🇷 Persian Support** - Full RTL, Farsi fonts, keyboard switching
- **🖥️ Ly Display Manager** - Minimal TUI login (no bloated GDM/SDDM)
- **📱 Ghostty Terminal** - Modern GPU-accelerated terminal
- **🔧 tmux Workflow** - Terminal multiplexer (no neovim)
- **🛡️ Iranian Optimized** - Anti-sanctions DNS, fast mirrors
- **🤖 Smart Detection** - Auto-configures for your hardware

## 🎛️ Bare Philosophy

Following Omarchy's "bare mode" - only essential tools:
- **Chromium** browser
- **Ghostty** terminal  
- **Essential TUI tools** (lazygit, btop, fzf, etc.)
- **tmux** for terminal multiplexing
- **copyq** clipboard manager

**Additional apps installed separately** (VSCode, Obsidian, Spotify, etc.)

## 🚀 Post-Install

```bash
# Install your preferred applications
yay -S visual-studio-code-bin obsidian spotify
pacman -S firefox mpv obs-studio telegram-desktop

# Setup dotfiles (if not done during install)
chezmoi init --apply git@github.com:YOUR-USERNAME/dotfiles.git
```

## 🎹 Key Bindings

- `Super + Return` → Ghostty terminal
- `Super + Space` → App launcher  
- `Super + W` → Chromium browser
- `Super + I` → Toggle Persian/English keyboard
- `Alt + Shift` → Quick keyboard toggle

## 📚 Documentation

- [**Detailed Installation Guide**](DETAILED-README.md)
- [**DevOps Tools Setup**](docs/DEVOPS-TOOLS.md)
- [**Omarchy Manual**](https://manuals.omamix.org/2/the-omarchy-manual) (inspiration)

## 🇮🇷 Persian Community

- **Telegram**: [@archlinux_ir](https://t.me/archlinux_ir)
- **DNS**: 10.70.95.150, 10.70.95.162 (Anti-sanctions)
- **Mirrors**: IUT Tehran, Yazd University optimized

---

*Created by [Abrino Cloud](https://abrino.cloud) • Inspired by Omarchy*