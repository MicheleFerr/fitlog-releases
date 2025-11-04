#!/bin/bash

# Script to remove unused imports based on flutter analyze output
# Usage: ./scripts/remove_unused_imports.sh

set -e

echo "🧹 Starting unused imports cleanup..."

# Get all unused_import warnings
UNUSED_IMPORTS=$(flutter analyze 2>&1 | grep "unused_import" | grep -v "test/" || true)

if [ -z "$UNUSED_IMPORTS" ]; then
    echo "✅ No unused imports found!"
    exit 0
fi

# Count total
TOTAL=$(echo "$UNUSED_IMPORTS" | wc -l | tr -d ' ')
echo "📊 Found $TOTAL unused imports (excluding tests)"

# Extract unique files with unused imports
FILES=$(echo "$UNUSED_IMPORTS" | awk -F'•' '{print $2}' | awk -F':' '{print $1}' | sort -u | sed 's/^ *//')

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "📁 Affected files: $FILE_COUNT"

# Process each file
FIXED=0
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Get all unused imports for this file
        IMPORTS=$(echo "$UNUSED_IMPORTS" | grep "$file" | awk -F"'" '{print $2}')

        # Remove each unused import
        while IFS= read -r import; do
            if [ -n "$import" ]; then
                # Escape special characters for sed
                ESCAPED_IMPORT=$(echo "$import" | sed 's/[\/&]/\\&/g')

                # Remove the import line (handles both single and double quotes)
                sed -i '' "/^import ['\"]$ESCAPED_IMPORT['\"];$/d" "$file" 2>/dev/null || true

                ((FIXED++)) || true
            fi
        done <<< "$IMPORTS"

        echo "  ✅ Fixed: $file"
    fi
done <<< "$FILES"

echo ""
echo "✨ Cleanup complete!"
echo "   Fixed: $FIXED unused imports"
echo "   Files: $FILE_COUNT"
echo ""
echo "🔍 Run 'flutter analyze' to verify..."
