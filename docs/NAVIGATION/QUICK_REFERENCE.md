# 🚀 Quick Reference - GymBro Development Guide

> **Quick lookup guide - Bookmark this!**
> **Full documentation index**: [`📚 docs/INDEX.md`](./INDEX.md)

---

## 📍 Where to Find Everything

| What | Where | Link |
|------|-------|------|
| Documentation Index | Complete navigation of all docs | [`📚 INDEX.md`](./INDEX.md) |
| Full Playbook | Detailed implementation guide | [`EXERCISE_IMPLEMENTATION_PLAYBOOK.md`](./EXERCISE_IMPLEMENTATION_PLAYBOOK.md) |
| Architecture | System design & overview | [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) |
| Status Tracking | Current progress (UPDATE WEEKLY!) | [`IMPLEMENTATION_STATUS.json`](./IMPLEMENTATION_STATUS.json) |
| This File | Quick lookup | You are here |

---

## 🎯 Where Am I? Quick Navigation

### "I just started" → [START HERE](#where-to-start)

### "I was working on something, what was I doing?"
```bash
# Run this to see current status:
cat docs/IMPLEMENTATION_STATUS.json | grep -E '"status"|"current_phase"|"progress_percent"' | head -10
```

### "I need the big picture"
→ Read: `docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` (Section: Executive Summary)

### "Show me what to do THIS WEEK"
```bash
# Edit and check your week:
jq '.timeline.week_1' docs/IMPLEMENTATION_STATUS.json
```

---

## 📋 Phase 1 Tasks (Weeks 1-4)

```
✅ Task 1.1: Validation & Testing (5-7 days)
   Files: scripts/validate_exercises.py
          test/features/exercise_database/validation_test.dart
   Do: Create validation script + dart tests + CI/CD hook
   Check: python3 scripts/validate_exercises.py assets/data/exercises_it.json

✅ Task 1.2: User Feedback System (10-14 days)
   Files: lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart
          lib/features/admin/presentation/providers/exercise_feedback_provider.dart
   Do: Add feedback button → Admin dashboard
   Check: Can submit feedback? Does admin see it?

✅ Task 1.3: Periodic Review (5-10 days)
   Files: cloud_functions/review_exercises.py
          lib/features/admin/presentation/screens/exercise_review_screen.dart
   Do: Cloud Function + Cloud Scheduler setup
   Check: Report generated? Admin notified?
```

---

## 🔧 Common Tasks

### "I need to check the current status"
```bash
# Quick status check:
cd /Users/michele/gymbro_flutter_new

# See overall progress:
cat docs/IMPLEMENTATION_STATUS.json | jq '.overall_progress_percent, .overall_status'

# See what phase we're in:
cat docs/IMPLEMENTATION_STATUS.json | jq '.quick_status'
```

### "Update status after my work session"
```bash
# 1. Edit the file:
code docs/IMPLEMENTATION_STATUS.json

# 2. Update these fields:
# - "last_updated": "ISO_DATE_HERE"
# - "progress_percent": new_value
# - "status": "IN_PROGRESS" or "COMPLETED"

# 3. For specific tasks, update:
# phases → phase_X → tasks → task_Y → progress_percent

# 4. Commit:
git add docs/IMPLEMENTATION_STATUS.json
git commit -m "docs: update implementation status"
```

### "I found a bug, what do I do?"
```bash
# 1. Check if it's critical:
# - Blocks progress? → Log as blocker
# - Nice to have? → Document in notes

# 2. Update status file:
# Add to "blockers" array:
{
  "date": "2025-10-XX",
  "task": "task_1_1",
  "description": "Python script fails on ...",
  "severity": "HIGH|MEDIUM|LOW",
  "resolution": null
}

# 3. Commit and notify
```

### "I need to jump to a specific file quickly"
```bash
# Validation script:
code scripts/validate_exercises.py

# Exercise feedback widget:
code lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart

# Admin feedback provider:
code lib/features/admin/presentation/providers/exercise_feedback_provider.dart

# Review screen:
code lib/features/admin/presentation/screens/exercise_review_screen.dart
```

---

## 📊 Status Quick Lookup

### Check what's done:
```bash
# See what's COMPLETED:
cat docs/IMPLEMENTATION_STATUS.json | jq '.phases[].tasks[] | select(.status == "COMPLETED")'
```

### Check what's in progress:
```bash
# See what's IN_PROGRESS:
cat docs/IMPLEMENTATION_STATUS.json | jq '.phases[].tasks[] | select(.status == "IN_PROGRESS")'
```

### Check blockers:
```bash
# See any blockers:
cat docs/IMPLEMENTATION_STATUS.json | jq '.blockers'
```

---

## 🎓 Phase Sequence

```
PHASE 1 (4 weeks): Foundational
├─ Task 1.1: Validation (Low effort, high impact) ✅
├─ Task 1.2: Feedback (Medium effort, high impact) ✅
└─ Task 1.3: Review (Low effort, high impact) ✅
└─ CHECKPOINT: All tasks done? → Move to Phase 2

PHASE 2 (6 weeks): Infrastructure
├─ Task 2.1: Conflict Management ⏳
├─ Task 2.2: Security & Backup ⏳
└─ Task 2.3: Smart Cache ⏳

PHASE 3 (6 weeks): Visibility & Scale
├─ Task 3.1: Client Monitoring ⏳
└─ Task 3.2: Changelog & Notifications ⏳

PHASE 4 (6+ weeks): Expansion
└─ Task 4.1: Public API & SDK ⏳
```

---

## ⏱️ Time Estimates

| Task | Duration | Effort | Impact |
|------|----------|--------|--------|
| 1.1 Validation | 5-7 days | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 1.2 Feedback | 10-14 days | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| 1.3 Review | 5-10 days | ⭐⭐ | ⭐⭐⭐⭐ |
| 2.1 Conflicts | 14-21 days | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 2.2 Security | 21-28 days | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 2.3 Cache | 10-14 days | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| 3.1 Monitoring | 14-21 days | ⭐⭐⭐ | ⭐⭐⭐ |
| 3.2 Notifications | 10-14 days | ⭐⭐⭐ | ⭐⭐⭐ |
| 4.1 Public API | 28-42 days | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🔑 Key Files Map

```
ROOT
├── docs/
│   ├── EXERCISE_DATABASE_SYNC_ARCHITECTURE.md  ← Start here (overview)
│   ├── EXERCISE_IMPLEMENTATION_PLAYBOOK.md     ← Implementation details
│   ├── IMPLEMENTATION_STATUS.json              ← Status tracking
│   └── QUICK_REFERENCE.md                      ← You are here
│
├── scripts/
│   └── validate_exercises.py                   ← Task 1.1
│
├── assets/data/
│   ├── exercises.json                          ← EN exercises (1567)
│   └── exercises_it.json                       ← IT exercises (1567) - CORRECTED
│
├── lib/features/exercise_database/
│   ├── data/repositories/
│   │   └── hybrid_exercise_repository.dart     ← Main entry point
│   ├── data/services/
│   │   ├── exercise_sync_service.dart
│   │   ├── exercise_cache_manager.dart
│   │   └── exercise_version_service.dart
│   └── presentation/
│       └── widgets/
│           └── exercise_card_feedback.dart     ← Task 1.2
│
├── lib/features/admin/
│   └── presentation/
│       ├── providers/
│       │   └── exercise_feedback_provider.dart ← Task 1.2
│       └── screens/
│           ├── exercise_review_screen.dart     ← Task 1.3
│           └── conflict_resolution_screen.dart ← Task 2.1
│
├── cloud_functions/
│   ├── review_exercises.py                     ← Task 1.3
│   └── backup_exercises.py                     ← Task 2.2
│
└── test/features/exercise_database/
    └── validation_test.dart                    ← Task 1.1
```

---

## 🚨 Troubleshooting Quickies

| Problem | Solution |
|---------|----------|
| Validation script fails | `python3 -m json.tool assets/data/exercises_it.json` |
| Firestore quota exceeded | Check Firebase console, batch size OK? |
| Tests not running | `flutter test --update-goldens` |
| Git merge conflict | `git status` to see files, manually resolve |
| Cloud Function not deploying | Check region, permissions, Python version |

---

## 📞 Decision Tree

```
Need to know
├─ What files exist?
│  └─ Check "Key Files Map" above
├─ Where am I?
│  └─ Check IMPLEMENTATION_STATUS.json
├─ What should I do next?
│  └─ Check Phase timeline
├─ How do I implement X?
│  └─ Check EXERCISE_IMPLEMENTATION_PLAYBOOK.md
├─ How does architecture work?
│  └─ Check EXERCISE_DATABASE_SYNC_ARCHITECTURE.md
└─ Is something broken?
   └─ Check Troubleshooting Quickies ☝️
```

---

## 📅 Weekly Routine

### Every Monday Morning:
```bash
# 1. Check current status:
cat docs/IMPLEMENTATION_STATUS.json | jq '.overall_status, .quick_status'

# 2. Read what tasks are this week:
jq '.timeline.week_X' docs/IMPLEMENTATION_STATUS.json

# 3. Set daily goal from that week's tasks
```

### Every Friday Evening:
```bash
# 1. Update progress:
vim docs/IMPLEMENTATION_STATUS.json

# 2. Commit changes:
git add docs/IMPLEMENTATION_STATUS.json
git commit -m "docs: update weekly progress - Week X"

# 3. Note blockers (if any):
# Add to blockers array

# 4. Plan next week
```

---

## 💾 Backup & Recovery

### Before big changes:
```bash
# Create backup of implementation status:
cp docs/IMPLEMENTATION_STATUS.json docs/IMPLEMENTATION_STATUS.backup_$(date +%Y%m%d).json

# Add to git:
git add docs/
git commit -m "docs: backup implementation status"
```

### If you get lost:
```bash
# Last 5 commits to docs:
git log --oneline docs/ | head -5

# See what changed:
git diff docs/IMPLEMENTATION_STATUS.json

# Go back to previous version:
git checkout HEAD~1 docs/IMPLEMENTATION_STATUS.json
```

---

## 🎓 Learning Path

### New to the project?
1. Read: `EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` (Executive Summary only)
2. Skim: `EXERCISE_IMPLEMENTATION_PLAYBOOK.md` (Task structure)
3. Look at: Key Files Map ☝️
4. Start: Task 1.1

### Coming back after break?
1. Check: `IMPLEMENTATION_STATUS.json` (current_phase, progress)
2. Jump to: That phase section in PLAYBOOK
3. Review: That phase's tasks
4. Continue: Where you left off

### Debugging issue?
1. Check: Troubleshooting Quickies
2. Read: Relevant task section in PLAYBOOK
3. If stuck: Check GitHub issues or ask

---

## 🏆 Success Criteria Checklist

### Phase 1 Complete:
```
☐ Validation script runs without errors
☐ Dart tests pass (flutter test)
☐ CI/CD auto-validates on commit
☐ Users can submit feedback
☐ Admin sees feedback stats
☐ Periodic review runs monthly
☐ All tests pass
☐ Staging deployment OK
☐ IMPLEMENTATION_STATUS.json shows 100% for Phase 1
```

### Ready for Phase 2:
```
☐ Phase 1 complete
☐ No critical bugs reported
☐ Documentation reviewed
☐ Team approval obtained
```

---

## 📞 Quick Links

- **Ask questions**: Check Playbook first
- **Found a bug**: Log in IMPLEMENTATION_STATUS.json
- **Need code examples**: See specific task in Playbook
- **Architecture questions**: See Architecture doc

---

## 📌 Copy-Paste Commands

```bash
# Status check:
cat docs/IMPLEMENTATION_STATUS.json | jq '.overall_progress_percent, .overall_status, .quick_status.current_phase'

# Edit status:
vim docs/IMPLEMENTATION_STATUS.json

# Run validation:
python3 scripts/validate_exercises.py assets/data/exercises_it.json

# Run tests:
flutter test test/features/exercise_database/

# Recent commits:
git log --oneline -10 docs/

# Branch for this feature:
git checkout -b feature/exercise-enhancement
```

---

**Last Updated**: 2025-10-16
**Quick Reference Version**: 1.0
**Keep this open while working!** 🚀

