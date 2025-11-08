#!/bin/bash

# 🔧 Design Violations Auto-Fix Script
#
# Automatically fixes spacing and border radius violations
# detected by audit_design_guidelines.sh
#
# Usage:
#   ./scripts/fix_design_violations.sh                    # Dry-run (preview only)
#   ./scripts/fix_design_violations.sh --apply            # Apply fixes
#   ./scripts/fix_design_violations.sh --file path.dart   # Fix single file
#   ./scripts/fix_design_violations.sh --rollback         # Restore from backup
#
# Safety Features:
#   - Dry-run by default (requires --apply to modify files)
#   - Automatic backup before modifications (.backup_design_fix/)
#   - Rollback capability
#   - Post-fix flutter analyze verification
#
# Fixes Applied:
#   1. Spacing System: Round EdgeInsets to nearest multiple of 4
#   2. Border Radius: Map to nearest standard value (8/12/16/20/24)

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=true
APPLY_FIXES=false
SINGLE_FILE=""
ROLLBACK=false
BACKUP_DIR=".backup_design_fix"

# Temporary files for tracking
TEMP_SPACING_LOG="/tmp/spacing_fixes_$$.txt"
TEMP_RADIUS_LOG="/tmp/radius_fixes_$$.txt"
TEMP_FILES_LOG="/tmp/files_modified_$$.txt"

# Cleanup temp files on exit
trap "rm -f $TEMP_SPACING_LOG $TEMP_RADIUS_LOG $TEMP_FILES_LOG" EXIT

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
    --rollback)
      ROLLBACK=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--apply] [--file path.dart] [--rollback]"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   🔧 Design Violations Auto-Fix${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================
# Rollback Mode
# ============================================
if [ "$ROLLBACK" = true ]; then
  if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ No backup found at $BACKUP_DIR${NC}"
    exit 1
  fi

  echo -e "${YELLOW}🔄 Restoring files from backup...${NC}"
  echo ""

  RESTORED=0
  while IFS= read -r backup_file; do
    original_file="${backup_file#$BACKUP_DIR/}"
    if [ -f "$backup_file" ]; then
      cp "$backup_file" "$original_file"
      RESTORED=$((RESTORED + 1))
      echo -e "   ✅ Restored: $original_file"
    fi
  done < <(find "$BACKUP_DIR" -type f -name "*.dart")

  echo ""
  echo -e "${GREEN}✅ Restored $RESTORED files from backup${NC}"
  echo -e "${YELLOW}💡 Backup preserved at: $BACKUP_DIR${NC}"
  echo ""
  exit 0
fi

# ============================================
# Mode Display
# ============================================
if [ "$DRY_RUN" = true ]; then
  echo -e "${CYAN}📋 Mode: DRY-RUN (preview only, no files modified)${NC}"
  echo -e "${CYAN}   Use --apply to actually modify files${NC}"
else
  echo -e "${GREEN}🔧 Mode: APPLY FIXES (files will be modified)${NC}"
  echo -e "${YELLOW}   Backups will be saved to: $BACKUP_DIR${NC}"
fi
echo ""

# ============================================
# Get Files to Process
# ============================================
if [ ! -z "$SINGLE_FILE" ]; then
  if [ ! -f "$SINGLE_FILE" ]; then
    echo -e "${RED}❌ File not found: $SINGLE_FILE${NC}"
    exit 1
  fi
  FILES_TO_PROCESS="$SINGLE_FILE"
  echo -e "${CYAN}📂 Processing single file: $SINGLE_FILE${NC}"
else
  FILES_TO_PROCESS=$(find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/theme/*" | sort)
  TOTAL_FILES=$(echo "$FILES_TO_PROCESS" | wc -l | tr -d ' ')
  echo -e "${CYAN}📂 Processing $TOTAL_FILES Dart files...${NC}"
fi
echo ""

# ============================================
# Helper Functions
# ============================================

# Round to nearest multiple of 4
round_to_multiple_of_4() {
  local num=$1
  local remainder=$((num % 4))

  if [ $remainder -eq 0 ]; then
    echo $num
  elif [ $remainder -le 2 ]; then
    echo $((num - remainder))
  else
    echo $((num + (4 - remainder)))
  fi
}

# Map to nearest standard border radius
map_to_standard_radius() {
  local num=$1
  local standards=(8 12 16 20 24)
  local closest=8
  local min_diff=999

  for standard in "${standards[@]}"; do
    diff=$((num > standard ? num - standard : standard - num))
    if [ $diff -lt $min_diff ]; then
      min_diff=$diff
      closest=$standard
    fi
  done

  echo $closest
}

# Backup file before modification
backup_file() {
  local file=$1

  if [ "$APPLY_FIXES" = true ]; then
    local backup_path="$BACKUP_DIR/$file"
    local backup_dir=$(dirname "$backup_path")

    mkdir -p "$backup_dir"
    cp "$file" "$backup_path"
  fi
}

# ============================================
# Main Processing Loop
# ============================================

echo -e "${BLUE}[1/2] Fixing Spacing System Violations...${NC}"
echo ""

# Initialize temp logs
> "$TEMP_SPACING_LOG"
> "$TEMP_RADIUS_LOG"
> "$TEMP_FILES_LOG"

for file in $FILES_TO_PROCESS; do
  # Skip if file doesn't exist
  if [ ! -f "$file" ]; then
    continue
  fi

  FILE_MODIFIED=false
  TEMP_FILE="${file}.tmp"
  cp "$file" "$TEMP_FILE"

  # ============================================
  # Fix Spacing Violations - EdgeInsets.all(N)
  # ============================================
  while IFS=: read -r linenum content; do
    # Extract all numbers from EdgeInsets.all()
    echo "$content" | grep -oE 'EdgeInsets\.all\([0-9]+\)' | while read -r match; do
      num=$(echo "$match" | grep -oE '[0-9]+')

      # Check if not multiple of 4
      if [ $((num % 4)) -ne 0 ] && [ $num -gt 0 ]; then
        rounded=$(round_to_multiple_of_4 $num)

        if [ $num -ne $rounded ]; then
          # Log this fix
          echo "$file:$linenum: EdgeInsets.all($num) → EdgeInsets.all($rounded)" >> "$TEMP_SPACING_LOG"

          # Apply fix to temp file
          sed -i '' "s/EdgeInsets\.all($num)/EdgeInsets.all($rounded)/g" "$TEMP_FILE"
          FILE_MODIFIED=true
        fi
      fi
    done
  done < <(grep -n "EdgeInsets\.all" "$file" 2>/dev/null || true)

  # ============================================
  # Fix Spacing Violations - EdgeInsets.symmetric
  # ============================================
  while IFS=: read -r linenum content; do
    # Check horizontal values
    echo "$content" | grep -oE 'horizontal:\s*[0-9]+' | while read -r match; do
      num=$(echo "$match" | grep -oE '[0-9]+')

      if [ $((num % 4)) -ne 0 ] && [ $num -gt 0 ]; then
        rounded=$(round_to_multiple_of_4 $num)

        if [ $num -ne $rounded ]; then
          echo "$file:$linenum: horizontal: $num → horizontal: $rounded" >> "$TEMP_SPACING_LOG"
          sed -i '' "s/horizontal:\s*$num/horizontal: $rounded/g" "$TEMP_FILE"
          FILE_MODIFIED=true
        fi
      fi
    done

    # Check vertical values
    echo "$content" | grep -oE 'vertical:\s*[0-9]+' | while read -r match; do
      num=$(echo "$match" | grep -oE '[0-9]+')

      if [ $((num % 4)) -ne 0 ] && [ $num -gt 0 ]; then
        rounded=$(round_to_multiple_of_4 $num)

        if [ $num -ne $rounded ]; then
          echo "$file:$linenum: vertical: $num → vertical: $rounded" >> "$TEMP_SPACING_LOG"
          sed -i '' "s/vertical:\s*$num/vertical: $rounded/g" "$TEMP_FILE"
          FILE_MODIFIED=true
        fi
      fi
    done
  done < <(grep -n "EdgeInsets\.symmetric" "$file" 2>/dev/null || true)

  # ============================================
  # Fix Spacing Violations - EdgeInsets.only
  # ============================================
  while IFS=: read -r linenum content; do
    for direction in top bottom left right; do
      echo "$content" | grep -oE "${direction}:\s*[0-9]+" | while read -r match; do
        num=$(echo "$match" | grep -oE '[0-9]+')

        if [ $((num % 4)) -ne 0 ] && [ $num -gt 0 ]; then
          rounded=$(round_to_multiple_of_4 $num)

          if [ $num -ne $rounded ]; then
            echo "$file:$linenum: $direction: $num → $direction: $rounded" >> "$TEMP_SPACING_LOG"
            sed -i '' "s/${direction}:\s*${num}/${direction}: ${rounded}/g" "$TEMP_FILE"
            FILE_MODIFIED=true
          fi
        fi
      done
    done
  done < <(grep -n "EdgeInsets\.only" "$file" 2>/dev/null || true)

  # ============================================
  # Apply spacing changes if file was modified
  # ============================================
  # Check if temp file differs from original (more reliable than FILE_MODIFIED flag)
  if ! cmp -s "$file" "$TEMP_FILE"; then
    echo "$file" >> "$TEMP_FILES_LOG"  # Log regardless of mode
    if [ "$APPLY_FIXES" = true ]; then
      backup_file "$file"
      mv "$TEMP_FILE" "$file"
    else
      rm -f "$TEMP_FILE"
    fi
  else
    rm -f "$TEMP_FILE"
  fi
done

# Show spacing fixes in dry-run mode
if [ "$DRY_RUN" = true ] && [ -s "$TEMP_SPACING_LOG" ]; then
  head -n 20 "$TEMP_SPACING_LOG" | while IFS=: read -r file linenum change; do
    echo -e "   ${YELLOW}$file:$linenum${NC}"
    echo -e "      - $change"
  done

  SPACING_COUNT=$(wc -l < "$TEMP_SPACING_LOG" | tr -d ' ')
  if [ $SPACING_COUNT -gt 20 ]; then
    echo -e "   ${YELLOW}... (showing first 20 of $SPACING_COUNT)${NC}"
  fi
  echo ""
fi

echo -e "${BLUE}[2/2] Fixing Border Radius Violations...${NC}"
echo ""

for file in $FILES_TO_PROCESS; do
  if [ ! -f "$file" ]; then
    continue
  fi

  FILE_MODIFIED=false
  TEMP_FILE="${file}.tmp"
  cp "$file" "$TEMP_FILE"

  # ============================================
  # Fix Border Radius Violations
  # ============================================
  while IFS=: read -r linenum content; do
    echo "$content" | grep -oE 'BorderRadius\.circular\([0-9]+\)' | while read -r match; do
      num=$(echo "$match" | grep -oE '[0-9]+')

      # Check if not in standard list
      if [[ ! " 8 12 16 20 24 " =~ " $num " ]]; then
        standard=$(map_to_standard_radius $num)

        if [ $num -ne $standard ]; then
          echo "$file:$linenum: BorderRadius.circular($num) → BorderRadius.circular($standard)" >> "$TEMP_RADIUS_LOG"
          sed -i '' "s/BorderRadius\.circular($num)/BorderRadius.circular($standard)/g" "$TEMP_FILE"
          FILE_MODIFIED=true
        fi
      fi
    done
  done < <(grep -n "BorderRadius\.circular" "$file" 2>/dev/null || true)

  # ============================================
  # Apply radius changes if file was modified
  # ============================================
  # Check if temp file differs from original
  if ! cmp -s "$file" "$TEMP_FILE"; then
    echo "$file" >> "$TEMP_FILES_LOG"  # Log regardless of mode
    if [ "$APPLY_FIXES" = true ]; then
      backup_file "$file"
      mv "$TEMP_FILE" "$file"
    else
      rm -f "$TEMP_FILE"
    fi
  else
    rm -f "$TEMP_FILE"
  fi
done

# Show radius fixes in dry-run mode
if [ "$DRY_RUN" = true ] && [ -s "$TEMP_RADIUS_LOG" ]; then
  head -n 20 "$TEMP_RADIUS_LOG" | while IFS=: read -r file linenum change; do
    echo -e "   ${YELLOW}$file:$linenum${NC}"
    echo -e "      - $change"
  done

  RADIUS_COUNT=$(wc -l < "$TEMP_RADIUS_LOG" | tr -d ' ')
  if [ $RADIUS_COUNT -gt 20 ]; then
    echo -e "   ${YELLOW}... (showing first 20 of $RADIUS_COUNT)${NC}"
  fi
  echo ""
fi

# ============================================
# Summary Report
# ============================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📊 Auto-Fix Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Count from log files
SPACING_FIXED=$(wc -l < "$TEMP_SPACING_LOG" 2>/dev/null | tr -d ' ' || echo "0")
RADIUS_FIXED=$(wc -l < "$TEMP_RADIUS_LOG" 2>/dev/null | tr -d ' ' || echo "0")
FILES_MODIFIED=$(sort -u "$TEMP_FILES_LOG" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
TOTAL_FIXED=$((SPACING_FIXED + RADIUS_FIXED))

if [ "$DRY_RUN" = true ]; then
  echo -e "${CYAN}🔍 DRY-RUN PREVIEW:${NC}"
  echo ""
  echo -e "${CYAN}Violations that would be fixed:${NC}"
  echo -e "   • Spacing System:     ${YELLOW}$SPACING_FIXED${NC}"
  echo -e "   • Border Radius:      ${YELLOW}$RADIUS_FIXED${NC}"
  echo -e "   ${CYAN}────────────────────────${NC}"
  echo -e "   ${MAGENTA}TOTAL:                 $TOTAL_FIXED${NC}"
  echo ""
  echo -e "${CYAN}Files that would be modified: ${YELLOW}$FILES_MODIFIED${NC}"
  echo ""
  echo -e "${GREEN}✅ To apply these fixes, run:${NC}"
  echo -e "   ${YELLOW}./scripts/fix_design_violations.sh --apply${NC}"
  echo ""
else
  echo -e "${GREEN}✅ FIXES APPLIED:${NC}"
  echo ""
  echo -e "${GREEN}Violations fixed:${NC}"
  echo -e "   • Spacing System:     ${GREEN}$SPACING_FIXED${NC}"
  echo -e "   • Border Radius:      ${GREEN}$RADIUS_FIXED${NC}"
  echo -e "   ${CYAN}────────────────────────${NC}"
  echo -e "   ${MAGENTA}TOTAL:                 $TOTAL_FIXED${NC}"
  echo ""
  echo -e "${GREEN}Files modified: ${MAGENTA}$FILES_MODIFIED${NC}"
  echo -e "${GREEN}Backup saved to: ${CYAN}$BACKUP_DIR${NC}"
  echo ""

  # ============================================
  # Verification with flutter analyze
  # ============================================
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}   🔍 Running flutter analyze for verification...${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""

  if flutter analyze --no-pub > /tmp/analyze_output.txt 2>&1; then
    echo -e "${GREEN}✅ flutter analyze passed - no errors introduced!${NC}"
  else
    echo -e "${RED}⚠️  flutter analyze found issues:${NC}"
    echo ""
    cat /tmp/analyze_output.txt | head -n 20
    echo ""
    echo -e "${YELLOW}💡 If these are unrelated to the fixes, they existed before.${NC}"
    echo -e "${YELLOW}   To rollback fixes: ./scripts/fix_design_violations.sh --rollback${NC}"
  fi
  echo ""

  # ============================================
  # Next Steps
  # ============================================
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}   💡 Next Steps${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${CYAN}1. Review Changes:${NC}"
  echo -e "   git diff"
  echo ""
  echo -e "${CYAN}2. Test App:${NC}"
  echo -e "   flutter run (verify UI looks correct)"
  echo ""
  echo -e "${CYAN}3. If Everything Looks Good:${NC}"
  echo -e "   git add ."
  echo -e "   git commit -m \"style: auto-fix spacing and border radius violations\""
  echo -e "   rm -rf $BACKUP_DIR"
  echo ""
  echo -e "${CYAN}4. If Issues Found:${NC}"
  echo -e "   ./scripts/fix_design_violations.sh --rollback"
  echo ""
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

exit 0
