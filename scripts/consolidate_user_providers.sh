#!/bin/bash

# Script to consolidate user provider imports
# Replaces 5 duplicate provider imports with consolidated_user_provider.dart

set -e

echo "🔄 Consolidating User Provider Imports..."
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter
updated_count=0

# Find all files with old provider imports
files=$(grep -rl "import.*\(current_user_provider\|cached_user_provider\|unified_user_provider\|user_provider_v2\|user_profile_provider\)\.dart" lib/ 2>/dev/null || true)

if [ -z "$files" ]; then
    echo "✅ No files found with old provider imports"
    exit 0
fi

echo "📋 Files to update:"
echo "$files" | nl
echo ""

# Process each file
for file in $files; do
    echo "📝 Processing: $file"

    # Create backup
    cp "$file" "$file.bak"

    # Replace imports using sed (macOS compatible)
    sed -i '' \
        -e "s|import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider\.dart';|import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';|g" \
        -e "s|import 'package:gymbro_flutter_new/features/auth/presentation/providers/cached_user_provider\.dart';|import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';|g" \
        -e "s|import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider\.dart';|import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';|g" \
        -e "s|import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2\.dart';|import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';|g" \
        -e "s|import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider\.dart';|import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';|g" \
        "$file"

    # Check if file was actually modified
    if ! diff -q "$file" "$file.bak" > /dev/null 2>&1; then
        echo "   ✅ Updated"
        ((updated_count++))
    else
        echo "   ⏭️  Skipped (no changes needed)"
        rm "$file.bak" # Remove backup if no changes
    fi
done

echo ""
echo "${GREEN}✅ Import consolidation complete!${NC}"
echo "   📊 Files updated: $updated_count"
echo ""
echo "📦 Backup files created with .bak extension"
echo "   Remove backups: find lib -name '*.bak' -delete"
echo ""
echo "🧪 Next steps:"
echo "   1. Run: flutter analyze"
echo "   2. Test compilation"
echo "   3. Delete old provider files if all tests pass"
