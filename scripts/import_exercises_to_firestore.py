#!/usr/bin/env python3
"""
Script per importare esercizi in Firestore con backup automatico e rollback
Legge da assets/data/exercises.json e importa nella collezione 'esercizi'
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
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
BACKUP_DIR = SCRIPT_DIR / "backups"
COLLECTION_NAME = "esercizi"
BATCH_SIZE = 500
AUTO_BACKUP_FILE = None  # Sarà impostato durante il backup automatico


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


def load_exercises_json():
    """Carica esercizi da file JSON"""
    if not EXERCISES_FILE.exists():
        print(f"❌ File esercizi non trovato: {EXERCISES_FILE}")
        print("   Esegui prima: python3 scripts/convert_wger_to_gymbro.py")
        return None

    try:
        with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
            exercises = json.load(f)

        if not isinstance(exercises, list):
            print("❌ Formato file non valido (deve essere un array JSON)")
            return None

        return exercises

    except Exception as e:
        print(f"❌ Errore caricamento file: {e}")
        return None


def create_automatic_backup(db):
    """Crea backup automatico pre-importazione"""
    global AUTO_BACKUP_FILE

    print("\n📦 Backup automatico pre-importazione...")

    try:
        # Ottieni documenti esistenti
        docs = list(db.collection(COLLECTION_NAME).stream())

        if len(docs) == 0:
            print("   Nessun documento da backuppare (collezione vuota) ✅")
            return True

        print(f"   Trovati {len(docs)} documenti da backuppare")

        # Crea directory backup
        BACKUP_DIR.mkdir(exist_ok=True)

        # Nome file con timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = BACKUP_DIR / f"exercises_backup_auto_{timestamp}.json"
        AUTO_BACKUP_FILE = backup_file

        # Prepara dati
        exercises = []
        for doc in docs:
            doc_data = doc.to_dict()
            doc_data['_firestore_id'] = doc.id
            exercises.append(doc_data)

        backup_data = {
            "metadata": {
                "backup_date": datetime.now().isoformat(),
                "backup_type": "automatic_pre_import",
                "collection": COLLECTION_NAME,
                "total_documents": len(exercises)
            },
            "exercises": exercises
        }

        # Salva
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(backup_data, f, indent=2, ensure_ascii=False)

        file_size_mb = backup_file.stat().st_size / (1024 * 1024)
        print(f"   Backup salvato: {backup_file.name} ({file_size_mb:.2f} MB) ✅")

        return True

    except Exception as e:
        print(f"\n❌ Errore durante backup automatico: {e}")
        return False


def delete_collection(db):
    """Cancella tutti i documenti dalla collezione"""
    print(f"\n🗑️  Cancellazione collezione '{COLLECTION_NAME}'...")

    try:
        docs = list(db.collection(COLLECTION_NAME).stream())
        total = len(docs)

        if total == 0:
            print("   Collezione già vuota ✅")
            return True

        print(f"   Trovati {total} documenti da cancellare")

        # Batch delete
        deleted = 0
        batch = db.batch()
        batch_count = 0

        for doc in docs:
            batch.delete(doc.reference)
            batch_count += 1
            deleted += 1

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
        errors = []

        for exercise in exercises:
            # Valida ID
            doc_id = exercise.get('id')
            if not doc_id:
                errors.append(f"Esercizio senza ID: {exercise.get('nome', 'Unknown')}")
                continue

            # Prepara dati (rimuovi campi null se preferisci)
            exercise_data = {k: v for k, v in exercise.items() if v is not None}

            # Aggiungi al batch
            doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
            batch.set(doc_ref, exercise_data)
            batch_count += 1
            imported += 1

            # Commit batch
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

        if errors:
            print(f"\n⚠️  {len(errors)} errori durante importazione:")
            for error in errors[:5]:
                print(f"   - {error}")
            if len(errors) > 5:
                print(f"   ... e altri {len(errors) - 5} errori")

        return True

    except Exception as e:
        print(f"\n❌ Errore durante importazione: {e}")
        return False


def rollback_from_backup(db):
    """Ripristina da backup automatico in caso di errore"""
    global AUTO_BACKUP_FILE

    if not AUTO_BACKUP_FILE or not AUTO_BACKUP_FILE.exists():
        print("\n❌ Backup automatico non disponibile per rollback!")
        return False

    print("\n🔄 Rollback da backup automatico...")

    try:
        # Carica backup
        with open(AUTO_BACKUP_FILE, 'r', encoding='utf-8') as f:
            backup_data = json.load(f)

        exercises = backup_data.get('exercises', [])

        # Cancella collezione corrente
        delete_collection(db)

        # Importa backup
        imported = 0
        batch = db.batch()
        batch_count = 0

        for exercise in exercises:
            exercise_data = {k: v for k, v in exercise.items() if k != '_firestore_id'}
            doc_id = exercise.get('_firestore_id') or exercise.get('id')

            if not doc_id:
                continue

            doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
            batch.set(doc_ref, exercise_data)
            batch_count += 1
            imported += 1

            if batch_count >= BATCH_SIZE:
                batch.commit()
                batch = db.batch()
                batch_count = 0

        if batch_count > 0:
            batch.commit()

        print(f"✅ Rollback completato: {imported} documenti ripristinati")
        return True

    except Exception as e:
        print(f"❌ Errore durante rollback: {e}")
        return False


def main():
    # Parsing argomenti
    force_mode = '--force' in sys.argv

    print("📥 GymBro - Firestore Import Tool")
    print("=" * 50)

    # Carica esercizi da JSON
    print("\n📖 Caricamento esercizi da JSON...")
    exercises = load_exercises_json()
    if not exercises:
        sys.exit(1)

    print(f"✅ Caricati {len(exercises)} esercizi dal file")

    # Valida dati
    exercises_with_id = sum(1 for ex in exercises if ex.get('id'))
    if exercises_with_id != len(exercises):
        print(f"⚠️  Attenzione: {len(exercises) - exercises_with_id} esercizi senza ID valido")

    # Conferma (skip se --force)
    if not force_mode:
        print("\n" + "=" * 50)
        print("⚠️  ATTENZIONE: Questa operazione è DISTRUTTIVA!")
        print(f"   1. Creerà backup automatico della collezione esistente")
        print(f"   2. Cancellerà TUTTI i documenti in '{COLLECTION_NAME}'")
        print(f"   3. Importerà {len(exercises)} nuovi documenti")
        print("   4. In caso di errore, farà rollback automatico")
        print("=" * 50)

        confirm = input("\nConfermi l'importazione? Digita 'IMPORT' per confermare: ").strip()
        if confirm != 'IMPORT':
            print("❌ Import annullato")
            sys.exit(0)

    # Inizializza Firebase
    print("\n🔥 Connessione a Firebase...")
    db = initialize_firebase()
    if not db:
        sys.exit(1)

    print("✅ Connesso a Firestore")

    # Backup automatico
    if not create_automatic_backup(db):
        print("\n❌ Impossibile procedere senza backup!")
        sys.exit(1)

    # Cancella collezione esistente
    if not delete_collection(db):
        print("\n⚠️  Errore durante cancellazione!")
        if AUTO_BACKUP_FILE:
            print("Rollback in corso...")
            rollback_from_backup(db)
        sys.exit(1)

    # Importa nuovi esercizi
    if not import_exercises(db, exercises):
        print("\n⚠️  Errore durante importazione!")
        print("Rollback in corso...")
        if rollback_from_backup(db):
            print("✅ Dati ripristinati allo stato precedente")
        else:
            print("❌ Rollback fallito! Ripristina manualmente con:")
            print(f"   python3 scripts/restore_firestore_exercises.py")
        sys.exit(1)

    # Successo!
    print("\n" + "=" * 50)
    print("✅ Importazione completata con successo!")
    print(f"📊 Documenti importati: {len(exercises)}")
    if AUTO_BACKUP_FILE:
        print(f"💾 Backup salvato in: {AUTO_BACKUP_FILE.name}")
    print("\n✨ Gli esercizi sono ora disponibili in Firestore!")


if __name__ == "__main__":
    main()
