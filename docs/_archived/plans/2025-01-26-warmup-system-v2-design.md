# Warmup System v2.0 - Design Document

**Generated**: 2025-01-26
**Source**: Brainstorming session with scientific research
**Status**: ✅ Approved for implementation

---

## 📋 Executive Summary

Redesign del sistema warmup per FitLog Pro basato su:
- Ricerche scientifiche peer-reviewed (PMC, ScienceDirect, PubMed)
- Best practices UX 2024/2025 per fitness app
- Integrazione con componenti esistenti (`PlateCalculatorWidget`, `BarbellSelectorWidget`)

**Scope**: Algoritmo migliorato + UX ottimizzata (no AI, no HR tracking, no storico warmup)

---

## 🔬 Base Scientifica

### Fonti Peer-Reviewed

1. [PMC - Revisiting the 'Whys' and 'Hows' of the Warm-Up](https://pmc.ncbi.nlm.nih.gov/articles/PMC10798919/)
2. [ScienceDirect - High-load and low-volume warm-up increases performance](https://www.sciencedirect.com/science/article/abs/pii/S1360859224004017)
3. [PMC - The Role of Specific Warm-up during Bench Press and Squat](https://pmc.ncbi.nlm.nih.gov/articles/PMC7558980/)
4. [Stronger By Science - Heavier warm-ups are best](https://www.strongerbyscience.com/heavier-warm-ups/)
5. [PubMed - Combination of general and specific warm-ups](https://pubmed.ncbi.nlm.nih.gov/21544000/)

### Key Findings

| Finding | Source | Implicazione |
|---------|--------|--------------|
| Warmup 80% > 60% > 40% per performance | ScienceDirect 2024 | Ultimo set warmup all'80% |
| Combined warmup +8.4% forza | PubMed | Progressione graduale importante |
| Static stretching -8-10% forza | PMC | Evitare stretching statico pre-lift |
| PAP (Post-Activation Potentiation) | PMC | Rest adeguato tra warmup e working set |

### Perché NON tracciare i warmup

La ricerca conferma che:
- I warmup set **non contano** verso il volume totale di allenamento
- Solo i work set vanno tracciati per progressive overload
- Dopo le prime sessioni, i warmup diventano routine automatica

> "You could add another line for your warm-up sets, but this is optional. Warm-up sets don't add to training stress." - [Hygieia](https://www.hygieia.com.sg/library/articles/why-and-how-to-keep-a-training-log-serious-lifters-track-their-data-for-better-progress/)

---

## 🎯 Algoritmo Science-Based

### Protocollo per Peso Target

```dart
List<WarmupSet> calculateWarmupSets(double targetWeight, bool isBarbell) {
  if (targetWeight < 40) {
    // Peso leggero: warmup minimo o nessuno
    return isBarbell
      ? [WarmupSet(weight: 20, reps: 8, percentage: 0)] // Solo bar
      : [WarmupSet(weight: targetWeight * 0.5, reps: 8, percentage: 50)];
  }

  if (targetWeight <= 80) {
    // Peso medio: 3 set
    return [
      if (isBarbell) WarmupSet(weight: 20, reps: 5, percentage: 0),
      WarmupSet(weight: round(targetWeight * 0.50), reps: 5, percentage: 50),
      WarmupSet(weight: round(targetWeight * 0.80), reps: 3, percentage: 80),
    ];
  }

  if (targetWeight <= 120) {
    // Peso pesante: 4 set
    return [
      if (isBarbell) WarmupSet(weight: 20, reps: 5, percentage: 0),
      WarmupSet(weight: round(targetWeight * 0.40), reps: 5, percentage: 40),
      WarmupSet(weight: round(targetWeight * 0.60), reps: 3, percentage: 60),
      WarmupSet(weight: round(targetWeight * 0.80), reps: 2, percentage: 80),
    ];
  }

  // Peso molto pesante (>120kg): 5 set
  return [
    if (isBarbell) WarmupSet(weight: 20, reps: 5, percentage: 0),
    WarmupSet(weight: round(targetWeight * 0.40), reps: 5, percentage: 40),
    WarmupSet(weight: round(targetWeight * 0.55), reps: 3, percentage: 55),
    WarmupSet(weight: round(targetWeight * 0.70), reps: 2, percentage: 70),
    WarmupSet(weight: round(targetWeight * 0.80), reps: 1, percentage: 80),
  ];
}
```

### Arrotondamento ai Piatti Disponibili

```dart
double roundToAvailablePlates(double weight, List<double> availablePlates) {
  // Usa i piatti configurati dall'utente in appConfigProvider.availablePlates
  // Default: [25, 20, 15, 10, 5, 2.5, 1.25]

  final smallestPlate = availablePlates.last; // es. 1.25kg
  final increment = smallestPlate * 2; // per lato = 2.5kg

  return (weight / increment).round() * increment;
}
```

### Rilevamento Tipo Esercizio

```dart
bool isLikelyBarbellExercise(String exerciseName) {
  final lower = exerciseName.toLowerCase();

  // Esercizi tipicamente con bilanciere
  final barbellKeywords = [
    'squat', 'bench', 'deadlift', 'press', 'row',
    'clean', 'snatch', 'jerk', 'barbell', 'bilanciere'
  ];

  // Esercizi tipicamente con manubri/macchine
  final nonBarbellKeywords = [
    'dumbbell', 'manubr', 'cable', 'cavo', 'machine',
    'macchina', 'curl', 'fly', 'raise', 'extension'
  ];

  if (nonBarbellKeywords.any((k) => lower.contains(k))) return false;
  if (barbellKeywords.any((k) => lower.contains(k))) return true;

  // Default: assume barbell per pesi > 40kg
  return true;
}
```

---

## 🎨 UI Design

### 1. Plate Calculator Button in Workout Header

**Posizione**: Header globale della schermata workout
**Icona**: `AppIcons.calculate` (calcolatrice)
**Comportamento**: Tap → BottomSheet con `PlateCalculatorWidget` pre-popolato

```
┌──────────────────────────────────────────┐
│ 🏋️ Chest Day        [🧮] [⏱️] [⋮]       │
└──────────────────────────────────────────┘
                        ↑
                  Plate Calculator
                  (peso prossimo set)
```

**Logica contesto**:
```dart
double getNextSetWeight() {
  // Trova il primo set non completato nel workout corrente
  for (final exercise in workout.exercises) {
    for (final set in exercise.sets) {
      if (!set.isCompleted && set.weight > 0) {
        return set.weight;
      }
    }
  }
  return 0; // Fallback
}
```

### 2. WarmupSuggestionCard (Redesign)

**File**: `lib/features/workout/presentation/widgets/warmup_suggestion_card.dart`

```
┌─────────────────────────────────────────────┐
│ 🔥 Warmup Consigliato                       │
│ 4 set · Target 100kg                        │
├─────────────────────────────────────────────┤
│  1  Bar (20kg)     × 5                      │
│  2  40kg           × 5    ← 10+10 per lato  │
│  3  60kg           × 3    ← 20 per lato     │
│  4  80kg           × 2    ← 20+10 per lato  │
├─────────────────────────────────────────────┤
│  [Personalizza]              [+ Aggiungi]   │
└─────────────────────────────────────────────┘
```

**Features**:
- Visualizzazione piatti inline (opzionale, se spazio)
- Bottone "Personalizza" → apre mini-modal
- Bottone "Aggiungi" → aggiunge tutti i set warmup
- Collapse/expand animato
- Design coerente con `AppSpacing`, `context.colors`, `SemanticIcon`

### 3. Mini-Modal Personalizzazione Warmup

**Trigger**: Tap su "Personalizza" nella card
**Tipo**: BottomSheet modale

```
┌─────────────────────────────────────────────┐
│ ─────  (drag handle)                        │
│                                             │
│ Personalizza Warmup            [X]          │
├─────────────────────────────────────────────┤
│                                             │
│  Set 1   [  20.0  ] kg   × [  5  ] reps     │
│  Set 2   [  40.0  ] kg   × [  5  ] reps     │
│  Set 3   [  60.0  ] kg   × [  3  ] reps     │
│  Set 4   [  80.0  ] kg   × [  2  ] reps     │
│                                             │
│  [+ Aggiungi Set]                           │
│                                             │
├─────────────────────────────────────────────┤
│  [Annulla]                    [Conferma]    │
└─────────────────────────────────────────────┘
```

**Features**:
- TextField per peso e reps di ogni set
- Swipe to delete su ogni riga
- Bottone per aggiungere set extra
- Validazione (peso > 0, reps > 0)

---

## 📁 File da Modificare/Creare

### Modifiche

| File | Azione |
|------|--------|
| `warmup_suggestion_card.dart` | Redesign completo con nuovo algoritmo |
| `exercise_list_item.dart` | Aggiornare chiamata a `WarmupSuggestionCard` |
| `workout_screen.dart` | Aggiungere plate calculator button in header |

### Eliminazioni

| File | Motivo |
|------|--------|
| `warmup_progression_v2.dart` | Dead code, mai usato |

### Nuovi File

| File | Descrizione |
|------|-------------|
| `warmup_customization_modal.dart` | Mini-modal per personalizzare i set warmup |
| `warmup_calculator_service.dart` | Service per algoritmo warmup (separato da UI) |

---

## 🌍 Localizzazioni Richieste

```json
{
  "warmupRecommended": "Warmup Consigliato",
  "warmupSetsCount": "{count} set · Target {weight}kg",
  "warmupEmptyBar": "Bilanciere vuoto",
  "warmupPerSide": "{plates} per lato",
  "warmupCustomize": "Personalizza",
  "warmupAddAll": "Aggiungi",
  "warmupCustomizeTitle": "Personalizza Warmup",
  "warmupAddSet": "Aggiungi Set",
  "warmupSetNumber": "Set {number}",
  "warmupConfirm": "Conferma",
  "warmupScienceBased": "Basato su ricerca scientifica"
}
```

---

## ✅ Checklist Implementazione

### Pre-requisiti
- [ ] Leggere `DESIGN_GUIDELINES.md`
- [ ] Verificare `PlateCalculatorWidget` funziona correttamente
- [ ] Verificare `appConfigProvider.availablePlates` è persistito

### Fase 1: Algoritmo
- [ ] Creare `warmup_calculator_service.dart`
- [ ] Implementare `calculateWarmupSets()`
- [ ] Implementare `roundToAvailablePlates()`
- [ ] Implementare `isLikelyBarbellExercise()`
- [ ] Unit test per algoritmo

### Fase 2: UI Card
- [ ] Redesign `WarmupSuggestionCard` con design system
- [ ] Integrare nuovo algoritmo
- [ ] Aggiungere visualizzazione piatti inline
- [ ] Testare in light/dark mode

### Fase 3: Personalizzazione
- [ ] Creare `warmup_customization_modal.dart`
- [ ] Collegare a bottone "Personalizza"
- [ ] Implementare add/remove set
- [ ] Validazione input

### Fase 4: Plate Calculator Header
- [ ] Aggiungere icona in `workout_screen.dart` header
- [ ] Implementare logica `getNextSetWeight()`
- [ ] Collegare a `PlateCalculatorWidget`

### Fase 5: Cleanup
- [ ] Eliminare `warmup_progression_v2.dart`
- [ ] Aggiungere localizzazioni EN/IT
- [ ] `flutter gen-l10n`
- [ ] `flutter analyze`
- [ ] Test manuale completo

---

## 📚 References

- [PMC - Warm-Up Research 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC10798919/)
- [Stronger By Science - Heavier Warm-Ups](https://www.strongerbyscience.com/heavier-warm-ups/)
- [Hevy App - Warm Up Sets](https://www.hevyapp.com/warm-up-sets/)
- [Barbell Logic - Building Better Practices](https://barbell-logic.com/building-better-practices-why-and-how-to-warm-up/)
- Existing codebase: `PlateCalculatorWidget`, `BarbellSelectorWidget`, `appConfigProvider`
