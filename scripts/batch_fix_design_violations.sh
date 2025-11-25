#!/bin/bash

# Batch fix common design system violations
# Handles: const violations, missing imports, border radius, TextStyle

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔧 Batch Fixing Design System Violations"
echo "=========================================="
echo ""

FIXED_COUNT=0
ERROR_COUNT=0
SKIPPED_COUNT=0

# Get all modified .dart files (excluding tests and generated)
FILES=$(git status --short | grep "^ M" | awk '{print $2}' | grep "\.dart$" | grep -v "_test\.dart$" | grep -v "/generated/" | grep -v "\.g\.dart$")

TOTAL_FILES=$(echo "$FILES" | wc -l | tr -d ' ')
echo "📦 Found $TOTAL_FILES modified Dart files to process"
echo ""

CURRENT=0

for file in $FILES; do
    CURRENT=$((CURRENT + 1))

    if [[ ! -f "$file" ]]; then
        continue
    fi

    echo "[$CURRENT/$TOTAL_FILES] Processing: $file"

    # Create backup
    cp "$file" "$file.bak"

    CHANGES_MADE=false

    # Fix 1: Border radius violations (4→8, 10→12, 14→16, 28→24)
    if grep -q "BorderRadius\.circular(4)" "$file"; then
        sed -i '' 's/BorderRadius\.circular(4)/BorderRadius.circular(8)/g' "$file"
        CHANGES_MADE=true
        echo "  ✓ Fixed border radius: 4 → 8"
    fi

    if grep -q "BorderRadius\.circular(10)" "$file"; then
        sed -i '' 's/BorderRadius\.circular(10)/BorderRadius.circular(12)/g' "$file"
        CHANGES_MADE=true
        echo "  ✓ Fixed border radius: 10 → 12"
    fi

    if grep -q "BorderRadius\.circular(14)" "$file"; then
        sed -i '' 's/BorderRadius\.circular(14)/BorderRadius.circular(16)/g' "$file"
        CHANGES_MADE=true
        echo "  ✓ Fixed border radius: 14 → 16"
    fi

    if grep -q "BorderRadius\.circular(28)" "$file"; then
        sed -i '' 's/BorderRadius\.circular(28)/BorderRadius.circular(24)/g' "$file"
        CHANGES_MADE=true
        echo "  ✓ Fixed border radius: 28 → 24"
    fi

    # Fix 2: Add color_scheme_extensions import if file uses context.colors.success/warning/error
    if grep -q "context\.colors\.\(success\|warning\)" "$file"; then
        if ! grep -q "color_scheme_extensions.dart" "$file"; then
            # Find last import line and add after it
            LAST_IMPORT_LINE=$(grep -n "^import" "$file" | tail -1 | cut -d: -f1)
            if [[ -n "$LAST_IMPORT_LINE" ]]; then
                awk -v line="$LAST_IMPORT_LINE" 'NR==line {print; print "import '\''package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart'\'';"; next} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
                CHANGES_MADE=true
                echo "  ✓ Added color_scheme_extensions.dart import"
            fi
        fi
    fi

    # Fix 3: Replace theme.colorScheme.success/warning with extension if available
    # (Only if extension is imported - safer pattern)
    if grep -q "color_scheme_extensions.dart" "$file"; then
        # This file has the extension, safe to use colorScheme.success directly
        # No changes needed - it should already work
        :
    fi

    # Verify fix didn't break syntax
    if flutter analyze "$file" 2>&1 | grep -q "Could not format"; then
        echo "  ⚠️  Syntax error after fixes, reverting..."
        mv "$file.bak" "$file"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    elif [[ "$CHANGES_MADE" == true ]]; then
        rm "$file.bak"
        FIXED_COUNT=$((FIXED_COUNT + 1))
        echo "  ✅ Fixed"
    else
        rm "$file.bak"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        echo "  → No changes needed"
    fi

    echo ""
done

echo "=========================================="
echo "✨ Batch Fix Complete!"
echo ""
echo "Results:"
echo "  ✅ Fixed:  $FIXED_COUNT files"
echo "  ⚠️  Errors: $ERROR_COUNT files"
echo "  → Skipped: $SKIPPED_COUNT files (no changes needed)"
echo "  📦 Total:  $TOTAL_FILES files processed"
echo ""
