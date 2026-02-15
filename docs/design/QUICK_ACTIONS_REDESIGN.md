# Quick Actions "+" Button — Redesign

## Stato attuale

Il "+" nella tab bar mostra 6 azioni in griglia 3x2 (overlay custom), tutte ridondanti rispetto ai tab esistenti (Home, Workout, Profile, AI Coach).

## Nuovo design: Overlay + CNPopupMenuButton interno

L'overlay resta come container visivo (sfondo scuro + animazione). Il contenuto interno viene ridisegnato con 3 sezioni. La sezione "Crea/Importa" usa un `CNPopupMenuButton` nativo dentro l'overlay.

### Flusso

1. Tap "+" → overlay si apre (come adesso)
2. Overlay mostra le 3 sezioni ridisegnate
3. Tap su un'azione → overlay si chiude + azione eseguita
4. Tap fuori → overlay si chiude

### Layout overlay

```
┌──────────────────────────────────────────┐
│              (sfondo scuro)              │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  🧠 Basato sulla tua split:       │  │
│  │                                    │  │
│  │  🦵 GAMBE (suggerito)              │  │  SEZIONE 1
│  │  Non le alleni da 5 giorni         │  │  Smart Suggestion
│  │  Template: "Leg Day"               │  │  (card ricca)
│  │           [ INIZIA ]               │  │
│  │                                    │  │
│  │  ┌───────────┐  ┌───────────┐     │  │
│  │  │Da Template│  │  Vuoto    │     │  │
│  │  └───────────┘  └───────────┘     │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ┌─────────────────┐                     │
│  │ 📐 Log Misure ▾ │  ← CNPopupMenu     │  SEZIONE 2
│  └─────────────────┘                     │  (popup nativo)
│                                          │
│  ┌─────────────────────┐                 │
│  │ 📝 Crea Template ▾  │  ← CNPopupMenu │  SEZIONE 3
│  └─────────────────────┘                 │  (popup nativo)
│                                          │
│              ✕ (chiudi)                  │
└──────────────────────────────────────────┘
```

### Sezione 1: Smart Suggestion (card custom nell'overlay)

Card grande con informazioni ricche (recovery %, nome template, giorni dall'ultimo allenamento). Questa e la parte che non poteva stare in un popup nativo e ora ha spazio.

### Sezione 2: Log Misure (CNPopupMenuButton nell'overlay)

Un `CNPopupMenuButton` nativo con label "Log Misure". Tap → popup con misure principali e secondarie:

```
Popup nativo:
┌───────────────────────────┐
│ ⚖️ Peso                    │
│ 📏 Girovita                │
│ 🔢 Grasso Corporeo %       │
├───────────────────────────┤  ← CNPopupMenuDivider
│ 💪 Braccia (dx/sx)         │
│ 🦵 Cosce (dx/sx)           │
│ 📐 Petto                   │
│ 🦴 Fianchi                 │
│ 📐 Spalle                  │
│ + Altre misure...          │
└───────────────────────────┘
```

**Misure principali** (sopra il divider): le 3 che la maggior parte degli utenti traccia.
**Misure secondarie** (sotto il divider): circonferenze specifiche.

Tap su una voce → overlay si chiude → bottom sheet mini con:
- Ultimo valore registrato (precompilato)
- Input numerico
- Bottoni +/- rapidi
- Salva

### Sezione 3: Template (CNPopupMenuButton nell'overlay)

Un `CNPopupMenuButton` nativo con label "Crea Template". Due voci:

```
Popup nativo:
┌───────────────────────────┐
│ ✏️ Crea Manualmente        │
│ 📥 Importa                 │
└───────────────────────────┘
```

- **Crea Manualmente** → naviga al template builder
- **Importa** → naviga all'import flow

### Comportamento al tap

| Elemento | Azione |
|----------|--------|
| **Card "Gambe (suggerito)" → INIZIA** | Chiude overlay → avvia workout con template |
| **"Da Template"** | Chiude overlay → naviga a lista template |
| **"Vuoto"** | Chiude overlay → avvia workout vuoto |
| **Log Misure popup → "Peso"** | Chiude overlay → bottom sheet input peso |
| **Log Misure popup → "Girovita"** | Chiude overlay → bottom sheet input girovita |
| **Log Misure popup → qualsiasi** | Chiude overlay → bottom sheet input per quella misura |
| **Crea Template popup → "Crea Manualmente"** | Chiude overlay → template builder |
| **Crea Template popup → "Importa"** | Chiude overlay → import flow |

---

## Sezione 1: Smart Workout Suggestion (prima voce del menu)

### Label dinamica

La prima voce del popup ha una label che cambia in base al contesto:

| Stato | Label | SF Symbol |
|-------|-------|-----------|
| Pattern rilevato + template | `"Pull Day (suggerito)"` | `figure.strengthtraining.traditional` |
| Pattern rilevato, no template | `"Schiena (suggerito)"` | `figure.strengthtraining.traditional` |
| No pattern, recovery-based | `"Gambe — 6gg fa"` | `figure.strengthtraining.traditional` |
| Squilibrio rilevato | `"Gambe — non le alleni da 8gg"` | `exclamationmark.triangle` |
| Utente nuovo (< 4 workout) | `"Inizia Workout"` | `plus.circle` |

### Algoritmo di suggerimento

#### Step 1: Categoria dominante per workout

Per ogni workout completato (ultimi 21 giorni):
- Conta gli esercizi per `ExerciseCategory`
- La categoria con piu esercizi = categoria dominante
- Esempio: 3 esercizi chest + 1 arms = chest day

#### Step 2: Pattern detection (ciclo)

Sequenza delle categorie dominanti (ordinate per data):
```
[chest, legs, back, shoulders, chest, legs, back, shoulders]
```

Cerca il pattern piu corto che si ripete almeno 2 volte:
- Prova lunghezza 2, poi 3, poi 4, ...fino a max 7
- Tolleranza: 1 mismatch per ciclo (workout fuori rotazione)

Se trovato:
- `detectedCycle = [chest, legs, back, shoulders]`
- `lastCompleted = legs`
- `nextSuggested = back`

Se non trovato: fallback recovery-based.

#### Step 3: Fallback recovery-based

Usa `muscleRecoveryHistoryProvider` (esistente):
- Per ogni categoria, calcola ore dall'ultimo allenamento
- Suggerisci quella piu riposata

#### Step 4: Associa template

Se l'utente ha template la cui categoria dominante corrisponde:
- Usa `bestTemplateProvider` (esistente) per scegliere il migliore
- La label diventa il nome del template: `"Pull Day (suggerito)"`
- Se nessun template corrisponde: label = nome categoria

### Gestione squilibrio muscolare

Se l'utente ignora ripetutamente il suggerimento (es. fa petto 3 volte in una settimana):
- La label evidenzia il muscolo trascurato: `"Gambe — non le alleni da 8gg"`
- Tono informativo, mai bloccante
- L'utente puo comunque scegliere "Da Template" o "Vuoto" per fare altro

### Edge cases

| Caso | Comportamento |
|------|--------------|
| Workout fuori rotazione (es. cardio) | Ignorato nella sequenza del ciclo |
| Skip nella rotazione | Prossimo = workout skippato (indipendente dal giorno) |
| Nessun pattern | Fallback: muscolo piu riposato |
| Utente nuovo (< 4 workout) | Prima voce = "Inizia Workout" generico |
| Cambio programma | Finestra 21gg, nuovo pattern in 1-2 settimane |
| 2 workout stesso giorno | Entrambi contano nella sequenza |
| Sessione mista | Categoria dominante per n. esercizi |

---

## Sezione 2: Log Misure (CNPopupMenuButton)

### Voci del popup

**Misure principali** (sopra il divider):

| Voce | MetricType | SF Symbol |
|------|-----------|-----------|
| Peso | `weight` | `scalemass` |
| Girovita | `waistCircumference` | `ruler` |
| Grasso Corporeo % | `bodyFatPercentage` | `percent` |

**Misure secondarie** (sotto il divider):

| Voce | MetricType | SF Symbol |
|------|-----------|-----------|
| Braccia (dx/sx) | `bicepRightCircumference` / `bicepLeftCircumference` | `figure.arms.open` |
| Cosce (dx/sx) | `thighRightCircumference` / `thighLeftCircumference` | `figure.walk` |
| Petto | `chestCircumference` | `figure.stand` |
| Fianchi | `hipCircumference` | `figure.stand.line.dotted.figure.stand` |
| Spalle | `shoulderCircumference` | `figure.strengthtraining.traditional` |
| Altre misure... | Naviga a measurement list screen | `ellipsis` |

### Bottom sheet input (comune a tutte le misure)

Ogni voce del popup apre lo stesso bottom sheet parametrizzato per quel MetricType:

```
┌──────────────────────────────────┐
│  ⚖️ Peso                         │  ← titolo dinamico
│                                  │
│  Ultimo: 78.5 kg (2 giorni fa)  │  ← ultimo valore
│                                  │
│  ┌──────────────┐               │
│  │   78.3  kg   │               │  ← precompilato
│  └──────────────┘               │
│                                  │
│  [ -0.1 ] [ +0.1 ] [ +0.5 ]    │  ← step basati sul MetricType
│                                  │
│        [ SALVA ]                 │
└──────────────────────────────────┘
```

- Titolo e unita dinamici in base al MetricType
- Step +/- diversi per tipo (peso: 0.1/0.5 kg, circonferenze: 0.5/1 cm)
- Precompilato con ultimo valore registrato
- Per misure bilaterali (braccia, cosce): input dx + sx nella stessa schermata

---

## Sezione 3: Crea Template (CNPopupMenuButton)

### Voci del popup

| Voce | SF Symbol | Destinazione |
|------|-----------|-------------|
| Crea Manualmente | `square.and.pencil` | Template builder (skip lista) |
| Importa | `square.and.arrow.down` | Import flow (workout_import) |

---

## Architettura implementativa

### File da creare

```
lib/features/quick_actions/
├── domain/
│   └── services/
│       └── split_detection_service.dart              # Pattern detection puro
├── presentation/
│   ├── providers/
│   │   └── next_workout_suggestion_provider.dart      # Smart suggestion
│   └── widgets/
│       ├── quick_actions_overlay_content.dart          # Contenuto overlay (3 sezioni)
│       ├── smart_workout_card.dart                    # Sezione 1: card suggerimento
│       ├── log_measurements_popup.dart                # Sezione 2: CNPopupMenuButton misure
│       ├── create_template_popup.dart                 # Sezione 3: CNPopupMenuButton crea/importa
│       └── quick_measurement_input_sheet.dart         # Bottom sheet input misura (generico)
```

### File da modificare

```
lib/core/navigation/main_shell.dart
  - Mantenere: _showQuickActionsOverlay() e animazione overlay
  - Sostituire: contenuto interno dell'overlay con QuickActionsOverlayContent
  - Rimuovere: _QuickAction enum e vecchia griglia 3x2
```

### Dipendenze

```
SplitDetectionService (puro, testabile)
        |
NextWorkoutSuggestionProvider
  ├── SplitDetectionService
  ├── muscleRecoveryHistoryProvider (esistente)
  ├── bestTemplateProvider (esistente)
  └── WorkoutHistoryRepository (esistente)
        |
QuickActionsOverlayContent (contenuto overlay)
  ├── SmartWorkoutCard (Sezione 1 - card ricca Flutter)
  ├── LogMeasurementsPopup (Sezione 2 - CNPopupMenuButton nativo)
  └── CreateTemplatePopup (Sezione 3 - CNPopupMenuButton nativo)
        |
QuickMeasurementInputSheet (bottom sheet generico per qualsiasi MetricType)
```

### Dati esistenti riusati

| Dato | Provider | File |
|------|----------|------|
| Categoria esercizio | `ExerciseCategory` | `exercise.dart` |
| Recovery muscolare | `muscleRecoveryHistoryProvider` | `template_suggestion_provider.dart` |
| Template ottimale | `bestTemplateProvider` | `template_suggestion_provider.dart` |
| Workout completati | `WorkoutHistoryRepository` | `workout_history_repository.dart` |
| Tipi misura | `MetricType` | `metric_type.dart` |
| Misure salvate | `MeasurementRepository` | `body_measurements/` |

### Ordine di implementazione

1. `SplitDetectionService` + test unitari
2. `NextWorkoutSuggestionProvider` (smart suggestion)
3. `SmartWorkoutCard` (card con recovery, template, label dinamica)
4. `LogMeasurementsPopup` (CNPopupMenuButton: principali + divider + secondarie)
5. `CreateTemplatePopup` (CNPopupMenuButton: Crea Manualmente + Importa)
6. `QuickActionsOverlayContent` (container che assembla le 3 sezioni)
7. Integrazione in `main_shell.dart` (sostituisci contenuto overlay)
8. `QuickMeasurementInputSheet` (bottom sheet generico parametrizzato per MetricType)
9. Routing: Da Template, Vuoto, Crea Manualmente, Importa
