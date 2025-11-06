# Interactive Async Warnings Checker

**Interactive tool** to check and fix `use_build_context_synchronously` and `unawaited_futures` warnings - **you control every fix**.

## What It Does

Scans your code for async warnings and **prompts you interactively**:

1. **Shows** code context around each warning
2. **Explains** why the warning exists (press `E`)
3. **Previews** the suggested fix (press `P`)
4. **Waits** for your decision: Accept, Skip, or Quit
5. **Saves** progress so you can resume later

## Usage

```bash
# Interactive mode (RECOMMENDED)
python3 scripts/fix_async_warnings.py

# Check specific file only
python3 scripts/fix_async_warnings.py --file lib/path/to/file.dart

# Resume from previous session
python3 scripts/fix_async_warnings.py --resume
```

## Interactive Commands

| Key | Action | Description |
|-----|--------|-------------|
| **A** | **Accept** | Apply the fix |
| **S** | **Skip** | Skip this warning |
| **P** | **Preview** | Show suggested fix |
| **E** | **Explain** | Learn why warning exists |
| **Q** | **Quit** | Save progress and exit |

## Example Session

```
🔍 Scanning for async warnings...
📊 Found 77 BuildContext + 56 unawaited warnings
   Total: 133 warnings to check

Press Enter to start...

======================================================================
[1/133] use_build_context_synchronously
📄 lib/features/home/widgets/card.dart:45
======================================================================

📄 Current code:
    42:   Future<void> loadData() async {
    43:     await fetchData();
>>> 44:     Navigator.of(context).push(...);
    45:   }

[A]ccept [S]kip [P]review [E]xplain [Q]uit? e

📚 BuildContext Async Safety Explanation:
⚠️  PROBLEM:
   After 'await', your widget might be disposed (unmounted).
   Using 'context' after await without checking can crash.

✅  SOLUTION:
   Add 'if (!mounted) return;' after await statements.

[A]ccept [S]kip [P]review [E]xplain [Q]uit? p

🔍 Suggested fix:
    43: await fetchData();
>>> NEW : if (!mounted) return;

    44: Navigator.of(context).push(...);

[A]ccept [S]kip [P]review [E]xplain [Q]uit? a

✅ Fixed!
```

## Warning Types

### 1. BuildContext Async Safety

**Problem**: Context used after `await` without mounted check
**Fix**: Adds `if (!mounted) return;` after await

### 2. Unawaited Futures

**Problem**: Async function called but not awaited
**Fix**: Wraps with `unawaited()` and adds `import 'dart:async';`

## When to Use

- **After implementing** new features
- **Before creating** a PR
- **When `flutter analyze`** shows async warnings
- **Periodically** during development

## Best Practices

1. **Start with `E`** (Explain) for new patterns
2. **Always `P`** (Preview) before accepting
3. **Work in sessions**: Fix 20-30 warnings, then `Q` (Quit)
4. **Resume later**: `--resume` flag continues where you left off
5. **Test after**: `flutter run` to verify fixes work
6. **Commit often**: One session = one commit

## Progress Tracking

Tool saves progress to `.async_warnings_progress.json`:

```bash
# Session 1: Fix 20 warnings
python3 scripts/fix_async_warnings.py
# [Process 20, then Q]

💾 Saving progress...
✨ Session summary:
   ✅ Fixed: 18
   ⏭️  Skipped: 2
   📊 Progress: 20/133 (15%)

# Session 2: Resume
python3 scripts/fix_async_warnings.py --resume

📂 Resuming from warning 21/133
```

## Advantages

- ✅ **Full control**: You decide every fix
- ✅ **Educational**: Learn Flutter async patterns
- ✅ **Safe**: Preview before applying
- ✅ **Resumable**: Quit and continue anytime
- ✅ **Focused**: `--file` flag for specific files

## Pro Tips

1. **Batch by feature**: Use `--file` for one feature at a time
2. **Learn first**: Press `E` for patterns you don't know
3. **Preview always**: Press `P` before `A`
4. **Skip complex**: Press `S` for complex async flows (manual review)
5. **Session length**: 20-30 warnings (~15 minutes) per session

---

**Type**: Interactive Checker (User-Controlled)
**Created**: 2025-11-02
**Full docs**: `scripts/ASYNC_WARNINGS_README.md`
