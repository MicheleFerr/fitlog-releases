# Exercise Conversion Scripts

Due script Python per convertire automaticamente i dati degli esercizi dal Google Sheets al formato JSON utilizzato dall'app GymBro TrackLog.

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