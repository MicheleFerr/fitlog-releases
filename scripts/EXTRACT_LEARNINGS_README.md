# 📊 LEARNINGS.md Auto-Extraction

**Script**: `extract_learnings.sh`
**Purpose**: Automatically extract patterns from git history and populate LEARNINGS.md
**Status**: FASE 3 - Full Integration (task-master.dev)

---

## 🎯 What It Does

Scans git commit history and plan documents to automatically discover:

1. **📈 Estimation Patterns**: Estimated vs actual times from plan retrospectives
2. **🔍 Common Pitfalls**: Recurring issues from "fix:", "bug:", "issue:" commits
3. **✨ Successful Patterns**: What works well from "feat:", "improve:" commits
4. **🔧 Tech Stack Insights**: Framework-specific learnings (Firebase, Localization, iOS, etc.)

**Output**: Updates `docs/plans/LEARNINGS.md` with discovered patterns

---

## 🚀 Usage

### Basic Usage

```bash
# Extract from last 6 months (default)
./scripts/extract_learnings.sh

# Extract from specific date
./scripts/extract_learnings.sh --since "2024-01-01"

# Extract from relative date
./scripts/extract_learnings.sh --since "3 months ago"
```

### Preview Mode

```bash
# Dry-run: See what would be extracted without updating LEARNINGS.md
./scripts/extract_learnings.sh --dry-run

# Verbose dry-run: Show detailed extraction process
./scripts/extract_learnings.sh --dry-run --verbose
```

### Help

```bash
./scripts/extract_learnings.sh --help
```

---

## 📊 What Gets Extracted

### 1. Estimation Patterns

**Source**: Plan retrospectives in `docs/plans/*-plan.md`

```markdown
## 📊 Post-Milestone Retrospective
- Estimated: 4.5h → Actual: 5.5h (122% of estimate)
```

**Extracted To**: `docs/plans/LEARNINGS.md` → Estimation Patterns table

```markdown
| Task Type | Initial Estimate | Actual Average | Adjustment Factor | Sample Size |
|-----------|------------------|----------------|-------------------|-------------|
| Feature implementation | 4.5h | 5.5h | +22% (+1h) | 3 samples |
```

### 2. Common Pitfalls

**Source**: Git commits with `fix:`, `bug:`, `issue:`, `problem:`

**Example Commits**:
```
a1b2c3d fix: Firebase security rules validation error
e4f5g6h fix: Localization missing for Italian
i7j8k9l bug: Theme colors hardcoded instead of context.colors
```

**Extracted To**: `docs/plans/LEARNINGS.md` → Common Pitfalls section

```markdown
### Firebase Security Rules Always Take Longer
- **Origin**: Multiple fixes (3 occurrences in 6 months)
- **Issue**: Security rules often underestimated
- **Solution**: Always add +15 min buffer to Firebase tasks
```

**Categories Detected**:
- Firebase/Firestore (security, queries, sync)
- Localization (missing translations, l10n keys)
- Theme/Colors (hardcoded colors, dark mode)
- Testing (missing tests, flaky tests)
- iOS/Platform (platform-specific issues)

### 3. Successful Patterns

**Source**: Git commits with `feat:`, `improve:`, `optimize:`, `enhance:`

**Example Commits**:
```
m1n2o3p feat: implement clean architecture for analytics
q4r5s6t improve: reusable component for workout card
u7v8w9x optimize: Riverpod provider with select
```

**Extracted To**: `docs/plans/LEARNINGS.md` → What Works Well section

```markdown
### Clean Architecture Layering
- **Origin**: Multiple features (5 occurrences)
- **Why it works**: Clear separation, testable, maintainable
- **Keep doing**: Always use Domain/Data/Presentation layers
```

**Categories Detected**:
- Clean Architecture (domain, repository, separation)
- State Management (Riverpod, providers, select)
- Reusable Components (widgets, DRY principle)
- Documentation (docs-first approach)

### 4. Tech Stack Insights

Automatically categorizes learnings by:
- **Flutter/Dart**: Widget patterns, Dart features
- **Riverpod**: State management best practices
- **Firebase**: Backend integration patterns
- **iOS**: Platform-specific implementations
- **Localization**: i18n best practices

---

## 📅 When to Run

### Recommended Schedule

```bash
# Monthly review (1st of each month)
./scripts/extract_learnings.sh --since "1 month ago"

# After completing 3+ milestones
./scripts/extract_learnings.sh --since "2024-01-01"

# Before quarterly planning
./scripts/extract_learnings.sh --since "3 months ago" --verbose

# Before major refactor (learn from past)
./scripts/extract_learnings.sh --dry-run
```

### Minimum Data Requirements

For meaningful extraction, you need:
- ✅ **At least 3 plan retrospectives** (for estimation patterns)
- ✅ **At least 10 fix/bug commits** (for pitfall patterns)
- ✅ **At least 10 feat/improve commits** (for success patterns)

**If you don't have enough data**:
- Script will warn: "No retrospective data found"
- LEARNINGS.md won't be updated
- Run script again after completing more milestones

---

## 🔧 Output Example

### Before Extraction

```markdown
## 🎯 Estimation Patterns

| Task Type | Initial Estimate | Actual Average | Adjustment Factor | Sample Size |
|-----------|------------------|----------------|-------------------|-------------|
| - | - | - | - | - |

**No patterns yet**. This table auto-populates as you complete milestones.
```

### After Extraction

```markdown
## 🎯 Estimation Patterns

**Last Updated**: 2025-01-15

| Task Type | Initial Estimate | Actual Average | Adjustment Factor | Sample Size |
|-----------|------------------|----------------|-------------------|-------------|
| Feature implementation | 4.5h | 5.5h | +22% (+1h) | 3 samples |

**Current accuracy**: 82%
**Target accuracy**: 90%+
```

---

## ⚙️ Configuration

### Default Settings

```bash
DEFAULT_SINCE="6 months ago"  # How far back to scan
MIN_OCCURRENCES=2             # Minimum pattern occurrences to include
```

### Custom Configuration

Override defaults via command-line:

```bash
# Scan last year
./scripts/extract_learnings.sh --since "1 year ago"

# Scan specific date range
./scripts/extract_learnings.sh --since "2024-01-01"
```

---

## 🛠️ Dependencies

**Required**:
- `git` - For commit history
- `grep`, `awk`, `sed` - Text processing
- `find` - File searching

**Optional**:
- `jq` - JSON parsing (recommended but not required)

**Check dependencies**:
```bash
./scripts/extract_learnings.sh
# Script will auto-check and prompt if missing
```

---

## 📝 How It Works

### Workflow

```
1. Scan git log since specified date
         ↓
2. Extract estimation data from plan retrospectives
         ↓
3. Identify recurring pitfalls (fix/bug commits)
         ↓
4. Identify successful patterns (feat/improve commits)
         ↓
5. Categorize and count occurrences
         ↓
6. Filter patterns (min 2 occurrences)
         ↓
7. Update LEARNINGS.md (or dry-run preview)
         ↓
8. Create backup (.backup file)
         ↓
9. Update "Last Updated" timestamp
```

### Example Output

```
📊 LEARNINGS.md Auto-Extraction
   Scanning git history since: 6 months ago

ℹ️  Extracting estimation patterns from plan retrospectives...
✅ Found 3 estimation patterns
📊 Summary:
   Average Estimated: 4.5h
   Average Actual: 5.5h
   Accuracy: 82%

ℹ️  Extracting common pitfalls from commit messages...
✅ Found 3 recurring pitfall categories
  🔍 Firebase/Firestore: 4 occurrences
  🔍 Localization: 3 occurrences
  🔍 Theme/Colors: 2 occurrences

ℹ️  Extracting successful patterns from commit messages...
✅ Found 2 successful patterns
  ✨ Clean Architecture: 5 occurrences
  ✨ Reusable Components: 3 occurrences

ℹ️  Updating LEARNINGS.md with extracted patterns...
✅ LEARNINGS.md updated successfully!
ℹ️  Backup saved at: docs/plans/LEARNINGS.md.backup

📝 Next steps:
1. Review changes: diff docs/plans/LEARNINGS.md.backup docs/plans/LEARNINGS.md
2. Commit: git add docs/plans/LEARNINGS.md && git commit -m "docs: update learnings from git history"
```

---

## 🔒 Safety Features

### Automatic Backup

Every run creates a backup:
```bash
docs/plans/LEARNINGS.md.backup
```

### Dry-Run Mode

Preview changes without modifying LEARNINGS.md:
```bash
./scripts/extract_learnings.sh --dry-run
```

### Rollback

If you don't like the changes:
```bash
# Restore from backup
mv docs/plans/LEARNINGS.md.backup docs/plans/LEARNINGS.md
```

---

## 🎯 Integration with task-master.dev

This script is part of the **task-master.dev integration** (FASE 3):

1. **Manual Planning** → User creates plans via `/taskmaster` or `git plan`
2. **Execution** → User implements with TodoWrite tracking
3. **Retrospective** → User fills retrospective in plan document
4. **Extraction** → This script auto-populates LEARNINGS.md ✅ YOU ARE HERE
5. **Application** → Claude applies learnings to future estimates

**See Also**:
- `CLAUDE.md` - REGOLA #14 for full workflow
- `docs/plans/2025-01-15-taskmaster-integration-design.md` - Design document
- `scripts/taskmaster_plan.sh` - CLI planning tool
- `.claude/commands/taskmaster.md` - Slash command

---

## 🆘 Troubleshooting

### "No plan documents found"

**Cause**: No `*-plan.md` files in `docs/plans/`
**Solution**: Create at least one plan via `/taskmaster` or `git plan` first

### "No retrospective data found"

**Cause**: Plan documents don't have `## 📊 Post-Milestone Retrospective` section filled
**Solution**: Complete at least one milestone and fill retrospective section

### "No pitfall patterns found"

**Cause**: Not enough git commits in timeframe
**Solution**: Extend timeframe: `--since "1 year ago"`

### Script not executable

**Cause**: Missing execute permission
**Solution**:
```bash
chmod +x scripts/extract_learnings.sh
```

---

## 📚 Related Documentation

- **CLAUDE.md** - REGOLA #14: LEARNINGS.md Auto-Population
- **docs/plans/LEARNINGS.md** - The file that gets updated
- **docs/plans/CONTEXT.md** - Milestone tracking
- **Design Document** - `docs/plans/2025-01-15-taskmaster-integration-design.md`

---

**Version**: 1.0
**Status**: FASE 3 Complete
**Part of**: task-master.dev integration
