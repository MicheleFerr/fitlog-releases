#!/usr/bin/env python3
"""
DeepL translation with full context for natural Italian
Translates complete text blocks instead of word-by-word
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
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "translation_progress.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# DeepL API Key
DEEPL_API_KEY = "faa0329c-f28a-405e-88e0-262cbb6e37df:fx"

BATCH_SIZE = 50


def load_progress():
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"translated_count": 0, "exercises": []}


def save_progress(progress):
    with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2, ensure_ascii=False)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress["exercises"], f, indent=2, ensure_ascii=False)


def translate_text(text, translator):
    """Translate complete text block with full context"""
    if not text or len(text.strip()) == 0:
        return None

    try:
        result = translator.translate_text(
            text,
            source_lang="EN",
            target_lang="IT",
            formality="default",
            preserve_formatting=True
        )
        return result.text
    except Exception as e:
        print(f"⚠️  Error: {e}")
        return text


def post_process_steps(text):
    """
    Fix step numbering after DeepL translation
    DeepL might translate 'Step:1' inconsistently
    """
    if not text:
        return None

    # Replace various step formats with consistent "Passo N:"
    text = re.sub(r'Step:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passo:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passaggio\s*(\d+):', r'Passo \1:', text, flags=re.IGNORECASE)

    return text


def translate_exercise(exercise, translator):
    """Translate exercise with full context for natural translation"""
    translated = exercise.copy()

    try:
        # Translate nome (exercise name)
        if exercise.get('nome'):
            translated['nome'] = translate_text(exercise['nome'], translator)

        # Translate noteTecniche as complete block for context
        if exercise.get('noteTecniche'):
            translated_notes = translate_text(exercise['noteTecniche'], translator)
            # Post-process to fix step numbering
            translated['noteTecniche'] = post_process_steps(translated_notes)

        # Translate mobility
        if exercise.get('mobilitaPre'):
            translated['mobilitaPre'] = translate_text(exercise['mobilitaPre'], translator)

        # Translate activation
        if exercise.get('attivazionePre'):
            translated['attivazionePre'] = translate_text(exercise['attivazionePre'], translator)

    except Exception as e:
        print(f"⚠️  Error translating: {e}")
        return exercise  # Return original on error

    return translated


def main():
    print("🇮🇹 GymBro - DeepL Full Context Translation")
    print("=" * 70)

    # Connect to DeepL
    print("\n🔌 Connecting to DeepL...")
    try:
        translator = deepl.Translator(DEEPL_API_KEY)
        usage = translator.get_usage()

        print(f"✅ Connected")
        print(f"📊 Usage: {usage.character.count:,} / {usage.character.limit:,}")

        if usage.character.limit_reached:
            print("❌ Limit reached!")
            return

    except Exception as e:
        print(f"❌ Failed: {e}")
        return

    # Load
    print("\n📖 Loading...")
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        all_exercises = json.load(f)

    progress = load_progress()
    print(f"✅ {len(all_exercises)} exercises")
    print(f"✅ {progress['translated_count']} already done")

    if progress['translated_count'] >= len(all_exercises):
        print("\n✨ Already complete!")
        return

    # Backup
    if progress['translated_count'] == 0:
        BACKUP_DIR.mkdir(exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = BACKUP_DIR / f"exercises_backup_{timestamp}.json"
        print(f"\n💾 Backup: {backup.name}")
        shutil.copy(EXERCISES_FILE, backup)

    # Translate
    start = progress['translated_count']
    print(f"\n🔄 Translating {start + 1} to {len(all_exercises)}")

    for i in range(start, len(all_exercises), BATCH_SIZE):
        batch_end = min(i + BATCH_SIZE, len(all_exercises))
        batch = all_exercises[i:batch_end]

        print(f"\n📦 Batch: {i + 1}-{batch_end}")

        for j, ex in enumerate(batch):
            translated = translate_exercise(ex, translator)
            progress['exercises'].append(translated)
            progress['translated_count'] += 1

            if (j + 1) % 10 == 0:
                pct = (i + j + 1) / len(all_exercises) * 100
                print(f"   {i + j + 1}/{len(all_exercises)} ({pct:.1f}%)")

        print(f"   💾 Saving...")
        save_progress(progress)
        print(f"   ✅ Done")

    # Final
    print(f"\n💾 Final save...")
    save_progress(progress)

    size = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ {OUTPUT_FILE.name} ({size:.2f} MB)")

    # Sample
    if len(progress['exercises']) > 0:
        print("\n" + "=" * 70)
        print("📋 Sample:")
        print("=" * 70)

        orig = all_exercises[0]
        trans = progress['exercises'][0]

        print(f"\nID: {trans['id']}")
        print(f"EN: {orig['nome']}")
        print(f"IT: {trans['nome']}")
        print(f"\nIT Notes (first 150 chars):")
        print(f"{trans.get('noteTecniche', '')[:150]}...")

    # Usage
    try:
        final = translator.get_usage()
        print(f"\n📊 DeepL:")
        print(f"   Characters: {final.character.count:,}")
        print(f"   Remaining: {final.character.limit - final.character.count:,}")
    except:
        pass

    print("\n✨ Complete!")
    print(f"   {progress['translated_count']}/{len(all_exercises)}")
    print("\n⚠️  Regenerate API key after this session")


if __name__ == "__main__":
    main()
