# Fix Async Warnings

Automatically fix `use_build_context_synchronously` and `unawaited_futures` warnings.

## What It Does

**Patterns Fixed:**

1. **BuildContext Async Safety**
   - Adds `if (!mounted) return;` after `await` statements
   - Prevents crashes from using context after widget disposal

2. **Unawaited Futures**
   - Wraps fire-and-forget calls with `unawaited()`
   - Patterns: `ref.read().notifier.method()`, `HapticFeedback.*()`, animation controllers
   - Adds `import 'dart:async';` if missing

## Usage

```bash
# Preview changes (dry-run)
python3 scripts/fix_async_warnings.py --dry-run

# Fix all warnings
python3 scripts/fix_async_warnings.py

# Fix specific file
python3 scripts/fix_async_warnings.py --file lib/path/to/file.dart
```

## When to Use

- After implementing new features
- Before creating a PR
- Periodically during development
- When `flutter analyze` shows async warnings

## Safety

- **Dry-run first**: Always preview changes with `--dry-run`
- **Review diffs**: Check `git diff` after running
- **Test manually**: Verify app still works correctly
- **Commit separately**: Easy to revert if needed

## Example Output

```
🔍 Scanning for async warnings...
📊 Found 15 BuildContext + 8 unawaited warnings

🔧 Fixing use_build_context_synchronously warnings...

📄 lib/features/home/presentation/widgets/card.dart
  ✅ Added mounted check at line 45

🔧 Fixing unawaited_futures warnings...

📄 lib/features/buddy/presentation/widgets/fab.dart
  ✅ Wrapped with unawaited() at line 233

✨ Summary: 23/23 warnings fixed

✅ Done! Run 'flutter analyze' to verify
```

## Limitations

- Only fixes common patterns (not all edge cases)
- May need manual adjustment for complex async flows
- Doesn't understand business logic context
- Review changes before committing

## Pro Tips

1. **Run dry-run first**: `python3 scripts/fix_async_warnings.py --dry-run`
2. **Commit often**: Fix → Test → Commit → Repeat
3. **Batch by feature**: `--file` flag for controlled fixes
4. **Verify**: Always run `flutter analyze` after
5. **Test**: Quick smoke test on real device

---

**Created by**: Claude Code automation
**Last Updated**: 2025-11-02
