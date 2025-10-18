#!/usr/bin/env python3
"""
Script per scaricare gli esercizi da ExerciseDB via RapidAPI
API: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb

Requisti:
    pip install requests python-dotenv

Setup:
    1. Crea file .env nella cartella scripts/ con:
       RAPIDAPI_KEY=your_api_key_here
    2. Ottieni la tua API key da: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
"""

import json
import os
import requests
import time
import sys
from pathlib import Path
from datetime import datetime

# Configurazione
RAPIDAPI_HOST = "exercisedb.p.rapidapi.com"
RAPIDAPI_BASE_URL = f"https://{RAPIDAPI_HOST}"
OUTPUT_DIR = Path(__file__).parent / "data"
OUTPUT_FILE = OUTPUT_DIR / "exercisedb_rapidapi_raw.json"
BACKUP_DIR = Path(__file__).parent / "backups"

# Numero di esercizi da scaricare (RapidAPI ha limiti)
# L'API ha 1300+ esercizi, ma usa paginazione
EXERCISES_LIMIT = 1500  # Limite massimo da scaricare
OFFSET_STEP = 100  # Esercizi per richiesta


def get_api_key():
    """Ottieni API key da variabile d'ambiente o .env file"""
    # Prima prova variabile d'ambiente
    api_key = os.getenv('RAPIDAPI_KEY')

    if not api_key:
        # Prova a caricare da .env file
        env_file = Path(__file__).parent / '.env'
        if env_file.exists():
            try:
                from dotenv import load_dotenv
                load_dotenv(env_file)
                api_key = os.getenv('RAPIDAPI_KEY')
            except ImportError:
                pass

    if not api_key:
        print("❌ RAPIDAPI_KEY non trovata!")
        print("\n📝 Setup richiesto:")
        print("   1. Ottieni API key da: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb")
        print("   2. Crea file scripts/.env con:")
        print("      RAPIDAPI_KEY=your_api_key_here")
        print("\n   Oppure esporta variabile d'ambiente:")
        print("      export RAPIDAPI_KEY=your_api_key_here")
        sys.exit(1)

    return api_key


def download_exercises(api_key, limit=None, offset=0):
    """Scarica esercizi da RapidAPI ExerciseDB"""
    url = f"{RAPIDAPI_BASE_URL}/exercises"

    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": RAPIDAPI_HOST
    }

    params = {
        "limit": limit or EXERCISES_LIMIT,
        "offset": offset
    }

    print(f"📥 Scaricamento esercizi (offset: {offset}, limit: {limit or EXERCISES_LIMIT})...", end=" ", flush=True)

    try:
        response = requests.get(url, headers=headers, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        print(f"✅ ({len(data)} esercizi)")
        return data
    except requests.RequestException as e:
        print(f"❌ Errore: {e}")
        return None


def download_exercise_by_id(api_key, exercise_id):
    """Scarica singolo esercizio per ID"""
    url = f"{RAPIDAPI_BASE_URL}/exercises/exercise/{exercise_id}"

    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": RAPIDAPI_HOST
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException:
        return None


def get_all_exercises(api_key):
    """Scarica tutti gli esercizi con paginazione"""
    all_exercises = []
    offset = 0

    print("🏋️  GymBro - ExerciseDB RapidAPI Downloader")
    print("=" * 60)
    print(f"🔑 API Key: {api_key[:10]}...{api_key[-10:]}")
    print(f"🌐 Endpoint: {RAPIDAPI_BASE_URL}")
    print("=" * 60)

    while offset < EXERCISES_LIMIT:
        exercises = download_exercises(api_key, limit=OFFSET_STEP, offset=offset)

        if not exercises or len(exercises) == 0:
            print("✅ Download completato (nessun altro esercizio)")
            break

        all_exercises.extend(exercises)
        offset += OFFSET_STEP

        # Progress
        print(f"   📊 Totale scaricati finora: {len(all_exercises)}")

        # Rate limiting (evita ban)
        if len(exercises) == OFFSET_STEP:
            time.sleep(0.5)  # Pausa tra richieste
        else:
            # Ultima pagina (meno esercizi del limite)
            break

    return all_exercises


def get_bodypart_list(api_key):
    """Ottieni lista body parts disponibili"""
    url = f"{RAPIDAPI_BASE_URL}/exercises/bodyPartList"
    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": RAPIDAPI_HOST
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException:
        return []


def get_equipment_list(api_key):
    """Ottieni lista equipment disponibili"""
    url = f"{RAPIDAPI_BASE_URL}/exercises/equipmentList"
    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": RAPIDAPI_HOST
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException:
        return []


def get_target_list(api_key):
    """Ottieni lista muscoli target disponibili"""
    url = f"{RAPIDAPI_BASE_URL}/exercises/targetList"
    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": RAPIDAPI_HOST
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException:
        return []


def backup_current_exercises():
    """Crea backup del file exercises.json attuale"""
    current_file = Path(__file__).parent.parent / "assets" / "data" / "exercises.json"

    if not current_file.exists():
        print("⚠️  Nessun file exercises.json esistente da backuppare")
        return None

    # Crea directory backup
    BACKUP_DIR.mkdir(exist_ok=True)

    # Nome backup con timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_backup_rapidapi_migration_{timestamp}.json"

    # Copia file
    import shutil
    shutil.copy2(current_file, backup_file)

    file_size_mb = backup_file.stat().st_size / (1024 * 1024)
    print(f"\n💾 Backup creato:")
    print(f"   📁 {backup_file}")
    print(f"   📦 Dimensione: {file_size_mb:.2f} MB")

    return backup_file


def save_exercises(exercises, metadata=None):
    """Salva esercizi in formato JSON"""
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Prepara dati con metadata
    output_data = {
        "metadata": {
            "source": "ExerciseDB RapidAPI",
            "api_endpoint": RAPIDAPI_BASE_URL,
            "download_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "total_exercises": len(exercises),
            **(metadata or {})
        },
        "exercises": exercises
    }

    # Salva JSON
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)

    print("\n" + "=" * 60)
    print(f"✅ Download completato!")
    print(f"📊 Esercizi scaricati: {len(exercises)}")
    print(f"💾 File salvato: {OUTPUT_FILE}")
    print(f"📦 Dimensione: {file_size_mb:.2f} MB")


def analyze_data(exercises):
    """Analizza dati scaricati"""
    if not exercises:
        return

    print("\n📊 Statistiche esercizi:")

    # Body parts
    body_parts = set()
    for ex in exercises:
        if 'bodyPart' in ex:
            body_parts.add(ex['bodyPart'])

    # Equipment
    equipments = set()
    for ex in exercises:
        if 'equipment' in ex:
            equipments.add(ex['equipment'])

    # Target muscles
    targets = set()
    for ex in exercises:
        if 'target' in ex:
            targets.add(ex['target'])

    # Con GIF
    with_gif = sum(1 for ex in exercises if ex.get('gifUrl'))

    print(f"   Body parts unici: {len(body_parts)}")
    print(f"   Equipment unici: {len(equipments)}")
    print(f"   Target muscles unici: {len(targets)}")
    print(f"   Con GIF: {with_gif}/{len(exercises)} ({with_gif/len(exercises)*100:.1f}%)")

    # Top 5 body parts
    if body_parts:
        print(f"\n   Top Body Parts: {', '.join(sorted(list(body_parts))[:5])}")

    # Top 5 equipment
    if equipments:
        print(f"   Top Equipment: {', '.join(sorted(list(equipments))[:5])}")


def main():
    # Ottieni API key
    api_key = get_api_key()

    # Backup file attuale
    print("🔄 Backup del database attuale...")
    backup_current_exercises()

    # Scarica metadata (opzionale, per info)
    print("\n📋 Scaricamento metadata...")
    body_parts = get_bodypart_list(api_key)
    equipments = get_equipment_list(api_key)
    targets = get_target_list(api_key)

    metadata = {
        "body_parts_available": body_parts,
        "equipments_available": equipments,
        "targets_available": targets
    }

    # Scarica tutti gli esercizi
    print("\n📥 Scaricamento esercizi...")
    exercises = get_all_exercises(api_key)

    if not exercises:
        print("\n❌ Nessun esercizio scaricato!")
        sys.exit(1)

    # Salva
    save_exercises(exercises, metadata)

    # Analizza
    analyze_data(exercises)

    print("\n✨ Pronto per la conversione!")
    print(f"   Prossimo step: python3 scripts/convert_exercisedb_to_gymbro.py")
    print("\n⚠️  NOTA: Il converter potrebbe richiedere modifiche per il nuovo formato RapidAPI")


if __name__ == "__main__":
    main()
