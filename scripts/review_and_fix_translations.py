#!/usr/bin/env python3
"""
Script per rivedere e correggere le traduzioni automatiche
Corregge ordine parole e pattern comuni
"""

import json
from pathlib import Path

# Percorsi
SCRIPT_DIR = Path(__file__).parent
COMPLETE_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it_complete.json"
FIXED_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"


def fix_exercise_name(nome):
    """
    Corregge pattern comuni nelle traduzioni

    Pattern da correggere:
    - "Ez Con Bilanciere" → "con Bilanciere EZ"
    - "Con Bilanciere Distensioni" → "Distensioni con Bilanciere"
    - "Smith Close-grip" → "Presa Stretta alla Smith"
    - Ordine parole italiano corretto
    """

    # Converti in lowercase per processing
    parts = nome.lower().split()

    # Fix pattern specifici
    fixes = {
        # Equipment position
        'con bilanciere': ('bilanciere', 'con_bilanciere'),
        'con manubri': ('manubri', 'con_manubri'),
        'ai cavi': ('cavi', 'ai_cavi'),
        'alla smith': ('smith', 'alla_smith'),
        'con kettlebell': ('kettlebell', 'con_kettlebell'),
        'con elastici': ('elastici', 'con_elastici'),
        'con elastico': ('elastico', 'con_elastico'),

        # Exercise types (vanno all'inizio)
        'distensioni': ('distensioni', 'EXERCISE'),
        'panca piana': ('panca_piana', 'EXERCISE'),
        'squat': ('squat', 'EXERCISE'),
        'stacco': ('stacco', 'EXERCISE'),
        'trazioni': ('trazioni', 'EXERCISE'),
        'piegamenti': ('piegamenti', 'EXERCISE'),
        'rematore': ('rematore', 'EXERCISE'),
        'curl': ('curl', 'EXERCISE'),
        'estensioni': ('estensioni', 'EXERCISE'),
        'alzate': ('alzate', 'EXERCISE'),
        'croci': ('croci', 'EXERCISE'),
        'spinta': ('spinta', 'EXERCISE'),

        # Grips (vanno dopo esercizio)
        'presa stretta': ('presa_stretta', 'GRIP'),
        'presa larga': ('presa_larga', 'GRIP'),
        'presa supina': ('presa_supina', 'GRIP'),
        'presa neutra': ('presa_neutra', 'GRIP'),
        'presa prona': ('presa_prona', 'GRIP'),

        # Variants (vanno dopo esercizio)
        'inclinato': ('inclinato', 'VARIANT'),
        'declinato': ('declinato', 'VARIANT'),
        'piana': ('piana', 'VARIANT'),
        'seduto': ('seduto', 'VARIANT'),
        'in piedi': ('in_piedi', 'VARIANT'),
        'sdraiato': ('sdraiato', 'VARIANT'),
        'un braccio': ('un_braccio', 'VARIANT'),
        'alternato': ('alternato', 'VARIANT'),
    }

    # Riordina nome seguendo pattern italiano
    # Italiano: [EXERCISE] [VARIANT] [GRIP] [EQUIPMENT]
    # Es: "Distensioni Inclinate Presa Stretta con Bilanciere"

    exercise_parts = []
    variant_parts = []
    grip_parts = []
    equipment_parts = []
    other_parts = []

    text = ' '.join(parts)

    # Identifica componenti
    for pattern, (marker, ptype) in fixes.items():
        if pattern in text:
            if ptype == 'EXERCISE':
                exercise_parts.append(pattern.title())
                text = text.replace(pattern, '')
            elif ptype == 'VARIANT':
                variant_parts.append(pattern.title())
                text = text.replace(pattern, '')
            elif ptype == 'GRIP':
                grip_parts.append(pattern.title())
                text = text.replace(pattern, '')
            elif ptype.startswith('con_') or ptype.startswith('ai_') or ptype.startswith('alla_'):
                equipment_parts.append(pattern.title())
                text = text.replace(pattern, '')

    # Raccogli altre parole rimaste
    remaining = [w.strip() for w in text.split() if w.strip()]

    # Costruisci nome corretto
    result_parts = []

    # 1. Exercise (se c'è)
    if exercise_parts:
        result_parts.extend(exercise_parts)

    # 2. Variants
    if variant_parts:
        result_parts.extend(variant_parts)

    # 3. Grip
    if grip_parts:
        result_parts.extend(grip_parts)

    # 4. Altre parole (muscoli, specificazioni)
    if remaining:
        result_parts.extend([w.title() for w in remaining])

    # 5. Equipment (alla fine)
    if equipment_parts:
        result_parts.extend(equipment_parts)

    # Se non abbiamo costruito nulla, usa originale capitalizzato
    if not result_parts:
        return ' '.join(w.capitalize() for w in nome.split())

    return ' '.join(result_parts)


def fix_specific_exercises(nome, exercise_id):
    """Correzioni manuali per esercizi specifici molto comuni"""

    specific_fixes = {
        'barbell_bench_press': 'Panca Piana con Bilanciere',
        'barbell_squat': 'Squat con Bilanciere',
        'barbell_deadlift': 'Stacco da Terra con Bilanciere',
        'dumbbell_bench_press': 'Panca Piana con Manubri',
        'dumbbell_squat': 'Squat con Manubri',
        'pull_up': 'Trazioni alla Sbarra',
        'chin_up': 'Trazioni Supine',
        'push_up': 'Piegamenti',
        'plank': 'Plank',
        'crunch': 'Crunch',
        'barbell_row': 'Rematore con Bilanciere',
        'dumbbell_row': 'Rematore con Manubri',
        'barbell_curl': 'Curl con Bilanciere',
        'dumbbell_curl': 'Curl con Manubri',
        'triceps_dip': 'Dip Tricipiti',
        'handstand': 'Verticale',
    }

    return specific_fixes.get(exercise_id, nome)


def review_translations():
    """Review e fix traduzioni"""

    print("🔍 GymBro - Review & Fix Translations")
    print("=" * 60)

    # Carica file
    print("\n📖 Caricamento exercises_it_complete.json...")
    with open(COMPLETE_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Fix traduzioni
    print("\n🔧 Correzione traduzioni...")
    fixed_count = 0

    for ex in exercises:
        nome_orig = ex['nome']

        # Applica fix specifici first
        nome_fixed = fix_specific_exercises(nome_orig, ex['id'])

        # Se non c'è fix specifico, applica pattern generici
        if nome_fixed == nome_orig:
            nome_fixed = fix_exercise_name(nome_orig)

        # Aggiorna se diverso
        if nome_fixed != nome_orig:
            ex['nome'] = nome_fixed
            fixed_count += 1

    print(f"✅ Corretti {fixed_count} nomi")

    # Mostra esempi correzioni
    print("\n📋 Esempi correzioni importanti:")
    important = ['barbell_bench_press', 'barbell_squat', 'barbell_deadlift', 'pull_up', 'push_up']
    for ex_id in important:
        ex = next((e for e in exercises if e['id'] == ex_id), None)
        if ex:
            print(f"   {ex_id}: {ex['nome']}")

    # Salva file corretto
    print(f"\n💾 Salvataggio {FIXED_FILE}...")
    with open(FIXED_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    file_size_mb = FIXED_FILE.stat().st_size / (1024 * 1024)

    print("\n" + "=" * 60)
    print("✅ Correzioni completate!")
    print(f"\n📊 Risultato finale:")
    print(f"   Esercizi totali: {len(exercises)}")
    print(f"   Nomi corretti: {fixed_count}")
    print(f"\n💾 File finale:")
    print(f"   {FIXED_FILE}")
    print(f"   Dimensione: {file_size_mb:.2f} MB")
    print("\n🎉 exercises_it.json è pronto all'uso!")


if __name__ == "__main__":
    review_translations()
