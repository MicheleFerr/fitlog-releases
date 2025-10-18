#!/usr/bin/env python3
"""
Script per scaricare gli esercizi dal database wger API
Database open-source di esercizi fitness con supporto multilingua
API: https://wger.de/api/v2/exerciseinfo/
"""

import json
import requests
import time
import sys
from pathlib import Path

# Configurazione
WGER_API_BASE = "https://wger.de/api/v2"
EXERCISEINFO_ENDPOINT = f"{WGER_API_BASE}/exerciseinfo/"
OUTPUT_DIR = Path(__file__).parent / "data"
OUTPUT_FILE = OUTPUT_DIR / "wger_exercises_raw.json"
RETRY_ATTEMPTS = 3
RETRY_DELAY = 2  # secondi


def download_all_exercises():
    """Scarica tutti gli esercizi dall'API wger con paginazione"""
    print("🏋️  GymBro - wger Exercise Downloader")
    print("=" * 50)

    all_exercises = []
    next_url = EXERCISEINFO_ENDPOINT
    page = 1
    total_count = None

    while next_url:
        print(f"\n📥 Downloading page {page}...", end=" ", flush=True)

        # Download con retry
        for attempt in range(RETRY_ATTEMPTS):
            try:
                response = requests.get(next_url, timeout=30)
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

        # Estrai dati
        results = data.get('results', [])
        all_exercises.extend(results)

        # Info progresso
        if total_count is None:
            total_count = data.get('count', 0)

        downloaded = len(all_exercises)
        progress = (downloaded / total_count * 100) if total_count > 0 else 0
        print(f"✅ ({downloaded}/{total_count} - {progress:.1f}%)")

        # Prossima pagina
        next_url = data.get('next')
        page += 1

        # Rate limiting rispettoso
        if next_url:
            time.sleep(0.5)

    return all_exercises, total_count


def save_exercises(exercises, total_count):
    """Salva gli esercizi in formato JSON"""
    # Crea directory se non esiste
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Prepara dati con metadata
    output_data = {
        "metadata": {
            "source": "wger.de API",
            "endpoint": EXERCISEINFO_ENDPOINT,
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


def analyze_languages(exercises):
    """Analizza le lingue disponibili"""
    languages = {}

    for exercise in exercises:
        for translation in exercise.get('exercises', []):
            lang_code = translation.get('language', {}).get('short_name', 'unknown')
            languages[lang_code] = languages.get(lang_code, 0) + 1

    print("\n📚 Lingue disponibili:")
    for lang, count in sorted(languages.items(), key=lambda x: x[1], reverse=True):
        print(f"   {lang}: {count} traduzioni")


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

    # Analizza lingue
    analyze_languages(exercises)

    print("\n✨ Pronto per la conversione!")
    print(f"   Prossimo step: python3 scripts/convert_wger_to_gymbro.py")


if __name__ == "__main__":
    main()
