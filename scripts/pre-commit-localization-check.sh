#!/bin/bash

# Pre-commit hook to detect localization violations
# Prevents commits with hardcoded strings

echo "🌍 Checking for localization violations..."

# Get list of staged Dart files in presentation layer
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$" | grep -E "(presentation|screens|widgets)")

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No presentation layer files to check"
    exit 0
fi

VIOLATIONS_FOUND=0

# Function to check file for violations
check_file() {
    local file="$1"
    local violations=0

    # Skip generated files and tests
    if [[ "$file" == *"/generated/"* ]] || [[ "$file" == *"_test.dart" ]]; then
        return 0
    fi

    # Check for Text('...') without localization
    if grep -q "Text(['\"]" "$file" && ! grep -q "context.l10n" "$file" && ! grep -q "AppLocalizations" "$file"; then
        local count=$(grep "Text(['\"]" "$file" | grep -v "context.l10n" | grep -v "AppLocalizations" | grep -v "Text('')" | grep -v 'Text("")' | wc -l | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            echo "⚠️  $file: $count potential hardcoded Text widgets"
            violations=$((violations + count))
        fi
    fi

    # Check for SnackBar without localization
    if grep -q "SnackBar" "$file" && grep -q "content:" "$file"; then
        local count=$(grep "SnackBar" "$file" | grep "content:" | grep -v "context.l10n" | grep -v "AppLocalizations" | wc -l | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            echo "⚠️  $file: $count potential hardcoded SnackBar messages"
            violations=$((violations + count))
        fi
    fi

    # Check for showDialog without localization
    if grep -q "showDialog" "$file" && grep -q "title:" "$file"; then
        local count=$(grep -A 5 "showDialog" "$file" | grep -E "(title:|content:)" | grep "Text(['\"]" | grep -v "context.l10n" | grep -v "AppLocalizations" | wc -l | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            echo "⚠️  $file: $count potential hardcoded Dialog messages"
            violations=$((violations + count))
        fi
    fi

    return $violations
}

# Check each staged file
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        check_file "$file"
        file_violations=$?
        VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + file_violations))
    fi
done

if [ $VIOLATIONS_FOUND -gt 0 ]; then
    echo ""
    echo "❌ COMMIT BLOCKED: Found $VIOLATIONS_FOUND potential localization violations"
    echo ""
    echo "📋 To fix:"
    echo "1. Import: import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';"
    echo "2. Replace: Text('...') → Text(context.l10n.keyName)"
    echo "3. Add keys to assets/i18n/app_en.arb and app_it.arb"
    echo "4. Run: flutter gen-l10n"
    echo ""
    echo "📖 See: LOCALIZATION_QUICK_FIX_GUIDE.md"
    echo ""
    echo "⚠️  To bypass this check (NOT recommended): git commit --no-verify"
    exit 1
fi

echo "✅ No localization violations detected"
exit 0
