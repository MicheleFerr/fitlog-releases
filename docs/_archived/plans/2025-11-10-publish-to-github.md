# Publish GymBro Flutter Project to GitHub

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Push the GymBro Flutter project to GitHub and configure it for ongoing development and collaboration.

**Architecture:**
1. Clean up untracked backup/report files by updating .gitignore
2. Review and commit pending changes (docs/NAVIGATION/INDEX.md, home_screen_optimized.dart)
3. Configure GitHub remote URL
4. Push main branch to GitHub
5. Verify successful push and document repository details

**Tech Stack:** Git, GitHub, Flutter

---

## Task 1: Update .gitignore to Exclude Backup & Report Files

**Files:**
- Modify: `.gitignore`

**Context:** Your project has many backup files (.bak), reports, and temporary files that should NOT be tracked:
- `*.l10n_backup` (localization backups)
- `*.textstyle_backup*` (theme backups)
- `*_REPORT.md`, `*_report.txt` (temporary reports)
- `docs/archived/` (archived docs)
- Temporary JSON files from scripts

**Step 1: Add rules to .gitignore**

Append these lines to `.gitignore`:

```gitignore
# GymBro Project - Backup & Temporary Files
*.bak
*.backup
*.tmp
*.l10n_backup
*.textstyle_backup*
*_backup
*_BACKUP
*_backup/
docs/archived/
docs/plans/
design_violations_report.txt
*_REPORT.md
*_REPORT.txt
*_report.md
*_report.txt
*_SESSION_*.md
CONSULTANT_*.md
EXECUTIVE_*.md
FINAL_*.md
MEMORY_*.md
PRE_COMMIT_*.md
SESSION_*.md
HOOK_*.md
*.batch*
*.py
fix_*.py
temp_*.json
*.test
firestore.rules.test
```

**Step 2: Verify changes**

Run:
```bash
cd /Users/michele/gymbro_flutter_new
cat .gitignore | tail -30
```

Expected output: New rules visible at end of file

**Step 3: Remove already-tracked backup files from git**

Run these commands to unstage the backup files:

```bash
git rm --cached '*.l10n_backup' 2>/dev/null || true
git rm --cached '*.bak' 2>/dev/null || true
git rm --cached '*_REPORT.md' 2>/dev/null || true
git rm --cached 'CONSULTANT_*.md' 2>/dev/null || true
git rm --cached 'EXECUTIVE_*.md' 2>/dev/null || true
git rm --cached 'FINAL_*.md' 2>/dev/null || true
git rm --cached 'MEMORY_*.md' 2>/dev/null || true
git rm --cached 'SESSION_*.md' 2>/dev/null || true
git rm --cached 'PRE_COMMIT_*.md' 2>/dev/null || true
git rm --cached 'design_violations_report.txt' 2>/dev/null || true
git rm --cached 'firestore.rules.test' 2>/dev/null || true
git rm --cached '*.batch*' 2>/dev/null || true
git rm --cached 'fix_*.py' 2>/dev/null || true
git rm --cached 'docs/archived/**' 2>/dev/null || true
```

**Step 4: Check git status**

Run:
```bash
git status
```

Expected output: .gitignore shows as modified, backup files removed from staging

**Step 5: Commit .gitignore update**

Run:
```bash
git add .gitignore
git commit -m "chore: update .gitignore to exclude backup files and temporary reports"
```

Expected output:
```
[main xxxxx] chore: update .gitignore to exclude backup files and temporary reports
 1 file changed, X insertions(+)
```

---

## Task 2: Review Pending Changes

**Files:**
- Check: `docs/NAVIGATION/INDEX.md` (modified)
- Check: `lib/features/home/presentation/home_screen_optimized.dart` (modified)

**Context:** These files are modified but not yet committed. Need to decide:
- Keep changes and commit them
- Discard changes

**Step 1: View current status**

Run:
```bash
git status -s
```

Expected output: Shows M (modified) files

**Step 2: Review the modified files**

For INDEX.md:
```bash
git diff docs/NAVIGATION/INDEX.md | head -50
```

For home_screen:
```bash
git diff lib/features/home/presentation/home_screen_optimized.dart | head -50
```

**Step 3: Decide what to do**

**OPTION A: Commit the changes (recommended if they're improvements)**
```bash
git add docs/NAVIGATION/INDEX.md lib/features/home/presentation/home_screen_optimized.dart
git commit -m "feat: update navigation index and optimize home screen"
```

**OPTION B: Discard the changes (if you want clean slate)**
```bash
git restore docs/NAVIGATION/INDEX.md
git restore lib/features/home/presentation/home_screen_optimized.dart
```

**For this plan: ASSUME OPTION A (commit the changes)**

Expected output after commit:
```
[main xxxxx] feat: update navigation index and optimize home screen
 2 files changed, X insertions(+)
```

**Step 4: Verify clean status**

Run:
```bash
git status
```

Expected output: `nothing to commit, working tree clean`

---

## Task 3: Create GitHub Repository

**Context:** You need to create a new repository on github.com first.

**Step 1: Go to GitHub**

1. Open https://github.com/new in your browser
2. Fill in:
   - **Repository name**: `gymbro-flutter` (or your preferred name)
   - **Description**: "FitLog Pro - Flutter fitness tracking app with clean architecture, Riverpod, and Firebase"
   - **Public/Private**: Choose your preference (public = open source, private = only you/collaborators)
   - **Add .gitignore**: Select "Dart" (we already have one, but helps for reference)
   - **Add license**: Optional (MIT, GPL, etc.)
3. Click "Create repository"

**Step 2: Copy the repository URL**

After creation, you'll see:
```
https://github.com/your-username/gymbro-flutter.git
```

(or SSH variant if you have SSH configured)

Save this URL for Task 4.

**Step 3: Note the HTTPS URL**

Example:
```
https://github.com/yourusername/gymbro-flutter.git
```

You'll use this in Task 4.

---

## Task 4: Configure GitHub Remote

**Files:**
- Configure: Git remote (no file changes)

**Context:** Connect your local repository to the GitHub repository.

**Step 1: Add GitHub remote**

Replace `YOUR-USERNAME` and `YOUR-REPO-NAME` with your actual values:

```bash
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
```

Example:
```bash
git remote add origin https://github.com/michele/gymbro-flutter.git
```

**Step 2: Verify remote is configured**

Run:
```bash
git remote -v
```

Expected output:
```
origin  https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git (fetch)
origin  https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git (push)
```

**Step 3: Check current branch**

Run:
```bash
git branch -M main
git branch
```

Expected output:
```
* main
```

(Your branch is already "main", which is correct)

---

## Task 5: Push to GitHub

**Files:**
- Push: All commits on main branch

**Context:** Upload your local commits to GitHub.

**Step 1: Push main branch**

Run:
```bash
git push -u origin main
```

Expected output:
```
Enumerating objects: XXX, done.
Counting objects: 100% (XXX/XXX), done.
Delta compression using up to 8 threads
Compressing objects: 100% (XXX/XXX), done.
Writing objects: 100% (XXX/XXX), X.XX MiB | X.XX MiB/s, done.
Total XXX (delta XXX), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (XXX/XXX), done.
To https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
 * [new branch]      main -> main
Branch 'main' set up to track remote tracking branch 'main' from 'origin'.
```

**Step 2: Verify push succeeded**

Run:
```bash
git log --oneline -5
git remote -v
```

Expected output:
- Recent commits visible
- Remote configured correctly

**Step 3: Visit GitHub to verify**

1. Go to https://github.com/YOUR-USERNAME/YOUR-REPO-NAME
2. Verify you see:
   - All your files and folders
   - Commit history in the main branch
   - .gitignore file present
   - README.md (if you have one)

---

## Task 6: Verify Successful Push & Document Setup

**Files:**
- Create: `.github/REPOSITORY_INFO.md` (optional documentation)

**Step 1: Verify all commits pushed**

Run:
```bash
git log --oneline origin/main | head -10
git log --oneline | head -10
```

Expected: Both should show the same recent commits

**Step 2: Check GitHub branch protection (optional)**

If you want to prevent direct pushes to main and require pull requests:

1. Go to GitHub repository Settings → Branches
2. Click "Add rule"
3. Set pattern to `main`
4. Enable "Require pull request reviews before merging"
5. Click "Create"

**Step 3: Final verification**

Run:
```bash
git branch -vv
```

Expected output:
```
* main a1b2c3d [origin/main] <latest commit message>
```

**Step 4: Document repository info (optional)**

If desired, create `.github/REPOSITORY_INFO.md`:

```markdown
# GymBro Flutter Repository

## GitHub Setup

- **Repository**: https://github.com/YOUR-USERNAME/YOUR-REPO-NAME
- **Branch**: main
- **Setup Date**: 2025-11-10
- **Framework**: Flutter
- **Architecture**: Clean Architecture + Riverpod
- **Database**: Firebase Firestore

## Development Workflow

### Clone the repository:
```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
cd YOUR-REPO-NAME
```

### Install dependencies:
```bash
flutter pub get
```

### Run the app:
```bash
flutter run
```

### Run tests:
```bash
flutter test
```

## Project Structure

See `docs/NAVIGATION/INDEX.md` for complete documentation.

## Contributing

- Follow the guidelines in `CLAUDE.md`
- Pre-commit hooks enforce code standards
- All features should be documented in `docs/`
- Use conventional commits: `feat:`, `fix:`, `docs:`, etc.
```

Run:
```bash
mkdir -p .github
# Create the file with content above
git add .github/REPOSITORY_INFO.md
git commit -m "docs: add GitHub repository info"
git push
```

---

## Success Criteria

✅ All of the following must be true:

1. ✅ .gitignore updated with backup file exclusions
2. ✅ Pending changes committed (or discarded)
3. ✅ GitHub remote configured (`git remote -v` shows origin)
4. ✅ Main branch pushed to GitHub (`git push -u origin main` succeeded)
5. ✅ GitHub repository page shows all files and commit history
6. ✅ Can clone from GitHub: `git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git`
7. ✅ Branch tracking configured: `git branch -vv` shows `[origin/main]`

---

## Next Steps After Publishing

1. **Protect main branch**: Settings → Branches → Add rule for `main`
2. **Add GitHub Actions** (optional): Automated tests/builds on push
3. **Create development branch**: `git checkout -b develop` for ongoing work
4. **Share repository**: Send URL to collaborators
5. **Setup GitHub Pages** (optional): Auto-host documentation from `docs/`

---

## Troubleshooting

**Problem**: `git push` returns "Permission denied"
- **Solution**: Check SSH keys or switch to HTTPS with personal access token

**Problem**: `remote add origin` fails with "fatal: remote origin already exists"
- **Solution**: Run `git remote remove origin` first, then `git remote add origin <url>`

**Problem**: `git push` returns "non-matching ref"
- **Solution**: Your branch name might be different. Run `git branch` to check, then `git push -u origin <branch-name>`

---

## Commands Quick Reference

```bash
# Update .gitignore and commit
git add .gitignore
git commit -m "chore: update .gitignore"

# Add GitHub remote
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git

# Push to GitHub
git push -u origin main

# Verify
git remote -v
git branch -vv
```
