#!/bin/bash
# Performance Pattern Checker for FitLog Pro
# Run after every feature/modification to catch anti-patterns
#
# Usage: .claude/scripts/performance-check.sh [path]
# Default path: lib/

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SEARCH_PATH="${1:-lib/}"
ISSUES_FOUND=0

echo "=============================================="
echo "  Performance Pattern Checker"
echo "  Scanning: $SEARCH_PATH"
echo "=============================================="
echo ""

# ---------------------------------------------
# CHECK 1: I/O operations inside loops
# Pattern: for/while loop containing openBox, getWorkout, saveWorkout, etc.
# ---------------------------------------------
echo "1. Checking for I/O operations inside loops..."

# Look for await calls to common I/O methods inside for loops
IO_IN_LOOP=$(grep -rn --include="*.dart" -E "for\s*\([^)]+\)\s*\{" "$SEARCH_PATH" -A 20 | grep -E "await.*(openBox|getWorkout|saveWorkout|getWorkouts|put\(|get\()" | grep -v "putAll" | head -10 || true)

if [ -n "$IO_IN_LOOP" ]; then
    echo -e "${YELLOW}  WARNING: Potential I/O inside loop:${NC}"
    echo "$IO_IN_LOOP" | head -5
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  OK${NC}"
fi
echo ""

# ---------------------------------------------
# CHECK 2: Sequential awaits (should use Future.wait)
# Pattern: await a(); await b(); await c(); on consecutive lines
# ---------------------------------------------
echo "2. Checking for sequential awaits (should use Future.wait)..."

# Find files with 3+ consecutive await statements
SEQ_AWAITS=$(grep -rn --include="*.dart" -E "^\s*await\s+" "$SEARCH_PATH" | \
    awk -F: '{file=$1; line=$2}
        file==prev_file && line==prev_line+1 {count++; if(count>=2) print prev_file":"prev_line" (3+ sequential awaits)"}
        {prev_file=file; prev_line=line; if(file!=prev_file) count=0}' | \
    sort -u | head -10 || true)

if [ -n "$SEQ_AWAITS" ]; then
    echo -e "${YELLOW}  WARNING: Sequential awaits found (consider Future.wait):${NC}"
    echo "$SEQ_AWAITS" | head -5
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  OK${NC}"
fi
echo ""

# ---------------------------------------------
# CHECK 3: Provider with Hive/Firebase without keepAlive
# Pattern: Provider that uses Hive or Firebase but no ref.keepAlive()
# ---------------------------------------------
echo "3. Checking Providers with Hive/Firebase (need keepAlive)..."

# Find provider files
PROVIDER_FILES=$(find "$SEARCH_PATH" -name "*_provider.dart" -type f 2>/dev/null || true)

for file in $PROVIDER_FILES; do
    if [ -f "$file" ]; then
        # Check if file uses Hive or Firebase
        USES_RESOURCES=$(grep -l -E "(Hive|Firebase|Repository)" "$file" 2>/dev/null || true)
        if [ -n "$USES_RESOURCES" ]; then
            # Check if it has keepAlive
            HAS_KEEPALIVE=$(grep -l "keepAlive" "$file" 2>/dev/null || true)
            if [ -z "$HAS_KEEPALIVE" ]; then
                # Check if it's a StateNotifier or AsyncNotifier (these might not need keepAlive)
                IS_NOTIFIER=$(grep -E "(StateNotifier|AsyncNotifier|Notifier)" "$file" 2>/dev/null || true)
                if [ -z "$IS_NOTIFIER" ]; then
                    echo -e "${YELLOW}  WARNING: $file uses Hive/Firebase but no keepAlive()${NC}"
                    ((ISSUES_FOUND++))
                fi
            fi
        fi
    fi
done
echo -e "${GREEN}  Check complete${NC}"
echo ""

# ---------------------------------------------
# CHECK 4: debugPrint inside loops
# Pattern: for/while with debugPrint inside
# ---------------------------------------------
echo "4. Checking for debugPrint inside loops..."

LOG_IN_LOOP=$(grep -rn --include="*.dart" -B 5 -E "debugPrint|print\\\(" "$SEARCH_PATH" 2>/dev/null | grep -E "for\s*\(|while\s*\(" | head -10 || true)

if [ -n "$LOG_IN_LOOP" ]; then
    echo -e "${YELLOW}  WARNING: Potential logging inside loop:${NC}"
    echo "$LOG_IN_LOOP" | head -5
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  OK${NC}"
fi
echo ""

# ---------------------------------------------
# CHECK 5: New Manager/Limiter instances (should be singleton)
# Pattern: = RateLimiter() or = SomeManager() not static
# ---------------------------------------------
echo "5. Checking for non-singleton Manager/Limiter..."

NON_SINGLETON=$(grep -rn --include="*.dart" -E "=\s*(new\s+)?(Rate|Manager|Limiter|Pool)\w*\(" "$SEARCH_PATH" | grep -v "static" | grep -v "_instance" | head -10 || true)

if [ -n "$NON_SINGLETON" ]; then
    echo -e "${YELLOW}  WARNING: Non-singleton Manager/Limiter found:${NC}"
    echo "$NON_SINGLETON" | head -5
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}  OK${NC}"
fi
echo ""

# ---------------------------------------------
# CHECK 6: Missing debounce on connectivity/auth listeners
# Pattern: onConnectivityChanged or authStateChanges without Timer/debounce
# ---------------------------------------------
echo "6. Checking for event handlers without debounce..."

EVENT_HANDLERS=$(grep -rln --include="*.dart" -E "(onConnectivityChanged|authStateChanges|onAuthStateChanged)" "$SEARCH_PATH" 2>/dev/null || true)

for file in $EVENT_HANDLERS; do
    HAS_DEBOUNCE=$(grep -l -E "(Timer|debounce|_debounce)" "$file" 2>/dev/null || true)
    if [ -z "$HAS_DEBOUNCE" ]; then
        echo -e "${YELLOW}  WARNING: $file has event listener but no debounce${NC}"
        ((ISSUES_FOUND++))
    fi
done
echo -e "${GREEN}  Check complete${NC}"
echo ""

# ---------------------------------------------
# SUMMARY
# ---------------------------------------------
echo "=============================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}  All checks passed!${NC}"
else
    echo -e "${YELLOW}  Found $ISSUES_FOUND potential issues${NC}"
    echo "  Review warnings above and fix if needed"
fi
echo "=============================================="

exit 0
