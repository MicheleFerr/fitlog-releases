---
name: verify-beta
description: Launch Beta Launch Verification Agent Team for autonomous pre-launch checks
---

# 🚀 Beta Launch Verification Team

**Purpose**: Autonomous verification of beta launch readiness using coordinated agent teams

## PREREQUISITES CHECK

Before launching the team:

1. **Agent Teams Enabled?**
   - Check `~/.claude/settings.json` has `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"`
   - If not, add it now and restart Claude

2. **Clean Git State?**
   - Run: `git status`
   - Ensure on `beta-candidate` or `main` branch
   - No uncommitted changes that could affect verification

3. **Dependencies Updated?**
   - Run: `flutter pub get`
   - Run: `flutter gen-l10n`

4. **CI/CD Pipeline Free?**
   - Check no builds running that could conflict

## LAUNCH COMMAND

I'm launching a Beta Launch Verification Team with 6 specialized agents to verify the checklist at `docs/BETA_LAUNCH_CHECKLIST.md`.

**Team Structure:**

Create an agent team to verify FitLog's beta launch readiness. Use the design documented in `docs/BETA_LAUNCH_AGENT_TEAM.md`.

Spawn 6 teammates (all using Sonnet model):

**1. Code Guardian 🛡️**
Verify code quality and iOS compliance:
- Check all pre-commit rules (AppIcons.*, context.l10n.*, context.colors.*)
- Find any `const Text(context.l10n.*)` patterns (iOS build blocker)
- Run `flutter analyze` and report errors/warnings
- Execute `.claude/scripts/performance-check.sh lib/` and categorize findings
- Verify anti-patterns: loop I/O, missing debounce, singleton managers

Success criteria: Zero critical violations, zero analyze errors.

**2. QA Specialist 🧪**
Test suite verification:
- Run `flutter test` full suite
- Check test coverage (target >60% on domain/data)
- Verify golden tests pass
- Document manual testing matrix (device + edge cases)
- List critical flows to verify manually

Success criteria: All tests passing, coverage meets target.

**3. Backend Auditor ☁️**
Firebase and data integrity:
- Review `firestore.rules` for production readiness
- Check `firebase/storage.rules` security
- Verify Cloud Functions in `functions/src/` are deployed and healthy
- Test Hive migration scripts exist and documented
- Verify data integrity safeguards (validation, error handling)

Require plan approval before executing any verification scripts.

Success criteria: All Firebase rules secure, Cloud Functions operational.

**4. UX Personas Inspector 👥**
Persona impact analysis (reference `docs/USER_PERSONAS.md`):
- Marco (principiante): Onboarding clarity, help availability
- Chiara (multitasking): Quick actions, timer background mode
- Luca (powerlifter): Data detail, export functionality
- Sofia (estetica): UI consistency, animation smoothness
- Roberto (busy): Efficiency, bulk operations

Check critical flows against each persona's needs. Flag any "--" impacts as blockers.

Success criteria: No persona has "--" impact, max 1 feature with "-" on 2+ personas.

**5. Docs & Compliance Officer 📚**
Documentation and legal:
- Verify `docs/INDEX.md` reflects current state
- Check `CLAUDE.md` project rules are up-to-date
- Review Privacy Policy and Terms of Service
- Validate GDPR compliance (data deletion, export flows)
- Confirm beta tester guide and feedback forms ready

Success criteria: All documentation current, legal compliance verified.

**6. Deployment Checker 🚀**
Build and store readiness:
- Check `pubspec.yaml` version and build number incremented
- Verify iOS provisioning profiles and TestFlight configuration
- Validate Android AAB build and Play Console beta track
- Test CI/CD pipeline (GitHub Actions/Codemagic)
- Confirm rollback plan documented

Require plan approval before executing deployment verification scripts.

Success criteria: Build ready, stores configured, automation tested.

---

**TEAM COORDINATION:**

Each teammate should:
1. Load their section from `docs/BETA_LAUNCH_CHECKLIST.md`
2. Execute verification independently (30-45 min estimate)
3. Report findings using the format in `docs/BETA_LAUNCH_AGENT_TEAM.md`
4. Message other teammates about cross-cutting issues
5. Notify lead when section complete

Use severity ratings:
- **P0**: Blocker - prevents launch (e.g., build fails, crashes)
- **P1**: Critical - major impact but has workaround
- **P2**: Important - should fix but not blocking
- **P3**: Nice-to-have - document for later

After all teammates finish, synthesize findings into:
- ✅ Items passing
- ⚠️ Warnings (non-blocking)
- ❌ Blockers (must fix)
- 📋 Manual tasks remaining
- 🎯 GO/NO-GO recommendation with sign-off table

Use delegate mode (Shift+Tab after spawn) to keep lead focused on coordination only.

## POST-VERIFICATION

After team completes:

1. **Review GO/NO-GO Decision**
   - If GO: Proceed with manual testing phase
   - If NO-GO: Document blockers, create fix plan, re-verify

2. **Update Sign-Off Table**
   - Fill in `docs/BETA_LAUNCH_CHECKLIST.md` sign-off table
   - Mark completed sections with ✅ and date

3. **Document Findings**
   - Create `docs/BETA_VERIFICATION_REPORT_[DATE].md`
   - Include all teammate reports
   - List action items for any issues found

4. **Clean Up Team**
   - Ask all teammates to shut down gracefully
   - Run team cleanup: "Clean up the team"

5. **Share Results**
   - Commit verification report
   - Notify stakeholders of GO/NO-GO status
   - If GO: Schedule manual testing with beta testers

## TROUBLESHOOTING

**Teammate Stuck?**
→ Select with Shift+Down, tell them: "Document what you've found so far and move to items you can verify independently"

**Lead Implementing Fixes?**
→ Tell lead: "Do not implement fixes. Focus only on verification and coordination. We'll fix issues in a separate iteration."

**Permission Prompts?**
→ Pre-approve bash/read in `~/.claude/settings.json` before launching

**Taking Too Long?**
→ Broadcast: "Provide 1-minute status update on progress and blockers"

---

**Documentation**: See [`docs/BETA_LAUNCH_AGENT_TEAM.md`](../../docs/BETA_LAUNCH_AGENT_TEAM.md) for full details.
