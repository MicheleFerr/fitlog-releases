#!/bin/bash

# Add AppIcons import to all files using AppIcons
# Usage: ./scripts/add_appicons_import.sh

IMPORT="import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';"

echo "🔧 Adding AppIcons import to files..."

# Find all files using AppIcons without the import
grep -rl "AppIcons\." lib/ --include="*.dart" | while read file; do
  if ! grep -q "import.*app_icons.dart" "$file"; then
    echo "  Fixing: $file"

    # Find the last import line and add AppIcons import after it
    # Use awk to insert after the last import
    awk -v import="$IMPORT" '
      /^import / { last_import = NR }
      { lines[NR] = $0 }
      END {
        for (i = 1; i <= NR; i++) {
          print lines[i]
          if (i == last_import) {
            print import
          }
        }
      }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
done

echo "✅ AppIcons import added to all files!"
