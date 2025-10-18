#!/usr/bin/env python3
"""
Professional translation with DeepL API
Translates all exercises EN->IT with high quality
"""

import json
import re
import shutil
from pathlib import Path
from datetime import datetime

try:
    import deepl
except ImportError:
    print("❌ DeepL library not installed. Installing...")
    import subprocess
    subprocess.check_call(["pip3", "install", "deepl"])
    import deepl

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# DeepL API Key
DEEPL_API_KEY = "faa0329c-f28a-405e-88e0-262cbb6e37df:fx"


def load_glossary():
    """Load fitness glossary"""
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def create_deepl_glossary(translator, glossary_dict):
    """
    Create DeepL custom glossary for fitness terms
    Returns glossary ID
    """
    print("\n📚 Creating DeepL custom glossary...")

    # Flatten glossary into single dict
    flat_glossary = {}
    for category, terms in glossary_dict.items():
        flat_glossary.update(terms)

    # DeepL has limit of 1000 entries per glossary
    # Take most important terms
    if len(flat_glossary) > 1000:
        flat_glossary = dict(list(flat_glossary.items())[:1000])

    glossary_name = "gymbro_fitness_glossary"

    # Check if glossary already exists
    try:
        glossaries = translator.list_glossaries()
        for g in glossaries:
            if g.name == glossary_name:
                print(f"✅ Found existing glossary: {g.glossary_id}")
                return g.glossary_id
    except Exception as e:
        print(f"⚠️  Could not check existing glossaries: {e}")

    # Create new glossary
    try:
        glossary = translator.create_glossary(
            glossary_name,
            source_lang="EN",
            target_lang="IT",
            entries=flat_glossary
        )
        print(f"✅ Created glossary: {glossary.glossary_id}")
        return glossary.glossary_id
    except Exception as e:
        print(f"⚠️  Could not create glossary: {e}")
        print("   Continuing without custom glossary...")
        return None


def translate_with_deepl(text, translator, glossary_id=None):
    """
    Translate text using DeepL
    """
    if not text or len(text.strip()) == 0:
        return None

    try:
        result = translator.translate_text(
            text,
            source_lang="EN",
            target_lang="IT",
            glossary=glossary_id if glossary_id else None
        )
        return result.text
    except Exception as e:
        print(f"⚠️  Translation error: {e}")
        return text  # Return original on error


def translate_exercise_name(name, translator, glossary_id=None):
    """Translate exercise name"""
    if not name:
        return None
    return translate_with_deepl(name, translator, glossary_id)


def translate_technical_notes(text, translator, glossary_id=None):
    """
    Translate technical notes step by step
    Preserves Step:N format
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

        # Extract step number if present
        step_match = re.match(r'(Step:)(\d+)\s+(.*)', step)
        if step_match:
            prefix = "Passo"
            number = step_match.group(2)
            content = step_match.group(3)

            # Translate content
            translated_content = translate_with_deepl(content, translator, glossary_id)
            translated_step = f"{prefix} {number}: {translated_content}"
        else:
            # No step number, translate as is
            translated_step = translate_with_deepl(step, translator, glossary_id)

        translated_steps.append(translated_step)

    return ' | '.join(translated_steps)


def translate_warmup_text(text, translator, glossary_id=None):
    """Translate warmup/activation exercises"""
    if not text:
        return None

    return translate_with_deepl(text, translator, glossary_id)


def translate_exercise(exercise, translator, glossary_id=None):
    """
    Translate complete exercise
    """
    translated = exercise.copy()

    # Translate nome
    if exercise.get('nome'):
        translated['nome'] = translate_exercise_name(
            exercise['nome'],
            translator,
            glossary_id
        )

    # Translate noteTecniche
    if exercise.get('noteTecniche'):
        translated['noteTecniche'] = translate_technical_notes(
            exercise['noteTecniche'],
            translator,
            glossary_id
        )

    # Translate mobilitaPre
    if exercise.get('mobilitaPre'):
        translated['mobilitaPre'] = translate_warmup_text(
            exercise['mobilitaPre'],
            translator,
            glossary_id
        )

    # Translate attivazionePre
    if exercise.get('attivazionePre'):
        translated['attivazionePre'] = translate_warmup_text(
            exercise['attivazionePre'],
            translator,
            glossary_id
        )

    return translated


def main():
    print("🇮🇹 GymBro - DeepL Professional Translation")
    print("=" * 70)

    # Initialize DeepL
    print("\n🔌 Connecting to DeepL API...")
    try:
        translator = deepl.Translator(DEEPL_API_KEY)

        # Check usage
        usage = translator.get_usage()
        if usage.character.limit_reached:
            print("❌ DeepL character limit reached!")
            return

        print(f"✅ Connected to DeepL")
        print(f"📊 Usage: {usage.character.count:,} / {usage.character.limit:,} characters")

    except Exception as e:
        print(f"❌ Failed to connect to DeepL: {e}")
        return

    # Load resources
    print("\n📖 Loading resources...")
    glossary_dict = load_glossary()

    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Loaded {len(exercises)} exercises")
    print(f"✅ Loaded glossary with {sum(len(v) for v in glossary_dict.values())} terms")

    # Create custom glossary
    glossary_id = create_deepl_glossary(translator, glossary_dict)

    # Backup
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_en_backup_{timestamp}.json"
    print(f"\n💾 Creating backup: {backup_file.name}")
    shutil.copy(EXERCISES_FILE, backup_file)

    # Translate
    print(f"\n🔄 Translating {len(exercises)} exercises...")
    print("   (This will take ~5-10 minutes)")
    translated_exercises = []

    for i, exercise in enumerate(exercises, 1):
        try:
            translated = translate_exercise(exercise, translator, glossary_id)
            translated_exercises.append(translated)

            if i % 50 == 0:
                print(f"   {i}/{len(exercises)}... ({i/len(exercises)*100:.1f}%)")

        except Exception as e:
            print(f"\n⚠️  Error translating exercise #{i} ({exercise.get('id')}): {e}")
            # Keep original on error
            translated_exercises.append(exercise)

    print(f"✅ Translated {len(translated_exercises)} exercises")

    # Save
    print(f"\n💾 Saving Italian exercises...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(translated_exercises, f, indent=2, ensure_ascii=False)

    file_size = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ Saved: {OUTPUT_FILE}")
    print(f"📦 Size: {file_size:.2f} MB")

    # Show sample
    print("\n" + "=" * 70)
    print("📋 Sample Translation (First Exercise):")
    print("=" * 70)

    sample_en = exercises[0]
    sample_it = translated_exercises[0]

    print(f"\nID: {sample_it['id']}")
    print(f"\nEN Name: {sample_en['nome']}")
    print(f"IT Name: {sample_it['nome']}")
    print(f"\nEN Notes (first 100 chars): {sample_en.get('noteTecniche', '')[:100]}...")
    print(f"IT Notes (first 100 chars): {sample_it.get('noteTecniche', '')[:100]}...")
    print(f"\nEN Mobility: {sample_en.get('mobilitaPre', 'N/A')}")
    print(f"IT Mobility: {sample_it.get('mobilitaPre', 'N/A')}")

    # Final usage
    try:
        final_usage = translator.get_usage()
        chars_used = final_usage.character.count - usage.character.count
        print(f"\n📊 Translation Stats:")
        print(f"   Characters used: {chars_used:,}")
        print(f"   Remaining: {final_usage.character.limit - final_usage.character.count:,}")
    except:
        pass

    print("\n" + "=" * 70)
    print("✨ Translation complete!")
    print(f"📁 Italian exercises: {OUTPUT_FILE.name}")
    print(f"💾 Backup: {backup_file.name}")
    print("\n⚠️  SECURITY: Regenerate your DeepL API key after this session")
    print("=" * 70)


if __name__ == "__main__":
    main()
