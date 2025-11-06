#!/usr/bin/env python3
"""
Auto-fix invalid_constant errors by removing 'const' from affected lines.
Extracts errors from flutter analyze and removes const keyword.
"""

import re
import subprocess
from pathlib import Path
from collections import defaultdict

PROJECT_ROOT = Path(__file__).parent.parent


def extract_invalid_const_errors():
    """Extract all invalid_constant errors from flutter analyze."""
    print("🔍 Running flutter analyze to find invalid_constant errors...")
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True,
        cwd=PROJECT_ROOT
    )

    # Parse output for invalid_constant errors
    errors = []
    pattern = r'error • Invalid constant value • (lib/[^:]+):(\d+):(\d+) • invalid_constant'
    matches = re.findall(pattern, result.stdout + result.stderr)

    for file_path, line_num, col_num in matches:
        errors.append({
            'file': file_path,
            'line': int(line_num),
            'col': int(col_num)
        })

    print(f"✅ Found {len(errors)} invalid_constant errors")
    return errors


def remove_const_from_line(line, col):
    """Remove 'const' keyword from a specific line at given column position."""
    # Find 'const ' before the column position
    # Common patterns: "const Icon(", "const Text(", "const SizedBox("

    # Try to find 'const ' before the error column
    match = re.search(r'\bconst\s+', line[:col])
    if match:
        # Remove the matched 'const '
        start = match.start()
        end = match.end()
        new_line = line[:start] + line[end:]
        return new_line

    # Fallback: remove first 'const ' found in line
    new_line = re.sub(r'\bconst\s+', '', line, count=1)
    return new_line


def fix_invalid_const_errors(errors):
    """Fix all invalid_constant errors by removing const keyword."""
    # Group errors by file
    errors_by_file = defaultdict(list)
    for error in errors:
        errors_by_file[error['file']].append(error)

    fixed_count = 0
    for file_path, file_errors in errors_by_file.items():
        full_path = PROJECT_ROOT / file_path

        if not full_path.exists():
            print(f"⚠️  File not found: {file_path}")
            continue

        # Read file
        with open(full_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Sort errors by line number (descending) to avoid offset issues
        file_errors.sort(key=lambda e: e['line'], reverse=True)

        # Fix each error
        for error in file_errors:
            line_idx = error['line'] - 1  # Convert to 0-indexed
            if 0 <= line_idx < len(lines):
                original_line = lines[line_idx]
                fixed_line = remove_const_from_line(original_line, error['col'])

                if original_line != fixed_line:
                    lines[line_idx] = fixed_line
                    fixed_count += 1
                    print(f"  ➖ Fixed line {error['line']} in {file_path}")

        # Write back
        with open(full_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)

        print(f"💾 Saved {len(file_errors)} fixes to {file_path}")

    return fixed_count


def main():
    """Main function."""
    print("🚀 Auto-fixing invalid_constant errors...\n")

    # Extract errors
    errors = extract_invalid_const_errors()

    if not errors:
        print("✅ No invalid_constant errors found!")
        return 0

    print(f"\n📝 Fixing {len(errors)} invalid_constant errors...")

    # Fix errors
    fixed_count = fix_invalid_const_errors(errors)

    print(f"\n✨ Done! Removed 'const' from {fixed_count} lines")
    print("📋 Next: Run 'flutter analyze' to verify fixes")

    return 0


if __name__ == '__main__':
    exit(main())
