# 📋 EXERCISE CARD SYSTEM OVERVIEW

> **Per**: Product Managers, Designers, Stakeholders, Non-Tech Team Members
>
> **Cosa è**: Guida completa per capire come funzionano le "card" degli esercizi in GymBro

---

## 🎯 Introduzione Rapida

La **card di un esercizio** è la piccola area visuale che mostra:
- 💪 Nome dell'esercizio (es: "Panca Piana")
- 🖼️ Foto/Icona dell'esercizio
- 🏷️ Categoria (Petto, Schiena, Gambe, ecc.)
- 📊 Informazioni aggiuntive (muscoli coinvolti, difficoltà, tempo, ecc.)
- ⚙️ Pulsanti per azioni (modifica, cancella, aggiungi, ecc.)

**Esempio Visuale:**
```
┌─────────────────────────────────────┐
│ 🏋️ PANCA PIANA                      │
│                                     │
│ [Foto esercizio]                    │
│                                     │
│ Categoria: Petto                    │
│ Muscoli: Petto, Spalle, Tricipiti  │
│ Difficoltà: Media                   │
│ Tempo stimato: 45 secondi           │
│                                     │
│ [Modifica] [Cancella] [Aggiungi]   │
└─────────────────────────────────────┘
```

---

## 📱 Dove Trovi le Card degli Esercizi

### 1️⃣ **Schermata Workout in Progress**
- Quando stai facendo un allenamento
- Mostra l'esercizio **corrente** con tutti i dettagli
- Puoi fare clic su "Modifica" per cambiare peso/reps
- Card **grande e prominente**

### 2️⃣ **Lista Esercizi nel Workout**
- Quando stai preparando/costruendo un workout
- Mostra **tutti gli esercizi** in una lista
- Card **più piccole**, disposte verticalmente
- Puoi aggiungere/rimuovere esercizi

### 3️⃣ **Selettore di Esercizi (Bottom Sheet)**
- Quando cerchi un esercizio da aggiungere
- Mostra la **libreria di 500+ esercizi**
- Card **mini** con search/filter
- Ricerca per nome o categoria

### 4️⃣ **Dashboard/Analitiche**
- Card con **statistiche** dell'esercizio
- Volume totale, progressione, PR (Personal Record)
- Card **specializzate** per visualizzare dati

---

## 🔄 Come Funziona il Ciclo di Vita di una Card

### Phase 1: **Creazione**
```
1. Utente seleziona categoria (Petto, Schiena, ecc.)
2. Vede lista di esercizi per quella categoria
3. Seleziona un esercizio dalla lista
4. Card viene creata e aggiunta al workout
```

### Phase 2: **Visualizzazione**
```
1. Card appare nella lista esercizi
2. Mostra:
   - Nome esercizio
   - Immagine/icona
   - Muscoli coinvolti
   - Note dell'esercizio
   - Numero di serie/ripetizioni pianificate
```

### Phase 3: **Modifica**
```
1. Utente fa clic sul pulsante "Modifica" o "Edit"
2. Si apre una schermata di editing
3. Può cambiare:
   - Peso (kg/lbs)
   - Numero di ripetizioni
   - Numero di serie
   - Note personali
   - Tempo di riposo
4. Cambiamenti salvati → card si aggiorna
```

### Phase 4: **Esecuzione**
```
1. Durante il workout, utente seleziona l'esercizio
2. Card diventa **full-screen** e prominente
3. Mostra il timer per il riposo (se configurato)
4. Utente completa la serie → segna come completata
5. Card si aggiorna con check ✅
```

### Phase 5: **Completamento/Archiviazione**
```
1. Workout finito
2. Card viene archiviata nello storico
3. Dati salvati per analytics e progressione
4. Contribuisce alle statistiche personali
```

---

## 🎨 Cosa Puoi Personalizzare nelle Card

### **Informazioni Visibili**
- ✅ Nome esercizio
- ✅ Foto/illustrazione
- ✅ Categoria colore-codificata
- ✅ Muscoli coinvolti (con icone)
- ✅ Livello difficoltà (Principiante, Intermedio, Avanzato)
- ✅ Tempo medio di esecuzione
- ✅ Numero di ripetizioni pianificate
- ✅ Peso/carico pianificato

### **Azioni Disponibili**
- ✅ Modifica esercizio (peso, reps, serie)
- ✅ Elimina esercizio dal workout
- ✅ Duplica esercizio (copia serie precedente)
- ✅ Segna come completato/non completato
- ✅ Aggiungi note personali
- ✅ Visualizza storico (volte che lo hai fatto)

### **Personalizzazioni Avanzate**
- ✅ Timer auto-start tra serie
- ✅ Notifiche sonore
- ✅ Live Activity su iOS (lockscreen)
- ✅ Calcolo automatico peso (APRE)
- ✅ Rest pause / drop set / superset

---

## 💾 Dove Vengono Salvati i Dati della Card

### **Salvataggio Gerarchico:**

```
┌───────────────────────────────────────────┐
│ 1. MEMORIA (App in esecuzione)            │
│    - Card in memoria RAM                  │
│    - Aggiornamenti istantanei            │
└───────────────────────────────────────────┘
            ↓
┌───────────────────────────────────────────┐
│ 2. DISPOSITIVO LOCALE (Hive Database)     │
│    - Salvataggio automatico ogni modifica │
│    - Accessibile offline                  │
│    - Velocissimo                          │
└───────────────────────────────────────────┘
            ↓
┌───────────────────────────────────────────┐
│ 3. CLOUD (Firebase per Premium)           │
│    - Sincronizzazione in background       │
│    - Backupautomatico                     │
│    - Recupero dati da altri dispositivi   │
└───────────────────────────────────────────┘
```

### **Cosa Significa Per l'Utente:**
- ✅ Puoi usare l'app offline
- ✅ I dati si sincronizzano automaticamente
- ✅ Non perdi mai i tuoi esercizi
- ✅ Accesso su iOS e Android

---

## 🔍 Come Vengono Trovati gli Esercizi

### **Metodi di Ricerca**

**1. Per Categoria (Più Comune)**
```
Utente clicca "Aggiungi Esercizio"
  ↓
Vede categorie: Petto, Schiena, Gambe, Spalle, Braccia, Addominali
  ↓
Seleziona "Petto"
  ↓
Vede esercizi per il petto: Panca Piana, Panca Inclinata, Dips, ecc.
```

**2. Per Nome (Ricerca diretta)**
```
Utente digita "Pan" in search bar
  ↓
App mostra: Panca Piana, Panca Inclinata, ecc.
```

**3. Per Muscolo Coinvolto**
```
Utente cerca esercizi che colpiscono il tricipite
  ↓
App suggerisce: Tricep Dips, Tricep Pushdown, French Press, ecc.
```

**4. Dagli Esercizi Recenti**
```
App ricorda ultimi esercizi usati
  ↓
Utente aggiunge di nuovo velocemente (freccia in alto)
```

---

## 🎨 Design e Tema

### **Colori per Categoria**

| Categoria | Colore | Icon |
|-----------|--------|------|
| Petto | 🔴 Rosso | 💪 |
| Schiena | 🔵 Blu | 🏋️ |
| Gambe | 🟣 Viola | 🦵 |
| Spalle | 🟠 Arancione | 💭 |
| Braccia | 🟢 Verde | 💪 |
| Addominali | 🟡 Giallo | 🤸 |

### **Tema Scuro vs Chiaro**
- **Tema Chiaro**: Sfondo bianco, testo nero, colori vivaci
- **Tema Scuro**: Sfondo scuro, testo bianco, colori meno saturi
- **Tema Sistema**: Si adatta automaticamente al tema del telefono

**Utente può scegliere**: Impostazioni → Tema

---

## 📊 Informazioni Tecniche Sugli Esercizi

### **Dati Memorizzati per Ogni Esercizio**

Ogni esercizio ha circa 20 informazioni:

```
📝 Testo:
  - Nome (es: "Panca Piana")
  - Descrizione
  - Note di sicurezza
  - Istruzioni di esecuzione

💪 Fisica:
  - Muscoli primari coinvolti
  - Muscoli secondari
  - Livello difficoltà
  - Tempo medio esecuzione

⚙️ Tecnica:
  - Range di movimento
  - Angolo di esecuzione
  - Tipo di attrezzo (bilanciere, manubri, macchina, etc)
  - Variazioni disponibili

📱 Metadati:
  - Categoria principale
  - Categoria secondaria
  - ID univoco
  - Data creazione/modifica
```

---

## 🚀 Performance e Velocità

### **Come GymBro Mantiene le Card Veloci**

**1. Cache (Memoria Locale)**
- App scarica esercizi al primo avvio
- Li memorizza sul telefono
- Non deve scaricarlo ogni volta
- ✅ Istantaneo

**2. Sincronizzazione Intelligente**
- Sincronizza solo le modifiche
- Non sincronizza tutto ogni volta
- Eseguita in background (non disturba l'utente)
- ✅ Non rallenta l'app

**3. Ottimizzazione UI**
- Card carica solo quando visibile
- Non carica immagini di tutte le card contemporaneamente
- Riduce uso memoria
- ✅ App fluida

**4. Ricerca Ottimizzata**
- Indicizzazione locale
- Ricerca su telefono (non richiede internet)
- Risultati istantanei
- ✅ Niente lag

---

## ❓ FAQ - Domande Frequenti

### **D: Quanti esercizi sono disponibili?**
R: ~500+ esercizi divisi per categoria. Aggiornati regolarmente.

### **D: Posso aggiungere i miei esercizi personali?**
R: In teoria sì (architettura supporta), ma attualmente non è abilitato nell'app. Pianificato per il futuro.

### **D: Cosa succede se perdo internet?**
R: L'app continua a funzionare normalmente. Sincronizza quando torni online.

### **D: Posso usare esercizi su più workout?**
R: Sì! Lo stesso esercizio può essere aggiunto a più workout. Sono indipendenti.

### **D: Come viene calcolato il peso automatico (APRE)?**
R: Sistema intelligente che analizza storico e regola peso in base a come ti senti (RPE - Rate of Perceived Exertion).

### **D: Posso personalizzare le card?**
R: Colori e layout no (design unificato). Ma puoi aggiungere note personali.

### **D: I dati degli esercizi si sincronizzano tra iOS e Android?**
R: Sì, tramite Firebase (per utenti premium).

---

## 🔒 Sicurezza e Privacy

### **Come Sono Protetti i Dati**

✅ **Dati Locali**: Salvati solo sul tuo dispositivo (crittografato)
✅ **Dati Cloud**: Crittografati in transito e a riposo (Firebase)
✅ **Autenticazione**: Solo tu puoi accedere ai tuoi dati
✅ **Niente Tracciamento**: Esercizi sono anonimi
✅ **GDPR Compliant**: Puoi esportare/cancellare i tuoi dati

---

## 🎯 Prossimi Miglioramenti Pianificati

### **In Roadmap:**
- [ ] Esercizi personalizzati custom
- [ ] Foto/video per ogni esercizio
- [ ] Suggerimenti intelligenti di esercizi
- [ ] Variazioni di esercizi automatiche
- [ ] Integrazione con Apple Health
- [ ] Community shared exercises
- [ ] Esercizi vocali (descrizione audio)

---

## 📞 Contatti e Support

Se hai domande su come le card degli esercizi funzionano:

1. **Prima**: Leggi questa documentazione
2. **Poi**: Controlla il file `EXERCISE_CARD_DEVELOPMENT_GUIDE.md` (per team dev)
3. **Infine**: Contatta il team dev se trovi bug

---

**Versione**: 1.0
**Data**: Ottobre 2025
**Autore**: Claude (AI Assistant)
**Target Audience**: Product Managers, Designers, Stakeholders
