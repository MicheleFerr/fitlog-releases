#!/usr/bin/env python3
"""
Generate Quick Wins from EXACT strings in presentation layer only
"""

import json
import re
from collections import Counter
from typing import Dict, List

def is_presentation_layer(file_path: str) -> bool:
    """Check if file is in presentation layer (Dart files in lib/ only)"""
    # Must be Dart file in lib/
    if not file_path.startswith('lib/') or not file_path.endswith('.dart'):
        return False

    # Skip data/domain layer
    skip_patterns = [
        "/data/repositories/",
        "/data/services/",
        "/domain/services/",
        "/domain/usecases/",
        "/domain/utils/",
    ]
    return not any(pattern in file_path for pattern in skip_patterns)

def is_real_ui_string(string_value: str) -> bool:
    """Check if string is real UI text (not debug/template/code)"""
    # Exclude patterns
    exclude_patterns = [
        r'\$\{',  # Template variables
        r'^\$[a-zA-Z]',  # Single variables
        r'Stack trace:',
        r'Error: \$',
        r'^\[.*\]$',  # JSON arrays
        r'^\{.*\}$',  # JSON objects
        r'^https?://',  # URLs
        r'^\d{4}-\d{2}-\d{2}',  # Dates
        r'^[A-Z_]+$',  # Constants (all caps)
        r'^\s*$',  # Empty/whitespace
        r'localizationslocaleofcontext',  # Code fragments
        r'^@[a-zA-Z]+',  # Annotations
    ]

    for pattern in exclude_patterns:
        if re.search(pattern, string_value):
            return False

    # Must have at least one letter
    if not re.search(r'[a-zA-Z]', string_value):
        return False

    # Reasonable length (5-200 chars)
    if len(string_value) < 5 or len(string_value) > 200:
        return False

    return True

def detect_language(string_value: str) -> str:
    """Detect language of string"""
    italian_words = ['è', 'à', 'ù', 'ì', 'ò', 'del', 'della', 'nel', 'nella',
                     'il', 'la', 'i', 'gli', 'le', 'un', 'una', 'che', 'per',
                     'con', 'non', 'dei', 'delle', 'negli', 'nelle']

    # Check for Italian accented characters
    if any(char in string_value for char in ['è', 'à', 'ù', 'ì', 'ò', 'É', 'À']):
        return 'IT'

    # Check for Italian words
    words = string_value.lower().split()
    if any(word in italian_words for word in words):
        return 'IT'

    # Default to English if has ASCII letters
    if re.search(r'[a-zA-Z]', string_value):
        return 'EN'

    return 'unknown'

def generate_localization_key(string_value: str, language: str) -> str:
    """Generate camelCase localization key"""
    # Remove special characters and split into words
    clean = re.sub(r'[^\w\s]', ' ', string_value)
    words = clean.split()

    if not words:
        return 'unknownKey'

    # camelCase
    key = words[0].lower()
    for word in words[1:]:
        key += word.capitalize()

    # Ensure valid Dart identifier
    if not re.match(r'^[a-zA-Z_]', key):
        key = 'key' + key

    key = re.sub(r'[^a-zA-Z0-9_]', '', key)

    # Truncate if too long
    if len(key) > 40:
        key = key[:40]

    return key

def main():
    print("🚀 Generating Presentation Layer Quick Wins\\n")

    # Load audit
    print("📂 Loading audit data...")
    with open('hardcoded_strings_merged.json', 'r', encoding='utf-8') as f:
        audit = json.load(f)
    print(f"   ✅ Loaded {len(audit)} total strings")

    # Filter to presentation layer only
    print("\\n🎯 Filtering to presentation layer...")
    presentation_strings = [
        entry for entry in audit
        if is_presentation_layer(entry['file_path'])
        and is_real_ui_string(entry['string_value'])
    ]
    print(f"   ✅ {len(presentation_strings)} presentation layer UI strings")

    # Count exact string occurrences
    print("\\n📊 Counting exact string occurrences...")
    string_data = {}
    for entry in presentation_strings:
        string_val = entry['string_value']

        if string_val not in string_data:
            string_data[string_val] = {
                'count': 0,
                'files': set(),
                'contexts': []
            }

        string_data[string_val]['count'] += 1
        string_data[string_val]['files'].add(entry['file_path'])
        if len(string_data[string_val]['contexts']) < 3:
            string_data[string_val]['contexts'].append(entry.get('context', ''))

    # Sort by count
    sorted_strings = sorted(string_data.items(), key=lambda x: x[1]['count'], reverse=True)

    print(f"   ✅ Found {len(sorted_strings)} unique strings")
    print(f"\\nTop 10 most common:")
    for string, data in sorted_strings[:10]:
        display = string[:50] + '...' if len(string) > 50 else string
        print(f"   {data['count']:3d}x: '{display}'")

    # Generate entries
    print("\\n🔑 Generating localization keys...")
    entries = []
    keys_used = set()

    for string_val, data in sorted_strings[:300]:  # Top 300
        # Detect language
        language = detect_language(string_val)

        # Generate key
        base_key = generate_localization_key(string_val, language)

        # Ensure unique key
        key = base_key
        counter = 2
        while key in keys_used:
            key = f"{base_key}{counter}"
            counter += 1

        keys_used.add(key)

        # Create entry
        entry = {
            'key': key,
            'value_en': string_val if language == 'EN' else string_val,  # Keep original
            'value_it': string_val if language == 'IT' else string_val,  # Keep original
            'occurrences': data['count'],
            'files': list(data['files'])[:5],  # Max 5 file examples
            'contexts': data['contexts'],
            'detected_language': language
        }
        entries.append(entry)

    # Save
    output = {
        'generated_at': '2025-11-08',
        'total_entries': len(entries),
        'total_occurrences': sum(e['occurrences'] for e in entries),
        'entries': entries
    }

    with open('localization_presentation_quick_wins.json', 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\\n✅ Generated {len(entries)} quick win entries")
    print(f"   Total occurrences: {output['total_occurrences']}")
    print(f"   Saved to: localization_presentation_quick_wins.json")

    # Statistics
    by_language = Counter([e['detected_language'] for e in entries])
    print(f"\\n📊 Language distribution:")
    for lang, count in by_language.most_common():
        print(f"   {lang}: {count} entries")

if __name__ == "__main__":
    main()
