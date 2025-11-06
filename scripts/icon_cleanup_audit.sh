#!/bin/bash

# 🧹 Icon Cleanup Audit Script
# Generates detailed report of rare Material Icons usage
# Author: Claude Code
# Date: 2025-11-01

set -e

PROJECT_ROOT="/Users/michele/gymbro_flutter_new"
OUTPUT_DIR="/tmp/icon_cleanup_audit"

cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧹 GymBro - Icon Cleanup Audit${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. ICON USAGE STATISTICS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}[1/5]${NC} Generating icon usage statistics..."

grep -rh "Icons\." lib/ --include="*.dart" | \
  grep -o "Icons\.[a-z_]*" | \
  sort | uniq -c | \
  sort -rn > "$OUTPUT_DIR/all_icons_usage.txt"

TOTAL_ICONS=$(wc -l < "$OUTPUT_DIR/all_icons_usage.txt" | tr -d ' ')
TOTAL_USES=$(awk '{sum += $1} END {print sum}' "$OUTPUT_DIR/all_icons_usage.txt")

echo -e "  ${YELLOW}Total unique icons:${NC} $TOTAL_ICONS"
echo -e "  ${YELLOW}Total icon uses:${NC} $TOTAL_USES"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. RARE ICONS (≤2 USES)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}[2/5]${NC} Finding rare icons (≤2 uses)..."

awk '$1 <= 2' "$OUTPUT_DIR/all_icons_usage.txt" > "$OUTPUT_DIR/rare_icons.txt"

RARE_COUNT=$(wc -l < "$OUTPUT_DIR/rare_icons.txt" | tr -d ' ')
RARE_PERCENT=$(awk -v rare="$RARE_COUNT" -v total="$TOTAL_ICONS" 'BEGIN {printf "%.1f", (rare/total)*100}')

echo -e "  ${YELLOW}Rare icons found:${NC} $RARE_COUNT ($RARE_PERCENT% of total)"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. SINGLE-USE ICONS (HIGHEST PRIORITY)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}[3/5]${NC} Analyzing single-use icons (1 use only)..."

awk '$1 == 1' "$OUTPUT_DIR/all_icons_usage.txt" > "$OUTPUT_DIR/single_use_icons.txt"

SINGLE_COUNT=$(wc -l < "$OUTPUT_DIR/single_use_icons.txt" | tr -d ' ')

echo -e "  ${YELLOW}Single-use icons:${NC} $SINGLE_COUNT"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. DETAILED AUDIT WITH FILE LOCATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}[4/5]${NC} Generating detailed audit report with file locations..."
echo -e "  ${YELLOW}(This may take 30-60 seconds)${NC}"

cat > "$OUTPUT_DIR/detailed_audit.txt" << 'HEADER'
# 🔍 GymBro - Rare Icons Detailed Audit
# Generated: $(date)
# Purpose: Manual review for cleanup decision

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HEADER

# Process each single-use icon
COUNTER=0
while read -r line; do
  COUNTER=$((COUNTER + 1))
  icon=$(echo "$line" | awk '{print $2}')

  # Progress indicator every 20 icons
  if [ $((COUNTER % 20)) -eq 0 ]; then
    echo -ne "  Processing: $COUNTER/$SINGLE_COUNT icons\r"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "[$COUNTER/$SINGLE_COUNT] $icon (1 use)" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "" >> "$OUTPUT_DIR/detailed_audit.txt"

  # Find file location
  grep -rn "$icon" lib/ --include="*.dart" 2>/dev/null | head -3 >> "$OUTPUT_DIR/detailed_audit.txt" || echo "  (No match found - may be in comments)" >> "$OUTPUT_DIR/detailed_audit.txt"

  echo "" >> "$OUTPUT_DIR/detailed_audit.txt"

  # Categorize automatically
  FILE_PATH=$(grep -rl "$icon" lib/ --include="*.dart" 2>/dev/null | head -1)

  if [[ "$FILE_PATH" == *"/tools/"* ]] || [[ "$FILE_PATH" == *"/debug"* ]]; then
    echo "  🔴 CATEGORY: Debug/Tools → LIKELY REMOVE" >> "$OUTPUT_DIR/detailed_audit.txt"
  elif [[ "$FILE_PATH" == *"/test/"* ]]; then
    echo "  🔴 CATEGORY: Test → REVIEW FOR REMOVAL" >> "$OUTPUT_DIR/detailed_audit.txt"
  elif [[ "$icon" == *"_outlined" ]] || [[ "$icon" == *"_rounded" ]]; then
    echo "  🟡 CATEGORY: Variant → CHECK FOR DUPLICATE" >> "$OUTPUT_DIR/detailed_audit.txt"
  else
    echo "  🟢 CATEGORY: Feature Code → MANUAL REVIEW" >> "$OUTPUT_DIR/detailed_audit.txt"
  fi

  echo "" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "DECISION: [ ] REMOVE  [ ] KEEP  [ ] REPLACE WITH: ______________" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "" >> "$OUTPUT_DIR/detailed_audit.txt"
  echo "" >> "$OUTPUT_DIR/detailed_audit.txt"

done < "$OUTPUT_DIR/single_use_icons.txt"

echo -ne "  Processing: $SINGLE_COUNT/$SINGLE_COUNT icons ✓\n"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. DUPLICATE VARIANTS ANALYSIS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${GREEN}[5/5]${NC} Analyzing duplicate variants..."

cat > "$OUTPUT_DIR/duplicate_variants.txt" << 'HEADER'
# 🔄 GymBro - Duplicate Icon Variants
# Icons with _outlined, _rounded, _filled variants

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HEADER

# Find icon families (base + variants)
declare -A icon_families

while read -r line; do
  icon=$(echo "$line" | awk '{print $2}')
  uses=$(echo "$line" | awk '{print $1}')

  # Extract base name (remove _outlined, _rounded, etc)
  base_name=$(echo "$icon" | sed -E 's/_(outlined|rounded|filled|off)$//')

  if [[ "$icon" != "$base_name" ]]; then
    icon_families["$base_name"]+="  $icon: $uses uses\n"
  fi
done < "$OUTPUT_DIR/all_icons_usage.txt"

# Print families with variants
VARIANT_COUNT=0
for base in "${!icon_families[@]}"; do
  # Check if base icon also exists
  base_uses=$(grep "Icons\.$base$" "$OUTPUT_DIR/all_icons_usage.txt" | awk '{print $1}')

  if [[ -n "$base_uses" ]]; then
    VARIANT_COUNT=$((VARIANT_COUNT + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "Icon Family: $base" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "  Icons.$base: $base_uses uses (BASE)" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo -e "${icon_families[$base]}" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "RECOMMENDATION: Standardize on 1-2 variants max" >> "$OUTPUT_DIR/duplicate_variants.txt"
    echo "" >> "$OUTPUT_DIR/duplicate_variants.txt"
  fi
done

echo -e "  ${YELLOW}Icon families with variants:${NC} $VARIANT_COUNT"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY REPORT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cat > "$OUTPUT_DIR/SUMMARY.txt" << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧹 GymBro - Icon Cleanup Audit Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generated: $(date)
Project: $PROJECT_ROOT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Statistics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total unique icons:              $TOTAL_ICONS
Total icon uses:                 $TOTAL_USES
Rare icons (≤2 uses):            $RARE_COUNT ($RARE_PERCENT%)
Single-use icons:                $SINGLE_COUNT
Icon families with variants:     $VARIANT_COUNT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Output Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All icons usage (sorted):        $OUTPUT_DIR/all_icons_usage.txt
Rare icons (≤2 uses):            $OUTPUT_DIR/rare_icons.txt
Single-use icons:                $OUTPUT_DIR/single_use_icons.txt
Detailed audit report:           $OUTPUT_DIR/detailed_audit.txt
Duplicate variants analysis:     $OUTPUT_DIR/duplicate_variants.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Review detailed audit:
   \$ less $OUTPUT_DIR/detailed_audit.txt

2. Review duplicate variants:
   \$ less $OUTPUT_DIR/duplicate_variants.txt

3. Follow refactoring plan:
   \$ less docs/ICON_REFACTORING_PLAN.md

4. Start cleanup:
   \$ git checkout -b refactor/icon-cleanup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 Cleanup Estimate
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Potential icon reduction:        $RARE_COUNT icons
Estimated bundle size saving:    ~50-100KB
Estimated refactoring time:      6-8 hours
Priority:                        Medium-High

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Audit complete! Review output files and start refactoring.

EOF

cat "$OUTPUT_DIR/SUMMARY.txt"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Audit Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📂 Output directory:${NC} $OUTPUT_DIR"
echo ""
echo -e "${BLUE}Next:${NC} Review detailed_audit.txt and start Phase 1 of refactoring plan"
echo ""
