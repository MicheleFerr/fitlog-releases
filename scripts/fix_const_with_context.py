#!/usr/bin/env python3
"""
Fix invalid const by finding widgets marked as const that use runtime values (context, Theme).
"""

import re
from pathlib import Path
from typing import List, Tuple

PROJECT_ROOT = Path(__file__).parent.parent


def find_files_with_const_issues():
    """Find all Dart files that might have const + context issues."""
    # Get all dart files in lib/
    dart_files = list((PROJECT_ROOT / 'lib').rglob('*.dart'))

    files_to_fix = []

    for dart_file in dart_files:
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()

                # Check if file has both 'const' and 'context.' or 'Theme.of(context)'
                if 'const ' in content and ('context.' in content or 'Theme.of(context)' in content):
                    files_to_fix.append(dart_file)
        except Exception as e:
            print(f"⚠️  Error reading {dart_file}: {e}")

    return files_to_fix


def fix_const_in_file(file_path: Path) -> int:
    """Fix const widgets that use context/Theme in a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    fixed_count = 0
    modified = False

    # Pattern: find lines with 'const Icon(' or 'const Text(' or 'const Container('
    # Then check next few lines for context. or Theme.of(context)

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if line has const widget
        match = re.search(r'\bconst\s+(Icon|Text|Container|SizedBox|Padding|Center|Column|Row|Stack)\s*\(', line)

        if match:
            # Look ahead in next 15 lines for context. or Theme.of
            uses_runtime_value = False
            look_ahead = min(15, len(lines) - i)

            for j in range(look_ahead):
                ahead_line = lines[i + j]
                if 'context.' in ahead_line or 'Theme.of(context)' in ahead_line:
                    uses_runtime_value = True
                    break

            if uses_runtime_value:
                # Remove 'const ' from this line
                new_line = re.sub(r'\bconst\s+', '', line, count=1)
                if new_line != line:
                    lines[i] = new_line
                    fixed_count += 1
                    modified = True
                    print(f"  ➖ Fixed line {i + 1}: removed const from {match.group(1)}")

        i += 1

    # Write back if modified
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)

    return fixed_count


def main():
    """Main function."""
    print("🚀 Auto-fixing const widgets with runtime values...\n")

    # Find files
    print("🔍 Finding files with const + context/Theme...")
    files = find_files_with_const_issues()
    print(f"✅ Found {len(files)} files to check\n")

    if not files:
        print("✅ No files need fixing!")
        return 0

    # Fix each file
    total_fixed = 0
    files_modified = 0

    for file_path in files:
        fixed = fix_const_in_file(file_path)
        if fixed > 0:
            total_fixed += fixed
            files_modified += 1
            rel_path = file_path.relative_to(PROJECT_ROOT)
            print(f"💾 Fixed {fixed} const issues in {rel_path}\n")

    print(f"✨ Done! Fixed {total_fixed} const issues in {files_modified} files")
    print("📋 Next: Run 'flutter analyze' to verify fixes")

    return 0


if __name__ == '__main__':
    exit(main())
