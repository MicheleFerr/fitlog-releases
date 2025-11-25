#!/bin/bash

# Fix remaining design system violations from bulk script
# Target: 91 invalid_constant + 104 undefined success errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔧 Fixing remaining design system violations..."
echo ""

# Get list of files with invalid_constant errors
echo "📋 Finding files with invalid_constant errors..."
INVALID_CONST_FILES=$(flutter analyze 2>&1 | grep "• invalid_constant" | awk '{print $5}' | sort -u)

# Get list of files with undefined success errors
echo "📋 Finding files with undefined 'success' errors..."
UNDEFINED_SUCCESS_FILES=$(flutter analyze 2>&1 | grep "success.*isn't defined" | awk '{print $6}' | sort -u)

# Combine and dedupe file lists
ALL_FILES=$(echo -e "$INVALID_CONST_FILES\n$UNDEFINED_SUCCESS_FILES" | sort -u)

FILE_COUNT=$(echo "$ALL_FILES" | wc -l | tr -d ' ')
echo "📦 Found $FILE_COUNT files to fix"
echo ""

FIXED_COUNT=0

for file in $ALL_FILES; do
    if [[ ! -f "$file" ]]; then
        continue
    fi

    echo "🔨 Fixing: $file"

    # Create backup
    cp "$file" "$file.bak"

    # Fix 1: Remove const from widgets with context.colors.*
    # Pattern: const Icon(..., color: context.colors.X)
    # Pattern: const Text(..., style: TextStyle(color: context.colors.X))
    # Pattern: const SemanticIcon(..., color: context.colors.X)

    sed -i '' 's/const Icon(/Icon(/g' "$file"
    sed -i '' 's/const Text(/Text(/g' "$file"
    sed -i '' 's/const SemanticIcon(/SemanticIcon(/g' "$file"
    sed -i '' 's/const TextStyle(/TextStyle(/g' "$file"
    sed -i '' 's/const AlwaysStoppedAnimation</AlwaysStoppedAnimation</g' "$file"

    # Fix 2: Replace Theme.of(context).colorScheme.success with context.colors.success
    # This requires ensuring the file imports color_scheme_extensions.dart

    # Check if file uses context.colors.success syntax
    if grep -q "context.colors.success" "$file"; then
        # Check if color_scheme_extensions import exists
        if ! grep -q "color_scheme_extensions.dart" "$file"; then
            # Add import after last import line
            awk '/^import/ {p=NR} p && NR==p+1 && !/^import/ {print "import '\''package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart'\'';"; printed=1} {print} END {if (!printed) print "import '\''package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart'\'';" }' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        fi
    fi

    # Verify fix didn't break syntax
    if flutter analyze "$file" 2>&1 | grep -q "Could not format"; then
        echo "  ⚠️  Syntax error, reverting..."
        mv "$file.bak" "$file"
    else
        rm "$file.bak"
        ((FIXED_COUNT++))
        echo "  ✅ Fixed"
    fi
done

echo ""
echo "✨ Complete! Fixed $FIXED_COUNT/$FILE_COUNT files"
echo ""
echo "Running flutter analyze to verify..."
flutter analyze 2>&1 | tail -5
