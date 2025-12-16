# SupersetRoundConfigSheet - Design Document

**Data**: 2024-12-09
**Status**: Approvato
**Autore**: Claude + Michele

---

## Overview

Modal bottom sheet per configurare peso/reps di tutti gli esercizi in un superset, navigando tra round con swipe orizzontale.

### Problema Risolto

Il precedente approccio (cella singola → picker) non permetteva:
- Navigazione fluida tra round
- Vista d'insieme di tutti gli esercizi per round
- Copia efficiente delle configurazioni

### Soluzione

Lista scrollabile di esercizi per round + PageView per navigare tra round + MinimalSetEditSheet per editing singolo esercizio.

---

## Ricerca UX/UI - Best Practices 2025

### Fonti Consultate

- [Smashing Magazine - Multi-Step Forms (Dec 2024)](https://www.smashingmagazine.com/2024/12/creating-effective-multistep-form-better-user-experience/)
- [Hevy App - Smart Superset Scrolling](https://www.hevyapp.com/features/what-are-supersets/)
- [Strong App - Supersets & Circuits](https://help.strongapp.io/article/98-supersets-and-circuits)
- [NN/g - Carousels on Mobile (2024)](https://www.nngroup.com/articles/mobile-carousels/)
- [Flutter Docs - Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Mobile at Scale - State Management](https://www.mobileatscale.com/content/posts/01-state-management/)

### Key Insights Applicati

| Principio | Fonte | Implementazione |
|-----------|-------|-----------------|
| "Fewer taps, the better" - Max 3 step | Stormotion | Vedi lista → tap → modifica → done |
| "Use list view for 4+ items" | NN/g | Lista scrollabile per esercizi |
| "Max 3-4 swipe to reach last item" | NN/g | Max 10 round, tipicamente 3-4 |
| "Clear pagination indicators" | NN/g | Dot indicators per round |
| "Local state for transient UI" | Flutter Docs | StatefulWidget interno |
| "Immutable state updates" | Best Practice 2025 | copyWith pattern |

---

## UI Structure

```
┌─────────────────────────────────────────────┐
│  ═══  (drag handle)                         │
│                                             │
│  ⚡ Configura Superset                       │
│                                             │
│  ●  ○  ○   Round 1 di 3        [+ Round]   │
│─────────────────────────────────────────────│
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 1. Panca Piana                      │   │
│  │    40 kg × 12 rep              ▶   │   │
│  ├─────────────────────────────────────┤   │
│  │ 2. Squat                            │   │
│  │    60 kg × 10 rep              ▶   │   │
│  ├─────────────────────────────────────┤   │
│  │ 3. Military Press                   │   │
│  │    25 kg × 10 rep              ▶   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  📋 Copia round in tutti            │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         ✓ Conferma                   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│        ← Swipe per cambiare round →        │
└─────────────────────────────────────────────┘
```

---

## Funzionalità Copia

### 1. Copia Esercizio → Tutti i round
**Dove**: Dentro MinimalSetEditSheet quando modifichi un esercizio
**Azione**: "Applica a tutti i round"
**Risultato**: Peso/reps di quell'esercizio copiati in tutti i round

### 2. Copia Round → Altri round
**Dove**: Main sheet, pulsante sotto la lista
**Azione**: "Copia round in tutti"
**Risultato**: Tutte le configurazioni del round corrente copiate negli altri round

---

## Navigation Flow

```
1. APERTURA
   └── Apre SupersetRoundConfigSheet
       └── Mostra Round 1 con lista esercizi

2. MODIFICA ESERCIZIO
   └── Tap su card esercizio
       └── Apre MinimalSetEditSheet
           ├── Modifica peso/reps
           ├── [Opzionale] "Applica a tutti i round"
           └── Swipe down = salva

3. NAVIGAZIONE ROUND
   └── Swipe ← → sulla lista
       └── PageView cambia round
           └── Dot indicator si aggiorna

4. AZIONI RAPIDE
   ├── "Copia round in tutti" → clona configurazione
   ├── [+ Round] → aggiunge round
   └── [- Round] → rimuove ultimo

5. CONFERMA
   └── Tap "Conferma"
       └── Valida configurazione
           └── Ritorna SupersetConfiguration
```

---

## Data Model

### State Architecture

```dart
class _SupersetRoundConfigSheetState extends State<SupersetRoundConfigSheet> {
  late PageController _pageController;
  int _currentRoundIndex = 0;
  late List<_RoundConfig> _rounds;  // Stato semi-immutabile
  bool _hasUnsavedChanges = false;
}
```

### Internal Models

```dart
class _RoundConfig {
  final int roundNumber;
  final Map<String, _CellConfig> exercises;

  _RoundConfig copyWithExercise(String exerciseId, _CellConfig config) {
    return _RoundConfig(
      roundNumber: roundNumber,
      exercises: {...exercises, exerciseId: config},
    );
  }
}

class _CellConfig {
  final double weight;
  final int reps;

  bool get isValid => weight > 0 && reps > 0;
}
```

### Update Pattern (Immutable)

```dart
void _updateExercise(int roundIndex, String exerciseId, _CellConfig config) {
  setState(() {
    _rounds = [
      for (int i = 0; i < _rounds.length; i++)
        if (i == roundIndex)
          _rounds[i].copyWithExercise(exerciseId, config)
        else
          _rounds[i]
    ];
    _hasUnsavedChanges = true;
  });
}
```

---

## Widget Tree

```
SupersetRoundConfigSheet (StatefulWidget)
├── PopScope (intercetta back)
│   └── Container (decoration)
│       └── Column
│           ├── _DragHandle (const)
│           ├── _Header (const)
│           ├── _RoundIndicator
│           ├── Expanded
│           │   └── PageView.builder
│           │       └── _RoundPage
│           │           └── ListView.builder
│           │               └── _ExerciseCard
│           ├── _QuickActions
│           └── _ConfirmButton
```

---

## Performance Optimizations

| Optimization | Implementation |
|--------------|----------------|
| const constructors | _DragHandle, _Header |
| ListView.builder | Lazy loading esercizi |
| PageView.builder | Lazy loading round |
| ValueKey | Preserva state in liste |
| PopScope | Invece di WillPopScope (deprecated) |

---

## Validazioni

1. **Pre-conferma**: Tutti gli esercizi devono avere peso > 0 e reps > 0
2. **Warning visivo**: Card con bordo rosso se configurazione invalida
3. **Discard dialog**: Conferma se ci sono modifiche non salvate

---

## File Output

```
lib/features/workout/presentation/widgets/
└── superset_round_config_sheet.dart  (~300 righe)
```

---

## API Usage

```dart
final config = await SupersetRoundConfigSheet.show(
  context: context,
  exercises: selectedExercises,
  initialConfiguration: existingConfig,  // null per nuovo
  initialRounds: 3,
  restAfterRound: 90,
);

if (config != null) {
  // Usa la configurazione
}
```
