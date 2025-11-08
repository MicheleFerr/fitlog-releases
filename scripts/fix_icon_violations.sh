#!/bin/bash

# 🎨 Icon Design System Auto-Fix Script
#
# Automatically replaces Icons.* with AppIcons.*
#
# Usage:
#   ./scripts/fix_icon_violations.sh                    # Dry-run (preview only)
#   ./scripts/fix_icon_violations.sh --apply            # Apply fixes
#   ./scripts/fix_icon_violations.sh --file path.dart   # Fix single file
#
# Safety Features:
#   - Dry-run by default (requires --apply to modify files)
#   - Only replaces icons that exist in AppIcons
#   - Reports missing icons for manual addition
#   - Preserves code formatting

set -e

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Flags
DRY_RUN=true
APPLY_FIXES=false
SINGLE_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --apply)
      DRY_RUN=false
      APPLY_FIXES=true
      shift
      ;;
    --file)
      SINGLE_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--apply] [--file path.dart]"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   🎨 Icon Design System Auto-Fix${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${CYAN}📋 Mode: DRY-RUN (preview only)${NC}"
  echo -e "${CYAN}   Use --apply to actually modify files${NC}"
else
  echo -e "${GREEN}🔧 Mode: APPLY FIXES${NC}"
fi
echo ""

# Get files to process
if [ ! -z "$SINGLE_FILE" ]; then
  if [ ! -f "$SINGLE_FILE" ]; then
    echo -e "${RED}❌ File not found: $SINGLE_FILE${NC}"
    exit 1
  fi
  FILES_TO_PROCESS="$SINGLE_FILE"
  echo -e "${CYAN}📂 Processing single file: $SINGLE_FILE${NC}"
else
  FILES_TO_PROCESS=$(find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/theme/app_icons.dart" | sort)
  TOTAL_FILES=$(echo "$FILES_TO_PROCESS" | wc -l | tr -d ' ')
  echo -e "${CYAN}📂 Processing $TOTAL_FILES Dart files...${NC}"
fi
echo ""

# Extract available AppIcons
echo -e "${BLUE}[1/3] Extracting available AppIcons...${NC}"
AVAILABLE_ICONS=$(grep "static const IconData" lib/shared/presentation/theme/app_icons.dart | awk '{print $4}' | sort)
ICON_COUNT=$(echo "$AVAILABLE_ICONS" | wc -l | tr -d ' ')
echo -e "${GREEN}   ✅ Found $ICON_COUNT icons in AppIcons${NC}"
echo ""

# No associative arrays needed - will use grep for lookup

# Temp files
TEMP_FIXES="/tmp/icon_fixes_$$.txt"
TEMP_MISSING="/tmp/missing_icons_$$.txt"
> "$TEMP_FIXES"
> "$TEMP_MISSING"

trap "rm -f $TEMP_FIXES $TEMP_MISSING" EXIT

echo -e "${BLUE}[2/3] Finding Icons.* violations...${NC}"
echo ""

TOTAL_FIXED=0
TOTAL_MISSING=0
FILES_MODIFIED=0

for file in $FILES_TO_PROCESS; do
  if [ ! -f "$file" ]; then
    continue
  fi

  FILE_CHANGED=false

  # Find all Icons.* usage (excluding Icons.adaptive, Icons.filled, etc., and AppIcons)
  while IFS=: read -r linenum content; do
    # Extract icon name from Icons.iconName pattern
    echo "$content" | grep -v "AppIcons\." | grep -oE 'Icons\.[a-zA-Z_]+' | while read -r match; do
      icon_name=$(echo "$match" | sed 's/Icons\.//')

      # Convert from snake_case/camelCase to match AppIcons naming
      # Icons.check_circle → checkCircle (AppIcons uses camelCase)
      icon_camel=$(echo "$icon_name" | perl -pe 's/_([a-z])/\U$1/g')

      # Check if icon exists in AppIcons (using grep)
      if echo "$AVAILABLE_ICONS" | grep -q "^${icon_camel}$"; then
        # Icon exists, prepare replacement
        echo "$file:$linenum: Icons.$icon_name → AppIcons.$icon_camel" >> "$TEMP_FIXES"

        if [ "$APPLY_FIXES" = true ]; then
          # Apply replacement with word boundary to avoid replacing AppIcons
          # BSD sed (macOS) uses [[:<:]] and [[:>:]] for word boundaries
          sed -i '' "s/[[:<:]]Icons\.$icon_name[[:>:]]/AppIcons.$icon_camel/g" "$file"
          FILE_CHANGED=true
        fi

        TOTAL_FIXED=$((TOTAL_FIXED + 1))
      else
        # Icon missing in AppIcons
        echo "$file:$linenum: Icons.$icon_name (missing in AppIcons)" >> "$TEMP_MISSING"
        TOTAL_MISSING=$((TOTAL_MISSING + 1))
      fi
    done
  done < <(grep -n "Icons\." "$file" 2>/dev/null | grep -v "Icons.adaptive" | grep -v "Icons.filled" | grep -v "Icons.outlined" | grep -v "Icons.rounded" | grep -v "Icons.sharp" || true)

  if [ "$FILE_CHANGED" = true ]; then
    FILES_MODIFIED=$((FILES_MODIFIED + 1))
  fi
done

echo -e "${BLUE}[3/3] Generating Report...${NC}"
echo ""

# Show preview of fixes in dry-run mode
if [ "$DRY_RUN" = true ] && [ -s "$TEMP_FIXES" ]; then
  echo -e "${GREEN}Fixes that would be applied:${NC}"
  echo ""
  head -n 20 "$TEMP_FIXES" | while IFS=: read -r file linenum change; do
    echo -e "   ${YELLOW}$file:$linenum${NC}"
    echo -e "      $change"
  done

  FIX_COUNT=$(wc -l < "$TEMP_FIXES" | tr -d ' ')
  if [ $FIX_COUNT -gt 20 ]; then
    echo -e "   ${YELLOW}... (showing first 20 of $FIX_COUNT)${NC}"
  fi
  echo ""
fi

# Show missing icons
if [ -s "$TEMP_MISSING" ]; then
  echo -e "${YELLOW}⚠️  Icons missing in AppIcons (need manual addition):${NC}"
  echo ""

  # Group by icon name
  cat "$TEMP_MISSING" | sed 's/.*Icons\.\([a-zA-Z_]*\).*/\1/' | sort -u | while read -r icon; do
    count=$(grep -c "Icons\.$icon" "$TEMP_MISSING")
    echo -e "   ${RED}Icons.$icon${NC} ($count occurrences)"
  done
  echo ""
fi

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📊 Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  # Count from temp files (more reliable than variables due to subshells)
  TOTAL_FIXED=$(wc -l < "$TEMP_FIXES" 2>/dev/null | tr -d ' ' || echo "0")
  TOTAL_MISSING=$(wc -l < "$TEMP_MISSING" 2>/dev/null | tr -d ' ' || echo "0")

  echo -e "${CYAN}Icons that would be fixed:     ${YELLOW}$TOTAL_FIXED${NC}"
  echo -e "${CYAN}Icons missing in AppIcons:     ${RED}$TOTAL_MISSING${NC}"
  echo -e "${CYAN}Files that would be modified:  ${YELLOW}~$FILES_MODIFIED${NC}"
  echo ""
  echo -e "${GREEN}✅ To apply these fixes, run:${NC}"
  echo -e "   ${YELLOW}./scripts/fix_icon_violations.sh --apply${NC}"
  echo ""
else
  echo -e "${GREEN}✅ Icons fixed:                 $TOTAL_FIXED${NC}"
  echo -e "${YELLOW}⚠️  Icons still missing:        $TOTAL_MISSING${NC}"
  echo -e "${GREEN}Files modified:                 $FILES_MODIFIED${NC}"
  echo ""

  if [ $TOTAL_MISSING -gt 0 ]; then
    echo -e "${YELLOW}💡 Next Steps:${NC}"
    echo -e "   1. Add missing icons to lib/shared/presentation/theme/app_icons.dart"
    echo -e "   2. Run this script again to fix remaining violations"
    echo ""
  else
    echo -e "${GREEN}✅ All Icons.* violations fixed!${NC}"
    echo ""
  fi
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

exit 0
