#!/usr/bin/env python3
"""
Script per verificare la presenza di esercizi fondamentali nel database
Controlla i "Big Compound" e altri esercizi essenziali per un'app fitness
"""

import json
from pathlib import Path

# File da controllare
DATA_FILE = Path(__file__).parent / "data" / "exercisedb_exercises_raw.json"

# Lista esercizi FONDAMENTALI che DEVONO esserci
FUNDAMENTAL_EXERCISES = {
    "compound_lower": [
        "squat", "back squat", "front squat", "barbell squat",
        "deadlift", "conventional deadlift", "romanian deadlift",
        "leg press", "lunge", "bulgarian split squat"
    ],
    "compound_upper_push": [
        "bench press", "barbell bench press", "dumbbell bench press",
        "overhead press", "military press", "shoulder press",
        "incline bench press", "decline bench press",
        "dip", "push up", "push-up"
    ],
    "compound_upper_pull": [
        "pull up", "pull-up", "chin up", "chin-up",
        "barbell row", "bent over row", "pendlay row",
        "lat pulldown", "cable row", "seated row"
    ],
    "isolation_arms": [
        "bicep curl", "barbell curl", "dumbbell curl",
        "tricep extension", "triceps extension", "skull crusher",
        "hammer curl", "preacher curl"
    ],
    "isolation_legs": [
        "leg extension", "leg curl", "hamstring curl",
        "calf raise", "standing calf raise", "seated calf raise"
    ],
    "core": [
        "plank", "crunch", "sit up", "sit-up",
        "leg raise", "hanging leg raise", "russian twist"
    ],
    "olympic": [
        "clean", "power clean", "snatch", "clean and jerk"
    ]
}


def load_exercises():
    """Carica esercizi dal file JSON"""
    if not DATA_FILE.exists():
        print(f"❌ File non trovato: {DATA_FILE}")
        return None

    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    return data.get('exercises', [])


def search_exercise(exercises, search_terms):
    """Cerca esercizio per nome (case-insensitive)"""
    found = []
    for ex in exercises:
        name = ex.get('name', '').lower()
        for term in search_terms:
            if term.lower() in name:
                found.append({
                    'id': ex.get('exerciseId'),
                    'name': ex.get('name'),
                    'equipment': ', '.join(ex.get('equipments', [])),
                    'bodyPart': ', '.join(ex.get('bodyParts', []))
                })
                break
    return found


def check_fundamentals(exercises):
    """Verifica presenza esercizi fondamentali"""
    print("🏋️  GymBro - Verifica Esercizi Fondamentali")
    print("=" * 70)
    print(f"📊 Totale esercizi nel database: {len(exercises)}\n")

    results = {}
    missing_categories = []

    for category, search_terms in FUNDAMENTAL_EXERCISES.items():
        print(f"\n{'─' * 70}")
        print(f"🔍 Categoria: {category.upper().replace('_', ' ')}")
        print(f"{'─' * 70}")

        found = search_exercise(exercises, search_terms)
        results[category] = found

        if found:
            print(f"✅ Trovati {len(found)} esercizi:")
            for ex in found[:10]:  # Mostra primi 10
                print(f"   • {ex['name']}")
                print(f"     Equipment: {ex['equipment']} | BodyPart: {ex['bodyPart']}")
            if len(found) > 10:
                print(f"   ... e altri {len(found) - 10} esercizi")
        else:
            print(f"❌ NESSUN esercizio trovato!")
            missing_categories.append(category)

    # Riepilogo finale
    print("\n" + "=" * 70)
    print("📋 RIEPILOGO FINALE")
    print("=" * 70)

    total_found = sum(len(v) for v in results.values())
    total_categories = len(FUNDAMENTAL_EXERCISES)
    categories_found = total_categories - len(missing_categories)

    print(f"\n✅ Esercizi fondamentali trovati: {total_found}")
    print(f"✅ Categorie coperte: {categories_found}/{total_categories}")

    if missing_categories:
        print(f"\n⚠️  Categorie MANCANTI ({len(missing_categories)}):")
        for cat in missing_categories:
            print(f"   ❌ {cat.replace('_', ' ').upper()}")
    else:
        print("\n🎉 TUTTE le categorie fondamentali sono presenti!")

    # Raccomandazione
    print("\n" + "=" * 70)
    print("💡 RACCOMANDAZIONE")
    print("=" * 70)

    coverage_percent = (categories_found / total_categories) * 100

    if coverage_percent >= 90:
        print("✅ Database OTTIMO: Hai tutti gli esercizi fondamentali!")
        print("   → Puoi procedere con l'import su Firebase")
    elif coverage_percent >= 70:
        print("⚠️  Database BUONO: Mancano alcune categorie")
        print("   → Considera di scaricare il database completo (5.000+ esercizi)")
    else:
        print("❌ Database INCOMPLETO: Mancano molte categorie fondamentali!")
        print("   → DEVI scaricare il database completo da ExerciseDB")
        print("   → Repo: https://github.com/exercisedb/exercisedb-api")

    return results, missing_categories


def main():
    # Carica dati
    exercises = load_exercises()
    if not exercises:
        return

    # Verifica
    results, missing = check_fundamentals(exercises)

    # Salva report
    report_file = Path(__file__).parent / "data" / "fundamental_exercises_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump({
            "total_exercises": len(exercises),
            "categories_checked": list(FUNDAMENTAL_EXERCISES.keys()),
            "results": {k: [ex['name'] for ex in v] for k, v in results.items()},
            "missing_categories": missing
        }, f, indent=2, ensure_ascii=False)

    print(f"\n💾 Report salvato: {report_file.name}")


if __name__ == "__main__":
    main()
