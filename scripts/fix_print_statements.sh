#!/bin/bash

# Script to replace print() with debugPrint() wrapped in kDebugMode
# Author: Claude
# Date: 2025-01-10

set -e

echo "🔧 Fixing print() statements in lib/ directory..."

# Counter for replaced files
TOTAL_FILES=0
TOTAL_REPLACEMENTS=0

# Find all Dart files in lib/ directory
find lib -name "*.dart" -type f | while read -r file; do
  # Skip files that already use debugPrint correctly
  if grep -q "print(" "$file"; then
    echo "📝 Processing: $file"

    # Count occurrences before replacement
    BEFORE=$(grep -c "print(" "$file" || echo "0")

    # Create temporary file
    TEMP_FILE="${file}.tmp"

    # Process the file line by line
    awk '
    BEGIN {
      in_debug_mode = 0
      indent = ""
    }
    {
      line = $0

      # Skip if already has kDebugMode check above
      if (prev_line ~ /if \(kDebugMode\)/) {
        print line
        prev_line = line
        next
      }

      # Skip if inside kDebugMode block already
      if (line ~ /if \(kDebugMode\)/) {
        in_debug_mode = 1
        print line
        prev_line = line
        next
      }

      if (in_debug_mode && line ~ /^\s*\}/) {
        in_debug_mode = 0
      }

      # Replace print( with debugPrint( and wrap with kDebugMode if not already wrapped
      if (line ~ /print\(/ && !in_debug_mode) {
        # Get indentation
        match(line, /^[[:space:]]*/)
        indent = substr(line, RSTART, RLENGTH)

        # Replace print with debugPrint
        gsub(/print\(/, "debugPrint(", line)

        # Wrap with kDebugMode check
        print indent "if (kDebugMode) {"
        print "  " line
        print indent "}"
      } else {
        # Just replace print with debugPrint without wrapping if already in kDebugMode
        if (line ~ /print\(/) {
          gsub(/print\(/, "debugPrint(", line)
        }
        print line
      }

      prev_line = line
    }
    ' "$file" > "$TEMP_FILE"

    # Check if file needs flutter/foundation.dart import
    if ! grep -q "import 'package:flutter/foundation.dart';" "$file" && grep -q "kDebugMode" "$TEMP_FILE"; then
      # Add import at the top (after existing imports)
      awk '
      BEGIN { import_added = 0 }
      {
        print
        if (!import_added && /^import / && !/^import.*foundation\.dart/) {
          # Check next line
          getline next_line
          if (next_line !~ /^import /) {
            print "import '\''package:flutter/foundation.dart'\'';"
            import_added = 1
          }
          print next_line
        }
      }
      ' "$TEMP_FILE" > "${TEMP_FILE}.2"
      mv "${TEMP_FILE}.2" "$TEMP_FILE"
    fi

    # Count occurrences after replacement
    AFTER=$(grep -c "print(" "$TEMP_FILE" || echo "0")
    REPLACED=$((BEFORE - AFTER))

    if [ $REPLACED -gt 0 ]; then
      # Move temp file to original
      mv "$TEMP_FILE" "$file"
      echo "   ✅ Replaced $REPLACED print() statements"
      TOTAL_FILES=$((TOTAL_FILES + 1))
      TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + REPLACED))
    else
      # Remove temp file if no changes
      rm -f "$TEMP_FILE"
    fi
  fi
done

echo ""
echo "✅ Done! Fixed $TOTAL_REPLACEMENTS print() statements in $TOTAL_FILES files"
echo ""
echo "🔍 Remaining print() statements (should be minimal):"
grep -r "print(" lib --include="*.dart" | wc -l
