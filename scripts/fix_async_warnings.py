#!/usr/bin/env python3
"""
Fix async warnings automatically (use_build_context_synchronously + unawaited_futures)

Usage:
    python3 scripts/fix_async_warnings.py              # Fix all files
    python3 scripts/fix_async_warnings.py --dry-run    # Preview changes
    python3 scripts/fix_async_warnings.py --file path  # Fix specific file
"""

import re
import subprocess
import sys
from pathlib import Path
from typing import List, Tuple

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
            # Parse: "info • ... • path/to/file.dart:123:45 • use_build_context_synchronously"
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

def fix_build_context_warning(filepath: str, line_num: int, dry_run: bool = False) -> bool:
    """Fix a single use_build_context_synchronously warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        # Look backwards for await statement
        for i in range(line_num - 1, max(0, line_num - 10), -1):
            if 'await' in lines[i]:
                # Add mounted check after the await
                indent = len(lines[i]) - len(lines[i].lstrip())

                # Check if already has mounted check
                if i + 1 < len(lines) and 'mounted' in lines[i + 1]:
                    return False

                # Insert mounted check
                mounted_check = ' ' * indent + 'if (!mounted) return;\n\n'

                if dry_run:
                    print(f"  Would add at line {i+2}: if (!mounted) return;")
                    return True

                lines.insert(i + 1, mounted_check)

                with open(filepath, 'w') as f:
                    f.writelines(lines)

                print(f"  ✅ Added mounted check at line {i+2}")
                return True

        return False

    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False

def fix_unawaited_warning(filepath: str, line_num: int, dry_run: bool = False) -> bool:
    """Fix a single unawaited_futures warning"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        target_line = lines[line_num - 1]

        # Common patterns to wrap with unawaited()
        patterns = [
            (r'(\s+)(ref\.read\([^)]+\)\.notifier\.\w+\([^)]*\))', r'\1unawaited(\2)'),
            (r'(\s+)(Navigator\.of\(context\)\.[^;]+)', r'\1unawaited(\2)'),
            (r'(\s+)(HapticFeedback\.\w+\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.forward\(\))', r'\1unawaited(\2)'),
            (r'(\s+)(_\w+Controller\.reverse\(\))', r'\1unawaited(\2)'),
        ]

        modified = False
        new_line = target_line

        for pattern, replacement in patterns:
            if re.search(pattern, new_line):
                new_line = re.sub(pattern, replacement, new_line)
                modified = True
                break

        if not modified:
            return False

        # Check if file has dart:async import
        has_async_import = any('import \'dart:async\'' in line for line in lines)

        if dry_run:
            print(f"  Would wrap line {line_num} with unawaited()")
            if not has_async_import:
                print(f"  Would add: import 'dart:async';")
            return True

        # Add import if missing
        if not has_async_import:
            # Find library; or first import
            insert_pos = 0
            for i, line in enumerate(lines):
                if 'library;' in line:
                    insert_pos = i + 1
                    break
                if line.startswith('import '):
                    insert_pos = i
                    break

            lines.insert(insert_pos, "\nimport 'dart:async';\n")
            line_num += 2  # Adjust for inserted lines

        lines[line_num - 1] = new_line

        with open(filepath, 'w') as f:
            f.writelines(lines)

        print(f"  ✅ Wrapped with unawaited() at line {line_num}")
        return True

    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False

def main():
    dry_run = '--dry-run' in sys.argv
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

    total = len(context_warnings) + len(unawaited_warnings)
    print(f"📊 Found {len(context_warnings)} BuildContext + {len(unawaited_warnings)} unawaited warnings")

    if dry_run:
        print("\n🔍 DRY RUN MODE - No files will be modified\n")

    fixed = 0

    # Fix BuildContext warnings
    if context_warnings:
        print("\n🔧 Fixing use_build_context_synchronously warnings...")
        files_done = set()
        for filepath, line_num in context_warnings:
            if filepath not in files_done:
                print(f"\n📄 {filepath}")
                files_done.add(filepath)
            if fix_build_context_warning(filepath, line_num, dry_run):
                fixed += 1

    # Fix unawaited warnings
    if unawaited_warnings:
        print("\n🔧 Fixing unawaited_futures warnings...")
        files_done = set()
        for filepath, line_num in unawaited_warnings:
            if filepath not in files_done:
                print(f"\n📄 {filepath}")
                files_done.add(filepath)
            if fix_unawaited_warning(filepath, line_num, dry_run):
                fixed += 1

    print(f"\n✨ Summary: {fixed}/{total} warnings fixed")

    if dry_run:
        print("\n💡 Run without --dry-run to apply changes")
    else:
        print("\n✅ Done! Run 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
