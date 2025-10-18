#!/usr/bin/env python3
"""
Manual batch translation helper
Creates batches for Claude to translate
"""

import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "manual_translation_progress.json"

def load_exercises():
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_progress():
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"translated_count": 0, "exercises": []}

def save_progress(progress):
    with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2, ensure_ascii=False)

    # Also save final file
    if len(progress['exercises']) > 0:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(progress['exercises'], f, indent=2, ensure_ascii=False)

def add_translations(translations_dict):
    """
    Add translated exercises
    translations_dict format:
    {
        "exercise_id": {
            "nome": "...",
            "noteTecniche": "...",
            "mobilitaPre": "...",
            "attivazionePre": "..."
        }
    }
    """
    all_exercises = load_exercises()
    progress = load_progress()

    start_idx = progress['translated_count']

    for ex in all_exercises[start_idx:]:
        if ex['id'] in translations_dict:
            # Apply translation
            translated = ex.copy()
            trans = translations_dict[ex['id']]

            translated['nome'] = trans.get('nome', ex['nome'])
            translated['noteTecniche'] = trans.get('noteTecniche', ex['noteTecniche'])
            translated['mobilitaPre'] = trans.get('mobilitaPre', ex['mobilitaPre'])
            translated['attivazionePre'] = trans.get('attivazionePre', ex['attivazionePre'])

            progress['exercises'].append(translated)
            progress['translated_count'] += 1
        else:
            # Stop when we reach untranslated
            break

    save_progress(progress)

    print(f"✅ Salvati {progress['translated_count']}/{len(all_exercises)} esercizi")

    return progress['translated_count'], len(all_exercises)

if __name__ == "__main__":
    all_ex = load_exercises()
    progress = load_progress()

    print(f"📊 Progresso: {progress['translated_count']}/{len(all_ex)}")
    print(f"🔄 Prossimi da tradurre: {all_ex[progress['translated_count']]['id']}")
