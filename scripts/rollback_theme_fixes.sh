#!/bin/bash

################################################################################
# 🔄 GymBro Theme Fixes Rollback
#
# Restores files from backup created by fix_theme_violations.sh
#
# Usage:
#   ./scripts/rollback_theme_fixes.sh [options]
#
# Options:
#   --backup-dir <path>  Backup directory to restore from (default: .theme_fix_backup)
#   --file <path>        Restore only specific file
#   --list               List all backed up files
#   --verify             Verify backup integrity before restoring
#   --help               Show this help message
#
# Examples:
#   # List all backed up files
#   ./scripts/rollback_theme_fixes.sh --list
#
#   # Restore single file
#   ./scripts/rollback_theme_fixes.sh --file lib/features/workout/presentation/widgets/exercise_list_item.dart
#
#   # Restore all files
#   ./scripts/rollback_theme_fixes.sh
#
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default options
BACKUP_DIR=".theme_fix_backup"
SPECIFIC_FILE=""
LIST_ONLY=false
VERIFY=false

# Counters
RESTORED_FILES=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        --help)
            head -n 28 "$0" | tail -n 26
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

log_error() {
    echo -e "${RED}✗${NC}  $1"
}

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  🔄 ${CYAN}GymBro Theme Fixes Rollback${NC}                            ${PURPLE}║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup directory not found: $BACKUP_DIR"
    log_info "Have you run fix_theme_violations.sh yet?"
    exit 1
fi

# List mode
if [ "$LIST_ONLY" = true ]; then
    log_info "Backed up files in $BACKUP_DIR:"
    echo ""
    find "$BACKUP_DIR/lib" -type f -name "*.dart" 2>/dev/null | sed "s|$BACKUP_DIR/||" | while read file; do
        echo -e "  ${CYAN}•${NC} $file"
    done
    echo ""
    exit 0
fi

# Verify mode
if [ "$VERIFY" = true ]; then
    log_info "Verifying backup integrity..."
    errors=0
    while IFS= read -r backup_file; do
        original_file="${backup_file#$BACKUP_DIR/}"
        if [ ! -f "$original_file" ]; then
            log_warning "Original file missing: $original_file"
            errors=$((errors + 1))
        fi
    done < <(find "$BACKUP_DIR/lib" -type f -name "*.dart")

    if [ "$errors" -eq 0 ]; then
        log_success "Backup integrity verified"
    else
        log_warning "Found $errors potential issues"
    fi
    echo ""
    exit 0
fi

# Restore function
restore_file() {
    local backup_file="$1"
    local original_file="${backup_file#$BACKUP_DIR/}"

    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi

    cp "$backup_file" "$original_file"
    RESTORED_FILES=$((RESTORED_FILES + 1))
    log_success "Restored: $original_file"
}

# Confirm restoration
if [ -z "$SPECIFIC_FILE" ]; then
    log_warning "This will restore ALL files from backup"
    echo -ne "Are you sure? (yes/no): "
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Rollback cancelled"
        exit 0
    fi
    echo ""
fi

# Perform restoration
if [ -n "$SPECIFIC_FILE" ]; then
    # Restore single file
    backup_path="$BACKUP_DIR/$SPECIFIC_FILE"
    if [ ! -f "$backup_path" ]; then
        log_error "No backup found for: $SPECIFIC_FILE"
        exit 1
    fi
    restore_file "$backup_path"
else
    # Restore all files
    log_info "Restoring files from backup..."
    echo ""
    while IFS= read -r backup_file; do
        restore_file "$backup_file"
    done < <(find "$BACKUP_DIR/lib" -type f -name "*.dart")
fi

# Summary
echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  📊 ${CYAN}Summary${NC}                                                   ${PURPLE}║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Files restored:          ${GREEN}$RESTORED_FILES${NC}"
echo ""
log_success "Rollback complete!"
echo ""
log_info "Next steps:"
echo "  1. Run: flutter analyze"
echo "  2. Test app to verify restoration"
echo ""

exit 0
