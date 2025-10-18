#!/usr/bin/env python3
"""
Script per completare la traduzione di exercises_it.json
Trova gli esercizi mancanti rispetto a exercises.json e li traduce
"""

import json
from pathlib import Path
from datetime import datetime

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_EN = ASSETS_DIR / "exercises.json"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"

# File output
MISSING_FILE = SCRIPT_DIR / "data" / "exercises_missing_it.json"
OUTPUT_FILE = ASSETS_DIR / "exercises_it_complete.json"


def load_json(file_path):
    """Carica file JSON"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(data, file_path):
    """Salva file JSON"""
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def load_glossary():
    """Carica glossario fitness EN->IT"""
    try:
        return load_json(GLOSSARY_FILE)
    except FileNotFoundError:
        print(f"⚠️  Glossario non trovato: {GLOSSARY_FILE}")
        return {}


def find_missing_exercises(exercises_en, exercises_it):
    """Trova esercizi presenti in EN ma mancanti in IT"""

    # Crea set di ID esercizi
    ids_en = {ex['id'] for ex in exercises_en}
    ids_it = {ex['id'] for ex in exercises_it}

    # Trova mancanti
    missing_ids = ids_en - ids_it

    # Estrai esercizi mancanti completi
    missing_exercises = [ex for ex in exercises_en if ex['id'] in missing_ids]

    return missing_exercises


def translate_exercise_name(name_en, glossary):
    """
    Traduce nome esercizio usando glossario e pattern comuni

    Pattern comuni:
    - barbell -> Bilanciere / con Bilanciere
    - dumbbell -> Manubri / con Manubri
    - cable -> Cavi / ai Cavi
    - bench press -> Distensioni / Panca Piana
    - squat -> Squat
    - deadlift -> Stacco
    - pull up -> Trazioni
    - push up -> Piegamenti / Flessioni
    - row -> Rematore
    - curl -> Curl
    - extension -> Estensioni
    - raise -> Alzate
    - fly -> Croci
    - press -> Distensioni / Spinta
    """

    # Pattern di traduzione comuni
    patterns = {
        # Attrezzatura
        'barbell': 'con Bilanciere',
        'dumbbell': 'con Manubri',
        'cable': 'ai Cavi',
        'smith machine': 'alla Smith Machine',
        'ez barbell': 'con Bilanciere EZ',
        'kettlebell': 'con Kettlebell',
        'resistance band': 'con Elastici',
        'band': 'con Elastico',
        'bodyweight': 'a Corpo Libero',
        'body weight': 'a Corpo Libero',

        # Esercizi base
        'bench press': 'Distensioni su Panca',
        'incline bench press': 'Distensioni Inclinate',
        'decline bench press': 'Distensioni Declinate',
        'squat': 'Squat',
        'deadlift': 'Stacco',
        'pull up': 'Trazioni',
        'chin up': 'Trazioni Supine',
        'push up': 'Piegamenti',
        'row': 'Rematore',
        'curl': 'Curl',
        'extension': 'Estensioni',
        'raise': 'Alzate',
        'fly': 'Croci',
        'press': 'Spinta',
        'shoulder press': 'Spinta Spalle',
        'military press': 'Military Press',

        # Varianti presa
        'close grip': 'Presa Stretta',
        'wide grip': 'Presa Larga',
        'narrow grip': 'Presa Stretta',
        'reverse grip': 'Presa Supina',
        'neutral grip': 'Presa Neutra',
        'pronated grip': 'Presa Prona',
        'underhand grip': 'Presa Supina',
        'overhand grip': 'Presa Prona',

        # Varianti movimento
        'incline': 'Inclinato',
        'decline': 'Declinato',
        'flat': 'Piana',
        'seated': 'Seduto',
        'standing': 'in Piedi',
        'lying': 'Sdraiato',
        'kneeling': 'in Ginocchio',
        'one arm': 'un Braccio',
        'single arm': 'un Braccio',
        'two arm': 'due Braccia',
        'alternating': 'Alternato',

        # Muscoli/Body parts
        'chest': 'Petto',
        'shoulder': 'Spalla',
        'back': 'Dorso',
        'biceps': 'Bicipiti',
        'triceps': 'Tricipiti',
        'leg': 'Gambe',
        'thigh': 'Cosce',
        'calf': 'Polpacci',
        'glute': 'Glutei',
        'hamstring': 'Femorali',
        'quadriceps': 'Quadricipiti',
        'forearm': 'Avambracci',
        'abs': 'Addominali',
        'core': 'Core',
    }

    # Converti in lowercase per matching
    name_lower = name_en.lower()
    result = name_en

    # Applica pattern
    for en, it in patterns.items():
        if en in name_lower:
            result = result.replace(en, it)
            result = result.replace(en.title(), it)
            result = result.replace(en.upper(), it.upper())

    # Capitalizza prima lettera di ogni parola
    result = ' '.join(word.capitalize() for word in result.split())

    return result


def translate_instructions(instructions_en, glossary):
    """Traduce istruzioni Step by Step"""
    if not instructions_en:
        return None

    # Pattern di traduzione per istruzioni
    patterns = {
        'Step:': 'Passo',
        'Grab': 'Afferra',
        'Hold': 'Mantieni',
        'Pull': 'Tira',
        'Push': 'Spingi',
        'Lower': 'Abbassa',
        'Raise': 'Alza',
        'Squeeze': 'Contrai',
        'Pause': 'Pausa',
        'Repeat': 'Ripeti',
        'Return': 'Torna',
        'Keep': 'Mantieni',
        'Set up': 'Posiziona',
        'Lie': 'Sdraiati',
        'Sit': 'Siediti',
        'Stand': 'Mettiti in piedi',
        'the bar': 'la barra',
        'your chest': 'il petto',
        'your back': 'la schiena',
        'your arms': 'le braccia',
        'straight': 'dritto',
        'slowly': 'lentamente',
        'for a moment': 'per un momento',
        'starting position': 'posizione di partenza',
    }

    result = instructions_en
    for en, it in patterns.items():
        result = result.replace(en, it)

    return result


def create_translated_exercise(exercise_en, glossary):
    """Crea esercizio tradotto da versione inglese"""

    # Traduci nome
    nome_it = translate_exercise_name(exercise_en['nome'], glossary)

    # Traduci note tecniche (istruzioni)
    note_tecniche = translate_instructions(exercise_en.get('noteTecniche'), glossary)

    # Traduci altri campi testuali
    mobilita_pre = translate_instructions(exercise_en.get('mobilitaPre'), glossary)
    attivazione_pre = translate_instructions(exercise_en.get('attivazionePre'), glossary)

    # Crea esercizio tradotto (mantieni tutti i campi originali)
    exercise_it = {
        **exercise_en,  # Copia tutti i campi
        'nome': nome_it,  # Sovrascrivi con traduzione
        'noteTecniche': note_tecniche,
        'mobilitaPre': mobilita_pre,
        'attivazionePre': attivazione_pre,
    }

    return exercise_it


def backup_current_it():
    """Backup del file exercises_it.json attuale"""
    if not EXERCISES_IT.exists():
        return None

    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_it_backup_{timestamp}.json"

    import shutil
    shutil.copy2(EXERCISES_IT, backup_file)

    print(f"💾 Backup creato: {backup_file.name}")
    return backup_file


def main():
    print("🔄 GymBro - Complete Italian Translations")
    print("=" * 60)

    # Carica file
    print("\n📖 Caricamento esercizi...")
    exercises_en = load_json(EXERCISES_EN)
    exercises_it = load_json(EXERCISES_IT)
    glossary = load_glossary()

    print(f"✅ EN: {len(exercises_en)} esercizi")
    print(f"✅ IT: {len(exercises_it)} esercizi")

    # Trova mancanti
    print("\n🔍 Ricerca esercizi mancanti...")
    missing = find_missing_exercises(exercises_en, exercises_it)

    print(f"\n📊 Trovati {len(missing)} esercizi da tradurre!")

    if not missing:
        print("\n✅ Nessun esercizio mancante! exercises_it.json è completo!")
        return

    # Mostra sample
    print("\n📋 Esempi di esercizi mancanti:")
    for ex in missing[:10]:
        print(f"   - {ex['id']}: {ex['nome']}")
    if len(missing) > 10:
        print(f"   ... e altri {len(missing) - 10}")

    # Salva lista mancanti (per review)
    save_json(missing, MISSING_FILE)
    print(f"\n💾 Lista completa salvata in: {MISSING_FILE}")

    # Traduci esercizi mancanti
    print(f"\n🔄 Traduzione automatica di {len(missing)} esercizi...")
    translated = []

    for i, ex in enumerate(missing, 1):
        ex_it = create_translated_exercise(ex, glossary)
        translated.append(ex_it)

        if i % 50 == 0:
            print(f"   Tradotti: {i}/{len(missing)}")

    print(f"✅ Traduzione completata!")

    # Mostra sample traduzioni
    print("\n📋 Esempi di traduzioni:")
    for ex in translated[:5]:
        en_name = [e['nome'] for e in missing if e['id'] == ex['id']][0]
        print(f"   EN: {en_name}")
        print(f"   IT: {ex['nome']}\n")

    # Combina con esercizi IT esistenti
    print("\n🔗 Combinazione con esercizi esistenti...")
    exercises_it_complete = exercises_it + translated
    exercises_it_complete.sort(key=lambda x: x['id'])  # Ordina per ID

    print(f"✅ Totale esercizi completi: {len(exercises_it_complete)}")

    # Backup prima di salvare
    print("\n💾 Backup file corrente...")
    backup_current_it()

    # Salva file completo
    print("\n💾 Salvataggio exercises_it_complete.json...")
    save_json(exercises_it_complete, OUTPUT_FILE)

    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)

    # Summary
    print("\n" + "=" * 60)
    print("✅ Traduzione completata con successo!")
    print(f"\n📊 Statistiche:")
    print(f"   Esercizi originali IT: {len(exercises_it)}")
    print(f"   Esercizi tradotti: {len(translated)}")
    print(f"   Totale esercizi IT: {len(exercises_it_complete)}")
    print(f"\n💾 File salvato:")
    print(f"   {OUTPUT_FILE}")
    print(f"   Dimensione: {file_size_mb:.2f} MB")

    print("\n📝 Prossimi step:")
    print("   1. Verifica le traduzioni in: scripts/data/exercises_missing_it.json")
    print("   2. Se corrette, rinomina:")
    print(f"      mv {OUTPUT_FILE} {EXERCISES_IT}")
    print("   3. Oppure usa lo script di review per controllare le traduzioni")

    # Verifica barbell bench press
    print("\n🔍 Verifica 'barbell bench press'...")
    bench_press = [e for e in exercises_it_complete if e['id'] == 'barbell_bench_press']
    if bench_press:
        print(f"✅ TROVATO!")
        print(f"   ID: {bench_press[0]['id']}")
        print(f"   Nome IT: {bench_press[0]['nome']}")
    else:
        print("❌ Non trovato (strano!)")


if __name__ == "__main__":
    main()
