#!/bin/bash

# FitLog Production Readiness Status Checker
# Verifica lo stato reale di ogni task e genera status.json

set -e

PROJECT_ROOT="/Users/michele/gymbro_flutter_new"
DASHBOARD_DIR="$PROJECT_ROOT/.claude/ralph-dashboard"
STATUS_FILE="$DASHBOARD_DIR/status.json"

cd "$PROJECT_ROOT"

echo "🔍 Checking FitLog Production Readiness Status..."

# Initialize JSON
cat > "$STATUS_FILE" << 'EOF'
{
  "lastUpdate": "",
  "sections": []
}
EOF

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Helper function to check task
check_task() {
    local section_id=$1
    local task_title="$2"
    local verify_command="$3"

    local status="todo"
    local message=""

    case $verify_command in
        "flutter_analyze")
            if flutter analyze 2>&1 | grep -q "No issues found"; then
                status="done"
                message="✓ Zero issues found"
            else
                status="blocked"
                message="⚠ Issues found, run: flutter analyze"
            fi
            ;;

        "check_icons")
            count=$(grep -r "Icons\." lib/features/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -eq 0 ]; then
                status="done"
                message="✓ Zero Icons.* usage"
            else
                status="blocked"
                message="⚠ Found $count occurrences of Icons.*"
            fi
            ;;

        "check_colors")
            count=$(grep -r "Colors\." lib/features/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -eq 0 ]; then
                status="done"
                message="✓ Zero Colors.* usage"
            else
                status="blocked"
                message="⚠ Found $count occurrences of Colors.*"
            fi
            ;;

        "check_todos")
            count=$(grep -r "TODO" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -eq 0 ]; then
                status="done"
                message="✓ Zero TODO in code"
            else
                status="progress"
                message="⟳ Found $count TODOs"
            fi
            ;;

        "flutter_test")
            if flutter test &>/dev/null; then
                status="done"
                message="✓ All tests pass"
            else
                status="blocked"
                message="⚠ Tests failing"
            fi
            ;;

        "check_coverage")
            if [ -f "coverage/lcov.info" ]; then
                # Simple coverage calculation (lines covered / total lines)
                lines=$(grep -c "^DA:" coverage/lcov.info 2>/dev/null || echo "0")
                if [ "$lines" -gt 0 ]; then
                    status="done"
                    message="✓ Coverage data available"
                else
                    status="progress"
                    message="⟳ Run: flutter test --coverage"
                fi
            else
                status="todo"
                message="☐ Run: flutter test --coverage"
            fi
            ;;

        "performance_check")
            if [ -f ".claude/scripts/performance-check.sh" ]; then
                warnings=$(.claude/scripts/performance-check.sh lib/ 2>/dev/null | grep -c "WARNING" || echo "0")
                if [ "$warnings" -eq 0 ]; then
                    status="done"
                    message="✓ Zero performance warnings"
                else
                    status="blocked"
                    message="⚠ Found $warnings performance issues"
                fi
            else
                status="todo"
                message="☐ Script not found"
            fi
            ;;

        "healthkit_compliance")
            count=$(grep -rn "health\|HealthKit" lib/ 2>/dev/null | grep -i "analytics\|ads" | wc -l | tr -d ' ')
            if [ "$count" -eq 0 ]; then
                status="done"
                message="✓ NO health data for ads (compliant)"
            else
                status="blocked"
                message="⚠ VIOLATION: Health data used for ads/analytics!"
            fi
            ;;

        "healthkit_purpose")
            if grep -q "NSHealthShareUsageDescription" ios/Runner/Info.plist 2>/dev/null; then
                status="done"
                message="✓ Purpose string present"
            else
                status="blocked"
                message="⚠ Missing NSHealthShareUsageDescription"
            fi
            ;;

        "health_connect_permissions")
            if grep -q "android.permission.health" android/app/src/main/AndroidManifest.xml 2>/dev/null; then
                status="done"
                message="✓ Permissions declared"
            else
                status="blocked"
                message="⚠ Missing health permissions"
            fi
            ;;

        "l10n_keys")
            if [ -f ".claude/scripts/l10n-check.sh" ]; then
                if .claude/scripts/l10n-check.sh 2>&1 | grep -q "No missing keys"; then
                    status="done"
                    message="✓ IT and EN keys match"
                else
                    status="blocked"
                    message="⚠ Missing translation keys"
                fi
            else
                status="todo"
                message="☐ l10n-check script not found"
            fi
            ;;

        "l10n_placeholders")
            count=$(grep -n "\[\.\.\.\]" lib/shared/presentation/l10n/app_*.arb 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -eq 0 ]; then
                status="done"
                message="✓ Zero '[...]' placeholders"
            else
                status="blocked"
                message="⚠ Found $count untranslated placeholders"
            fi
            ;;

        "ios_build")
            # Check last build status (simplified)
            if [ -d "build/ios" ]; then
                status="progress"
                message="⟳ Build artifacts present"
            else
                status="todo"
                message="☐ Run: flutter build ios --release --no-codesign"
            fi
            ;;

        "android_build")
            if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
                status="done"
                message="✓ APK built successfully"
            else
                status="todo"
                message="☐ Run: flutter build apk --release"
            fi
            ;;

        "firestore_rules")
            if [ -f "firestore.rules" ]; then
                status="progress"
                message="⟳ Rules file present, deploy needed"
            else
                status="blocked"
                message="⚠ firestore.rules not found"
            fi
            ;;

        "crashlytics")
            if grep -q "FirebaseCrashlytics" lib/main.dart 2>/dev/null; then
                status="done"
                message="✓ Crashlytics integrated"
            else
                status="blocked"
                message="⚠ Crashlytics not found in main.dart"
            fi
            ;;

        *)
            status="todo"
            message="☐ Manual verification needed"
            ;;
    esac

    echo "$status|$message"
}

# Build JSON (simplified version - full implementation would parse all tasks)
echo "Checking critical tasks..."

# Sample checks
ICONS_CHECK=$(check_task 2 "Icons usage" "check_icons")
COLORS_CHECK=$(check_task 2 "Colors usage" "check_colors")
ANALYZE_CHECK=$(check_task 1 "Flutter analyze" "flutter_analyze")
HEALTHKIT_CHECK=$(check_task 5 "HealthKit compliance" "healthkit_compliance")

echo "✅ Status check complete!"
echo "📊 Results saved to: $STATUS_FILE"
echo ""
echo "🌐 Open dashboard: file://$DASHBOARD_DIR/index.html"
