#!/usr/bin/env python3
"""
Analyze most common UI strings for quick wins migration
Generates semantic localization keys and prepares ARB entries
"""

import json
import re
from collections import Counter
from typing import Dict, List, Tuple
from dataclasses import dataclass, asdict

@dataclass
class LocalizationEntry:
    """Represents a localization entry to be added"""
    key: str
    value_en: str
    value_it: str
    occurrences: int
    language: str  # Original language detected
    contexts: List[str]  # Files where this string appears

def is_real_ui_string(string_value: str) -> bool:
    """Check if string is real UI text (not debug/template/boilerplate)"""
    # Exclude patterns
    exclude_patterns = [
        r'\$\{',  # Template variables: ${...}
        r'^\$[a-zA-Z]',  # Single template variables: $var
        r'Stack trace:',  # Debug logging
        r'Stack:',  # Debug logging
        r'Error: \$',  # Error logging with variables
        r'Errore: \$',  # Italian error logging
        r'Exception:',  # Exception messages
        r'📍',  # Debug emoji
        r'^[A-Z_]{3,}$',  # ALL_CAPS constants
        r'freezed',  # Freezed boilerplate
        r'MyClass\._\(\)',  # Freezed constructor message
        r'github\.com',  # GitHub URLs
        r'^\d+$',  # Pure numbers
        r'^[{\[\]}<>]+$',  # Only brackets
        r'^\+?\$',  # Starts with $ or +$ (template vars)
        r'^[\]\[\{\}]+',  # Starts with brackets
        r'EEEE.*yyyy',  # Date format strings
        r'^\s*$',  # Empty/whitespace only
        r'failed: \$',  # Error with variable
        r'error: \$',  # Error with variable (case insensitive)
        r': \$e$',  # Ends with: $e
        r': \$error$',  # Ends with: $error
        r': \$stackTrace$',  # Ends with: $stackTrace
    ]

    for pattern in exclude_patterns:
        if re.search(pattern, string_value, re.IGNORECASE):
            return False

    # Must have at least one letter
    if not re.search(r'[a-zA-Z]', string_value):
        return False

    # Too short to be meaningful UI text (less than 3 chars)
    if len(string_value.strip()) < 3:
        return False

    # Exclude strings that are mostly symbols/numbers
    alpha_count = sum(1 for c in string_value if c.isalpha())
    if alpha_count < 3:  # At least 3 letters
        return False

    return True

def load_ui_strings() -> List[Dict]:
    """Load UI strings from merged results"""
    with open("hardcoded_strings_merged.json", 'r', encoding='utf-8') as f:
        all_strings = json.load(f)

    # Filter:
    # 1. Not in app_localizations (generated files)
    # 2. Only in lib/ (app code)
    # 3. Only UI-facing types
    # 4. Real UI strings (not debug/template)
    ui_types = ["text_widget", "label", "title", "message", "hint", "error", "tooltip"]

    filtered = [
        s for s in all_strings
        if "app_localizations" not in s['file_path']
        and s['file_path'].startswith("lib/")
        and s['string_type'] in ui_types
        and is_real_ui_string(s['string_value'])
    ]

    print(f"✅ Loaded {len(filtered)} real UI strings (from {len(all_strings)} total)")
    return filtered

def generate_semantic_key(string_value: str, language: str) -> str:
    """Generate semantic camelCase key from string value"""
    # Clean string
    cleaned = string_value.strip()

    # Common patterns for key generation
    common_mappings = {
        # Actions
        'Save': 'save',
        'Salva': 'save',
        'Cancel': 'cancel',
        'Annulla': 'cancel',
        'Delete': 'delete',
        'Elimina': 'delete',
        'Edit': 'edit',
        'Modifica': 'edit',
        'Add': 'add',
        'Aggiungi': 'add',
        'Remove': 'remove',
        'Rimuovi': 'remove',
        'Confirm': 'confirm',
        'Conferma': 'confirm',
        'Start': 'start',
        'Inizia': 'start',
        'Stop': 'stop',
        'Ferma': 'stop',
        'Continue': 'continueAction',
        'Continua': 'continueAction',
        'Skip': 'skip',
        'Salta': 'skip',
        'Next': 'next',
        'Avanti': 'next',
        'Previous': 'previous',
        'Indietro': 'previous',
        'Finish': 'finish',
        'Completa': 'finish',
        'Close': 'close',
        'Chiudi': 'close',

        # Common UI
        'OK': 'ok',
        'Yes': 'yes',
        'Sì': 'yes',
        'No': 'no',
        'Back': 'back',
        'Done': 'done',
        'Fatto': 'done',
        'Loading...': 'loading',
        'Caricamento...': 'loading',
        'Error': 'error',
        'Errore': 'error',
        'Success': 'success',
        'Successo': 'success',
        'Warning': 'warning',
        'Attenzione': 'warning',

        # Workout specific
        'Workout': 'workout',
        'Allenamento': 'workout',
        'Exercise': 'exercise',
        'Esercizio': 'exercise',
        'Set': 'set',
        'Serie': 'set',
        'Reps': 'reps',
        'Ripetizioni': 'reps',
        'Weight': 'weight',
        'Peso': 'weight',
        'Rest': 'rest',
        'Pausa': 'rest',
        'Timer': 'timer',
        'Cronometro': 'timer',
    }

    # Check exact match first
    if cleaned in common_mappings:
        return common_mappings[cleaned]

    # Generate from string
    # Remove special characters
    key = re.sub(r'[^\w\s]', '', cleaned)
    # Convert to camelCase
    words = key.split()
    if not words:
        # Fallback for strings with only special chars
        key = re.sub(r'[^\w]', '_', cleaned.lower())
        return f"string_{abs(hash(key)) % 10000}"

    # First word lowercase, rest titlecase
    key = words[0].lower() + ''.join(w.capitalize() for w in words[1:])

    # Limit length
    if len(key) > 40:
        key = key[:40]

    return key

def analyze_common_strings(ui_strings: List[Dict], top_n: int = 300) -> List[LocalizationEntry]:
    """Analyze and prepare top N common strings for migration"""
    # Count occurrences
    string_counts = Counter(s['string_value'] for s in ui_strings)

    # Get top N
    most_common = string_counts.most_common(top_n)

    print(f"\n📊 Analyzing top {top_n} common strings...")
    print(f"   Coverage: {sum(count for _, count in most_common)} / {len(ui_strings)} occurrences ({sum(count for _, count in most_common)/len(ui_strings)*100:.1f}%)")

    # Prepare localization entries
    entries = []
    used_keys = set()

    for string_value, count in most_common:
        # Find all occurrences to determine language and contexts
        occurrences = [s for s in ui_strings if s['string_value'] == string_value]

        # Determine dominant language
        language_counts = Counter(s['language'] for s in occurrences)
        dominant_language = language_counts.most_common(1)[0][0]

        # Generate semantic key
        base_key = generate_semantic_key(string_value, dominant_language)

        # Ensure unique key
        key = base_key
        suffix = 2
        while key in used_keys:
            key = f"{base_key}{suffix}"
            suffix += 1
        used_keys.add(key)

        # Get contexts (unique files)
        contexts = list(set(s['file_path'] for s in occurrences))[:5]  # Limit to 5 examples

        # Determine English and Italian values
        if dominant_language == 'EN':
            value_en = string_value
            # Try to find Italian translation from occurrences
            italian_occurrences = [s for s in ui_strings if s['language'] == 'IT' and s['string_value'] != string_value]
            # For now, use the same (user will need to translate)
            value_it = string_value  # TODO: Add translation logic
        elif dominant_language == 'IT':
            value_it = string_value
            # Try to find English translation
            value_en = string_value  # TODO: Add translation logic
        else:
            # Unknown language, use as-is
            value_en = string_value
            value_it = string_value

        entry = LocalizationEntry(
            key=key,
            value_en=value_en,
            value_it=value_it,
            occurrences=count,
            language=dominant_language,
            contexts=contexts
        )
        entries.append(entry)

    return entries

def save_results(entries: List[LocalizationEntry]):
    """Save results to JSON for next steps"""
    output = {
        'total_entries': len(entries),
        'total_occurrences': sum(e.occurrences for e in entries),
        'by_language': {
            'EN': len([e for e in entries if e.language == 'EN']),
            'IT': len([e for e in entries if e.language == 'IT']),
            'UNKNOWN': len([e for e in entries if e.language == 'UNKNOWN']),
        },
        'entries': [asdict(e) for e in entries]
    }

    with open("localization_quick_wins.json", 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Saved {len(entries)} localization entries to localization_quick_wins.json")

    # Print statistics
    print(f"\n📊 Quick Wins Statistics:")
    print(f"   Total unique strings: {len(entries)}")
    print(f"   Total occurrences covered: {sum(e.occurrences for e in entries)}")
    print(f"   By language:")
    print(f"     - English: {output['by_language']['EN']}")
    print(f"     - Italian: {output['by_language']['IT']}")
    print(f"     - Unknown: {output['by_language']['UNKNOWN']}")

    # Show top 20 examples
    print(f"\n🔝 Top 20 most common strings:")
    for i, entry in enumerate(entries[:20], 1):
        lang_emoji = {'EN': '🇬🇧', 'IT': '🇮🇹', 'UNKNOWN': '❓'}
        print(f"   {i}. {lang_emoji[entry.language]} '{entry.value_en}' → {entry.key} ({entry.occurrences}x)")

def main():
    """Main execution"""
    print("🚀 Starting Quick Wins Analysis...\n")

    # Load UI strings
    ui_strings = load_ui_strings()

    # Analyze top 300 common strings
    entries = analyze_common_strings(ui_strings, top_n=300)

    # Save results
    save_results(entries)

    print("\n✅ Analysis complete!")
    print("   Next step: Review localization_quick_wins.json and add to ARB files")

if __name__ == "__main__":
    main()
