#!/usr/bin/env python3
"""
Google Cloud Translation API
FREE: 500k characters/month
Setup: https://console.cloud.google.com/apis/library/translate.googleapis.com
"""

import json
import re
import shutil
from pathlib import Path
from datetime import datetime

try:
    from google.cloud import translate_v2 as translate
except ImportError:
    print("❌ Google Cloud library not installed")
    print("📦 Install: pip3 install google-cloud-translate")
    exit(1)

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "translation_progress.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

BATCH_SIZE = 100


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


def post_process_steps(text):
    if not text:
        return None
    text = re.sub(r'Step:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passo:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passaggio\s*(\d+):', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Fase:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    return text


def translate_batch(exercises, translate_client):
    """Translate batch of exercises"""
    translated_exercises = []

    for ex in exercises:
        translated = ex.copy()

        try:
            # Translate nome
            if ex.get('nome'):
                result = translate_client.translate(ex['nome'], target_language='it', source_language='en')
                translated['nome'] = result['translatedText']

            # Translate noteTecniche
            if ex.get('noteTecniche'):
                result = translate_client.translate(ex['noteTecniche'], target_language='it', source_language='en')
                translated['noteTecniche'] = post_process_steps(result['translatedText'])

            # Translate mobilitaPre
            if ex.get('mobilitaPre'):
                result = translate_client.translate(ex['mobilitaPre'], target_language='it', source_language='en')
                translated['mobilitaPre'] = result['translatedText']

            # Translate attivazionePre
            if ex.get('attivazionePre'):
                result = translate_client.translate(ex['attivazionePre'], target_language='it', source_language='en')
                translated['attivazionePre'] = result['translatedText']

        except Exception as e:
            print(f"   ⚠️  Error: {e}")
            translated = ex  # Keep original

        translated_exercises.append(translated)

    return translated_exercises


def main():
    print("🇮🇹 GymBro - Google Cloud Translation")
    print("=" * 70)

    # Initialize client
    print("\n🔌 Connecting to Google Cloud...")
    try:
        translate_client = translate.Client()
        print("✅ Connected")
    except Exception as e:
        print(f"❌ Failed: {e}")
        print("\n📝 Setup:")
        print("   1. Vai su: https://console.cloud.google.com")
        print("   2. Abilita 'Cloud Translation API'")
        print("   3. Crea Service Account e scarica JSON key")
        print("   4. export GOOGLE_APPLICATION_CREDENTIALS='path/to/key.json'")
        print("   5. pip3 install google-cloud-translate")
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

        translated_batch = translate_batch(batch, translate_client)

        for ex in translated_batch:
            progress['exercises'].append(ex)
            progress['translated_count'] += 1

        pct = progress['translated_count'] / len(all_exercises) * 100
        print(f"   ✅ {progress['translated_count']}/{len(all_exercises)} ({pct:.1f}%)")

        print(f"   💾 Saving...")
        save_progress(progress)

    print(f"\n✅ Complete!")
    size = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"   Output: {OUTPUT_FILE.name} ({size:.2f} MB)")


if __name__ == "__main__":
    main()
