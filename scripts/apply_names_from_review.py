#!/usr/bin/env python3
"""
Applica i nomi modificati da exercises_it_nomi.json a exercises_it.json
Supporta anche import da CSV
"""

import json
import csv
from pathlib import Path
from datetime import datetime

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
NAMES_JSON = ASSETS_DIR / "exercises_it_nomi.json"
NAMES_CSV = ASSETS_DIR / "exercises_it_nomi.csv"
BACKUP_DIR = SCRIPT_DIR / "backups"


def load_names_from_json():
    """Carica nomi da JSON"""
    with open(NAMES_JSON, 'r', encoding='utf-8') as f:
        return {item['id']: item['nome'] for item in json.load(f)}


def load_names_from_csv():
    """Carica nomi da CSV"""
    names = {}
    with open(NAMES_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            names[row['id']] = row['nome']
    return names


def backup_exercises():
    """Crea backup di exercises_it.json"""
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_it_before_names_apply_{timestamp}.json"

    import shutil
    shutil.copy2(EXERCISES_IT, backup_file)

    print(f"💾 Backup creato: {backup_file.name}")
    return backup_file


def apply_names():
    """Applica nomi corretti a exercises_it.json"""

    print("🔄 GymBro - Apply Names from Review")
    print("=" * 60)

    # Determina quale file usare
    use_csv = False
    if NAMES_JSON.exists() and NAMES_CSV.exists():
        # Usa il più recente
        json_time = NAMES_JSON.stat().st_mtime
        csv_time = NAMES_CSV.stat().st_mtime
        use_csv = csv_time > json_time
        source_file = NAMES_CSV if use_csv else NAMES_JSON
        print(f"\n📖 Usando file più recente: {source_file.name}")
    elif NAMES_CSV.exists():
        use_csv = True
        source_file = NAMES_CSV
        print(f"\n📖 Usando: {source_file.name}")
    elif NAMES_JSON.exists():
        source_file = NAMES_JSON
        print(f"\n📖 Usando: {source_file.name}")
    else:
        print("\n❌ Nessun file nomi trovato!")
        print("   Esegui prima: python3 scripts/extract_names_for_review.py")
        return

    # Carica nomi
    print(f"📖 Caricamento nomi da {source_file.name}...")
    if use_csv:
        names_map = load_names_from_csv()
    else:
        names_map = load_names_from_json()

    print(f"✅ Caricati {len(names_map)} nomi")

    # Carica esercizi
    print(f"\n📖 Caricamento {EXERCISES_IT}...")
    with open(EXERCISES_IT, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Backup
    print("\n💾 Creazione backup...")
    backup_exercises()

    # Applica nomi
    print("\n🔄 Applicazione nomi corretti...")
    updated_count = 0
    changes = []

    for ex in exercises:
        ex_id = ex['id']
        if ex_id in names_map:
            old_name = ex['nome']
            new_name = names_map[ex_id]

            if old_name != new_name:
                ex['nome'] = new_name
                updated_count += 1
                changes.append({
                    'id': ex_id,
                    'old': old_name,
                    'new': new_name
                })

    print(f"✅ Aggiornati {updated_count} nomi")

    # Mostra sample modifiche
    if changes:
        print("\n📋 Sample modifiche (prime 10):")
        for change in changes[:10]:
            print(f"\n   ID: {change['id']}")
            print(f"   ❌ Vecchio: {change['old']}")
            print(f"   ✅ Nuovo:   {change['new']}")

        if len(changes) > 10:
            print(f"\n   ... e altre {len(changes) - 10} modifiche")

    # Salva exercises_it.json aggiornato
    print(f"\n💾 Salvataggio {EXERCISES_IT}...")
    with open(EXERCISES_IT, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    file_size = EXERCISES_IT.stat().st_size / (1024 * 1024)

    # Salva log modifiche
    if changes:
        log_file = SCRIPT_DIR / "data" / f"names_changes_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        log_file.parent.mkdir(exist_ok=True)

        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(changes, f, indent=2, ensure_ascii=False)

        print(f"📋 Log modifiche salvato: {log_file}")

    print("\n" + "=" * 60)
    print("✅ Applicazione nomi completata!")
    print(f"\n📊 Risultato:")
    print(f"   Nomi aggiornati: {updated_count}")
    print(f"   File aggiornato: {EXERCISES_IT}")
    print(f"   Dimensione: {file_size:.2f} MB")

    if updated_count == 0:
        print("\n⚠️  Nessuna modifica applicata (nomi già aggiornati?)")
    else:
        print("\n🎉 exercises_it.json è stato aggiornato con i nuovi nomi!")


if __name__ == "__main__":
    apply_names()
