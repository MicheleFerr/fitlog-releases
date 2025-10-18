#!/usr/bin/env python3
"""
Script per fare backup della collezione esercizi da Firestore
Esporta tutti i documenti in formato JSON con timestamp
"""

import json
import sys
import time
from pathlib import Path
from datetime import datetime

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ Firebase Admin SDK non installato!")
    print("   Installa con: pip3 install firebase-admin")
    sys.exit(1)

# Configurazione
SCRIPT_DIR = Path(__file__).parent
SERVICE_ACCOUNT_KEY = SCRIPT_DIR / "service-account-key.json"
BACKUP_DIR = SCRIPT_DIR / "backups"
COLLECTION_NAME = "esercizi"


def initialize_firebase():
    """Inizializza Firebase Admin SDK"""
    if not SERVICE_ACCOUNT_KEY.exists():
        print(f"❌ File credenziali non trovato: {SERVICE_ACCOUNT_KEY}")
        print("   Assicurati che service-account-key.json sia nella cartella scripts/")
        return None

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(str(SERVICE_ACCOUNT_KEY))
            firebase_admin.initialize_app(cred)

        return firestore.client()
    except Exception as e:
        print(f"❌ Errore inizializzazione Firebase: {e}")
        return None


def backup_collection(db):
    """Esporta collezione esercizi da Firestore"""
    print(f"\n📦 Backup collezione '{COLLECTION_NAME}'...")

    try:
        # Ottieni tutti i documenti
        docs = db.collection(COLLECTION_NAME).stream()

        exercises = []
        count = 0

        for doc in docs:
            doc_data = doc.to_dict()
            doc_data['_firestore_id'] = doc.id  # Salva anche l'ID documento
            exercises.append(doc_data)
            count += 1

            if count % 50 == 0:
                print(f"   Esportati {count} documenti...", end="\r", flush=True)

        print(f"   Esportati {count} documenti... ✅")

        return exercises

    except Exception as e:
        print(f"\n❌ Errore durante backup: {e}")
        return None


def save_backup(exercises):
    """Salva backup su file JSON"""
    # Crea directory backup se non esiste
    BACKUP_DIR.mkdir(exist_ok=True)

    # Nome file con timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_backup_{timestamp}.json"

    # Prepara dati con metadata
    backup_data = {
        "metadata": {
            "backup_date": datetime.now().isoformat(),
            "collection": COLLECTION_NAME,
            "total_documents": len(exercises),
            "firebase_project": "gymbro"
        },
        "exercises": exercises
    }

    # Salva JSON
    with open(backup_file, 'w', encoding='utf-8') as f:
        json.dump(backup_data, f, indent=2, ensure_ascii=False)

    # Info file
    file_size_mb = backup_file.stat().st_size / (1024 * 1024)

    print("\n" + "=" * 50)
    print(f"✅ Backup completato!")
    print(f"📊 Documenti esportati: {len(exercises)}")
    print(f"💾 File salvato: {backup_file}")
    print(f"📦 Dimensione: {file_size_mb:.2f} MB")

    return backup_file


def list_existing_backups():
    """Lista backup esistenti"""
    if not BACKUP_DIR.exists():
        return []

    backups = sorted(BACKUP_DIR.glob("exercises_backup_*.json"), reverse=True)
    return backups


def main():
    print("💾 GymBro - Firestore Backup Tool")
    print("=" * 50)

    # Mostra backup esistenti
    existing_backups = list_existing_backups()
    if existing_backups:
        print(f"\n📋 Backup esistenti ({len(existing_backups)}):")
        for backup in existing_backups[:5]:  # Mostra ultimi 5
            file_size_mb = backup.stat().st_size / (1024 * 1024)
            # Estrai timestamp dal nome
            timestamp_str = backup.stem.replace("exercises_backup_", "")
            print(f"   - {backup.name} ({file_size_mb:.2f} MB)")
        if len(existing_backups) > 5:
            print(f"   ... e altri {len(existing_backups) - 5} backup")

    # Conferma
    print("\n⚠️  Stai per creare un nuovo backup.")
    confirm = input("Continuare? (s/N): ").strip().lower()
    if confirm not in ['s', 'si', 'y', 'yes']:
        print("❌ Backup annullato")
        sys.exit(0)

    # Inizializza Firebase
    print("\n🔥 Connessione a Firebase...")
    db = initialize_firebase()
    if not db:
        sys.exit(1)

    print("✅ Connesso a Firestore")

    # Backup
    exercises = backup_collection(db)
    if exercises is None:
        sys.exit(1)

    if len(exercises) == 0:
        print("\n⚠️  Nessun documento trovato nella collezione!")
        confirm = input("Salvare comunque backup vuoto? (s/N): ").strip().lower()
        if confirm not in ['s', 'si', 'y', 'yes']:
            print("❌ Backup annullato")
            sys.exit(0)

    # Salva
    backup_file = save_backup(exercises)

    print("\n✨ Backup completato con successo!")
    print(f"   Per ripristinare: python3 scripts/restore_firestore_exercises.py")


if __name__ == "__main__":
    main()
