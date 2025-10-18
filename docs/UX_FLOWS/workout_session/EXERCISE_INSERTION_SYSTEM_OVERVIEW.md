# 📝 EXERCISE INSERTION SYSTEM OVERVIEW

> **Per**: Product Managers, Designers, Non-Tech Team Members, Stakeholders
>
> **Cosa è**: Guida completa su come gli utenti aggiungono esercizi ai loro allenamenti

---

## 🎯 Introduzione Rapida

L'**esercizio insertion system** è il processo tramite cui un utente aggiunge esercizi al proprio workout. Comprende:

- 💪 Cercare/selezionare esercizi da libreria (500+)
- ⚙️ Configurare serie, ripetizioni, peso
- 🎯 Sceglierne il tipo (normale, superset, drop set, rest-pause)
- 📊 Personalizzare con note e impostazioni
- ✅ Salvare nel workout

**Esempio Visuale:**
```
┌─────────────────────────────────────────┐
│ [+] Aggiungi Esercizio (Fab button)    │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│  MODAL: Inserimento Esercizio           │
├─────────────────────────────────────────┤
│ [Tab Single] [Tab Advanced]             │
├─────────────────────────────────────────┤
│                                         │
│ 🔍 Cerca esercizio...                  │
│    ├─ 💪 Panca Piana                   │
│    ├─ 🎯 Panca Inclinata              │
│    └─ 📍 Dips                          │
│                                         │
│ [Seleziona] → Personalizza → [Aggiungi] │
└─────────────────────────────────────────┘
```

---

## 📱 Flusso Utente Completo

### **Fase 1: Accesso**

L'utente accede al sistema di inserimento tramite:

**Metodo 1: Pulsante Principale**
```
Durante Workout Attivo
    ↓
[+] Pulsante Flottante (FAB)
    ↓
Si apre MODAL "Aggiungi Esercizio"
```

**Metodo 2: Menu Impostazioni**
```
Menù Workout
    ↓
"Personalizza Workout"
    ↓
Lista esercizi con pulsanti "+ Aggiungi"
```

**Metodo 3: Partire da Template**
```
Scegli Template (es: "Upper Body")
    ↓
App pre-popola esercizi dal template
    ↓
Utente può aggiungerne altri
```

---

### **Fase 2: Tipo di Esercizio**

**Opzione 1: Esercizio Singolo (Standard)**
```
┌──────────────────────────┐
│ SINGLE EXERCISE          │
├──────────────────────────┤
│ Cercare esercizio        │
│ ↓                        │
│ Panca Piana              │
│ [Seleziona]              │
└──────────────────────────┘
```

**Opzione 2: Esercizi Avanzati (Advanced Tab)**
```
┌──────────────────────────┐
│ ADVANCED                 │
├──────────────────────────┤
│ [Superset]  [DropSet]    │
│ [RestPause]              │
└──────────────────────────┘
```

---

### **Fase 3: Ricerca e Selezione**

**Come Trovare un Esercizio:**

**Metodo 1: Per Nome**
```
Digita: "panca"
    ↓
Risultati:
    - Panca Piana
    - Panca Inclinata
    - Panca Declinata
```

**Metodo 2: Per Categoria**
```
Filtra categoria: "Petto"
    ↓
Mostra tutti esercizi petto:
    - Panca Piana
    - Dips
    - Croci
    - Macchina Pettorali
    - ecc.
```

**Metodo 3: Per Muscolo Coinvolto**
```
Seleziona: "Tricipiti"
    ↓
Esercizi che colpiscono tricipiti:
    - Tricep Dips
    - Tricep Pushdown
    - French Press
    - Close Grip Bench
```

**Metodo 4: Per Difficoltà**
```
Difficoltà: "Principiante"
    ↓
Solo esercizi facili da fare
```

**Metodo 5: Per Attrezzo**
```
Con Manubri disponibili
    ↓
Mostra solo esercizi con manubri:
    - Curl Manubri
    - Alzate Laterali
    - ecc.
```

---

### **Fase 4: Personalizzazione (Pre-Aggiunta)**

Una volta selezionato l'esercizio, l'utente personalizza:

**Configurazione Serie/Ripetizioni:**

```
┌─────────────────────────────────┐
│ PERSONALIZZA ESERCIZIO          │
├─────────────────────────────────┤
│                                 │
│ Esercizio: Panca Piana          │
│                                 │
│ Serie 1: [95.0 kg] × [10 reps]  │
│ Serie 2: [90.0 kg] × [12 reps]  │
│ Serie 3: [85.0 kg] × [15 reps]  │
│                                 │
│ [+ Aggiungi Serie] [- Rimuovi]  │
│                                 │
│ Note: (Opzionale)               │
│ [Testo libero]                  │
│                                 │
│ [Aggiungi al Workout]           │
└─────────────────────────────────┘
```

**Cosa Può Personalizzare:**

| Elemento | Descrizione | Esempio |
|----------|-------------|---------|
| Peso | Carico da sollevare | 95 kg (o lbs) |
| Ripetizioni | Reps da fare | 10 ripetizioni |
| Serie | Numero di serie | 3 serie totali |
| Tempo Riposo | Secondi tra serie | 120 secondi |
| Note | Appunti personali | "Senti bene la schiena" |
| Warm-up | Marcaturaserie come warm-up | Set 1 è warm-up |

**Suggerimenti Intelligenti:**

```
Quando aggiungi "Panca Piana":
    ↓
App ricorda:
- Ultima volta: 100 kg × 8 reps
- Media ultimamente: 95 kg
    ↓
Suggerisce automaticamente: 95 kg
    ↓
Utente accetta suggerimento
    ✅ Configurazione veloce
```

---

## 🎯 Tipi di Esercizi Avanzati

### **1️⃣ SUPERSET**

**Cosa Sono:** 2+ esercizi fatti **uno dopo l'altro SENZA RIPOSO**

**Esempio:**
```
Giro 1:
├─ Panca Piana (95kg × 10 rep) ✅
├─ [Nessun riposo]
└─ Trazioni (corpo × 8 reps) ✅
    ↓ [Riposo 2 min]

Giro 2:
├─ Panca Piana (95kg × 10 rep) ✅
├─ [Nessun riposo]
└─ Trazioni (corpo × 8 reps) ✅
    ↓ [Riposo 2 min]

Giro 3:
└─ (come sopra)
```

**Vantaggi:**
- ✅ Riduce tempo workout
- ✅ Aumenta volume
- ✅ Anticipa stanchezza muscolare

**Configurazione Superset:**
```
┌──────────────────────────────────────┐
│ AGGIUNGI SUPERSET                    │
├──────────────────────────────────────┤
│                                      │
│ Esercizio 1: [Panca Piana]          │
│ Esercizio 2: [Trazioni]             │
│ Esercizio 3: [+ Aggiungi esercizio] │
│                                      │
│ Numero di Giri: [3]                 │
│ Riposo tra giri: [120 secondi]      │
│                                      │
│ [Aggiungi Superset]                 │
└──────────────────────────────────────┘
```

---

### **2️⃣ DROP SET**

**Cosa Sono:** Una serie che **riduce progressivamente il peso**

**Esempio:**
```
Esecuzione:
├─ 🔴 PESANTE: 100kg × 10 reps
│       (fino al cedimento)
│
├─ [Ridurre peso al 80%]
│
├─ 🟡 MEDIO: 80kg × 12 reps
│       (fino al cedimento)
│
├─ [Ridurre peso al 60%]
│
└─ 🟢 LEGGERO: 60kg × 15 reps
        (fino al cedimento)

✅ Una sola serie = massima fatica
✅ Completa solo quando totalmente esausto
```

**Vantaggi:**
- ✅ Stimolo totale muscolare
- ✅ Una serie molto intensa
- ✅ Meno tempo necessario

**Configurazione Drop Set:**
```
┌────────────────────────────────┐
│ CONFIGURA DROP SET             │
├────────────────────────────────┤
│                                │
│ Esercizio: Panca Piana         │
│                                │
│ Stadio 1 (Pesante):            │
│  └─ 100 kg × 10 reps          │
│                                │
│ Stadio 2 (Medio):              │
│  └─ 80 kg × 12 reps           │
│                                │
│ Stadio 3 (Leggero):            │
│  └─ 60 kg × 15 reps           │
│                                │
│ [+ Aggiungi Stadio]            │
│ [- Rimuovi Stadio]             │
│                                │
│ [Aggiungi Drop Set]            │
└────────────────────────────────┘
```

**Riduzione Automatica:**
App calcola automaticamente:
- 🔴 Pesante = 100% del tuo peso
- 🟡 Medio = 80% del peso pesante
- 🟢 Leggero = 60% del peso pesante

Puoi regolare manualmente se vuoi.

---

### **3️⃣ REST-PAUSE**

**Cosa Sono:** Una serie con **brevi pause** per fare altri reps

**Esempio:**
```
Serie singola, ma divisa:

├─ Fase 1: 100kg × 10 reps
│          (fino al cedimento)
│
├─ [Riposo 15 secondi]
│
├─ Fase 2: 100kg × 4 reps
│          (peso stesso, nuovi reps)
│
├─ [Riposo 15 secondi]
│
└─ Fase 3: 100kg × 2 reps
           (ultima spinta)

✅ Peso fisso, ripetizioni distribuite
✅ Accumulo di volume in una serie
✅ Grande fattore "brucia" muscolare
```

**Vantaggi:**
- ✅ Peso uguale per tutta la serie
- ✅ Facile da configurare
- ✅ Massima bruciatura muscolare

**Configurazione Rest-Pause:**
```
┌────────────────────────────────┐
│ REST-PAUSE                     │
├────────────────────────────────┤
│                                │
│ Esercizio: Curl Bilanciere     │
│                                │
│ Peso: [40 kg]                  │
│ Reps Target: [20 ripetizioni]  │
│ Riposo tra fasi: [15 sec]      │
│ Numero di fasi: [3]            │
│                                │
│ [Aggiungi Rest-Pause]          │
└────────────────────────────────┘
```

---

## 🔧 Impostazioni e Toggle Personalizzazione

### **Impostazione 1: Auto-APRE (Auto-Programmed Resistance Exercise)**

**Che Cosa È:**
App **calcola automaticamente il peso** basandosi su quanto hai sollevato prima.

**Come Funziona:**

```
├─ Primo step: Inserisci peso massimo conosciuto
│  └─ Massimale (1RM): 110 kg
│
├─ Secondo step: Scegli "protocollo"
│  ├─ Protocollo 3RM: Peso per 3 ripetizioni massime
│  ├─ Protocollo 6RM: Peso per 6 ripetizioni massime
│  └─ Protocollo 10RM: Peso per 10 ripetizioni massime
│
└─ Risultato: App calcola peso suggerito
   └─ Es: 100 kg per 3 reps (90% del massimale)
```

**Toggle:** ✅ / ❌ (On/Off)

**Vantaggi:**
- ✅ Non devi ricordare i pesi
- ✅ Sempre progressione intelligente
- ✅ Auto-adattamento al tuo livello

**Quando Utile:**
- Quando non ricordi quanti kg fare
- Quando vuoi seguire protocollo preciso
- Quando vuoi auto-regolazione matematica

---

### **Impostazione 2: RPE (Rate of Perceived Exertion)**

**Che Cosa È:**
**Quanto faticosa è stata la serie** (da 1=molto facile a 10=massimo sforzo)

**Come Usarla:**

```
Dopo aver fatto serie:
    ↓
Inserisci RPE: 7/10
    ↓
Significa: "Potevo fare 3 altre ripetizioni"
    ↓
App adatta peso prossimo set
```

**Range Target:**
```
Scelgo: RPE 7-9
├─ Significa: Sempre tra 7 e 9 di sforzo
├─ Se RPE era 6: Peso aumenta
├─ Se RPE era 9: Peso rimane uguale
└─ Se RPE era 10: Peso diminuisce
```

**Toggle:** ✅ / ❌ (On/Off)

---

### **Impostazione 3: Tempo Riposo Automatico**

**Per Protocollo APRE:**

| Protocollo | Tempo Riposo | Motivo |
|-----------|--------------|--------|
| 3RM (Forza) | 3 minuti | Recupero nervoso completo |
| 6RM (Ipertrofia) | 1.5 minuti | Equilibrio volume-fatica |
| 10RM (Resistenza) | 1 minuto | Mantenere volume alto |

**Utente Può:**
- ✅ Usare tempi predefiniti (Auto)
- ✅ Personalizzare tempi manuali
- ✅ Salvare come preset

---

### **Impostazione 4: Unità di Misura**

**Toggle Between:**
- 🇮🇹 Chilogrammi (kg)
- 🇺🇸 Libre (lbs)

**Funzionamento:**
```
Scegli: Libbre (lbs)
    ↓
Inserisci: 220 lbs
    ↓
App Salva: 100 kg (internamente)
    ↓
Visualizza: 220 lbs (interfaccia)
    ↓
Sync: Converte per dispositivo che usa kg
```

---

### **Impostazione 5: Numero di Serie Predefinite**

**Default:** 3 serie

**Personalizzabile:**
```
Ogni volta che aggiungi esercizio:
    ↓
Puoi cambiarequante serie:
├─ 1 serie (per esercizio secondario)
├─ 3 serie (standard)
├─ 4 serie (intenso)
└─ + Aggiungi quante ne vuoi
```

**Salvataggio:**
- Prima volta: Setup manuale
- Prossime volte: Se è un esercizio ricorrente, ricorda il numero

---

## 💾 Salvataggio e Sincronizzazione

### **Dove Vanno i Tuoi Esercizi:**

**Fase 1: Memoria (App Aperta)**
```
Aggiungi esercizio
    ↓
Appare nella lista workout
    ↓
Completamente locale (RAM)
    ↓
Se chiudi l'app: Potrebbe andare perso (se non salvato)
```

**Fase 2: Dispositivo Locale (Hive)**
```
Workout salvato automaticamente ogni 30 sec
    ↓
Memorizzato nel telefono
    ↓
Accessibile anche offline
    ↓
Velocissimo
```

**Fase 3: Cloud (Firebase - Premium)**
```
Al completamento workout:
    ↓
Sincronizza con Firebase (nuvola)
    ↓
Accessibile su iOS/Android
    ↓
Backupautomatico
    ↓
(Solo premium, free users: solo locale)
```

---

## 🎨 Personalizzazione Schermata

### **Toggle Disponibili per UI:**

**1. Mostra/Nascondi Muscoli Coinvolti**
- ✅ Mostra sempre (default)
- ❌ Nascondi per interfaccia pulita

**2. Mostra/Nascondi Difficoltà**
- ✅ Mostra indicatore
- ❌ Nascondi

**3. Mostra/Nascondi Note dell'Esercizio**
- ✅ Mostra descrizione breve
- ❌ Solo nome

**4. Layout della Lista**
- 📊 Grid (2 colonne)
- 📝 Lista (1 colonna, compatta)
- 📋 Dettagliata (1 colonna, tanta info)

**5. Ordinamento**
- 🔄 Per frequenza (più usati primi)
- 📅 Per data (più recenti)
- 🔤 Per nome (A-Z)
- 💪 Per muscolo principale

**6. Filtro Muscoli Automatico**
- Se workout è "Upper Body":
  - Filtra automaticamente esercizi petto/schiena/spalle
  - Nascondi gambe
- Utente può override

**7. Tema Scuro/Chiaro**
- Influenza colori badge categoria
- Sfondo card
- Testi

---

## ❓ FAQ - Domande Frequenti

### **D: Posso creare esercizi personali?**
R: No al momento. La app ha 500+ esercizi. Se manca, può essere segnalato al team (verrà aggiunto).

### **D: Se commetto errore, posso rimuovere esercizio?**
R: Sì! Fai clic sull'esercizio e seleziona "Rimuovi". Se workout è già iniziato, puoi rimuovere dal timer.

### **D: Posso usare stessi esercizi in più workout?**
R: Sì! Stessi esercizio può essere usato ovunque. Sono indipendenti.

### **D: Cosa succede se dimezzi pesi di mezzo?**
R: App supporta decimali. Es: 47.5 kg è valido.

### **D: Posso usare fractional plate tracking?**
R: Sì, inserisci esattamente il peso. Es: 47.5 kg.

### **D: Superset conta come uno o due esercizi?**
R: Entrambi! Viene conteggiato per ogni esercizio nel superset.

### **D: Per Drop Set, mi calcola automaticamente i pesi?**
R: Sì! Di default:
- Stadio 1: 100% del tuo peso
- Stadio 2: 80%
- Stadio 3: 60%
Ma puoi personalizzare.

### **D: Posso salvare le mie configurazioni favorite?**
R: Salva come Template! Crea template "Bench Session" con i tuoi esercizi, e riutilizza ogni volta.

### **D: Se ho APRE abilitato, mi forza a usare il peso suggerito?**
R: No! Suggerisce, ma puoi sempre cambiarlo manualmente.

---

## 🚀 Prossimi Miglioramenti Pianificati

- [ ] Esercizi personalizzati custom (creare esercizi tuoi)
- [ ] Video for each exercise (tutorial)
- [ ] Suggerimenti intelligenti di progressione
- [ ] Variazioni automatiche di esercizi
- [ ] Integrazione Apple Health / Google Fit
- [ ] Esercizi vocali (ascolta descrizione durante workout)
- [ ] Comunità di esercizi condivisi

---

**Versione**: 1.0
**Data**: Ottobre 2025
**Autore**: Claude (AI Assistant)
**Target Audience**: Product Managers, Designers, Non-Tech Team
