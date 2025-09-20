#!/bin/bash

# Quick script to check backup status

echo "📊 System Configuration Backup Status"
echo "======================================"

# Check if timer is active
echo "🕒 Timer Status:"
systemctl --user is-active config-backup.timer
systemctl --user list-timers config-backup.timer

echo
echo "📋 Last Backup Run:"
if [ -f ~/.config/system-config/backup-summary.txt ]; then
    head -2 ~/.config/system-config/backup-summary.txt
    echo "Files: $(ls -la ~/.config/system-config/backup-summary.txt | awk '{print $5}') bytes"
    echo "Last modified: $(ls -la ~/.config/system-config/backup-summary.txt | awk '{print $6, $7, $8}')"
else
    echo "No backup found yet"
fi

echo
echo "📜 Recent Logs (last 5 lines):"
journalctl --user -u config-backup.service -n 5 --no-pager | tail -5

echo
echo "💡 Commands:"
echo "  systemctl --user start config-backup.service    # Run backup now"
echo "  journalctl --user -u config-backup.service      # View full logs"