#!/usr/bin/env python3
"""
Script to translate exercises from English to Italian
Uses fitness glossary for technical terms consistency
"""

import json
import shutil
from pathlib import Path
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# Translation mapping for common patterns
STEP_PATTERN = "Step:"
STEP_ITALIAN = "Passo"


def load_glossary():
    """Load fitness glossary EN->IT"""
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def translate_exercise_name(name, glossary):
    """
    Translate exercise name using glossary
    This is a helper that will be enhanced with actual translations
    """
    # This will be done by Claude AI with context
    # For now, just lowercase and prepare
    return name.lower()


def translate_instructions(text, glossary):
    """
    Translate instruction text using glossary
    Maintains step numbering: Step:1 -> Passo 1:
    """
    if not text:
        return None

    # Replace Step: with Passo
    translated = text.replace("Step:", "Passo")

    return translated


def prepare_for_translation(exercises, glossary):
    """
    Prepare exercises for translation
    Returns list of exercises with fields to translate
    """
    to_translate = []

    for i, exercise in enumerate(exercises):
        item = {
            "index": i,
            "original": {
                "nome": exercise.get("nome"),
                "noteTecniche": exercise.get("noteTecniche"),
                "mobilitaPre": exercise.get("mobilitaPre"),
                "attivazionePre": exercise.get("attivazionePre"),
            },
            "id": exercise.get("id"),
            "focus": exercise.get("focus"),
            "attrezzatura": exercise.get("attrezzatura"),
        }
        to_translate.append(item)

    return to_translate


def apply_translations(exercises, translations):
    """
    Apply translations back to exercises
    """
    translated_exercises = []

    for i, exercise in enumerate(exercises):
        if i < len(translations):
            trans = translations[i]

            # Create translated exercise
            translated = {
                **exercise,  # Keep all original fields
                "nome": trans.get("nome", exercise["nome"]),
                "noteTecniche": trans.get("noteTecniche", exercise["noteTecniche"]),
                "mobilitaPre": trans.get("mobilitaPre", exercise["mobilitaPre"]),
                "attivazionePre": trans.get("attivazionePre", exercise["attivazionePre"]),
            }
            translated_exercises.append(translated)
        else:
            translated_exercises.append(exercise)

    return translated_exercises


def create_translation_batch(exercises, start_idx, batch_size=10):
    """
    Create a batch of exercises for translation
    Returns formatted text for Claude to translate
    """
    batch = exercises[start_idx:start_idx + batch_size]

    output = []
    output.append("=" * 80)
    output.append(f"BATCH: Exercises {start_idx + 1} to {start_idx + len(batch)}")
    output.append("=" * 80)
    output.append("")

    for i, ex in enumerate(batch):
        idx = start_idx + i
        output.append(f"--- Exercise #{idx + 1} ---")
        output.append(f"ID: {ex.get('id')}")
        output.append(f"Focus: {ex.get('focus')}")
        output.append(f"Equipment: {ex.get('attrezzatura')}")
        output.append("")
        output.append(f"EN Name: {ex.get('nome')}")
        output.append(f"EN Notes: {ex.get('noteTecniche', 'N/A')[:100]}...")
        output.append(f"EN Mobility: {ex.get('mobilitaPre', 'N/A')[:80]}...")
        output.append(f"EN Activation: {ex.get('attivazionePre', 'N/A')[:80]}...")
        output.append("")

    return "\n".join(output)


def main():
    print("🇮🇹 GymBro - Exercise Translator EN → IT")
    print("=" * 70)

    # Load glossary
    print("\n📖 Loading fitness glossary...")
    glossary = load_glossary()
    print(f"✅ Loaded glossary with {sum(len(v) for v in glossary.values())} terms")

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

    # Prepare for translation
    print(f"\n🔄 Preparing exercises for translation...")
    to_translate = prepare_for_translation(exercises, glossary)
    print(f"✅ Prepared {len(to_translate)} exercises")

    # Create sample batch for review
    print(f"\n📋 Creating sample batch (first 10 exercises)...")
    sample_batch = create_translation_batch(exercises, 0, 10)

    sample_file = SCRIPT_DIR / "translation_sample_batch.txt"
    with open(sample_file, 'w', encoding='utf-8') as f:
        f.write(sample_batch)

    print(f"✅ Sample batch saved to: {sample_file.name}")

    print("\n" + "=" * 70)
    print("📋 NEXT STEPS:")
    print("   1. Review sample batch in: translation_sample_batch.txt")
    print("   2. Approve translation approach")
    print("   3. Proceed with full translation of 1,500 exercises")
    print("=" * 70)


if __name__ == "__main__":
    main()
