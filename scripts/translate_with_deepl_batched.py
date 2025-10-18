#!/usr/bin/env python3
"""
Batched DeepL translation with progress saving
Translates exercises in batches and saves progress
"""

import json
import re
import shutil
from pathlib import Path
from datetime import datetime
import deepl

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "translation_progress.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# DeepL API Key
DEEPL_API_KEY = "faa0329c-f28a-405e-88e0-262cbb6e37df:fx"

# Batch size
BATCH_SIZE = 100


def load_glossary():
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_progress():
    """Load translation progress"""
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"translated_count": 0, "exercises": []}


def save_progress(progress):
    """Save translation progress"""
    with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2, ensure_ascii=False)

    # Also save to final file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress["exercises"], f, indent=2, ensure_ascii=False)


def translate_with_deepl(text, translator):
    """Translate text using DeepL"""
    if not text or len(text.strip()) == 0:
        return None

    try:
        result = translator.translate_text(
            text,
            source_lang="EN",
            target_lang="IT"
        )
        return result.text
    except Exception as e:
        print(f"⚠️  Translation error: {e}")
        return text


def translate_technical_notes(text, translator):
    """Translate technical notes step by step"""
    if not text:
        return None

    steps = text.split(' | ')
    translated_steps = []

    for step in steps:
        step = step.strip()
        if not step:
            continue

        # Extract step number
        step_match = re.match(r'(Step:)(\d+)\s+(.*)', step)
        if step_match:
            number = step_match.group(2)
            content = step_match.group(3)
            translated_content = translate_with_deepl(content, translator)
            translated_step = f"Passo {number}: {translated_content}"
        else:
            translated_step = translate_with_deepl(step, translator)

        translated_steps.append(translated_step)

    return ' | '.join(translated_steps)


def translate_exercise(exercise, translator):
    """Translate complete exercise"""
    translated = exercise.copy()

    # Translate nome
    if exercise.get('nome'):
        translated['nome'] = translate_with_deepl(exercise['nome'], translator)

    # Translate noteTecniche
    if exercise.get('noteTecniche'):
        translated['noteTecniche'] = translate_technical_notes(
            exercise['noteTecniche'],
            translator
        )

    # Translate mobilitaPre
    if exercise.get('mobilitaPre'):
        translated['mobilitaPre'] = translate_with_deepl(
            exercise['mobilitaPre'],
            translator
        )

    # Translate attivazionePre
    if exercise.get('attivazionePre'):
        translated['attivazionePre'] = translate_with_deepl(
            exercise['attivazionePre'],
            translator
        )

    return translated


def main():
    print("🇮🇹 GymBro - DeepL Batched Translation")
    print("=" * 70)

    # Initialize DeepL
    print("\n🔌 Connecting to DeepL API...")
    try:
        translator = deepl.Translator(DEEPL_API_KEY)
        usage = translator.get_usage()

        print(f"✅ Connected to DeepL")
        print(f"📊 Usage: {usage.character.count:,} / {usage.character.limit:,} characters")

        if usage.character.limit_reached:
            print("❌ Character limit reached!")
            return

    except Exception as e:
        print(f"❌ Failed to connect: {e}")
        return

    # Load resources
    print("\n📖 Loading resources...")
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        all_exercises = json.load(f)

    progress = load_progress()

    print(f"✅ Loaded {len(all_exercises)} total exercises")
    print(f"✅ Already translated: {progress['translated_count']}")

    # Check if already done
    if progress['translated_count'] >= len(all_exercises):
        print("\n✨ All exercises already translated!")
        return

    # Backup on first run
    if progress['translated_count'] == 0:
        BACKUP_DIR.mkdir(exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = BACKUP_DIR / f"exercises_en_backup_{timestamp}.json"
        print(f"\n💾 Creating backup: {backup_file.name}")
        shutil.copy(EXERCISES_FILE, backup_file)

    # Translate in batches
    start_idx = progress['translated_count']
    remaining = len(all_exercises) - start_idx

    print(f"\n🔄 Translating exercises {start_idx + 1} to {len(all_exercises)}")
    print(f"   Remaining: {remaining} exercises")
    print(f"   Batch size: {BATCH_SIZE}")

    batch_count = 0
    for i in range(start_idx, len(all_exercises), BATCH_SIZE):
        batch_end = min(i + BATCH_SIZE, len(all_exercises))
        batch = all_exercises[i:batch_end]
        batch_count += 1

        print(f"\n📦 Batch {batch_count}: Exercises {i + 1}-{batch_end}")

        for j, exercise in enumerate(batch):
            try:
                translated = translate_exercise(exercise, translator)
                progress['exercises'].append(translated)
                progress['translated_count'] += 1

                if (j + 1) % 10 == 0:
                    print(f"   {i + j + 1}/{len(all_exercises)}... ({(i + j + 1)/len(all_exercises)*100:.1f}%)")

            except Exception as e:
                print(f"\n⚠️  Error at exercise #{i + j + 1}: {e}")
                progress['exercises'].append(exercise)  # Keep original
                progress['translated_count'] += 1

        # Save progress after each batch
        print(f"   💾 Saving progress...")
        save_progress(progress)
        print(f"   ✅ Batch {batch_count} complete ({batch_end}/{len(all_exercises)})")

    # Final save
    print(f"\n💾 Final save...")
    save_progress(progress)

    file_size = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ Saved: {OUTPUT_FILE}")
    print(f"📦 Size: {file_size:.2f} MB")

    # Sample
    if len(progress['exercises']) > 0:
        print("\n" + "=" * 70)
        print("📋 Sample (First Exercise):")
        print("=" * 70)

        sample_en = all_exercises[0]
        sample_it = progress['exercises'][0]

        print(f"\nID: {sample_it['id']}")
        print(f"\nEN: {sample_en['nome']}")
        print(f"IT: {sample_it['nome']}")
        print(f"\nEN Notes: {sample_en.get('noteTecniche', '')[:100]}...")
        print(f"IT Notes: {sample_it.get('noteTecniche', '')[:100]}...")

    # Final usage
    try:
        final_usage = translator.get_usage()
        print(f"\n📊 DeepL Usage:")
        print(f"   Used: {final_usage.character.count:,} characters")
        print(f"   Remaining: {final_usage.character.limit - final_usage.character.count:,}")
    except:
        pass

    print("\n" + "=" * 70)
    print("✨ Translation complete!")
    print(f"   Translated: {progress['translated_count']}/{len(all_exercises)}")
    print(f"   Output: {OUTPUT_FILE.name}")
    print("\n⚠️  Remember to regenerate your DeepL API key")
    print("=" * 70)


if __name__ == "__main__":
    main()
