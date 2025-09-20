#!/bin/bash

# Update Package Lists Script
# This script updates the package lists in the system-config directory
# Called automatically by pacman hooks after package install/remove operations
# Following Arch Linux best practices

SYSTEM_CONFIG_DIR="/home/anthon/.config/system-config"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure directory exists
mkdir -p "$SYSTEM_CONFIG_DIR"

# Update package lists using Arch Wiki recommended format
echo "# Package list updated: $DATE" > "$SYSTEM_CONFIG_DIR/installed-packages.txt"
echo "# All explicitly installed packages (for complete restore)" >> "$SYSTEM_CONFIG_DIR/installed-packages.txt"
pacman -Qqe >> "$SYSTEM_CONFIG_DIR/installed-packages.txt"

echo "# Native packages updated: $DATE" > "$SYSTEM_CONFIG_DIR/packages-native.txt"  
echo "# Packages from official repositories" >> "$SYSTEM_CONFIG_DIR/packages-native.txt"
pacman -Qqen >> "$SYSTEM_CONFIG_DIR/packages-native.txt"

echo "# Foreign packages updated: $DATE" > "$SYSTEM_CONFIG_DIR/packages-foreign.txt"
echo "# Packages from AUR or other sources" >> "$SYSTEM_CONFIG_DIR/packages-foreign.txt"
pacman -Qqem >> "$SYSTEM_CONFIG_DIR/packages-foreign.txt"

# Log the update
echo "[$DATE] Package lists updated - Total: $(pacman -Qq | wc -l) installed, $(pacman -Qqe | wc -l) explicit" >> "$SYSTEM_CONFIG_DIR/package-updates.log"