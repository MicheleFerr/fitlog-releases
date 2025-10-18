#!/usr/bin/env python3
"""
Analizza TUTTI i nomi degli esercizi e crea piano di correzione completo
Basato su nomenclatura fitness italiana standard
"""

import json
import re
from pathlib import Path
from collections import defaultdict

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
PLAN_FILE = SCRIPT_DIR / "data" / "correction_plan.json"
REPORT_FILE = SCRIPT_DIR / "data" / "correction_report.md"


# Dizionario completo nomenclatura fitness italiana
EQUIPMENT_IT = {
    'barbell': 'Bilanciere',
    'dumbbell': 'Manubri',
    'dumbbells': 'Manubri',
    'cable': 'Cavi',
    'band': 'Elastico',
    'resistance band': 'Elastico',
    'kettlebell': 'Kettlebell',
    'ez barbell': 'Bilanciere EZ',
    'ez-barbell': 'Bilanciere EZ',
    'ez bar': 'Bilanciere EZ',
    'smith machine': 'Smith Machine',
    'smith': 'Smith Machine',
    'lever': 'Macchina',
    'machine': 'Macchina',
    'body weight': 'Corpo Libero',
    'bodyweight': 'Corpo Libero',
    'stability ball': 'Fitball',
    'exercise ball': 'Fitball',
    'swiss ball': 'Fitball',
    'bosu ball': 'Bosu',
    'medicine ball': 'Palla Medica',
    'rope': 'Corda',
    'wheel roller': 'Ab Wheel',
    'foam roll': 'Foam Roller',
    'roller': 'Foam Roller',
    'sled': 'Slitta',
    'tire': 'Pneumatico',
    'assisted': 'Assistito',
    'weighted': 'Zavorra',
}

EXERCISES_IT = {
    # Petto
    'bench press': 'Panca Piana',
    'incline bench press': 'Panca Inclinata',
    'decline bench press': 'Panca Declinata',
    'chest press': 'Chest Press',
    'fly': 'Croci',
    'flys': 'Croci',
    'flyes': 'Croci',
    'push up': 'Piegamenti',
    'push-up': 'Piegamenti',
    'pushup': 'Piegamenti',
    'dip': 'Dip',
    'dips': 'Dip',

    # Dorso
    'pull up': 'Trazioni',
    'pull-up': 'Trazioni',
    'pullup': 'Trazioni',
    'chin up': 'Trazioni Supine',
    'lat pulldown': 'Lat Machine',
    'pulldown': 'Pulldown',
    'row': 'Rematore',
    'rows': 'Rematore',
    'deadlift': 'Stacco',
    'shrug': 'Scrollate',
    'shrugs': 'Scrollate',

    # Spalle
    'shoulder press': 'Lento',
    'military press': 'Lento Militare',
    'overhead press': 'Lento',
    'lateral raise': 'Alzate Laterali',
    'front raise': 'Alzate Frontali',
    'rear delt': 'Deltoidi Posteriori',
    'rear deltoid': 'Deltoidi Posteriori',
    'face pull': 'Face Pull',

    # Braccia
    'bicep curl': 'Curl Bicipiti',
    'biceps curl': 'Curl Bicipiti',
    'curl': 'Curl',
    'hammer curl': 'Curl a Martello',
    'concentration curl': 'Curl in Concentrazione',
    'preacher curl': 'Curl alla Panca Scott',
    'tricep extension': 'Estensioni Tricipiti',
    'triceps extension': 'Estensioni Tricipiti',
    'extension': 'Estensioni',
    'pushdown': 'Pushdown',
    'kickback': 'Kickback',

    # Gambe
    'squat': 'Squat',
    'back squat': 'Back Squat',
    'front squat': 'Front Squat',
    'lunge': 'Affondi',
    'lunges': 'Affondi',
    'leg press': 'Leg Press',
    'leg curl': 'Leg Curl',
    'leg extension': 'Leg Extension',
    'calf raise': 'Calf Raise',
    'hip thrust': 'Hip Thrust',
    'glute bridge': 'Ponte per Glutei',

    # Core
    'crunch': 'Crunch',
    'sit up': 'Sit-Up',
    'sit-up': 'Sit-Up',
    'plank': 'Plank',
    'russian twist': 'Russian Twist',
    'leg raise': 'Sollevamento Gambe',
    'bicycle': 'Bicicletta',

    # Cardio
    'jump': 'Salto',
    'jumping': 'Salti',
    'sprint': 'Sprint',
    'run': 'Corsa',
    'running': 'Corsa',
}

GRIPS_IT = {
    'close grip': 'Presa Stretta',
    'close-grip': 'Presa Stretta',
    'narrow grip': 'Presa Stretta',
    'wide grip': 'Presa Larga',
    'wide-grip': 'Presa Larga',
    'reverse grip': 'Presa Inversa',
    'underhand grip': 'Presa Supina',
    'overhand grip': 'Presa Prona',
    'neutral grip': 'Presa Neutra',
    'pronated': 'Presa Prona',
    'supinated': 'Presa Supina',
}

POSITIONS_IT = {
    'standing': 'in Piedi',
    'seated': 'Seduto',
    'lying': 'Sdraiato',
    'incline': 'Inclinato',
    'decline': 'Declinato',
    'flat': 'Piana',
    'kneeling': 'in Ginocchio',
    'one arm': 'a Un Braccio',
    'single arm': 'a Un Braccio',
    'one leg': 'a Una Gamba',
    'alternating': 'Alternato',
    'unilateral': 'Unilaterale',
}


def normalize_text(text):
    """Normalizza testo per matching"""
    return text.lower().strip()


def translate_exercise_name_advanced(name_en, exercise_id):
    """
    Traduzione avanzata basata su pattern e dizionari completi
    """

    # Pattern speciali per esercizi molto comuni
    special_cases = {
        'barbell_bench_press': 'Panca Piana con Bilanciere',
        'dumbbell_bench_press': 'Panca Piana con Manubri',
        'barbell_squat': 'Squat con Bilanciere',
        'barbell_back_squat': 'Back Squat con Bilanciere',
        'barbell_deadlift': 'Stacco da Terra con Bilanciere',
        'conventional_deadlift': 'Stacco Convenzionale',
        'romanian_deadlift': 'Stacco Rumeno',
        'pull_up': 'Trazioni alla Sbarra',
        'chin_up': 'Trazioni Supine',
        'push_up': 'Piegamenti',
        'dip': 'Dip',
        'plank': 'Plank',
        'crunch': 'Crunch',
        'sit_up': 'Sit-Up',
    }

    if exercise_id in special_cases:
        return special_cases[exercise_id]

    # Analisi nome inglese
    name_lower = normalize_text(name_en)

    # Componenti trovati
    equipment = None
    exercise = None
    grip = None
    position = None
    other_parts = []

    # Identifica equipment
    for en, it in EQUIPMENT_IT.items():
        if en in name_lower:
            equipment = it
            name_lower = name_lower.replace(en, '')
            break

    # Identifica esercizio base
    for en, it in EXERCISES_IT.items():
        if en in name_lower:
            exercise = it
            name_lower = name_lower.replace(en, '')
            break

    # Identifica presa
    for en, it in GRIPS_IT.items():
        if en in name_lower:
            grip = it
            name_lower = name_lower.replace(en, '')
            break

    # Identifica posizione
    for en, it in POSITIONS_IT.items():
        if en in name_lower:
            position = it
            name_lower = name_lower.replace(en, '')
            break

    # Parole rimaste (speciali, angoli, varianti)
    remaining = name_lower.replace('_', ' ').replace('-', ' ')
    remaining_words = [w.strip() for w in remaining.split() if w.strip() and len(w) > 1]

    # Costruisci nome italiano
    # Pattern: [ESERCIZIO] [POSIZIONE] [PRESA] [ALTRE_INFO] [con EQUIPMENT]
    parts = []

    if exercise:
        parts.append(exercise)

    if position:
        parts.append(position)

    if grip:
        parts.append(grip)

    # Altre parole (capitalize)
    if remaining_words:
        # Filtra parole comuni
        skip_words = {'with', 'on', 'the', 'and', 'or', 'a', 'an', 'to', 'of', 'for'}
        filtered = [w.capitalize() for w in remaining_words if w not in skip_words]
        parts.extend(filtered)

    if equipment:
        if equipment in ['Bilanciere', 'Manubri', 'Kettlebell']:
            parts.append(f'con {equipment}')
        elif equipment in ['Cavi', 'Elastico']:
            parts.append(f'ai {equipment}')
        elif equipment in ['Smith Machine', 'Macchina', 'Fitball', 'Bosu']:
            parts.append(f'alla {equipment}')
        else:
            parts.append(equipment)

    # Se non abbiamo costruito niente, usa capitalizzazione semplice
    if not parts:
        return ' '.join(w.capitalize() for w in name_en.replace('_', ' ').replace('-', ' ').split())

    return ' '.join(parts)


def analyze_all_exercises():
    """Analizza tutti gli esercizi e genera piano correzioni"""

    print("🔍 Analisi Completa Nomenclatura Esercizi")
    print("=" * 70)

    # Carica esercizi
    print("\n📖 Caricamento exercises_it.json...")
    with open(ASSETS_DIR / "exercises_it.json", 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Analizza e genera correzioni
    print("\n🔄 Analisi e generazione correzioni...")
    corrections = []
    categories = defaultdict(int)

    for ex in exercises:
        nome_attuale = ex['nome']
        nome_corretto = translate_exercise_name_advanced(ex['id'], ex['id'])

        if nome_attuale != nome_corretto:
            # Categorizza tipo correzione
            category = "ordine_parole"
            if "con" not in nome_attuale.lower() and "con" in nome_corretto.lower():
                category = "aggiunta_preposizioni"
            elif any(word in nome_attuale for word in ['press', 'curl', 'pull', 'push']):
                category = "traduzione_mancante"

            corrections.append({
                "id": ex['id'],
                "nome_attuale": nome_attuale,
                "nome_corretto": nome_corretto,
                "category": category
            })
            categories[category] += 1

    print(f"✅ Trovate {len(corrections)} correzioni necessarie")

    # Salva piano correzioni
    print(f"\n💾 Salvataggio piano correzioni...")
    with open(PLAN_FILE, 'w', encoding='utf-8') as f:
        json.dump(corrections, f, indent=2, ensure_ascii=False)

    # Genera report
    print(f"📄 Generazione report...")
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write("# 📊 Piano Correzione Nomenclatura Esercizi\n\n")
        f.write(f"**Data:** {Path(__file__).stat().st_mtime}\n")
        f.write(f"**Totale esercizi:** {len(exercises)}\n")
        f.write(f"**Correzioni necessarie:** {len(corrections)}\n\n")

        f.write("## 📈 Statistiche per Categoria\n\n")
        for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            f.write(f"- **{cat}**: {count} correzioni\n")

        f.write("\n## 🔝 Top 50 Correzioni Importanti\n\n")
        f.write("(Esercizi base e più comuni)\n\n")

        # Mostra top 50 correzioni
        for i, corr in enumerate(corrections[:50], 1):
            f.write(f"### {i}. `{corr['id']}`\n")
            f.write(f"- ❌ **Attuale:** {corr['nome_attuale']}\n")
            f.write(f"- ✅ **Corretto:** {corr['nome_corretto']}\n")
            f.write(f"- 📁 Categoria: {corr['category']}\n\n")

        if len(corrections) > 50:
            f.write(f"\n... e altre {len(corrections) - 50} correzioni\n")
            f.write(f"\nVedi file completo: `{PLAN_FILE}`\n")

    print("\n" + "=" * 70)
    print("✅ Analisi completata!")
    print(f"\n📊 Risultati:")
    print(f"   Correzioni totali: {len(corrections)}")
    print(f"   Categorie: {len(categories)}")

    print(f"\n📁 File generati:")
    print(f"   1. {PLAN_FILE}")
    print(f"      → Piano completo correzioni (JSON)")
    print(f"   2. {REPORT_FILE}")
    print(f"      → Report leggibile (Markdown)")

    print(f"\n📋 Top 10 Correzioni:")
    for i, corr in enumerate(corrections[:10], 1):
        print(f"\n   {i}. {corr['id']}")
        print(f"      ❌ {corr['nome_attuale']}")
        print(f"      ✅ {corr['nome_corretto']}")

    return corrections


if __name__ == "__main__":
    analyze_all_exercises()
