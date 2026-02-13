# Analisi Competitor: Import Workout da Testo/Foto

**Data**: 2026-02-13
**Feature target**: Importa Scheda da Testo/Foto (AI-powered)
**Ricerca**: Market Intelligence per FitLog Pro

---

## 1. Panoramica Competitor

### 1.1 SmartGym - "Import from Text" (Apple Intelligence)

**Come funziona:**
- Usa Apple Foundation Models (on-device LLM) su iOS 26+
- L'utente copia testo da ChatGPT/note/messaggi e lo incolla nell'app
- Il testo viene parsato in routine strutturate con set, rep, rest time
- Se un esercizio non e' nel database SmartGym, viene sostituito con il piu' simile

**Requisiti tecnici:**
- iOS 26+ obbligatorio (esclude iPhone pre-15)
- Apple Intelligence deve essere abilitata
- SmartGym v7.7+
- Solo iOS (niente Android)

**Limitazioni documentate:**
- Ogni routine deve avere un "giorno" esplicito
- Un esercizio per riga, numerato
- Il nome esercizio deve essere esplicito (no "Full Body Workout")
- Non inserire consigli/tips nel testo
- L'inglese e' la lingua piu' accurata
- Evitare range per set/rep/rest (es. "3-4 set" non funziona)
- Se l'esercizio non esiste nel database o l'equipment e' disabilitato, viene sostituito silenziosamente

**Punti deboli:**
- Database esercizi limitato (utenti lamentano che esercizi base mancano)
- Sostituzioni silenziose senza avvertire l'utente
- Solo iOS 26+ esclude la maggioranza degli utenti
- Nessun supporto per foto/immagini
- Formattazione rigida del testo richiesta
- L'utente deve riformattare il testo manualmente se non segue le regole

**Fonti:**
- [SmartGym Knowledge Base - Import from Text](https://help.smartgymapp.com/article/150-import-routine-from-text)
- [9to5Mac - SmartGym Apple Intelligence](https://9to5mac.com/2025/09/15/smart-gym-apple-intelligence-ios-26/)

---

### 1.2 Hevy - HevyGPT + n8n PDF Workflow

**HevyGPT (integrazione ChatGPT):**
- GPT custom che genera workout e li importa via ChatGPT Actions + Hevy API
- L'utente chatta con il GPT, descrive cosa vuole, il GPT crea la routine
- La routine viene pushata direttamente nell'account Hevy
- NON e' un import da testo arbitrario: e' generazione AI guidata

**Limitazioni HevyGPT:**
- Max 4 routine nella versione free (bloccante)
- Non funziona su Android ChatGPT app (solo web)
- Richiede account ChatGPT
- Non importa schede esistenti, ne genera di nuove
- L'utente non puo' incollare un programma dal trainer

**CSV Import:**
- Accetta solo formato Strong CSV
- Un solo import consentito (non ripetibile)
- Nessun supporto per formati custom
- Team non supporta riformattazione file

**n8n + Gemini AI (workflow esterno non ufficiale):**
- Workflow n8n che prende PDF, lo converte in Base64, lo manda a Gemini AI
- Gemini estrae il testo, lo confronta con lista esercizi Hevy API
- Genera JSON strutturato e lo invia a Hevy API
- Setup: ~15 minuti, richiede competenze tecniche
- NON e' una feature dell'app: e' un hack tecnico esterno

**Hevy API:**
- API pubblica documentata (api.hevyapp.com/docs)
- Permette creazione programmatica di routine, esercizi custom, workout
- API Key da Settings > Developer
- 400+ esercizi nel database + esercizi custom illimitati (Pro)

**Punti deboli:**
- Nessun import da testo libero nell'app
- HevyGPT genera, non importa schede esistenti
- CSV import rigido (solo formato Strong)
- La soluzione PDF richiede n8n + setup tecnico
- 4 routine max in free (friction immediata)
- 7 esercizi custom max in free

**Fonti:**
- [HevyGPT Feature Page](https://www.hevyapp.com/features/hevy-gpt/)
- [Hevy CSV Import Tutorial](https://help.hevyapp.com/hc/en-us/articles/35687878672663-Tutorial-Log-Previous-Workouts-and-Import-CSV)
- [n8n PDF to Hevy Workflow](https://n8n.io/workflows/6527-convert-workout-plan-pdfs-to-hevy-app-routines-with-gemini-ai/)
- [Hevy API Docs](https://api.hevyapp.com/docs/)

---

### 1.3 Strong App

**Import/Export:**
- Export CSV: Date, Workout Name, Duration, Exercise Name, Set Order, Weight, Reps, Distance, Seconds, Notes, Workout No
- Export CSV disponibile SOLO per utenti premium
- **NESSUN import CSV o testo**: i file esportati NON possono essere reimportati
- L'app e' "data-in, no-data-back"

**Punti deboli:**
- Zero capacita' di import (ne' testo, ne' CSV, ne' foto)
- Export solo premium (lock-in dei dati)
- UI richiede molti tap per azioni base (lamentele Reddit)
- Nessuna integrazione AI

**Fonti:**
- [Strong Help - Export Data](https://help.strongapp.io/article/235-export-workout-data)
- [Setgraph - Strong Alternatives](https://setgraph.app/articles/best-strong-app-alternatives-(2025))

---

### 1.4 JEFIT

**Import capabilities:**
- NO import da testo libero
- NO import da CSV
- Routine Builder web-based (richiede costruzione manuale)
- Download routine dalla community JEFIT
- Database 1400+ esercizi con video HD

**Punti deboli:**
- Nessuna feature di import automatico
- Costruzione manuale routine obbligatoria
- L'utente deve ricreare tutto da zero se cambia app

**Fonti:**
- [JEFIT Q&A - Import Routine](https://www.jefit.com/q&a/124401794/hodr25/how-to-import-a-routine)

---

### 1.5 Fitbod

**Import capabilities:**
- NO import da testo, CSV, o foto
- L'AI genera automaticamente i workout (modello opposto: zero input utente)
- Integra dati da Apple Health, Fitbit, Strava per recovery
- Non permette di importare programmi personalizzati da trainer

**Punti deboli:**
- Filosofia "l'AI sa meglio" - l'utente non puo' importare il proprio programma
- Nessun modo per seguire un programma specifico dal trainer
- Lock-in algoritmico: se l'AI sbaglia, l'utente non ha alternative

**Fonti:**
- [Fitbod Algorithm](https://fitbod.me/blog/fitbod-algorithm/)
- [Fitbod Workouts](https://fitbod.me/workouts)

---

### 1.6 FitNotes

**Import capabilities:**
- Import CSV da Strong, IronGAINS, HeavySet, FitBod
- Formato CSV specifico richiesto per ogni app sorgente
- L'utente deve specificare le unita' di misura
- Nessun import da testo libero
- Nessun import da foto

**Punti deboli:**
- Solo CSV strutturato (no testo libero)
- Richiede formattazione manuale se il CSV non e' standard
- Nessuna AI per matching esercizi
- Nessun supporto multilingua per nomi esercizi

**Fonti:**
- [FitNotes iOS - Migrate from Other Apps](https://www.getfitnotes.com/docs/migrate-from-other-apps.html)

---

### 1.7 Alpha Progression

**Import capabilities:**
- Import di workout/giorni da altri piani INTERNI all'app
- Export CSV per analisi esterna
- Nessun import da testo libero esterno
- AI coach per generazione programmi
- Condivisione piani con amici/clienti
- 620+ esercizi nel database

**Punti deboli:**
- Import solo tra piani interni (no input esterno)
- Nessun import da testo/foto
- L'AI genera ma non importa

**Fonti:**
- [Alpha Progression](https://alphaprogression.com/en)
- [Fitness Drum Review](https://fitnessdrum.com/alpha-progression-app-review/)

---

### 1.8 MyFitnessPal

**Import capabilities:**
- Export CSV per utenti premium
- Nessun import workout da testo o foto
- Focus su nutrizione, non su weight training
- Barcode scanning per cibo (non per workout)

---

### 1.9 GymBook

**Import capabilities:**
- Informazioni limitate disponibili
- Nessuna feature documentata di import da testo/foto

---

## 2. Tabella Comparativa

| Feature | SmartGym | Hevy | Strong | JEFIT | Fitbod | FitNotes | Alpha Prog | FitLog Pro (target) |
|---------|----------|------|--------|-------|--------|----------|------------|---------------------|
| **Import da testo libero** | Si (iOS 26+) | No (solo HevyGPT genera) | No | No | No | No | No | **Si** |
| **Import da foto/immagine** | No | No | No | No | No | No | No | **Si** |
| **Import CSV** | No | Si (solo formato Strong) | No (solo export) | No | No | Si (multi-formato) | No | Futuro |
| **AI parsing** | Si (Apple on-device) | Si (ChatGPT via GPT custom) | No | No | Si (solo generazione) | No | Si (solo generazione) | **Si (OpenRouter/Llama)** |
| **Matching esercizi** | Sostituzione automatica silenziosa | Via API list + AI | N/A | N/A | N/A | Manuale | Interno | **Fuzzy + conferma utente** |
| **Multilingua** | Inglese migliore | Inglese | N/A | N/A | N/A | No | No | **Si (IT/EN)** |
| **Cross-platform** | Solo iOS | iOS + Android | iOS + Android | iOS + Android | iOS + Android | iOS + Android | iOS + Android | **iOS + Android** |
| **Formato libero (tolleranza)** | Bassa (regole rigide) | N/A | N/A | N/A | N/A | No | N/A | **Alta (AI flexible)** |
| **Costo feature** | Gratis (iOS 26+) | Free limited / Pro | N/A | N/A | Premium | Gratis | Premium | **Free tier incluso** |

---

## 3. Gap Competitivi (Opportunita' FitLog)

### 3.1 NESSUNO FA BENE - Massima opportunita'

| Gap | Dettaglio | Opportunita' FitLog |
|-----|-----------|---------------------|
| **Import da foto** | NESSUN competitor ha import da foto di schede palestra integrate nell'app | First-mover advantage. Foto di schede scritte a mano, PDF screenshot, foto di lavagne palestra |
| **Testo libero vero** | SmartGym richiede formato rigido. Nessun altro accetta testo naturale | Parsing AI flessibile che accetta "Panca 4x8, Squat 3x5 poi addominali" |
| **Multilingua nativo** | SmartGym funziona meglio solo in inglese. Nessuno supporta italiano | "Panca piana 4x10 rec 90s" parsato correttamente in italiano |
| **Conferma interattiva** | SmartGym sostituisce esercizi silenziosamente | UI che mostra anteprima, evidenzia ambiguita', permette correzioni |
| **Cross-platform AI import** | SmartGym = solo iOS 26+, HevyGPT = solo web ChatGPT | Feature nativa nell'app su iOS E Android |

### 3.2 Workflow trainer -> atleta

| Gap | Dettaglio |
|-----|-----------|
| **Il trainer manda WhatsApp/PDF** | Nessuna app permette di importare direttamente una scheda ricevuta via chat |
| **Schede handwritten** | In Italia molti trainer scrivono schede su carta. Nessuna app le digitalizza |
| **Formati italiani** | "4x8 rec 1'30" / "Panca 4 serie da 10" / "Chest press 3x12 + superset lat pulldown 3x10" - nessuno li parsa |

---

## 4. Table Stakes (Must-Have)

Queste feature sono il minimo indispensabile basato sull'analisi competitor:

| Must-Have | Motivazione |
|-----------|-------------|
| **Matching con database esercizi** | SmartGym e Hevy lo fanno. L'utente si aspetta che "Bench Press" venga riconosciuto |
| **Supporto set x rep** | Formato universale "3x10" o "4 serie da 8" |
| **Rest time parsing** | SmartGym include rest time nel parsing |
| **Anteprima prima di salvare** | L'utente deve vedere e confermare il risultato |
| **Possibilita' di edit post-import** | Tutti i competitor permettono modifiche dopo |
| **Fallback manuale** | Se l'AI sbaglia, l'utente deve poter correggere facilmente |

---

## 5. Rischi e Mitigazioni

| Rischio | Impatto | Mitigazione |
|---------|---------|-------------|
| **SmartGym su iOS 26+ gratuito** | Utenti Apple potrebbero preferire soluzione nativa zero-costo | FitLog offre: foto import, multilingua, Android, formato libero - piu' feature |
| **Costi API OpenRouter/Llama** | Ogni parsing ha un costo. Se feature popolare, costi scalano | Limiti per tier (es. 5 import/mese free, illimitati premium) + caching prompt |
| **Accuratezza parsing testo libero** | Testo naturale e' ambiguo. "Panca 4 serie" = panca piana? inclinata? | Step di conferma con suggerimenti, fuzzy match con confidence score |
| **Accuratezza OCR foto** | Foto sfocate, calligrafia illeggibile, illuminazione scarsa | Feedback quality ("foto troppo sfocata"), retry, fallback a input manuale |
| **Esercizi non nel database** | L'utente scrive "Croci ai cavi" ma nel DB e' "Cable Fly" | Matching multilingua + possibilita' creare esercizio custom al volo |
| **Hevy apre API pubblica** | Qualcuno potrebbe costruire import simile per Hevy | Vantaggio: feature nativa nell'app, non workflow esterno |
| **Apple estende Foundation Models ad Android** | Improbabile a breve, ma possibile | Non dipendere da un singolo LLM provider. OpenRouter = multi-model |

---

## 6. Raccomandazioni Strategiche

### 6.1 Posizionamento differenziante

FitLog puo' posizionarsi come **l'unica app che importa schede palestra in qualsiasi formato**:
- Testo libero (italiano e inglese)
- Foto di schede cartacee
- Screenshot di PDF
- Messaggi WhatsApp copiati
- Output di ChatGPT/AI

Nessun competitor copre tutti questi scenari.

### 6.2 Priorita' implementazione

1. **P0 - Testo libero**: Il caso d'uso piu' comune. L'utente copia il messaggio del trainer da WhatsApp e lo incolla
2. **P0 - Anteprima e conferma**: Differenziatore vs SmartGym (che sostituisce silenziosamente)
3. **P1 - Foto/OCR**: Differenziatore unico. Nessun competitor lo ha
4. **P1 - Matching esercizi multilingua**: Vantaggio competitivo nel mercato italiano
5. **P2 - Import da PDF**: Evoluzione naturale dopo foto/OCR

### 6.3 Modello di business

- **Free tier**: 3-5 import/mese (coerente con limiti Hevy free)
- **Premium**: Import illimitati
- **Costi stimati**: ~$0.01-0.05 per parsing con Llama via OpenRouter

### 6.4 UX differenziante

Basandosi sui punti deboli dei competitor:

| Competitor debole in | FitLog forte in |
|----------------------|-----------------|
| SmartGym: sostituzioni silenziose | Anteprima con evidenziazione ambiguita' |
| SmartGym: formato rigido | Testo libero naturale "come lo scrivi" |
| SmartGym: solo inglese accurato | Parsing italiano nativo |
| SmartGym: solo iOS 26+ | Cross-platform |
| Hevy: HevyGPT genera, non importa | Import vero di schede esistenti |
| Hevy: setup tecnico per PDF | Un tap per foto |
| Strong: zero import | Qualsiasi formato |
| Fitbod: l'AI decide per te | L'utente importa IL SUO programma |

---

## 7. Scenario Competitivo Futuro

### Trend osservati:
- Apple sta spingendo Foundation Models on-device (privacy, zero costi API)
- Hevy sta costruendo un ecosistema API-first (possibile apertura a import)
- L'AI nel fitness si concentra su generazione, non su import
- Il gap "import scheda dal trainer" rimane completamente scoperto

### Finestra di opportunita':
- SmartGym ha alzato il livello ma SOLO per iOS 26+ (minoranza utenti)
- Hevy ha le API ma non la feature utente
- Nessuno ha foto import
- Nessuno supporta italiano in modo nativo
- **La finestra e' APERTA per 6-12 mesi** prima che altri copino

---

## 8. Conclusioni

La feature "Importa Scheda da Testo/Foto" rappresenta un **differenziatore competitivo significativo** per FitLog Pro:

1. **Import da foto**: Zero competitor. First-mover advantage reale
2. **Testo libero multilingua**: Solo SmartGym fa qualcosa di simile, ma con limitazioni severe
3. **Il caso d'uso "trainer via WhatsApp"**: Problema reale non risolto da nessuno
4. **Cross-platform**: SmartGym limita a iOS 26+, FitLog copre tutti

Il rischio principale e' il **costo API per parsing** e l'**accuratezza su formati non standard**, entrambi mitigabili con limiti di tier e UI di conferma interattiva.
