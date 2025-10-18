#!/usr/bin/env python3
"""
Script per convertire esercizi da formato wger a formato GymBro
Mappa campi, traduce termini, genera ID univoci
"""

import json
import sys
from pathlib import Path

# Percorsi
SCRIPT_DIR = Path(__file__).parent
INPUT_FILE = SCRIPT_DIR / "data" / "wger_exercises_raw.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"

# Mapping muscoli: wger ID → abbreviazione GymBro
MUSCLE_MAP = {
    # Principali
    1: "TRAP",      # Trapezius
    2: "DELT",      # Shoulders
    3: "PETT",      # Pectorals
    4: "LAT",       # Lats
    5: "BICI",      # Biceps
    6: "TRIC",      # Triceps
    7: "AVA",       # Forearms
    8: "GLUT",      # Glutes
    9: "QUAD",      # Quadriceps
    10: "FEMOR",    # Hamstrings
    11: "POLP",     # Calves
    13: "ADDO",     # Adductors
    14: "ADD",      # Abductors
    15: "CORE",     # Core/Abs
}

# Mapping attrezzatura
EQUIPMENT_MAP = {
    1: "Bilanciere",
    3: "Manubri",
    4: "Gym mat",
    5: "Swiss Ball",
    6: "Pull-up bar",
    7: "Corpo Libero",
    8: "Panche",
    9: "Incline bench",
    10: "Kettlebell",
}

# Mapping categorie → difficoltà
CATEGORY_DIFFICULTY_MAP = {
    8: "Principiante",    # Arms
    9: "Principiante",    # Legs
    10: "Intermedio",     # Abs
    11: "Avanzato",       # Chest
    12: "Intermedio",     # Back
    13: "Intermedio",     # Shoulders
    14: "Principiante",   # Calves
}


def create_exercise_id(nome):
    """Crea ID univoco dal nome (come script esistente)"""
    if not nome:
        return ""

    exercise_id = nome.lower()

    replacements = {
        'à': 'a', 'á': 'a', 'ä': 'a',
        'è': 'e', 'é': 'e', 'ë': 'e',
        'ì': 'i', 'í': 'i', 'ï': 'i',
        'ò': 'o', 'ó': 'o', 'ö': 'o',
        'ù': 'u', 'ú': 'u', 'ü': 'u',
        ' ': '_', '-': '_', '/': '_',
        '(': '', ')': '', '[': '', ']': '',
        '"': '', "'": '', '.': '', ',': '',
        ':': '', ';': ''
    }

    for old, new in replacements.items():
        exercise_id = exercise_id.replace(old, new)

    while '__' in exercise_id:
        exercise_id = exercise_id.replace('__', '_')

    return exercise_id.strip('_')


def get_translation(exercise, lang_id=2):
    """Ottieni traduzione in lingua specificata con fallback

    Language IDs in wger:
    - 1: German (de)
    - 2: English (en)
    - 4: Spanish (es)
    - etc.

    Default: 2 (English) since Italian is not available in wger
    """
    translations = exercise.get('translations', [])

    if not translations:
        return None

    # Cerca lingua richiesta
    for trans in translations:
        if trans.get('language') == lang_id:
            return trans

    # Fallback su inglese (lang_id=2)
    if lang_id != 2:
        for trans in translations:
            if trans.get('language') == 2:
                return trans

    # Fallback prima traduzione disponibile
    return translations[0] if translations else None


def map_muscles(muscle_data):
    """Mappa ID muscoli wger a abbreviazioni GymBro

    Args:
        muscle_data: Lista di dizionari con struttura {'id': int, 'name': str, ...}
    """
    if not muscle_data:
        return None

    muscles = []
    for muscle in muscle_data:
        muscle_id = muscle.get('id') if isinstance(muscle, dict) else muscle
        if muscle_id in MUSCLE_MAP:
            muscles.append(MUSCLE_MAP[muscle_id])

    return ", ".join(muscles) if muscles else None


def map_equipment(equipment_data):
    """Mappa attrezzatura da wger

    Args:
        equipment_data: Lista di dizionari con struttura {'id': int, 'name': str}
    """
    if not equipment_data:
        return "Vario"

    equipment = []
    for eq in equipment_data:
        eq_id = eq.get('id') if isinstance(eq, dict) else eq
        if eq_id in EQUIPMENT_MAP:
            equipment.append(EQUIPMENT_MAP[eq_id])

    if not equipment:
        return "Vario"

    # Semplifica se troppi
    if len(equipment) > 2:
        return "Vario"

    return ", ".join(equipment)


def get_image_url(exercise):
    """Ottieni URL immagine"""
    images = exercise.get('images', [])
    if images and len(images) > 0:
        return images[0].get('image')
    return None


def determine_difficulty(category_id):
    """Determina difficoltà dalla categoria"""
    return CATEGORY_DIFFICULTY_MAP.get(category_id, "Intermedio")


def convert_exercise(wger_exercise):
    """Converte singolo esercizio da wger a GymBro"""
    # Ottieni traduzione inglese (italiano non disponibile in wger)
    translation = get_translation(wger_exercise, lang_id=2)
    if not translation:
        return None

    nome = translation.get('name', '').strip()
    if not nome:
        return None

    # Estrai category ID
    category = wger_exercise.get('category')
    category_id = category.get('id') if isinstance(category, dict) else category

    # Crea esercizio GymBro
    gymbro_exercise = {
        "id": create_exercise_id(nome),
        "nome": nome,
        "focus": map_muscles(wger_exercise.get('muscles', [])),
        "imageUrl": get_image_url(wger_exercise),
        "muscoliSecondari": map_muscles(wger_exercise.get('muscles_secondary', [])),
        "difficolta": determine_difficulty(category_id),
        "tipoEsercizio": "Compound",  # Default, può essere raffinato
        "attrezzatura": map_equipment(wger_exercise.get('equipment', [])),
        "patternMovimento": "Vario",  # Default
        "rangeRipetizioni": "8-15",   # Default
        "noteTecniche": translation.get('description', '').strip() or None,
        "mobilitaPre": None,
        "attivazionePre": None,
        "warmupSets": None,
        "tempoWarmup": None,
        "drillTecnico": None,
        "prevenzioneInfortuni": None,
        "cooldownConsigliato": None,
        "spiegazioneTermini": None,
        "tempoEsecuzione": None,
        "tempoNote": None
    }

    return gymbro_exercise


def load_wger_data():
    """Carica dati wger"""
    if not INPUT_FILE.exists():
        print(f"❌ File non trovato: {INPUT_FILE}")
        print("   Esegui prima: python3 scripts/download_wger_exercises.py")
        return None

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    return data.get('exercises', [])


def save_gymbro_exercises(exercises):
    """Salva esercizi in formato GymBro"""
    # Assicura che la directory esista
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"💾 File salvato: {OUTPUT_FILE}")
    print(f"📦 Dimensione: {file_size_mb:.2f} MB")


def main():
    print("🔄 GymBro - wger to GymBro Converter")
    print("=" * 50)

    # Carica dati wger
    print("\n📖 Caricamento dati wger...")
    wger_exercises = load_wger_data()
    if not wger_exercises:
        sys.exit(1)

    print(f"✅ Caricati {len(wger_exercises)} esercizi da wger")

    # Converti
    print("\n🔄 Conversione in formato GymBro...")
    gymbro_exercises = []
    skipped = []

    for wger_ex in wger_exercises:
        gymbro_ex = convert_exercise(wger_ex)
        if gymbro_ex:
            gymbro_exercises.append(gymbro_ex)
        else:
            skipped.append(wger_ex.get('id', 'unknown'))

    # Statistiche
    print("\n" + "=" * 50)
    print(f"✅ Conversione completata!")
    print(f"📊 Esercizi convertiti: {len(gymbro_exercises)}")
    print(f"⚠️  Esercizi saltati: {len(skipped)}")

    if skipped and len(skipped) < 20:
        print(f"\n📋 IDs saltati: {', '.join(map(str, skipped[:10]))}")

    # Salva
    print("\n💾 Salvataggio...")
    save_gymbro_exercises(gymbro_exercises)

    # Analisi
    if len(gymbro_exercises) > 0:
        print("\n📊 Statistiche esercizi:")
        with_images = sum(1 for ex in gymbro_exercises if ex.get('imageUrl'))
        with_focus = sum(1 for ex in gymbro_exercises if ex.get('focus'))
        with_notes = sum(1 for ex in gymbro_exercises if ex.get('noteTecniche'))

        print(f"   Con immagini: {with_images}/{len(gymbro_exercises)} ({with_images/len(gymbro_exercises)*100:.1f}%)")
        print(f"   Con focus muscolare: {with_focus}/{len(gymbro_exercises)} ({with_focus/len(gymbro_exercises)*100:.1f}%)")
        print(f"   Con note tecniche: {with_notes}/{len(gymbro_exercises)} ({with_notes/len(gymbro_exercises)*100:.1f}%)")
    else:
        print("\n⚠️  Nessun esercizio convertito! Controlla i dati di input.")

    print("\n✨ Pronto per l'importazione in Firestore!")
    print("   Prossimo step: python3 scripts/import_exercises_to_firestore.py")


if __name__ == "__main__":
    main()
