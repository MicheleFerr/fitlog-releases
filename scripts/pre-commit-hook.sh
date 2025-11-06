#!/bin/bash
# 🔍 Pre-commit Hook: Hive Memory Leak Prevention
#
# Installation:
# cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
# chmod +x .git/hooks/pre-commit
#
# Purpose:
# - Prevent direct Hive.openBox() calls (use HiveBoxManager instead)
# - Warn about custom _isDisposed flags (use ref.mounted in Riverpod 3.0)
# - Ensure proper memory leak prevention patterns

set -e

echo "🔍 Running memory leak prevention checks..."

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# ============================================================
# CHECK 1: Direct Hive.openBox() calls
# ============================================================
echo "📦 Checking for direct Hive.openBox() calls..."

# Get staged files
STAGED_DART_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)

if [ -n "$STAGED_DART_FILES" ]; then
  # Check each staged file
  for FILE in $STAGED_DART_FILES; do
    # Skip allowed files
    if [[ "$FILE" == *"hive_box_manager.dart"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"test/"* ]] || [[ "$FILE" == *"_test.dart"* ]]; then
      continue # Allow in tests
    fi
    if [[ "$FILE" == *"docs/"* ]] || [[ "$FILE" == *".md"* ]]; then
      continue # Skip documentation
    fi

    # Check for Hive.openBox
    if git diff --cached "$FILE" | grep -q "Hive\.openBox"; then
      echo -e "${RED}❌ ERROR: Direct Hive.openBox() found in $FILE${NC}"
      echo "   Use HiveBoxManager.openBox() instead:"
      echo "   "
      echo "   ❌ WRONG:"
      echo "   final box = await Hive.openBox('my_box');"
      echo "   "
      echo "   ✅ CORRECT:"
      echo "   final manager = ref.watch(hiveBoxManagerProvider);"
      echo "   final box = await manager.openBox('my_box');"
      echo "   "
      ERRORS=$((ERRORS + 1))
    fi

    # Check for Hive.openLazyBox
    if git diff --cached "$FILE" | grep -q "Hive\.openLazyBox"; then
      echo -e "${RED}❌ ERROR: Direct Hive.openLazyBox() found in $FILE${NC}"
      echo "   Use HiveBoxManager.openLazyBox() instead"
      echo "   "
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# ============================================================
# CHECK 2: Custom _isDisposed flags (Riverpod 3.0 anti-pattern)
# ============================================================
echo "🔄 Checking for deprecated _isDisposed pattern..."

if [ -n "$STAGED_DART_FILES" ]; then
  for FILE in $STAGED_DART_FILES; do
    # Skip base classes and old files
    if [[ "$FILE" == *"base_hybrid_repository.dart"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"test/"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"docs/"* ]]; then
      continue
    fi

    # Check for _isDisposed in new code
    if git diff --cached "$FILE" | grep -E '^\+.*bool _isDisposed' | grep -v "base_hybrid_repository"; then
      echo -e "${YELLOW}⚠️  WARNING: Custom _isDisposed flag found in $FILE${NC}"
      echo "   Riverpod 3.0 best practice: Use ref.mounted instead"
      echo "   "
      echo "   ❌ OLD (Riverpod 2.x):"
      echo "   bool _isDisposed = false;"
      echo "   if (_isDisposed) return;"
      echo "   "
      echo "   ✅ NEW (Riverpod 3.0):"
      echo "   if (!ref.mounted) return;"
      echo "   "
      WARNINGS=$((WARNINGS + 1))
    fi
  done
fi

# ============================================================
# CHECK 3: Box.close() without await
# ============================================================
echo "🔒 Checking for box.close() without await..."

if [ -n "$STAGED_DART_FILES" ]; then
  for FILE in $STAGED_DART_FILES; do
    if [[ "$FILE" == *"test/"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"docs/"* ]]; then
      continue
    fi

    # Check for .close() without await
    if git diff --cached "$FILE" | grep -E '^\+.*\.close\(\)' | grep -v "await" | grep -v "//" | grep -v "debugPrint"; then
      echo -e "${YELLOW}⚠️  WARNING: box.close() without await found in $FILE${NC}"
      echo "   Always use: await box.close()"
      echo "   "
      WARNINGS=$((WARNINGS + 1))
    fi
  done
fi

# ============================================================
# CHECK 4: Missing HiveBoxNames constant usage
# ============================================================
echo "📝 Checking for hardcoded box names..."

if [ -n "$STAGED_DART_FILES" ]; then
  for FILE in $STAGED_DART_FILES; do
    # Skip HiveBoxNames file itself
    if [[ "$FILE" == *"hive_box_names.dart"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"test/"* ]]; then
      continue
    fi
    if [[ "$FILE" == *"docs/"* ]]; then
      continue
    fi

    # Check for openBox with string literal (not constant)
    if git diff --cached "$FILE" | grep -E '^\+.*openBox<.*>\(' | grep -E "'[a-z_]+'" | grep -v "HiveBoxNames"; then
      echo -e "${YELLOW}⚠️  WARNING: Hardcoded box name in $FILE${NC}"
      echo "   Use HiveBoxNames constants instead:"
      echo "   "
      echo "   ❌ WRONG:"
      echo "   manager.openBox('workouts')"
      echo "   "
      echo "   ✅ CORRECT:"
      echo "   manager.openBox(HiveBoxNames.workouts)"
      echo "   "
      WARNINGS=$((WARNINGS + 1))
    fi
  done
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ All memory leak prevention checks passed!${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
elif [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ Found $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  echo -e "${RED}   Commit BLOCKED - fix errors before committing${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
else
  echo -e "${YELLOW}⚠️  Found $WARNINGS warning(s) (no errors)${NC}"
  echo -e "${GREEN}   Commit allowed, but consider fixing warnings${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
