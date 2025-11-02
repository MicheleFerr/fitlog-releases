#!/usr/bin/env python3
"""
Fix use_build_context_synchronously warnings by adding mounted checks.
"""

import re
import subprocess
import sys
from pathlib import Path

def get_build_context_warnings():
    """Get all use_build_context_synchronously warnings from flutter analyze."""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True
    )

    warnings = []
    for line in result.stdout.split('\n') + result.stderr.split('\n'):
        if 'use_build_context_synchronously' in line:
            # Skip warnings with "unrelated mounted check" - those need manual review
            if 'unrelated' in line:
                continue

            # Extract file:line:column
            match = re.search(r'(lib/[^:]+\.dart):(\d+):(\d+)', line)
            if match:
                warnings.append({
                    'file': match.group(1),
                    'line': int(match.group(2)),
                    'column': int(match.group(3))
                })

    return warnings

def find_async_gap_line(file_path, context_line):
    """Find the nearest await statement before the context usage."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Search backwards from context_line to find the await
    for i in range(context_line - 1, max(0, context_line - 50), -1):
        line = lines[i]
        if 'await ' in line and not line.strip().startswith('//'):
            return i + 1  # 1-indexed

    return None

def has_mounted_check_after_await(file_path, await_line, context_line):
    """Check if there's already a mounted check between await and context usage."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    for i in range(await_line, context_line):
        line = lines[i].strip()
        if 'if (!mounted)' in line or 'if (mounted)' in line:
            return True

    return False

def add_mounted_check(file_path, await_line):
    """Add 'if (!mounted) return;' after the await line."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    if await_line >= len(lines):
        return False

    # Find the indentation of the await line
    await_line_content = lines[await_line - 1]
    indent_match = re.match(r'^(\s*)', await_line_content)
    indent = indent_match.group(1) if indent_match else '    '

    # Check if next line is already a blank line or comment
    insert_index = await_line

    # Skip blank lines immediately after await
    while insert_index < len(lines) and lines[insert_index].strip() == '':
        insert_index += 1

    # Insert mounted check
    mounted_check = f"{indent}if (!mounted) return;\n"

    # Add blank line before for readability if not already there
    if insert_index > 0 and lines[insert_index - 1].strip() != '':
        lines.insert(insert_index, '\n')
        insert_index += 1

    lines.insert(insert_index, mounted_check)

    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True

def main():
    print("🔍 Finding use_build_context_synchronously warnings...")
    warnings = get_build_context_warnings()

    if not warnings:
        print("✅ No fixable use_build_context_synchronously warnings found!")
        return

    print(f"Found {len(warnings)} warnings (excluding 'unrelated mounted check')")

    # Group by file and await line to avoid duplicates
    processed = set()
    fixed_count = 0
    skipped_count = 0

    for warning in warnings:
        file_path = warning['file']
        context_line = warning['line']

        # Find the await statement
        await_line = find_async_gap_line(file_path, context_line)

        if not await_line:
            print(f"⚠️  {file_path}:{context_line} - Could not find async gap")
            skipped_count += 1
            continue

        # Create unique key to avoid processing same await multiple times
        key = f"{file_path}:{await_line}"
        if key in processed:
            continue
        processed.add(key)

        # Check if mounted check already exists
        if has_mounted_check_after_await(file_path, await_line, context_line):
            print(f"✓ {file_path}:{await_line} - Already has mounted check")
            continue

        # Add mounted check
        if add_mounted_check(file_path, await_line):
            print(f"✅ {file_path}:{await_line} - Added mounted check")
            fixed_count += 1
        else:
            print(f"⚠️  {file_path}:{await_line} - Could not add mounted check")
            skipped_count += 1

    print(f"\n✅ Done! Fixed {fixed_count} instances, skipped {skipped_count}")
    print(f"\n💡 Run 'flutter analyze' to verify fixes")

if __name__ == '__main__':
    main()
