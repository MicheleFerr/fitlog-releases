#!/usr/bin/env python3
"""
Script to replace print() with debugPrint() in Flutter/Dart files
Automatically adds kDebugMode check and imports
"""

import os
import re
from pathlib import Path

def has_foundation_import(content: str) -> bool:
    """Check if file already imports flutter/foundation.dart"""
    return "import 'package:flutter/foundation.dart'" in content or \
           'import "package:flutter/foundation.dart"' in content

def add_foundation_import(content: str) -> str:
    """Add foundation import after other imports"""
    lines = content.split('\n')

    # Find last import line
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith('import '):
            last_import_idx = i

    if last_import_idx >= 0:
        # Insert after last import
        lines.insert(last_import_idx + 1, "import 'package:flutter/foundation.dart';")
    else:
        # No imports found, add at top
        lines.insert(0, "import 'package:flutter/foundation.dart';")

    return '\n'.join(lines)

def replace_print_statements(content: str) -> tuple[str, int]:
    """Replace print() with debugPrint() wrapped in kDebugMode"""

    replacements = 0
    lines = content.split('\n')
    new_lines = []
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Skip if already has kDebugMode check above
        if i > 0 and 'kDebugMode' in lines[i-1]:
            new_lines.append(line)
            i += 1
            continue

        # Skip comments and strings
        if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
            new_lines.append(line)
            i += 1
            continue

        # Check if line has print(
        if re.search(r'\bprint\s*\(', line) and not 'debugPrint' in line:
            # Get indentation
            indent = line[:len(line) - len(line.lstrip())]

            # Replace print with debugPrint
            new_line = re.sub(r'\bprint\s*\(', 'debugPrint(', line)

            # Wrap with kDebugMode check
            new_lines.append(f"{indent}if (kDebugMode) {{")
            new_lines.append(f"{indent}  {new_line.strip()}")
            new_lines.append(f"{indent}}}")

            replacements += 1
        else:
            new_lines.append(line)

        i += 1

    return '\n'.join(new_lines), replacements

def process_file(filepath: Path) -> int:
    """Process a single Dart file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if file has print statements
        if not re.search(r'\bprint\s*\(', content):
            return 0

        # Replace print statements
        new_content, replacements = replace_print_statements(content)

        if replacements > 0:
            # Add foundation import if needed
            if 'kDebugMode' in new_content and not has_foundation_import(new_content):
                new_content = add_foundation_import(new_content)

            # Write back to file
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)

            print(f"✅ {filepath.relative_to(Path.cwd())}: {replacements} replacements")
            return replacements

        return 0

    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return 0

def main():
    """Main function"""
    print("🔧 Fixing print() statements in lib/ directory...\n")

    lib_dir = Path('lib')
    if not lib_dir.exists():
        print("❌ lib/ directory not found!")
        return

    total_files = 0
    total_replacements = 0

    # Process all Dart files
    for filepath in lib_dir.rglob('*.dart'):
        replacements = process_file(filepath)
        if replacements > 0:
            total_files += 1
            total_replacements += replacements

    print(f"\n✅ Done! Fixed {total_replacements} print() statements in {total_files} files")

    # Check remaining
    remaining = 0
    for filepath in lib_dir.rglob('*.dart'):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            remaining += len(re.findall(r'\bprint\s*\(', content))

    print(f"🔍 Remaining print() statements: {remaining}")

if __name__ == '__main__':
    main()
