# 🏋️ Piano Completo Refactoring Superset

## 📊 Analisi Sistema Attuale

### Flusso Creazione Superset
```
User Input (SupersetBuilderWidget)
  ↓
SupersetConfiguration (config model)
  ↓
SupersetConverter.configurationToSupersetExercise()
  ↓
SupersetExercise (workout model) → aggiunto a workout_provider
```

**Status**: ✅ FUNZIONA - Non modificare

---

### Flusso Esecuzione Superset (PROBLEMATICO)

#### File Coinvolti:
1. **`superset_card.dart`** - Main UI, visualizza superset
2. **`superset_execution_sheet.dart`** - VECCHIO, stesso bug di V2
3. **`superset_execution_sheet_v2.dart`** - NUOVO ma buggy
4. **`rpe_selector_bottom_sheet.dart`** - Usato da superset_card

#### Problema Attuale (superset_card.dart:840-1086):
```dart
// ❌ LOGICA ERRATA
void _handleExerciseToggle(...) {
  // Apre modal PER SINGOLO ESERCIZIO
  // Permette completamento parziale
  // NO flow sequenziale obbligato
}
```

#### Problema Attuale (execution sheets):
- Usa PageView con swipe libero
- NON guida flow sequenziale
- Permette skip esercizi
- Legge da `exercise.sets` invece di `supersetSets`

---

### Sistema Timer (OK)

**Provider**: `UnifiedTimerProvider` in `lib/features/timer/presentation/providers/`
- ✅ Già implementato e funzionante
- ✅ Supporta Live Activities iOS
- ✅ Background audio
- ✅ Notifiche

**Integrazione necessaria**:
- Dopo completamento TUTTI esercizi del round → Timer countdown
- Auto-start prossimo round quando timer = 0

---

## 🎯 PIANO REFACTORING (Opzione A Completa)

### Fase 1: Creare Nuovo Widget Esecuzione Sequenziale

**File**: `lib/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart`

```dart
/// Widget per esecuzione CORRETTA superset con flow sequenziale
///
/// Flow:
/// 1. Mostra Esercizio 1 → RPE input → CONFERMA
/// 2. [AUTOMATICO] Passa a Esercizio 2 → RPE input → CONFERMA
/// 3. [AUTOMATICO] Mostra Timer Riposo (90sec con countdown)
/// 4. [AUTOMATICO] Passa a Round 2 o termina
class SupersetSequentialExecutionSheet extends ConsumerStatefulWidget {
  final SupersetExercise superset;
  final int roundIndex;  // Quale round stiamo eseguendo
  final Function(SupersetSet completedRound) onRoundCompleted;
  final VoidCallback? onAllRoundsCompleted;
}
```

**Stati del Widget**:
```dart
enum SupersetExecutionStep {
  exercising,  // Sta eseguendo un esercizio
  resting,     // Riposo tra round
  completed,   // Round completato
}
```

**Componenti**:
- `_ExerciseInputScreen` - Input RPE/peso/reps per singolo esercizio
- `_RestTimerScreen` - Countdown timer tra round
- `_CompletionScreen` - Feedback completamento

---

### Fase 2: Modificare superset_card.dart

**Cambiamenti in `_handleExerciseToggle()`**:

```dart
void _handleExerciseToggle(...) {
  // NON permettere completamento singolo esercizio
  // Invece:
  if (!supersetSet.isFullyCompleted) {
    _startSupersetRound(context, supersetSet);
  } else {
    // Deseleziona round completato
    _undoRoundCompletion(context, supersetSet);
  }
}

void _startSupersetRound(BuildContext context, SupersetSet supersetSet) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false, // NON permettere chiusura accidentale
    builder: (context) => SupersetSequentialExecutionSheet(
      superset: widget.superset,
      roundIndex: supersetSet.setNumber - 1,
      onRoundCompleted: (completedRound) {
        widget.onSupersetSetUpdate?.call(completedRound);
        Navigator.pop(context);

        // Se non è l'ultimo round, chiedi se vuole continuare
        if (!_isLastRound(supersetSet)) {
          _askToContinueNextRound(context);
        }
      },
    ),
  );
}
```

---

### Fase 3: Integrazione Timer Riposo

**Utilizzo `UnifiedTimerProvider`**:

```dart
// In SupersetSequentialExecutionSheet

Future<void> _startRestTimer(int durationSeconds) async {
  final timerProvider = ref.read(unifiedTimerProvider.notifier);

  await timerProvider.startTimer(
    durationSeconds: durationSeconds,
    exerciseName: widget.superset.name,
    currentSet: widget.roundIndex + 1,
    totalSets: widget.superset.supersetSets.length,
    onComplete: () {
      // Timer completato, passa al prossimo round
      if (widget.roundIndex < widget.superset.supersetSets.length - 1) {
        _moveToNextRound();
      } else {
        widget.onAllRoundsCompleted?.call();
      }
    },
  );
}
```

**UI Rest Timer**:
```dart
Widget _buildRestTimerScreen() {
  final timer = ref.watch(unifiedTimerProvider);

  return Column(
    children: [
      Text('Riposo tra Round'),
      Text(
        timer?.remaining.toString() ?? '--:--',
        style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      ),
      CircularProgressIndicator(value: timer?.progress ?? 0),

      // Pulsante salta riposo
      TextButton(
        onPressed: () {
          ref.read(unifiedTimerProvider.notifier).skipTimer();
          _moveToNextRound();
        },
        child: Text('Salta Riposo'),
      ),
    ],
  );
}
```

---

### Fase 4: Validazione Strict Completamento

**In `lib/features/workout/domain/entities/exercise.dart`**:

```dart
extension SupersetExerciseValidation on SupersetExercise {
  /// Valida che un round sia stato completato CORRETTAMENTE
  bool isRoundValidlyCompleted(int roundIndex) {
    if (roundIndex >= supersetSets.length) return false;

    final round = supersetSets[roundIndex];

    // Tutti gli esercizi devono essere completati
    if (!round.isFullyCompleted) return false;

    // Tutti devono avere actualReps, actualWeight, RPE
    for (final data in round.exerciseData.values) {
      if (data.actualReps == null) return false;
      if (data.actualWeight == null && data.targetWeight != null) return false;
      if (data.rpe == null) return false;
    }

    return true;
  }
}
```

---

### Fase 5: Deprecare File Vecchi

**File da deprecare** (NON eliminare subito):
- `superset_execution_sheet.dart` → Aggiungi @Deprecated
- `superset_execution_sheet_v2.dart` → Aggiungi @Deprecated

```dart
@Deprecated('Use SupersetSequentialExecutionSheet instead')
class SupersetExecutionSheet extends ConsumerStatefulWidget {
  // ...
}
```

---

## 📝 Checklist Implementazione

### Step 1: Nuovo Widget Sequenziale
- [ ] Creare `superset_sequential_execution_sheet.dart`
- [ ] Implementare stati (exercising/resting/completed)
- [ ] UI per input singolo esercizio
- [ ] Transizione automatica tra esercizi
- [ ] Validazione input obbligatori

### Step 2: UI Rest Timer
- [ ] Schermata countdown timer
- [ ] Integrazione UnifiedTimerProvider
- [ ] Live Activity iOS
- [ ] Audio/notifiche completamento
- [ ] Pulsante skip riposo

### Step 3: Modifiche superset_card.dart
- [ ] Refactor `_handleExerciseToggle`
- [ ] Chiamare nuovo widget sequenziale
- [ ] Rimuovere logica completamento singolo
- [ ] Gestire feedback UI round completati

### Step 4: Validazione
- [ ] Extension per validazione round
- [ ] Check strict completamento
- [ ] Prevenire skip esercizi
- [ ] Log analytics completamento

### Step 5: Testing
- [ ] Test flow completo A→B→Rest→A→B→Rest
- [ ] Test skip riposo
- [ ] Test interru interruzione mid-round
- [ ] Test iOS Live Activity
- [ ] Test background audio

### Step 6: Cleanup
- [ ] Deprecare vecchi execution sheets
- [ ] Aggiornare documentazione
- [ ] Rimuovere codice dead
- [ ] Update CLAUDE.md con nuove regole

---

## 🔗 Dipendenze tra Fasi

```
Fase 1 (Nuovo Widget)
  ↓ (deve essere completo prima di)
Fase 3 (Timer Integration)
  ↓ (deve essere completo prima di)
Fase 2 (Modifiche Card)
  ↓
Fase 4 (Validazione)
  ↓
Fase 5 (Deprecazione)
```

---

## ⚠️ Punti di Attenzione

1. **Backward Compatibility**:
   - Superset esistenti devono continuare a funzionare
   - Dati salvati in Firestore/Hive devono essere compatibili

2. **State Management**:
   - Aggiornamenti provider devono essere atomici
   - Prevent race condition tra timer e completion

3. **iOS Live Activities**:
   - Testare che funzionino durante riposo
   - Verificare che si aggiornino correttamente

4. **Performance**:
   - Non bloccare UI durante transizioni
   - Animazioni fluide 60fps

---

## 📱 UX Flow Completo

```
[User] Tap su "Set 1" non completato
  ↓
[Modal] SupersetSequentialExecutionSheet
  ↓
[Screen 1] Panca Piana
  - Mostra target: 10 reps @ 80kg
  - Input: peso effettivo, reps, RPE
  - [Conferma] →
  ↓
[Screen 2] Trazioni
  - Mostra target: 8 reps @ BW
  - Input: peso effettivo, reps, RPE
  - [Conferma] →
  ↓
[Screen 3] Riposo Timer
  - Countdown 90 secondi
  - Live Activity attiva
  - Audio a fine timer
  - [Skip] opzionale
  ↓
[Chiude Modal]
[UI aggiornata] Set 1 → Verde ✅
```

---

## 🧪 Scenari di Test

1. **Happy Path**: A→B→Rest→completato
2. **Interruzione**: Chiude app durante esercizio → riprende
3. **Skip Rest**: Salta riposo → passa subito a Round 2
4. **Background**: App in background durante timer → continua
5. **Modifica**: Torna indietro su round completato → deseleziona
6. **Multi-round**: Esegue 3 round consecutivi

---

## 📊 Metriche Successo

- ✅ 0 completamenti parziali (solo A senza B)
- ✅ 100% flow sequenziale rispettato
- ✅ Timer funziona in background
- ✅ Live Activity aggiornata correttamente
- ✅ Analytics tracking completo

---

## 🚀 Priorità Implementazione

**MUST HAVE (P0)**:
- Flow sequenziale obbligato
- Timer tra round
- Validazione completamento

**SHOULD HAVE (P1)**:
- Live Activity iOS
- Skip riposo
- Feedback completamento

**NICE TO HAVE (P2)**:
- Animazioni fluide
- Audio personalizzato
- Analytics avanzati
