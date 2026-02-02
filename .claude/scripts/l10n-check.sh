#!/bin/bash

# Localization Completeness Checker
# Verifica che app_en.arb e app_it.arb abbiano le stesse chiavi

set -e

L10N_DIR="assets/i18n"
EN_FILE="$L10N_DIR/app_en.arb"
IT_FILE="$L10N_DIR/app_it.arb"

echo "🌍 Checking Localization Completeness..."
echo ""

# Check files exist
if [ ! -f "$EN_FILE" ]; then
    echo "❌ Error: $EN_FILE not found"
    exit 1
fi

if [ ! -f "$IT_FILE" ]; then
    echo "❌ Error: $IT_FILE not found"
    exit 1
fi

# Extract keys (lines starting with quote and not @)
EN_KEYS=$(grep '^\s*"[^@]' "$EN_FILE" | sed 's/^\s*"\([^"]*\)".*/\1/' | sort)
IT_KEYS=$(grep '^\s*"[^@]' "$IT_FILE" | sed 's/^\s*"\([^"]*\)".*/\1/' | sort)

EN_COUNT=$(echo "$EN_KEYS" | wc -l | tr -d ' ')
IT_COUNT=$(echo "$IT_KEYS" | wc -l | tr -d ' ')

echo "📊 Key Counts:"
echo "  EN: $EN_COUNT keys"
echo "  IT: $IT_COUNT keys"
echo ""

# Find missing keys
MISSING_IN_IT=$(comm -23 <(echo "$EN_KEYS") <(echo "$IT_KEYS"))
MISSING_IN_EN=$(comm -13 <(echo "$EN_KEYS") <(echo "$IT_KEYS"))

if [ -z "$MISSING_IN_IT" ] && [ -z "$MISSING_IN_EN" ]; then
    echo "✅ Perfect match! No missing keys"
    echo ""

    # Check for untranslated placeholders
    PLACEHOLDERS=$(grep -n "\[\.\.\.\]" "$EN_FILE" "$IT_FILE" 2>/dev/null || true)

    if [ -z "$PLACEHOLDERS" ]; then
        echo "✅ No '[...]' placeholders found"
    else
        echo "⚠️  Warning: Found '[...]' placeholders (not translated):"
        echo "$PLACEHOLDERS"
        exit 1
    fi

    exit 0
else
    if [ ! -z "$MISSING_IN_IT" ]; then
        echo "❌ Keys missing in IT:"
        echo "$MISSING_IN_IT" | sed 's/^/  - /'
        echo ""
    fi

    if [ ! -z "$MISSING_IN_EN" ]; then
        echo "❌ Keys missing in EN:"
        echo "$MISSING_IN_EN" | sed 's/^/  - /'
        echo ""
    fi

    exit 1
fi
