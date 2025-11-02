#!/usr/bin/env python3
"""
Fix unawaited_futures warnings by adding unawaited() wrapper.
"""

import re
import subprocess
import sys
from pathlib import Path

def get_unawaited_futures():
    """Get all unawaited_futures warnings from flutter analyze."""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True
    )

    warnings = []
    for line in result.stdout.split('\n') + result.stderr.split('\n'):
        if 'unawaited_futures' in line:
            # Extract file:line:column
            match = re.search(r'(lib/[^:]+\.dart):(\d+):(\d+)', line)
            if match:
                warnings.append({
                    'file': match.group(1),
                    'line': int(match.group(2)),
                    'column': int(match.group(3))
                })

    return warnings

def add_unawaited_import(file_path):
    """Add 'import 'dart:async' show unawaited;' if not present."""
    with open(file_path, 'r') as f:
        content = f.read()

    # Check if already imported
    if "import 'dart:async'" in content or 'import "dart:async"' in content:
        # Check if un awaited is already in show clause
        if 'unawaited' in content.split('library;')[0]:  # Only check imports before library
            return False  # Already has unawaited

    # Find where to insert import (after other imports, before library)
    lines = content.split('\n')
    insert_index = 0

    for i, line in enumerate(lines):
        if line.strip().startswith('import '):
            insert_index = i + 1
        elif line.strip() == 'library;':
            break

    # Insert import
    lines.insert(insert_index, "import 'dart:async' show unawaited;")

    with open(file_path, 'w') as f:
        f.write('\n'.join(lines))

    return True

def fix_unawaited_line(file_path, line_num, column):
    """Wrap expression at line with unawaited()."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    if line_num > len(lines):
        return False

    line = lines[line_num - 1]  # 0-indexed

    # Find the expression to wrap (from column to semicolon or end of statement)
    # Common patterns: HapticFeedback.*, _controller.*, ref.read(...), service.method()

    # Extract the full statement
    statement_start = line[:column - 1].rstrip()
    statement_end = line[column - 1:]

    # Find the end of the expression (usually semicolon or closing paren/brace)
    expr_match = re.match(r'([^;]+)(;?.*)', statement_end)
    if not expr_match:
        return False

    expression = expr_match.group(1).strip()
    rest = expr_match.group(2)

    # Wrap with unawaited()
    new_line = f"{statement_start}unawaited({expression}){rest}\n"
    lines[line_num - 1] = new_line

    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True

def main():
    print("🔍 Finding unawaited_futures warnings...")
    warnings = get_unawaited_futures()

    if not warnings:
        print("✅ No unawaited_futures warnings found!")
        return

    print(f"Found {len(warnings)} warnings in {len(set(w['file'] for w in warnings))} files")

    # Group by file
    by_file = {}
    for w in warnings:
        if w['file'] not in by_file:
            by_file[w['file']] = []
        by_file[w['file']].append(w)

    fixed_count = 0
    import_count = 0

    for file_path, file_warnings in by_file.items():
        print(f"\n📝 Processing {file_path}...")

        # Add import first
        if add_unawaited_import(file_path):
            import_count += 1
            print(f"  ✅ Added unawaited import")

        # Fix warnings (in reverse order to preserve line numbers)
        for warning in sorted(file_warnings, key=lambda w: w['line'], reverse=True):
            if fix_unawaited_line(file_path, warning['line'], warning['column']):
                fixed_count += 1
                print(f"  ✅ Fixed line {warning['line']}")
            else:
                print(f"  ⚠️  Could not fix line {warning['line']}")

    print(f"\n✅ Done! Fixed {fixed_count} warnings, added {import_count} imports")

if __name__ == '__main__':
    main()
