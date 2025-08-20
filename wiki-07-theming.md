# 07. Theming

> **Complete Catppuccin Mocha and Dracula theme setup for every application**

## 🎨 Overview

We'll configure:
- System-wide Catppuccin Mocha theme
- Alternative Dracula theme
- Consistent theming across all applications
- Icon packs
- Cursor themes
- Font configuration

## 🎭 Catppuccin Mocha Color Palette

```yaml
Base Colors:
  rosewater: "#f5e0dc"
  flamingo: "#f2cdcd"
  pink: "#f5c2e7"
  mauve: "#cba6f7"
  red: "#f38ba8"
  maroon: "#eba0ac"
  peach: "#fab387"
  yellow: "#f9e2af"
  green: "#a6e3a1"
  teal: "#94e2d5"
  sky: "#89dceb"
  sapphire: "#74c7ec"
  blue: "#89b4fa"
  lavender: "#b4befe"
  
Surface Colors:
  text: "#cdd6f4"
  subtext1: "#bac2de"
  subtext0: "#a6adc8"
  overlay2: "#9399b2"
  overlay1: "#7f849c"
  overlay0: "#6c7086"
  surface2: "#585b70"
  surface1: "#45475a"
  surface0: "#313244"
  base: "#1e1e2e"
  mantle: "#181825"
  crust: "#11111b"
```

## 🖼️ GTK Theme

### Install Catppuccin GTK
```bash
# Install dependencies
sudo pacman -S gtk-engine-murrine sassc

# Clone and install theme
git clone https://github.com/catppuccin/gtk.git
cd gtk
sudo cp -r src/catppuccin-mocha-* /usr/share/themes/
cd ..
rm -rf gtk

# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-mauve-standard+default"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
```

### GTK Configuration Files
```bash
# GTK 3
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=catppuccin-mocha-mauve-standard+default
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrains Mono 10
gtk-cursor-theme-name=Catppuccin-Mocha-Dark-Cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

# GTK 4
mkdir -p ~/.config/gtk-4.0
ln -sf /usr/share/themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/* ~/.config/gtk-4.0/
```

## 🎯 Icons and Cursors

### Icon Theme
```bash
# Install Papirus icons
sudo pacman -S papirus-icon-theme

# Install Catppuccin folders
git clone https://github.com/catppuccin/papirus-folders.git
cd papirus-folders
sudo cp -r src/* /usr/share/icons/Papirus
./papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
cd ..
rm -rf papirus-folders
```

### Cursor Theme
```bash
# Install Catppuccin cursors
yay -S catppuccin-cursors-mocha

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Mocha-Dark-Cursors'

# For Hyprland
hyprctl setcursor Catppuccin-Mocha-Dark-Cursors 24
```

## 🎨 Waybar Theme

```bash
# Create Waybar style
cat > ~/.config/waybar/style.css << 'EOF'
/* Catppuccin Mocha Theme */
@define-color base   #1e1e2e;
@define-color mantle #181825;
@define-color crust  #11111b;

@define-color text     #cdd6f4;
@define-color subtext0 #a6adc8;
@define-color subtext1 #bac2de;

@define-color surface0 #313244;
@define-color surface1 #45475a;
@define-color surface2 #585b70;

@define-color overlay0 #6c7086;
@define-color overlay1 #7f849c;
@define-color overlay2 #9399b2;

@define-color blue      #89b4fa;
@define-color lavender  #b4befe;
@define-color sapphire  #74c7ec;
@define-color sky       #89dceb;
@define-color teal      #94e2d5;
@define-color green     #a6e3a1;
@define-color yellow    #f9e2af;
@define-color peach     #fab387;
@define-color maroon    #eba0ac;
@define-color red       #f38ba8;
@define-color mauve     #cba6f7;
@define-color pink      #f5c2e7;
@define-color flamingo  #f2cdcd;
@define-color rosewater #f5e0dc;

* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: transparent;
}

.modules-left,
.modules-center,
.modules-right {
    background: @base;
    border: 2px solid @surface0;
    border-radius: 10px;
    margin: 4px;
    padding: 0px;
}

#workspaces button {
    color: @overlay0;
    padding: 0 8px;
    border-radius: 8px;
    margin: 4px;
}

#workspaces button.active {
    background: @surface1;
    color: @mauve;
}

#workspaces button:hover {
    background: @surface1;
    color: @text;
    border-bottom: 2px solid @mauve;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#tray {
    padding: 0 10px;
    color: @text;
}

#battery.charging {
    color: @green;
}

#battery.warning:not(.charging) {
    color: @yellow;
}

#battery.critical:not(.charging) {
    color: @red;
    animation: blink 0.5s linear infinite alternate;
}

@keyframes blink {
    to {
        background-color: @red;
        color: @base;
    }
}

#network.disconnected {
    color: @red;
}

#pulseaudio.muted {
    color: @overlay0;
}

tooltip {
    background: @base;
    border: 2px solid @surface0;
}

tooltip label {
    color: @text;
}
EOF
```

## 🚀 Rofi Theme

```bash
# Create Rofi theme
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/catppuccin-mocha.rasi << 'EOF'
* {
    bg-col:  #1e1e2e;
    bg-col-light: #313244;
    border-col: #313244;
    selected-col: #45475a;
    blue: #89b4fa;
    fg-col: #cdd6f4;
    fg-col2: #f38ba8;
    grey: #6c7086;
    width: 600;
}

element-text, element-icon, mode-switcher {
    background-color: inherit;
    text-color: inherit;
}

window {
    height: 360px;
    border: 3px;
    border-color: @border-col;
    background-color: @bg-col;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col;
    border-radius: 5px;
    padding: 2px;
}

prompt {
    background-color: @blue;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 3px;
    margin: 20px 0px 0px 20px;
}

textbox-prompt-colon {
    expand: false;
    str: ":";
}

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px 0px 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 2;
    background-color: @bg-col;
}

element {
    padding: 5px;
    background-color: @bg-col;
    text-color: @fg-col;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @fg-col2;
}
EOF

# Create power menu
cat > ~/.config/rofi/powermenu.sh << 'EOF'
#!/bin/bash

chosen=$(echo -e "  Lock\n  Logout\n  Reboot\n  Shutdown\n  Suspend" | rofi -dmenu -theme ~/.config/rofi/catppuccin-mocha.rasi)

case "$chosen" in
    "  Lock") hyprlock ;;
    "  Logout") hyprctl dispatch exit ;;
    "  Reboot") systemctl reboot ;;
    "  Shutdown") systemctl poweroff ;;
    "  Suspend") systemctl suspend ;;
esac
EOF
chmod +x ~/.config/rofi/powermenu.sh
```

## 💻 Alacritty Theme

```bash
cat > ~/.config/alacritty/alacritty.toml << 'EOF'
[window]
padding = { x = 10, y = 10 }
decorations = "full"
opacity = 0.95
startup_mode = "Windowed"
dynamic_title = true

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }
size = 11

[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
dim_foreground = "#7f849c"
bright_foreground = "#cdd6f4"

[colors.cursor]
text = "#1e1e2e"
cursor = "#f5e0dc"

[colors.vi_mode_cursor]
text = "#1e1e2e"
cursor = "#b4befe"

[colors.search.matches]
foreground = "#1e1e2e"
background = "#a6adc8"

[colors.search.focused_match]
foreground = "#1e1e2e"
background = "#a6e3a1"

[colors.footer_bar]
foreground = "#1e1e2e"
background = "#a6adc8"

[colors.hints.start]
foreground = "#1e1e2e"
background = "#f9e2af"

[colors.hints.end]
foreground = "#1e1e2e"
background = "#a6adc8"

[colors.selection]
text = "#1e1e2e"
background = "#f5e0dc"

[colors.normal]
black = "#45475a"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#bac2de"

[colors.bright]
black = "#585b70"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#a6adc8"

[colors.dim]
black = "#45475a"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#bac2de"
EOF
```

## 🔍 Dunst Notifications

```bash
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    scale = 0
    notification_limit = 0
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 3
    frame_color = "#89b4fa"
    separator_color = frame
    sort = yes
    font = JetBrains Mono 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 0
    max_icon_size = 32
    icon_path = /usr/share/icons/Papirus-Dark/16x16/status/:/usr/share/icons/Papirus-Dark/16x16/devices/
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/rofi -dmenu -p dunst -theme ~/.config/rofi/catppuccin-mocha.rasi
    browser = /usr/bin/firefox
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 10
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#313244"
    timeout = 10

[urgency_normal]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#89b4fa"
    timeout = 10

[urgency_critical]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#f38ba8"
    timeout = 0
EOF
```

## 🎨 VS Code Theme

```bash
# VS Code settings
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'EOF'
{
    "workbench.colorTheme": "Catppuccin Mocha",
    "workbench.iconTheme": "catppuccin-mocha",
    "editor.fontFamily": "'JetBrainsMono Nerd Font', 'monospace'",
    "editor.fontSize": 13,
    "editor.fontLigatures": true,
    "editor.cursorBlinking": "smooth",
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.smoothScrolling": true,
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": true,
    "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
    "terminal.integrated.fontSize": 13,
    "window.titleBarStyle": "custom",
    "window.menuBarVisibility": "compact"
}
EOF
```

## 🌙 Firefox Theme

```bash
# Install Catppuccin for Firefox
# 1. Open Firefox
# 2. Go to: https://github.com/catppuccin/firefox
# 3. Follow installation instructions

# Or use Firefox Color:
# https://color.firefox.com/?theme=XQAAAALWAQAAAAAAAABBKYhm849SCicxcUfbB38oKRicm6da8pFtMcajvXaAE3RJ0F_F447xQs-L1kFlGgDKq4IIvWciiy4upusW7OvXIRinrLrwLvjXB37kvhN5ElayHo02fx3o8RrDShIhRpNiQMOdww5V2sCMLAfehhp1Dku7r6Jc9fE6BQlE5x-GoqHkOlRW0dBB0b7LL-ovLaXtY3kfDhu_yJYPrSKDo9kW5bIXg7HbNvWC4hkEHoNfAAs6l5Jvd4nRuBLbsmNULOgGW6L2kUnSekobSJIkFnOtF_-qAWfA
```

## 🔄 Qt Theme

```bash
# Install Qt5ct/Qt6ct
sudo pacman -S qt5ct qt6ct kvantum

# Configure Qt5
cat > ~/.config/qt5ct/qt5ct.conf << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/Catppuccin-Mocha.conf
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=gtk3
style=kvantum-dark

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x16\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0 \0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x16\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0 \0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF
```

## 🎭 Alternative: Dracula Theme

```bash
# Quick Dracula theme installer
cat > ~/install-dracula.sh << 'EOF'
#!/bin/bash

# GTK Theme
git clone https://github.com/dracula/gtk.git
sudo mv gtk /usr/share/themes/Dracula

# Icons
wget -qO- https://github.com/dracula/gtk/files/5214870/Dracula.zip | sudo unzip -d /usr/share/icons/

# Alacritty
mkdir -p ~/.config/alacritty
curl -o ~/.config/alacritty/dracula.toml https://raw.githubusercontent.com/dracula/alacritty/master/dracula.toml

echo "Dracula theme installed!"
echo "Switch themes in Settings/Tweaks"
EOF
chmod +x ~/install-dracula.sh
```

## 🖼️ SDDM Theme

```bash
# Install Catppuccin SDDM theme
yay -S sddm-catppuccin-git

# Configure SDDM
sudo mkdir -p /etc/sddm.conf.d
sudo cat > /etc/sddm.conf.d/theme.conf << 'EOF'
[Theme]
Current=catppuccin-mocha
EOF
```

## 🎨 Neofetch Theme

```bash
# Configure neofetch
mkdir -p ~/.config/neofetch
cat > ~/.config/neofetch/config.conf << 'EOF'
print_info() {
    prin "╭──────────────────────────────────────╮"
    info title
    prin "╰──────────────────────────────────────╯"
    
    info "󰌢 OS" distro
    info "󰏖 Kernel" kernel
    info "󰅐 Uptime" uptime
    info "󰏗 Packages" packages
    info " Shell" shell
    info "󰈈 DE/WM" wm
    info "󰋩 Theme" theme
    info "󰂯 Icons" icons
    info " Terminal" term
    info "󰍛 CPU" cpu
    info "󰘚 GPU" gpu
    info "󰑭 Memory" memory
    info "󰋊 Disk" disk
    info "󰈀 Resolution" resolution
}

# Colors
colors=(4 6 1 8 8 6)

# Text Options
bold="on"
underline_enabled="on"
underline_char="-"
separator=" "

# Color Blocks
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
EOF
```

---

<div align="center">

[← Previous: Essential Software](06-Essential-Software) • [Next: Dotfiles Management →](08-Dotfiles-Management)

</div>