# Arch Linux System Maintenance

Automated monthly maintenance for Arch Linux integrated with your `~/.config/system-config` setup.

## 📋 Overview

This maintenance system performs comprehensive Arch Linux maintenance tasks:

- **System Updates**: Full system updates including AUR packages via `yay`
- **Mirror Optimization**: Updates pacman mirrors using `reflector` for fastest downloads
- **Cache Management**: Cleans old package cache files while keeping recent versions
- **Orphan Removal**: Removes unused packages no longer required by any software
- **Flatpak Maintenance**: Updates Flatpak apps and handles dependency restoration
- **SSD Optimization**: Performs SSD TRIM for better performance
- **Journal Cleanup**: Manages systemd journal log size
- **System Health**: Checks for failed services and disk usage
- **Comprehensive Logging**: All operations logged with integration to backup summaries

## 🚀 Quick Start

### Manual Execution

```bash
# Interactive mode - prompts for confirmation
~/.config/system-config/maintenance/maintenance.sh

# Automated mode - no prompts (used by timer)
~/.config/system-config/maintenance/maintenance.sh --auto

# Preview mode - see what would be done
~/.config/system-config/maintenance/maintenance.sh --dry-run
```

### Automated Scheduling

The system runs automatically on the **1st of every month at 2:00 AM** (with up to 2 hours random delay to distribute load).

```bash
# Check timer status
systemctl --user status arch-maintenance.timer

# View next scheduled run
systemctl --user list-timers

# Manually trigger maintenance
systemctl --user start arch-maintenance.service
```

## ⚙️ Configuration

Edit `~/.config/system-config/maintenance/maintenance.conf` to customize behavior:

### Key Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `AUTO` | `0` | Auto-confirm all prompts (1=yes, 0=no) |
| `KEEP_CACHE` | `3` | Number of old package versions to keep |
| `JOURNAL_DAYS` | `14` | Keep journal logs for N days |
| `TRIM` | `1` | Enable SSD TRIM optimization |
| `UPDATE_MIRRORS` | `1` | Update pacman mirrors using reflector |
| `MIRROR_COUNTRY` | `"US"` | Country for mirror selection (auto-detected) |
| `NOTIFICATIONS` | `1` | Send desktop notifications |

### Advanced Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `FLATPAK_ENABLED` | `1` | Enable Flatpak operations |
| `FLATPAK_REINSTALL` | `1` | Reinstall Flatpak apps after orphan removal |
| `YAY_ENABLED` | `1` | Use yay for AUR updates |
| `BACKUP_PACMAN_DB` | `1` | Backup pacman database before operations |
| `INTEGRATE_BACKUP_SUMMARY` | `1` | Add results to backup-summary.txt |

## 📂 File Structure

```
~/.config/system-config/maintenance/
├── maintenance.sh              # Main maintenance script
├── maintenance.conf            # Configuration file
└── README.md                   # This documentation

~/.config/system-config/logs/
├── maintenance-YYYYMMDD-HHMMSS.log  # Detailed operation logs
└── backup-summary.txt               # Integrated maintenance summaries

~/.config/systemd/user/
├── arch-maintenance.service    # Systemd service definition
└── arch-maintenance.timer      # Monthly scheduling timer
```

## 🔧 Manual Control

### Service Management

```bash
# Enable/disable automatic maintenance
systemctl --user enable arch-maintenance.timer   # Enable
systemctl --user disable arch-maintenance.timer  # Disable

# Start maintenance immediately
systemctl --user start arch-maintenance.service

# Check service logs
journalctl --user -u arch-maintenance.service
```

### Configuration Examples

**Conservative Setup** (minimal changes):
```bash
# Edit maintenance.conf
KEEP_CACHE=5          # Keep more package versions
JOURNAL_DAYS=30       # Keep logs longer
FLATPAK_REINSTALL=0   # Don't reinstall Flatpak apps
```

**Aggressive Cleanup**:
```bash
# Edit maintenance.conf
KEEP_CACHE=1          # Keep only latest package version
JOURNAL_DAYS=7        # Shorter log retention
AUTO=1                # Never prompt (use with caution)
```

## 📊 Integration Features

### Backup System Integration

- **Automatic logging** to your existing `backup-summary.txt`
- **Consistent file structure** with other system-config components
- **Unified notification system** using your desktop environment

### Statistics Tracking

Each maintenance run provides:
- Number of packages updated
- Disk space freed from cache cleanup  
- Orphaned packages removed
- Execution time and error count

### Smart Dependency Handling

- **Flatpak Protection**: Automatically reinstalls Flatpak applications after orphan removal to restore broken dependencies
- **AUR Integration**: Uses `yay` when available for comprehensive updates
- **Graceful Fallbacks**: Continues operation even if optional tools are missing

## 🛠️ Troubleshooting

### Common Issues

**Mirror updates fail**:
```bash
sudo pacman -S reflector  # Ensure reflector is installed
```

**No AUR updates**:
```bash
# Install yay if missing
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

**Flatpak errors after maintenance**:
```bash
flatpak repair  # Fix broken Flatpak dependencies
```

### Log Analysis

**View recent maintenance logs**:
```bash
tail -f ~/.config/system-config/logs/maintenance-*.log
```

**Check for errors**:
```bash
grep "❌\|ERROR" ~/.config/system-config/logs/maintenance-*.log
```

**Service debugging**:
```bash
# Test service manually
systemctl --user start arch-maintenance.service
systemctl --user status arch-maintenance.service

# Check detailed logs
journalctl --user -u arch-maintenance.service --since today
```

### Timer Issues

**Timer not running**:
```bash
# Ensure user session persists
sudo loginctl enable-linger anthon

# Reload systemd configuration
systemctl --user daemon-reload
systemctl --user enable arch-maintenance.timer
```

**Change schedule**:
```bash
# Edit timer file
vim ~/.config/systemd/user/arch-maintenance.timer

# Reload after changes
systemctl --user daemon-reload
systemctl --user restart arch-maintenance.timer
```

## 🔐 Security Considerations

### Sudo Requirements

The script uses `sudo` for privileged operations:
- Package management (`pacman`, `yay`)
- Mirror updates (`reflector`)
- System maintenance (`fstrim`, `journalctl`)

### Safety Features

- **Dry-run mode** for testing changes
- **Pacman database backup** before major operations
- **Confirmation prompts** in interactive mode
- **Graceful error handling** with detailed logging
- **No automatic reboot** - you control when to restart

### Permissions

- Script runs as regular user with sudo escalation
- Configuration files are user-writable only
- Logs stored in user directory

## 📈 Monitoring

### Notifications

Desktop notifications show:
- ✅ **Successful completion** with summary statistics
- ⚠️ **Warnings** for partially completed operations
- ❌ **Errors** with log file location

### Log Rotation

- Maintenance logs older than **12 months** are automatically removed
- Journal logs cleaned based on `JOURNAL_DAYS` setting
- Package cache managed with `KEEP_CACHE` versions

## 🎯 Best Practices

### Recommended Schedule

- **Monthly maintenance**: Balances system health with stability
- **Manual runs**: Before important work or after major changes
- **Dry runs**: Test configuration changes before applying

### Configuration Tuning

- **Development systems**: More aggressive cleanup, shorter retention
- **Production systems**: Conservative settings, longer retention  
- **Gaming systems**: Careful with orphan removal (game launchers)

### Monitoring Strategy

1. **Check logs** after first few automated runs
2. **Monitor disk usage** trends over time
3. **Verify system stability** after maintenance
4. **Adjust settings** based on your usage patterns

---

## 💡 Tips & Tricks

**Quick status check**:
```bash
# See when maintenance last ran and next schedule
systemctl --user list-timers | grep maintenance
tail -1 ~/.config/system-config/backup-summary.txt
```

**Emergency stop**:
```bash
# Stop running maintenance
systemctl --user stop arch-maintenance.service
```

**Temporary disable**:
```bash
# Disable for this month only
systemctl --user stop arch-maintenance.timer
# Re-enable next month
systemctl --user start arch-maintenance.timer
```

Your Arch system now has bulletproof automated maintenance! 🎉