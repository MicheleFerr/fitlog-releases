#!/bin/bash

# 🎨 Design System Violations Checker
# Cerca tutte le violazioni delle design guidelines nel codebase
# Riferimento: docs/DESIGN_GUIDELINES.md

set -e

# Colori per output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contatori
total_violations=0
hardcoded_strings=0
hardcoded_colors=0
hardcoded_textstyles=0
wrong_components=0
wrong_opacity=0

echo "🎨 =========================================="
echo "🎨 Design System Violations Checker"
echo "🎨 =========================================="
echo ""

# ============================================
# 1. TESTI HARDCODED
# ============================================
echo -e "${BLUE}📝 [1/6] Checking hardcoded strings...${NC}"
echo "   Expected: context.l10n.*"
echo ""

# Text widget con stringhe hardcoded (inglese/italiano)
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/.dart_tool/*" \
  -not -path "*/l10n/*" \
  -exec grep -l "Text(['\"][A-Za-zÀ-ÿ\s]{3,}['\"])" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with hardcoded strings in Text()${NC}"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/.dart_tool/*" \
    -not -path "*/l10n/*" \
    -exec grep -Hn "Text(['\"][A-Za-zÀ-ÿ\s]{3,}['\"])" {} \; 2>/dev/null | head -10
  echo ""
  hardcoded_strings=$violations
  total_violations=$((total_violations + violations))
else
  echo -e "${GREEN}✅ No hardcoded strings found${NC}"
fi

echo ""

# ============================================
# 2. COLORI HARDCODED
# ============================================
echo -e "${BLUE}🎨 [2/6] Checking hardcoded colors...${NC}"
echo "   Expected: context.colors.*"
echo ""

# Colors.* (es: Colors.blue, Colors.red)
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/theme/*" \
  -exec grep -l "Colors\.[a-z]" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with Colors.*${NC}"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/theme/*" \
    -exec grep -Hn "Colors\.[a-z]" {} \; 2>/dev/null | head -10
  echo ""
  hardcoded_colors=$violations
  total_violations=$((total_violations + violations))
fi

# Color(0x...) hex colors
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/theme/*" \
  -exec grep -l "Color(0x[0-9A-Fa-f]\{8\})" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with Color(0x...)${NC}"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/theme/*" \
    -exec grep -Hn "Color(0x[0-9A-Fa-f]\{8\})" {} \; 2>/dev/null | head -10
  echo ""
  hardcoded_colors=$((hardcoded_colors + violations))
  total_violations=$((total_violations + violations))
fi

if [ "$hardcoded_colors" -eq 0 ]; then
  echo -e "${GREEN}✅ No hardcoded colors found${NC}"
fi

echo ""

# ============================================
# 3. TEXTSTYLE HARDCODED
# ============================================
echo -e "${BLUE}✍️  [3/6] Checking hardcoded TextStyles...${NC}"
echo "   Expected: context.textTheme.*"
echo ""

violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/theme/*" \
  -exec grep -l "TextStyle(" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Found $violations files with TextStyle()${NC}"
  echo "   (Note: Some may be valid .copyWith() usage)"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/theme/*" \
    -exec grep -Hn "TextStyle(" {} \; 2>/dev/null | head -10
  echo ""
  hardcoded_textstyles=$violations
  total_violations=$((total_violations + violations))
else
  echo -e "${GREEN}✅ No TextStyle() found${NC}"
fi

echo ""

# ============================================
# 4. COMPONENTI SBAGLIATI
# ============================================
echo -e "${BLUE}🔧 [4/6] Checking wrong components...${NC}"
echo "   Expected: LoadingIndicator, SnackBarService, ModalService"
echo ""

# CircularProgressIndicator diretto
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/widgets/loading_indicator.dart" \
  -exec grep -l "CircularProgressIndicator()" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with CircularProgressIndicator()${NC}"
  echo "   Should use: LoadingIndicator()"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/widgets/loading_indicator.dart" \
    -exec grep -Hn "CircularProgressIndicator()" {} \; 2>/dev/null | head -10
  echo ""
  wrong_components=$violations
  total_violations=$((total_violations + violations))
fi

# ScaffoldMessenger diretto
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/services/snackbar_service.dart" \
  -exec grep -l "ScaffoldMessenger\.of(context)" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with ScaffoldMessenger${NC}"
  echo "   Should use: SnackBarService.show*()"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/services/snackbar_service.dart" \
    -exec grep -Hn "ScaffoldMessenger\.of(context)" {} \; 2>/dev/null | head -10
  echo ""
  wrong_components=$((wrong_components + violations))
  total_violations=$((total_violations + violations))
fi

# showModalBottomSheet diretto
violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -not -path "*/services/modal_service.dart" \
  -exec grep -l "showModalBottomSheet(" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with showModalBottomSheet()${NC}"
  echo "   Should use: ModalService.show*()"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -not -path "*/services/modal_service.dart" \
    -exec grep -Hn "showModalBottomSheet(" {} \; 2>/dev/null | head -10
  echo ""
  wrong_components=$((wrong_components + violations))
  total_violations=$((total_violations + violations))
fi

if [ "$wrong_components" -eq 0 ]; then
  echo -e "${GREEN}✅ All components are correct${NC}"
fi

echo ""

# ============================================
# 5. withOpacity() invece di withValues(alpha:)
# ============================================
echo -e "${BLUE}🔍 [5/6] Checking deprecated opacity methods...${NC}"
echo "   Expected: .withValues(alpha: 0.x)"
echo ""

violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -exec grep -l "\.withOpacity(" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${RED}❌ Found $violations files with .withOpacity()${NC}"
  echo "   Should use: .withValues(alpha: 0.x)"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -exec grep -Hn "\.withOpacity(" {} \; 2>/dev/null | head -10
  echo ""
  wrong_opacity=$violations
  total_violations=$((total_violations + violations))
else
  echo -e "${GREEN}✅ No .withOpacity() found${NC}"
fi

echo ""

# ============================================
# 6. PRINT() STATEMENTS (bonus check)
# ============================================
echo -e "${BLUE}🖨️  [6/6] Checking print() statements...${NC}"
echo "   Expected: debugPrint() + kDebugMode"
echo ""

violations=$(find lib -name "*.dart" \
  -not -path "*/generated/*" \
  -exec grep -l "print(" {} \; 2>/dev/null | wc -l)

if [ "$violations" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Found $violations files with print()${NC}"
  echo "   Should use: debugPrint() with kDebugMode check"
  find lib -name "*.dart" \
    -not -path "*/generated/*" \
    -exec grep -Hn "print(" {} \; 2>/dev/null | head -10
  echo ""
  total_violations=$((total_violations + violations))
else
  echo -e "${GREEN}✅ No print() statements found${NC}"
fi

echo ""

# ============================================
# SUMMARY
# ============================================
echo "🎨 =========================================="
echo "🎨 Summary"
echo "🎨 =========================================="
echo ""

if [ "$total_violations" -eq 0 ]; then
  echo -e "${GREEN}✅ Perfect! No design violations found!${NC}"
  echo -e "${GREEN}   Your codebase follows all design guidelines.${NC}"
  exit 0
else
  echo -e "${RED}❌ Found violations:${NC}"
  echo ""
  [ "$hardcoded_strings" -gt 0 ] && echo "   📝 Hardcoded strings: $hardcoded_strings files"
  [ "$hardcoded_colors" -gt 0 ] && echo "   🎨 Hardcoded colors: $hardcoded_colors files"
  [ "$hardcoded_textstyles" -gt 0 ] && echo "   ✍️  Hardcoded TextStyles: $hardcoded_textstyles files"
  [ "$wrong_components" -gt 0 ] && echo "   🔧 Wrong components: $wrong_components files"
  [ "$wrong_opacity" -gt 0 ] && echo "   🔍 Wrong opacity method: $wrong_opacity files"
  echo ""
  echo -e "${YELLOW}📖 See docs/DESIGN_GUIDELINES.md for correct patterns${NC}"
  echo -e "${YELLOW}🛠️  Run 'flutter analyze' to check for other issues${NC}"
  echo ""
  exit 1
fi
