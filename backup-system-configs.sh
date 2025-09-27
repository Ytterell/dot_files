#!/bin/bash

# System Configuration Backup Script
# Backs up important system configurations to system-config directory

# Show help if requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat << EOF
📁 System Configuration Backup Script

Backs up critical system configurations to ~/.config/system-config/

🚀 USAGE:
    $0                    # Run complete backup
    $0 --help             # Show this help

📂 BACKED UP CONFIGURATIONS:
    • Wayland/Hyprland: Window manager, compositor settings
    • Theme System: GTK, Qt, Rofi, Matugen configurations  
    • Applications: Warp Terminal, Obsidian settings
    • Shell Environment: Bash profile, aliases, Git config
    • System Maintenance: Automated maintenance scripts

📄 OUTPUT:
    • Files: ~/.config/system-config/
    • Summary: ~/.config/system-config/backup-summary.txt
    • Notifications: Desktop notifications on completion

EOF
    exit 0
fi

SYSTEM_CONFIG_DIR="/home/anthon/.config/system-config"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to send notifications
send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        notify-send \
            --app-name="System Config Backup" \
            --icon="$icon" \
            "$title" \
            "$message"
    fi
}

# Error handling function
handle_error() {
    echo "❌ Backup failed: $1"
    send_notification "❌ Config Backup Failed" "Error: $1" "dialog-error"
    exit 1
}

echo "🔄 Backing up system configurations..."

# === WAYLAND COMPOSITOR (Hyprland) ===
echo "📱 Backing up Wayland/Hyprland configs..."
mkdir -p "$SYSTEM_CONFIG_DIR/wayland-compositor"

# Main Hyprland configurations
cp ~/.config/hypr/hyprland.conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null
cp ~/.config/hypr/colors.conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null
cp ~/.config/hypr/hypridle.conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null  
cp ~/.config/hypr/hyprlock.conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null
cp ~/.config/hypr/hyprpaper.conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null

# Copy important conf subdirectory files
cp -r ~/.config/hypr/conf "$SYSTEM_CONFIG_DIR/wayland-compositor/" 2>/dev/null

# Waybar configuration
cp ~/.config/waybar/modules.json "$SYSTEM_CONFIG_DIR/wayland-compositor/waybar-modules.json" 2>/dev/null
cp ~/.config/waybar/launch.sh "$SYSTEM_CONFIG_DIR/wayland-compositor/waybar-launch.sh" 2>/dev/null

# === THEME SYSTEM ===  
echo "🎨 Backing up theme system configs..."
mkdir -p "$SYSTEM_CONFIG_DIR/theme-system"

# Matugen (theme generator)
cp ~/.config/matugen/config.toml "$SYSTEM_CONFIG_DIR/theme-system/matugen-config.toml" 2>/dev/null
cp -r ~/.config/matugen/templates "$SYSTEM_CONFIG_DIR/theme-system/" 2>/dev/null

# GTK theme settings
cp ~/.config/gtk-3.0/settings.ini "$SYSTEM_CONFIG_DIR/theme-system/gtk3-settings.ini" 2>/dev/null
cp ~/.config/gtk-3.0/gtk.css "$SYSTEM_CONFIG_DIR/theme-system/gtk3-custom.css" 2>/dev/null
cp ~/.config/gtk-4.0/settings.ini "$SYSTEM_CONFIG_DIR/theme-system/gtk4-settings.ini" 2>/dev/null
cp ~/.config/gtk-4.0/gtk.css "$SYSTEM_CONFIG_DIR/theme-system/gtk4-custom.css" 2>/dev/null

# Qt theme settings
cp ~/.config/qt6ct/qt6ct.conf "$SYSTEM_CONFIG_DIR/theme-system/" 2>/dev/null

# Rofi (launcher) configurations
cp ~/.config/rofi/config.rasi "$SYSTEM_CONFIG_DIR/theme-system/rofi-config.rasi" 2>/dev/null
cp -r ~/.config/rofi/config-*.rasi "$SYSTEM_CONFIG_DIR/theme-system/" 2>/dev/null

# Generated theme colors (auto-updated by matugen)
cp ~/.config/waybar/colors.css "$SYSTEM_CONFIG_DIR/theme-system/waybar-colors.css" 2>/dev/null
cp ~/.config/gtk-3.0/colors.css "$SYSTEM_CONFIG_DIR/theme-system/gtk3-colors.css" 2>/dev/null
cp ~/.config/rofi/colors.rasi "$SYSTEM_CONFIG_DIR/theme-system/rofi-colors.rasi" 2>/dev/null

# === APPLICATIONS ===
echo "🚀 Backing up application configs..."
mkdir -p "$SYSTEM_CONFIG_DIR/applications"

# Warp Terminal
cp ~/.config/warp-terminal/user_preferences.json "$SYSTEM_CONFIG_DIR/applications/warp-preferences.json" 2>/dev/null

# Obsidian settings
cp ~/.config/obsidian/obsidian.json "$SYSTEM_CONFIG_DIR/applications/obsidian-settings.json" 2>/dev/null

# === SHELL ENVIRONMENT ===
echo "🐚 Backing up shell environment..."
mkdir -p "$SYSTEM_CONFIG_DIR/shell-environment"

# Profile files
cp ~/.bash_profile "$SYSTEM_CONFIG_DIR/shell-environment/" 2>/dev/null

# Shell aliases and configurations
cp ~/.config/bashrc/10-aliases "$SYSTEM_CONFIG_DIR/shell-environment/aliases.sh" 2>/dev/null
cp ~/.bashrc "$SYSTEM_CONFIG_DIR/shell-environment/.bashrc" 2>/dev/null

# Environment variables from various sources
env | grep -E "(WAYLAND|XDG|QT|GTK|GDK)" > "$SYSTEM_CONFIG_DIR/shell-environment/environment-variables.txt" 2>/dev/null

# === GIT CONFIGURATION ===
echo "🔧 Backing up Git configuration..."
mkdir -p "$SYSTEM_CONFIG_DIR/shell-environment"

# Git global configuration (excluding sensitive credentials)
cp ~/.gitconfig "$SYSTEM_CONFIG_DIR/shell-environment/.gitconfig" 2>/dev/null || true
# Note: .git-credentials is intentionally excluded for security

# === SYSTEM MAINTENANCE ===
echo "🔧 Backing up system maintenance..."
mkdir -p "$SYSTEM_CONFIG_DIR/maintenance"

# Maintenance system (configs only - scripts are already in place)
# Note: maintenance.sh and README.md are already in the system-config directory
cp ~/.config/systemd/user/arch-maintenance.service "$SYSTEM_CONFIG_DIR/maintenance/" 2>/dev/null || true
cp ~/.config/systemd/user/arch-maintenance.timer "$SYSTEM_CONFIG_DIR/maintenance/" 2>/dev/null || true

# Create a summary
cat > "$SYSTEM_CONFIG_DIR/backup-summary.txt" << EOF
# System Configuration Backup Summary
# Generated: $DATE

=== WAYLAND COMPOSITOR ===
- Hyprland main configuration
- Lock screen, idle, wallpaper configs  
- Waybar status bar configuration

=== THEME SYSTEM ===
- Matugen theme generator settings
- GTK 3.0/4.0 theme configurations
- Qt6 theme settings
- Rofi launcher themes
- Auto-generated color files

=== APPLICATIONS ===
- Warp Terminal preferences
- Obsidian settings

=== SHELL ENVIRONMENT ===
- Profile configurations
- Shell aliases and functions
- Environment variables

=== GIT CONFIGURATION ===
- Git global settings
- User configuration (name, email)
- Core Git preferences

=== SYSTEM MAINTENANCE ===
- Automated maintenance scripts and configuration
- Systemd service and timer definitions
- Monthly maintenance scheduling

Total config files backed up: $(find "$SYSTEM_CONFIG_DIR" -type f -name "*.conf" -o -name "*.ini" -o -name "*.json" -o -name "*.toml" -o -name "*.css" -o -name "*.rasi" -o -name "*.service" -o -name "*.timer" | wc -l)
EOF

echo "✅ System configuration backup complete!"
echo "📁 Files saved to: $SYSTEM_CONFIG_DIR"
echo "📊 Summary: $SYSTEM_CONFIG_DIR/backup-summary.txt"

# Send success notification
FILE_COUNT=$(find "$SYSTEM_CONFIG_DIR" -type f -name "*.conf" -o -name "*.ini" -o -name "*.json" -o -name "*.toml" -o -name "*.css" -o -name "*.rasi" -o -name "*.service" -o -name "*.timer" | wc -l)
send_notification "📂 Config Backup Complete" "Backed up $FILE_COUNT configuration files\nSaved to: ~/.config/system-config" "folder-download"

echo
echo "   Before pushing to GitHub, ensure .gitignore excludes sensitive files:"
echo "   - applications/warp-preferences.json (contains API keys)"
echo "   - shell-environment/environment-variables.txt (session data)"
echo "   - *.log files (may contain personal info)"
echo "   📋 Use template files instead for public repos"
