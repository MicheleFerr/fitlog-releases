#!/usr/bin/env python3
"""
Script semplice per fare backup del database esercizi attuale
Salva sia il file JSON locale che i dati da Firestore (se disponibile)
"""

import json
import shutil
from pathlib import Path
from datetime import datetime
import sys

# Percorsi
ASSETS_DIR = Path(__file__).parent.parent / "assets" / "data"
BACKUP_DIR = Path(__file__).parent / "backups"
EXERCISES_FILE = ASSETS_DIR / "exercises.json"


def backup_json_file():
    """Backup del file JSON locale"""
    if not EXERCISES_FILE.exists():
        print(f"⚠️  File non trovato: {EXERCISES_FILE}")
        return None

    # Crea directory backup
    BACKUP_DIR.mkdir(exist_ok=True)

    # Nome backup con timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_backup_{timestamp}.json"

    # Copia file
    shutil.copy2(EXERCISES_FILE, backup_file)

    # Info
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
        num_exercises = len(data) if isinstance(data, list) else 0

    file_size_mb = backup_file.stat().st_size / (1024 * 1024)

    print(f"✅ Backup JSON locale creato:")
    print(f"   📁 {backup_file}")
    print(f"   📊 Esercizi: {num_exercises}")
    print(f"   📦 Dimensione: {file_size_mb:.2f} MB")

    return backup_file


def backup_firestore():
    """Backup da Firestore (opzionale)"""
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore

        # Service account
        service_account_file = Path(__file__).parent / "service-account-key.json"

        if not service_account_file.exists():
            print("⚠️  Service account non trovato, skip backup Firestore")
            return None

        # Inizializza Firebase (se non già fatto)
        if not firebase_admin._apps:
            cred = credentials.Certificate(str(service_account_file))
            firebase_admin.initialize_app(cred)

        db = firestore.client()

        # Scarica tutti i documenti
        print("\n📥 Scaricamento da Firestore...")
        exercises_ref = db.collection('esercizi')
        docs = exercises_ref.stream()

        firestore_exercises = []
        for doc in docs:
            exercise_data = doc.to_dict()
            exercise_data['id'] = doc.id  # Aggiungi ID documento
            firestore_exercises.append(exercise_data)

        # Salva backup
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        firestore_backup_file = BACKUP_DIR / f"firestore_exercises_backup_{timestamp}.json"

        with open(firestore_backup_file, 'w', encoding='utf-8') as f:
            json.dump({
                "metadata": {
                    "source": "Firestore",
                    "collection": "esercizi",
                    "backup_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                    "total_documents": len(firestore_exercises)
                },
                "exercises": firestore_exercises
            }, f, indent=2, ensure_ascii=False)

        file_size_mb = firestore_backup_file.stat().st_size / (1024 * 1024)

        print(f"✅ Backup Firestore creato:")
        print(f"   📁 {firestore_backup_file}")
        print(f"   📊 Documenti: {len(firestore_exercises)}")
        print(f"   📦 Dimensione: {file_size_mb:.2f} MB")

        return firestore_backup_file

    except ImportError:
        print("⚠️  firebase-admin non installato, skip backup Firestore")
        print("   Installa con: pip install firebase-admin")
        return None
    except Exception as e:
        print(f"⚠️  Errore backup Firestore: {e}")
        return None


def list_backups():
    """Lista tutti i backup disponibili"""
    if not BACKUP_DIR.exists():
        print("📂 Nessun backup esistente")
        return []

    backups = sorted(BACKUP_DIR.glob("exercises_backup_*.json"), reverse=True)

    if not backups:
        print("📂 Nessun backup esistente")
        return []

    print(f"\n📋 Backup disponibili ({len(backups)}):")
    for i, backup in enumerate(backups[:10], 1):  # Mostra solo ultimi 10
        file_size_mb = backup.stat().st_size / (1024 * 1024)
        timestamp = backup.stem.replace('exercises_backup_', '')
        print(f"   {i}. {timestamp} - {file_size_mb:.2f} MB")

    return backups


def main():
    print("💾 GymBro - Exercise Database Backup Tool")
    print("=" * 60)

    # Lista backup esistenti
    list_backups()

    # Backup JSON locale
    print("\n🔄 Backup file JSON locale...")
    json_backup = backup_json_file()

    if not json_backup:
        print("\n❌ Backup fallito!")
        sys.exit(1)

    # Backup Firestore (opzionale)
    print("\n🔄 Tentativo backup Firestore...")
    firestore_backup = backup_firestore()

    # Summary
    print("\n" + "=" * 60)
    print("✅ Backup completato!")

    if json_backup:
        print(f"   📁 JSON locale: {json_backup.name}")

    if firestore_backup:
        print(f"   📁 Firestore: {firestore_backup.name}")

    print(f"\n💡 Tutti i backup sono salvati in: {BACKUP_DIR}")
    print("\n🔄 Per ripristinare un backup:")
    print("   1. Copia il file backup in assets/data/exercises.json")
    print("   2. Oppure usa: python3 scripts/restore_firestore_exercises.py")


if __name__ == "__main__":
    main()
