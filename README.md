# System Configuration & Documentation

Comprehensive system configuration, package management, themes, and documentation for your ML4W Hyprland setup on Arch Linux.

**📁 Directory Structure**: All configuration files and documentation are organized in `~/.config/system-config/` following XDG Base Directory specifications.

## 📋 Table of Contents

- [📦 Package Management](#-package-management)
- [🔧 System Maintenance](#-system-maintenance)
- [🎨 Application Themes](#-application-themes)  
- [🔧 System Integration](#-system-integration)
- [📚 Installation & Restore](#-installation--restore)
- [📁 Files Reference](#-files-reference)

## 📦 Package Management

### Automatic Package Tracking

Your system automatically tracks all package installations and removals using pacman hooks following Arch Linux best practices.

#### Package Lists Maintained:
- **`installed-packages.txt`** - All explicitly installed packages (for complete system restore)
- **`packages-native.txt`** - Packages from official Arch repositories  
- **`packages-foreign.txt`** - AUR and other foreign packages
- **`package-updates.log`** - Timestamped history of package list updates

#### How It Works:
1. **Pacman Hook**: `/etc/pacman.d/hooks/update-package-lists.hook`
2. **Update Script**: `~/.config/system-config/update-package-lists.sh`
3. **Triggers**: Automatically runs after any `pacman -S` or `pacman -R` operation
4. **Format**: Uses Arch Wiki recommended `pacman -Qqe` format for easy restoration

#### Manual Updates:
If needed, you can manually update the lists:
```bash
~/.config/system-config/update-package-lists.sh
```

#### Package Restoration:
```bash
# Restore all explicitly installed packages
sudo pacman -S --needed - < ~/.config/system-config/installed-packages.txt

# Restore only official repository packages
sudo pacman -S --needed - < ~/.config/system-config/packages-native.txt

# View foreign/AUR packages to install manually
cat ~/.config/system-config/packages-foreign.txt
```

## 🔧 System Maintenance

### Automated Monthly Maintenance

Your system includes automated monthly maintenance that keeps Arch Linux healthy and up-to-date:

- **System Updates**: Full system updates including AUR packages via `yay`
- **Mirror Optimization**: Updates pacman mirrors using `reflector` for fastest downloads  
- **Package Cache Management**: Cleans old packages while keeping recent versions
- **Orphan Package Removal**: Removes unused packages with Flatpak dependency protection
- **SSD Optimization**: Performs SSD TRIM for better performance
- **Journal Management**: Cleans systemd logs to manage disk usage
- **System Health Checks**: Monitors for failed services and disk usage
- **Comprehensive Logging**: All operations logged with desktop notifications

#### Maintenance Schedule

**Automated**: Runs on the **1st of every month at 2:00 AM** (with up to 2 hours random delay)

```bash
# Check maintenance schedule
systemctl --user list-timers | grep maintenance

# Run maintenance manually (interactive)
~/.config/system-config/maintenance/maintenance.sh

# Run maintenance automatically (no prompts)
~/.config/system-config/maintenance/maintenance.sh --auto

# Preview what would be done
~/.config/system-config/maintenance/maintenance.sh --dry-run
```

#### Configuration

Customize maintenance behavior by editing `~/.config/system-config/maintenance/maintenance.conf`:
- Package cache retention (default: 3 versions)
- Journal log retention (default: 14 days)
- Country for mirror selection (auto-detected)
- Enable/disable specific maintenance tasks

#### Logs & Monitoring

- **Detailed logs**: `~/.config/system-config/logs/maintenance-*.log`
- **Integrated summaries**: Added to `backup-summary.txt`
- **Desktop notifications**: Success/failure notifications
- **Automatic cleanup**: Logs older than 12 months are removed

### System Configuration Backup

Comprehensive backup of critical system configurations organized by category:

#### Auto-Backup Script:
```bash
# Run complete system configuration backup
~/.config/system-config/backup-system-configs.sh
```

#### Backed Up Configurations:

**🖥️ Wayland Compositor (`wayland-compositor/`)**
- **Hyprland**: Main config, colors, window rules, keybindings
- **Hypridle/Hyprlock**: Screen lock and idle management
- **Hyprpaper**: Wallpaper configuration  
- **Waybar**: Status bar modules and launch scripts
- **Complete conf/ directory**: All Hyprland variations and profiles

**🎨 Theme System (`theme-system/`)**
- **Matugen**: Theme generator configuration and templates
- **GTK 3.0/4.0**: Settings, custom CSS, generated colors
- **Qt6**: Theme settings via qt6ct
- **Rofi**: Launcher configurations and color schemes
- **Generated Colors**: Auto-updated theme files

**🚀 Applications (`applications/`)**
- **Warp Terminal**: Complete preferences and settings
- **Obsidian**: Vault and application settings

**🐚 Shell Environment (`shell-environment/`)**
- **Profile Files**: .bash_profile and environment setup
- **Environment Variables**: Wayland, XDG, Qt, GTK variables
- **Git Configuration**: Global git settings and user config

**🔧 System Maintenance (`maintenance/`)**
- **Maintenance Scripts**: Automated system maintenance
- **Configuration**: Customizable maintenance settings
- **Documentation**: Complete maintenance system documentation

#### Backup Statistics:
- **Total Files**: 127+ configuration files
- **Categories**: 5 major system areas
- **Coverage**: Complete ML4W Hyprland environment + automated maintenance

## 🎨 Application Themes

### ML4W Material 3 Color Scheme

Your setup uses a sophisticated Material Design 3 color scheme generated by **Matugen**:

- **Primary**: `#86d6be` (Teal)
- **Background**: `#0f1513` (Dark Green)
- **Surface**: `#1b211f` (Container backgrounds)
- **Text**: `#dee4e0` (Light gray-green)
- **Accent**: `#a2f2da` (Light teal highlights)

### 🦊 Firefox Theme

#### Setup:
1. Enable userChrome.css: `about:config` → `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
2. Restart Firefox
3. Theme files are already installed

#### What's Themed:
- Dark UI with teal accents and rounded tabs
- Consistent toolbar and URL bar styling
- Matching context menus and internal pages

#### Files:
- Active: `~/.mozilla/firefox/hda5zepb.default-release/chrome/userChrome.css`
- Active: `~/.mozilla/firefox/hda5zepb.default-release/chrome/userContent.css`
- Backup: `~/.config/system-config/firefox/`

### 📔 Obsidian Theme

#### Setup:
1. Settings → Appearance → Enable "CSS snippets"  
2. Toggle "ML4W-material3" ON
3. Theme snippet is already installed

#### What's Themed:
- Dark workspace with teal headings and accents
- Code blocks with teal borders
- Consistent sidebar and status bar styling

#### Files:
- Active: `~/.config/obsidian/snippets/ML4W-material3.css`
- Backup: `~/.config/system-config/obsidian/ML4W-material3.css`

## 🔧 System Integration

The configuration system integrates seamlessly with your ML4W setup:

- **Matugen**: Colors extracted from existing `colors.conf`
- **GTK**: Matches gtk-3.0 and gtk-4.0 themes
- **Waybar**: Same color variables as your status bar
- **Hyprland**: Consistent with window borders and decorations

### Current Themed Applications:
- ✅ **Hyprland** - Window manager with teal borders
- ✅ **Waybar** - Status bar with teal accents
- ✅ **Warp Terminal** - "Phenomenon" theme (40% opacity)
- ✅ **Firefox** - Dark UI with teal highlights
- ✅ **Obsidian** - Dark editor with teal accents
- ✅ **GTK Apps** - System-wide dark theme

## 📚 Installation & Restore

### System Restore Process:
1. **Install base system** (Arch Linux)
2. **Restore packages**:
   ```bash
   sudo pacman -S --needed - < ~/.config/system-config/installed-packages.txt
   ```
3. **Install AUR packages** manually from `packages-foreign.txt`
4. **Restore ML4W dotfiles**
5. **Restore system configurations**:
   ```bash
   # Restore Hyprland configurations
   cp ~/.config/system-config/wayland-compositor/* ~/.config/hypr/
   
   # Restore theme system
   cp ~/.config/system-config/theme-system/gtk3-settings.ini ~/.config/gtk-3.0/settings.ini
   cp ~/.config/system-config/theme-system/qt6ct.conf ~/.config/qt6ct/
   
   # Restore application settings
   cp ~/.config/system-config/applications/warp-preferences.json ~/.config/warp-terminal/user_preferences.json
   ```
6. **Apply themes** (Firefox userChrome.css, Obsidian snippets)

### Backup Strategy:
- **Package lists**: Auto-updated on every package operation
- **Theme files**: Backed up in `~/.config/system-config/`
- **Color scheme**: Stored in `ml4w-material3-palette.json`

## 📁 Files Reference

### System Configuration Directory: `~/.config/system-config/`

#### Package Management:
- `installed-packages.txt` - All explicitly installed packages
- `packages-native.txt` - Official repository packages
- `packages-foreign.txt` - AUR and foreign packages  
- `package-updates.log` - Update history log
- `update-package-lists.sh` - Auto-update script

#### Application Themes:
- `ml4w-material3-palette.json` - Complete color reference
- `firefox/userChrome.css` - Firefox UI theme (backup)
- `firefox/userContent.css` - Firefox content theme (backup)
- `obsidian/ML4W-material3.css` - Obsidian theme snippet (backup)

#### System Configuration Backups:
- `wayland-compositor/` - Complete Hyprland setup (90+ files)
- `theme-system/` - Matugen, GTK, Qt, Rofi configurations
- `applications/` - Warp Terminal, Obsidian settings
- `shell-environment/` - Profile files, environment variables, Git config
- `maintenance/` - System maintenance scripts and configuration
- `logs/` - Maintenance and backup logs
- `backup-system-configs.sh` - Automated backup script
- `backup-summary.txt` - Latest backup report
- `check-backup-status.sh` - Backup verification script

#### System Integration:
- `/etc/pacman.d/hooks/update-package-lists.hook` - Pacman trigger
- `~/.config/systemd/user/` - User systemd services and timers

### Active Theme Files:
- Firefox: `~/.mozilla/firefox/hda5zepb.default-release/chrome/`
- Obsidian: `~/.config/obsidian/snippets/ML4W-material3.css`

## 🔧 Troubleshooting

### Package Tracking Issues:
- Check hook exists: `ls /etc/pacman.d/hooks/update-package-lists.hook`
- Test script manually: `~/.config/system-config/update-package-lists.sh`
- View update log: `cat ~/.config/system-config/package-updates.log`

### System Configuration Backup Issues:
- Run backup manually: `~/.config/system-config/backup-system-configs.sh`
- Check backup summary: `cat ~/.config/system-config/backup-summary.txt`
- Verify file counts: `find ~/.config/system-config/ -type f | wc -l`
- Missing configs: Check if source files exist in `~/.config/`

### System Maintenance Issues:
- **Check maintenance status**: `systemctl --user status arch-maintenance.timer`
- **View maintenance logs**: `tail ~/.config/system-config/logs/maintenance-*.log`
- **Test maintenance manually**: `~/.config/system-config/maintenance/maintenance.sh --dry-run`
- **Timer not running**: `systemctl --user enable arch-maintenance.timer`
- **Missing dependencies**: `sudo pacman -S reflector` (for mirror updates)

### Theme Issues:
- **Firefox**: Ensure userChrome.css is enabled in about:config
- **Obsidian**: Check CSS snippets are enabled in Settings
- **Colors**: Compare with other themed applications

---

## 🚀 Future Enhancements

This system configuration approach can be expanded with:
- Additional application themes
- System setting backups
- Custom scripts and utilities
- Dotfiles integration
- Automated setup scripts

Your ML4W Hyprland system now has comprehensive configuration management! 🎉