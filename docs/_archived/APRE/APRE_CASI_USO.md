# 🎯 APRE SYSTEM - CASI D'USO PRATICI & FLOWCHART

**Data**: 2025-11-06  
**Scopo**: Esemplificare con scenari reali il sistema APRE

---

## 📱 SCENARIO 1: User NUOVO (No History)

```
┌─────────────────────────────────────────────────────────────────┐
│ USER APRE DI BENCH PRESS (primo esercizio)                      │
└─────────────────────────────────────────────────────────────────┘

STEP 1: Seleziona "Auto Adjustment"
  └─ AutoAdjustmentModal opens
     └─ App cerca storico: 0 set trovati ❌
     
STEP 2: Mostra dialog NO HISTORY
  ┌──────────────────────────────────────────────────────┐
  │ ⚠️ Nessuno Storico                                    │
  │                                                        │
  │ Come stimi il tuo 1RM?                               │
  │ ○ Dal mio ultimo workout (best guess)                │
  │ ● Stima personale (conosci il valore)               │
  │ ○ Voglio fare un test                                │
  │                                                        │
  │ Input: [100] kg                                       │
  │                                                        │
  │ Con 1RM 100kg:                                        │
  │ 📌 APRE-3: 92.0 kg (3RM)                             │
  │ 📌 APRE-6: 83.0 kg (6RM)                             │
  │ 📌 APRE-10: 75.0 kg (10RM)                           │
  │                                                        │
  │ ⚠️ Confidence: LOW (dati manuali)                     │
  │ 💡 Aggiorna dopo i primi workout                     │
  │                                                        │
  │ [Annulla] [Salva e Attiva APRE]                      │
  └──────────────────────────────────────────────────────┘
     └─ User inserisce: 100kg
     
STEP 3: Esercizio salvato
  exercise {
    useAPRE: true,
    apreProtocol: 6,
    apreBaseWeight: 83.0,
    calculated1RM: 100.0,
    calculated3RM: 92.0,
    calculated6RM: 83.0,
    calculated10RM: 75.0,
    lastCalculationDate: now,
    calculationMetadata: 'Manual input (Confidence: LOW)',
  }
  
STEP 4: Primo Workout
  Set 1: 41.5kg x 10 reps (warm-up)
  Set 2: 62.25kg x 6 reps (prep)
  Set 3: 83.0kg x ? reps (max effort)
  
  └─ User completa: 83kg x 8 reps
     └─ RPE Selector appare
     └─ APREService.getAdjustment(6, 8)
        └─ Lookup: "8-12 reps" → +5lbs (2.27kg)
     └─ Suggerisce Set 4: 85.5kg
     
STEP 5: Workout finito
  └─ App aggiunge dati a storico
  └─ Metadata aggiornato: 'Based on 1 set'
  └─ Prossimo workout: APRE usa questi nuovi dati
```

---

## 📊 SCENARIO 2: CALCOLO 1RM PROGRESSIVO

```
Timeline dei workout:

WORKOUT 1 (Giorno 1)
├─ Set 3: 83kg x 8 reps
├─ Set 4: 85.5kg x 7 reps
└─ Storico: 1 set registrato

WORKOUT 2 (Giorno 3)
├─ Set 3: 85.5kg x 9 reps (migliorato!)
├─ Set 4: 88.0kg x 8 reps
└─ Storico: 2 set registrati

WORKOUT 3 (Giorno 5)
├─ Set 3: 88.0kg x 7 reps
├─ Set 4: 90.5kg x 6 reps
└─ Storico: 3 set registrati

WORKOUT 4 (Giorno 7)
├─ Set 3: 90.5kg x 10 reps (OTTIMO!)
├─ Set 4: 93.0kg x 9 reps
└─ Storico: 4 set registrati

WORKOUT 5 (Giorno 10)
└─ User apre AutoAdjustmentModal
   └─ App ricacola 1RM da 4 set
      ├─ Stima 1RM Set 1: 100.0 kg
      ├─ Stima 1RM Set 2: 102.0 kg
      ├─ Stima 1RM Set 3: 104.5 kg
      ├─ Stima 1RM Set 4: 103.0 kg
      └─ Media robusta: 102.4 kg (+2.4% vs manual 100kg!)
   
   └─ Nuovi calcoli:
      ├─ calculated1RM: 102.4 kg
      ├─ calculated6RM: 85.0 kg (nuovo baseWeight!)
      └─ Confidence: MEDIUM (4 set, recenti)
      
   └─ Banner di aggiornamento:
      ┌────────────────────────────────────────┐
      │ 📈 1RM Aggiornato!                      │
      │ 100.0kg → 102.4kg (+2.4%)              │
      │ Data calcolo: Giorno 10                │
      │ Confidence: MEDIUM                     │
      └────────────────────────────────────────┘

WORKOUT 6+ (Giorno 15)
└─ Storico: 5+ set
   └─ 1RM si raffina ulteriormente
   └─ Confidence: HIGH (≥7 set)
   └─ I pesi Set 1-4 si adattano automaticamente
```

---

## 🔄 SCENARIO 3: CAMBIO PROTOCOL MID-TRAINING

```
USER HA BENCH PRESS CON PROTOCOL 6 (Hypertrophy)

WORKOUT 1-4: Allena con APRE-6
├─ Set 3: 83kg x ? (target 6)
└─ Set 4: Adjusted
   └─ Se 5-7 reps → peso unchanged
   └─ Se 8-12 reps → +5lbs
   
DECISION: "Voglio focalizzarmi su forza (strength)"
└─ Decide di passare a APRE-3

SCENARIO A: User cambia PRIMA di workout
─────────────────────────────────────
1. AutoAdjustmentModal → Protocol selector
   ┌──────────────────────────────────────┐
   │ APRE Protocol                         │
   │ ○ 3 (Strength, 3min rest)            │
   │ ● 6 (Hypertrophy, 2min rest)        │ ← Attuale
   │ ○ 10 (Endurance, 1min rest)          │
   │                                       │
   │ 📋 Preview cambio:                   │
   │ Set 1: 46.0kg (50%) ← era 41.5kg    │
   │ Set 2: 69.0kg (75%) ← era 62.25kg   │
   │ Set 3: 92.0kg (100%) ← era 83kg     │
   │ Set 4: Adjusted                     │
   │                                       │
   │ ⏱️ Rest Time: 3min (← era 2min)      │
   │                                       │
   │ [Annulla] [Applica cambio]           │
   └──────────────────────────────────────┘
   
2. App aggiorna esercizio
   exercise {
     apreProtocol: 3,  // ← CHANGED
     apreBaseWeight: 92.0,  // ← CHANGED (100% 1RM vs 83%)
     // 1RM rimane lo stesso: calculated1RM: 102.4
   }
   
3. Prossimo workout usa APRE-3

SCENARIO B: User tenta cambio DURANTE workout ❌
──────────────────────────────────────────
1. Set 1-2 completati con Protocol 6
   ├─ Set 1: 41.5kg ✅
   └─ Set 2: 62.25kg ✅
   
2. Accanto cerca di cambiare Protocol
   └─ AutoAdjustmentModal apre
   └─ Seleziona Protocol 3
   
3. WARNING DIALOG appears
   ┌────────────────────────────────────┐
   │ ⚠️ Cambio Protocol                  │
   │                                     │
   │ Non puoi cambiare protocol durante │
   │ il workout in corso.                │
   │                                     │
   │ Opzioni:                           │
   │ 1️⃣ Finisci questo workout          │
   │ 2️⃣ Scarta le modifiche             │
   │ 3️⃣ Crea nuovo esercizio Protocol 3 │
   │                                     │
   │ [Annulla] [Mantieni Protocol 6]    │
   └────────────────────────────────────┘
   
4. User sceglie "Annulla"
   └─ Continua con Protocol 6
   └─ Potrà cambiare dopo workout finito

SCENARIO C: User FORZA cambio (manual)
──────────────────────────────────────
// Se app trovasse bug e user modifica manualmente
exercise.apreProtocol = 3  // Direct assignment (bad!)

PROTEZIONE: Validator in workflow
├─ Quando carica workout
├─ Verifica: exercise.apreProtocol vs ultimi set usati
├─ Se mismatch: show warning + audit log
```

---

## 📈 SCENARIO 4: VISUALIZZAZIONE METADATA 1RM

```
CASO: User apre AutoAdjustmentModal dopo 10 workout

┌─────────────────────────────────────────────────────┐
│ AUTO ADJUSTMENT - BENCH PRESS                        │
└─────────────────────────────────────────────────────┘

📊 ANALISI DEI TUOI DATI
┌──────────────────────────────────────────────────────┐
│ Formula: Brzycki (standard scientifico)            │
│ Set analizzati: 8 / 10 (top 10 per peso)          │
│ Dati da: 12 giorni fa (media)                      │
│ Variabilità: ±2.1kg                                │
│ Affidabilità: HIGH ✅                              │
│  • ≥7 set ✓                                        │
│  • < 14 giorni ✓                                   │
│  • SD ≤ 8% ✓                                       │
└──────────────────────────────────────────────────────┘

📌 RISULTATI
┌──────────────────────────────────────────────────────┐
│ 1RM Stimato: 102.4 kg                              │
│ ├─ 3RM (92%): 94.2 kg                              │
│ ├─ 6RM (83%): 85.0 kg ← APRE Base Weight           │
│ └─ 10RM (75%): 76.8 kg                             │
│                                                     │
│ Ultimi aggiornamenti:                              │
│ ├─ Set 1: 88kg x 10 reps (4 giorni fa)            │
│ ├─ Set 2: 85kg x 9 reps (7 giorni fa)             │
│ ├─ Set 3: 90kg x 8 reps (12 giorni fa)            │
│ └─ ... (altri 5 set)                              │
└──────────────────────────────────────────────────────┘

⚙️ CONFIGURAZIONE APRE
┌──────────────────────────────────────────────────────┐
│ Tipo: APRE                                          │
│ Protocol: 6 (Strength-Hypertrophy)                  │
│ Base Weight: 85.0 kg                                │
│ Rest Time: 2 min (auto-adjust attivo)               │
└──────────────────────────────────────────────────────┘

🎯 AZIONI
┌──────────────────────────────────────────────────────┐
│ [🔄 Ricacola 1RM Adesso] (forza refresh)            │
│ [⚙️ Impostazioni Avanzate] (config dataset)          │
│ [✅ Salva e Chiudi]                                 │
└──────────────────────────────────────────────────────┘

---

⚠️ NOTA: 1RM calcolato 7 giorni fa
   Considera ricacolo se hai fatto nuovi PR.
```

---

## 🚨 SCENARIO 5: EDGE CASES & PROBLEMI GESTITI

### 5A: User non completa Set 3 (fallisce)

```
APRE Lookup richiede "actual reps completati"
Ma se user fallisce Set 3, non c'è Set 4!

Cosa fare?

OPZIONE ATTUALE (?)
└─ Ignora APRE, user modifica manualmente

PROPOSTA
├─ Mostrare messaggio: "Peso troppo pesante"
├─ Suggerire riduzione set 4
│  └─ "Prova con -5kg al prossimo workout"
└─ Registrare fallimento nello storico
   └─ Utile per futuri calcoli confidence
```

### 5B: User registra manualmente set (non durante workout)

```
SCENARIO: User finisce workout, poi manualmente
aggiunge set "ho fatto 5 extra reps"

PROBLEMA: Set non ha reps "target" (solo actual)
└─ APRE lookup: APREService.getAdjustment(protocol, actual)
   └─ Funziona se actual reps sono registrati!

SOLUZIONE
└─ EditSetModal mostra ambo i campi
   ├─ Target reps? [6] (precompilato da protocol)
   └─ Actual reps? [9] (user input)
```

### 5C: User cancella storico intermedio

```
SCENARIO: 10 set registrati
Set 5 è un outlier (errore misurazione)

PROPOSTA: Outlier detection automatico
├─ Check: Estim. 1RM set 5 è 10%+ diverso dagli altri?
├─ Se sì: Flag set come "possibly inaccurate"
└─ User può manuellement escluderlo da calcoli
```

### 5D: App offline, no internet

```
APRE calcolazioni sono offline-first
├─ Storico salvato in Hive (locale)
├─ Calcoli 1RM fatti localmente
└─ Firebase sync quando torni online
   └─ Metadata preservato (calculated1RM, etc.)
```

---

## 📊 FLOWCHART: FLUSSO COMPLETO APRE

```
START: User seleziona esercizio
│
├─► Is APRE enabled globalmente? (config.enableApre)
│   NO → Bypass APRE, use standard workflow
│   YES → Continue
│
├─► Is exercise.useAPRE == true?
│   NO → Bypass APRE per questo esercizio
│   YES → Continue
│
├─► Load exercise.apreProtocol
│   └─ 3, 6, or 10
│
├─► Get APRE Set Structure
│   └─ APREService.getAPRESetStructure(protocol, baseWeight)
│   └─ Sets 1-4 calcolati
│
├─► User completa Set 3
│   └─ actualReps = ?
│
├─► Calculate adjustment
│   └─ APREService.getAdjustment(protocol, actualReps)
│   └─ lookup table matches actualReps range
│
├─► Calculate Set 4 weight
│   └─ APREService.calculateNextWeight(...)
│   └─ suggestedWeight = currentWeight + adjustment
│
├─► Show RpeSelectorBottomSheet
│   ├─ Display: "APRE Suggestion: ${suggestedWeight}kg"
│   └─ User confirms or overrides
│
├─► Save Set 3 & 4 results
│   ├─ Add to exercise history
│   ├─ Store weight for next session
│   └─ Update calculationMetadata if needed
│
├─► Next session (load same exercise)
│   ├─► Is lastCalculationDate < 7 days?
│   │   YES → Reuse cached calculated1RM/3RM/6RM/10RM
│   │   NO → Recalculate from storico
│   │
│   └─► Repeat from "Load exercise.apreProtocol"
│
END
```

---

## 🧪 TEST SCENARIOS

### Test 1: Protocol Selection Boundaries
```
Input: targetReps
├─ 1 reps → Expected: Protocol 3
├─ 5 reps → Expected: Protocol 3
├─ 6 reps → Expected: Protocol 6  ← boundary!
├─ 10 reps → Expected: Protocol 6
├─ 11 reps → Expected: Protocol 10 ← boundary!
└─ 20 reps → Expected: Protocol 10

Assertion: ✓ Correct transitions
```

### Test 2: 1RM Calculation Consistency
```
Given: 5 historical sets with known reps/weight
└─ Set 1: 100kg x 1 rep → est. 1RM: 100.0kg
└─ Set 2: 95kg x 3 reps → est. 1RM: 103.0kg
└─ Set 3: 90kg x 6 reps → est. 1RM: 105.0kg
└─ Set 4: 85kg x 9 reps → est. 1RM: 107.0kg
└─ Set 5: 80kg x 12 reps → est. 1RM: 108.0kg

Expected: Average 1RM ≈ 104.6kg (robust median)
Assertion: ✓ Calculated within ±2kg
```

### Test 3: No History Fallback
```
Given: 0 historical sets
└─ User enters manual 1RM: 100kg
└─ calculateAPREWeights([], protocol: 6, manual: 100)

Expected:
├─ calculated1RM: 100.0kg
├─ calculated6RM: 83.0kg
├─ Confidence: LOW
├─ metadata: contains "Manual input"
└─ requiresManualInput: true

Assertion: ✓ No crash, graceful fallback
```

### Test 4: Protocol Change Validation
```
Given: Workout in progress
│  └─ 2 sets completati con Protocol 6

When: User tenta cambio a Protocol 3

Expected: Exception thrown + warning dialog
Assertion: ✓ Cannot change protocol mid-workout
```

### Test 5: Cache Expiration
```
Given: calculated1RM cached 8 giorni fa
│  └─ lastCalculationDate: now - 8 days

When: Load exercise

Expected:
├─ shouldRecalculate() → true
├─ Ricacola da storico
└─ lastCalculationDate: now (aggiornato)

Assertion: ✓ Cache invalida dopo 7 giorni
```

---

## 🎯 SUMMARY: FRUIBILITÀ IMPROVEMENTS

| Aspetto | Prima | Dopo |
|---------|-------|------|
| **Trasparenza 1RM** | "Confidence: High?" | "Formula: Brzycki, 8 set, ±2.1kg, HIGH ✅" |
| **No History** | Crash/undefined | Modal guidato, input manuale, LOW confidence |
| **Cambio Protocol** | Silent change | Warning, preview pesi, blocco mid-workout |
| **Top 10 Set** | Magic number | Configurable (5/10/20), documented |
| **Data Staleness** | Hidden | Date indicator, banner warning |
| **User Guidance** | Minimal | Tooltip, explanation, preview |
| **Confidence Meaning** | Ambiguous | Specific criteria per level |

---

**Document Status**: ✅ Completato  
**Last Update**: 2025-11-06  
**Examples**: 5 scenari + 5 test + flowchart
