#!/usr/bin/env python3
"""
Add new translations from localization_quick_wins.json to ARB files
Intelligently merges without duplicating existing keys
"""

import json
from pathlib import Path
from typing import Dict, List

def load_arb_file(filepath: str) -> Dict:
    """Load ARB file and return as dictionary"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_quick_wins() -> Dict:
    """Load quick wins localization entries"""
    with open("localization_quick_wins.json", 'r', encoding='utf-8') as f:
        return json.load(f)

def add_translations_to_arb(arb_data: Dict, entries: List[Dict], language: str) -> tuple[Dict, int]:
    """
    Add new translations to ARB data
    Returns: (updated_arb_data, count_added)
    """
    added_count = 0

    for entry in entries:
        key = entry['key']

        # Skip if key already exists
        if key in arb_data:
            continue

        # Get value for this language
        value = entry['value_en'] if language == 'en' else entry['value_it']

        # Add to ARB
        arb_data[key] = value

        # Add description metadata (optional but recommended)
        meta_key = f"@{key}"
        arb_data[meta_key] = {
            "description": f"From quick wins migration - {entry['occurrences']} occurrences",
            "context": f"Found in: {', '.join(entry['contexts'][:2])}"
        }

        added_count += 1

    return arb_data, added_count

def save_arb_file(filepath: str, arb_data: Dict):
    """Save ARB file with proper formatting"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(arb_data, f, indent=2, ensure_ascii=False)

def main():
    """Main execution"""
    print("🚀 Adding Quick Wins translations to ARB files...\n")

    # Paths
    en_arb_path = "assets/i18n/app_en.arb"
    it_arb_path = "assets/i18n/app_it.arb"

    # Load existing ARB files
    print("📂 Loading existing ARB files...")
    en_arb = load_arb_file(en_arb_path)
    it_arb = load_arb_file(it_arb_path)
    print(f"   EN: {len([k for k in en_arb.keys() if not k.startswith('@')])} keys")
    print(f"   IT: {len([k for k in it_arb.keys() if not k.startswith('@')])} keys")

    # Load quick wins
    print("\n📊 Loading quick wins localization entries...")
    quick_wins = load_quick_wins()
    entries = quick_wins['entries']
    print(f"   Found {len(entries)} entries to add")

    # Add to EN ARB
    print("\n🇬🇧 Adding translations to app_en.arb...")
    en_arb, en_added = add_translations_to_arb(en_arb, entries, 'en')
    print(f"   ✅ Added {en_added} new keys")

    # Add to IT ARB
    print("\n🇮🇹 Adding translations to app_it.arb...")
    it_arb, it_added = add_translations_to_arb(it_arb, entries, 'it')
    print(f"   ✅ Added {it_added} new keys")

    # Save updated ARB files
    print("\n💾 Saving updated ARB files...")
    save_arb_file(en_arb_path, en_arb)
    save_arb_file(it_arb_path, it_arb)
    print("   ✅ Files saved")

    # Print summary
    print("\n" + "="*60)
    print("📊 SUMMARY")
    print("="*60)
    print(f"English (app_en.arb):")
    print(f"  - Before: {len([k for k in load_arb_file(en_arb_path+'.backup').keys() if not k.startswith('@')])} keys")
    print(f"  - Added: {en_added} keys")
    print(f"  - After: {len([k for k in en_arb.keys() if not k.startswith('@')])} keys")
    print(f"\nItalian (app_it.arb):")
    print(f"  - Before: {len([k for k in load_arb_file(it_arb_path+'.backup').keys() if not k.startswith('@')])} keys")
    print(f"  - Added: {it_added} keys")
    print(f"  - After: {len([k for k in it_arb.keys() if not k.startswith('@')])} keys")
    print("="*60)

    print("\n✅ Translations added successfully!")
    print("   Next step: Run 'flutter gen-l10n' to regenerate localizations")

if __name__ == "__main__":
    main()
