#!/bin/bash

# 🎨 Design Guidelines Audit Script
#
# Scansiona l'intera codebase per violazioni design guidelines
# Usa gli stessi pattern del pre-commit hook ma su TUTTI i file
#
# Usage:
#   ./scripts/audit_design_guidelines.sh                 # Full audit
#   ./scripts/audit_design_guidelines.sh --report-only   # Solo report, no output dettagliato
#   ./scripts/audit_design_guidelines.sh --fix           # Auto-fix alcune violazioni
#
# Output:
#   - Report su console (colorato)
#   - Opzionale: salva su design_violations_report.txt

set -e

# Colori per output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Flags
REPORT_ONLY=false
AUTO_FIX=false
SAVE_REPORT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --report-only)
      REPORT_ONLY=true
      shift
      ;;
    --fix)
      AUTO_FIX=true
      shift
      ;;
    --save)
      SAVE_REPORT=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--report-only] [--fix] [--save]"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   🎨 Design Guidelines Audit - Full Codebase Scan${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Get all Dart files (exclude generated/, theme/ for some checks)
ALL_DART_FILES=$(find lib -name "*.dart" -not -path "*/generated/*" | sort)
TOTAL_FILES=$(echo "$ALL_DART_FILES" | wc -l | tr -d ' ')

echo -e "${CYAN}📂 Scanning $TOTAL_FILES Dart files...${NC}"
echo ""

# ============================================
# Check 1: Spacing System Violations
# ============================================
echo -e "${BLUE}[1/4] Checking Spacing System (multiples of 4)...${NC}"

# Use single grep for all files, then filter
SPACING_VIOLATIONS=$(find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/theme/*" -exec grep -Hn "EdgeInsets\." {} \; 2>/dev/null | while IFS=: read -r file linenum content; do
  # Extract all numbers from EdgeInsets
  numbers=$(echo "$content" | grep -oE '[0-9]+')

  for num in $numbers; do
    # Check if not multiple of 4
    if [ $((num % 4)) -ne 0 ] && [ $num -gt 0 ]; then
      echo "${file}:${linenum}"
      break
    fi
  done
done)

SPACING_COUNT=$(echo "$SPACING_VIOLATIONS" | grep -c ":" 2>/dev/null || echo "0")

if [ $SPACING_COUNT -gt 0 ]; then
  echo -e "${RED}   ❌ Found $SPACING_COUNT spacing violations${NC}"
  if [ "$REPORT_ONLY" = false ]; then
    echo ""
    echo -e "$SPACING_VIOLATIONS" | head -n 10
    if [ $SPACING_COUNT -gt 10 ]; then
      echo -e "${YELLOW}   ... (showing first 10 of $SPACING_COUNT)${NC}"
    fi
    echo ""
  fi
else
  echo -e "${GREEN}   ✅ No spacing violations found${NC}"
fi

echo ""

# ============================================
# Check 2: Border Radius Violations
# ============================================
echo -e "${BLUE}[2/4] Checking Border Radius (8/12/16/20/24)...${NC}"

# Use single grep for all files
RADIUS_VIOLATIONS=$(find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/theme/*" -exec grep -Hn "BorderRadius\.circular" {} \; 2>/dev/null | while IFS=: read -r file linenum content; do
  # Extract the radius value
  radius=$(echo "$content" | grep -oE 'circular\(([0-9]+)\)' | grep -oE '[0-9]+')

  if [ ! -z "$radius" ]; then
    # Check if radius is in allowed list
    if [[ ! " 8 12 16 20 24 " =~ " $radius " ]]; then
      echo "${file}:${linenum}"
    fi
  fi
done)

RADIUS_COUNT=$(echo "$RADIUS_VIOLATIONS" | grep -c ":" 2>/dev/null || echo "0")

if [ $RADIUS_COUNT -gt 0 ]; then
  echo -e "${RED}   ❌ Found $RADIUS_COUNT border radius violations${NC}"
  if [ "$REPORT_ONLY" = false ]; then
    echo ""
    echo -e "$RADIUS_VIOLATIONS" | head -n 10
    if [ $RADIUS_COUNT -gt 10 ]; then
      echo -e "${YELLOW}   ... (showing first 10 of $RADIUS_COUNT)${NC}"
    fi
    echo ""
  fi
else
  echo -e "${GREEN}   ✅ No border radius violations found${NC}"
fi

echo ""

# ============================================
# Check 3: Hardcoded TextStyle Violations
# ============================================
echo -e "${BLUE}[3/4] Checking Hardcoded TextStyle...${NC}"

# Use single grep for all files
TEXTSTYLE_VIOLATIONS=$(find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/theme/*" -not -name "app_theme.dart" -exec grep -Hn "TextStyle(" {} \; 2>/dev/null | grep -v "copyWith" | grep -v "// ignore:" | grep -v "static const TextStyle" | cut -d: -f1,2)

TEXTSTYLE_COUNT=$(echo "$TEXTSTYLE_VIOLATIONS" | grep -c ":" 2>/dev/null || echo "0")

if [ $TEXTSTYLE_COUNT -gt 0 ]; then
  echo -e "${RED}   ❌ Found $TEXTSTYLE_COUNT hardcoded TextStyle instances${NC}"
  if [ "$REPORT_ONLY" = false ]; then
    echo ""
    echo -e "$TEXTSTYLE_VIOLATIONS" | head -n 10
    if [ $TEXTSTYLE_COUNT -gt 10 ]; then
      echo -e "${YELLOW}   ... (showing first 10 of $TEXTSTYLE_COUNT)${NC}"
    fi
    echo ""
  fi
else
  echo -e "${GREEN}   ✅ No hardcoded TextStyle found${NC}"
fi

echo ""

# ============================================
# Check 4: Hardcoded Animation Violations
# ============================================
echo -e "${BLUE}[4/4] Checking Hardcoded Animations...${NC}"

# Use single grep for all files, excluding animation system files
ANIMATION_CONTROLLER=$(find lib -name "*.dart" -not -path "*/generated/*" -not -name "interactive_element.dart" -not -name "expanding_strip_container.dart" -not -name "animated_icon_patterns.dart" -exec grep -Hn "AnimationController(" {} \; 2>/dev/null | grep -v "// ignore:" | cut -d: -f1,2)

ANIMATION_SCALE=$(find lib -name "*.dart" -not -path "*/generated/*" -not -name "interactive_element.dart" -not -name "expanding_strip_container.dart" -not -name "animated_icon_patterns.dart" -exec grep -Hn "AnimatedScale(" {} \; 2>/dev/null | grep -v "// ignore:" | cut -d: -f1,2)

# Combine both
ANIMATION_VIOLATIONS=$(printf "%s\n%s" "$ANIMATION_CONTROLLER" "$ANIMATION_SCALE" | grep -v "^$")
ANIMATION_COUNT=$(echo "$ANIMATION_VIOLATIONS" | grep -c ":" 2>/dev/null || echo "0")

if [ $ANIMATION_COUNT -gt 0 ]; then
  echo -e "${YELLOW}   ⚠️  Found $ANIMATION_COUNT hardcoded animations${NC}"
  if [ "$REPORT_ONLY" = false ]; then
    echo ""
    echo -e "$ANIMATION_VIOLATIONS" | head -n 10
    if [ $ANIMATION_COUNT -gt 10 ]; then
      echo -e "${YELLOW}   ... (showing first 10 of $ANIMATION_COUNT)${NC}"
    fi
    echo ""
  fi
else
  echo -e "${GREEN}   ✅ No hardcoded animations found${NC}"
fi

echo ""

# ============================================
# Summary Report
# ============================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📊 Audit Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

TOTAL_VIOLATIONS=$((SPACING_COUNT + RADIUS_COUNT + TEXTSTYLE_COUNT))
TOTAL_WARNINGS=$ANIMATION_COUNT

echo -e "${CYAN}📂 Files Scanned:${NC} $TOTAL_FILES"
echo ""
echo -e "${CYAN}🔴 Critical Violations (MUST FIX):${NC}"
echo -e "   • Spacing System:     ${RED}$SPACING_COUNT${NC}"
echo -e "   • Border Radius:      ${RED}$RADIUS_COUNT${NC}"
echo -e "   • Hardcoded TextStyle: ${RED}$TEXTSTYLE_COUNT${NC}"
echo -e "   ${CYAN}────────────────────────${NC}"
echo -e "   ${MAGENTA}TOTAL:                 $TOTAL_VIOLATIONS${NC}"
echo ""
echo -e "${CYAN}⚠️  Warnings (SHOULD FIX):${NC}"
echo -e "   • Hardcoded Animations: ${YELLOW}$TOTAL_WARNINGS${NC}"
echo ""

# Overall status
if [ $TOTAL_VIOLATIONS -eq 0 ] && [ $TOTAL_WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ All design guidelines are respected!${NC}"
  echo -e "${GREEN}   Pre-commit hook is working correctly.${NC}"
  EXIT_CODE=0
elif [ $TOTAL_VIOLATIONS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  No critical violations, but $TOTAL_WARNINGS warnings found.${NC}"
  echo -e "${YELLOW}   Consider migrating hardcoded animations to InteractiveElement.${NC}"
  EXIT_CODE=0
else
  echo -e "${RED}❌ Found $TOTAL_VIOLATIONS critical violations that need fixing.${NC}"
  echo -e "${YELLOW}   These violations would be blocked by pre-commit hook on new commits.${NC}"
  EXIT_CODE=1
fi

echo ""

# ============================================
# Recommendations
# ============================================
if [ $TOTAL_VIOLATIONS -gt 0 ] || [ $TOTAL_WARNINGS -gt 0 ]; then
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}   💡 Recommended Actions${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""

  if [ $SPACING_COUNT -gt 0 ]; then
    echo -e "${YELLOW}📏 Spacing Violations:${NC}"
    echo -e "   1. Replace with multiples of 4: 4, 8, 12, 16, 20, 24, 32"
    echo -e "   2. Example: EdgeInsets.all(15) → EdgeInsets.all(16)"
    echo -e "   3. Reference: docs/DESIGN_GUIDELINES.md → Spacing System"
    echo ""
  fi

  if [ $RADIUS_COUNT -gt 0 ]; then
    echo -e "${YELLOW}📐 Border Radius Violations:${NC}"
    echo -e "   1. Use standard values: 8 (small), 12 (medium), 16 (large), 20 (XL), 24 (hero)"
    echo -e "   2. Example: BorderRadius.circular(10) → BorderRadius.circular(12)"
    echo -e "   3. Reference: docs/DESIGN_GUIDELINES.md → Border Radius Scale"
    echo ""
  fi

  if [ $TEXTSTYLE_COUNT -gt 0 ]; then
    echo -e "${YELLOW}📝 TextStyle Violations:${NC}"
    echo -e "   1. Use context.textTheme.* instead of TextStyle()"
    echo -e "   2. Example: TextStyle(fontSize: 16) → context.textTheme.bodyLarge"
    echo -e "   3. For customization: context.textTheme.titleLarge?.copyWith(...)"
    echo -e "   4. Reference: docs/DESIGN_GUIDELINES.md → Typography"
    echo ""
  fi

  if [ $ANIMATION_COUNT -gt 0 ]; then
    echo -e "${YELLOW}🎬 Animation Violations:${NC}"
    echo -e "   1. Migrate to InteractiveElement for press feedback animations"
    echo -e "   2. Example: AnimationController → InteractiveElement(feedbackConfig: ...)"
    echo -e "   3. Reference: docs/DESIGN_GUIDELINES.md → Unified Animation System"
    echo ""
  fi

  echo -e "${CYAN}🔧 Quick Fixes:${NC}"
  echo -e "   • Run with --fix flag to auto-fix some violations (coming soon)"
  echo -e "   • Pre-commit hook will prevent new violations from being committed"
  echo ""
fi

# ============================================
# Save Report (optional)
# ============================================
if [ "$SAVE_REPORT" = true ]; then
  REPORT_FILE="design_violations_report.txt"
  echo "Design Guidelines Audit Report" > "$REPORT_FILE"
  echo "Generated: $(date)" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Files Scanned: $TOTAL_FILES" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Critical Violations:" >> "$REPORT_FILE"
  echo "  - Spacing System: $SPACING_COUNT" >> "$REPORT_FILE"
  echo "  - Border Radius: $RADIUS_COUNT" >> "$REPORT_FILE"
  echo "  - Hardcoded TextStyle: $TEXTSTYLE_COUNT" >> "$REPORT_FILE"
  echo "  TOTAL: $TOTAL_VIOLATIONS" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Warnings:" >> "$REPORT_FILE"
  echo "  - Hardcoded Animations: $TOTAL_WARNINGS" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "Detailed Violations:" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  if [ ! -z "$SPACING_VIOLATIONS" ]; then
    echo "Spacing Violations:" >> "$REPORT_FILE"
    echo -e "$SPACING_VIOLATIONS" >> "$REPORT_FILE"
  fi
  if [ ! -z "$RADIUS_VIOLATIONS" ]; then
    echo "Border Radius Violations:" >> "$REPORT_FILE"
    echo -e "$RADIUS_VIOLATIONS" >> "$REPORT_FILE"
  fi
  if [ ! -z "$TEXTSTYLE_VIOLATIONS" ]; then
    echo "TextStyle Violations:" >> "$REPORT_FILE"
    echo -e "$TEXTSTYLE_VIOLATIONS" >> "$REPORT_FILE"
  fi
  if [ ! -z "$ANIMATION_VIOLATIONS" ]; then
    echo "Animation Violations:" >> "$REPORT_FILE"
    echo -e "$ANIMATION_VIOLATIONS" >> "$REPORT_FILE"
  fi

  echo -e "${GREEN}📄 Report saved to: $REPORT_FILE${NC}"
  echo ""
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

exit $EXIT_CODE
