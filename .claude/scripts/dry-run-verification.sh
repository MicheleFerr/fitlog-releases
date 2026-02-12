#!/bin/bash
# Dry Run - Test Agent Team System with Limited Scope
# Tests the verification infrastructure without full beta verification

set -e

echo "🧪 DRY RUN: Agent Team Verification Test"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}ℹ️  This is a dry run to test the agent team infrastructure${NC}"
echo "   Scope: Limited to code quality checks only"
echo "   Duration: ~5-10 minutes"
echo "   Agents: 2 (Code Guardian + QA Specialist)"
echo ""

# 1. Run pre-verification
echo "1️⃣  Running pre-verification checks..."
echo ""
if .claude/scripts/pre-verification.sh; then
    echo ""
    echo -e "${GREEN}✅ Pre-checks passed${NC}"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  Blockers found, but continuing dry run for testing${NC}"
    fi
fi
echo ""

# 2. Create dry-run report directory
DRY_RUN_DIR="docs/verification-reports/dry-runs"
mkdir -p "$DRY_RUN_DIR"

REPORT_FILE="$DRY_RUN_DIR/dry-run-$(date +%Y%m%d-%H%M%S).md"

# 3. Generate dry-run prompt
echo "2️⃣  Generating dry-run prompt..."
echo ""

cat > /tmp/dry-run-prompt.txt << 'EOF'
Create a small agent team to test the beta verification infrastructure.

This is a DRY RUN - test with limited scope only:

**Spawn 2 teammates (both Sonnet):**

1. **Code Guardian (Dry Run)**
   - Check ONLY files in `lib/features/settings/` for:
     - Pre-commit rules (AppIcons.*, context.l10n.*, context.colors.*)
     - iOS compliance (no `const` with context.l10n)
   - Run: `flutter analyze lib/features/settings/`
   - Report findings with severity (P0-P3)
   - Estimate: 3-5 minutes

2. **QA Specialist (Dry Run)**
   - Run ONLY settings-related tests:
     - `flutter test test/features/settings/ --no-sound-null-safety`
   - Check if tests exist and pass
   - Document any failures
   - Estimate: 3-5 minutes

**Team Coordination:**
- Each teammate reports using format from docs/BETA_LAUNCH_AGENT_TEAM.md
- Include severity ratings (P0-P3) in findings
- Notify lead when complete

**Lead Tasks:**
- After both teammates finish, synthesize findings
- Generate GO/NO-GO for infrastructure test (not actual beta launch)
- Test the reporting format and quality gates

This dry run validates:
✅ Agent team spawn/coordination works
✅ Reporting format is clear
✅ Quality gates (TaskCompleted hook) function
✅ Scripts execute properly

DO NOT run full beta verification - this is infrastructure testing only.
EOF

echo -e "${GREEN}✅ Prompt generated${NC}"
echo ""

# 4. Display prompt
echo "3️⃣  Dry Run Prompt"
echo "-------------------"
echo ""
cat /tmp/dry-run-prompt.txt
echo ""
echo ""

# 5. Instructions
echo "================================"
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "================================"
echo ""
echo "1. Copy the prompt above"
echo ""
echo "2. In another terminal, run:"
echo "   $ cd /Users/michele/gymbro_flutter_new"
echo "   $ claude --teammate-mode tmux"
echo ""
echo "3. Paste the dry-run prompt"
echo ""
echo "4. Observe:"
echo "   - Do teammates spawn correctly?"
echo "   - Do they follow the reporting format?"
echo "   - Does TaskCompleted hook enforce quality gates?"
echo "   - Does lead synthesize properly?"
echo ""
echo "5. After completion, run:"
echo "   $ .claude/scripts/post-verification.sh $REPORT_FILE"
echo ""
echo "6. Review generated report and verify format"
echo ""
echo ""
echo -e "${YELLOW}💡 Troubleshooting:${NC}"
echo "   - If teammates don't appear: Check ~/.claude/settings.json"
echo "   - If no split panes: Ensure tmux installed (brew install tmux)"
echo "   - If permission prompts: Pre-approvals should be in settings"
echo "   - If TaskCompleted doesn't trigger: Check hook is executable"
echo ""
echo "Report will be saved to: $REPORT_FILE"
echo ""

# Save prompt to file for easy access
echo "💾 Prompt also saved to: /tmp/dry-run-prompt.txt"
echo "   Run: cat /tmp/dry-run-prompt.txt | pbcopy"
