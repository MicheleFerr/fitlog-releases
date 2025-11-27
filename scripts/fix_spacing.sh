#!/bin/bash

# 🎨 AppSpacing Auto-Fix Script
#
# Converte automaticamente hardcoded EdgeInsets e BorderRadius values
# in AppSpacing.* constants.
#
# Usage:
#   ./scripts/fix_spacing.sh [--dry-run] [--file path/to/file.dart]
#
# Options:
#   --dry-run    Show what would be changed without modifying files
#   --file       Fix a specific file only
#   --staged     Fix only staged files
#   --all        Fix all Dart files in lib/
#
# Mapping:
#   4  → AppSpacing.xxs
#   8  → AppSpacing.xs
#   12 → AppSpacing.sm
#   16 → AppSpacing.md
#   20 → AppSpacing.lg
#   24 → AppSpacing.xl
#   32 → AppSpacing.xxl
#   48 → AppSpacing.xxxl

set -e

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=0
TARGET_FILE=""
STAGED_ONLY=0
ALL_FILES=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --file)
      TARGET_FILE="$2"
      shift 2
      ;;
    --staged)
      STAGED_ONLY=1
      shift
      ;;
    --all)
      ALL_FILES=1
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Usage: ./scripts/fix_spacing.sh [--dry-run] [--file path] [--staged] [--all]"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${BLUE}🎨 AppSpacing Auto-Fix${NC}"
echo ""

# Get files to process
if [ ! -z "$TARGET_FILE" ]; then
  FILES="$TARGET_FILE"
elif [ $STAGED_ONLY -eq 1 ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$" | grep "^lib/" || true)
elif [ $ALL_FILES -eq 1 ]; then
  FILES=$(find lib -name "*.dart" -type f | grep -v "generated/" | grep -v ".g.dart" | grep -v "theme/app_spacing.dart")
else
  echo -e "${YELLOW}Usage: ./scripts/fix_spacing.sh [--dry-run] [--file path] [--staged] [--all]${NC}"
  echo ""
  echo "Options:"
  echo "  --dry-run    Show changes without modifying files"
  echo "  --file       Fix a specific file"
  echo "  --staged     Fix only staged files"
  echo "  --all        Fix all Dart files in lib/"
  exit 0
fi

if [ -z "$FILES" ]; then
  echo -e "${GREEN}No files to process${NC}"
  exit 0
fi

TOTAL_FIXES=0
FILES_MODIFIED=0

# Process each file
for file in $FILES; do
  if [ ! -f "$file" ]; then
    continue
  fi

  # Skip generated and theme files
  if [[ "$file" == *"generated/"* ]] || [[ "$file" == *".g.dart"* ]] || [[ "$file" == *"app_spacing.dart"* ]] || [[ "$file" == *"app_theme.dart"* ]]; then
    continue
  fi

  FILE_FIXES=0
  TEMP_FILE=$(mktemp)
  cp "$file" "$TEMP_FILE"

  # Check if file already imports AppSpacing
  HAS_IMPORT=$(grep -c "import.*app_spacing.dart" "$file" || true)
  NEEDS_IMPORT=0

  # ============================================
  # Fix EdgeInsets.all(N)
  # ============================================

  # EdgeInsets.all(4) → EdgeInsets.all(AppSpacing.xxs)
  if grep -q "EdgeInsets\.all(4)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(4)/EdgeInsets.all(AppSpacing.xxs)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.xxs)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(8) → EdgeInsets.all(AppSpacing.xs)
  if grep -q "EdgeInsets\.all(8)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(8)/EdgeInsets.all(AppSpacing.xs)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.xs)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(12) → EdgeInsets.all(AppSpacing.sm)
  if grep -q "EdgeInsets\.all(12)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(12)/EdgeInsets.all(AppSpacing.sm)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.sm)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(16) → EdgeInsets.all(AppSpacing.md)
  if grep -q "EdgeInsets\.all(16)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(16)/EdgeInsets.all(AppSpacing.md)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.md)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(20) → EdgeInsets.all(AppSpacing.lg)
  if grep -q "EdgeInsets\.all(20)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(20)/EdgeInsets.all(AppSpacing.lg)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.lg)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(24) → EdgeInsets.all(AppSpacing.xl)
  if grep -q "EdgeInsets\.all(24)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(24)/EdgeInsets.all(AppSpacing.xl)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.xl)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # EdgeInsets.all(32) → EdgeInsets.all(AppSpacing.xxl)
  if grep -q "EdgeInsets\.all(32)" "$TEMP_FILE"; then
    sed -i '' 's/EdgeInsets\.all(32)/EdgeInsets.all(AppSpacing.xxl)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + $(grep -c "EdgeInsets\.all(AppSpacing\.xxl)" "$TEMP_FILE" || echo 0)))
    NEEDS_IMPORT=1
  fi

  # ============================================
  # Fix EdgeInsets.symmetric horizontal
  # ============================================

  # horizontal: 8 → horizontal: AppSpacing.xs
  if grep -q "horizontal: 8" "$TEMP_FILE"; then
    sed -i '' 's/horizontal: 8/horizontal: AppSpacing.xs/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # horizontal: 12 → horizontal: AppSpacing.sm
  if grep -q "horizontal: 12" "$TEMP_FILE"; then
    sed -i '' 's/horizontal: 12/horizontal: AppSpacing.sm/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # horizontal: 16 → horizontal: AppSpacing.md
  if grep -q "horizontal: 16" "$TEMP_FILE"; then
    sed -i '' 's/horizontal: 16/horizontal: AppSpacing.md/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # horizontal: 20 → horizontal: AppSpacing.lg
  if grep -q "horizontal: 20" "$TEMP_FILE"; then
    sed -i '' 's/horizontal: 20/horizontal: AppSpacing.lg/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # horizontal: 24 → horizontal: AppSpacing.xl
  if grep -q "horizontal: 24" "$TEMP_FILE"; then
    sed -i '' 's/horizontal: 24/horizontal: AppSpacing.xl/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # ============================================
  # Fix EdgeInsets.symmetric vertical
  # ============================================

  # vertical: 8 → vertical: AppSpacing.xs
  if grep -q "vertical: 8" "$TEMP_FILE"; then
    sed -i '' 's/vertical: 8/vertical: AppSpacing.xs/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # vertical: 12 → vertical: AppSpacing.sm
  if grep -q "vertical: 12" "$TEMP_FILE"; then
    sed -i '' 's/vertical: 12/vertical: AppSpacing.sm/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # vertical: 16 → vertical: AppSpacing.md
  if grep -q "vertical: 16" "$TEMP_FILE"; then
    sed -i '' 's/vertical: 16/vertical: AppSpacing.md/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # vertical: 24 → vertical: AppSpacing.xl
  if grep -q "vertical: 24" "$TEMP_FILE"; then
    sed -i '' 's/vertical: 24/vertical: AppSpacing.xl/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # ============================================
  # Fix EdgeInsets.only (left, right, top, bottom)
  # ============================================

  for direction in left right top bottom; do
    # 8
    if grep -q "$direction: 8" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 8/$direction: AppSpacing.xs/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
    # 12
    if grep -q "$direction: 12" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 12/$direction: AppSpacing.sm/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
    # 16
    if grep -q "$direction: 16" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 16/$direction: AppSpacing.md/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
    # 20
    if grep -q "$direction: 20" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 20/$direction: AppSpacing.lg/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
    # 24
    if grep -q "$direction: 24" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 24/$direction: AppSpacing.xl/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
    # 32
    if grep -q "$direction: 32" "$TEMP_FILE"; then
      sed -i '' "s/$direction: 32/$direction: AppSpacing.xxl/g" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
      NEEDS_IMPORT=1
    fi
  done

  # ============================================
  # Fix SizedBox height/width
  # ============================================

  # SizedBox(height: 8) → SizedBox(height: AppSpacing.xs)
  if grep -q "SizedBox(height: 8)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(height: 8)/SizedBox(height: AppSpacing.xs)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # SizedBox(height: 12) → SizedBox(height: AppSpacing.sm)
  if grep -q "SizedBox(height: 12)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(height: 12)/SizedBox(height: AppSpacing.sm)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # SizedBox(height: 16) → SizedBox(height: AppSpacing.md)
  if grep -q "SizedBox(height: 16)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(height: 16)/SizedBox(height: AppSpacing.md)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # SizedBox(height: 24) → SizedBox(height: AppSpacing.xl)
  if grep -q "SizedBox(height: 24)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(height: 24)/SizedBox(height: AppSpacing.xl)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # SizedBox(height: 32) → SizedBox(height: AppSpacing.xxl)
  if grep -q "SizedBox(height: 32)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(height: 32)/SizedBox(height: AppSpacing.xxl)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # SizedBox(width: ...) same patterns
  if grep -q "SizedBox(width: 8)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(width: 8)/SizedBox(width: AppSpacing.xs)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  if grep -q "SizedBox(width: 12)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(width: 12)/SizedBox(width: AppSpacing.sm)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  if grep -q "SizedBox(width: 16)" "$TEMP_FILE"; then
    sed -i '' 's/SizedBox(width: 16)/SizedBox(width: AppSpacing.md)/g' "$TEMP_FILE"
    FILE_FIXES=$((FILE_FIXES + 1))
    NEEDS_IMPORT=1
  fi

  # ============================================
  # Add import if needed
  # ============================================

  if [ $NEEDS_IMPORT -eq 1 ] && [ $HAS_IMPORT -eq 0 ]; then
    # Add import after last import statement
    # Find last import line number
    LAST_IMPORT_LINE=$(grep -n "^import " "$TEMP_FILE" | tail -1 | cut -d: -f1)

    if [ ! -z "$LAST_IMPORT_LINE" ]; then
      # Insert AppSpacing import after last import
      sed -i '' "${LAST_IMPORT_LINE}a\\
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
" "$TEMP_FILE"
      FILE_FIXES=$((FILE_FIXES + 1))
    fi
  fi

  # ============================================
  # Apply changes
  # ============================================

  if [ $FILE_FIXES -gt 0 ]; then
    FILES_MODIFIED=$((FILES_MODIFIED + 1))
    TOTAL_FIXES=$((TOTAL_FIXES + FILE_FIXES))

    if [ $DRY_RUN -eq 1 ]; then
      echo -e "${YELLOW}Would fix: $file ($FILE_FIXES changes)${NC}"
      diff "$file" "$TEMP_FILE" | head -20 || true
    else
      cp "$TEMP_FILE" "$file"
      echo -e "${GREEN}Fixed: $file ($FILE_FIXES changes)${NC}"
    fi
  fi

  rm "$TEMP_FILE"
done

echo ""
if [ $DRY_RUN -eq 1 ]; then
  echo -e "${BLUE}Dry run complete: $TOTAL_FIXES potential fixes in $FILES_MODIFIED files${NC}"
else
  echo -e "${GREEN}Complete: $TOTAL_FIXES fixes applied in $FILES_MODIFIED files${NC}"
fi
echo ""
