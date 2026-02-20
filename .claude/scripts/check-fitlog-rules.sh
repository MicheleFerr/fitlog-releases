#!/bin/bash
# FitLog Rules Enforcer
# Validates code changes against project conventions
# Used by PreToolUse hook to block violations

set -e

# Read the tool input from stdin (JSON with file content)
input=$(cat)

# Extract the new content - handle both Edit and Write tools
# For Edit: look at new_string field
# For Write: look at content field
content=$(echo "$input" | jq -r '.new_string // .content // empty' 2>/dev/null)

# If no content found, pass through
if [ -z "$content" ]; then
    exit 0
fi

# Also get the file path to check if it's a Dart file
file_path=$(echo "$input" | jq -r '.file_path // empty' 2>/dev/null)

# Only check Dart files
if [[ "$file_path" != *.dart ]]; then
    exit 0
fi

# Skip generated files
if [[ "$file_path" == *"/generated/"* ]] || [[ "$file_path" == *".g.dart" ]] || [[ "$file_path" == *".freezed.dart" ]]; then
    exit 0
fi

errors=""

# Rule 1: Icons.* instead of AppIcons.*
# Match Icons.xxx but not AppIcons.xxx
if echo "$content" | grep -E '\bIcons\.[a-z_]+' | grep -v 'AppIcons' > /dev/null 2>&1; then
    errors+="  - Icons.* detected - use AppIcons.* instead\n"
fi

# Rule 2: Colors.* instead of context.colors.*
# Match Colors.xxx (like Colors.blue, Colors.red)
if echo "$content" | grep -E '\bColors\.[a-z]+' > /dev/null 2>&1; then
    errors+="  - Colors.* detected - use context.colors.* instead\n"
fi

# Rule 3: Hardcoded strings in Text widgets
# Match Text('Something') or Text("Something") with capital letter start
if echo "$content" | grep -E "Text\s*\(\s*['\"][A-Z][^'\"]*['\"]" > /dev/null 2>&1; then
    # Exclude some allowed patterns
    if ! echo "$content" | grep -E "Text\s*\(\s*['\"][\$\{]" > /dev/null 2>&1; then
        errors+="  - Hardcoded string in Text() - use context.l10n.* instead\n"
    fi
fi

# Rule 4: CircularProgressIndicator instead of LoadingIndicator
if echo "$content" | grep -E '\bCircularProgressIndicator\s*\(' > /dev/null 2>&1; then
    errors+="  - CircularProgressIndicator detected - use LoadingIndicator() instead\n"
fi

# Rule 5: ScaffoldMessenger instead of SnackBarService
if echo "$content" | grep -E '\bScaffoldMessenger\.' > /dev/null 2>&1; then
    errors+="  - ScaffoldMessenger detected - use SnackBarService.* instead\n"
fi

# Rule 6: const with context.l10n (iOS build error)
if echo "$content" | grep -E 'const\s+Text\s*\(\s*context\.l10n' > /dev/null 2>&1; then
    errors+="  - const with context.l10n detected - remove const (iOS build error)\n"
fi

# Rule 7: Direct icon size numbers instead of AppIconSize
if echo "$content" | grep -E 'Icon\s*\([^)]*size:\s*[0-9]+' > /dev/null 2>&1; then
    errors+="  - Hardcoded icon size - use AppIconSize.* instead\n"
fi

# Rule 8: StateProvider (removed in Riverpod 3.x)
if echo "$content" | grep -E '\bStateProvider\s*<' > /dev/null 2>&1; then
    errors+="  - StateProvider removed in Riverpod 3.x - use createStateProvider<T>(value) from state_provider_helper.dart\n"
fi

# Rule 9: Direct Hive.openBox (should use HiveBoxManagerEnhanced)
if echo "$content" | grep -E '\bHive\.openBox\s*\(' > /dev/null 2>&1; then
    errors+="  - Direct Hive.openBox() - use HiveBoxManagerEnhanced().openBox() instead\n"
fi

# Rule 10: Hardcoded route paths (should use AppRoutes constants)
if echo "$content" | grep -E "context\.(go|push|goNamed|pushNamed)\s*\(\s*['\"]/" > /dev/null 2>&1; then
    errors+="  - Hardcoded route path - use AppRoutes.* constants from app_routes.dart\n"
fi

# Output errors if any
if [ -n "$errors" ]; then
    echo ""
    echo "======================================"
    echo "FitLog Rules Enforcer - VIOLATIONS"
    echo "======================================"
    echo ""
    echo "File: $file_path"
    echo ""
    echo "Issues found:"
    echo -e "$errors"
    echo ""
    echo "Reference: See CLAUDE.md for correct patterns"
    echo "======================================"
    echo ""
    # Exit with error to block the operation
    exit 1
fi

# All good
exit 0
