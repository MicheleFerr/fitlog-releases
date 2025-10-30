#!/bin/bash

# 🛡️ HiveBoxManager Enforcement Script
# Prevents direct Hive.openBox() calls from being committed
#
# Usage:
#   ./scripts/check_hive_box_manager.sh           # Check all files
#   ./scripts/check_hive_box_manager.sh --staged  # Check only staged files (for pre-commit)
#
# Exit codes:
#   0 - No violations found
#   1 - Violations found (blocks commit)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check mode
MODE="${1:-all}"

echo -e "${BLUE}🔍 Checking for direct Hive.openBox() calls...${NC}"
echo ""

# Function to search files
check_files() {
  local files="$1"

  # Search for violations
  # Pattern: Look for "Hive.openBox" or "await openBox" but exclude:
  # - hive_box_manager.dart (the implementation itself)
  # - Lines with boxManager.openBox or _boxManager.openBox (correct usage)
  # - Comment lines (starting with //, *, or inside /** */)

  VIOLATIONS=$(echo "$files" | while read -r file; do
    if [ -f "$file" ] && [[ "$file" == *.dart ]]; then
      # Skip hive_box_manager.dart and hive_box_manager_enhanced.dart (the implementations themselves)
      if [[ "$file" == *"hive_box_manager.dart" ]] || [[ "$file" == *"hive_box_manager_enhanced.dart" ]]; then
        continue
      fi

      # Skip integration documentation files (contain example code only)
      if [[ "$file" == */integration/* ]]; then
        continue
      fi

      # Search for violations (not in comments, not using boxManager)
      grep -n "Hive\.openBox\|await openBox" "$file" 2>/dev/null | \
        grep -v "^\s*//" | \
        grep -v "^\s*\*" | \
        grep -v "^\s*///" | \
        grep -v "boxManager\.openBox" | \
        grep -v "_boxManager\.openBox" | \
        grep -v "// .*Hive\.openBox" | \
        grep -v "/// .*Hive\.openBox" | \
        grep -v "Call Hive\.openBox" | \
        grep -v "No direct Hive\.openBox" | \
        sed "s|^|$file:|" || true
    fi
  done)

  echo "$VIOLATIONS"
}

# Get files to check based on mode
if [ "$MODE" = "--staged" ]; then
  echo -e "${BLUE}Mode: Checking staged files only${NC}"
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$" || true)
else
  echo -e "${BLUE}Mode: Checking all Dart files in lib/${NC}"
  FILES=$(find lib/ -name "*.dart" -type f)
fi

# Check for violations
VIOLATIONS=$(check_files "$FILES")

# Count violations (filter empty lines)
VIOLATION_COUNT=$(echo "$VIOLATIONS" | grep -c "Hive\.openBox\|await openBox" 2>/dev/null || echo "0")

# Clean up the count (remove any newlines/spaces)
VIOLATION_COUNT=$(echo "$VIOLATION_COUNT" | tr -d '\n\r ' | head -c 10)

# Default to 0 if empty or invalid
if [ -z "$VIOLATION_COUNT" ] || ! [[ "$VIOLATION_COUNT" =~ ^[0-9]+$ ]]; then
  VIOLATION_COUNT=0
fi

echo ""

# Report results
if [ "$VIOLATION_COUNT" -eq 0 ]; then
  echo -e "${GREEN}✅ SUCCESS: No direct Hive.openBox() calls found!${NC}"
  echo ""
  echo "All Hive operations are using centralized HiveBoxManager."
  exit 0
else
  echo -e "${RED}❌ ERROR: Found $VIOLATION_COUNT direct Hive.openBox() call(s)!${NC}"
  echo ""
  echo -e "${YELLOW}Violations:${NC}"
  echo "$VIOLATIONS" | while IFS= read -r line; do
    if [ -n "$line" ]; then
      echo -e "${RED}  $line${NC}"
    fi
  done
  echo ""
  echo -e "${YELLOW}📖 How to fix:${NC}"
  echo ""
  echo "  1. Import HiveBoxManager:"
  echo "     import 'package:gymbro_flutter_new/core/data/hive_box_manager.dart';"
  echo ""
  echo "  2. Use one of these patterns:"
  echo ""
  echo "     ${GREEN}a) Provider injection:${NC}"
  echo "        final boxManager = ref.watch(hiveBoxManagerProvider);"
  echo "        await boxManager.openBox('my_box');"
  echo ""
  echo "     ${GREEN}b) Constructor parameter:${NC}"
  echo "        MyService({HiveBoxManager? boxManager})"
  echo "            : _boxManager = boxManager ?? HiveBoxManager();"
  echo ""
  echo "     ${GREEN}c) Singleton with optional param:${NC}"
  echo "        Future<void> initialize({HiveBoxManager? boxManager}) async {"
  echo "          _boxManager = boxManager ?? HiveBoxManager();"
  echo "        }"
  echo ""
  echo -e "${YELLOW}📚 Documentation:${NC}"
  echo "  - Full guide: docs/TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_MIGRATION_REPORT.md"
  echo "  - Checklist: docs/TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_CHECKLIST.md"
  echo ""
  exit 1
fi
