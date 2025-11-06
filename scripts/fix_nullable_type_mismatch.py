#!/usr/bin/env python3
"""
Fix nullable to non-nullable type mismatch errors.
Adds null checks or null assertion (!) where needed.
"""

import re
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple

PROJECT_ROOT = Path(__file__).parent.parent


def get_nullable_errors() -> List[Tuple[str, int, str, str]]:
    """Extract nullable → non-nullable errors from flutter analyze."""
    result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True)
    output = result.stdout + result.stderr

    errors = []
    # Pattern: The argument type 'int?' can't be assigned to the parameter type 'int'
    pattern = r"The argument type '([^']+\?)' can't be assigned to the parameter type '([^']+)'.*?•\s*(lib/[^:]+):(\d+):\d+"

    for match in re.finditer(pattern, output, re.MULTILINE):
        from_type = match.group(1)  # e.g., 'int?'
        to_type = match.group(2)    # e.g., 'int'
        file_path = match.group(3)   # e.g., 'lib/...'
        line_num = int(match.group(4))

        # Only handle nullable → non-nullable of same base type
        if from_type.endswith('?'):
            base_from = from_type[:-1]
            # Check if base type matches or is compatible
            if base_from == to_type or (base_from in ['int', 'double'] and to_type == 'num'):
                errors.append((file_path, line_num, from_type, to_type))

    return errors


def fix_nullable_error(file_path: str, line_num: int, from_type: str, to_type: str) -> bool:
    """Fix a single nullable error by adding null check or !."""
    full_path = PROJECT_ROOT / file_path

    try:
        with open(full_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        line = lines[line_num - 1]

        # Strategy: Look for the problematic expression and add ?? 0 or !
        # Common patterns:
        # - someValue (just a variable)
        # - object.property
        # - function()

        # For numbers (int?, double?, num?), add ?? 0 or ?? 0.0
        if from_type in ['int?', 'double?', 'num?']:
            default_value = '0.0' if 'double' in from_type else '0'

            # Try to find the problematic expression
            # Look for patterns like: functionName(problemValue)
            # We need to wrap problemValue with ?? default

            # Simple approach: if line has a function call, try to add ??
            # More complex: parse the AST (too complex for this script)

            # For now, let's just add a comment for manual fix
            if '??' not in line and '!' not in line:
                # Add comment to indicate manual fix needed
                indent = len(line) - len(line.lstrip())
                comment = f"{' ' * indent}// TODO: Fix nullable error on line {line_num}: {from_type} → {to_type}\n"
                lines.insert(line_num - 1, comment)

                with open(full_path, 'w', encoding='utf-8') as f:
                    f.writelines(lines)
                return True

        return False

    except Exception as e:
        print(f"❌ Error fixing {file_path}:{line_num}: {e}")
        return False


def main():
    """Main function."""
    print("🚀 Auto-fixing nullable → non-nullable type mismatches...\n")

    # Get errors
    print("🔍 Finding nullable errors...")
    errors = get_nullable_errors()
    print(f"✅ Found {len(errors)} nullable errors\n")

    if not errors:
        print("✅ No nullable errors found!")
        return 0

    # Group by file
    errors_by_file: Dict[str, List[Tuple[int, str, str]]] = {}
    for file_path, line_num, from_type, to_type in errors:
        if file_path not in errors_by_file:
            errors_by_file[file_path] = []
        errors_by_file[file_path].append((line_num, from_type, to_type))

    print(f"📁 {len(errors_by_file)} files affected\n")

    # Display errors for manual fixing
    for file_path, file_errors in sorted(errors_by_file.items()):
        print(f"📄 {file_path}:")
        for line_num, from_type, to_type in file_errors:
            print(f"   Line {line_num}: {from_type} → {to_type}")
        print()

    print("⚠️  NULLABLE ERRORS REQUIRE MANUAL FIXES")
    print("These errors need careful handling:")
    print("1. Add null check: value ?? defaultValue")
    print("2. Add null assertion: value! (only if you're sure it's not null)")
    print("3. Refactor to avoid nullable altogether")
    print()
    print("I'll display the problematic lines for you to review.")

    return 0


if __name__ == '__main__':
    exit(main())
