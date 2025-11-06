#!/bin/bash

################################################################################
# 🎨 Fix Theme Violations - WIDGETS/SCREENS ONLY (Safe Mode)
#
# Fixes only files in presentation/widgets and presentation/screens
# These files always have BuildContext available
#
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  🎨 Safe Theme Migration - Widgets/Screens Only          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

TOTAL=0
FIXED=0
SKIPPED=0

# Find all presentation/widgets and presentation/screens files
echo -e "${CYAN}Finding widget and screen files...${NC}"
echo ""

FILES=$(find lib/features/*/presentation/widgets lib/features/*/presentation/screens -name "*.dart" -type f 2>/dev/null)

for file in $FILES; do
    TOTAL=$((TOTAL + 1))

    # Skip if no violations
    if ! grep -q "Colors\." "$file" 2>/dev/null; then
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Check for complex patterns
    HAS_CONST=$(grep -c "const.*Colors\." "$file" 2>/dev/null || echo 0)
    HAS_SHADE=$(grep -c "Colors\..*\.shade" "$file" 2>/dev/null || echo 0)

    if [ "$HAS_CONST" -gt 0 ] || [ "$HAS_SHADE" -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC}  Skipping complex: $(basename $file)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Fix the file
    echo -e "${GREEN}→${NC}  Fixing: $(basename $file)"
    ./scripts/fix_theme_violations.sh --file "$file" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        FIXED=$((FIXED + 1))
    else
        echo -e "${YELLOW}⚠${NC}  Failed: $(basename $file)"
        SKIPPED=$((SKIPPED + 1))
    fi
done

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  📊 Summary                                                ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Total widget/screen files: ${CYAN}$TOTAL${NC}"
echo -e "  Fixed:                     ${GREEN}$FIXED${NC}"
echo -e "  Skipped:                   ${YELLOW}$SKIPPED${NC}"
echo ""

if [ "$FIXED" -gt 0 ]; then
    echo -e "${GREEN}✓${NC}  Migration complete! Run ${CYAN}flutter analyze${NC} to verify"
else
    echo -e "${YELLOW}ℹ${NC}  No files were fixed"
fi
echo ""
