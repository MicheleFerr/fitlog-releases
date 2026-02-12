# ⚡ Beta Verification Quick Start Guide

**Quick reference for running automated beta verification with agent teams**

---

## 🚀 QUICK START (3 Commands)

```bash
# 1. Pre-check (30 seconds)
.claude/scripts/pre-verification.sh

# 2. Launch verification (30-45 min)
claude --teammate-mode tmux
/verify-beta

# 3. Generate report (automatic)
# Team lead synthesizes findings automatically
```

---

## 📚 FIRST TIME? Start with Dry Run

Test the infrastructure before full verification:

```bash
# Test with limited scope (5-10 min)
.claude/scripts/dry-run-verification.sh

# Follow instructions, then review output
# This validates agent spawn, reporting, quality gates
```

---

## 🎯 FULL VERIFICATION

### Step 1: Pre-Flight Check
```bash
cd /Users/michele/gymbro_flutter_new
.claude/scripts/pre-verification.sh
```

**Expected output:**
- ✅ All checks pass → Proceed to Step 2
- ⚠️  Warnings → Review but safe to proceed
- ❌ Blockers → Fix before launching team

### Step 2: Launch Agent Team
```bash
# New terminal window
claude --teammate-mode tmux
```

Then:
```
/verify-beta
```

**What happens:**
1. **Team spawns** (30 sec): 6 agents in split panes
2. **Parallel verification** (30-45 min): Each agent works independently
3. **Cross-team communication** (15 min): Agents share findings
4. **Synthesis** (10 min): Lead generates GO/NO-GO decision

### Step 3: Review & Document

Team lead provides:
- ✅ Items passed
- ⚠️  Warnings (non-blocking)
- ❌ Blockers (must fix)
- 🎯 GO/NO-GO recommendation

Then generate report:
```bash
.claude/scripts/post-verification.sh
```

Opens template in editor - fill with agent findings.

---

## 🎛️ CONTROLS

### Navigate Agents (In-Process Mode)
- **Shift+Up/Down**: Switch between agents
- **Shift+Tab**: Toggle delegate mode
- **Ctrl+T**: Toggle task list
- **Enter**: View agent session
- **Escape**: Interrupt agent

### Navigate Panes (Split Mode)
- **Click pane**: Focus that agent
- **Type**: Send message to focused agent
- **tmux prefix + arrow**: Navigate panes
- **tmux prefix + z**: Zoom pane

### Talk to Agents
```
# To specific agent (when selected):
Check your progress and report any blockers you've encountered

# Broadcast to all:
Broadcast to all teammates: Provide quick status update
```

### Emergency Controls
```
# Stop stuck agent
Ask [agent-name] teammate to shut down

# Clean up team
Clean up the team

# Kill orphaned tmux session
tmux ls
tmux kill-session -t <name>
```

---

## 📊 MONITORING PROGRESS

### Check Overall Status
```
Show me the task list and status of all teammates
```

### Check Individual Agent
```
# Select agent with Shift+Down, then:
What's your current status and any blockers?
```

### If Lead Starts Implementing
```
Wait for your teammates to complete their tasks.
Focus only on coordination, not implementation.
```

---

## 🔧 TROUBLESHOOTING

### No Split Panes Appearing
```bash
# Check tmux installed
which tmux

# If not:
brew install tmux

# Verify settings
cat ~/.claude/settings.json | grep teammateMode
# Should show: "teammateMode": "tmux"
```

### Teammates Not Spawning
```
# Check agent teams enabled
cat ~/.claude/settings.json | grep AGENT_TEAMS
# Should show: "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"

# If missing, restart Claude after adding to settings
```

### Too Many Permission Prompts
Check `~/.claude/settings.json` has:
```json
{
  "permissions": {
    "read": "allow",
    "bash": {
      "glob": [".claude/scripts/*.sh", "flutter", "dart", "git"],
      "mode": "allow"
    }
  }
}
```

### Agent Stuck or Errored
```
# Select agent (Shift+Down), then:
Document what you've completed so far and move to next items
you can verify independently. Skip blocked items for now.
```

### TaskCompleted Hook Not Triggering
```bash
# Check executable
ls -la .claude/hooks/TaskCompleted.sh
# Should show: -rwxr-xr-x

# If not:
chmod +x .claude/hooks/TaskCompleted.sh
```

---

## 📈 EXPECTED TIMELINE

| Phase | Duration | What Happens |
|-------|----------|--------------|
| **Pre-Check** | 30s | Validate environment |
| **Team Spawn** | 30s | Create 6 agents |
| **Verification** | 30-45 min | Parallel execution |
| **Communication** | 15 min | Cross-team sync |
| **Synthesis** | 10 min | Lead generates report |
| **Review** | 15 min | Fill report template |
| **Total** | ~60-90 min | Full verification cycle |

---

## 💰 COST ESTIMATE

- **Tokens**: 300K-500K total (6 agents × ~50K-80K each)
- **Cost**: ~$15-25 USD (Sonnet pricing)
- **Value**: Saves 3-4 hours manual work + ensures comprehensive coverage

---

## ✅ SUCCESS CRITERIA

### Dry Run Success
- ✅ 2 agents spawn and complete tasks
- ✅ Reports follow proper format
- ✅ Quality gates enforce standards
- ✅ Lead synthesizes findings

### Full Verification Success
- ✅ All 6 agents complete their sections
- ✅ GO/NO-GO decision made with rationale
- ✅ Report generated with all findings
- ✅ Sign-off table ready for approval

---

## 📁 FILE LOCATIONS

| File | Purpose |
|------|---------|
| `docs/BETA_LAUNCH_CHECKLIST.md` | Full checklist (what to verify) |
| `docs/BETA_LAUNCH_AGENT_TEAM.md` | Team design (how agents work) |
| `.claude/commands/verify-beta.md` | Launch skill (quick command) |
| `.claude/scripts/pre-verification.sh` | Pre-flight checks |
| `.claude/scripts/post-verification.sh` | Report generator |
| `.claude/scripts/dry-run-verification.sh` | Test infrastructure |
| `.claude/hooks/TaskCompleted.sh` | Quality gate enforcement |
| `docs/verification-reports/` | Generated reports |

---

## 🔗 NEXT STEPS AFTER VERIFICATION

### If GO Decision
1. ✅ Complete manual testing checklist
2. ✅ Update sign-off table in checklist
3. ✅ Prepare beta tester communications
4. ✅ Schedule TestFlight/Play Store upload
5. ✅ Set up monitoring dashboards

### If NO-GO Decision
1. 📋 Document all P0 blockers
2. 🔧 Create fix plan with timeline
3. 🧪 Re-verify after fixes
4. 📊 Generate new verification report

### If CONDITIONAL Decision
1. ⚠️  List conditions/mitigations
2. 📝 Get stakeholder approval on risks
3. 🎯 Set post-launch monitoring alerts
4. 📅 Schedule follow-up fixes

---

## 💡 PRO TIPS

### Before First Run
- ✅ Run dry-run first to familiarize
- ✅ Review sample report format
- ✅ Have git in clean state
- ✅ Schedule during low-activity hours

### During Verification
- 👀 Monitor task list regularly
- 💬 Nudge stuck agents proactively
- 📝 Take notes on unexpected findings
- 🔄 Let agents coordinate themselves

### After Verification
- 📊 Archive report in git
- 🔄 Update checklist if gaps found
- 📈 Track metrics (time, tokens, findings)
- 🧠 Improve prompts for next run

---

## 🆘 SUPPORT

**Issues with agent teams?**
- Check [limitations](BETA_LAUNCH_AGENT_TEAM.md#limitations)
- Review [troubleshooting](BETA_LAUNCH_AGENT_TEAM.md#troubleshooting)

**Issues with verification logic?**
- Review [checklist](BETA_LAUNCH_CHECKLIST.md)
- Check [project rules](../CLAUDE.md)

**Technical problems?**
- Run: `.claude/scripts/health-check.sh`
- Check: `flutter doctor`
- Verify: `git status`

---

**Last Updated**: 2026-02-10
**Version**: 1.0.0
**Status**: ✅ Ready for Use
