# Async Warnings Auto-Fixer

Automatic tool to fix `use_build_context_synchronously` and `unawaited_futures` warnings in Flutter code.

## Quick Start

```bash
# 1. Preview changes (ALWAYS DO THIS FIRST)
python3 scripts/fix_async_warnings.py --dry-run

# 2. Apply fixes
python3 scripts/fix_async_warnings.py

# 3. Verify
flutter analyze
```

## What It Fixes

### 1. BuildContext Async Safety (`use_build_context_synchronously`)

**Problem:**
```dart
Future<void> loadData() async {
  await fetchData();
  Navigator.of(context).push(...);  // ⚠️ Warning: context might be invalid
}
```

**Fixed:**
```dart
Future<void> loadData() async {
  await fetchData();
  if (!mounted) return;  // ✅ Safety check added
  Navigator.of(context).push(...);
}
```

### 2. Unawaited Futures (`unawaited_futures`)

**Problem:**
```dart
void refresh() async {
  await loadData();
  ref.read(provider.notifier).refresh();  // ⚠️ Warning: Future not awaited
}
```

**Fixed:**
```dart
import 'dart:async';  // ✅ Import added if missing

void refresh() async {
  await loadData();
  unawaited(ref.read(provider.notifier).refresh());  // ✅ Marked as fire-and-forget
}
```

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

## Usage Examples

### Fix All Warnings
```bash
python3 scripts/fix_async_warnings.py
```

Output:
```
🔍 Scanning for async warnings...
📊 Found 15 BuildContext + 8 unawaited warnings

🔧 Fixing use_build_context_synchronously warnings...
📄 lib/features/home/presentation/widgets/card.dart
  ✅ Added mounted check at line 45

✨ Summary: 23/23 warnings fixed
✅ Done! Run 'flutter analyze' to verify
```

### Preview Changes First (Recommended)
```bash
python3 scripts/fix_async_warnings.py --dry-run
```

Output:
```
🔍 DRY RUN MODE - No files will be modified

📄 lib/features/home/presentation/widgets/card.dart
  Would add at line 45: if (!mounted) return;

✨ Summary: 23/23 warnings would be fixed
💡 Run without --dry-run to apply changes
```

### Fix Specific File
```bash
python3 scripts/fix_async_warnings.py --file lib/features/home/presentation/widgets/card.dart
```

## Workflow Integration

### During Development
```bash
# 1. Implement feature
vim lib/features/new_feature/...

# 2. Run analyzer
flutter analyze

# 3. If async warnings appear, preview fix
python3 scripts/fix_async_warnings.py --dry-run

# 4. Apply fix
python3 scripts/fix_async_warnings.py

# 5. Verify
flutter analyze

# 6. Test
flutter run

# 7. Commit
git add -A
git commit -m "fix: async safety improvements"
```

### Before PR
```bash
# Clean up all async warnings
python3 scripts/fix_async_warnings.py --dry-run
python3 scripts/fix_async_warnings.py
flutter analyze
git add -A
git commit -m "fix: resolve async warnings before PR"
```

### Periodic Cleanup
```bash
# Weekly/monthly cleanup
python3 scripts/fix_async_warnings.py
```

## Safety Guarantees

✅ **Safe:**
- Adds safety checks (reduces crashes)
- Marks fire-and-forget operations explicitly
- Only modifies async patterns
- Preserves code functionality

⚠️ **Limitations:**
- May add unnecessary checks in some cases
- Doesn't understand complex business logic
- May need manual adjustment for edge cases
- Review diffs before committing

## Best Practices

1. **Always dry-run first**
   ```bash
   python3 scripts/fix_async_warnings.py --dry-run
   ```

2. **Review changes**
   ```bash
   git diff
   ```

3. **Test manually**
   ```bash
   flutter run
   # Test affected features
   ```

4. **Commit separately**
   ```bash
   git add -A
   git commit -m "fix: async safety improvements"
   ```

5. **Batch by feature**
   ```bash
   # Fix home feature only
   python3 scripts/fix_async_warnings.py --file lib/features/home/...
   # Test
   # Commit
   # Next feature
   ```

## Troubleshooting

### Script Errors

**Error: flutter: command not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Error: Permission denied**
```bash
chmod +x scripts/fix_async_warnings.py
```

### False Fixes

**Unnecessary mounted checks:**
- Review and remove if context not used after
- Happens when analyzer is conservative

**Over-wrapping with unawaited():**
- Some futures should be awaited
- Review each change manually

## Integration with Claude Code

Use slash command for convenience:
```
/fix-async
```

Or run directly:
```bash
python3 scripts/fix_async_warnings.py --dry-run
```

## Statistics

From initial cleanup (2025-11-02):
- **Before**: 163 warnings
- **After manual**: 133 warnings (30 fixed)
- **Estimated script coverage**: ~80-90% of remaining warnings
- **Time saved**: ~3-4 hours vs manual fixes

## Contributing

If you find a pattern that should be fixed automatically:

1. Document the pattern
2. Add regex to `patterns` list
3. Test with `--dry-run`
4. Submit PR

## License

Internal tool for GymBro TrackLog project.

---

**Created**: 2025-11-02
**Last Updated**: 2025-11-02
**Author**: Claude Code
