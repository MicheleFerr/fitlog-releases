#!/bin/bash
# GymBro Code Quality Dashboard
# Shows current state of code quality metrics

echo "📊 GymBro Code Quality Dashboard"
echo "================================="
echo ""
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to get status emoji
get_status() {
  local count=$1
  if [ "$count" -eq 0 ]; then
    echo -e "${GREEN}✅${NC}"
  elif [ "$count" -lt 10 ]; then
    echo -e "${YELLOW}⚠️${NC}"
  else
    echo -e "${RED}❌${NC}"
  fi
}

# 1. Compilation Errors
echo -e "${BLUE}🔴 CRITICAL ISSUES${NC}"
echo "==================="
ERRORS=$(flutter analyze 2>&1 | grep "error •" | wc -l | tr -d ' ')
ERRORS_STATUS=$(get_status $ERRORS)
echo -e "$ERRORS_STATUS Compilation Errors: $ERRORS"

RELATIVE_IMPORTS=$(find lib -name "*.dart" -type f -exec grep -l "import '\.\." {} \; 2>/dev/null | wc -l | tr -d ' ')
IMPORTS_STATUS=$(get_status $RELATIVE_IMPORTS)
echo -e "$IMPORTS_STATUS Relative Imports: $RELATIVE_IMPORTS"

echo ""

# 2. Code Quality Issues
echo -e "${BLUE}🟡 CODE QUALITY${NC}"
echo "================"

# Hardcoded strings
if [ -f "./scripts/find_hardcoded_strings.sh" ]; then
  STRINGS=$(./scripts/find_hardcoded_strings.sh 2>&1 | grep -c "Hardcoded string found" || echo "0")
else
  STRINGS="N/A"
fi
STRINGS_STATUS=$(get_status $STRINGS)
echo -e "$STRINGS_STATUS Hardcoded Strings: $STRINGS"

# Hardcoded colors
COLORS=$(grep -r "Colors\." lib/features --include="*.dart" 2>/dev/null | \
         grep -v "Colors.transparent" | \
         grep -v "// OK" | \
         wc -l | tr -d ' ')
COLORS_STATUS=$(get_status $COLORS)
echo -e "$COLORS_STATUS Hardcoded Colors: $COLORS"

# Raw components
SPINNERS=$(grep -r "CircularProgressIndicator()" lib/features --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
SPINNERS_STATUS=$(get_status $SPINNERS)
echo -e "$SPINNERS_STATUS Raw CircularProgressIndicator: $SPINNERS"

SNACKBARS=$(grep -r "ScaffoldMessenger.of(context)" lib/features --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
SNACKBARS_STATUS=$(get_status $SNACKBARS)
echo -e "$SNACKBARS_STATUS Raw ScaffoldMessenger: $SNACKBARS"

DIALOGS=$(grep -r "showDialog(" lib/features --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
DIALOGS_STATUS=$(get_status $DIALOGS)
echo -e "$DIALOGS_STATUS Raw showDialog: $DIALOGS"

echo ""

# 3. Test Coverage
echo -e "${BLUE}🧪 TESTING${NC}"
echo "=========="
TEST_ERRORS=$(flutter analyze 2>&1 | grep "test/" | grep "error •" | wc -l | tr -d ' ')
TEST_STATUS=$(get_status $TEST_ERRORS)
echo -e "$TEST_STATUS Test Errors: $TEST_ERRORS"

echo ""

# 4. Summary
echo "=============================="
TOTAL_ISSUES=$((ERRORS + RELATIVE_IMPORTS + COLORS + SPINNERS + SNACKBARS + DIALOGS))

if [ "$ERRORS" -eq 0 ] && [ "$RELATIVE_IMPORTS" -eq 0 ]; then
  echo -e "${GREEN}✨ Critical checks PASSED${NC}"
else
  echo -e "${RED}❌ Critical issues found: Fix before commit${NC}"
fi

if [ "$TOTAL_ISSUES" -eq 0 ]; then
  echo -e "${GREEN}🏆 PERFECT CODE QUALITY!${NC}"
elif [ "$TOTAL_ISSUES" -lt 50 ]; then
  echo -e "${YELLOW}⚠️  Good but can improve: $TOTAL_ISSUES total issues${NC}"
else
  echo -e "${RED}📈 Needs attention: $TOTAL_ISSUES total issues${NC}"
fi

echo ""
echo "🎯 Target: All metrics to 0"
echo "📚 Docs: CODE_QUALITY_RULES.md"
echo ""

exit 0
