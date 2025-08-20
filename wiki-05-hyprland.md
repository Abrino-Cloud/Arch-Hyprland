# 05. Hyprland Setup

> **Installing and configuring Hyprland for maximum performance with zero animations**

## 🎯 Overview

We'll set up:
- Hyprland window manager with zero animations
- Waybar status bar
- Application launcher (Rofi)
- Notification system (Dunst)
- Screenshot tools
- Clipboard management
- Essential utilities

## 📦 Install Display Drivers

### Intel Graphics
```bash
sudo pacman -S mesa vulkan-intel intel-media-driver
```

### AMD Graphics
```bash
sudo pacman -S mesa vulkan-radeon libva-mesa-driver
```

### NVIDIA Graphics
```bash
# For newer cards (GTX 900+)
sudo pacman -S nvidia nvidia-utils nvidia-settings

# For older cards
sudo pacman -S nvidia-470xx-dkms nvidia-470xx-utils
```

### Verify Graphics
```bash
# Check OpenGL
glxinfo | grep "OpenGL renderer"

# Check Vulkan
vulkaninfo | grep deviceName
```

## 🪟 Install Hyprland

### Core Installation
```bash
# Install Hyprland and dependencies
sudo pacman -S hyprland xdg-desktop-portal-hyprland \
  polkit-kde-agent qt5-wayland qt6-wayland \
  qt5ct qt6ct kvantum

# Install essential tools
sudo pacman -S waybar rofi-wayland dunst \
  grim slurp swappy wl-clipboard cliphist \
  brightnessctl pamixer playerctl \
  network-manager-applet blueman pavucontrol

# Install terminal and file manager
sudo pacman -S alacritty thunar thunar-archive-plugin \
  thunar-volman tumbler file-roller gvfs gvfs-mtp

# Install fonts
sudo pacman -S ttf-jetbrains-mono-nerd ttf-font-awesome \
  ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-fira-code ttf-firacode-nerd
```

### Display Manager (SDDM)
```bash
# Install SDDM
sudo pacman -S sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Enable SDDM
sudo systemctl enable sddm
```

## ⚙️ Hyprland Configuration

### Create Zero-Animation Config
```bash
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# ═══════════════════════════════════════════════════════════════
#  HYPRLAND ZERO - MAXIMUM PERFORMANCE CONFIGURATION
# ═══════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────
# MONITOR CONFIGURATION
# ───────────────────────────────────────────────────────────────
monitor=,preferred,auto,1
# monitor=HDMI-A-1,1920x1080@144,0x0,1  # Example for specific setup

# ───────────────────────────────────────────────────────────────
# AUTOSTART APPLICATIONS
# ───────────────────────────────────────────────────────────────
exec-once = waybar
exec-once = dunst
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = hypridle
exec-once = hyprpaper

# Cursor
exec-once = hyprctl setcursor Catppuccin-Mocha-Dark-Cursors 24

# ───────────────────────────────────────────────────────────────
# ENVIRONMENT VARIABLES
# ───────────────────────────────────────────────────────────────
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = MOZ_ENABLE_WAYLAND,1
env = _JAVA_AWT_WM_NONREPARENTING,1

# NVIDIA specific (uncomment if using NVIDIA)
# env = LIBVA_DRIVER_NAME,nvidia
# env = GBM_BACKEND,nvidia-drm
# env = __GLX_VENDOR_LIBRARY_NAME,nvidia
# env = WLR_NO_HARDWARE_CURSORS,1

# ───────────────────────────────────────────────────────────────
# INPUT CONFIGURATION
# ───────────────────────────────────────────────────────────────
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options = caps:escape  # Caps Lock as Escape
    kb_rules =
    
    follow_mouse = 1
    mouse_refocus = false
    
    sensitivity = 0
    accel_profile = flat
    
    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
        drag_lock = true
        clickfinger_behavior = true
    }
}

# ───────────────────────────────────────────────────────────────
# GENERAL SETTINGS - OPTIMIZED FOR SPEED
# ───────────────────────────────────────────────────────────────
general {
    gaps_in = 2
    gaps_out = 4
    border_size = 2
    
    # Catppuccin Mocha colors
    col.active_border = rgba(cba6f7ff) rgba(89b4faff) 45deg
    col.inactive_border = rgba(313244ff)
    
    layout = dwindle
    
    no_cursor_warps = true
    resize_on_border = true
    extend_border_grab_area = 15
    hover_icon_on_border = true
}

# ───────────────────────────────────────────────────────────────
# DECORATION - MINIMAL FOR MAXIMUM PERFORMANCE
# ───────────────────────────────────────────────────────────────
decoration {
    rounding = 0  # No rounding for speed
    
    blur {
        enabled = false  # Disabled for performance
    }
    
    drop_shadow = false  # Disabled for performance
    
    dim_inactive = false
    dim_strength = 0.1
}

# ───────────────────────────────────────────────────────────────
# ANIMATIONS - COMPLETELY DISABLED FOR ZERO LATENCY
# ───────────────────────────────────────────────────────────────
animations {
    enabled = false
    
    # Even with animations disabled, set these to minimum
    bezier = instant, 0, 1, 0, 1
    animation = windows, 0, 1, instant
    animation = windowsOut, 0, 1, instant
    animation = border, 0, 1, instant
    animation = fade, 0, 1, instant
    animation = workspaces, 0, 1, instant
}

# ───────────────────────────────────────────────────────────────
# LAYOUT CONFIGURATION
# ───────────────────────────────────────────────────────────────
dwindle {
    pseudotile = true
    preserve_split = true
    no_gaps_when_only = false
    force_split = 2
    smart_split = false
    smart_resizing = true
}

master {
    new_is_master = false
    new_on_top = false
    no_gaps_when_only = false
    orientation = left
    mfact = 0.55
}

# ───────────────────────────────────────────────────────────────
# MISC SETTINGS
# ───────────────────────────────────────────────────────────────
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
    vfr = true
    vrr = 1
    always_follow_on_dnd = true
    layers_hog_keyboard_focus = true
    animate_manual_resizes = false
    animate_mouse_windowdragging = false
    focus_on_activate = true
    no_direct_scanout = false
}

# ───────────────────────────────────────────────────────────────
# WINDOW RULES
# ───────────────────────────────────────────────────────────────
# Float specific windows
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, class:^(Rofi)$
windowrulev2 = float, title:^(Media viewer)$
windowrulev2 = float, title:^(Picture-in-Picture)$

# Size rules
windowrulev2 = size 800 600, class:^(pavucontrol)$
windowrulev2 = size 800 600, class:^(blueman-manager)$

# Gaming rules (immediate mode for lowest latency)
windowrulev2 = immediate, class:^(cs2)$
windowrulev2 = immediate, class:^(steam_app)$
windowrulev2 = immediate, class:^(hl2_linux)$
windowrulev2 = fullscreen, class:^(cs2)$

# ───────────────────────────────────────────────────────────────
# KEYBINDINGS
# ───────────────────────────────────────────────────────────────
$mainMod = SUPER

# Core applications
bind = $mainMod, Return, exec, alacritty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, W, exec, firefox
bind = $mainMod, C, exec, code
bind = $mainMod, V, togglefloating,
bind = $mainMod, F, fullscreen, 0
bind = $mainMod, M, fullscreen, 1  # Maximize
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Application launcher
bind = $mainMod, Space, exec, rofi -show drun -theme ~/.config/rofi/catppuccin-mocha.rasi
bind = $mainMod SHIFT, Space, exec, rofi -show run -theme ~/.config/rofi/catppuccin-mocha.rasi
bind = $mainMod, Tab, exec, rofi -show window -theme ~/.config/rofi/catppuccin-mocha.rasi

# Clipboard
bind = $mainMod SHIFT, V, exec, cliphist list | rofi -dmenu -theme ~/.config/rofi/catppuccin-mocha.rasi | cliphist decode | wl-copy

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
bind = SHIFT, Print, exec, grim - | swappy -f -
bind = $mainMod, Print, exec, grim -g "$(slurp)" - | wl-copy
bind = $mainMod SHIFT, Print, exec, grim - | wl-copy

# Audio control
binde = , XF86AudioRaiseVolume, exec, pamixer -i 5
binde = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86AudioMicMute, exec, pamixer --default-source -t

# Media control
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
bind = , XF86AudioStop, exec, playerctl stop

# Brightness control
binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move focus with mainMod + hjkl
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Move windows
bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d
bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, L, movewindow, r
bind = $mainMod SHIFT, K, movewindow, u
bind = $mainMod SHIFT, J, movewindow, d

# Resize windows
binde = $mainMod CTRL, left, resizeactive, -20 0
binde = $mainMod CTRL, right, resizeactive, 20 0
binde = $mainMod CTRL, up, resizeactive, 0 -20
binde = $mainMod CTRL, down, resizeactive, 0 20
binde = $mainMod CTRL, H, resizeactive, -20 0
binde = $mainMod CTRL, L, resizeactive, 20 0
binde = $mainMod CTRL, K, resizeactive, 0 -20
binde = $mainMod CTRL, J, resizeactive, 0 20

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize with mouse
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Lock screen
bind = $mainMod, L, exec, hyprlock

# Power menu
bind = $mainMod, X, exec, ~/.config/rofi/powermenu.sh
EOF
```

## 🎨 Wallpaper Setup

```bash
# Create hyprpaper config
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprpaper.conf << 'EOF'
preload = ~/.config/wallpapers/catppuccin-mocha.png
wallpaper = ,~/.config/wallpapers/catppuccin-mocha.png
EOF

# Create wallpaper directory
mkdir -p ~/.config/wallpapers

# Download Catppuccin wallpaper
wget -O ~/.config/wallpapers/catppuccin-mocha.png \
  https://raw.githubusercontent.com/catppuccin/wallpapers/main/os/arch-black-4k.png
```

## 🔒 Screen Lock Setup

```bash
# Install swaylock-effects
yay -S swaylock-effects-git

# Create hyprlock config
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprlock.conf << 'EOF'
background {
    monitor =
    path = ~/.config/wallpapers/catppuccin-mocha.png
    blur_size = 5
    blur_passes = 2
}

input-field {
    monitor =
    size = 200, 50
    outline_thickness = 2
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    outer_color = rgb(b4befe)
    inner_color = rgb(1e1e2e)
    font_color = rgb(cdd6f4)
    fade_on_empty = true
    placeholder_text = <i>Enter Password...</i>
    hide_input = false
    position = 0, -20
    halign = center
    valign = center
}

label {
    monitor =
    text = $TIME
    color = rgb(cdd6f4)
    font_size = 55
    font_family = JetBrains Mono Nerd Font
    position = 0, 80
    halign = center
    valign = center
}
EOF
```

## 🔧 Idle Management

```bash
# Create hypridle config
cat > ~/.config/hypr/hypridle.conf << 'EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300  # 5 minutes
    on-timeout = brightnessctl -s set 10%
    on-resume = brightnessctl -r
}

listener {
    timeout = 600  # 10 minutes
    on-timeout = loginctl lock-session
}

listener {
    timeout = 1800  # 30 minutes
    on-timeout = systemctl suspend
}
EOF
```

## 🚀 Performance Verification

```bash
# Check Hyprland is running
hyprctl version

# Monitor performance
hyprctl dispatch exec htop

# Check compositor FPS
WAYLAND_DEBUG=1 alacritty 2>&1 | grep -i fps

# GPU usage
nvidia-smi  # For NVIDIA
radeontop   # For AMD
intel_gpu_top  # For Intel
```

---

<div align="center">

[← Previous: System Configuration](04-System-Configuration) • [Next: Essential Software →](06-Essential-Software)

</div>