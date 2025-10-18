# 📝 Guida Traduzione Nomi Esercizi

Sistema per rivedere e correggere manualmente i nomi degli esercizi in italiano.

---

## 🚀 Quick Start

### 1. **Estrai i nomi per revisione**
```bash
python3 scripts/extract_names_for_review.py
```

**Output:**
- `assets/data/exercises_it_nomi.json` - File JSON pulito
- `assets/data/exercises_it_nomi.csv` - File CSV (per Excel/Sheets)

### 2. **Modifica i nomi**
Apri uno dei file creati e correggi i nomi:

**Opzione A: JSON (VSCode, editor testo)**
```json
[
  {
    "id": "barbell_bench_press",
    "nome": "Panca Piana con Bilanciere"  ← Modifica qui
  },
  {
    "id": "barbell_squat",
    "nome": "Squat con Bilanciere"  ← Modifica qui
  }
]
```

**Opzione B: CSV (Excel, Google Sheets)**
```csv
id,nome
barbell_bench_press,"Panca Piana con Bilanciere"  ← Modifica qui
barbell_squat,"Squat con Bilanciere"  ← Modifica qui
```

### 3. **Applica le modifiche**
```bash
python3 scripts/apply_names_from_review.py
```

✅ I nomi corretti vengono applicati a `exercises_it.json`!

---

## 📋 Dettagli File

### `exercises_it_nomi.json`
```json
[
  {"id": "exercise_id", "nome": "Nome Italiano"},
  {"id": "exercise_id", "nome": "Nome Italiano"}
]
```

**Pro:**
- ✅ Facile da editare con VSCode
- ✅ Syntax highlighting
- ✅ Validazione JSON automatica

**Contro:**
- ❌ Attenzione alle virgole (JSON strict)

### `exercises_it_nomi.csv`
```csv
id,nome
exercise_id,Nome Italiano
exercise_id,Nome Italiano
```

**Pro:**
- ✅ Apri con Excel / Google Sheets
- ✅ Filtri, ordinamento, ricerca Excel
- ✅ Più user-friendly per non-developer

**Contro:**
- ❌ Attenzione ai nomi con virgole (usa "")

---

## 🔍 Come Trovare Esercizi da Correggere

### Metodo 1: Cerca pattern in inglese
Nel file JSON/CSV cerca:
- Nomi che iniziano con lettere minuscole
- Parole inglesi non tradotte: "press", "pull", "push"
- Mix italiano/inglese: "Con Bilanciere Press"

### Metodo 2: Usa Excel/Sheets
1. Apri `exercises_it_nomi.csv`
2. Ordina colonna "nome" alfabeticamente
3. Cerca pattern strani o inglesi
4. Correggi direttamente in Excel
5. Salva (mantieni formato CSV!)

### Metodo 3: Script di ricerca (opzionale)
```bash
# Cerca esercizi con parole inglesi
grep -i "press\|pull\|push\|curl" assets/data/exercises_it_nomi.csv
```

---

## ✅ Best Practices Traduzione

### Pattern Italiano Corretto
```
[ESERCIZIO] [VARIANTE] [PRESA] [ATTREZZATURA]
```

**Esempi corretti:**
- ✅ "Distensioni Inclinate Presa Stretta con Bilanciere"
- ✅ "Squat Bulgaro con Manubri"
- ✅ "Rematore a Un Braccio con Manubrio"
- ✅ "Trazioni alla Sbarra Presa Supina"

**Esempi da evitare:**
- ❌ "Con Bilanciere Distensioni Presa Stretta" (ordine sbagliato)
- ❌ "Bench Press con Bilanciere" (inglese)
- ❌ "Panca piana bilanciere" (mancano articoli/preposizioni)

### Linee Guida
1. **Capitalizzazione:** Ogni parola importante inizia con maiuscola
2. **Articoli:** Usa "con", "alla", "ai", "a" appropriatamente
3. **Consistenza:** Usa sempre lo stesso termine (es: "Distensioni" non "Spinta")
4. **Chiarezza:** Nome deve essere comprensibile senza spiegazioni

---

## 🔄 Workflow Completo

### Scenario 1: Correzioni Minori (pochi esercizi)
```bash
# 1. Estrai nomi
python3 scripts/extract_names_for_review.py

# 2. Apri JSON e correggi 5-10 esercizi
code assets/data/exercises_it_nomi.json

# 3. Applica modifiche
python3 scripts/apply_names_from_review.py
```

### Scenario 2: Revisione Massiva (Excel)
```bash
# 1. Estrai nomi
python3 scripts/extract_names_for_review.py

# 2. Apri CSV in Excel/Sheets
open assets/data/exercises_it_nomi.csv

# 3. Usa filtri Excel per trovare problemi:
#    - Filtra nomi che contengono "press"
#    - Filtra nomi che iniziano con minuscola
#    - Ordina e correggi

# 4. Salva CSV (stesso nome!)

# 5. Applica modifiche
python3 scripts/apply_names_from_review.py
```

### Scenario 3: Revisione Collaborativa
```bash
# 1. Estrai nomi
python3 scripts/extract_names_for_review.py

# 2. Upload su Google Sheets
# 3. Condividi con team fitness
# 4. Revisione collaborativa
# 5. Download come CSV: exercises_it_nomi.csv

# 6. Applica modifiche
python3 scripts/apply_names_from_review.py
```

---

## 🛡️ Sicurezza

### Backup Automatico
Ogni volta che esegui `apply_names_from_review.py`:
- ✅ Backup automatico in `scripts/backups/`
- ✅ Formato: `exercises_it_before_names_apply_TIMESTAMP.json`
- ✅ Log modifiche in `scripts/data/names_changes_TIMESTAMP.json`

### Ripristino
Se qualcosa va storto:
```bash
# Trova backup più recente
ls -lt scripts/backups/exercises_it_before_names_apply_*

# Ripristina
cp scripts/backups/exercises_it_before_names_apply_TIMESTAMP.json \
   assets/data/exercises_it.json
```

---

## 📊 Verifica Modifiche

### Dopo aver applicato le modifiche:
```bash
# Conta modifiche applicate
cat scripts/data/names_changes_*.json | python3 -m json.tool | grep "id" | wc -l

# Verifica esercizio specifico
cat assets/data/exercises_it.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
ex = next(e for e in data if e['id'] == 'barbell_bench_press')
print(ex['nome'])
"
```

---

## 🎯 Checklist Revisione

### Prima di applicare:
- [ ] File modificato salvato correttamente
- [ ] CSV mantiene formato (virgole, quotes)
- [ ] JSON valido (no virgole mancanti)
- [ ] Nomi seguono pattern italiano
- [ ] Termini consistenti in tutto il file

### Dopo aver applicato:
- [ ] Numero modifiche atteso (vedi log)
- [ ] Backup creato in `scripts/backups/`
- [ ] `exercises_it.json` aggiornato
- [ ] Test in app: ricerca esercizi funziona

---

## 📁 File Generati

```
assets/data/
├── exercises_it.json              # File principale (MODIFICATO)
├── exercises_it_nomi.json         # Solo nomi (TU MODIFICHI QUESTO)
└── exercises_it_nomi.csv          # CSV alternativo (TU MODIFICHI QUESTO)

scripts/
├── backups/
│   ├── exercises_it_before_names_apply_20251005_120000.json  # Backup
│   └── ...
└── data/
    ├── names_changes_20251005_120000.json  # Log modifiche
    └── ...
```

---

## 🚀 Pro Tips

### 1. **Usa Find & Replace in batch**
```json
// Correggi pattern comuni in VSCode/editor
Find:    "(\w+) Press"
Replace: "Spinta $1"
```

### 2. **Excel Formulas per pattern**
```excel
# Colonna C: Auto-fix ordine (esempio)
=IF(LEFT(B2,3)="Con",
    RIGHT(B2,LEN(B2)-FIND(" ",B2)) & " " & LEFT(B2,FIND(" ",B2)-1),
    B2)
```

### 3. **Ricerca esercizi popolari first**
Concentrati su esercizi base:
- Bench press, squat, deadlift
- Pull up, push up, dip
- Curl, extension, raise
- Row, press, fly

---

## ❓ FAQ

**Q: Posso modificare entrambi JSON e CSV?**
A: Sì, ma lo script usa il file più recente. Modifica solo uno.

**Q: Cosa succede se cancello un esercizio dal file nomi?**
A: Nessun problema, quell'esercizio non verrà modificato.

**Q: Posso aggiungere nuovi esercizi?**
A: No, questo sistema modifica solo nomi esistenti. Per nuovi esercizi usa altri script.

**Q: Gli ID si possono modificare?**
A: NO! Non modificare gli ID, solo la colonna "nome".

---

**🔧 Script disponibili:**
- `extract_names_for_review.py` - Estrae nomi
- `apply_names_from_review.py` - Applica modifiche
- Entrambi con backup e logging automatici

**Buona revisione!** 🎉
