#!/bin/bash

################################################################################
# 🎨 GymBro Theme Violations Fixer
#
# Automatically fixes hardcoded color violations in Flutter code
# Replaces Colors.* with context.colors.* theme-aware alternatives
#
# Usage:
#   ./scripts/fix_theme_violations.sh [options]
#
# Options:
#   --dry-run           Show what would be changed without modifying files
#   --file <path>       Fix only specific file (for testing)
#   --backup-dir <path> Custom backup directory (default: .theme_fix_backup)
#   --no-backup         Skip backup creation (NOT RECOMMENDED)
#   --verbose           Show detailed output
#   --help              Show this help message
#
# Examples:
#   # Test on single file (dry run)
#   ./scripts/fix_theme_violations.sh --dry-run --file lib/features/workout/presentation/widgets/exercise_list_item.dart
#
#   # Fix single file with backup
#   ./scripts/fix_theme_violations.sh --file lib/features/workout/presentation/widgets/exercise_list_item.dart
#
#   # Fix all files (with backup)
#   ./scripts/fix_theme_violations.sh
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default options
DRY_RUN=false
SPECIFIC_FILE=""
BACKUP_DIR=".theme_fix_backup"
NO_BACKUP=false
VERBOSE=false

# Counters
TOTAL_FILES=0
MODIFIED_FILES=0
TOTAL_REPLACEMENTS=0
SKIPPED_FILES=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            head -n 30 "$0" | tail -n 28
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

################################################################################
# Utility Functions
################################################################################

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

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}  →${NC} $1"
    fi
}

################################################################################
# Backup Functions
################################################################################

create_backup() {
    local file="$1"

    if [ "$NO_BACKUP" = true ]; then
        log_verbose "Skipping backup (--no-backup flag)"
        return 0
    fi

    # Create backup directory structure
    local backup_path="$BACKUP_DIR/$(dirname "$file")"
    mkdir -p "$backup_path"

    # Copy file to backup
    cp "$file" "$BACKUP_DIR/$file"
    log_verbose "Backed up: $file"
}

################################################################################
# Import Management
################################################################################

add_theme_imports() {
    local file="$1"
    local added_imports=0

    # Check if file uses context.colors (would need the imports)
    if ! grep -q "context\.colors\." "$file"; then
        log_verbose "File doesn't use context.colors, skipping imports"
        return 0
    fi

    # Find the last import line
    local last_import_line=$(grep -n "^import " "$file" | tail -1 | cut -d: -f1)

    if [ -z "$last_import_line" ]; then
        log_warning "No imports found in $file, cannot add imports"
        return 1
    fi

    # Import 1: build_context_extensions.dart (for context.colors)
    if ! grep -q "build_context_extensions.dart" "$file"; then
        local import1="import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';"

        if [ "$DRY_RUN" = false ]; then
            sed -i '' "${last_import_line}a\\
$import1
" "$file"
            last_import_line=$((last_import_line + 1))
            added_imports=$((added_imports + 1))
        fi
        log_verbose "Added build_context_extensions import"
    else
        log_verbose "build_context_extensions import already exists"
    fi

    # Import 2: color_scheme_extensions.dart (for .success, .warning)
    if ! grep -q "color_scheme_extensions.dart" "$file"; then
        local import2="import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';"

        if [ "$DRY_RUN" = false ]; then
            sed -i '' "${last_import_line}a\\
$import2
" "$file"
            added_imports=$((added_imports + 1))
        fi
        log_verbose "Added color_scheme_extensions import"
    else
        log_verbose "color_scheme_extensions import already exists"
    fi

    if [ "$added_imports" -gt 0 ]; then
        log_verbose "Added $added_imports theme imports to $file"
    fi
}

################################################################################
# Color Replacement Functions
################################################################################

replace_colors_in_file() {
    local file="$1"
    local replacements=0

    log_verbose "Processing: $file"

    # Create backup
    create_backup "$file"

    # Define color replacements as array of "old|new" pairs
    # Order matters - more specific first
    local color_replacements=(
        # Primary colors
        "Colors\.blue|context.colors.primary"

        # Secondary colors
        "Colors\.orange|context.colors.secondary"

        # Success (custom extension)
        "Colors\.lightGreen|context.colors.success"
        "Colors\.green|context.colors.success"

        # Error
        "Colors\.red|context.colors.error"

        # Warning (custom extension)
        "Colors\.deepOrange|context.colors.warning"
        "Colors\.amber|context.colors.warning"
        "Colors\.yellow|context.colors.warning"

        # Tertiary
        "Colors\.deepPurple|context.colors.tertiary"
        "Colors\.purple|context.colors.tertiary"
        "Colors\.cyan|context.colors.tertiary"

        # Surface and background
        "Colors\.white|context.colors.surface"
        "Colors\.grey|context.colors.surfaceVariant"

        # Text colors
        "Colors\.black|context.colors.onSurface"

        # Special cases - kept as-is
        # Colors.transparent - Universal, no theme needed
    )

    # Perform replacements
    for pair in "${color_replacements[@]}"; do
        local old_color=$(echo "$pair" | cut -d'|' -f1)
        local new_color=$(echo "$pair" | cut -d'|' -f2)

        # Count occurrences before replacement (remove backslashes for grep)
        local search_pattern=$(echo "$old_color" | sed 's/\\\././g')
        local count=$(grep -o "$search_pattern" "$file" 2>/dev/null | wc -l | tr -d ' ')

        if [ "$count" -gt 0 ]; then
            log_verbose "  Found $count occurrences of $search_pattern"
            replacements=$((replacements + count))

            if [ "$DRY_RUN" = false ]; then
                # Perform replacement (macOS compatible)
                sed -i '' "s/$old_color/$new_color/g" "$file"
            fi
        fi
    done

    # Add imports if needed and replacements were made
    if [ "$replacements" -gt 0 ]; then
        add_theme_imports "$file"
    fi

    echo "$replacements"
}

################################################################################
# Edge Case Detection
################################################################################

is_complex_file() {
    local file="$1"
    local has_issues=false

    # Check for const + Colors.* (can't use context in const)
    if grep -q "const.*Colors\." "$file" 2>/dev/null; then
        log_warning "Complex pattern detected: const + Colors.* in $(basename $file)"
        has_issues=true
    fi

    # Check for Colors.*.shade (MaterialColor accessor not available on Color)
    if grep -q "Colors\..*\.shade" "$file" 2>/dev/null; then
        log_warning "Complex pattern detected: Colors.*.shade in $(basename $file)"
        has_issues=true
    fi

    # Check for Colors.*[index] (array accessor)
    if grep -q "Colors\.\[" "$file" 2>/dev/null; then
        log_warning "Complex pattern detected: Colors.*[index] in $(basename $file)"
        has_issues=true
    fi

    # Return 0 (success) if has issues, so 'if is_complex_file' passes
    if [ "$has_issues" = true ]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Main Processing
################################################################################

process_file() {
    local file="$1"

    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Skip if file doesn't contain Colors.
    if ! grep -q "Colors\." "$file" 2>/dev/null; then
        log_verbose "Skipping $file (no violations)"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return
    fi

    # Skip theme files (they legitimately define colors)
    if [[ "$file" == *"theme/app_theme.dart"* ]] || [[ "$file" == *"color_scheme_extensions.dart"* ]]; then
        log_verbose "Skipping theme file: $file"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return
    fi

    # Check for complex patterns
    if is_complex_file "$file"; then
        log_warning "Skipping complex file: $file (needs manual review)"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return
    fi

    # Process the file
    local count=$(replace_colors_in_file "$file" 2>/dev/null | tail -1)

    # Validate count is a number
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        log_warning "Invalid count returned for $file, skipping"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return
    fi

    if [ "$count" -gt 0 ]; then
        MODIFIED_FILES=$((MODIFIED_FILES + 1))
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + count))

        if [ "$DRY_RUN" = true ]; then
            log_info "Would fix $file: $count replacements"
        else
            log_success "Fixed $file: $count replacements"
        fi
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  🎨 ${CYAN}GymBro Theme Violations Fixer${NC}                          ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Show configuration
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE - No files will be modified"
    fi

    if [ -n "$SPECIFIC_FILE" ]; then
        log_info "Target: Single file ($SPECIFIC_FILE)"
    else
        log_info "Target: All Dart files in lib/"
    fi

    if [ "$NO_BACKUP" = false ]; then
        log_info "Backup directory: $BACKUP_DIR/"
    else
        log_warning "Backup DISABLED"
    fi

    echo ""

    # Create backup directory
    if [ "$NO_BACKUP" = false ] && [ "$DRY_RUN" = false ]; then
        mkdir -p "$BACKUP_DIR"
        log_success "Created backup directory: $BACKUP_DIR/"
    fi

    # Process files
    log_info "Scanning for violations..."
    echo ""

    if [ -n "$SPECIFIC_FILE" ]; then
        # Process single file
        if [ ! -f "$SPECIFIC_FILE" ]; then
            log_error "File not found: $SPECIFIC_FILE"
            exit 1
        fi
        process_file "$SPECIFIC_FILE"
    else
        # Process all files
        while IFS= read -r file; do
            process_file "$file"
        done < <(find lib -name "*.dart" -type f)
    fi

    # Summary
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  📊 ${CYAN}Summary${NC}                                                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Total files scanned:     ${CYAN}$TOTAL_FILES${NC}"
    echo -e "  Files modified:          ${GREEN}$MODIFIED_FILES${NC}"
    echo -e "  Files skipped:           ${YELLOW}$SKIPPED_FILES${NC}"
    echo -e "  Total replacements:      ${PURPLE}$TOTAL_REPLACEMENTS${NC}"
    echo ""

    if [ "$DRY_RUN" = false ] && [ "$MODIFIED_FILES" -gt 0 ]; then
        log_success "All modifications complete!"
        echo ""
        log_info "Next steps:"
        echo "  1. Run: flutter analyze"
        echo "  2. Test app in light/dark mode"
        echo "  3. If issues, restore from: $BACKUP_DIR/"
        echo ""
        log_info "To restore from backup:"
        echo "  cp -r $BACKUP_DIR/lib/* lib/"
    elif [ "$DRY_RUN" = true ]; then
        log_info "Dry run complete. Run without --dry-run to apply changes."
    else
        log_info "No files needed modification."
    fi

    echo ""
}

# Run main function
main

exit 0
