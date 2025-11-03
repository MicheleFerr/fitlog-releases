#!/usr/bin/env python3
"""
Interactive Async Warnings Checker - Prompts for each fix

Usage:
    python3 scripts/fix_async_warnings.py              # Check all warnings interactively
    python3 scripts/fix_async_warnings.py --file path  # Check specific file only
    python3 scripts/fix_async_warnings.py --resume     # Resume from last session
"""

import re
import subprocess
import sys
import json
from pathlib import Path
from typing import List, Tuple, Optional

# Progress tracking file
PROGRESS_FILE = Path('.async_warnings_progress.json')

def get_build_context_warnings() -> List[Tuple[str, int]]:
    """Get list of files with use_build_context_synchronously warnings"""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True
    )

    warnings = []
    for line in result.stdout.split('\n'):
        if 'use_build_context_synchronously' in line:
            parts = line.split('•')
            if len(parts) >= 3:
                location = parts[-2].strip()
                if ':' in location:
                    filepath, line_num = location.rsplit(':', 2)[:2]
                    warnings.append((filepath.strip(), int(line_num)))

    return warnings

def get_unawaited_warnings() -> List[Tuple[str, int]]:
    """Get list of files with unawaited_futures warnings"""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True
    )

    warnings = []
    for line in result.stdout.split('\n'):
        if 'unawaited_futures' in line:
            parts = line.split('•')
            if len(parts) >= 3:
                location = parts[-2].strip()
                if ':' in location:
                    filepath, line_num = location.rsplit(':', 2)[:2]
                    warnings.append((filepath.strip(), int(line_num)))

    return warnings

def show_code_context(filepath: str, line_num: int, context_lines: int = 5) -> None:
    """Show code context around the warning line"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        start = max(0, line_num - context_lines - 1)
        end = min(len(lines), line_num + context_lines)

        print("\n📄 Current code:")
        for i in range(start, end):
            prefix = ">>>" if i == line_num - 1 else "   "
            print(f"{prefix} {i+1:4d}: {lines[i]}", end='')
        print()
    except Exception as e:
        print(f"❌ Error reading file: {e}")

def preview_build_context_fix(filepath: str, line_num: int) -> Optional[str]:
    """Preview the fix for a BuildContext warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return None

        # Look backwards for await statement
        for i in range(line_num - 1, max(0, line_num - 10), -1):
            if 'await' in lines[i]:
                indent = len(lines[i]) - len(lines[i].lstrip())

                # Check if already has mounted check
                if i + 1 < len(lines) and 'mounted' in lines[i + 1]:
                    return None

                mounted_check = ' ' * indent + 'if (!mounted) return;\n\n'

                # Show preview
                preview = []
                preview.append(f"   {i+1:4d}: {lines[i]}")
                preview.append(f">>> NEW : {mounted_check}")
                if i + 1 < len(lines):
                    preview.append(f"   {i+2:4d}: {lines[i + 1]}")

                return ''.join(preview)

        return None
    except Exception as e:
        return f"❌ Error: {e}"

def preview_unawaited_fix(filepath: str, line_num: int) -> Optional[str]:
    """Preview the fix for an unawaited warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return None

        target_line = lines[line_num - 1]

        patterns = [
            (r'(\s+)(ref\.read\([^)]+\)\.notifier\.\w+\([^)]*\))', r'\1unawaited(\2)'),
            (r'(\s+)(Navigator\.of\(context\)\.[^;]+)', r'\1unawaited(\2)'),
            (r'(\s+)(HapticFeedback\.\w+\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.forward\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.reverse\(\))', r'\1unawaited(\2)'),
        ]

        new_line = None
        for pattern, replacement in patterns:
            if re.search(pattern, target_line):
                new_line = re.sub(pattern, replacement, target_line)
                break

        if not new_line:
            return None

        has_async_import = any('import \'dart:async\'' in line for line in lines)

        preview = []
        if not has_async_import:
            preview.append(">>> NEW : import 'dart:async';\n")
        preview.append(f"   OLD : {target_line}")
        preview.append(f">>> NEW : {new_line}")

        return ''.join(preview)
    except Exception as e:
        return f"❌ Error: {e}"

def apply_build_context_fix(filepath: str, line_num: int) -> bool:
    """Apply the fix for a BuildContext warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        for i in range(line_num - 1, max(0, line_num - 10), -1):
            if 'await' in lines[i]:
                indent = len(lines[i]) - len(lines[i].lstrip())

                if i + 1 < len(lines) and 'mounted' in lines[i + 1]:
                    return False

                mounted_check = ' ' * indent + 'if (!mounted) return;\n\n'
                lines.insert(i + 1, mounted_check)

                with open(filepath, 'w') as f:
                    f.writelines(lines)

                return True

        return False
    except Exception as e:
        print(f"❌ Error applying fix: {e}")
        return False

def apply_unawaited_fix(filepath: str, line_num: int) -> bool:
    """Apply the fix for an unawaited warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        target_line = lines[line_num - 1]

        patterns = [
            (r'(\s+)(ref\.read\([^)]+\)\.notifier\.\w+\([^)]*\))', r'\1unawaited(\2)'),
            (r'(\s+)(Navigator\.of\(context\)\.[^;]+)', r'\1unawaited(\2)'),
            (r'(\s+)(HapticFeedback\.\w+\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.forward\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.reverse\(\))', r'\1unawaited(\2)'),
        ]

        new_line = None
        for pattern, replacement in patterns:
            if re.search(pattern, target_line):
                new_line = re.sub(pattern, replacement, target_line)
                break

        if not new_line:
            return False

        has_async_import = any('import \'dart:async\'' in line for line in lines)

        if not has_async_import:
            insert_pos = 0
            for i, line in enumerate(lines):
                if 'library;' in line:
                    insert_pos = i + 1
                    break
                if line.startswith('import '):
                    insert_pos = i
                    break

            lines.insert(insert_pos, "\nimport 'dart:async';\n")
            line_num += 2

        lines[line_num - 1] = new_line

        with open(filepath, 'w') as f:
            f.writelines(lines)

        return True
    except Exception as e:
        print(f"❌ Error applying fix: {e}")
        return False

def explain_build_context_warning():
    """Explain BuildContext async safety"""
    print("""
📚 BuildContext Async Safety Explanation:

⚠️  PROBLEM:
   After an 'await' statement, your widget might be disposed (unmounted).
   If you use 'context' after the await without checking, it can crash.

✅  SOLUTION:
   Add 'if (!mounted) return;' after await statements.
   This checks if the widget is still alive before using context.

💡  EXAMPLE:
   BAD:
      await fetchData();
      Navigator.of(context).push(...);  // ❌ context might be invalid

   GOOD:
      await fetchData();
      if (!mounted) return;  // ✅ Safety check
      Navigator.of(context).push(...);
""")

def explain_unawaited_warning():
    """Explain unawaited futures"""
    print("""
📚 Unawaited Futures Explanation:

⚠️  PROBLEM:
   You're calling an async function but not awaiting it.
   Flutter analyzer warns because this might be unintentional.

✅  SOLUTION:
   Wrap with 'unawaited()' to explicitly mark as "fire-and-forget".
   This tells the analyzer "yes, I know, I don't need to await this".

💡  EXAMPLE:
   BAD:
      ref.read(provider.notifier).refresh();  // ❌ Warning: not awaited

   GOOD:
      unawaited(ref.read(provider.notifier).refresh());  // ✅ Explicit
""")

def save_progress(current_index: int, warning_type: str):
    """Save progress to resume later"""
    progress = {
        'index': current_index,
        'type': warning_type
    }
    with open(PROGRESS_FILE, 'w') as f:
        json.dump(progress, f)

def load_progress() -> Optional[dict]:
    """Load saved progress"""
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE, 'r') as f:
            return json.load(f)
    return None

def clear_progress():
    """Clear saved progress"""
    if PROGRESS_FILE.exists():
        PROGRESS_FILE.unlink()

def interactive_check_warnings(warnings: List[Tuple[str, int, str]]):
    """Interactively check and fix warnings"""
    total = len(warnings)
    fixed = 0
    skipped = 0
    start_index = 0

    # Check for resume
    if '--resume' in sys.argv:
        progress = load_progress()
        if progress:
            start_index = progress.get('index', 0)
            print(f"📂 Resuming from warning {start_index + 1}/{total}")

    for idx in range(start_index, total):
        filepath, line_num, warning_type = warnings[idx]

        print("\n" + "="*70)
        print(f"[{idx + 1}/{total}] {warning_type}")
        print(f"📄 {filepath}:{line_num}")
        print("="*70)

        show_code_context(filepath, line_num)

        while True:
            choice = input("\n[A]ccept [S]kip [P]review [E]xplain [Q]uit? ").strip().lower()

            if choice == 'q':
                print(f"\n💾 Saving progress... (use --resume to continue)")
                save_progress(idx, warning_type)
                print(f"\n✨ Session summary:")
                print(f"   ✅ Fixed: {fixed}")
                print(f"   ⏭️  Skipped: {skipped}")
                print(f"   📊 Progress: {idx}/{total} ({idx*100//total}%)")
                return

            elif choice == 'e':
                if warning_type == 'use_build_context_synchronously':
                    explain_build_context_warning()
                else:
                    explain_unawaited_warning()
                continue

            elif choice == 'p':
                print("\n🔍 Suggested fix:")
                if warning_type == 'use_build_context_synchronously':
                    preview = preview_build_context_fix(filepath, line_num)
                else:
                    preview = preview_unawaited_fix(filepath, line_num)

                if preview:
                    print(preview)
                else:
                    print("❌ No fix available for this warning")
                continue

            elif choice == 's':
                print("⏭️  Skipped")
                skipped += 1
                break

            elif choice == 'a':
                print("🔧 Applying fix...")
                success = False
                if warning_type == 'use_build_context_synchronously':
                    success = apply_build_context_fix(filepath, line_num)
                else:
                    success = apply_unawaited_fix(filepath, line_num)

                if success:
                    print("✅ Fixed!")
                    fixed += 1
                else:
                    print("❌ Could not apply fix")
                break

            else:
                print("❌ Invalid choice. Use: a/s/p/e/q")

    # All done
    clear_progress()
    print("\n" + "="*70)
    print("🎉 All warnings checked!")
    print(f"   ✅ Fixed: {fixed}")
    print(f"   ⏭️  Skipped: {skipped}")
    print(f"   📊 Total: {total}")
    print("\n💡 Run 'flutter analyze' to verify")

def main():
    specific_file = None

    if '--file' in sys.argv:
        idx = sys.argv.index('--file')
        if idx + 1 < len(sys.argv):
            specific_file = sys.argv[idx + 1]

    print("🔍 Scanning for async warnings...")

    # Get warnings
    context_warnings = get_build_context_warnings()
    unawaited_warnings = get_unawaited_warnings()

    if specific_file:
        context_warnings = [(f, l) for f, l in context_warnings if f == specific_file]
        unawaited_warnings = [(f, l) for f, l in unawaited_warnings if f == specific_file]

    # Combine into single list with type
    all_warnings = []
    all_warnings.extend([(f, l, 'use_build_context_synchronously') for f, l in context_warnings])
    all_warnings.extend([(f, l, 'unawaited_futures') for f, l in unawaited_warnings])

    total = len(all_warnings)
    print(f"📊 Found {len(context_warnings)} BuildContext + {len(unawaited_warnings)} unawaited warnings")
    print(f"   Total: {total} warnings to check")

    if total == 0:
        print("\n✅ No warnings found! Clean codebase!")
        return

    print("\n💡 Interactive mode:")
    print("   [A]ccept - Apply the suggested fix")
    print("   [S]kip - Skip this warning")
    print("   [P]review - Show suggested fix before applying")
    print("   [E]xplain - Learn why this warning exists")
    print("   [Q]uit - Save progress and exit (use --resume to continue)")

    input("\n Press Enter to start... ")

    interactive_check_warnings(all_warnings)

if __name__ == '__main__':
    main()
