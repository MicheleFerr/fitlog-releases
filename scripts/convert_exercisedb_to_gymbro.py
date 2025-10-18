#!/usr/bin/env python3
"""
Script per convertire esercizi da formato ExerciseDB a formato GymBro
Mappa campi, traduce termini, genera ID univoci
"""

import json
import sys
from pathlib import Path

# Percorsi
SCRIPT_DIR = Path(__file__).parent
INPUT_FILE = SCRIPT_DIR / "data" / "exercisedb_exercises_raw.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"

# Mapping body parts/muscles → abbreviazioni GymBro
BODYPART_MAP = {
    # Upper Body
    "CHEST": ["PETT"],
    "BACK": ["LAT", "TRAP"],
    "SHOULDERS": ["DELT"],
    "UPPER ARMS": ["BICI", "TRIC"],
    "LOWER ARMS": ["AVA"],

    # Core
    "WAIST": ["CORE"],
    "ABS": ["CORE"],
    "CORE": ["CORE"],

    # Lower Body
    "QUADRICEPS": ["QUAD"],
    "HAMSTRINGS": ["FEMOR"],
    "GLUTES": ["GLUT"],
    "THIGHS": ["QUAD", "FEMOR"],
    "CALVES": ["POLP"],
    "ADDUCTORS": ["ADDO"],
    "ABDUCTORS": ["ADD"],
    "LOWER LEGS": ["POLP"],

    # Full Body
    "FULL BODY": ["CORE"],
    "CARDIO": [],  # Skip, non è un muscolo
}

# Mapping attrezzatura
EQUIPMENT_MAP = {
    "BODY WEIGHT": "Corpo Libero",
    "BARBELL": "Bilanciere",
    "DUMBBELL": "Manubri",
    "DUMBBELLS": "Manubri",
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
}

# Mapping exercise type → difficoltà/tipo
EXERCISE_TYPE_MAP = {
    "STRENGTH": {"tipo": "Compound", "difficolta": "Intermedio"},
    "CARDIO": {"tipo": "Cardio", "difficolta": "Principiante"},
    "STRETCHING": {"tipo": "Stretching", "difficolta": "Principiante"},
    "POWERLIFTING": {"tipo": "Compound", "difficolta": "Avanzato"},
    "STRONGMAN": {"tipo": "Compound", "difficolta": "Avanzato"},
    "OLYMPIC WEIGHTLIFTING": {"tipo": "Compound", "difficolta": "Avanzato"},
    "PLYOMETRICS": {"tipo": "Compound", "difficolta": "Intermedio"},
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
        ':': '', ';': '', '&': 'and'
    }

    for old, new in replacements.items():
        exercise_id = exercise_id.replace(old, new)

    while '__' in exercise_id:
        exercise_id = exercise_id.replace('__', '_')

    return exercise_id.strip('_')


def map_body_parts(body_parts):
    """Mappa body parts ExerciseDB a abbreviazioni GymBro"""
    if not body_parts:
        return None

    muscles = set()
    for part in body_parts:
        part_upper = part.upper()
        if part_upper in BODYPART_MAP:
            muscles.update(BODYPART_MAP[part_upper])

    return ", ".join(sorted(muscles)) if muscles else None


def map_equipment(equipments):
    """Mappa attrezzatura da ExerciseDB"""
    if not equipments:
        return "Vario"

    equipment_it = []
    for eq in equipments:
        eq_upper = eq.upper()
        if eq_upper in EQUIPMENT_MAP:
            equipment_it.append(EQUIPMENT_MAP[eq_upper])

    if not equipment_it:
        return "Vario"

    # Semplifica se troppi
    if len(equipment_it) > 2:
        return "Vario"

    return ", ".join(equipment_it)


def get_exercise_type_info(exercise_type):
    """Ottieni tipo esercizio e difficoltà da exerciseType"""
    if not exercise_type:
        return "Compound", "Intermedio"

    type_upper = exercise_type.upper()
    info = EXERCISE_TYPE_MAP.get(type_upper, {"tipo": "Compound", "difficolta": "Intermedio"})
    return info["tipo"], info["difficolta"]


def clean_html(text):
    """Rimuove tag HTML basilari dal testo"""
    if not text:
        return None

    # Rimuovi tag HTML comuni
    import re
    text = re.sub(r'<[^>]+>', '', text)
    text = text.strip()
    return text if text else None


def convert_exercise(exercisedb_exercise):
    """Converte singolo esercizio da ExerciseDB a GymBro"""
    nome = exercisedb_exercise.get('name', '').strip()
    if not nome:
        return None

    # exerciseType non esiste nella nuova API, usa default basato su equipments
    equipments = exercisedb_exercise.get('equipments', [])
    equipment_str = ', '.join(equipments).upper() if equipments else ''

    # Inferisci tipo e difficoltà da equipment e body parts
    if 'BODY WEIGHT' in equipment_str or 'ASSISTED' in equipment_str:
        tipo_esercizio, difficolta = "Compound", "Principiante"
    elif 'BARBELL' in equipment_str or 'TRAP BAR' in equipment_str:
        tipo_esercizio, difficolta = "Compound", "Intermedio"
    else:
        tipo_esercizio, difficolta = "Compound", "Intermedio"

    # Mappa muscoli (priorità a targetMuscles, poi bodyParts, poi secondary)
    all_muscles = []
    all_muscles.extend(exercisedb_exercise.get('targetMuscles', []))
    all_muscles.extend(exercisedb_exercise.get('bodyParts', []))

    focus = map_body_parts(all_muscles)
    muscoli_secondari = map_body_parts(exercisedb_exercise.get('secondaryMuscles', []))

    # Note tecniche da istruzioni
    instructions = exercisedb_exercise.get('instructions', [])
    note_tecniche = " | ".join(instructions) if instructions else None

    # Crea esercizio GymBro
    gymbro_exercise = {
        "id": create_exercise_id(nome),
        "nome": nome,
        "focus": focus,
        "imageUrl": exercisedb_exercise.get('gifUrl'),  # Cambiato da imageUrl a gifUrl
        "muscoliSecondari": muscoli_secondari,
        "difficolta": difficolta,
        "tipoEsercizio": tipo_esercizio,
        "attrezzatura": map_equipment(equipments),
        "patternMovimento": "Vario",  # Default
        "rangeRipetizioni": "8-15" if tipo_esercizio == "Compound" else "12-20",
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


def load_exercisedb_data():
    """Carica dati ExerciseDB"""
    if not INPUT_FILE.exists():
        print(f"❌ File non trovato: {INPUT_FILE}")
        print("   Esegui prima: python3 scripts/download_exercisedb_exercises.py")
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
    print("🔄 GymBro - ExerciseDB to GymBro Converter")
    print("=" * 50)

    # Carica dati ExerciseDB
    print("\n📖 Caricamento dati ExerciseDB...")
    exercisedb_exercises = load_exercisedb_data()
    if not exercisedb_exercises:
        sys.exit(1)

    print(f"✅ Caricati {len(exercisedb_exercises)} esercizi da ExerciseDB")

    # Converti
    print("\n🔄 Conversione in formato GymBro...")
    gymbro_exercises = []
    skipped = []

    for exercisedb_ex in exercisedb_exercises:
        gymbro_ex = convert_exercise(exercisedb_ex)
        if gymbro_ex:
            gymbro_exercises.append(gymbro_ex)
        else:
            skipped.append(exercisedb_ex.get('exerciseId', 'unknown'))

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
