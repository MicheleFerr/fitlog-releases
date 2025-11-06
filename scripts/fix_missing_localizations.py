#!/usr/bin/env python3
"""
Auto-fix missing localization keys by extracting them from flutter analyze
and adding them to app_en.arb and app_it.arb with reasonable translations.
"""

import re
import json
import subprocess
from pathlib import Path
from typing import Dict, Set

# Paths
PROJECT_ROOT = Path(__file__).parent.parent
ARB_EN = PROJECT_ROOT / 'assets/i18n/app_en.arb'
ARB_IT = PROJECT_ROOT / 'assets/i18n/app_it.arb'

# Simple translation dictionary for common terms
TRANSLATIONS = {
    # Common terms
    'select': ('select', 'seleziona'),
    'export': ('export', 'esporta'),
    'import': ('import', 'importa'),
    'save': ('save', 'salva'),
    'cancel': ('cancel', 'annulla'),
    'delete': ('delete', 'elimina'),
    'edit': ('edit', 'modifica'),
    'add': ('add', 'aggiungi'),
    'remove': ('remove', 'rimuovi'),
    'clear': ('clear', 'pulisci'),
    'close': ('close', 'chiudi'),
    'open': ('open', 'apri'),
    'start': ('start', 'inizia'),
    'stop': ('stop', 'ferma'),
    'pause': ('pause', 'pausa'),
    'resume': ('resume', 'riprendi'),
    'continue': ('continue', 'continua'),
    'finish': ('finish', 'termina'),
    'complete': ('complete', 'completa'),
    'confirm': ('confirm', 'conferma'),
    'back': ('back', 'indietro'),
    'next': ('next', 'avanti'),
    'previous': ('previous', 'precedente'),
    'done': ('done', 'fatto'),
    'search': ('search', 'cerca'),
    'filter': ('filter', 'filtra'),
    'sort': ('sort', 'ordina'),
    'view': ('view', 'visualizza'),
    'show': ('show', 'mostra'),
    'hide': ('hide', 'nascondi'),
    'loading': ('loading', 'caricamento'),
    'error': ('error', 'errore'),
    'success': ('success', 'successo'),
    'warning': ('warning', 'avviso'),
    'info': ('info', 'informazione'),

    # Workout/Fitness terms
    'workout': ('workout', 'allenamento'),
    'exercise': ('exercise', 'esercizio'),
    'set': ('set', 'serie'),
    'rep': ('rep', 'ripetizione'),
    'weight': ('weight', 'peso'),
    'duration': ('duration', 'durata'),
    'rest': ('rest', 'riposo'),
    'timer': ('timer', 'timer'),
    'volume': ('volume', 'volume'),
    'intensity': ('intensity', 'intensità'),
    'progress': ('progress', 'progresso'),
    'history': ('history', 'cronologia'),
    'statistics': ('statistics', 'statistiche'),
    'analytics': ('analytics', 'analisi'),
    'performance': ('performance', 'prestazione'),
    'comparison': ('comparison', 'confronto'),
    'improvement': ('improvement', 'miglioramento'),
    'decline': ('decline', 'declino'),
    'similar': ('similar', 'simile'),
    'record': ('record', 'record'),
    'personal': ('personal', 'personale'),
    'achievement': ('achievement', 'risultato'),
    'template': ('template', 'modello'),
    'routine': ('routine', 'routine'),
    'schedule': ('schedule', 'programma'),
    'profile': ('profile', 'profilo'),
    'buddy': ('buddy', 'compagno'),
    'partner': ('partner', 'partner'),
    'matching': ('matching', 'accoppiamento'),
    'availability': ('availability', 'disponibilità'),
    'format': ('format', 'formato'),
    'data': ('data', 'dati'),
    'type': ('type', 'tipo'),
    'total': ('total', 'totale'),
    'overall': ('overall', 'complessivo'),
    'detected': ('detected', 'rilevato'),
    'description': ('description', 'descrizione'),
    'demo': ('demo', 'demo'),
    'development': ('development', 'sviluppo'),
    'mode': ('mode', 'modalità'),
    'seed': ('seed', 'inizializza'),
    'copy': ('copied', 'copiato'),
    'try': ('try', 'prova'),
    'again': ('again', 'di nuovo'),
    'oops': ('oops', 'ops'),
    'looking': ('looking', 'cercando'),
    'need': ('need', 'necessario'),
    'more': ('more', 'più'),
    'no': ('no', 'nessun'),
    'new': ('new', 'nuovo'),
    'find': ('find', 'trova'),
    'compared': ('compared', 'confrontato'),
    'to': ('to', 'a'),
    'last': ('last', 'ultimo'),
    'searching': ('searching', 'ricerca'),
    'for': ('for', 'per'),
    'matches': ('matches', 'corrispondenze'),
    'its': ('it\'s', 'è'),
    'match': ('match', 'abbinamento'),
    'improved': ('improved', 'migliorato'),
    'declined': ('declined', 'peggiorato'),
    'assessment': ('assessment', 'valutazione'),
    'lifted': ('lifted', 'sollevato'),
    'yet': ('yet', 'ancora'),
    'city': ('city', 'città'),
    'picker': ('picker', 'selettore'),
    'ice': ('ice', 'rompighiaccio'),
    'breaker': ('breaker', ''),
    'breakers': ('breakers', 'rompighiaccio'),
}


def camel_to_words(camel_case: str) -> str:
    """Convert camelCase to separate words."""
    # Insert space before capital letters
    result = re.sub('([A-Z])', r' \1', camel_case)
    return result.strip().lower()


def translate_key(key: str) -> tuple[str, str]:
    """Generate English and Italian translations for a camelCase key."""
    words = camel_to_words(key).split()

    en_parts = []
    it_parts = []

    for word in words:
        word_lower = word.lower()
        if word_lower in TRANSLATIONS:
            en, it = TRANSLATIONS[word_lower]
            en_parts.append(en)
            it_parts.append(it)
        else:
            # Fallback: use the word as-is
            en_parts.append(word)
            it_parts.append(word)  # Keep English for unknown words

    en_text = ' '.join(en_parts).capitalize()
    it_text = ' '.join(it_parts).capitalize()

    return en_text, it_text


def extract_missing_keys() -> Set[str]:
    """Extract all missing AppLocalizations keys from flutter analyze."""
    print("🔍 Running flutter analyze to find missing keys...")
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True,
        cwd=PROJECT_ROOT
    )

    # Parse output for undefined_getter errors on AppLocalizations
    pattern = r"The getter '(\w+)' isn't defined for the type 'AppLocalizations'"
    matches = re.findall(pattern, result.stdout + result.stderr)

    missing_keys = set(matches)
    print(f"✅ Found {len(missing_keys)} unique missing keys")
    return missing_keys


def load_arb(path: Path) -> Dict:
    """Load ARB file as JSON."""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_arb(path: Path, data: Dict):
    """Save ARB file as JSON with proper formatting."""
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')  # Add trailing newline


def add_missing_keys(arb_en: Dict, arb_it: Dict, missing_keys: Set[str]) -> tuple[int, int]:
    """Add missing keys to ARB files."""
    added_en = 0
    added_it = 0

    for key in sorted(missing_keys):
        # Skip if key already exists
        if key in arb_en or key in arb_it:
            continue

        # Generate translations
        en_text, it_text = translate_key(key)

        # Add to English ARB
        arb_en[key] = en_text
        arb_en[f'@{key}'] = {
            'description': f'Auto-generated for {key}'
        }
        added_en += 1

        # Add to Italian ARB
        arb_it[key] = it_text
        added_it += 1

        print(f"  ➕ {key}: EN='{en_text}', IT='{it_text}'")

    return added_en, added_it


def main():
    """Main function."""
    print("🚀 Auto-fixing missing localization keys...\n")

    # Extract missing keys
    missing_keys = extract_missing_keys()

    if not missing_keys:
        print("✅ No missing keys found!")
        return

    print(f"\n📝 Adding {len(missing_keys)} missing keys to ARB files...")

    # Load ARB files
    arb_en = load_arb(ARB_EN)
    arb_it = load_arb(ARB_IT)

    # Add missing keys
    added_en, added_it = add_missing_keys(arb_en, arb_it, missing_keys)

    # Save ARB files
    if added_en > 0:
        save_arb(ARB_EN, arb_en)
        print(f"💾 Saved {added_en} new keys to {ARB_EN.name}")

    if added_it > 0:
        save_arb(ARB_IT, arb_it)
        print(f"💾 Saved {added_it} new keys to {ARB_IT.name}")

    # Regenerate localizations
    print("\n🔄 Regenerating localizations with flutter gen-l10n...")
    result = subprocess.run(
        ['flutter', 'gen-l10n'],
        cwd=PROJECT_ROOT
    )

    if result.returncode == 0:
        print("✅ Localizations regenerated successfully!")
    else:
        print("❌ Error regenerating localizations")
        return 1

    print(f"\n✨ Done! Added {added_en} English + {added_it} Italian translations")
    print("📋 Next: Review and improve auto-generated translations if needed")

    return 0


if __name__ == '__main__':
    exit(main())
