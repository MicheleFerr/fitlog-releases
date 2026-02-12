#!/bin/bash
# Pre-Verification Setup Script
# Prepara l'ambiente per la verifica beta con agent teams

set -e  # Exit on error

echo "🔍 Beta Verification Pre-Check"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track issues
WARNINGS=0
BLOCKERS=0

# Function to report
report_ok() {
    echo -e "${GREEN}✅ $1${NC}"
}

report_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

report_blocker() {
    echo -e "${RED}❌ $1${NC}"
    ((BLOCKERS++))
}

# 1. Check Git State
echo "1️⃣  Git State Check"
echo "-------------------"

if ! git diff-index --quiet HEAD --; then
    report_warning "Uncommitted changes detected"
    echo "   Run: git status"
else
    report_ok "Git working directory clean"
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "   Current branch: $CURRENT_BRANCH"

if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "beta-candidate"* ]]; then
    report_warning "Not on main or beta-candidate branch"
    echo "   Consider: git checkout -b beta-candidate-$(date +%Y%m%d)"
fi
echo ""

# 2. Check Dependencies
echo "2️⃣  Dependencies Check"
echo "---------------------"

if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    report_ok "Flutter: $FLUTTER_VERSION"
else
    report_blocker "Flutter not found in PATH"
fi

if command -v dart &> /dev/null; then
    DART_VERSION=$(dart --version 2>&1 | head -n 1)
    report_ok "Dart: $DART_VERSION"
else
    report_blocker "Dart not found in PATH"
fi
echo ""

# 3. Check Flutter Packages
echo "3️⃣  Flutter Packages"
echo "-------------------"

if [ -f "pubspec.lock" ]; then
    report_ok "pubspec.lock exists"

    # Check if packages are up to date
    if flutter pub get --dry-run 2>&1 | grep -q "Changed"; then
        report_warning "Packages need updating"
        echo "   Run: flutter pub get"
    else
        report_ok "Packages up to date"
    fi
else
    report_blocker "pubspec.lock not found"
fi
echo ""

# 4. Check Localization
echo "4️⃣  Localization"
echo "----------------"

if [ -d "lib/shared/presentation/l10n/generated" ]; then
    L10N_FILES=$(find lib/shared/presentation/l10n/generated -name "*.dart" | wc -l)
    if [ "$L10N_FILES" -gt 0 ]; then
        report_ok "Localization files generated ($L10N_FILES files)"
    else
        report_warning "No localization files found"
        echo "   Run: flutter gen-l10n"
    fi
else
    report_warning "Localization directory missing"
    echo "   Run: flutter gen-l10n"
fi
echo ""

# 5. Check Agent Teams Setup
echo "5️⃣  Agent Teams Configuration"
echo "-----------------------------"

if [ -f "$HOME/.claude/settings.json" ]; then
    if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "$HOME/.claude/settings.json"; then
        report_ok "Agent teams enabled in settings"
    else
        report_blocker "Agent teams NOT enabled"
        echo "   Add to ~/.claude/settings.json:"
        echo '   "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }'
    fi
else
    report_blocker "Claude settings.json not found"
fi

if command -v tmux &> /dev/null; then
    TMUX_VERSION=$(tmux -V)
    report_ok "tmux: $TMUX_VERSION"
else
    report_warning "tmux not installed (split panes unavailable)"
    echo "   Install: brew install tmux"
fi
echo ""

# 6. Check CI/CD Status (if applicable)
echo "6️⃣  CI/CD Pipeline"
echo "------------------"

if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
    report_ok "GitHub Actions workflows found ($WORKFLOW_COUNT)"
else
    echo "   ℹ️  No GitHub Actions detected"
fi
echo ""

# 7. Check Critical Scripts
echo "7️⃣  Verification Scripts"
echo "------------------------"

REQUIRED_SCRIPTS=(
    ".claude/scripts/performance-check.sh"
    ".claude/scripts/health-check.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            report_ok "$(basename "$script")"
        else
            report_warning "$(basename "$script") not executable"
            echo "   Run: chmod +x $script"
        fi
    else
        report_blocker "$(basename "$script") not found"
    fi
done
echo ""

# 8. Create Report Directory
echo "8️⃣  Report Directory"
echo "-------------------"

REPORT_DIR="docs/verification-reports"
if [ ! -d "$REPORT_DIR" ]; then
    mkdir -p "$REPORT_DIR"
    report_ok "Created $REPORT_DIR"
else
    report_ok "Report directory exists"
fi
echo ""

# 9. Summary
echo "================================"
echo "📊 Pre-Verification Summary"
echo "================================"
echo ""

if [ $BLOCKERS -gt 0 ]; then
    echo -e "${RED}❌ BLOCKED: $BLOCKERS critical issue(s) found${NC}"
    echo "   Fix blockers before launching agent team"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS: $WARNINGS non-critical issue(s) found${NC}"
    echo "   Review warnings but safe to proceed"
    exit 0
else
    echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
    echo "   Ready to launch agent team!"
    exit 0
fi
