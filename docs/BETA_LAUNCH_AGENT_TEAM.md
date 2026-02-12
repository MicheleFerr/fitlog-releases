# 🤖 Beta Launch Verification Agent Team

**Purpose**: Autonomous verification of beta launch readiness using coordinated agent teams
**Framework**: Claude Code Agent Teams (Experimental)
**Checklist**: [`BETA_LAUNCH_CHECKLIST.md`](BETA_LAUNCH_CHECKLIST.md)

---

## 📋 SETUP REQUIREMENTS

### 1. Enable Agent Teams
```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 2. Choose Display Mode

**Option A: In-Process (Default)**
- All agents in one terminal
- Use Shift+Up/Down to switch between agents
- Works everywhere

**Option B: Split Panes (Recommended)**
- Each agent in separate pane
- Visual parallelism
- Requires tmux or iTerm2

```json
// For split panes:
{
  "teammateMode": "tmux"
}
```

### 3. Pre-Approve Permissions
To avoid permission prompts during verification, pre-approve:
- Read operations (unlimited)
- Bash commands (for testing scripts)
- WebFetch (for documentation checks)

---

## 🎯 TEAM STRUCTURE

### Team Lead (Orchestrator)
**Role**: Coordinate verification, synthesize findings, make GO/NO-GO decision
**Tools**: Task management, teammate messaging, result synthesis
**Model**: Sonnet (coordination doesn't need Opus)

### Teammate 1: Code Guardian 🛡️
**Responsibilities**:
- ✅ Verify all pre-commit rules (icons, l10n, colors)
- ✅ Check iOS build compliance (const with context.l10n)
- ✅ Run `flutter analyze` (zero errors)
- ✅ Execute `performance-check.sh` on all features
- ✅ Verify anti-patterns (loop I/O, singleton managers)

**Critical Files**:
- `CLAUDE.md` (regole critiche)
- `lib/**/*.dart` (tutto il codice)
- `.claude/scripts/performance-check.sh`

**Success Criteria**:
- Zero violations regole critiche
- Zero errori `flutter analyze`
- Zero warning gravi da performance check

### Teammate 2: QA Specialist 🧪
**Responsibilities**:
- ✅ Run full test suite (`flutter test`)
- ✅ Check test coverage (>60% domain/data)
- ✅ Verify golden tests pass
- ✅ Document manual testing matrix
- ✅ List edge cases to verify manually

**Critical Files**:
- `test/**/*_test.dart`
- Coverage reports
- Golden test images

**Success Criteria**:
- All automated tests passing
- Coverage meets threshold
- Manual test checklist ready

### Teammate 3: Backend Auditor ☁️
**Responsibilities**:
- ✅ Verify Firestore rules (production ready)
- ✅ Check Cloud Functions (exercise popularity, scheduled)
- ✅ Test rate limiting configuration
- ✅ Verify Hive migration scripts
- ✅ Check data integrity safeguards

**Critical Files**:
- `firestore.rules`
- `firebase/storage.rules`
- `functions/src/**/*.ts`
- Hive models (`*.g.dart`)

**Success Criteria**:
- All Firebase rules tested
- Cloud Functions deployed and healthy
- Data integrity verified

### Teammate 4: UX Personas Inspector 👥
**Responsibilities**:
- ✅ Run Persona Impact Analysis on critical flows
- ✅ Verify onboarding for Marco (principiante)
- ✅ Check timer/background for Chiara (multitasking)
- ✅ Validate data detail for Luca (powerlifter)
- ✅ Assess UI for Sofia (estetica)
- ✅ Verify efficiency for Roberto (busy)

**Critical Files**:
- `docs/USER_PERSONAS.md`
- `lib/features/onboarding/`
- `lib/features/workout/`
- UI components

**Success Criteria**:
- No "--" impact on primary personas
- Max 1 feature with "-" on 2+ personas
- All mitigations documented

### Teammate 5: Docs & Compliance Officer 📚
**Responsibilities**:
- ✅ Verify documentation updated (INDEX.md, CLAUDE.md)
- ✅ Check Privacy Policy & Terms
- ✅ Validate GDPR compliance (deletion, export)
- ✅ Review beta tester guide
- ✅ Confirm changelog prepared

**Critical Files**:
- `docs/INDEX.md`
- `CLAUDE.md`
- Privacy Policy (external)
- Beta tester documentation

**Success Criteria**:
- All docs reflect current state
- Legal compliance verified
- Beta resources ready

### Teammate 6: Deployment Checker 🚀
**Responsibilities**:
- ✅ Verify build configuration (version bump)
- ✅ Check iOS provisioning & TestFlight setup
- ✅ Validate Android AAB & Play Console beta
- ✅ Test CI/CD pipeline
- ✅ Confirm rollback plan ready

**Critical Files**:
- `pubspec.yaml` (version)
- `ios/` configuration
- `android/` build files
- CI/CD configs

**Success Criteria**:
- Build numbers incremented
- Store listings ready
- Deploy automation tested

---

## 🚀 LAUNCHING THE TEAM

### Quick Start Command

```bash
# In FitLog project root:
claude --teammate-mode tmux
```

Then paste this prompt:

```
Create an agent team to verify FitLog's beta launch readiness using the
checklist at docs/BETA_LAUNCH_CHECKLIST.md.

Spawn 6 teammates following the structure in docs/BETA_LAUNCH_AGENT_TEAM.md:

1. Code Guardian (Sonnet) - verify code quality, iOS compliance, performance
2. QA Specialist (Sonnet) - run test suite, check coverage, document manual tests
3. Backend Auditor (Sonnet) - verify Firebase, Cloud Functions, data integrity
4. UX Personas Inspector (Sonnet) - run persona impact analysis on critical flows
5. Docs & Compliance Officer (Sonnet) - check documentation, legal, beta resources
6. Deployment Checker (Sonnet) - verify build config, store readiness, CI/CD

Each teammate should:
- Work through their section of the checklist
- Report findings with severity (P0-blocker, P1-critical, P2-important, P3-nice-to-have)
- Message other teammates if they discover cross-cutting issues
- Notify the lead when their section is complete

After all teammates finish, synthesize findings into a GO/NO-GO recommendation
with clear blockers, risks accepted, and sign-off table.

Require plan approval for Backend Auditor and Deployment Checker before
they execute any verification scripts.
```

### Advanced: Delegate Mode

After team starts, press **Shift+Tab** to enter delegate mode. This prevents the lead from implementing fixes itself and keeps it focused on coordination.

---

## 📊 WORKFLOW

### Phase 1: Parallel Verification (30-60 min)
Each teammate works independently:
- Reads their section of `BETA_LAUNCH_CHECKLIST.md`
- Executes verification commands
- Documents findings in structured format
- Messages lead with progress updates

### Phase 2: Cross-Team Communication (15-30 min)
Teammates message each other when they find:
- Cross-cutting issues (e.g., performance affects QA tests)
- Conflicts (e.g., code changes break deployment)
- Dependencies (e.g., backend needs code fix first)

### Phase 3: Synthesis & Decision (15 min)
Lead compiles:
- ✅ All checks passed
- ⚠️ Warnings (non-blocking)
- ❌ Blockers (must fix before launch)
- 📋 Manual verification tasks remaining
- 🎯 GO/NO-GO recommendation

### Phase 4: Cleanup
```
Ask all teammates to shut down gracefully
Clean up the team
```

---

## 📝 OUTPUT FORMAT

Each teammate reports in this structure:

```markdown
## [Agent Name] - Verification Report

### Summary
- ✅ Passed: X items
- ⚠️ Warnings: Y items
- ❌ Blockers: Z items

### Detailed Findings

#### ✅ PASSED
- [Item 1.1] Code follows AppIcons.* pattern
- [Item 1.2] All text uses context.l10n.*
...

#### ⚠️ WARNINGS (Non-Blocking)
- [Item 2.3] Performance: 2 minor anti-patterns detected (P3)
  - File: lib/features/workout/data/services/workout_repository.dart:45
  - Issue: Potential debounce missing on rapid event handler
  - Impact: Low - unlikely to affect beta users
  - Recommendation: Fix before production

#### ❌ BLOCKERS (Must Fix)
- [Item 1.1] iOS Build Compliance: Found `const Text(context.l10n.title)` (P0)
  - File: lib/features/settings/presentation/screens/settings_screen.dart:127
  - Impact: HIGH - causes iOS build failure
  - Action Required: Remove `const` keyword

### Cross-Team Dependencies
- Blocked by: None
- Blocks: None
- Notified: [Other agents messaged about findings]

### Manual Verification Required
- [ ] Test on iPhone SE 2020 (small screen)
- [ ] Verify dark mode on all screens
- [ ] Check timer in background with app kill

### Recommendation
[GO / NO-GO / CONDITIONAL]
```

---

## 🎯 GO/NO-GO CRITERIA

### ✅ AUTOMATIC GO (All Must Pass)
- Zero P0 blockers (iOS build errors, critical crashes)
- Zero P1 critical issues (data loss, security vulnerabilities)
- All automated tests passing
- Firebase rules production-ready
- Code analysis clean (`flutter analyze`)

### ⚠️ CONDITIONAL GO (Requires Review)
- Max 3 P1 issues with documented workarounds
- Max 5 P2 issues with mitigation plans
- Manual testing checklist prepared
- Rollback plan documented

### ❌ NO-GO (Any Blocker)
- 1+ P0 blockers unresolved
- 4+ P1 critical issues
- Test suite failing (>5% failure rate)
- Firebase security rules not tested
- iOS build cannot compile

---

## 🔧 TROUBLESHOOTING

### Teammate Stopped on Error
```
# Select stuck teammate (Shift+Down in in-process mode)
Check your error logs and continue verification. If blocked, document
the blocker and move to next items you can verify independently.
```

### Lead Implementing Instead of Delegating
```
Wait for your teammates to complete their tasks before proceeding.
Focus on coordination and synthesis only.
```

### Too Many Permission Prompts
Pre-approve in `~/.claude/settings.json`:
```json
{
  "permissions": {
    "read": "allow",
    "bash": {
      "glob": [".claude/scripts/*.sh", "flutter", "dart"],
      "mode": "allow"
    }
  }
}
```

### Results Taking Too Long
```
Broadcast to all teammates: "Provide a quick status update on your
progress and any blockers you've encountered."
```

---

## 💡 BEST PRACTICES

### 1. Size Tasks Appropriately
Each teammate's section should take 15-30 minutes. If longer, break into smaller verification chunks.

### 2. Start with Read-Only Verification
Don't ask teammates to fix issues during verification. They should:
- ✅ Document findings
- ❌ NOT implement fixes

Fixes come in a separate iteration after GO/NO-GO decision.

### 3. Use Hooks for Quality Gates
Create `.claude/hooks/TaskCompleted.sh`:
```bash
#!/bin/bash
# Prevent task completion without proper documentation

TASK_SUBJECT="$1"
TASK_DESCRIPTION="$2"

if [[ "$TASK_DESCRIPTION" != *"Severity:"* ]]; then
  echo "❌ Task must include severity rating (P0-P3)"
  exit 2  # Block completion
fi

exit 0
```

### 4. Monitor Token Usage
Agent teams use ~6x more tokens (one context per agent). For beta verification (estimated 30-60 min):
- Expected: ~300K-500K tokens total
- Cost: ~$15-25 USD (Sonnet pricing)

Worth it for comprehensive parallel verification vs sequential (3-4 hours manual).

### 5. Run During Low-Activity Hours
Teammates execute tests, build scripts, analysis tools. Schedule when:
- No active development happening
- CI/CD pipeline free
- Stable git branch (e.g., `beta-candidate`)

---

## 🔗 RELATED DOCUMENTATION

- [BETA_LAUNCH_CHECKLIST.md](BETA_LAUNCH_CHECKLIST.md) - Full checklist
- [CLAUDE.md](../CLAUDE.md) - Project rules
- [USER_PERSONAS.md](USER_PERSONAS.md) - Personas for UX verification
- [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) - Development standards

---

## 📈 CONTINUOUS IMPROVEMENT

After each verification run:
1. **Document timing**: Track how long each phase takes
2. **Refine checklist**: Add items teammates missed
3. **Update prompts**: Improve teammate instructions based on gaps
4. **Automate more**: Convert manual checks to scripts where possible

---

**Last Updated**: 2026-02-10
**Status**: 🧪 Experimental (Agent Teams feature)
**Tested**: Not yet - first beta verification pending
