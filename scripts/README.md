# Exercise Management Scripts

Suite completa di script Python per gestire gli esercizi in GymBro TrackLog:
- 🌐 Import da database wger (open-source fitness database)
- 🔥 Gestione Firestore (backup, restore, import)
- 📊 Conversione da Google Sheets (legacy)

---

## 🆕 Sistema ExerciseDB + Firestore (RACCOMANDATO)

### Panoramica
Scarica **11.000+ esercizi** dal database open-source [ExerciseDB](https://exercisedb.dev) con immagini HD, istruzioni dettagliate, e metadati completi, poi importa in Firestore con backup automatico.

### 📦 Setup Iniziale

#### 1. Installa Dipendenze
```bash
pip3 install firebase-admin requests
```

#### 2. Configura Firebase Service Account
Il file `scripts/service-account-key.json` è già presente (vedi template per crearne uno nuovo se necessario).

### 🚀 Workflow Completo

#### Opzione A: Import Completo da ExerciseDB (First Time)
```bash
# 1. Scarica esercizi da ExerciseDB API (~11.000+ esercizi, ~5-10 min)
python3 scripts/download_exercisedb_exercises.py
# Output: scripts/data/exercisedb_exercises_raw.json

# 2. Converti in formato GymBro
python3 scripts/convert_exercisedb_to_gymbro.py
# Output: assets/data/exercises.json

# 3. (Opzionale) Backup manuale Firestore
python3 scripts/backup_firestore_exercises.py
# Output: scripts/backups/exercises_backup_TIMESTAMP.json

# 4. Import in Firestore (backup automatico + rollback in caso errore)
python3 scripts/import_exercises_to_firestore.py
# Richiede conferma con "IMPORT"
```

#### Opzione B: Aggiorna Esercizi Esistenti
```bash
# Re-scarica da ExerciseDB per ottenere aggiornamenti
python3 scripts/download_exercisedb_exercises.py
python3 scripts/convert_exercisedb_to_gymbro.py

# Import (backup automatico incluso)
python3 scripts/import_exercises_to_firestore.py
```

#### Opzione C: Ripristina da Backup
```bash
# Lista e ripristina backup precedenti
python3 scripts/restore_firestore_exercises.py
# Selezione interattiva del backup + conferma con "RESTORE"
```

### 📚 Script Disponibili

#### 1. `download_exercisedb_exercises.py` - Scarica da ExerciseDB API
- ✅ Download completo con paginazione cursor-based
- ✅ Retry automatico su errori
- ✅ Rate limiting rispettoso
- ✅ Salva in `scripts/data/exercisedb_exercises_raw.json`
- ✅ Mostra statistiche body parts, equipment, tipi

```bash
python3 scripts/download_exercisedb_exercises.py
```

#### 2. `convert_exercisedb_to_gymbro.py` - Conversione Formato
- ✅ Mappa campi ExerciseDB → GymBro
- ✅ Nomi in inglese (traduzione italiana futura)
- ✅ Genera ID univoci automaticamente
- ✅ Mapping muscoli, body parts e attrezzatura
- ✅ Statistiche completezza dati (immagini, focus, note)

```bash
python3 scripts/convert_exercisedb_to_gymbro.py
```

**Mapping Principali:**
| ExerciseDB | GymBro |
|------------|--------|
| name | nome |
| bodyParts + targetMuscles | focus (QUAD, GLUT, PETT, ecc.) |
| secondaryMuscles | muscoliSecondari |
| imageUrl | imageUrl |
| equipments | attrezzatura (IT) |
| exerciseType | difficolta + tipoEsercizio |
| instructions/keywords | noteTecniche |

#### 3. `backup_firestore_exercises.py` - Backup Firestore
- ✅ Esporta collezione "esercizi" completa
- ✅ Salva con timestamp in `scripts/backups/`
- ✅ Include metadata (data, conteggio documenti)
- ✅ Lista backup esistenti

```bash
python3 scripts/backup_firestore_exercises.py
```

#### 4. `restore_firestore_exercises.py` - Restore da Backup
- ✅ Lista backup disponibili con preview
- ✅ Selezione interattiva
- ✅ Cancella + ripristina in batch
- ✅ Conferma richiesta ("RESTORE")

```bash
python3 scripts/restore_firestore_exercises.py
```

#### 5. `import_exercises_to_firestore.py` - Import con Sicurezza
- ✅ **Backup automatico** pre-import
- ✅ **Rollback automatico** in caso di errore
- ✅ Batch operations (500 doc/batch) per efficienza
- ✅ Progress tracking con percentuali
- ✅ Conferma interattiva ("IMPORT")
- ✅ Opzione `--force` per skip conferma

```bash
# Con conferma
python3 scripts/import_exercises_to_firestore.py

# Senza conferma (uso in automazioni)
python3 scripts/import_exercises_to_firestore.py --force
```

### 🔒 Sicurezza e Rollback
Tutti gli script firestore implementano meccanismi di sicurezza:
- ✅ Backup automatico prima di operazioni distruttive
- ✅ Rollback automatico su errori
- ✅ Conferme esplicite richieste
- ✅ Backup salvati in `scripts/backups/` (gitignored)

### 📊 Dati ExerciseDB
- **Fonte:** [ExerciseDB.dev](https://exercisedb.dev) - Database open-source
- **Totale esercizi:** **11.000+**
- **Lingue:** EN (traduzione IT da implementare)
- **Contenuti:** Nome, istruzioni dettagliate, muscoli, body parts, attrezzatura, immagini HD/GIF
- **Licenza:** GNU AGPL-3.0 (open-source, uso commerciale OK)

---

## 📊 Sistema Google Sheets (Legacy)

Script per convertire esercizi da Google Sheets (metodo legacy).

## 🚀 Script API (RACCOMANDATO) - `convert_exercises_api.py`

**Connessione diretta a Google Sheets senza download!**

### Setup Iniziale (una sola volta):
1. Scarica le credenziali del service account:
   - Vai su [Google Cloud Console](https://console.cloud.google.com/)
   - Progetto: `gymprogressapp-184bc`
   - IAM & Admin > Service Accounts
   - `gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com`
   - Keys > Add Key > Create new key > JSON
   - Salva come: `scripts/service-account-key.json`

2. Condividi il Google Sheet con il service account:
   - Apri il tuo Google Sheet
   - Share > Add: `gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com`
   - Ruolo: Viewer

### Come Usare:
```bash
# Modalità interattiva (più semplice)
python3 scripts/convert_exercises_api.py

# Modalità diretta
python3 scripts/convert_exercises_api.py "https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID"

# Con foglio specifico
python3 scripts/convert_exercises_api.py "URL_SHEET" "Nome_Foglio"
```

## 📋 Script Offline - `convert_exercises.py`

### Metodo 1: File CSV
1. Esporta il Google Sheet come CSV
2. Esegui: `python3 scripts/convert_exercises.py path/to/file.csv`

### Metodo 2: Copia/Incolla
1. Seleziona tutti i dati nel Google Sheet (incluso header)
2. Copia (Cmd+C)
3. Esegui: `python3 scripts/convert_exercises.py`
4. Scegli opzione 2
5. Incolla i dati e premi Ctrl+D per finire

## Colonne Supportate

Lo script cerca queste colonne nel Google Sheet (nomi non case-sensitive):

- **Nome** - Nome dell'esercizio (OBBLIGATORIO)
- **Focus** - Muscoli primari (es: "QUAD, GLUT")
- **Muscoli Secondari** - Muscoli secondari
- **Difficolta/Difficoltà** - Principiante/Intermedio/Avanzato
- **Tipo Esercizio** - Compound/Isolamento
- **Attrezzatura** - Bilanciere/Manubri/Cavi/Macchina/Vario
- **Pattern Movimento** - Squat Pattern/Lunge Pattern/etc
- **Range Ripetizioni** - es: "8-15", "1-5 (forza)"
- **Image URL/ImageURL** - URL dell'immagine
- **Note Tecniche** - Note tecniche
- **Mobilita Pre/Mobilità Pre** - Esercizi mobilità
- **Attivazione Pre** - Esercizi attivazione
- **Warmup Sets** - Serie di riscaldamento
- **Tempo Warmup** - Tempo riscaldamento
- **Drill Tecnico** - Drill tecnici
- **Prevenzione Infortuni** - Note prevenzione
- **Cooldown Consigliato** - Esercizi cooldown
- **Spiegazione Termini** - Spiegazione terminologia

## Output

Il file JSON viene salvato in: `assets/data/exercises.json`

Lo script:
- ✅ Crea automaticamente ID univoci dagli nomi
- ✅ Pulisce e formatta i dati
- ✅ Gestisce valori vuoti
- ✅ Supporta caratteri speciali italiani
- ✅ Mostra statistiche di conversione

## Esempio d'Uso

```bash
# Conversione interattiva
python3 scripts/convert_exercises.py

# Da file CSV
python3 scripts/convert_exercises.py data.csv

# Specificando output custom
python3 scripts/convert_exercises.py data.csv custom_output.json
```

## Note

- Lo script riconosce automaticamente separatori CSV (`,`, `;`, `\t`)
- I nomi delle colonne sono flessibili (maiuscole/minuscole, spazi)
- Gli ID degli esercizi sono generati automaticamente dal nome
- I dati vuoti vengono convertiti in `null` nel JSON