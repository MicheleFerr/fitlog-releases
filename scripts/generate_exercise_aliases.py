#!/usr/bin/env python3
"""
Script per generare automaticamente aliases per il database esercizi.

Genera alias intelligenti per migliorare il fuzzy matching:
- Rimozione articoli italiani (il, la, lo, gli, i, le)
- Rimozione specifiche attrezzatura (con bilanciere, con manubri, ecc.)
- Abbreviazioni comuni (RDL, BP, ecc.)
- Varianti senza caratteri speciali

Usage:
    python3 scripts/generate_exercise_aliases.py
"""

import json
import re
from pathlib import Path
from typing import List, Set
from datetime import datetime

# Articoli italiani da rimuovere
ITALIAN_ARTICLES = ['il', 'lo', 'la', 'i', 'gli', 'le', "l'"]

# Termini di attrezzatura da rimuovere per creare varianti
EQUIPMENT_TERMS = [
    'con bilanciere',
    'con manubri',
    'con manubrio',
    'al cavo',
    'ai cavi',
    'alla macchina',
    'alla smith machine',
    'al multipower',
    'a corpo libero',
    'con kettlebell',
    'con elastico',
    'con palla medica',
]

# Abbreviazioni comuni nel fitness (italiano -> abbreviazione)
COMMON_ABBREVIATIONS = {
    'romanian deadlift': 'rdl',
    'stacco rumeno': 'rdl',
    'stacco da terra': 'deadlift',
    'panca piana': 'bp',
    'bench press': 'bp',
    'military press': 'mp',
    'overhead press': 'ohp',
    'squat': 'sq',
    'leg extension': 'leg ext',
    'leg curl': 'leg curl',
    'lat machine': 'lat',
    'pulldown': 'lat',
    'trazioni': 'pull up',
    'pull up': 'pu',
    'chin up': 'cu',
    'dip': 'dip',
    'rematore': 'row',
    'curl': 'curl',
    'french press': 'fp',
    'tricipiti': 'tri',
    'bicipiti': 'bi',
    'spinte': 'press',
}


def normalize_string(text: str) -> str:
    """Normalizza stringa: lowercase, rimuove accenti."""
    text = text.lower()
    text = text.replace('à', 'a').replace('á', 'a').replace('â', 'a')
    text = text.replace('è', 'e').replace('é', 'e').replace('ê', 'e')
    text = text.replace('ì', 'i').replace('í', 'i').replace('î', 'i')
    text = text.replace('ò', 'o').replace('ó', 'o').replace('ô', 'o')
    text = text.replace('ù', 'u').replace('ú', 'u').replace('û', 'u')
    return text.strip()


def remove_articles(text: str) -> str:
    """Rimuove articoli italiani dall'inizio della stringa."""
    words = text.split()
    if len(words) > 1 and words[0].lower() in ITALIAN_ARTICLES:
        return ' '.join(words[1:])
    return text


def remove_equipment(text: str) -> str:
    """Rimuove specifiche di attrezzatura dalla stringa."""
    normalized = normalize_string(text)
    for equipment in EQUIPMENT_TERMS:
        # Rimuovi il termine di attrezzatura
        normalized = normalized.replace(equipment, '')
    # Pulisci spazi multipli e trim
    normalized = re.sub(r'\s+', ' ', normalized).strip()
    return normalized


def generate_abbreviation(text: str) -> List[str]:
    """Genera abbreviazioni basate su prime lettere o termini comuni."""
    abbreviations = []

    # Controlla se c'è un'abbreviazione comune conosciuta
    normalized = normalize_string(text)
    for full_term, abbr in COMMON_ABBREVIATIONS.items():
        if full_term in normalized:
            abbreviations.append(abbr)

    # Genera abbreviazione da prime lettere (se >2 parole)
    words = text.split()
    if len(words) >= 2:
        first_letters = ''.join([w[0].lower() for w in words if len(w) > 0])
        if len(first_letters) >= 2:
            abbreviations.append(first_letters)

    return abbreviations


def generate_aliases(exercise_name: str) -> List[str]:
    """
    Genera lista di aliases per un esercizio.

    Strategie:
    1. Nome senza articoli
    2. Nome senza attrezzatura
    3. Abbreviazioni comuni
    4. Varianti normalizzate
    """
    aliases: Set[str] = set()

    # Normalizza nome base
    normalized_base = normalize_string(exercise_name)

    # 1. Rimuovi articoli
    without_articles = remove_articles(exercise_name)
    if without_articles != exercise_name:
        aliases.add(normalize_string(without_articles))

    # 2. Rimuovi attrezzatura
    without_equipment = remove_equipment(exercise_name)
    if without_equipment and without_equipment != normalized_base:
        aliases.add(without_equipment)
        # Anche senza articoli
        without_both = remove_articles(without_equipment)
        if without_both != without_equipment:
            aliases.add(normalize_string(without_both))

    # 3. Abbreviazioni
    abbreviations = generate_abbreviation(exercise_name)
    aliases.update(abbreviations)

    # 4. Varianti con/senza trattini e underscore
    if '-' in normalized_base:
        aliases.add(normalized_base.replace('-', ' '))
        aliases.add(normalized_base.replace('-', ''))
    if '_' in normalized_base:
        aliases.add(normalized_base.replace('_', ' '))
        aliases.add(normalized_base.replace('_', ''))

    # 5. Rimuovi alias identici al nome normalizzato originale
    aliases.discard(normalized_base)
    aliases.discard(exercise_name.lower())

    # Filtra alias troppo corti (< 2 caratteri) eccetto abbreviazioni note
    filtered_aliases = []
    for alias in aliases:
        if len(alias) >= 2 or alias in COMMON_ABBREVIATIONS.values():
            filtered_aliases.append(alias)

    return sorted(list(set(filtered_aliases)))


def process_exercises_json(input_path: Path, output_path: Path, backup: bool = True):
    """
    Processa il file JSON degli esercizi aggiungendo aliases.

    Args:
        input_path: Percorso file JSON input
        output_path: Percorso file JSON output
        backup: Se True, crea backup del file originale
    """
    # Leggi JSON
    with open(input_path, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"📚 Caricati {len(exercises)} esercizi da {input_path}")

    # Crea backup se richiesto
    if backup:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_path = input_path.parent / f"{input_path.stem}_backup_{timestamp}.json"
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(exercises, f, ensure_ascii=False, indent=2)
        print(f"💾 Backup creato: {backup_path}")

    # Processa ogni esercizio
    total_aliases = 0
    exercises_with_aliases = 0

    for exercise in exercises:
        exercise_name = exercise.get('nome', '')
        if not exercise_name:
            continue

        # Genera aliases
        aliases = generate_aliases(exercise_name)

        # Aggiungi al JSON
        exercise['aliases'] = aliases

        if aliases:
            total_aliases += len(aliases)
            exercises_with_aliases += 1

    # Salva JSON modificato
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Completato!")
    print(f"   📊 Esercizi processati: {len(exercises)}")
    print(f"   🏷️  Esercizi con aliases: {exercises_with_aliases}")
    print(f"   📝 Totale aliases generati: {total_aliases}")
    print(f"   📈 Media aliases per esercizio: {total_aliases / max(exercises_with_aliases, 1):.1f}")
    print(f"   💾 File salvato: {output_path}")


def main():
    """Entry point dello script."""
    import sys

    # Percorsi
    project_root = Path(__file__).parent.parent

    # Determina quale file processare (default: entrambi)
    files_to_process = []

    if len(sys.argv) > 1:
        # Argomento specificato: "en", "it", o "all"
        arg = sys.argv[1].lower()
        if arg in ['en', 'english']:
            files_to_process = ['exercises.json']
        elif arg in ['it', 'italian']:
            files_to_process = ['exercises_it.json']
        elif arg == 'all':
            files_to_process = ['exercises.json', 'exercises_it.json']
        else:
            print(f"❌ Argomento non valido: {sys.argv[1]}")
            print("   Usa: 'en', 'it', o 'all' (default)")
            return 1
    else:
        # Default: processa entrambi i file
        files_to_process = ['exercises.json', 'exercises_it.json']

    print("🚀 Script Generazione Aliases - GymBro Exercise Database")
    print(f"   Files da processare: {', '.join(files_to_process)}")
    print()

    # Processa ogni file
    success = True
    for filename in files_to_process:
        exercises_json_path = project_root / 'assets' / 'data' / filename
        output_path = exercises_json_path  # Sovrascrive il file originale (dopo backup)

        print(f"\n{'='*60}")
        print(f"📁 Processing: {filename}")
        print(f"{'='*60}")
        print(f"   Input:  {exercises_json_path}")
        print(f"   Output: {output_path}")
        print()

        # Verifica che il file esista
        if not exercises_json_path.exists():
            print(f"⚠️  Warning: File non trovato: {exercises_json_path}")
            print(f"   Saltato.")
            continue

        # Processa
        try:
            process_exercises_json(exercises_json_path, output_path, backup=True)
        except Exception as e:
            print(f"\n❌ Errore durante il processing di {filename}: {e}")
            import traceback
            traceback.print_exc()
            success = False

    # Riepilogo finale
    if success:
        print(f"\n{'='*60}")
        print("🎉 Aliases generati con successo per tutti i file!")
        print(f"{'='*60}")
        print("\n💡 Prossimi passi:")
        print("   1. Verifica i file generati")
        print("   2. Esegui 'flutter clean && flutter pub get'")
        print("   3. Testa il fuzzy matching con i nuovi aliases")
        return 0
    else:
        print("\n⚠️  Alcuni file hanno avuto errori.")
        return 1


if __name__ == '__main__':
    exit(main())
