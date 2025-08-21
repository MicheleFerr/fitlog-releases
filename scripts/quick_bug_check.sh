#!/bin/bash

# 🚀 GymBro Quick Bug Check
# Versione veloce del bug checker per controlli rapidi
# Usage: ./scripts/quick_bug_check.sh

set -e

# Colori
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}🚀 GymBro Quick Bug Check${NC}\n"

# 1. Flutter Analyze (solo conteggio)
echo -e "${BOLD}1. Flutter Analyze:${NC}"
ANALYZE_OUTPUT=$(flutter analyze 2>&1 || true)
ERRORS=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || echo "0")
WARNINGS=$(echo "$ANALYZE_OUTPUT" | grep -c "warning •" || echo "0")
INFO=$(echo "$ANALYZE_OUTPUT" | grep -c "info •" || echo "0")

if [ "$ERRORS" -gt 0 ]; then
    echo -e "  ${RED}❌ $ERRORS errori${NC}"
else
    echo -e "  ${GREEN}✅ 0 errori${NC}"
fi
echo -e "  ${YELLOW}⚠️  $WARNINGS warnings${NC}"
echo -e "  ${GREEN}ℹ️  $INFO info${NC}"

# 2. Timer/Audio Issues
echo -e "\n${BOLD}2. Timer/Audio Critici:${NC}"
TIMER_ISSUES=$(grep -r "TIMER_COMPLETE_BACKGROUND\|TIMER_COMPLETE_FOREGROUND\|startSilentLoop" lib/ ios/ 2>/dev/null | wc -l || echo "0")
if [ "$TIMER_ISSUES" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠️  $TIMER_ISSUES problemi timer/audio trovati${NC}"
else
    echo -e "  ${GREEN}✅ Nessun problema timer critico${NC}"
fi

# 3. TODO/FIXME
echo -e "\n${BOLD}3. TODO/FIXME:${NC}"
TODOS=$(grep -r "TODO\|FIXME\|BUG" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
echo -e "  📝 $TODOS TODO/FIXME trovati"

# 4. Hardcoded Strings
echo -e "\n${BOLD}4. Localizzazione:${NC}"
HARDCODED=$(grep -r "Text(['\"]" --include="*.dart" lib/ 2>/dev/null | grep -v "AppLocalizations" | wc -l || echo "0")
if [ "$HARDCODED" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠️  $HARDCODED possibili stringhe hardcoded${NC}"
else
    echo -e "  ${GREEN}✅ Tutte le stringhe localizzate${NC}"
fi

# 5. Test Coverage
echo -e "\n${BOLD}5. Test:${NC}"
TEST_FILES=$(find test/ integration_test/ -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
echo -e "  🧪 $TEST_FILES file di test"

# Summary
echo -e "\n${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}${BOLD}🔴 $ERRORS ERRORI CRITICI DA RISOLVERE${NC}"
elif [ "$WARNINGS" -gt 50 ]; then
    echo -e "${YELLOW}${BOLD}🟡 Molti warnings da sistemare${NC}"
else
    echo -e "${GREEN}${BOLD}🟢 Progetto in buono stato${NC}"
fi
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

exit 0