---
allowed-tools: Glob(*), Grep(*), Read(*), Write(*), Edit(*), Bash(git:*)
description: Automatically sync all documentation with current codebase - UPDATE outdated docs, DELETE deprecated, CREATE missing, ARCHIVE speculative
---

# `/sync-docs` - Auto-Update All Documentation

> **Slash Command**: Automatically sync all documentation with current codebase

## 🎯 What It Does

```
/sync-docs
↓
Scans ALL docs in docs/
↓
For each doc:
  1. Read the documentation
  2. Analyze related code
  3. Compare: Is doc outdated? Missing? Deprecated?
  4. Action: UPDATE / DELETE / ARCHIVE / KEEP
↓
Report changes and commit automatically
```

## 📋 Per Each Document

### ✅ KEEP (No Changes)
- Documentation matches current code
- Shows: "✅ CURRENT (Last updated: Oct 18)"

### 🔄 UPDATE
- Documentation is **OUTDATED** but still relevant
- Action: **Merge intelligently**
  - Keep custom explanations
  - Update code samples
  - Update technical patterns
  - Add new sections
- Shows: "🔄 UPDATED: Added 3 new sections, fixed 2 patterns"

### ➕ CREATE
- Code exists but **NO DOCUMENTATION** for it
- Create new doc in appropriate UX_FLOWS folder
- Add to NAVIGATION/INDEX.md
- Shows: "➕ CREATED: docs/UX_FLOWS/workout_session/NEW_FEATURE.md"

### 🗑️ DELETE
- Documentation describes **DEPRECATED FEATURES**
- Code no longer exists
- Delete the file
- Shows: "🗑️ DELETED: docs/TECHNICAL_FOUNDATION/OLD_SYSTEM.md (feature removed)"

### 📦 ARCHIVE
- Documentation is about **FUTURE/SPECULATIVE FEATURES**
- Not actively implemented
- Move to `docs/archived/`
- Shows: "📦 ARCHIVED: docs/archived/FUTURE_AI_COACH.md"

## 🔧 How to Use

### Manual Execution
```bash
# In chat, just type:
/sync-docs
```

### Automatic (Pre-Commit)
```bash
# Before each commit, automatically runs
# If changes made: asks if you want to commit them
```

## 📊 Report Format

```
🤖 DOCUMENTATION SYNC REPORT
===========================

📂 Scanned: 32 documentation files
🔍 Code analysis: 1,245 files

ACTIONS TAKEN:
✅ CURRENT (Keep): 24 files
   - TIMER_AUDIO_KB.md (Oct 18)
   - EXERCISE_CARD_DEVELOPMENT_GUIDE.md (Oct 17)
   ...

🔄 UPDATED: 5 files
   - USER_MODELS_GUIDE.md
     + Added UserProfileConsolidated section
     + Updated sealed class pattern

   - LOCALIZATION_GUIDE.md
     + Updated context.l10n examples
     - Removed deprecated AppLocalizations pattern

➕ CREATED: 2 new files
   - docs/UX_FLOWS/workout_session/REST_TIMER_IMPLEMENTATION.md
   - docs/TECHNICAL_FOUNDATION/BACKGROUND_TASK_OPTIMIZATION.md

🗑️ DELETED: 1 file
   - DEPRECATED_TIMER_FIX_SUMMARY.md (no longer used)

📦 ARCHIVED: 0 files

✅ COMPLETE: docs/ is now in sync with codebase
⏱️ Time: 2 minutes 34 seconds
📝 Next: Will commit changes automatically
```

## ⚙️ Configuration

### What Triggers Updates
- Code changes (new features, removed features)
- Pattern changes (deprecated patterns removed, new patterns added)
- Architecture changes
- File moves/renames

### What Does NOT Trigger Updates
- Comments in code (unless major documentation changes)
- Variable renames (unless architectural change)
- Formatting only changes

## 🚀 Best Practices

1. **Run before major releases**: `/sync-docs` before tagging a release
2. **Run after big refactors**: After architectural changes
3. **Run quarterly**: Catch drift that might have accumulated
4. **Review changes**: Always review the diff before committing

## 📌 Special Cases

### Documentation Has Custom Explanations
- **Behavior**: Keeps custom text, updates code samples only
- **Example**:
  ```
  OLD: "This is how REST timers work: [deprecated pattern]"
  NEW: "This is how REST timers work: [new pattern with same explanation]"
  ```

### Code Was Completely Removed
- **Behavior**: Archives documentation, doesn't delete
- **Reason**: Might be useful for historical reference
- **Location**: Moved to `docs/archived/REMOVED_FEATURES.md`

### New Pattern But No Code Yet
- **Behavior**: Does NOT create docs (avoid orphaned documentation)
- **Action**: User must request it manually or feature must have code first

---

## 🎯 Integration

This command integrates with:
- `.claude/hooks/document-categorization-guide.md` - Uses same categorization logic
- `docs/NAVIGATION/INDEX.md` - Auto-updates when docs added/removed/moved
- Git pre-commit - Optionally runs before each commit

---

**Last Updated**: October 18, 2025
**Status**: ✅ Active - Ready for use
