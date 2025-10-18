#!/usr/bin/env python3
import json
import sys

def merge_translations():
    # Read existing Italian translations
    with open('assets/i18n/app_it.arb', 'r', encoding='utf-8') as f:
        existing = json.load(f)

    # Read new workout translations
    with open('workout_translations_it.json', 'r', encoding='utf-8') as f:
        new_translations = json.load(f)

    # Count before
    before_count = len([k for k in existing.keys() if not k.startswith('@')])

    # Merge new translations (skip category headers that start with _)
    added = 0
    updated = 0
    for key, value in new_translations.items():
        if not key.startswith('_'):  # Skip category headers
            if key in existing:
                if existing[key] != value:
                    existing[key] = value
                    updated += 1
                    print(f"Updated: {key}")
            else:
                existing[key] = value
                added += 1
                print(f"Added: {key}")

    # Save merged translations
    with open('assets/i18n/app_it.arb', 'w', encoding='utf-8') as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)

    # Count after
    after_count = len([k for k in existing.keys() if not k.startswith('@')])

    print(f"\n✅ Merge completato!")
    print(f"Prima: {before_count} traduzioni")
    print(f"Dopo: {after_count} traduzioni")
    print(f"Aggiunte: {added} nuove traduzioni")
    print(f"Aggiornate: {updated} traduzioni esistenti")
    print(f"Totale modifiche: {added + updated}")

if __name__ == "__main__":
    merge_translations()