#!/bin/bash
# FitLog Codebase Health Monitor
# Detects zombie files: orphans, duplicates, stale files

set -e

echo ""
echo "=========================================="
echo "   FitLog Codebase Health Check"
echo "=========================================="
echo ""

# Configuration
LIB_DIR="lib"
STALE_PATTERNS="old_|temp_|deprecated_|_backup|_old|_temp|_copy"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

issues_found=0

# ============================================
# 1. Find duplicate file names in different directories
# ============================================
echo "1. Checking for duplicate file names..."

duplicates=$(find "$LIB_DIR" -name "*.dart" -exec basename {} \; 2>/dev/null | sort | uniq -d)

if [ -n "$duplicates" ]; then
    echo -e "${YELLOW}   Duplicate file names found:${NC}"
    while IFS= read -r dup; do
        echo "   - $dup found in:"
        find "$LIB_DIR" -name "$dup" -exec echo "     {}" \;
    done <<< "$duplicates"
    issues_found=$((issues_found + 1))
else
    echo -e "${GREEN}   No duplicate file names${NC}"
fi
echo ""

# ============================================
# 2. Find potentially orphan files (not imported anywhere)
# ============================================
echo "2. Checking for orphan files (not imported)..."

orphan_count=0
orphan_list=""

# Get all dart files
while IFS= read -r file; do
    # Get just the filename without extension
    filename=$(basename "$file" .dart)

    # Skip some known patterns
    if [[ "$filename" == "main" ]] || \
       [[ "$filename" == *"_test" ]] || \
       [[ "$filename" == *".g" ]] || \
       [[ "$filename" == *".freezed" ]] || \
       [[ "$file" == *"/generated/"* ]] || \
       [[ "$file" == *"/l10n/"* ]]; then
        continue
    fi

    # Check if this file is imported anywhere
    if ! grep -rq "import.*$filename" "$LIB_DIR" --include="*.dart" 2>/dev/null; then
        # Double check it's not a barrel file or entry point
        if ! grep -q "^export " "$file" 2>/dev/null; then
            orphan_list+="   - $file\n"
            orphan_count=$((orphan_count + 1))
        fi
    fi
done < <(find "$LIB_DIR" -name "*.dart" -type f 2>/dev/null)

if [ $orphan_count -gt 0 ]; then
    echo -e "${YELLOW}   Potentially orphan files ($orphan_count):${NC}"
    echo -e "$orphan_list"
    issues_found=$((issues_found + 1))
else
    echo -e "${GREEN}   No orphan files detected${NC}"
fi
echo ""

# ============================================
# 3. Find stale/temp files
# ============================================
echo "3. Checking for stale/temp files..."

stale_files=$(find "$LIB_DIR" -name "*.dart" 2>/dev/null | grep -E "($STALE_PATTERNS)" || true)

if [ -n "$stale_files" ]; then
    echo -e "${YELLOW}   Potentially stale files:${NC}"
    while IFS= read -r file; do
        echo "   - $file"
    done <<< "$stale_files"
    issues_found=$((issues_found + 1))
else
    echo -e "${GREEN}   No stale files detected${NC}"
fi
echo ""

# ============================================
# 4. Find broken imports
# ============================================
echo "4. Checking for broken imports..."

broken_count=0

# Look for imports that don't resolve
while IFS= read -r file; do
    # Extract imports
    while IFS= read -r import_line; do
        # Get the import path
        import_path=$(echo "$import_line" | grep -oE "'[^']+'" | tr -d "'")

        # Skip package imports
        if [[ "$import_path" == package:* ]]; then
            continue
        fi

        # For relative imports, try to resolve
        if [[ "$import_path" == ../* ]] || [[ "$import_path" == ./* ]]; then
            dir=$(dirname "$file")
            resolved="$dir/$import_path"
            # Normalize the path
            if [ ! -f "$resolved" ]; then
                echo -e "${RED}   Broken import in $file:${NC}"
                echo "      $import_line"
                broken_count=$((broken_count + 1))
            fi
        fi
    done < <(grep "^import " "$file" 2>/dev/null || true)
done < <(find "$LIB_DIR" -name "*.dart" -type f 2>/dev/null | head -100)

if [ $broken_count -eq 0 ]; then
    echo -e "${GREEN}   No broken imports detected (checked first 100 files)${NC}"
else
    issues_found=$((issues_found + 1))
fi
echo ""

# ============================================
# 5. Summary
# ============================================
echo "=========================================="
if [ $issues_found -gt 0 ]; then
    echo -e "${YELLOW}   $issues_found potential issues found${NC}"
    echo "   Run /cleanup for detailed analysis"
else
    echo -e "${GREEN}   Codebase is healthy!${NC}"
fi
echo "=========================================="
echo ""

exit 0
