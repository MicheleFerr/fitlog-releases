# Interactive Async Warnings Checker

**Interactive tool** to check and fix `use_build_context_synchronously` and `unawaited_futures` warnings in Flutter code - **with full user control**.

## Quick Start

```bash
# 1. Run interactive checker (RECOMMENDED)
python3 scripts/fix_async_warnings.py

# 2. Check specific file only
python3 scripts/fix_async_warnings.py --file lib/path/to/file.dart

# 3. Resume from previous session
python3 scripts/fix_async_warnings.py --resume
```

## What It Does

The tool scans your code for async warnings and **prompts you interactively** for each one:

- **Shows** the warning location and code context
- **Explains** why the warning exists (press `E`)
- **Previews** the suggested fix (press `P`)
- **Waits** for your decision: Accept, Skip, or Quit
- **Saves** progress so you can resume later

## Interactive Workflow

```
🔍 Scanning for async warnings...
📊 Found 77 BuildContext + 56 unawaited warnings
   Total: 133 warnings to check

💡 Interactive mode:
   [A]ccept - Apply the suggested fix
   [S]kip - Skip this warning
   [P]review - Show suggested fix before applying
   [E]xplain - Learn why this warning exists
   [Q]uit - Save progress and exit (use --resume to continue)

Press Enter to start...

======================================================================
[1/133] use_build_context_synchronously
📄 lib/features/home/presentation/widgets/card.dart:45
======================================================================

📄 Current code:
    42:   Future<void> loadData() async {
    43:     await fetchData();
>>> 44:     Navigator.of(context).push(...);
    45:   }
    46:

[A]ccept [S]kip [P]review [E]xplain [Q]uit? p

🔍 Suggested fix:
    43: await fetchData();
>>> NEW : if (!mounted) return;

    44: Navigator.of(context).push(...);

[A]ccept [S]kip [P]review [E]xplain [Q]uit? a

🔧 Applying fix...
✅ Fixed!

======================================================================
[2/133] unawaited_futures
📄 lib/features/buddy/presentation/widgets/fab.dart:233
======================================================================
...
```

## Interactive Commands

| Command | Action | Description |
|---------|--------|-------------|
| **A** | **Accept** | Apply the suggested fix to the code |
| **S** | **Skip** | Skip this warning (move to next) |
| **P** | **Preview** | Show what the fix will look like |
| **E** | **Explain** | Learn why this warning exists |
| **Q** | **Quit** | Save progress and exit (resume later with `--resume`) |

## Warning Types Fixed

### 1. BuildContext Async Safety (`use_build_context_synchronously`)

**Problem:**
```dart
Future<void> loadData() async {
  await fetchData();
  Navigator.of(context).push(...);  // ⚠️ Warning: context might be invalid
}
```

**Fix (when you press `A`):**
```dart
Future<void> loadData() async {
  await fetchData();
  if (!mounted) return;  // ✅ Safety check added
  Navigator.of(context).push(...);
}
```

**Why?** After an `await`, your widget might be disposed. The `mounted` check prevents crashes.

### 2. Unawaited Futures (`unawaited_futures`)

**Problem:**
```dart
void refresh() async {
  await loadData();
  ref.read(provider.notifier).refresh();  // ⚠️ Warning: Future not awaited
}
```

**Fix (when you press `A`):**
```dart
import 'dart:async';  // ✅ Import added if missing

void refresh() async {
  await loadData();
  unawaited(ref.read(provider.notifier).refresh());  // ✅ Marked as fire-and-forget
}
```

**Why?** Explicitly marks the operation as "fire-and-forget" so the analyzer knows it's intentional.

## Usage Examples

### Example 1: Interactive Session

```bash
$ python3 scripts/fix_async_warnings.py

🔍 Scanning for async warnings...
📊 Found 77 BuildContext + 56 unawaited warnings
   Total: 133 warnings to check

Press Enter to start...

[1/133] use_build_context_synchronously
📄 lib/features/home/widgets/card.dart:45

[A]ccept [S]kip [P]review [E]xplain [Q]uit? e

📚 BuildContext Async Safety Explanation:

⚠️  PROBLEM:
   After an 'await' statement, your widget might be disposed (unmounted).
   If you use 'context' after the await without checking, it can crash.

✅  SOLUTION:
   Add 'if (!mounted) return;' after await statements.
   This checks if the widget is still alive before using context.

[A]ccept [S]kip [P]review [E]xplain [Q]uit? p

🔍 Suggested fix:
    43: await fetchData();
>>> NEW : if (!mounted) return;

    44: Navigator.of(context).push(...);

[A]ccept [S]kip [P]review [E]xplain [Q]uit? a

✅ Fixed!
```

### Example 2: Resume Session

```bash
# Start checking
$ python3 scripts/fix_async_warnings.py

[1/133] ... [Accept 5 warnings]
[6/133] ... [Press Q to quit]

💾 Saving progress... (use --resume to continue)
✨ Session summary:
   ✅ Fixed: 5
   ⏭️  Skipped: 0
   📊 Progress: 6/133 (4%)

# Later: Resume from warning 6
$ python3 scripts/fix_async_warnings.py --resume

📂 Resuming from warning 6/133
[6/133] ...
```

### Example 3: Check Specific File

```bash
# Only check warnings in one file
$ python3 scripts/fix_async_warnings.py --file lib/features/home/presentation/widgets/card.dart

📊 Found 3 BuildContext + 1 unawaited warnings
   Total: 4 warnings to check
```

## Workflow Integration

### During Development

```bash
# 1. Implement feature
vim lib/features/new_feature/...

# 2. Run analyzer
flutter analyze

# 3. If async warnings appear, run interactive checker
python3 scripts/fix_async_warnings.py

# 4. Accept/skip warnings interactively
# [A]ccept the ones you understand
# [E]xplain the ones you're unsure about
# [P]review before accepting

# 5. Verify
flutter analyze

# 6. Commit
git add -A
git commit -m "fix: async safety improvements"
```

### Before PR

```bash
# Interactive cleanup of all async warnings
python3 scripts/fix_async_warnings.py

# Review each warning
# Accept safe ones, skip complex ones for manual review

# Verify
flutter analyze

# Commit
git add -A
git commit -m "fix: resolve async warnings before PR"
```

## Features

### ✅ Advantages of Interactive Mode

- **Full control**: You decide which fixes to apply
- **Learn as you go**: Explanations help you understand patterns
- **Preview first**: See the fix before applying
- **Safe**: No unexpected changes
- **Resumable**: Quit and continue later
- **Educational**: Helps you learn Flutter async patterns

### 🎯 Progress Tracking

The tool saves your progress to `.async_warnings_progress.json`:

```json
{
  "index": 15,
  "type": "use_build_context_synchronously"
}
```

You can quit anytime (press `Q`) and resume later with `--resume`.

## Patterns Recognized

### BuildContext Patterns
- After `await` statements
- Before `Navigator.of(context)`
- Before `ScaffoldMessenger.of(context)`
- Before any `context` usage after async gap

### Unawaited Patterns
- `ref.read(...).notifier.method()`
- `Navigator.of(context).push(...)`
- `HapticFeedback.*()`
- `_controller.forward()`
- `_controller.reverse()`

## Best Practices

1. **Start with explanations** (press `E` for new patterns)
   ```
   [E]xplain → Understand why → [P]review → [A]ccept
   ```

2. **Preview before accepting** (press `P`)
   ```bash
   # See what will change before applying
   [P]review first, then [A]ccept or [S]kip
   ```

3. **Work in sessions** (use `Q` to quit, `--resume` to continue)
   ```bash
   # Session 1: Fix 20 warnings
   python3 scripts/fix_async_warnings.py
   # [Process 20, then Q]

   # Session 2: Continue
   python3 scripts/fix_async_warnings.py --resume
   ```

4. **Batch by feature** (use `--file` for focused work)
   ```bash
   # Fix home feature only
   python3 scripts/fix_async_warnings.py --file lib/features/home/...
   # Test home feature
   # Commit

   # Next feature
   python3 scripts/fix_async_warnings.py --file lib/features/buddy/...
   ```

5. **Test after each session**
   ```bash
   flutter run
   # Test affected features
   git add -A
   git commit -m "fix: async safety in home feature"
   ```

## Troubleshooting

### Tool Won't Start

**Error: flutter: command not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Error: Permission denied**
```bash
chmod +x scripts/fix_async_warnings.py
```

### Progress File Issues

**Error: Can't resume / corrupt progress**
```bash
# Delete progress file and start fresh
rm .async_warnings_progress.json
python3 scripts/fix_async_warnings.py
```

### False Positives

Some warnings might not need fixing:
- **Press `S` to skip** if the warning is safe to ignore
- **Press `E` to understand** why the warning exists
- **Manual review** complex async flows

## Integration with Claude Code

Use slash command for convenience:
```
/fix-async
```

Or run directly:
```bash
python3 scripts/fix_async_warnings.py
```

## Statistics

From testing (2025-11-02):
- **Total warnings**: 133 (77 BuildContext + 56 unawaited)
- **Interactive approach**: Full user control
- **Time per warning**: ~10-15 seconds (with explanations)
- **Session length**: ~20-30 warnings before needing a break
- **Estimated total time**: 30-45 minutes (can pause/resume)

## Contributing

If you find a pattern that should be recognized:

1. Document the pattern
2. Add regex to `patterns` list in script
3. Test with real warning
4. Submit PR

---

**Created**: 2025-11-02
**Last Updated**: 2025-11-02
**Author**: Claude Code
**Type**: Interactive Checker (User-Controlled)
