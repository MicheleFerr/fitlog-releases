#!/usr/bin/env python3
"""
Script per ripristinare la collezione esercizi in Firestore da backup
Permette di scegliere quale backup ripristinare
"""

import json
import sys
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
BATCH_SIZE = 500  # Limite Firestore per batch operations


def initialize_firebase():
    """Inizializza Firebase Admin SDK"""
    if not SERVICE_ACCOUNT_KEY.exists():
        print(f"❌ File credenziali non trovato: {SERVICE_ACCOUNT_KEY}")
        return None

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(str(SERVICE_ACCOUNT_KEY))
            firebase_admin.initialize_app(cred)

        return firestore.client()
    except Exception as e:
        print(f"❌ Errore inizializzazione Firebase: {e}")
        return None


def list_backups():
    """Lista tutti i backup disponibili"""
    if not BACKUP_DIR.exists():
        return []

    backups = sorted(BACKUP_DIR.glob("exercises_backup_*.json"), reverse=True)
    return backups


def select_backup(backups):
    """Permette all'utente di scegliere un backup"""
    print("\n📋 Backup disponibili:")
    print("=" * 50)

    for i, backup in enumerate(backups, 1):
        file_size_mb = backup.stat().st_size / (1024 * 1024)

        # Estrai timestamp
        timestamp_str = backup.stem.replace("exercises_backup_", "")
        try:
            dt = datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")
            date_str = dt.strftime("%d/%m/%Y %H:%M:%S")
        except:
            date_str = timestamp_str

        # Preview metadata
        try:
            with open(backup, 'r', encoding='utf-8') as f:
                data = json.load(f)
                doc_count = data.get('metadata', {}).get('total_documents', '?')
        except:
            doc_count = '?'

        print(f"{i}. {backup.name}")
        print(f"   Data: {date_str}")
        print(f"   Documenti: {doc_count}")
        print(f"   Dimensione: {file_size_mb:.2f} MB")
        print()

    # Selezione
    while True:
        try:
            choice = input(f"Scegli backup da ripristinare (1-{len(backups)}) o 'q' per uscire: ").strip()

            if choice.lower() == 'q':
                return None

            choice_num = int(choice)
            if 1 <= choice_num <= len(backups):
                return backups[choice_num - 1]

            print(f"⚠️  Scelta non valida. Inserisci un numero tra 1 e {len(backups)}")
        except ValueError:
            print("⚠️  Inserisci un numero valido o 'q' per uscire")


def load_backup(backup_file):
    """Carica backup da file"""
    print(f"\n📖 Caricamento backup...")

    try:
        with open(backup_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        exercises = data.get('exercises', [])
        metadata = data.get('metadata', {})

        print(f"✅ Backup caricato")
        print(f"   Data backup: {metadata.get('backup_date', 'Unknown')}")
        print(f"   Documenti: {len(exercises)}")

        return exercises

    except Exception as e:
        print(f"❌ Errore caricamento backup: {e}")
        return None


def delete_existing_collection(db):
    """Cancella tutti i documenti dalla collezione esistente"""
    print(f"\n🗑️  Cancellazione collezione esistente...")

    try:
        # Conta documenti esistenti
        existing_docs = list(db.collection(COLLECTION_NAME).stream())
        total = len(existing_docs)

        if total == 0:
            print("   Collezione già vuota ✅")
            return True

        print(f"   Trovati {total} documenti da cancellare")

        # Batch delete
        deleted = 0
        batch = db.batch()
        batch_count = 0

        for doc in existing_docs:
            batch.delete(doc.reference)
            batch_count += 1
            deleted += 1

            # Commit batch quando raggiungiamo il limite
            if batch_count >= BATCH_SIZE:
                batch.commit()
                batch = db.batch()
                batch_count = 0
                print(f"   Cancellati {deleted}/{total}...", end="\r", flush=True)

        # Commit ultimo batch
        if batch_count > 0:
            batch.commit()

        print(f"   Cancellati {deleted}/{total}... ✅")
        return True

    except Exception as e:
        print(f"\n❌ Errore durante cancellazione: {e}")
        return False


def import_exercises(db, exercises):
    """Importa esercizi in Firestore"""
    print(f"\n📥 Importazione {len(exercises)} esercizi...")

    try:
        imported = 0
        batch = db.batch()
        batch_count = 0

        for exercise in exercises:
            # Rimuovi campo metadata interno se presente
            exercise_data = {k: v for k, v in exercise.items() if k != '_firestore_id'}

            # Usa ID documento originale o campo 'id'
            doc_id = exercise.get('_firestore_id') or exercise.get('id')
            if not doc_id:
                print(f"\n⚠️  Esercizio senza ID, salto: {exercise.get('nome', 'Unknown')}")
                continue

            # Aggiungi al batch
            doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
            batch.set(doc_ref, exercise_data)
            batch_count += 1
            imported += 1

            # Commit batch quando raggiungiamo il limite
            if batch_count >= BATCH_SIZE:
                batch.commit()
                batch = db.batch()
                batch_count = 0
                progress = (imported / len(exercises)) * 100
                print(f"   Importati {imported}/{len(exercises)} ({progress:.1f}%)...", end="\r", flush=True)

        # Commit ultimo batch
        if batch_count > 0:
            batch.commit()

        print(f"   Importati {imported}/{len(exercises)} (100.0%)... ✅")
        return True

    except Exception as e:
        print(f"\n❌ Errore durante importazione: {e}")
        return False


def main():
    print("🔙 GymBro - Firestore Restore Tool")
    print("=" * 50)

    # Lista backup
    backups = list_backups()

    if not backups:
        print("\n❌ Nessun backup trovato!")
        print(f"   Cartella backup: {BACKUP_DIR}")
        print("   Crea un backup con: python3 scripts/backup_firestore_exercises.py")
        sys.exit(1)

    # Seleziona backup
    selected_backup = select_backup(backups)
    if not selected_backup:
        print("❌ Restore annullato")
        sys.exit(0)

    # Carica backup
    exercises = load_backup(selected_backup)
    if not exercises:
        sys.exit(1)

    # Conferma finale
    print("\n" + "=" * 50)
    print("⚠️  ATTENZIONE: Questa operazione è DISTRUTTIVA!")
    print(f"   - Cancellerà TUTTI i documenti in '{COLLECTION_NAME}'")
    print(f"   - Importerà {len(exercises)} documenti dal backup")
    print("=" * 50)

    confirm = input("\nConfermi il ripristino? Digita 'RESTORE' per confermare: ").strip()
    if confirm != 'RESTORE':
        print("❌ Restore annullato (conferma non valida)")
        sys.exit(0)

    # Inizializza Firebase
    print("\n🔥 Connessione a Firebase...")
    db = initialize_firebase()
    if not db:
        sys.exit(1)

    print("✅ Connesso a Firestore")

    # Cancella collezione esistente
    if not delete_existing_collection(db):
        sys.exit(1)

    # Importa backup
    if not import_exercises(db, exercises):
        print("\n❌ Restore fallito!")
        sys.exit(1)

    # Successo
    print("\n" + "=" * 50)
    print("✅ Restore completato con successo!")
    print(f"📊 Documenti ripristinati: {len(exercises)}")
    print("✨ La collezione è stata ripristinata dal backup")


if __name__ == "__main__":
    main()
