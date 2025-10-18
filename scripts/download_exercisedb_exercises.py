#!/usr/bin/env python3
"""
Script per scaricare gli esercizi dal database ExerciseDB API v2
Database open-source con oltre 11.000 esercizi fitness con immagini
API: https://v2.exercisedb.dev/api/v1/exercises
"""

import json
import requests
import time
import sys
from pathlib import Path

# Configurazione
EXERCISEDB_API_BASE = "https://gym-micheleferrs-projects.vercel.app/api/v1"
EXERCISES_ENDPOINT = f"{EXERCISEDB_API_BASE}/exercises"
BYPASS_TOKEN = "gym2025automationbypasssecret012"  # Vercel bypass token
OUTPUT_DIR = Path(__file__).parent / "data"
OUTPUT_FILE = OUTPUT_DIR / "exercisedb_exercises_raw.json"
RETRY_ATTEMPTS = 3
RETRY_DELAY = 2
PAGE_LIMIT = 100  # Esercizi per pagina


def download_all_exercises():
    """Scarica tutti gli esercizi dall'API ExerciseDB con paginazione offset-based"""
    print("🏋️  GymBro - ExerciseDB Exercise Downloader (Personal API)")
    print("=" * 50)

    all_exercises = []
    offset = 0
    page = 1
    total_count = None

    while True:
        # Prepara URL con offset e bypass token
        url = f"{EXERCISES_ENDPOINT}?limit={PAGE_LIMIT}&offset={offset}&x-vercel-protection-bypass={BYPASS_TOKEN}"

        print(f"\n📥 Downloading page {page}...", end=" ", flush=True)

        # Download con retry
        for attempt in range(RETRY_ATTEMPTS):
            try:
                response = requests.get(url, timeout=30)
                response.raise_for_status()
                data = response.json()
                break
            except requests.RequestException as e:
                if attempt < RETRY_ATTEMPTS - 1:
                    print(f"\n⚠️  Retry {attempt + 1}/{RETRY_ATTEMPTS}...", end=" ", flush=True)
                    time.sleep(RETRY_DELAY)
                else:
                    print(f"\n❌ Error downloading page {page}: {e}")
                    return None

        # Verifica successo
        if not data.get('success'):
            print(f"\n❌ API returned error: {data.get('message', 'Unknown error')}")
            break

        # Estrai dati
        results = data.get('data', [])
        if not results:
            print("✅ (No more data)")
            break

        all_exercises.extend(results)

        # Estrai metadata
        metadata = data.get('metadata', {})
        if total_count is None:
            total_count = metadata.get('totalExercises', 0)

        # Info progresso
        downloaded = len(all_exercises)
        progress = (downloaded / total_count * 100) if total_count > 0 else 0
        print(f"✅ ({downloaded}/{total_count} - {progress:.1f}%)")

        # Check se ci sono altre pagine
        next_page = metadata.get('nextPage')
        if not next_page or len(results) < PAGE_LIMIT:
            break

        # Incrementa offset per prossima pagina
        offset += PAGE_LIMIT
        page += 1

        # Rate limiting rispettoso
        time.sleep(0.3)

    return all_exercises, total_count if total_count else len(all_exercises)


def save_exercises(exercises, total_count):
    """Salva gli esercizi in formato JSON"""
    # Crea directory se non esiste
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Prepara dati con metadata
    output_data = {
        "metadata": {
            "source": "ExerciseDB Personal API (Vercel)",
            "endpoint": EXERCISEDB_API_BASE,
            "download_date": time.strftime("%Y-%m-%d %H:%M:%S"),
            "total_exercises": total_count,
            "exercises_downloaded": len(exercises)
        },
        "exercises": exercises
    }

    # Salva JSON
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    # Info file
    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)

    print("\n" + "=" * 50)
    print(f"✅ Download completato!")
    print(f"📊 Esercizi scaricati: {len(exercises)}/{total_count}")
    print(f"💾 File salvato: {OUTPUT_FILE}")
    print(f"📦 Dimensione: {file_size_mb:.2f} MB")


def analyze_data(exercises):
    """Analizza i dati scaricati"""
    print("\n📊 Statistiche:")

    # Body parts
    body_parts = set()
    for ex in exercises:
        body_parts.update(ex.get('bodyParts', []))
    print(f"   Body parts: {len(body_parts)}")

    # Equipment
    equipments = set()
    for ex in exercises:
        equipments.update(ex.get('equipments', []))
    print(f"   Equipments: {len(equipments)}")

    # Con immagini
    with_images = sum(1 for ex in exercises if ex.get('imageUrl'))
    print(f"   Con immagini: {with_images}/{len(exercises)} ({with_images/len(exercises)*100:.1f}%)")

    # Exercise types
    types = {}
    for ex in exercises:
        ex_type = ex.get('exerciseType', 'Unknown')
        types[ex_type] = types.get(ex_type, 0) + 1
    print(f"\n📋 Tipi esercizi:")
    for ex_type, count in sorted(types.items(), key=lambda x: x[1], reverse=True):
        print(f"   {ex_type}: {count}")


def main():
    # Download
    result = download_all_exercises()
    if result is None:
        sys.exit(1)

    exercises, total_count = result

    if not exercises:
        print("\n❌ Nessun esercizio scaricato!")
        sys.exit(1)

    # Salva
    save_exercises(exercises, total_count)

    # Analizza
    analyze_data(exercises)

    print("\n✨ Pronto per la conversione!")
    print(f"   Prossimo step: python3 scripts/convert_exercisedb_to_gymbro.py")


if __name__ == "__main__":
    main()
