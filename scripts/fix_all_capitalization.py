#!/usr/bin/env python3
"""
Corregge tutti i problemi di capitalizzazione e nomenclatura
"""

import json
from pathlib import Path
from datetime import datetime
import shutil
import re

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

def fix_prepositions(text):
    """
    Corregge capitalizzazione preposizioni:
    - Minuscole quando in mezzo alla frase
    - Maiuscole solo se all'inizio
    """
    # Pattern: preposizione NON all'inizio
    text = re.sub(r'(\s)Con(\s)', r'\1con\2', text)
    text = re.sub(r'(\s)Ai(\s)', r'\1ai\2', text)
    text = re.sub(r'(\s)Alla(\s)', r'\1alla\2', text)
    text = re.sub(r'(\s)Al(\s)', r'\1al\2', text)
    text = re.sub(r'(\s)Su(\s)', r'\1su\2', text)
    text = re.sub(r'(\s)In(\s)', r'\1in\2', text)
    text = re.sub(r'(\s)Da(\s)', r'\1da\2', text)
    text = re.sub(r'(\s)Per(\s)', r'\1per\2', text)
    text = re.sub(r'(\s)Di(\s)', r'\1di\2', text)
    text = re.sub(r'(\s)A(\s)', r'\1a\2', text)

    # Fix casi speciali con parentesi
    text = re.sub(r'\(In\s', r'(in ', text)
    text = re.sub(r'\(Con\s', r'(con ', text)
    text = re.sub(r'\(A\s', r'(a ', text)

    return text


def fix_common_english_terms(text):
    """
    Traduce termini inglesi comuni
    Mantiene termini che sono ormai standard in italiano
    """
    # Mantieni questi termini (sono standard internazionali)
    keep_as_is = ['Push-Up', 'Pull-Up', 'Chin-Up', 'Sit-Up', 'Hip Thrust',
                  'Plank', 'Crunch', 'Squat', 'Dip', 'Curl', 'Lat Machine',
                  'Step', 'Jumping Jack', 'Burpee', 'Box Jump']

    for term in keep_as_is:
        if term in text:
            return text  # Non modificare se contiene termini standard

    # Traduzioni
    translations = {
        # Press -> Spinta/Distensioni
        r'\bPress\b': 'Spinta',
        r'\bBench Press\b': 'Panca Piana',
        r'\bChest Press\b': 'Chest Press',  # Mantieni
        r'\bShoulder Press\b': 'Spinta per Spalle',

        # Pull -> Trazione
        r'\bPull\b(?!-Up)': 'Trazione',
        r'\bPulldown\b': 'Lat Machine',

        # Row -> Rematore
        r'\bRow\b': 'Rematore',

        # Raise -> Alzate
        r'\bRaise\b': 'Alzate',

        # Fly -> Croci
        r'\bFly\b': 'Croci',
        r'\bFlyes\b': 'Croci',

        # Extension -> Estensioni
        r'\bExtension\b': 'Estensioni',
    }

    for eng, ita in translations.items():
        text = re.sub(eng, ita, text)

    return text


def fix_word_order(text):
    """
    Corregge ordine parole problematiche
    """
    # Pattern: "Presa [Tipo] [Esercizio]" -> "[Esercizio] Presa [Tipo]"
    # Es: "Presa Stretta Pulldown" -> "Pulldown Presa Stretta"

    # Non modificare nomi che sembrano già corretti
    if text.startswith(('Squat', 'Panca', 'Stacco', 'Trazioni', 'Affondi',
                        'Curl', 'Estensioni', 'Alzate', 'Rematore', 'Croci',
                        'Spinta', 'Plank', 'Crunch', 'Sit-Up')):
        return text

    return text


def main():
    print("🔧 Fix Capitalizzazione e Nomenclatura")
    print("=" * 70)

    # Backup
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_it_before_auto_fix_{timestamp}.json"
    shutil.copy2(EXERCISES_IT, backup_file)
    print(f"\n💾 Backup: {backup_file.name}")

    # Carica esercizi
    print("\n📖 Caricamento exercises_it.json...")
    with open(EXERCISES_IT, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Applica correzioni
    print("\n🔄 Applicazione correzioni automatiche...")
    changes = []

    for ex in exercises:
        nome_originale = ex['nome']
        nome_corretto = nome_originale

        # 1. Fix preposizioni
        nome_corretto = fix_prepositions(nome_corretto)

        # 2. Fix termini inglesi (opzionale, commenta se vuoi mantenerli)
        # nome_corretto = fix_common_english_terms(nome_corretto)

        # 3. Fix ordine parole
        # nome_corretto = fix_word_order(nome_corretto)

        if nome_originale != nome_corretto:
            ex['nome'] = nome_corretto
            changes.append({
                'id': ex['id'],
                'old': nome_originale,
                'new': nome_corretto
            })

    print(f"✅ Corretti {len(changes)} nomi")

    # Salva
    print(f"\n💾 Salvataggio exercises_it.json...")
    with open(EXERCISES_IT, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    # Salva log
    if changes:
        log_file = SCRIPT_DIR / "data" / f"auto_fixes_{timestamp}.json"
        log_file.parent.mkdir(exist_ok=True)

        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(changes, f, indent=2, ensure_ascii=False)

        print(f"📋 Log salvato: {log_file.name}")

    # Mostra sample
    print(f"\n📋 Sample correzioni (prime 20):")
    for i, change in enumerate(changes[:20], 1):
        print(f"\n{i}. {change['id']}")
        print(f"   ❌ {change['old']}")
        print(f"   ✅ {change['new']}")

    if len(changes) > 20:
        print(f"\n... e altre {len(changes) - 20} correzioni")

    print("\n" + "=" * 70)
    print("✅ Correzioni completate!")
    print(f"\n📊 Risultato:")
    print(f"   Modificati: {len(changes)} esercizi")
    print(f"   File: {EXERCISES_IT}")


if __name__ == "__main__":
    main()
