#!/usr/bin/env python3
"""
Script to add weight suggestion translations to ARB files.

Reads from assets/i18n/weight_suggestion_keys_TO_ADD.json
Appends to app_en.arb and app_it.arb
"""

import json
from pathlib import Path

def add_translations():
    project_root = Path(__file__).parent.parent

    # Paths
    keys_file = project_root / 'assets' / 'i18n' / 'weight_suggestion_keys_TO_ADD.json'
    en_arb = project_root / 'assets' / 'i18n' / 'app_en.arb'
    it_arb = project_root / 'assets' / 'i18n' / 'app_it.arb'

    # Load translation keys
    with open(keys_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    english_keys = data['ENGLISH_KEYS']
    italian_keys = data['ITALIAN_KEYS']

    # Load existing ARB files
    with open(en_arb, 'r', encoding='utf-8') as f:
        en_content = f.read()

    with open(it_arb, 'r', encoding='utf-8') as f:
        it_content = f.read()

    # Parse existing JSON (remove trailing })
    en_json = json.loads(en_content)
    it_json = json.loads(it_content)

    # Add English keys
    for key, value in english_keys.items():
        if key not in en_json:
            en_json[key] = value

    # Add Italian keys (same keys, different values, no @ annotations)
    for key, value in italian_keys.items():
        if key not in it_json:
            it_json[key] = value

    # Write back with pretty formatting
    with open(en_arb, 'w', encoding='utf-8') as f:
        json.dump(en_json, f, indent=2, ensure_ascii=False)

    with open(it_arb, 'w', encoding='utf-8') as f:
        json.dump(it_json, f, indent=2, ensure_ascii=False)

    print(f"✅ Added translations to ARB files:")
    print(f"   - {en_arb}")
    print(f"   - {it_arb}")
    print(f"\n📝 Next step: Run 'flutter gen-l10n' to regenerate localization files")

    # Count added keys
    en_added = sum(1 for k in english_keys if not k.startswith('@'))
    print(f"\n📊 Stats: {en_added} new translation keys added")

if __name__ == '__main__':
    add_translations()
