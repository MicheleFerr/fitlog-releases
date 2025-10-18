#!/usr/bin/env python3
"""
Estrae solo i nomi degli esercizi per facilitare la revisione/traduzione manuale
Crea un file JSON semplice con ID e nome per ogni esercizio
"""

import json
from pathlib import Path

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
NAMES_FILE = ASSETS_DIR / "exercises_it_nomi.json"
NAMES_CSV = ASSETS_DIR / "exercises_it_nomi.csv"


def extract_names():
    """Estrae nomi in formato semplice per revisione"""

    print("📋 GymBro - Extract Names for Review")
    print("=" * 60)

    # Carica esercizi
    print(f"\n📖 Caricamento {EXERCISES_IT}...")
    with open(EXERCISES_IT, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Estrai solo ID e nome (ordinato per ID)
    names_data = []
    for ex in sorted(exercises, key=lambda x: x['id']):
        names_data.append({
            "id": ex['id'],
            "nome": ex['nome']
        })

    # Salva JSON
    print(f"\n💾 Salvataggio {NAMES_FILE}...")
    with open(NAMES_FILE, 'w', encoding='utf-8') as f:
        json.dump(names_data, f, indent=2, ensure_ascii=False)

    json_size = NAMES_FILE.stat().st_size / 1024
    print(f"✅ JSON salvato ({json_size:.1f} KB)")

    # Salva anche CSV per facilità editing
    print(f"\n💾 Salvataggio {NAMES_CSV}...")
    with open(NAMES_CSV, 'w', encoding='utf-8') as f:
        f.write("id,nome\n")
        for item in names_data:
            # Escape virgole nel nome
            nome_escaped = f'"{item["nome"]}"' if ',' in item["nome"] else item["nome"]
            f.write(f'{item["id"]},{nome_escaped}\n')

    csv_size = NAMES_CSV.stat().st_size / 1024
    print(f"✅ CSV salvato ({csv_size:.1f} KB)")

    # Mostra sample
    print("\n📋 Sample (primi 10):")
    for item in names_data[:10]:
        print(f"   {item['id']}: {item['nome']}")

    print("\n" + "=" * 60)
    print("✅ Estrazione completata!")
    print(f"\n📁 File creati:")
    print(f"   1. {NAMES_FILE}")
    print(f"      → Modifica questo per correggere i nomi")
    print(f"\n   2. {NAMES_CSV}")
    print(f"      → Alternativa CSV (Excel, Sheets, ecc.)")
    print(f"\n📝 Prossimi step:")
    print(f"   1. Apri uno dei file sopra")
    print(f"   2. Correggi i nomi che vuoi")
    print(f"   3. Esegui: python3 scripts/apply_names_from_review.py")
    print(f"      → Applica i nomi corretti a exercises_it.json")


if __name__ == "__main__":
    extract_names()
