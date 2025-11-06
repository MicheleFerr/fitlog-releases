#!/bin/bash

# 🔒 GymBro TrackLog - Security Pre-Commit Check Script
#
# This script performs security checks before allowing a commit.
# It checks for:
# 1. Hardcoded secrets (API keys, passwords, tokens)
# 2. print() statements (should use debugPrint() + kDebugMode)
# 3. Unsafe parsing (parse() without try-catch)
# 4. TODO/FIXME with SECURITY tag
#
# Usage: ./scripts/security_check.sh
# Or: Add to .git/hooks/pre-commit

set -e  # Exit on error

echo "🔒 Running security checks..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any check failed
FAILED=0

# ==============================================================================
# CHECK 1: Hardcoded Secrets
# ==============================================================================
echo "1️⃣  Checking for hardcoded secrets..."

# Patterns to search for
SECRET_PATTERNS=(
  "password\s*=\s*['\"]"
  "api[_-]?key\s*=\s*['\"]"
  "secret\s*=\s*['\"]"
  "token\s*=\s*['\"]"
  "AWS_ACCESS_KEY"
  "AWS_SECRET"
  "firebase[_-]?admin"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -rn --include="*.dart" -E "$pattern" lib/ 2>/dev/null | grep -v "// SAFE:" | grep -v "firebase_options.dart"; then
    echo -e "${RED}❌ FAILED: Found potential hardcoded secret!${NC}"
    echo "   Pattern: $pattern"
    echo "   If this is a false positive, add '// SAFE:' comment"
    FAILED=1
  fi
done

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ No hardcoded secrets found${NC}"
fi
echo ""

# ==============================================================================
# CHECK 2: print() statements (should use debugPrint() + kDebugMode)
# ==============================================================================
echo "2️⃣  Checking for print() statements..."

PRINT_COUNT=$(grep -rn --include="*.dart" "^\s*print(" lib/ 2>/dev/null | wc -l | tr -d ' ')

if [ "$PRINT_COUNT" -gt 0 ]; then
  echo -e "${RED}❌ FAILED: Found $PRINT_COUNT print() statement(s)${NC}"
  echo "   Use debugPrint() wrapped in 'if (kDebugMode) { ... }' instead"
  echo ""
  echo "   Files with print():"
  grep -rn --include="*.dart" "^\s*print(" lib/ | head -5
  FAILED=1
else
  echo -e "${GREEN}✅ No print() statements found${NC}"
fi
echo ""

# ==============================================================================
# CHECK 3: Unsafe parsing (parse() without tryParse())
# ==============================================================================
echo "3️⃣  Checking for unsafe parsing..."

# Count .parse( usage (potentially unsafe)
UNSAFE_PARSE=$(grep -rn --include="*.dart" "\.parse(" lib/ 2>/dev/null | grep -v "tryParse" | grep -v "// SAFE:" | wc -l | tr -d ' ')

if [ "$UNSAFE_PARSE" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Found $UNSAFE_PARSE potential unsafe parse() call(s)${NC}"
  echo "   Consider using tryParse() instead for safer error handling"
  echo ""
  echo "   Examples:"
  grep -rn --include="*.dart" "\.parse(" lib/ | grep -v "tryParse" | grep -v "// SAFE:" | head -3
  echo ""
  echo "   If these are safe, add '// SAFE:' comment"
  # Don't fail on this, just warn
else
  echo -e "${GREEN}✅ No unsafe parse() calls found${NC}"
fi
echo ""

# ==============================================================================
# CHECK 4: Security TODOs
# ==============================================================================
echo "4️⃣  Checking for security-related TODOs..."

SECURITY_TODOS=$(grep -rn --include="*.dart" "TODO.*SECURITY\|FIXME.*SECURITY\|XXX.*SECURITY" lib/ 2>/dev/null | wc -l | tr -d ' ')

if [ "$SECURITY_TODOS" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  INFO: Found $SECURITY_TODOS security TODO(s)${NC}"
  grep -rn --include="*.dart" "TODO.*SECURITY\|FIXME.*SECURITY\|XXX.*SECURITY" lib/ | head -3
  echo ""
  echo "   These should be addressed before production deployment"
  # Don't fail, just inform
else
  echo -e "${GREEN}✅ No security TODOs found${NC}"
fi
echo ""

# ==============================================================================
# CHECK 5: Flutter analyze
# ==============================================================================
echo "5️⃣  Running flutter analyze..."

if flutter analyze --no-fatal-infos > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Flutter analyze passed${NC}"
else
  echo -e "${RED}❌ FAILED: Flutter analyze found issues${NC}"
  echo "   Run 'flutter analyze' for details"
  FAILED=1
fi
echo ""

# ==============================================================================
# Final Result
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAILED -eq 1 ]; then
  echo -e "${RED}❌ Security checks FAILED${NC}"
  echo ""
  echo "Please fix the issues above before committing."
  echo ""
  exit 1
else
  echo -e "${GREEN}✅ All security checks passed!${NC}"
  echo ""
  exit 0
fi
