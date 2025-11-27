#!/bin/bash

# Script to fix deprecated Flutter API usage
# Auto-generated for gymbro_flutter_new project

set -e

PROJECT_ROOT="/Users/michele/gymbro_flutter_new"
cd "$PROJECT_ROOT"

echo "🔧 Fixing Flutter API deprecations..."

# Counter for fixes
FIXED_FILES=0

# 1. Fix withOpacity → withValues(alpha:)
echo "📝 Fixing withOpacity deprecations..."
find lib -name "*.dart" -type f -exec grep -l "\.withOpacity(" {} \; | while read file; do
    # Replace .withOpacity(X) with .withValues(alpha: X)
    perl -i -pe 's/\.withOpacity\(([^)]+)\)/.withValues(alpha: $1)/g' "$file"
    echo "  ✓ $file"
    ((FIXED_FILES++))
done

# 2. Fix surfaceVariant → surfaceContainerHighest
echo "📝 Fixing surfaceVariant deprecations..."
find lib -name "*.dart" -type f -exec grep -l "\.surfaceVariant" {} \; | while read file; do
    perl -i -pe 's/\.surfaceVariant/.surfaceContainerHighest/g' "$file"
    echo "  ✓ $file"
    ((FIXED_FILES++))
done

# 3. Fix Color.red/green/blue accessors
echo "📝 Fixing Color component accessor deprecations..."
find lib -name "*.dart" -type f -exec grep -l "\.red\b\|\.green\b\|\.blue\b" {} \; | while read file; do
    # This is complex - needs manual review
    # .red → (*.r * 255.0).round() & 0xff
    # .green → (*.g * 255.0).round() & 0xff
    # .blue → (*.b * 255.0).round() & 0xff
    echo "  ⚠️  Manual fix needed: $file (Color.red/green/blue)"
done

# 4. Fix Color.value → toARGB32()
echo "📝 Fixing Color.value deprecations..."
find lib -name "*.dart" -type f -exec grep -l "\.value\b" {} \; | while read file; do
    # Check if it's Color.value (not all .value is Color)
    if grep -q "color.*\.value\|Color.*\.value" "$file"; then
        echo "  ⚠️  Manual fix needed: $file (Color.value → toARGB32())"
    fi
done

echo ""
echo "✅ Automated fixes completed!"
echo "📊 Files processed: $FIXED_FILES"
echo ""
echo "⚠️  Manual fixes still required for:"
echo "   - Radio widget groupValue/onChanged (requires RadioGroup wrapper)"
echo "   - Color component accessors (red/green/blue)"
echo "   - Speech recognition options (partialResults/cancelOnError)"
echo "   - InputSanitizer → InputValidator (test files)"
echo ""
echo "🔍 Run 'flutter analyze' to verify fixes..."
