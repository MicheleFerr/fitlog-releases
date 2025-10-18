#!/usr/bin/env python3
"""
Microsoft Azure Translator API
FREE: 2M characters/month (more than enough for all 1500 exercises)
"""

import json
import re
import shutil
import requests
import uuid
from pathlib import Path
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "translation_progress.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# Azure Translator Config
# Get your key from: https://portal.azure.com/#create/Microsoft.CognitiveServicesTextTranslation
AZURE_KEY = "YOUR_KEY_HERE"  # Sostituire con la tua key
AZURE_ENDPOINT = "https://api.cognitive.microsofttranslator.com"
AZURE_LOCATION = "global"  # Or your resource location

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


def translate_with_azure(texts, key, endpoint, location):
    """
    Translate multiple texts at once using Azure Translator
    texts: list of strings to translate
    """
    if not texts:
        return []

    path = '/translate'
    constructed_url = endpoint + path

    params = {
        'api-version': '3.0',
        'from': 'en',
        'to': 'it'
    }

    headers = {
        'Ocp-Apim-Subscription-Key': key,
        'Ocp-Apim-Subscription-Region': location,
        'Content-type': 'application/json',
        'X-ClientTraceId': str(uuid.uuid4())
    }

    # Azure expects array of objects with 'text' key
    body = [{'text': text} for text in texts if text]

    try:
        response = requests.post(
            constructed_url,
            params=params,
            headers=headers,
            json=body,
            timeout=30
        )
        response.raise_for_status()

        results = response.json()
        translations = [r['translations'][0]['text'] for r in results]
        return translations

    except requests.exceptions.RequestException as e:
        print(f"⚠️  Azure API error: {e}")
        return texts  # Return originals on error


def post_process_steps(text):
    """Fix step numbering after translation"""
    if not text:
        return None

    # Replace various step formats
    text = re.sub(r'Step:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passo:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Passaggio\s*(\d+):', r'Passo \1:', text, flags=re.IGNORECASE)
    text = re.sub(r'Fase:\s*(\d+)', r'Passo \1:', text, flags=re.IGNORECASE)

    return text


def translate_batch(exercises, key, endpoint, location):
    """Translate a batch of exercises"""
    # Collect all texts to translate
    texts_to_translate = []
    text_map = []  # Track which text belongs to which exercise/field

    for i, ex in enumerate(exercises):
        if ex.get('nome'):
            texts_to_translate.append(ex['nome'])
            text_map.append((i, 'nome'))

        if ex.get('noteTecniche'):
            texts_to_translate.append(ex['noteTecniche'])
            text_map.append((i, 'noteTecniche'))

        if ex.get('mobilitaPre'):
            texts_to_translate.append(ex['mobilitaPre'])
            text_map.append((i, 'mobilitaPre'))

        if ex.get('attivazionePre'):
            texts_to_translate.append(ex['attivazionePre'])
            text_map.append((i, 'attivazionePre'))

    # Translate all texts in one API call
    translated_texts = translate_with_azure(texts_to_translate, key, endpoint, location)

    # Apply translations back to exercises
    translated_exercises = [ex.copy() for ex in exercises]

    for (ex_idx, field), translation in zip(text_map, translated_texts):
        if field == 'noteTecniche':
            translation = post_process_steps(translation)
        translated_exercises[ex_idx][field] = translation

    return translated_exercises


def main():
    print("🇮🇹 GymBro - Azure Translator (FREE 2M chars/month)")
    print("=" * 70)

    # Check key
    if AZURE_KEY == "YOUR_KEY_HERE":
        print("\n❌ Azure API key non configurata!")
        print("\n📝 Setup:")
        print("   1. Vai su: https://portal.azure.com")
        print("   2. Crea risorsa 'Translator'")
        print("   3. Copia 'Key 1' dalla sezione 'Keys and Endpoint'")
        print("   4. Modifica questo file e sostituisci AZURE_KEY")
        print("\n💡 Piano FREE: 2M caratteri/mese (più che sufficiente!)")
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
    print(f"   Batch size: {BATCH_SIZE}")

    for i in range(start, len(all_exercises), BATCH_SIZE):
        batch_end = min(i + BATCH_SIZE, len(all_exercises))
        batch = all_exercises[i:batch_end]

        print(f"\n📦 Batch: {i + 1}-{batch_end}")

        try:
            translated_batch = translate_batch(batch, AZURE_KEY, AZURE_ENDPOINT, AZURE_LOCATION)

            for ex in translated_batch:
                progress['exercises'].append(ex)
                progress['translated_count'] += 1

            pct = progress['translated_count'] / len(all_exercises) * 100
            print(f"   ✅ {progress['translated_count']}/{len(all_exercises)} ({pct:.1f}%)")

        except Exception as e:
            print(f"   ⚠️  Error: {e}")
            # Add originals on error
            for ex in batch:
                progress['exercises'].append(ex)
                progress['translated_count'] += 1

        # Save progress
        print(f"   💾 Saving...")
        save_progress(progress)

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

    print("\n✨ Complete!")
    print(f"   {progress['translated_count']}/{len(all_exercises)}")
    print("\n💚 Costo: €0 (dentro quota gratuita)")


if __name__ == "__main__":
    main()
