#!/usr/bin/env python3
"""
Converter da ExerciseDB RapidAPI a formato GymBro
Supporta il formato JSON restituito dalla RapidAPI
"""

import json
import sys
from pathlib import Path

# Percorsi
SCRIPT_DIR = Path(__file__).parent
INPUT_FILE = SCRIPT_DIR / "data" / "exercisedb_rapidapi_raw.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"

# Mapping body parts → abbreviazioni GymBro
BODYPART_MAP = {
    # Upper Body
    "CHEST": ["PETT"],
    "BACK": ["LAT", "TRAP"],
    "SHOULDERS": ["DELT"],
    "UPPER ARMS": ["BICI", "TRIC"],
    "LOWER ARMS": ["AVA"],
    "NECK": ["TRAP"],

    # Core
    "WAIST": ["CORE"],
    "ABS": ["CORE"],
    "CORE": ["CORE"],

    # Lower Body
    "UPPER LEGS": ["QUAD", "FEMOR"],
    "LOWER LEGS": ["POLP"],
    "CARDIO": [],  # Skip
}

# Mapping target muscles → abbreviazioni GymBro
TARGET_MAP = {
    # Chest
    "PECTORALS": ["PETT"],

    # Back
    "LATS": ["LAT"],
    "TRAPS": ["TRAP"],
    "UPPER BACK": ["TRAP"],
    "LOWER BACK": ["LAT"],

    # Shoulders
    "DELTS": ["DELT"],
    "DELTOIDI": ["DELT"],

    # Arms
    "BICEPS": ["BICI"],
    "TRICEPS": ["TRIC"],
    "FOREARMS": ["AVA"],

    # Core
    "ABS": ["CORE"],
    "OBLIQUES": ["CORE"],
    "SERRATUS ANTERIOR": ["CORE"],

    # Legs
    "QUADS": ["QUAD"],
    "GLUTES": ["GLUT"],
    "HAMSTRINGS": ["FEMOR"],
    "CALVES": ["POLP"],
    "ADDUCTORS": ["ADDO"],
    "ABDUCTORS": ["ADD"],

    # Other
    "CARDIOVASCULAR SYSTEM": [],
    "SPINE": ["CORE"],
}

# Mapping equipment
EQUIPMENT_MAP = {
    "BODY WEIGHT": "Corpo Libero",
    "BARBELL": "Bilanciere",
    "DUMBBELL": "Manubri",
    "CABLE": "Cavi",
    "MACHINE": "Macchina",
    "KETTLEBELL": "Kettlebell",
    "BAND": "Elastici",
    "RESISTANCE BAND": "Elastici",
    "MEDICINE BALL": "Palla Medica",
    "STABILITY BALL": "Swiss Ball",
    "SWISS BALL": "Swiss Ball",
    "FOAM ROLL": "Foam Roller",
    "EZ BARBELL": "Bilanciere EZ",
    "TRAP BAR": "Trap Bar",
    "WEIGHTED": "Zavorre",
    "ASSISTED": "Assistito",
    "LEVERAGE MACHINE": "Macchina",
    "ROPE": "Corde",
    "SLED MACHINE": "Slitta",
    "SKIERG MACHINE": "SkiErg",
    "STATIONARY BIKE": "Cyclette",
    "UPPER BODY ERGOMETER": "Ergometro",
    "TIRE": "Pneumatico",
    "WHEEL ROLLER": "Ab Wheel",
    "SMITH MACHINE": "Smith Machine",
    "BOSU BALL": "Bosu Ball",
    "ROLLER": "Foam Roller",
    "HAMMER": "Hammer",
}


def create_exercise_id(nome):
    """Crea ID univoco dal nome"""
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
        ':': '', ';': '', '&': 'and'
    }

    for old, new in replacements.items():
        exercise_id = exercise_id.replace(old, new)

    while '__' in exercise_id:
        exercise_id = exercise_id.replace('__', '_')

    return exercise_id.strip('_')


def map_muscles(body_part, target):
    """Mappa body part e target muscle a abbreviazioni GymBro"""
    muscles = set()

    # Target muscle ha priorità
    if target:
        target_upper = target.upper()
        if target_upper in TARGET_MAP:
            muscles.update(TARGET_MAP[target_upper])

    # Body part come fallback/aggiunta
    if body_part:
        part_upper = body_part.upper()
        if part_upper in BODYPART_MAP:
            muscles.update(BODYPART_MAP[part_upper])

    return ", ".join(sorted(muscles)) if muscles else None


def map_equipment(equipment):
    """Mappa equipment da RapidAPI"""
    if not equipment:
        return "Vario"

    eq_upper = equipment.upper()
    return EQUIPMENT_MAP.get(eq_upper, "Vario")


def determine_difficulty(body_part, equipment):
    """Determina difficoltà basata su body part e equipment"""
    if not equipment:
        return "Intermedio"

    eq_upper = equipment.upper()

    # Body weight → Principiante
    if "BODY WEIGHT" in eq_upper or "ASSISTED" in eq_upper:
        return "Principiante"

    # Macchine → Principiante/Intermedio
    if "MACHINE" in eq_upper:
        return "Principiante"

    # Bilanciere complessi → Avanzato
    if "BARBELL" in eq_upper or "OLYMPIC" in eq_upper:
        if body_part and body_part.upper() in ["UPPER LEGS", "BACK"]:
            return "Intermedio"
        return "Intermedio"

    # Default
    return "Intermedio"


def determine_exercise_type(body_part, equipment):
    """Determina tipo esercizio"""
    if not body_part:
        return "Compound"

    part_upper = body_part.upper()

    # Cardio
    if "CARDIO" in part_upper:
        return "Cardio"

    # Isolamento per piccoli muscoli
    if part_upper in ["LOWER ARMS", "CALVES"]:
        return "Isolamento"

    # Compound per default (specialmente legs, back, chest)
    return "Compound"


def get_rep_range(tipo_esercizio, body_part):
    """Ottieni range ripetizioni basato su tipo e body part"""
    if tipo_esercizio == "Cardio":
        return "Tempo"

    # Compound grandi muscoli → più basso
    if body_part and body_part.upper() in ["UPPER LEGS", "BACK", "CHEST"]:
        return "6-12"

    # Isolamento o muscoli piccoli → più alto
    if tipo_esercizio == "Isolamento":
        return "12-20"

    # Default
    return "8-15"


def convert_exercise(rapidapi_exercise):
    """Converte singolo esercizio da RapidAPI a GymBro"""
    # Campi RapidAPI
    nome = rapidapi_exercise.get('name', '').strip()
    if not nome:
        return None

    body_part = rapidapi_exercise.get('bodyPart')
    target = rapidapi_exercise.get('target')
    equipment = rapidapi_exercise.get('equipment')
    gif_url = rapidapi_exercise.get('gifUrl')
    instructions = rapidapi_exercise.get('instructions', [])
    secondary_muscles = rapidapi_exercise.get('secondaryMuscles', [])

    # Determina caratteristiche
    tipo_esercizio = determine_exercise_type(body_part, equipment)
    difficolta = determine_difficulty(body_part, equipment)

    # Mappa muscoli
    focus = map_muscles(body_part, target)

    # Muscoli secondari
    muscoli_secondari = None
    if secondary_muscles:
        sec_muscles = set()
        for muscle in secondary_muscles:
            muscle_upper = muscle.upper()
            if muscle_upper in TARGET_MAP:
                sec_muscles.update(TARGET_MAP[muscle_upper])
        muscoli_secondari = ", ".join(sorted(sec_muscles)) if sec_muscles else None

    # Note tecniche da istruzioni
    note_tecniche = " | ".join(instructions) if instructions else None

    # Crea esercizio GymBro
    gymbro_exercise = {
        "id": create_exercise_id(nome),
        "nome": nome,
        "focus": focus,
        "imageUrl": gif_url,
        "muscoliSecondari": muscoli_secondari,
        "difficolta": difficolta,
        "tipoEsercizio": tipo_esercizio,
        "attrezzatura": map_equipment(equipment),
        "patternMovimento": "Vario",
        "rangeRipetizioni": get_rep_range(tipo_esercizio, body_part),
        "noteTecniche": note_tecniche,
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


def load_rapidapi_data():
    """Carica dati RapidAPI"""
    if not INPUT_FILE.exists():
        print(f"❌ File non trovato: {INPUT_FILE}")
        print("   Esegui prima: python3 scripts/download_exercisedb_rapidapi.py")
        return None

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    return data.get('exercises', [])


def save_gymbro_exercises(exercises):
    """Salva esercizi in formato GymBro"""
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"💾 File salvato: {OUTPUT_FILE}")
    print(f"📦 Dimensione: {file_size_mb:.2f} MB")


def main():
    print("🔄 GymBro - RapidAPI to GymBro Converter")
    print("=" * 60)

    # Carica dati RapidAPI
    print("\n📖 Caricamento dati RapidAPI...")
    rapidapi_exercises = load_rapidapi_data()
    if not rapidapi_exercises:
        sys.exit(1)

    print(f"✅ Caricati {len(rapidapi_exercises)} esercizi da RapidAPI")

    # Converti
    print("\n🔄 Conversione in formato GymBro...")
    gymbro_exercises = []
    skipped = []

    for rapidapi_ex in rapidapi_exercises:
        gymbro_ex = convert_exercise(rapidapi_ex)
        if gymbro_ex:
            gymbro_exercises.append(gymbro_ex)
        else:
            skipped.append(rapidapi_ex.get('id', 'unknown'))

    # Statistiche
    print("\n" + "=" * 60)
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

        # Breakdown per difficoltà
        diff_counts = {}
        for ex in gymbro_exercises:
            diff = ex.get('difficolta', 'Unknown')
            diff_counts[diff] = diff_counts.get(diff, 0) + 1

        print(f"\n📋 Distribuzione difficoltà:")
        for diff, count in sorted(diff_counts.items()):
            print(f"   {diff}: {count} ({count/len(gymbro_exercises)*100:.1f}%)")

    print("\n✨ Pronto per l'importazione!")
    print("   Prossimo step: python3 scripts/import_exercises_to_firestore.py")


if __name__ == "__main__":
    main()
