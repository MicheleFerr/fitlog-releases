#!/usr/bin/env python3
"""
Script avanzato per convertire esercizi direttamente da Google Sheets usando API
Utilizza il service account gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com
"""

import json
import sys
import os
from pathlib import Path
import gspread
from google.oauth2.service_account import Credentials

def clean_string(value):
    """Pulisce e formatta le stringhe"""
    if not value or str(value).strip() == '' or str(value).strip().lower() == 'null':
        return None
    return str(value).strip()

def create_exercise_id(nome):
    """Crea un ID univoco dal nome dell'esercizio"""
    if not nome:
        return ""
    
    exercise_id = nome.lower()
    
    # Sostituzioni per caratteri italiani
    replacements = {
        'à': 'a', 'á': 'a', 'ä': 'a',
        'è': 'e', 'é': 'e', 'ë': 'e',
        'ì': 'i', 'í': 'i', 'ï': 'i',
        'ò': 'o', 'ó': 'o', 'ö': 'o',
        'ù': 'u', 'ú': 'u', 'ü': 'u',
        ' ': '_', '-': '_', '/': '_',
        '(': '', ')': '', '[': '', ']': '',
        '"': '', "'": '', '.': '', ',': '',
        ':': '', ';': ''
    }
    
    for old, new in replacements.items():
        exercise_id = exercise_id.replace(old, new)
    
    # Rimuovi underscore multipli
    while '__' in exercise_id:
        exercise_id = exercise_id.replace('__', '_')
    
    return exercise_id.strip('_')

def setup_google_sheets_api():
    """Configura l'accesso alle Google Sheets API"""
    # Prima controlla se esistono le credenziali
    possible_paths = [
        "/Users/michele/gymbro_flutter_new/scripts/service-account-key.json",
        "/Users/michele/gymbro_flutter_new/service-account-key.json",
        "/Users/michele/.config/gcloud/service-account-key.json",
        "./service-account-key.json"
    ]
    
    credentials_path = None
    for path in possible_paths:
        if os.path.exists(path):
            credentials_path = path
            break
    
    if not credentials_path:
        print("❌ File delle credenziali non trovato!")
        print("📥 Scarica le credenziali del service account da Google Cloud Console:")
        print("   1. Vai su https://console.cloud.google.com/")
        print("   2. Progetto: gymprogressapp-184bc")
        print("   3. IAM & Admin > Service Accounts")
        print("   4. gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com")
        print("   5. Keys > Add Key > Create new key > JSON")
        print("   6. Salva come: scripts/service-account-key.json")
        return None
    
    try:
        # Scopes necessari per Google Sheets
        scopes = [
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/drive'
        ]
        
        credentials = Credentials.from_service_account_file(
            credentials_path, 
            scopes=scopes
        )
        
        client = gspread.authorize(credentials)
        print(f"✅ Connesso alle Google Sheets API usando: {credentials_path}")
        return client
        
    except Exception as e:
        print(f"❌ Errore nell'autenticazione: {e}")
        return None

def extract_sheet_id_from_url(url):
    """Estrae l'ID del sheet dall'URL di Google Sheets"""
    if '/spreadsheets/d/' in url:
        return url.split('/spreadsheets/d/')[1].split('/')[0]
    return url

def download_and_convert_sheet(sheet_url, worksheet_name=None, output_path=None):
    """Scarica e converte un Google Sheet in JSON"""
    
    # Setup API client
    client = setup_google_sheets_api()
    if not client:
        return 0
    
    try:
        # Estrai ID del sheet
        sheet_id = extract_sheet_id_from_url(sheet_url)
        print(f"📊 Connessione al sheet: {sheet_id}")
        
        # Apri il foglio
        spreadsheet = client.open_by_key(sheet_id)
        
        # Seleziona il worksheet
        if worksheet_name:
            worksheet = spreadsheet.worksheet(worksheet_name)
        else:
            worksheet = spreadsheet.sheet1  # Primo foglio
            
        print(f"📋 Caricamento dati da: {worksheet.title}")
        
        # Ottieni tutti i dati
        data = worksheet.get_all_records()
        print(f"📊 Trovate {len(data)} righe di dati")
        
        exercises = []
        
        for row in data:
            # Salta righe vuote - La colonna si chiama 'ESERCIZIO'
            nome = clean_string(row.get('ESERCIZIO', ''))
            if not nome:
                continue
            
            # Mappatura delle colonne del Google Sheet (MAIUSCOLE)
            exercise = {
                "id": create_exercise_id(nome),
                "nome": nome,
                "focus": clean_string(row.get('FOCUS', '')),
                "imageUrl": clean_string(row.get('IMG', '')),
                "muscoliSecondari": clean_string(row.get('MUSCOLI_SECONDARI', '')),
                "difficolta": clean_string(row.get('DIFFICOLTA', 'Intermedio')),
                "tipoEsercizio": clean_string(row.get('TIPO_ESERCIZIO', 'Isolamento')),
                "attrezzatura": clean_string(row.get('ATTREZZATURA', 'Vario')),
                "patternMovimento": clean_string(row.get('PATTERN_MOVIMENTO', 'Vario')),
                "rangeRipetizioni": clean_string(row.get('RANGE_RIPETIZIONI', '8-15')),
                "noteTecniche": clean_string(row.get('NOTE_TECNICHE', '')),
                "mobilitaPre": clean_string(row.get('MOBILITA_PRE', '')),
                "attivazionePre": clean_string(row.get('ATTIVAZIONE_PRE', '')),
                "warmupSets": clean_string(row.get('WARMUP_SETS', '')),
                "tempoWarmup": clean_string(row.get('TEMPO_WARMUP', '')),
                "drillTecnico": clean_string(row.get('DRILL_TECNICO', '')),
                "prevenzioneInfortuni": clean_string(row.get('PREVENZIONE_INFORTUNI', '')),
                "cooldownConsigliato": clean_string(row.get('COOLDOWN_CONSIGLIATO', '')),
                "spiegazioneTermini": clean_string(row.get('SPIEGAZIONE_TERMINI', ''))
            }
            
            exercises.append(exercise)
        
        # Salva il JSON
        if not output_path:
            output_path = "/Users/michele/gymbro_flutter_new/assets/data/exercises.json"
            
        # Assicurati che la directory esista
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as json_file:
            json.dump(exercises, json_file, indent=2, ensure_ascii=False)
        
        print(f"✅ Convertiti {len(exercises)} esercizi da Google Sheets a {output_path}")
        
        # Mostra statistiche
        print("\n📊 Statistiche:")
        print(f"   Total esercizi: {len(exercises)}")
        
        # Raggruppa per difficoltà
        difficolta_stats = {}
        attrezzatura_stats = {}
        
        for ex in exercises:
            diff = ex.get('difficolta', 'N/A')
            attr = ex.get('attrezzatura', 'N/A')
            
            difficolta_stats[diff] = difficolta_stats.get(diff, 0) + 1
            attrezzatura_stats[attr] = attrezzatura_stats.get(attr, 0) + 1
        
        print("   Per difficoltà:")
        for diff, count in sorted(difficolta_stats.items()):
            print(f"     {diff}: {count}")
            
        print("   Per attrezzatura:")
        for attr, count in sorted(attrezzatura_stats.items()):
            print(f"     {attr}: {count}")
        
        return len(exercises)
        
    except gspread.exceptions.SpreadsheetNotFound:
        print("❌ Foglio non trovato. Verifica:")
        print("   1. L'URL del foglio è corretto")
        print("   2. Il foglio è condiviso con: gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com")
        print("   3. Il service account ha permessi di lettura")
        return 0
        
    except Exception as e:
        print(f"❌ Errore durante il download: {e}")
        return 0

def main():
    print("🏋️ GymBro Exercise Converter - Google Sheets API")
    print("=" * 50)
    
    # Installa dipendenze se necessario
    try:
        import gspread
    except ImportError:
        print("📦 Installazione dipendenze...")
        os.system("pip3 install gspread google-auth")
        import gspread
    
    if len(sys.argv) > 1:
        # Modalità da linea di comando
        sheet_url = sys.argv[1]
        worksheet_name = sys.argv[2] if len(sys.argv) > 2 else None
        output_path = sys.argv[3] if len(sys.argv) > 3 else None
        
        download_and_convert_sheet(sheet_url, worksheet_name, output_path)
    else:
        # Modalità interattiva
        print("🔗 Inserisci l'URL del tuo Google Sheet:")
        print("   Esempio: https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit#gid=0")
        sheet_url = input("\nURL del Google Sheet: ").strip()
        
        if not sheet_url:
            print("❌ URL non valido")
            return
        
        print("\n📋 Nome del foglio di lavoro (opzionale, default: primo foglio):")
        worksheet_name = input("Nome worksheet (lascia vuoto per default): ").strip()
        worksheet_name = worksheet_name if worksheet_name else None
        
        download_and_convert_sheet(sheet_url, worksheet_name)

if __name__ == "__main__":
    main()