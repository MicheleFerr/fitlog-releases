#!/usr/bin/env python3
"""
Script per convertire i dati degli esercizi da Google Sheets a JSON
Supporta sia CSV che copia/incolla diretto dai fogli Google
"""

import json
import csv
import sys
import os
from pathlib import Path

def clean_string(value):
    """Pulisce e formatta le stringhe"""
    if not value or value.strip() == '':
        return None
    return value.strip()

def create_exercise_id(nome):
    """Crea un ID univoco dal nome dell'esercizio"""
    if not nome:
        return ""
    
    # Converti in minuscolo e sostituisci spazi con underscore
    exercise_id = nome.lower()
    
    # Sostituzioni specifiche per caratteri italiani
    replacements = {
        'à': 'a', 'á': 'a', 'ä': 'a',
        'è': 'e', 'é': 'e', 'ë': 'e',
        'ì': 'i', 'í': 'i', 'ï': 'i',
        'ò': 'o', 'ó': 'o', 'ö': 'o',
        'ù': 'u', 'ú': 'u', 'ü': 'u',
        ' ': '_',
        '-': '_',
        '/': '_',
        '(': '',
        ')': '',
        '[': '',
        ']': '',
        '"': '',
        "'": '',
        '.': '',
        ',': '',
        ':': '',
        ';': ''
    }
    
    for old, new in replacements.items():
        exercise_id = exercise_id.replace(old, new)
    
    # Rimuovi underscore multipli
    while '__' in exercise_id:
        exercise_id = exercise_id.replace('__', '_')
    
    # Rimuovi underscore all'inizio e alla fine
    exercise_id = exercise_id.strip('_')
    
    return exercise_id

def convert_csv_to_json(csv_file_path, output_path):
    """Converte un file CSV in JSON"""
    exercises = []
    
    with open(csv_file_path, 'r', encoding='utf-8') as file:
        # Prova a determinare il delimitatore
        sample = file.read(1024)
        file.seek(0)
        
        delimiter = ','
        if sample.count(';') > sample.count(','):
            delimiter = ';'
        elif sample.count('\t') > sample.count(','):
            delimiter = '\t'
        
        reader = csv.DictReader(file, delimiter=delimiter)
        
        for row in reader:
            # Salta righe vuote
            if not any(row.values()):
                continue
                
            # Mappa i campi dal CSV al nostro modello
            # Adatta questi nomi di colonna a quelli del tuo Google Sheet
            nome = clean_string(row.get('Nome', ''))
            if not nome:
                continue
                
            exercise = {
                "id": create_exercise_id(nome),
                "nome": nome,
                "focus": clean_string(row.get('Focus', '')),
                "imageUrl": clean_string(row.get('Image URL', row.get('ImageURL', ''))),
                "muscoliSecondari": clean_string(row.get('Muscoli Secondari', '')),
                "difficolta": clean_string(row.get('Difficolta', row.get('Difficoltà', 'Intermedio'))),
                "tipoEsercizio": clean_string(row.get('Tipo Esercizio', 'Isolamento')),
                "attrezzatura": clean_string(row.get('Attrezzatura', 'Vario')),
                "patternMovimento": clean_string(row.get('Pattern Movimento', 'Vario')),
                "rangeRipetizioni": clean_string(row.get('Range Ripetizioni', '8-15')),
                "noteTecniche": clean_string(row.get('Note Tecniche', '')),
                "mobilitaPre": clean_string(row.get('Mobilita Pre', row.get('Mobilità Pre', ''))),
                "attivazionePre": clean_string(row.get('Attivazione Pre', '')),
                "warmupSets": clean_string(row.get('Warmup Sets', '')),
                "tempoWarmup": clean_string(row.get('Tempo Warmup', '')),
                "drillTecnico": clean_string(row.get('Drill Tecnico', '')),
                "prevenzioneInfortuni": clean_string(row.get('Prevenzione Infortuni', '')),
                "cooldownConsigliato": clean_string(row.get('Cooldown Consigliato', '')),
                "spiegazioneTermini": clean_string(row.get('Spiegazione Termini', ''))
            }
            
            exercises.append(exercise)
    
    # Salva il JSON
    with open(output_path, 'w', encoding='utf-8') as json_file:
        json.dump(exercises, json_file, indent=2, ensure_ascii=False)
    
    print(f"✅ Convertiti {len(exercises)} esercizi da {csv_file_path} a {output_path}")
    return len(exercises)

def convert_text_to_json(text_input, output_path):
    """Converte testo copiato direttamente da Google Sheets"""
    lines = text_input.strip().split('\n')
    if len(lines) < 2:
        print("❌ Errore: Il testo deve contenere almeno un header e una riga di dati")
        return 0
    
    # Prima riga = header
    headers = [h.strip() for h in lines[0].split('\t')]
    exercises = []
    
    for line in lines[1:]:
        # Salta righe vuote
        if not line.strip():
            continue
            
        values = line.split('\t')
        
        # Crea un dizionario dalla riga
        row = {}
        for i, value in enumerate(values):
            if i < len(headers):
                row[headers[i]] = value.strip() if value else ''
        
        nome = clean_string(row.get('Nome', ''))
        if not nome:
            continue
            
        exercise = {
            "id": create_exercise_id(nome),
            "nome": nome,
            "focus": clean_string(row.get('Focus', '')),
            "imageUrl": clean_string(row.get('Image URL', row.get('ImageURL', ''))),
            "muscoliSecondari": clean_string(row.get('Muscoli Secondari', '')),
            "difficolta": clean_string(row.get('Difficolta', row.get('Difficoltà', 'Intermedio'))),
            "tipoEsercizio": clean_string(row.get('Tipo Esercizio', 'Isolamento')),
            "attrezzatura": clean_string(row.get('Attrezzatura', 'Vario')),
            "patternMovimento": clean_string(row.get('Pattern Movimento', 'Vario')),
            "rangeRipetizioni": clean_string(row.get('Range Ripetizioni', '8-15')),
            "noteTecniche": clean_string(row.get('Note Tecniche', '')),
            "mobilitaPre": clean_string(row.get('Mobilita Pre', row.get('Mobilità Pre', ''))),
            "attivazionePre": clean_string(row.get('Attivazione Pre', '')),
            "warmupSets": clean_string(row.get('Warmup Sets', '')),
            "tempoWarmup": clean_string(row.get('Tempo Warmup', '')),
            "drillTecnico": clean_string(row.get('Drill Tecnico', '')),
            "prevenzioneInfortuni": clean_string(row.get('Prevenzione Infortuni', '')),
            "cooldownConsigliato": clean_string(row.get('Cooldown Consigliato', '')),
            "spiegazioneTermini": clean_string(row.get('Spiegazione Termini', ''))
        }
        
        exercises.append(exercise)
    
    # Salva il JSON
    with open(output_path, 'w', encoding='utf-8') as json_file:
        json.dump(exercises, json_file, indent=2, ensure_ascii=False)
    
    print(f"✅ Convertiti {len(exercises)} esercizi dal testo a {output_path}")
    return len(exercises)

def main():
    print("🏋️ GymBro Exercise Converter")
    print("=" * 40)
    
    # Percorso di default per il JSON
    default_output = "/Users/michele/gymbro_flutter_new/assets/data/exercises.json"
    
    if len(sys.argv) > 1:
        # Modalità CSV file
        csv_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else default_output
        
        if not os.path.exists(csv_file):
            print(f"❌ Errore: File {csv_file} non trovato")
            return
        
        convert_csv_to_json(csv_file, output_file)
    else:
        # Modalità interattiva
        print("Scegli il metodo di conversione:")
        print("1. File CSV")
        print("2. Copia/incolla da Google Sheets")
        
        choice = input("\nInserisci la tua scelta (1 o 2): ").strip()
        
        if choice == "1":
            csv_file = input("Percorso del file CSV: ").strip()
            if not os.path.exists(csv_file):
                print(f"❌ Errore: File {csv_file} non trovato")
                return
            convert_csv_to_json(csv_file, default_output)
            
        elif choice == "2":
            print("\n📋 Copia i dati da Google Sheets (includi header) e incollali qui.")
            print("Premi Ctrl+D (Mac) o Ctrl+Z (Windows) quando hai finito:\n")
            
            text_data = sys.stdin.read()
            if not text_data.strip():
                print("❌ Nessun dato inserito")
                return
                
            convert_text_to_json(text_data, default_output)
        else:
            print("❌ Scelta non valida")

if __name__ == "__main__":
    main()