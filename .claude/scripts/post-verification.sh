#!/bin/bash
# Post-Verification Report Generator
# Processes agent team findings and generates final report

set -e

echo "📊 Beta Verification Post-Processing"
echo "====================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arguments
REPORT_FILE="${1:-docs/verification-reports/beta-verification-$(date +%Y%m%d-%H%M%S).md}"

if [ $# -eq 0 ]; then
    echo -e "${BLUE}ℹ️  No report file specified, using: $REPORT_FILE${NC}"
    echo ""
fi

# Ensure directory exists
mkdir -p "$(dirname "$REPORT_FILE")"

# Get git info
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_STATUS=$(git status --short | wc -l)

# Generate report header
cat > "$REPORT_FILE" << EOF
# 🧪 Beta Launch Verification Report

**Date**: $(date +"%Y-%m-%d %H:%M:%S")
**Branch**: \`$GIT_BRANCH\`
**Commit**: \`$GIT_COMMIT\`
**Uncommitted Changes**: $GIT_STATUS files

---

## 📋 Executive Summary

> **DECISION**: [GO / NO-GO / CONDITIONAL] - _TO BE FILLED BY TEAM LEAD_

### Overview
- **P0 Blockers**: _[Count]_ - Must fix before launch
- **P1 Critical**: _[Count]_ - Significant impact
- **P2 Important**: _[Count]_ - Should address
- **P3 Nice-to-Have**: _[Count]_ - Document for later

### Key Findings
_[Summary of most important findings from all agents]_

---

## 🤖 Agent Team Reports

### 1️⃣ Code Guardian 🛡️

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Findings
_[Paste Code Guardian report here]_

---

### 2️⃣ QA Specialist 🧪

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Findings
_[Paste QA Specialist report here]_

---

### 3️⃣ Backend Auditor ☁️

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Findings
_[Paste Backend Auditor report here]_

---

### 4️⃣ UX Personas Inspector 👥

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Persona Impact Analysis
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco (Principiante) | _[++/+/0/-/--]_ | _[Notes]_ |
| Chiara (Multitasking) | _[++/+/0/-/--]_ | _[Notes]_ |
| Luca (Powerlifter) | _[++/+/0/-/--]_ | _[Notes]_ |
| Sofia (Estetica) | _[++/+/0/-/--]_ | _[Notes]_ |
| Roberto (Busy) | _[++/+/0/-/--]_ | _[Notes]_ |

#### Findings
_[Paste UX Personas Inspector report here]_

---

### 5️⃣ Docs & Compliance Officer 📚

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Findings
_[Paste Docs & Compliance Officer report here]_

---

### 6️⃣ Deployment Checker 🚀

#### Summary
- ✅ **Passed**: _[Count]_
- ⚠️ **Warnings**: _[Count]_
- ❌ **Blockers**: _[Count]_

#### Findings
_[Paste Deployment Checker report here]_

---

## 📋 Consolidated Issues

### 🚨 P0 Blockers (MUST FIX)
_[List all P0 issues from all agents]_

### ⚠️ P1 Critical Issues
_[List all P1 issues from all agents]_

### 📌 P2 Important Issues
_[List all P2 issues from all agents]_

### 💡 P3 Nice-to-Have
_[List all P3 issues from all agents]_

---

## ✅ Manual Verification Checklist

### Device Testing
- [ ] iPhone 12 Pro (iOS 16.0+) - Critical flows
- [ ] iPhone SE 2020 (small screen) - Layout verification
- [ ] Pixel 5 (Android 12+) - Critical flows
- [ ] Galaxy A52 (mid-range) - Performance verification

### Edge Cases
- [ ] App kill during active workout
- [ ] Network loss during sync
- [ ] Low battery mode (iOS/Android)
- [ ] Background app refresh disabled
- [ ] Clock/timezone changes

### Critical User Flows
- [ ] Onboarding: Signup → Profile → First workout
- [ ] Workout: Template → Start → Timer → Complete
- [ ] Live Activities: Lock screen updates (iOS)
- [ ] Sync: Offline changes → Conflict resolution
- [ ] XP System: Workout completion → Tier progression

---

## 🎯 GO/NO-GO Decision Matrix

### Automatic GO (If All True)
- [ ] Zero P0 blockers
- [ ] Zero P1 critical issues OR max 3 with workarounds
- [ ] All automated tests passing (>95%)
- [ ] Firebase rules production-ready
- [ ] iOS build compiles successfully

### Automatic NO-GO (If Any True)
- [ ] 1+ P0 blockers unresolved
- [ ] 4+ P1 critical issues
- [ ] Test suite failure rate >5%
- [ ] Firebase security rules not tested
- [ ] iOS build fails

### Decision: _[GO / NO-GO / CONDITIONAL]_

**Rationale**: _[Explain decision]_

**Conditions** (if conditional): _[List what needs to be addressed]_

---

## 📝 Action Items

### Immediate (Before Beta Launch)
_[List P0 and critical P1 issues to fix]_

### Short-term (Within 1 week of launch)
_[List P1-P2 issues to address post-launch]_

### Long-term (Future releases)
_[List P3 and nice-to-have improvements]_

---

## 📊 Sign-Off Table

| Area | Status | Sign-off | Date |
|------|--------|----------|------|
| Code Quality | ⬜ | _[Name]_ | _[Date]_ |
| Performance | ⬜ | _[Name]_ | _[Date]_ |
| UX (Personas) | ⬜ | _[Name]_ | _[Date]_ |
| Backend | ⬜ | _[Name]_ | _[Date]_ |
| Testing | ⬜ | _[Name]_ | _[Date]_ |
| Documentation | ⬜ | _[Name]_ | _[Date]_ |
| Deployment | ⬜ | _[Name]_ | _[Date]_ |
| Legal/Privacy | ⬜ | _[Name]_ | _[Date]_ |

**Final Approval**: ⬜ _[Name]_ - _[Date]_

---

## 🔗 Related Documents

- [Beta Launch Checklist](../BETA_LAUNCH_CHECKLIST.md)
- [Agent Team Documentation](../BETA_LAUNCH_AGENT_TEAM.md)
- [User Personas](../USER_PERSONAS.md)
- [CLAUDE.md](../../CLAUDE.md)

---

**Generated by**: Beta Verification Agent Team
**Tool Version**: Claude Code + Agent Teams (Experimental)
EOF

echo -e "${GREEN}✅ Report template created: $REPORT_FILE${NC}"
echo ""
echo "Next steps:"
echo "1. Fill in agent findings from team lead synthesis"
echo "2. Complete executive summary and decision"
echo "3. Update sign-off table as sections are verified"
echo "4. Commit report: git add $REPORT_FILE && git commit -m 'docs: beta verification report'"
echo ""

# Open report in editor if available
if command -v code &> /dev/null; then
    echo "Opening report in VS Code..."
    code "$REPORT_FILE"
elif command -v vim &> /dev/null; then
    echo "To edit: vim $REPORT_FILE"
else
    echo "To edit: open $REPORT_FILE"
fi
