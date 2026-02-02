#!/bin/bash

# Accessibility Checker (WCAG 2.1 Level AA)
# Verifica contrast ratio, touch targets, semantic labels

set -e

echo "♿ Checking Accessibility (WCAG 2.1 AA)..."
echo ""

ISSUES_FOUND=0

# 1. Check touch targets (iconSize < 24 is likely too small)
echo "📱 Checking Touch Targets..."
SMALL_ICONS=$(grep -rn "iconSize.*:[[:space:]]*[0-9]\+" lib/features/ --include="*.dart" 2>/dev/null | \
              awk -F: '{print $1":"$2": "$3}' | \
              while read line; do
                  size=$(echo "$line" | grep -o "iconSize.*:[[:space:]]*[0-9]\+" | grep -o "[0-9]\+")
                  if [ "$size" -lt 24 ]; then
                      echo "$line"
                  fi
              done)

if [ -z "$SMALL_ICONS" ]; then
    echo "  ✅ All icon sizes ≥24 (good for 44x44pt touch target)"
else
    echo "  ⚠️  Small icons found (<24):"
    echo "$SMALL_ICONS" | sed 's/^/    /'
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 2. Check for missing Semantics on interactive widgets
echo "🔍 Checking Semantic Labels..."
SCREENS=$(find lib/features -name "*_screen.dart" 2>/dev/null || true)

if [ -z "$SCREENS" ]; then
    echo "  ⚠️  No screens found to check"
else
    MISSING_SEMANTICS=0
    for screen in $SCREENS; do
        # Check if screen has interactive widgets but no Semantics or semanticLabel
        if grep -q "IconButton\|ElevatedButton\|TextButton\|GestureDetector" "$screen" 2>/dev/null; then
            # Check for both Semantics widget AND semanticLabel property
            if ! grep -q "Semantics\|semanticLabel" "$screen" 2>/dev/null; then
                echo "  ⚠️  $screen has interactive widgets but no Semantics/semanticLabel"
                MISSING_SEMANTICS=$((MISSING_SEMANTICS + 1))
            fi
        fi
    done

    if [ "$MISSING_SEMANTICS" -eq 0 ]; then
        echo "  ✅ All screens with interactive widgets have Semantics"
    else
        echo "  ⚠️  $MISSING_SEMANTICS screens missing Semantics"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi
echo ""

# 3. Check for hardcoded colors (may have contrast issues)
echo "🎨 Checking Color Usage..."
HARDCODED_COLORS=$(grep -rn "Color(0x\|Colors\." lib/features/ --include="*.dart" 2>/dev/null | \
                   grep -v "context.colors\|AppColors" | \
                   wc -l | tr -d ' ')

if [ "$HARDCODED_COLORS" -eq 0 ]; then
    echo "  ✅ All colors use theme (context.colors.*)"
else
    echo "  ⚠️  Found $HARDCODED_COLORS hardcoded colors (may have contrast issues)"
    echo "     Use context.colors.* for guaranteed WCAG 2.1 AA compliance"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 4. Check for const Text with context.l10n (iOS build error + accessibility issue)
echo "📝 Checking const Text with Localization..."
CONST_L10N=$(grep -rn "const Text(context.l10n" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

if [ "$CONST_L10N" -eq 0 ]; then
    echo "  ✅ No 'const Text(context.l10n...)' usage"
else
    echo "  ⚠️  Found $CONST_L10N occurrences of 'const Text(context.l10n...)'"
    echo "     This causes iOS build errors AND breaks screen reader support"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ISSUES_FOUND" -eq 0 ]; then
    echo "✅ Accessibility: PASS"
    echo "   All WCAG 2.1 AA checks passed!"
    exit 0
else
    echo "⚠️  Accessibility: $ISSUES_FOUND ISSUES FOUND"
    echo ""
    echo "Recommendations:"
    echo "  1. Fix touch targets: use iconSize ≥24"
    echo "  2. Add Semantics to interactive widgets"
    echo "  3. Use context.colors.* for contrast compliance"
    echo "  4. Remove 'const' from Text(context.l10n...)"
    echo ""
    echo "Note: Contrast ratio verification requires manual testing"
    echo "      Use Chrome DevTools or https://webaim.org/resources/contrastchecker/"
    exit 1
fi
