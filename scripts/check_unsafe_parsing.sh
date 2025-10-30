#!/bin/bash

# 🏋️‍♂️ FitLog Pro - Pre-Commit Hook
#
# CRITICAL SECURITY CHECK: Block unsafe number parsing
#
# This script prevents commits containing:
# - double.parse() without try/catch
# - int.parse() without try/catch
# - Unvalidated user input
#
# ✅ SAFE:
#   - double.tryParse()
#   - int.tryParse()
#   - InputValidationService.parseDoubleInRange()
#
# ❌ UNSAFE (will block commit):
#   - double.parse()
#   - int.parse()

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Checking for unsafe number parsing..."

# Get list of staged Dart files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "✅ No Dart files staged for commit"
  exit 0
fi

# Initialize violation counter
VIOLATIONS=0
VIOLATIONS_LIST=""

# Check each staged file
for FILE in $STAGED_FILES; do
  # Skip generated files
  if [[ $FILE == *".g.dart" ]] || [[ $FILE == *".freezed.dart" ]] || [[ $FILE == *"generated"* ]]; then
    continue
  fi

  # Check for double.parse()
  if grep -n "double\.parse(" "$FILE" > /dev/null 2>&1; then
    LINES=$(grep -n "double\.parse(" "$FILE" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATIONS_LIST="${VIOLATIONS_LIST}\n${RED}❌ UNSAFE: double.parse() in $FILE:$LINES${NC}"
    VIOLATIONS_LIST="${VIOLATIONS_LIST}\n   ${YELLOW}Fix: Use double.tryParse() or InputValidationService.parseDoubleInRange()${NC}"
  fi

  # Check for int.parse()
  if grep -n "int\.parse(" "$FILE" > /dev/null 2>&1; then
    LINES=$(grep -n "int\.parse(" "$FILE" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
    VIOLATIONS=$((VIOLATIONS + 1))
    VIOLATIONS_LIST="${VIOLATIONS_LIST}\n${RED}❌ UNSAFE: int.parse() in $FILE:$LINES${NC}"
    VIOLATIONS_LIST="${VIOLATIONS_LIST}\n   ${YELLOW}Fix: Use int.tryParse() or InputValidationService.parseIntInRange()${NC}"
  fi
done

# Report results
if [ $VIOLATIONS -gt 0 ]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}🚨 COMMIT BLOCKED: Found $VIOLATIONS unsafe parsing violation(s)${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "$VIOLATIONS_LIST"
  echo ""
  echo -e "${YELLOW}📖 Why is this dangerous?${NC}"
  echo "   - double.parse() throws exception on invalid input → app crash"
  echo "   - int.parse() throws exception on invalid input → app crash"
  echo "   - User can enter 'abc' or malicious input → security risk"
  echo ""
  echo -e "${GREEN}✅ Safe alternatives:${NC}"
  echo "   1. Use double.tryParse() + null check"
  echo "   2. Use InputValidationService.parseDoubleInRange()"
  echo "   3. Use InputValidationService.parseIntInRange()"
  echo ""
  echo -e "${YELLOW}Example fix:${NC}"
  echo "   ❌ final weight = double.parse(controller.text);"
  echo "   ✅ final weight = InputValidationService.parseWeight(controller.text);"
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi

echo "✅ No unsafe parsing violations found"
exit 0
