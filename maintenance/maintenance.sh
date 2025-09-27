#!/bin/bash

# Arch Linux System Maintenance Script
# Integrated with ~/.config/system-config setup
# Based on: https://github.com/cdvel/arch-maintenance
# Enhanced for monthly automated maintenance with proper logging and notifications

set -euo pipefail

# =============================================================================
# CONFIGURATION & SETUP
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SYSTEM_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/maintenance.conf"

# Source configuration
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=maintenance.conf
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Resolve LOG_DIR (relative to system-config if not absolute)
if [[ "$LOG_DIR" == /* ]]; then
    LOG_DIR_FULL="$LOG_DIR"
else
    LOG_DIR_FULL="$SYSTEM_CONFIG_DIR/$LOG_DIR"
fi
mkdir -p "$LOG_DIR_FULL"

# Set up logging
LOG_FILE="$LOG_DIR_FULL/maintenance-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Counters and stats
PACKAGES_UPDATED=0
CACHE_FREED_MB=0
ORPHANS_REMOVED=0
ERRORS_COUNT=0
START_TIME=$(date +%s)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $*"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
    ((ERRORS_COUNT++))
}

log_section() {
    echo
    echo -e "${PURPLE}${BOLD}🔷 $*${NC}"
    echo -e "${PURPLE}────────────────────────────────────────────${NC}"
}

send_notification() {
    if [[ "$NOTIFICATIONS" == "1" ]] && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
        notify-send --app-name="System Maintenance" --icon="$3" "$1" "$2" 2>/dev/null || true
    fi
}

confirm_action() {
    if [[ "$AUTO" == "1" ]] || [[ "${FORCE_AUTO:-0}" == "1" ]]; then
        return 0
    fi

    echo -e "${YELLOW}$1 [y/N]${NC}"
    read -r response
    [[ "${response,,}" =~ ^(yes|y)$ ]]
}

run_command() {
    local cmd="$1"
    local desc="$2"
    
    log "$desc..."
    
    if [[ "$DRY_RUN" == "1" ]]; then
        log "DRY RUN: $cmd"
        return 0
    fi

    if eval "$cmd"; then
        log_success "$desc completed"
        return 0
    else
        log_error "$desc failed"
        return 1
    fi
}

check_dependencies() {
    local missing=0
    
    log "Checking dependencies..."
    
    # Check for required commands
    local deps=("pacman" "paccache" "systemctl" "journalctl")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "Required command not found: $dep"
            ((missing++))
        fi
    done
    
    # Check optional but recommended
    if [[ "$UPDATE_MIRRORS" == "1" ]] && ! command -v reflector &>/dev/null; then
        log_warning "reflector not found - mirror updates will be skipped"
        UPDATE_MIRRORS=0
    fi
    
    if [[ "$YAY_ENABLED" == "1" ]] && ! command -v yay &>/dev/null; then
        log_warning "yay not found - AUR updates will use pacman only"
        YAY_ENABLED=0
    fi
    
    if [[ "$FLATPAK_ENABLED" == "1" ]] && ! command -v flatpak &>/dev/null; then
        log_warning "flatpak not found - Flatpak operations will be skipped"
        FLATPAK_ENABLED=0
    fi
    
    if [[ $missing -gt 0 ]]; then
        log_error "Missing $missing required dependencies"
        return 1
    fi
    
    log_success "All dependencies available"
    return 0
}

show_disk_usage() {
    if [[ "$SHOW_DISK_USAGE" == "1" ]]; then
        echo -e "${CYAN}💽 Disk usage:${NC}"
        df -h / /home 2>/dev/null | grep -E "(Filesystem|/dev/)" || true
    fi
}

# =============================================================================
# MAINTENANCE FUNCTIONS
# =============================================================================

backup_pacman_database() {
    if [[ "$BACKUP_PACMAN_DB" != "1" ]]; then
        return 0
    fi
    
    log_section "Backing up pacman database"
    
    local backup_dir="/var/lib/pacman/backup"
    local backup_file="$backup_dir/pacman_database_$(date +%Y%m%d).tar.gz"
    
    if [[ "$DRY_RUN" != "1" ]]; then
        sudo mkdir -p "$backup_dir" 2>/dev/null || true
        
        if sudo tar -czf "$backup_file" -C /var/lib/pacman/ local 2>/dev/null; then
            log_success "Pacman database backed up to $backup_file"
        else
            log_error "Failed to backup pacman database"
        fi
    else
        log "DRY RUN: Would backup pacman database to $backup_file"
    fi
}

update_mirrors() {
    if [[ "$UPDATE_MIRRORS" != "1" ]]; then
        return 0
    fi
    
    log_section "Updating pacman mirrors"
    
    if ! confirm_action "Update pacman mirrors for optimal download speeds?"; then
        log_warning "Skipping mirror update"
        return 0
    fi
    
    local reflector_cmd="reflector --verbose --latest $MIRROR_COUNT --protocol $MIRROR_PROTOCOL --sort rate --save /etc/pacman.d/mirrorlist"
    
    # Try to auto-detect country if not set or if set to "US" (default)
    if [[ -z "${MIRROR_COUNTRY:-}" ]] || [[ "${MIRROR_COUNTRY}" == "US" ]]; then
        local detected_country
        detected_country=$(curl -s https://ipinfo.io/country 2>/dev/null || echo "")
        if [[ -n "$detected_country" ]]; then
            reflector_cmd="reflector --verbose --country '$detected_country' --latest $MIRROR_COUNT --protocol $MIRROR_PROTOCOL --sort rate --save /etc/pacman.d/mirrorlist"
            log "Auto-detected country: $detected_country"
        fi
    else
        reflector_cmd="reflector --verbose --country '$MIRROR_COUNTRY' --latest $MIRROR_COUNT --protocol $MIRROR_PROTOCOL --sort rate --save /etc/pacman.d/mirrorlist"
    fi
    
    if run_command "sudo $reflector_cmd" "Mirror list update"; then
        log_success "Mirrors updated for optimal performance"
    fi
}

system_update() {
    log_section "System update"
    
    if ! confirm_action "Perform full system update (including AUR packages)?"; then
        log_warning "Skipping system update"
        return 0
    fi
    
    local update_cmd
    if [[ "$YAY_ENABLED" == "1" ]]; then
        if [[ "$AUTO" == "1" ]]; then
            update_cmd="yay -Syu --noconfirm --needed"
        else
            update_cmd="yay -Syu --needed"
        fi
        log "Using yay for repository and AUR updates"
    else
        if [[ "$AUTO" == "1" ]]; then
            update_cmd="sudo pacman -Syu --noconfirm --needed"
        else
            update_cmd="sudo pacman -Syu --needed"
        fi
        log "Using pacman for repository updates only"
    fi
    
    # Count packages before update
    local packages_before
    packages_before=$(pacman -Q | wc -l)
    
    if run_command "$update_cmd" "System update"; then
        # Count packages after update
        local packages_after
        packages_after=$(pacman -Q | wc -l)
        PACKAGES_UPDATED=$((packages_after - packages_before))
        
        log_success "System updated successfully"
        if [[ $PACKAGES_UPDATED -gt 0 ]]; then
            log "New packages installed: $PACKAGES_UPDATED"
        fi
    fi
    
    # Update file database for pkgfile
    run_command "sudo pacman -Fy --noconfirm" "Package file database update" || true
}

clean_package_cache() {
    log_section "Cleaning package cache"
    
    if ! confirm_action "Clean package cache (keeping $KEEP_CACHE versions)?"; then
        log_warning "Skipping package cache cleaning"
        return 0
    fi
    
    # Calculate cache size before cleaning
    local cache_before=0
    if [[ -d /var/cache/pacman/pkg ]]; then
        cache_before=$(du -sm /var/cache/pacman/pkg | cut -f1)
    fi
    
    # Clean installed packages cache
    run_command "sudo paccache -rq -k $KEEP_CACHE" "Clean installed packages cache"
    
    # Clean uninstalled packages cache  
    run_command "sudo paccache -rq -u -k 0" "Clean uninstalled packages cache"
    
    # Clean yay cache if available
    if [[ "$YAY_ENABLED" == "1" ]] && confirm_action "Clean yay build cache?"; then
        run_command "yay -Sc --noconfirm" "Clean yay build cache"
    fi
    
    # Calculate freed space
    local cache_after=0
    if [[ -d /var/cache/pacman/pkg ]]; then
        cache_after=$(du -sm /var/cache/pacman/pkg | cut -f1)
    fi
    CACHE_FREED_MB=$((cache_before - cache_after))
    
    if [[ $CACHE_FREED_MB -gt 0 ]]; then
        log_success "Freed ${CACHE_FREED_MB}MB from package cache"
    fi
}

remove_orphans() {
    log_section "Removing orphaned packages"
    
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)
    
    if [[ -z "$orphans" ]]; then
        log_success "No orphaned packages found"
        return 0
    fi
    
    echo -e "${YELLOW}Found orphaned packages:${NC}"
    echo "$orphans"
    
    if [[ "$FLATPAK_ENABLED" == "1" ]] && [[ "$FLATPAK_REINSTALL" == "1" ]]; then
        log_warning "Flatpak apps will be reinstalled after orphan removal to fix dependencies"
    fi
    
    if ! confirm_action "Remove these orphaned packages?"; then
        log_warning "Skipping orphaned package removal"
        return 0
    fi
    
    local orphan_count
    orphan_count=$(echo "$orphans" | wc -l)
    
    local remove_cmd
    if [[ "$AUTO" == "1" ]]; then
        remove_cmd="sudo pacman -Rns --noconfirm"
    else
        remove_cmd="sudo pacman -Rns"
    fi
    
    if echo "$orphans" | xargs -r $remove_cmd; then
        ORPHANS_REMOVED=$orphan_count
        log_success "Removed $ORPHANS_REMOVED orphaned packages"
    else
        log_error "Failed to remove some orphaned packages"
    fi
}

flatpak_maintenance() {
    if [[ "$FLATPAK_ENABLED" != "1" ]]; then
        return 0
    fi
    
    log_section "Flatpak maintenance"
    
    # Update Flatpak applications
    if confirm_action "Update Flatpak applications?"; then
        run_command "flatpak update -y" "Update Flatpak applications"
    fi
    
    # Remove unused runtimes
    if confirm_action "Remove unused Flatpak runtimes and extensions?"; then
        run_command "flatpak uninstall --unused -y" "Remove unused Flatpak runtimes"
    fi
    
    # Reinstall apps if orphan removal happened and FLATPAK_REINSTALL is enabled
    if [[ "$FLATPAK_REINSTALL" == "1" ]] && [[ $ORPHANS_REMOVED -gt 0 ]]; then
        if confirm_action "Reinstall Flatpak packages to fix potential dependency issues?"; then
            local flatpak_apps
            flatpak_apps=$(flatpak list --app --columns=application 2>/dev/null || true)
            
            if [[ -n "$flatpak_apps" ]]; then
                log "Reinstalling Flatpak packages to restore dependencies..."
                echo "$flatpak_apps" | while read -r app; do
                    if [[ -n "$app" ]]; then
                        run_command "flatpak install --reinstall -y '$app'" "Reinstall $app" || true
                    fi
                done
                log_success "Flatpak packages reinstalled"
            else
                log "No Flatpak applications found to reinstall"
            fi
        fi
    fi
}

trim_ssd() {
    if [[ "$TRIM" != "1" ]]; then
        return 0
    fi
    
    log_section "SSD TRIM optimization"
    
    if ! confirm_action "Perform SSD TRIM (optimize SSD performance)?"; then
        log_warning "Skipping SSD TRIM"
        return 0
    fi
    
    run_command "sudo fstrim -av" "SSD TRIM optimization"
}

clean_journals() {
    log_section "Cleaning system journals"
    
    if ! confirm_action "Clean journal logs older than $JOURNAL_DAYS days?"; then
        log_warning "Skipping journal cleanup"
        return 0
    fi
    
    run_command "sudo journalctl --vacuum-time=${JOURNAL_DAYS}d" "Clean old journal logs"
}

check_failed_services() {
    if [[ "$CHECK_FAILED_SERVICES" != "1" ]]; then
        return 0
    fi
    
    log_section "Checking for failed services"
    
    local failed_services
    failed_services=$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)
    
    if [[ -n "$failed_services" ]]; then
        log_warning "Failed services found:"
        echo "$failed_services"
    else
        log_success "No failed services detected"
    fi
}

# =============================================================================
# REPORTING & CLEANUP
# =============================================================================

generate_summary() {
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local duration_min=$((duration / 60))
    
    log_section "Maintenance Summary"
    
    echo -e "${BLUE}Duration:${NC} ${duration_min} minutes"
    echo -e "${BLUE}Packages updated:${NC} $PACKAGES_UPDATED"
    echo -e "${BLUE}Cache freed:${NC} ${CACHE_FREED_MB}MB"
    echo -e "${BLUE}Orphans removed:${NC} $ORPHANS_REMOVED"
    echo -e "${BLUE}Errors:${NC} $ERRORS_COUNT"
    
    # Integrate with backup summary if enabled
    if [[ "$INTEGRATE_BACKUP_SUMMARY" == "1" ]]; then
        local summary_file="$SYSTEM_CONFIG_DIR/backup-summary.txt"
        local maintenance_summary="$(date '+%Y-%m-%d %H:%M:%S'): Maintenance completed - updated $PACKAGES_UPDATED pkgs, freed ${CACHE_FREED_MB}MB, removed $ORPHANS_REMOVED orphans"
        
        echo >> "$summary_file"
        echo "=== SYSTEM MAINTENANCE ===" >> "$summary_file"
        echo "$maintenance_summary" >> "$summary_file"
    fi
    
    # Send completion notification
    local status
    if [[ $ERRORS_COUNT -eq 0 ]]; then
        status="✅ Maintenance Completed Successfully"
        send_notification "$status" "Updated $PACKAGES_UPDATED packages, freed ${CACHE_FREED_MB}MB" "system-run"
    else
        status="⚠️ Maintenance Completed with $ERRORS_COUNT Errors"
        send_notification "$status" "Check $LOG_FILE for details" "dialog-warning"
    fi
    
    echo -e "${GREEN}$status${NC}"
    echo -e "${CYAN}Log saved to: $LOG_FILE${NC}"
}

cleanup_old_logs() {
    # Remove maintenance logs older than 12 months
    find "$LOG_DIR_FULL" -name "maintenance-*.log" -mtime +365 -delete 2>/dev/null || true
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

show_help() {
    cat << EOF
${BLUE}${BOLD}Arch Linux System Maintenance Script${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    -h, --help              Show this help message
    -a, --auto              Enable auto-confirm mode (no prompts)
    -d, --dry-run           Show what would be done without making changes
    -c, --config FILE       Use alternative configuration file
    
${BOLD}CONFIGURATION:${NC}
    Edit $CONFIG_FILE to customize behavior

${BOLD}EXAMPLES:${NC}
    $0                      # Interactive maintenance
    $0 --auto               # Automated maintenance (for systemd)
    $0 --dry-run            # Preview operations
    
${BOLD}INTEGRATION:${NC}
    This script integrates with your ~/.config/system-config setup:
    - Logs: $LOG_DIR_FULL
    - Config: $CONFIG_FILE
    - Integrates with existing backup summaries
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--auto)
            FORCE_AUTO=1
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=1
            shift
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Check if running as root (needed for most operations)
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root - it will use sudo when needed"
        exit 1
    fi
    
    # Header
    echo -e "${BLUE}${BOLD}══════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}        ARCH LINUX SYSTEM MAINTENANCE       ${NC}"
    echo -e "${BLUE}${BOLD}══════════════════════════════════════════${NC}"
    echo -e "${CYAN}🚀 Starting maintenance at $(date)${NC}"
    echo -e "${CYAN}📁 System config: $SYSTEM_CONFIG_DIR${NC}"
    echo -e "${CYAN}📝 Log file: $LOG_FILE${NC}"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "${YELLOW}${BOLD}🧪 DRY RUN MODE - No actual changes will be made${NC}"
    fi
    
    if [[ "${FORCE_AUTO:-0}" == "1" ]]; then
        echo -e "${CYAN}🤖 AUTO MODE - No prompts will be shown${NC}"
    fi
    
    echo
    
    # Show initial disk usage
    show_disk_usage
    
    # Check dependencies
    check_dependencies || exit 1
    
    # Execute maintenance tasks
    backup_pacman_database
    update_mirrors
    system_update
    clean_package_cache
    remove_orphans
    flatpak_maintenance
    trim_ssd
    clean_journals
    check_failed_services
    
    # Show final disk usage
    show_disk_usage
    
    # Generate summary and cleanup
    generate_summary
    cleanup_old_logs
    
    echo -e "${GREEN}🎉 System maintenance completed!${NC}"
    
    if [[ $ERRORS_COUNT -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Handle script termination
trap 'log_error "Script interrupted"; exit 130' INT TERM

# Run main function
main "$@"