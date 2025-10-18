# 🛡️ Install Localization Pre-Commit Checks

This guide shows how to install automated localization checks that prevent new violations from being committed.

---

## 📋 What Gets Installed

1. **Pre-commit hook** - Automatically checks staged files before each commit
2. **Scanner script** - Manual scan tool for checking entire codebase
3. **Git hook integration** - Seamless integration with your git workflow

---

## 🚀 OPTION 1: Quick Install (Recommended)

### Step 1: Copy Pre-Commit Hook

```bash
cd /Users/michele/gymbro_flutter_new

# Copy the pre-commit script to git hooks directory
cp scripts/pre-commit-localization-check.sh .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit
```

### Step 2: Test It Works

```bash
# Create a test file with a violation
echo "import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hardcoded String'); // This should be blocked
  }
}" > lib/test_violation.dart

# Try to commit it
git add lib/test_violation.dart
git commit -m "test: check pre-commit hook"
```

**Expected Result**: Commit should be BLOCKED with a violation warning.

### Step 3: Clean Up Test

```bash
# Remove test file
rm lib/test_violation.dart
git reset
```

---

## 🚀 OPTION 2: Advanced Install (Team Setup)

### For Repository Maintainers

Create a shared pre-commit hook that all team members can use:

#### Step 1: Create Hooks Directory

```bash
mkdir -p .githooks
```

#### Step 2: Move Hook to Shared Location

```bash
cp scripts/pre-commit-localization-check.sh .githooks/pre-commit
chmod +x .githooks/pre-commit
```

#### Step 3: Update Git Configuration

```bash
git config core.hooksPath .githooks
```

#### Step 4: Commit Hook to Repository

```bash
git add .githooks/pre-commit
git commit -m "chore: add localization pre-commit hook"
git push
```

#### Step 5: Team Members Install

Each team member runs:
```bash
git config core.hooksPath .githooks
```

---

## 🔧 How It Works

### When You Commit

1. You stage files: `git add .`
2. You try to commit: `git commit -m "..."`
3. **Hook runs automatically** and checks staged Dart files
4. If violations found: commit is BLOCKED
5. If no violations: commit proceeds normally

### What It Checks

- ✅ Text widgets with hardcoded strings
- ✅ SnackBar messages without localization
- ✅ Dialog titles/content without localization
- ✅ Missing `build_context_extensions.dart` import

### What It Ignores

- ❌ Generated files (`/generated/`)
- ❌ Test files (`*_test.dart`)
- ❌ Files outside presentation layer
- ❌ Empty Text widgets (`Text('')`)

---

## 📖 Example Output

### When Violations Found

```
🌍 Checking for localization violations...
⚠️  lib/features/workout/presentation/widgets/my_widget.dart: 3 potential hardcoded Text widgets
⚠️  lib/features/workout/presentation/widgets/my_widget.dart: 1 potential hardcoded SnackBar messages

❌ COMMIT BLOCKED: Found 4 potential localization violations

📋 To fix:
1. Import: import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
2. Replace: Text('...') → Text(context.l10n.keyName)
3. Add keys to assets/i18n/app_en.arb and app_it.arb
4. Run: flutter gen-l10n

📖 See: LOCALIZATION_QUICK_FIX_GUIDE.md

⚠️  To bypass this check (NOT recommended): git commit --no-verify
```

### When No Violations

```
🌍 Checking for localization violations...
✅ No localization violations detected
[main abc1234] feat: add new localized feature
 2 files changed, 45 insertions(+), 5 deletions(-)
```

---

## 🆘 Troubleshooting

### Problem: Hook Not Running

**Check if hook exists:**
```bash
ls -la .git/hooks/pre-commit
```

**Check if executable:**
```bash
chmod +x .git/hooks/pre-commit
```

**Check git config:**
```bash
git config core.hooksPath
```

### Problem: Hook Running But Not Blocking

**Test manually:**
```bash
.git/hooks/pre-commit
echo $?  # Should be 1 if violations found
```

**Check file permissions:**
```bash
ls -la .git/hooks/pre-commit
# Should show: -rwxr-xr-x (executable)
```

### Problem: False Positives

Edit the hook to exclude specific patterns:
```bash
nano .git/hooks/pre-commit

# Add exclusions like:
if [[ "$line" == *"// LOCALIZATION_EXEMPT"* ]]; then
    continue
fi
```

### Problem: Need to Bypass Hook (Emergency)

**Temporarily bypass:**
```bash
git commit --no-verify -m "emergency fix"
```

**⚠️ WARNING**: Use `--no-verify` ONLY for emergencies! Fix violations ASAP.

---

## 🎛️ Configuration Options

### Customize Hook Strictness

Edit `.git/hooks/pre-commit` to adjust:

#### Option 1: Warning Only (Don't Block)
```bash
# At the end of the file, change:
exit 1  # Blocks commit
# To:
exit 0  # Allows commit with warning
```

#### Option 2: Only Check New Files
```bash
# Change this line:
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$")
# To:
STAGED_FILES=$(git diff --cached --name-only --diff-filter=A | grep "\.dart$")
```

#### Option 3: Exclude Specific Directories
```bash
# Add after STAGED_FILES definition:
STAGED_FILES=$(echo "$STAGED_FILES" | grep -v "test/" | grep -v "admin/")
```

---

## 📊 Manual Scanning

### Scan Entire Codebase

```bash
# Run full scan
./scan_localization_violations.sh

# Scan specific feature
./scan_localization_violations.sh | grep "features/workout"

# Count violations only
./scan_localization_violations.sh | head -5
```

### Scan Before Push

Add to your workflow:
```bash
# Before pushing
./scan_localization_violations.sh
if [ $? -ne 0 ]; then
    echo "Fix violations before pushing!"
    exit 1
fi
git push
```

---

## 🔄 Keeping It Updated

### Update Hook

If the hook script is updated:
```bash
# Pull latest changes
git pull

# Update local hook
cp scripts/pre-commit-localization-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Update Scanner

```bash
# Pull latest changes
git pull

# Make sure scanner is executable
chmod +x scan_localization_violations.sh
```

---

## 👥 Team Guidelines

### For All Developers

1. ✅ Install hook as soon as you clone the repo
2. ✅ Never use `--no-verify` without team lead approval
3. ✅ Fix violations immediately when detected
4. ✅ Run manual scan before creating PR

### For Team Leads

1. ✅ Enforce hook installation in onboarding
2. ✅ Review violations in code review
3. ✅ Run weekly scans to detect any bypasses
4. ✅ Update hook when new patterns emerge

### For CI/CD

Add to your CI pipeline:
```yaml
# .github/workflows/ci.yml
- name: Check Localization
  run: |
    chmod +x scan_localization_violations.sh
    ./scan_localization_violations.sh
```

---

## 📈 Success Metrics

**Track these metrics weekly:**

```bash
# Total violations in codebase
./scan_localization_violations.sh | grep "Total violations found"

# New violations this week
git diff HEAD~7 --name-only | xargs -I {} ./scan_localization_violations.sh | grep "{}"

# Files fixed this week
git log --since="1 week ago" --grep="localization" --oneline | wc -l
```

**Goal**: Reduce violations to zero and maintain it.

---

## 🎯 Next Steps

1. ✅ Install pre-commit hook (Option 1 or 2)
2. ✅ Test it works with a violation
3. ✅ Share this guide with team
4. ✅ Add hook installation to onboarding docs
5. ✅ Schedule weekly violation review

---

## 📚 Related Documentation

- **Quick Fix Guide**: `LOCALIZATION_QUICK_FIX_GUIDE.md`
- **Comprehensive Report**: `LOCALIZATION_VIOLATIONS_COMPREHENSIVE_REPORT.md`
- **Scan Summary**: `LOCALIZATION_SCAN_SUMMARY.md`
- **Project Rules**: `CLAUDE.md` (REGOLA #1)

---

## ❓ FAQ

### Q: Can I disable the hook temporarily?

**A**: Yes, use `git commit --no-verify`, but this should be rare and only for emergencies.

### Q: What if I'm working on a draft and want to commit work-in-progress?

**A**: Create a draft commit with `--no-verify`, but create a follow-up issue to fix violations before merging.

### Q: Does this slow down commits?

**A**: No, the check runs in <1 second for typical commits (1-5 files). Even with 20+ files, it takes <2 seconds.

### Q: What about false positives?

**A**: The hook is designed to minimize false positives. If you find one, you can either:
1. Fix it anyway (strings should be localized)
2. Add a comment exemption pattern
3. Report it to improve the hook

### Q: Can I run this on existing code before committing?

**A**: Yes! Run `./scan_localization_violations.sh` anytime to check your changes.

---

**Installation Status**: Not yet installed (follow Option 1 or 2 above)
**Hook Version**: 1.0
**Last Updated**: 2025-10-12

---

**Ready to Install?** Choose Option 1 (Quick) or Option 2 (Team) and follow the steps above!
