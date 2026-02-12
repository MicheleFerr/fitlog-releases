#!/bin/bash
# TaskCompleted Hook - Quality Gate for Agent Team Tasks
# Ensures teammates document findings properly before marking tasks complete

TASK_ID="$1"
TASK_SUBJECT="$2"
TASK_DESCRIPTION="$3"
TASK_STATUS="$4"

# Only run for completion (not for other updates)
if [ "$TASK_STATUS" != "completed" ]; then
    exit 0
fi

# Skip for non-verification tasks
if [[ "$TASK_SUBJECT" != *"Verify"* && "$TASK_SUBJECT" != *"Check"* && "$TASK_SUBJECT" != *"Review"* ]]; then
    exit 0
fi

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check 1: Must include severity rating
if [[ "$TASK_DESCRIPTION" != *"P0"* && "$TASK_DESCRIPTION" != *"P1"* && "$TASK_DESCRIPTION" != *"P2"* && "$TASK_DESCRIPTION" != *"P3"* ]]; then
    echo -e "${RED}❌ Quality Gate Failed: Task must include severity ratings${NC}"
    echo ""
    echo "Verification tasks must categorize findings:"
    echo "  - P0: Blocker (prevents launch)"
    echo "  - P1: Critical (major impact)"
    echo "  - P2: Important (should fix)"
    echo "  - P3: Nice-to-have (document)"
    echo ""
    echo "Add severity ratings to task description before marking complete."
    exit 2  # Block completion
fi

# Check 2: Must include summary counts
if [[ "$TASK_DESCRIPTION" != *"✅"* && "$TASK_DESCRIPTION" != *"Passed"* ]]; then
    echo -e "${YELLOW}⚠️  Warning: Task missing summary counts${NC}"
    echo ""
    echo "Best practice: Include summary like:"
    echo "  - ✅ Passed: X items"
    echo "  - ⚠️ Warnings: Y items"
    echo "  - ❌ Blockers: Z items"
    echo ""
    echo "Continue anyway? This is a warning, not a blocker."
    # Don't block, just warn
fi

# Check 3: Must include recommendation for verification tasks
if [[ "$TASK_SUBJECT" == *"Verify"* || "$TASK_SUBJECT" == *"Review"* ]]; then
    if [[ "$TASK_DESCRIPTION" != *"GO"* && "$TASK_DESCRIPTION" != *"NO-GO"* && "$TASK_DESCRIPTION" != *"CONDITIONAL"* ]]; then
        echo -e "${YELLOW}⚠️  Warning: Verification task missing GO/NO-GO recommendation${NC}"
        echo ""
        echo "Consider adding recommendation: [GO / NO-GO / CONDITIONAL]"
        # Don't block, just warn
    fi
fi

# All quality gates passed
exit 0
