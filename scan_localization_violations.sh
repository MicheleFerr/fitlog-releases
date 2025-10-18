#!/bin/bash

# Comprehensive Localization Violation Scanner for GymBro
# Scans for hardcoded strings that should use AppLocalizations/context.l10n

echo "🔍 GymBro Localization Violation Scanner"
echo "=========================================="
echo ""

VIOLATIONS_FILE="/tmp/localization_violations.txt"
> "$VIOLATIONS_FILE"

violation_count=0

# Function to check file for violations
check_file() {
    local file="$1"
    local basename=$(basename "$file")

    # Skip generated files, tests, and backups
    if [[ "$file" == *"/generated/"* ]] || [[ "$file" == *"_test.dart" ]] || [[ "$file" == *".backup" ]]; then
        return
    fi

    # Pattern 1: Text('...') or Text("...") with hardcoded strings (not empty, not variables)
    grep -n "Text(['\"]" "$file" | grep -v "context.l10n" | grep -v "AppLocalizations" | grep -v "Text('')" | grep -v 'Text("")' | grep -v "//" | while IFS=: read -r line_num line_content; do
        # Extract the string content
        string=$(echo "$line_content" | sed -n "s/.*Text(['\"]\\([^'\"]*\\)['\"].*/\\1/p")
        if [[ -n "$string" && "$string" != "\$"* ]]; then
            echo "CRITICAL|$file|$line_num|Text widget|$string" >> "$VIOLATIONS_FILE"
            ((violation_count++))
        fi
    done

    # Pattern 2: AppBar(title: Text(...))
    grep -n "AppBar" "$file" | grep "title:" | grep -v "context.l10n" | grep -v "AppLocalizations" | while IFS=: read -r line_num line_content; do
        if echo "$line_content" | grep -q "Text(['\"]"; then
            string=$(echo "$line_content" | sed -n "s/.*Text(['\"]\\([^'\"]*\\)['\"].*/\\1/p")
            if [[ -n "$string" ]]; then
                echo "CRITICAL|$file|$line_num|AppBar title|$string" >> "$VIOLATIONS_FILE"
                ((violation_count++))
            fi
        fi
    done

    # Pattern 3: SnackBar(content: Text(...))
    grep -n "SnackBar" "$file" | grep "content:" | grep -v "context.l10n" | grep -v "AppLocalizations" | while IFS=: read -r line_num line_content; do
        if echo "$line_content" | grep -q "Text(['\"]"; then
            string=$(echo "$line_content" | sed -n "s/.*Text(['\"]\\([^'\"]*\\)['\"].*/\\1/p")
            if [[ -n "$string" ]]; then
                echo "CRITICAL|$file|$line_num|SnackBar|$string" >> "$VIOLATIONS_FILE"
                ((violation_count++))
            fi
        fi
    done

    # Pattern 4: showDialog with hardcoded title/content
    grep -n "showDialog" "$file" -A 10 | grep -E "(title:|content:)" | grep "Text(['\"]" | grep -v "context.l10n" | grep -v "AppLocalizations" | while IFS=: read -r line_num line_content; do
        if echo "$line_content" | grep -q "Text(['\"]"; then
            string=$(echo "$line_content" | sed -n "s/.*Text(['\"]\\([^'\"]*\\)['\"].*/\\1/p")
            if [[ -n "$string" ]]; then
                echo "CRITICAL|$file|$line_num|Dialog|$string" >> "$VIOLATIONS_FILE"
                ((violation_count++))
            fi
        fi
    done

    # Pattern 5: InputDecoration(hintText:, labelText:, errorText:)
    grep -n -E "(hintText:|labelText:|errorText:|helperText:)" "$file" | grep "['\"]" | grep -v "context.l10n" | grep -v "AppLocalizations" | while IFS=: read -r line_num line_content; do
        string=$(echo "$line_content" | sed -n "s/.*Text:[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p")
        if [[ -z "$string" ]]; then
            string=$(echo "$line_content" | sed -n "s/.*:[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p")
        fi
        if [[ -n "$string" ]]; then
            echo "CRITICAL|$file|$line_num|Form field|$string" >> "$VIOLATIONS_FILE"
            ((violation_count++))
        fi
    done

    # Pattern 6: throw Exception with hardcoded message
    grep -n "throw " "$file" | grep -v "context.l10n" | grep -v "AppLocalizations" | while IFS=: read -r line_num line_content; do
        if echo "$line_content" | grep -qE "throw.*['\"]"; then
            string=$(echo "$line_content" | sed -n "s/.*throw.*['\"]\\([^'\"]*\\)['\"].*/\\1/p")
            if [[ -n "$string" ]]; then
                echo "LOW|$file|$line_num|Exception message|$string" >> "$VIOLATIONS_FILE"
                ((violation_count++))
            fi
        fi
    done
}

# Scan all presentation layer files
echo "📂 Scanning presentation layer files..."
while IFS= read -r file; do
    check_file "$file"
done < <(find /Users/michele/gymbro_flutter_new/lib/features -name "*.dart" -path "*/presentation/*" -type f)

# Scan shared presentation files
while IFS= read -r file; do
    check_file "$file"
done < <(find /Users/michele/gymbro_flutter_new/lib/shared/presentation -name "*.dart" -type f)

# Count violations
total_violations=$(wc -l < "$VIOLATIONS_FILE" | tr -d ' ')

echo ""
echo "📊 SCAN RESULTS"
echo "==============="
echo "Total violations found: $total_violations"
echo ""

if [[ $total_violations -eq 0 ]]; then
    echo "✅ No localization violations found!"
    exit 0
fi

# Group by severity
critical=$(grep "^CRITICAL" "$VIOLATIONS_FILE" | wc -l | tr -d ' ')
low=$(grep "^LOW" "$VIOLATIONS_FILE" | wc -l | tr -d ' ')

echo "🔴 Critical (user-facing): $critical"
echo "🟡 Low (internal/debug): $low"
echo ""
echo "📋 DETAILED VIOLATIONS:"
echo "======================="
echo ""

# Sort by file and display
current_file=""
while IFS='|' read -r severity file line_num type string; do
    # Clean up file path
    short_file=$(echo "$file" | sed 's|/Users/michele/gymbro_flutter_new/||')

    if [[ "$file" != "$current_file" ]]; then
        echo ""
        echo "📄 $short_file"
        echo "   $(echo "$short_file" | sed 's/./-/g')"
        current_file="$file"
    fi

    # Icon based on severity
    if [[ "$severity" == "CRITICAL" ]]; then
        icon="🔴"
    else
        icon="🟡"
    fi

    echo "   $icon Line $line_num: $type"
    echo "      Hardcoded: \"$string\""

    # Suggest key name
    key_name=$(echo "$string" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_' | cut -c1-40)
    echo "      Suggested key: $key_name"
    echo ""
done < "$VIOLATIONS_FILE"

echo ""
echo "💡 NEXT STEPS:"
echo "=============="
echo "1. Add missing keys to assets/i18n/app_en.arb and app_it.arb"
echo "2. Run: flutter gen-l10n"
echo "3. Replace hardcoded strings with context.l10n.keyName"
echo "4. Import build_context_extensions.dart in affected files"
echo ""

# Save full report
REPORT_FILE="/Users/michele/gymbro_flutter_new/LOCALIZATION_VIOLATIONS_REPORT.txt"
cp "$VIOLATIONS_FILE" "$REPORT_FILE"
echo "📝 Full report saved to: LOCALIZATION_VIOLATIONS_REPORT.txt"

exit 1
