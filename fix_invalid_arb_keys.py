#!/usr/bin/env python3
"""
Fix all invalid ARB keys to make them valid Dart identifiers
"""

import json
import re
from typing import Dict, Tuple, List

def is_valid_dart_identifier(key: str) -> bool:
    """Check if key is a valid Dart method name"""
    # Must start with letter or _
    if not re.match(r'^[a-zA-Z_]', key):
        return False

    # Must contain only alphanumeric and underscore
    if not re.match(r'^[a-zA-Z0-9_]+$', key):
        return False

    return True

def fix_key(key: str) -> str:
    """Convert invalid key to valid Dart identifier"""
    # Remove @ if present (metadata keys)
    is_metadata = key.startswith('@')
    if is_metadata:
        key = key[1:]

    original_key = key

    # Replace accented characters
    replacements = {
        'à': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
        'À': 'A', 'È': 'E', 'É': 'E', 'Ì': 'I', 'Ò': 'O', 'Ù': 'U',
    }
    for old, new in replacements.items():
        key = key.replace(old, new)

    # If starts with number, prepend with letter
    if re.match(r'^\d', key):
        # Try to make it semantic
        if 'rm' in key.lower():
            key = 'rm' + key[1:].capitalize()
        else:
            key = 'n' + key  # prepend 'n' for number

    # Remove any non-alphanumeric (except underscore)
    key = re.sub(r'[^a-zA-Z0-9_]', '', key)

    # If still starts with number, prepend 'key'
    if re.match(r'^\d', key):
        key = 'key' + key

    # Add back @ if metadata
    if is_metadata:
        key = '@' + key

    return key

def fix_arb_file(filepath: str) -> Tuple[Dict, int]:
    """Fix all invalid keys in ARB file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        arb_data = json.load(f)

    fixed_arb = {}
    fix_count = 0
    fixes = []

    for key, value in arb_data.items():
        # Check if key needs fixing
        if key.startswith('@'):
            # Metadata key
            base_key = key[1:]
            if not is_valid_dart_identifier(base_key):
                new_key = fix_key(key)
                fixed_arb[new_key] = value
                fix_count += 1
                fixes.append(f"  {key} → {new_key}")
            else:
                fixed_arb[key] = value
        else:
            # Regular key
            if not is_valid_dart_identifier(key):
                new_key = fix_key(key)
                fixed_arb[new_key] = value
                fix_count += 1
                fixes.append(f"  {key} → {new_key}")
            else:
                fixed_arb[key] = value

    return fixed_arb, fix_count, fixes

def main():
    """Main execution"""
    print("🔧 Fixing invalid ARB keys...\n")

    files = [
        "assets/i18n/app_en.arb",
        "assets/i18n/app_it.arb"
    ]

    total_fixes = 0

    for filepath in files:
        print(f"📂 Processing {filepath}...")
        fixed_arb, fix_count, fixes = fix_arb_file(filepath)

        if fix_count > 0:
            print(f"   ⚠️ Found {fix_count} invalid keys:")
            for fix in fixes[:10]:  # Show first 10
                print(fix)
            if len(fixes) > 10:
                print(f"   ... and {len(fixes) - 10} more")

            # Save fixed version
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(fixed_arb, f, indent=2, ensure_ascii=False)

            print(f"   ✅ Fixed and saved")
            total_fixes += fix_count
        else:
            print(f"   ✅ No invalid keys found")

    print(f"\n{'='*60}")
    print(f"✅ Total fixes: {total_fixes}")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
