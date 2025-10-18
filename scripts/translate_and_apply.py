#!/usr/bin/env python3
"""
Script to translate exercises from English to Italian
Uses fitness glossary for technical terms consistency
"""

import json
import re
import shutil
from pathlib import Path
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"


def load_glossary():
    """Load fitness glossary EN->IT"""
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def translate_with_glossary(text, glossary):
    """
    Translate text using glossary with intelligent matching
    Handles multi-word terms and case-insensitive matching
    """
    if not text:
        return None

    translated = text

    # Create a flat list of all terms sorted by length (longest first)
    all_terms = []
    for category in glossary.values():
        all_terms.extend(category.items())

    # Sort by length descending to match longer phrases first
    all_terms.sort(key=lambda x: len(x[0]), reverse=True)

    # Replace each term (case-insensitive)
    for en_term, it_term in all_terms:
        # Use regex for whole word matching, case-insensitive
        pattern = r'\b' + re.escape(en_term) + r'\b'
        translated = re.sub(pattern, it_term, translated, flags=re.IGNORECASE)

    return translated


def translate_exercise_name(name, glossary):
    """
    Translate exercise name using glossary
    """
    if not name:
        return None

    # Apply glossary translations
    translated = translate_with_glossary(name, glossary)

    return translated


def translate_steps(text, glossary):
    """
    Translate instruction text step by step
    Maintains step numbering: Step:1 -> Passo 1:
    """
    if not text:
        return None

    # Split by | separator
    steps = text.split(' | ')
    translated_steps = []

    for step in steps:
        step = step.strip()
        if not step:
            continue

        # Translate "Step:" to "Passo"
        step_translated = step.replace('Step:', 'Passo')

        # Apply glossary
        step_translated = translate_with_glossary(step_translated, glossary)

        translated_steps.append(step_translated)

    return ' | '.join(translated_steps)


def translate_warmup_exercises(text, glossary):
    """
    Translate warmup/activation exercises
    Format: "Exercise 2x10, Exercise 2x15"
    """
    if not text:
        return None

    return translate_with_glossary(text, glossary)


def translate_exercise(exercise, glossary):
    """
    Translate all fields of an exercise
    """
    translated = exercise.copy()

    # Translate nome (exercise name)
    if exercise.get('nome'):
        translated['nome'] = translate_exercise_name(exercise['nome'], glossary)

    # Translate noteTecniche (technical notes with steps)
    if exercise.get('noteTecniche'):
        translated['noteTecniche'] = translate_steps(exercise['noteTecniche'], glossary)

    # Translate mobilitaPre
    if exercise.get('mobilitaPre'):
        translated['mobilitaPre'] = translate_warmup_exercises(exercise['mobilitaPre'], glossary)

    # Translate attivazionePre
    if exercise.get('attivazionePre'):
        translated['attivazionePre'] = translate_warmup_exercises(exercise['attivazionePre'], glossary)

    return translated


def main():
    print("🇮🇹 GymBro - Exercise Translator EN → IT")
    print("=" * 70)

    # Load glossary
    print("\n📖 Loading fitness glossary...")
    glossary = load_glossary()
    total_terms = sum(len(v) for v in glossary.values())
    print(f"✅ Loaded glossary with {total_terms} terms across {len(glossary)} categories")

    # Load exercises
    print(f"\n📖 Loading exercises from: {EXERCISES_FILE}")
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)
    print(f"✅ Loaded {len(exercises)} exercises")

    # Backup
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_en_backup_{timestamp}.json"
    print(f"\n💾 Creating backup: {backup_file.name}")
    shutil.copy(EXERCISES_FILE, backup_file)
    print("✅ Backup created")

    # Translate exercises
    print(f"\n🔄 Translating exercises...")
    translated_exercises = []

    for i, exercise in enumerate(exercises, 1):
        translated = translate_exercise(exercise, glossary)
        translated_exercises.append(translated)

        if i % 100 == 0:
            print(f"   Translated {i}/{len(exercises)} exercises...")

    print(f"✅ Translated {len(translated_exercises)} exercises")

    # Save Italian exercises
    print(f"\n💾 Saving Italian exercises to: {OUTPUT_FILE}")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(translated_exercises, f, indent=2, ensure_ascii=False)

    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ Saved: {OUTPUT_FILE}")
    print(f"📦 Size: {file_size_mb:.2f} MB")

    # Show sample
    print("\n" + "=" * 70)
    print("📋 Sample Translation (First Exercise):")
    print("=" * 70)

    sample = translated_exercises[0]
    print(f"\nID: {sample['id']}")
    print(f"EN Name: {exercises[0]['nome']}")
    print(f"IT Name: {sample['nome']}")
    print(f"\nEN Notes (first 100 chars): {exercises[0]['noteTecniche'][:100]}...")
    print(f"IT Notes (first 100 chars): {sample['noteTecniche'][:100]}...")
    print(f"\nEN Mobility: {exercises[0]['mobilitaPre']}")
    print(f"IT Mobility: {sample['mobilitaPre']}")

    print("\n" + "=" * 70)
    print("✨ Translation complete!")
    print(f"📁 Italian exercises saved to: {OUTPUT_FILE.name}")
    print(f"💾 Backup saved to: {backup_file.name}")
    print("=" * 70)


if __name__ == "__main__":
    main()
