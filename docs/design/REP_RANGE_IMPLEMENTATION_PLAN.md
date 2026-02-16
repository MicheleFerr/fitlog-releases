# 🎯 Piano Implementazione: Rep Range Feature (Opus 4.6)

**Data**: 2026-02-15
**Team**: rep-range-opus (Opus 4.6)
**Status**: 📋 Piano Completo - Ready for Implementation
**Versione**: 2.0 (analisi approfondita con Opus 4.6)

---

## 📊 Executive Summary

### Obiettivo
Permettere agli utenti di definire un **range di ripetizioni** (es. 8-12) invece di un numero fisso, per tutti i tipi di esercizio (standard, superset, dropset, rest-pause).

### Persona Impact
| Persona | Impatto | Rationale |
|---------|---------|-----------|
| Luca | +++     | Feature CHIAVE per programmazione seria |
| Chiara | ++     | Flessibilita' perfetta: adatta al tempo reale |
| Roberto | ++    | Efficienza: minimo se fretta, massimo se tempo |
| Sofia | +       | Si sente piu' "pro" con feature avanzata |
| Marco | 0/+     | Neutro se UI chiara, toggle exact/range |

**Verdict**: ✅ **PROCEDI** - Zero personas con impatto negativo

### Key Metrics
| Metrica | Valore |
|---------|--------|
| **Classi da modificare** | 8 domain/data + 4 UI input + ~10 UI display |
| **File totali impattati** | ~25 |
| **Breaking changes** | ✅ ZERO |
| **Migrazione Firestore** | ✅ NON necessaria |
| **Cloud Functions** | ✅ NESSUNA modifica (passthrough JSON) |
| **Bug fix incluso** | ✅ Workout import range perso |
| **Stima sviluppo** | 3-4 giorni |

---

## 🏗️ Architettura Proposta

### Approccio: Campi Nullable Addizionali (Zero Breaking Changes)

```dart
// Domain Entity - ExerciseSet
class ExerciseSet {
  final int? reps;            // Target singolo (BACKWARD COMPAT)
  final int? minReps;         // 🆕 Min del range (es. 8)
  final int? maxReps;         // 🆕 Max del range (es. 12)
  final int? actualReps;      // Reps effettive (INVARIATO)

  bool get hasRepRange => minReps != null && maxReps != null && minReps != maxReps;

  String get repsDisplay {
    if (hasRepRange) return '$minReps-$maxReps';
    return '${reps ?? minReps ?? maxReps ?? "-"}';
  }
}

// Template - SetTemplate
class SetTemplate {
  final int? targetReps;      // Singolo (BACKWARD COMPAT)
  final int? targetMinReps;   // 🆕 Min range
  final int? targetMaxReps;   // 🆕 Max range

  bool get hasRepRange => targetMinReps != null && targetMaxReps != null && targetMinReps != targetMaxReps;

  String get repsDisplay {
    if (hasRepRange) return '$targetMinReps-$targetMaxReps';
    return '${targetReps ?? "-"}';
  }
}
```

### Regola di Fallback
```
IF (minReps != null && maxReps != null && minReps != maxReps)
  → Usa REP RANGE → display "8-12"
ELSE IF (minReps == maxReps)
  → Tratta come singolo → display "10" (non "10-10")
ELSE IF (reps != null)
  → Backward compat → display "10"
ELSE
  → Nessun target → display "-"
```

### Edge Cases Documentati
| Edge Case | Handling |
|-----------|----------|
| `reps=null, minReps=null, maxReps=null` | Nessun target (es. esercizio a tempo) |
| `reps=10, minReps=null, maxReps=null` | Backward compat singolo: "10" |
| `reps=null, minReps=8, maxReps=12` | Range senza default: "8-12" |
| `reps=10, minReps=8, maxReps=12` | Range prioritario: "8-12", `reps` ignorato per display |
| `minReps > maxReps` | INVALIDO: normalizzare in fromJson (swap) |
| `minReps == maxReps` | Trattare come singolo: "10" non "10-10" |
| `solo minReps O solo maxReps` | Trattare come singolo valore |

### Firestore Schema

**Nuovo documento con range:**
```json
{
  "setNumber": 1,
  "weight": 80.0,
  "reps": 10,              // Midpoint/backward compat
  "minReps": 8,            // 🆕
  "maxReps": 12,           // 🆕
  "actualReps": 10,
  "rpe": 8
}
```

**Template con range:**
```json
{
  "setNumber": 1,
  "targetWeight": 80.0,
  "targetReps": 10,            // Backward compat
  "targetMinReps": 8,          // 🆕
  "targetMaxReps": 12,         // 🆕
  "targetRpe": 8
}
```

**Vecchi documenti (INVARIATI, funzionano come prima):**
```json
{
  "setNumber": 1,
  "weight": 80.0,
  "reps": 10,
  "actualReps": 10
}
```

✅ **Zero migrazione Firestore** - Nullable = backward compatible
✅ **Zero modifica Cloud Functions** - JSON passthrough

---

## 📁 FASE 1: Core Data Models (8 classi)

### Priorita': CRITICAL | Stima: 3-4 ore

| # | File | Classe | Campi da Aggiungere | Note |
|---|------|--------|---------------------|------|
| 1.1 | `exercise.dart:441` | `ExerciseSet` | `minReps: int?`, `maxReps: int?` | + helpers `hasRepRange`, `repsDisplay`, aggiornare `isFullyCompleted`/`isPartiallyCompleted` |
| 1.2 | `exercise.dart:671` | `SupersetExerciseData` | `targetMinReps: int?`, `targetMaxReps: int?` | Pattern identico a ExerciseSet |
| 1.3 | `exercise.dart:1313` | `DropSetStage` | `minReps: int?`, `maxReps: int?` | `reps` e' `int` NON-nullable, range come opzionale |
| 1.4 | `exercise.dart:1590` | `RestPauseSet` | `minReps: int?`, `maxReps: int?` | `reps` e' `int` NON-nullable, range come opzionale |
| 1.5 | `exercise.dart` | `RestPauseExercise` | `targetMinReps: int?`, `targetMaxReps: int?` | `targetReps` e' `int` non-nullable |
| 1.6 | `workout_model.dart:846` | `ExerciseSetModel` | `minReps: int?`, `maxReps: int?` | + `fromJson`/`toJson`/`toDomain`/`fromDomain` |
| 1.7 | `workout_template.dart:749` | `SetTemplate` | `targetMinReps: int?`, `targetMaxReps: int?` | + `fromJson`/`toJson` + helpers |
| 1.8 | `workout_preset.dart:63` | `RepRangePreset` | `minReps: int?`, `maxReps: int?` | + aggiornare JSON asset |

### Logica `isFullyCompleted` Aggiornata

```dart
// ExerciseSet - exercise.dart
bool get isFullyCompleted {
  if (actualReps == null) return false;
  if (hasRepRange) {
    return actualReps! >= minReps!; // Completato se >= minimo del range
  }
  return reps != null && actualReps! >= reps!;
}

bool get isPartiallyCompleted {
  if (actualReps == null || actualReps == 0) return false;
  if (hasRepRange) {
    return actualReps! < minReps!; // Parziale se sotto il minimo
  }
  return reps != null && actualReps! < reps!;
}

bool get isAboveRange {
  if (!hasRepRange || actualReps == null) return false;
  return actualReps! > maxReps!; // Sopra il massimo del range
}
```

---

## 📁 FASE 2: Conversioni Template ↔ Workout (4 flussi critici)

### Priorita': CRITICAL | Stima: 2-3 ore

| # | File | Metodo | Modifica |
|---|------|--------|----------|
| 2.1 | `workout_template.dart:766` | `SetTemplate.toExerciseSet()` | Propagare `targetMinReps`→`minReps`, `targetMaxReps`→`maxReps` |
| 2.2 | `workout_template.dart:560` | `ExerciseTemplate.toWorkoutExercise()` | Propagare range per standard, superset, dropset, rest-pause |
| 2.3 | `workout_template.dart:388` | `ExerciseTemplate.fromExercise()` | Preservare range da ExerciseSet → SetTemplate |
| 2.4 | `template_cloud_service.dart:534` | `_exerciseToJson()` | Serializzare range per standard/superset/dropset/restpause |

### Dettaglio Conversioni

```dart
// 2.1 SetTemplate.toExerciseSet()
ExerciseSet toExerciseSet() {
  return ExerciseSet(
    setNumber: setNumber,
    weight: targetWeight,
    reps: targetReps,
    minReps: targetMinReps,     // 🆕
    maxReps: targetMaxReps,     // 🆕
    rpe: targetRpe,
  );
}

// 2.3 ExerciseTemplate.fromExercise() - standard
SetTemplate(
  setNumber: set.setNumber,
  targetWeight: set.weight,
  targetReps: set.reps,
  targetMinReps: set.minReps,   // 🆕
  targetMaxReps: set.maxReps,   // 🆕
  targetRpe: set.rpe,
)

// 2.4 _exerciseToJson - Cloud sync
'targetMinReps': s.minReps,     // 🆕
'targetMaxReps': s.maxReps,     // 🆕
```

---

## 📁 FASE 3: Bug Fix Workout Import

### Priorita': HIGH (fix bug ESISTENTE) | Stima: 30 min

**File**: `lib/features/workout_import/presentation/providers/workout_import_provider.dart:292`

```dart
// ATTUALE (BUGGY - range PERSO)
targetReps: s.reps ?? s.maxReps ?? (s.isMaxReps ? null : 8),

// FIX CORRETTO
targetReps: s.reps ?? s.maxReps ?? (s.isMaxReps ? null : 8),
targetMinReps: s.minReps,       // 🆕 Preserva min
targetMaxReps: s.maxReps,       // 🆕 Preserva max
```

**Contesto**: `ParsedSet` ha GIA' `minReps`/`maxReps` (parsati dall'AI). Quando l'utente importa "3x10-12", il parser crea correttamente `ParsedSet(minReps: 10, maxReps: 12)`, ma la conversione in SetTemplate scarta `minReps`. Con questo fix, il range viene finalmente preservato end-to-end.

---

## 📁 FASE 4: UI Input Widgets (4 widget)

### Priorita': CRITICAL | Stima: 5-6 ore

| # | File | Widget | Complessita' | Modifiche |
|---|------|--------|-------------|-----------|
| 4.1 | `reps_picker_modal.dart` | RepsPickerModal | **ALTA** | Dual wheel picker (min\|max), quick select range presets, return type `(int, int)?` |
| 4.2 | `minimal_set_edit_sheet.dart` | MinimalSetEditSheet | **ALTA** | Toggle exact/range, dual wheel, fast scrub con range |
| 4.3 | `quick_edit_overlay_v2.dart` | QuickEditOverlayV2 | **MEDIA** | Range picker + superset support |
| 4.4 | `edit_set_modal.dart` | EditSetModal | **MEDIA** | TextField "8-12" format + integrazione picker |

### 4.1 RepsPickerModal - Design Dettagliato

```
┌────────────────────────────────┐
│  Ripetizioni                   │
│                                │
│  ┌─ Toggle ─────────────────┐  │
│  │ [Esatto] [Range]        │  │
│  └──────────────────────────┘  │
│                                │
│  ┌─────┐    ─    ┌─────┐      │
│  │  7  │         │ 11  │      │
│  │▸ 8 ◂│         │▸12 ◂│      │
│  │  9  │         │ 13  │      │
│  └─────┘         └─────┘      │
│   MIN              MAX         │
│                                │
│  Quick Select:                 │
│  [3-5] [6-8] [8-12] [12-15]  │
│                    [15-20]     │
│                                │
│  ┌────────────────────────┐    │
│  │     Conferma (8-12)    │    │
│  └────────────────────────┘    │
└────────────────────────────────┘
```

**Comportamento:**
- Toggle "Esatto / Range": Default su "Esatto" (backward compat per Marco)
- In mode "Esatto": Singolo wheel come oggi
- In mode "Range": Dual wheel con constraint `min <= max`
- Quick select: Preset range comuni (UX veloce per Chiara)
- Fast scrub: Aggiorna il wheel attivo (ultimo toccato)

### 4.2 MinimalSetEditSheet - Integrazione Range

**Stato attuale**: `_reps` (int), `_repsController` (FixedExtentScrollController)
**Modifica**: Aggiungere `_minReps`, `_maxReps`, `_isRangeMode`

```dart
// Nuovo state
int _minReps;
int _maxReps;
bool _isRangeMode;

// Output aggiornato
ExerciseSet(
  reps: _isRangeMode ? null : _reps,
  minReps: _isRangeMode ? _minReps : null,
  maxReps: _isRangeMode ? _maxReps : null,
)
```

### Per Superset/Dropset/RestPause

- **Superset**: Range ha senso → abilitare picker range
- **Dropset**: Range meno utile (stage specifici) → proporre singolo valore di default, range opzionale
- **RestPause**: Tipicamente AMRAP → proporre singolo valore, range opzionale

---

## 📁 FASE 5: UI Display (~10 widget)

### Priorita': HIGH | Stima: 4-5 ore

### Alta Priorita'

| # | File | Widget | Modifica |
|---|------|--------|----------|
| 5.1 | `exercise_list_item_sets.dart:718` | ExerciseListItemSets | Display "10/8-12 reps" + coloring semantico |
| 5.2 | `template_view_screen.dart:490` | TemplateViewScreen | Display "x8-12" + smart grouping range |
| 5.3 | `edit_template_screen.dart:757` | EditTemplateScreen | Display "8-12 rep" nelle compact rows |
| 5.4 | `superset_card.dart` | SupersetCard | Display range per target reps |

### Media Priorita'

| # | File | Widget | Modifica |
|---|------|--------|----------|
| 5.5 | `exercise_history_bottom_sheet.dart` | ExerciseHistorySheet | Backward compat: range se disponibile |
| 5.6 | `exercise_history_tab.dart` | ExerciseHistoryTab | Backward compat display |
| 5.7 | `quick_edit_overlay_v2.dart` | QuickEditOverlay | "Last: 80kg x 10 (8-12)" info |

### Bassa Priorita'

| # | File | Widget | Modifica |
|---|------|--------|----------|
| 5.8 | `workout_share_card.dart:317` | WorkoutShareCard | "Set 1: 80kg x 10 (target 8-12)" opzionale |
| 5.9 | `workout_completion_summary_screen.dart` | CompletionSummary | Stat "% sets in range" bonus |
| 5.10 | `dropset_completion_modal.dart` | DropsetModal | Range opzionale per stage |
| 5.11 | `rest_pause_execution_modal.dart` | RestPauseModal | Range come target totale opzionale |

### Coloring Logic

```dart
// Helper function per colore reps vs range
Color getRepsStatusColor(BuildContext context, int actualReps, int? minReps, int? maxReps) {
  if (minReps == null || maxReps == null) {
    return context.colors.onSurface; // Default, no range
  }
  if (actualReps >= minReps && actualReps <= maxReps) {
    return context.colors.success;     // 🟢 In range
  }
  if (actualReps < minReps) {
    return context.colors.warning;     // 🟠 Sotto range
  }
  return context.colors.tertiary;      // 🔵 Sopra range (bonus!)
}
```

### Display Format Helper

```dart
String formatRepsDisplay({
  required int? actualReps,
  int? reps,
  int? minReps,
  int? maxReps,
}) {
  final hasRange = minReps != null && maxReps != null && minReps != maxReps;
  final target = hasRange ? '$minReps-$maxReps' : '${reps ?? minReps ?? maxReps ?? "-"}';

  if (actualReps != null) {
    return '$actualReps/$target';  // "10/8-12"
  }
  return target;  // "8-12"
}
```

---

## 📁 FASE 6: Rep Range Presets (Asset JSON)

### Priorita': LOW (enhancement) | Stima: 1 ora

**File**: `assets/data/rep_presets.json`

```json
[
  {"id": "strength", "reps": 3, "minReps": 1, "maxReps": 5},
  {"id": "power", "reps": 5, "minReps": 3, "maxReps": 6},
  {"id": "strength_hypertrophy", "reps": 8, "minReps": 6, "maxReps": 8},
  {"id": "hypertrophy", "reps": 10, "minReps": 8, "maxReps": 12},
  {"id": "endurance", "reps": 12, "minReps": 12, "maxReps": 15},
  {"id": "high_endurance", "reps": 20, "minReps": 15, "maxReps": 25}
]
```

**File da aggiornare:**
- `assets/data/rep_presets.json` - Dati
- `workout_preset.dart:63` - `RepRangePreset` model
- `json_preset_repository.dart` - Parse logic

---

## 📁 FASE 7: Analytics (Opzionale)

### Priorita': LOW | Stima: 2-3 ore

| # | Feature | File | Note |
|---|---------|------|------|
| 7.1 | Rep zone con range | `rep_zone_tab.dart` | Classificare range nel zone dominante |
| 7.2 | Range band in grafici | `reps_line_chart.dart` | Area colorata per visualizzare target range |
| 7.3 | Stat "% in range" | `workout_completion_summary_screen.dart` | Percentuale set completati nel range |

**AnalyticsSet**: NON necessita di range - usa reps EFFETTIVE per calcoli (volume, 1RM).
**LastWorkoutSetData**: NON necessita di range - mostra dati storici reali.

---

## 🎨 UX Flow Dettagliati

### Flow 1: Creazione Template con Range

```
1. User tap "Add Set" in Edit Template
2. MinimalSetEditSheet si apre con default "10 reps"
3. User tap sul numero reps → apre RepsPickerModal
4. User toggle "Range" → dual wheel appare
5. User seleziona 8 (min) e 12 (max), oppure tap chip "8-12"
6. Conferma → display "8-12 rep" nella compact row del template
7. Salva template → Firestore: targetMinReps: 8, targetMaxReps: 12
```

### Flow 2: Esecuzione Workout con Range

```
1. User avvia template con set target "80kg x 8-12 reps"
2. Display non completato:
   ┌──────────────────────────────┐
   │  Set 1                       │
   │  80kg x 8-12 reps           │  ← Target range
   │  [    Complete    ]          │
   └──────────────────────────────┘

3. User tap "Complete" → MinimalSetEditSheet pre-compilato:
   - Peso: 80kg
   - Reps: 10 (midpoint del range, o ultimo actualReps)

4. User conferma 10 reps → display aggiornato:
   ┌──────────────────────────────┐
   │  Set 1 ✅                    │
   │  80kg x 10/8-12 reps        │  ← Verde: in range
   └──────────────────────────────┘

5. Varianti coloring:
   6/8-12  → 🟠 Arancione (sotto range)
   10/8-12 → 🟢 Verde (in range)
   15/8-12 → 🔵 Azzurro (sopra range, bonus!)
```

### Flow 3: Workout Import con Range

```
1. User importa testo "Bench Press 3x8-12 @80kg"
2. AI parsa: ParsedSet(minReps: 8, maxReps: 12, weight: 80)
3. 🆕 Conversione PRESERVA range: SetTemplate(targetMinReps: 8, targetMaxReps: 12)
4. Preview mostra "3 x 8-12 reps @ 80kg" (gia' funzionante nel preview!)
5. User conferma → template creato con range completo
```

### Flow 4: Backward Compatibility

```
Vecchio template (singolo valore):
- Firestore: { "reps": 10 } (no minReps/maxReps)
- Parse: minReps=null, maxReps=null, reps=10
- Display: "10 reps" (come prima)
- Comportamento: INVARIATO al 100%
```

---

## 🧪 Piano Testing

### Unit Tests

```dart
group('ExerciseSet Rep Range', () {
  test('hasRepRange true when min/max defined and different', () {
    final set = ExerciseSet(minReps: 8, maxReps: 12);
    expect(set.hasRepRange, true);
  });

  test('hasRepRange false when min==max', () {
    final set = ExerciseSet(minReps: 10, maxReps: 10);
    expect(set.hasRepRange, false);
  });

  test('hasRepRange false when null', () {
    final set = ExerciseSet(reps: 10);
    expect(set.hasRepRange, false);
  });

  test('repsDisplay shows range', () {
    final set = ExerciseSet(minReps: 8, maxReps: 12);
    expect(set.repsDisplay, '8-12');
  });

  test('repsDisplay shows single when min==max', () {
    final set = ExerciseSet(minReps: 10, maxReps: 10);
    expect(set.repsDisplay, '10');
  });

  test('isFullyCompleted checks against minReps', () {
    final set = ExerciseSet(minReps: 8, maxReps: 12, actualReps: 8);
    expect(set.isFullyCompleted, true);
  });

  test('isPartiallyCompleted when below minReps', () {
    final set = ExerciseSet(minReps: 8, maxReps: 12, actualReps: 6);
    expect(set.isPartiallyCompleted, true);
  });

  test('isAboveRange when above maxReps', () {
    final set = ExerciseSet(minReps: 8, maxReps: 12, actualReps: 15);
    expect(set.isAboveRange, true);
  });

  test('backward compat: works without range', () {
    final set = ExerciseSet(reps: 10, actualReps: 10);
    expect(set.hasRepRange, false);
    expect(set.repsDisplay, '10');
    expect(set.isFullyCompleted, true);
  });

  test('edge case: minReps > maxReps normalized', () {
    // fromJson should swap
    final json = {'minReps': 12, 'maxReps': 8};
    final set = ExerciseSet.fromJson(json);
    expect(set.minReps, 8);
    expect(set.maxReps, 12);
  });
});

group('SetTemplate Rep Range', () {
  test('toJson includes range fields', () {
    final template = SetTemplate(
      setNumber: 1, targetMinReps: 8, targetMaxReps: 12,
    );
    final json = template.toJson();
    expect(json['targetMinReps'], 8);
    expect(json['targetMaxReps'], 12);
  });

  test('fromJson reads range fields', () {
    final template = SetTemplate.fromJson({
      'setNumber': 1, 'targetMinReps': 8, 'targetMaxReps': 12,
    });
    expect(template.targetMinReps, 8);
    expect(template.targetMaxReps, 12);
  });

  test('fromJson backward compat without range', () {
    final template = SetTemplate.fromJson({
      'setNumber': 1, 'targetReps': 10,
    });
    expect(template.targetMinReps, isNull);
    expect(template.targetMaxReps, isNull);
    expect(template.targetReps, 10);
  });

  test('toExerciseSet propagates range', () {
    final template = SetTemplate(
      setNumber: 1, targetMinReps: 8, targetMaxReps: 12,
    );
    final set = template.toExerciseSet();
    expect(set.minReps, 8);
    expect(set.maxReps, 12);
  });
});

group('Workout Import Bug Fix', () {
  test('ParsedSet range preserved in SetTemplate', () {
    final parsed = ParsedSet(minReps: 10, maxReps: 12);
    // Dopo il fix, la conversione deve preservare il range
    final template = _convertParsedSetToTemplate(parsed);
    expect(template.targetMinReps, 10);
    expect(template.targetMaxReps, 12);
  });
});
```

### Widget Tests

```dart
group('RepsPickerModal', () {
  testWidgets('toggle between exact and range mode', ...);
  testWidgets('dual wheel picker enforces min <= max', ...);
  testWidgets('quick select chips set range correctly', ...);
  testWidgets('returns null on cancel', ...);
  testWidgets('returns single value in exact mode', ...);
  testWidgets('returns range in range mode', ...);
});

group('ExerciseListItemSets Display', () {
  testWidgets('shows "8-12 reps" for range target', ...);
  testWidgets('shows "10/8-12 reps" for completed in range', ...);
  testWidgets('green color when in range', ...);
  testWidgets('orange color when below range', ...);
  testWidgets('blue color when above range', ...);
  testWidgets('backward compat: shows "10 reps" for single value', ...);
});
```

### Manual Testing Checklist

- [ ] Crea template con range 8-12 → Salva → Riapri → Range preservato
- [ ] Crea template con singolo valore 10 → Funziona come prima
- [ ] Esegui workout con range → Completa nel range → Verde ✅
- [ ] Esegui workout con range → Completa sotto min → Arancione ⚠️
- [ ] Esegui workout con range → Completa sopra max → Azzurro 🎉
- [ ] Esegui workout VECCHIO (singolo) → Funziona identico
- [ ] Import testo "3x8-12" → Range preservato end-to-end
- [ ] Superset con range → Range per ogni esercizio nel superset
- [ ] Dropset con range → Opzionale per stage
- [ ] Template view → Display "x8-12" corretto
- [ ] Exercise history → Backward compat per dati vecchi
- [ ] Analytics/grafici → Funzionano correttamente con reps effettive
- [ ] Cloud sync → Template con range sincronizzato correttamente
- [ ] Offline → Range salvato localmente, sincronizzato al reconnect
- [ ] Rep presets → Mostrano range se disponibile

---

## ⚠️ Rischi e Mitigazioni

| Rischio | Prob. | Impatto | Mitigazione |
|---------|-------|---------|-------------|
| Breaking changes non previsti | BASSA | ALTO | Tutti campi nullable, test completo su dataset esistente |
| Confusione utenti | MEDIA | MEDIO | Toggle exact/range (default: exact), tooltips per Marco |
| Performance serialization | BASSA | BASSO | Campi nullable = overhead minimo |
| Cloud Function incompatibility | MOLTO BASSA | MEDIO | CF fa passthrough JSON, nessuna modifica server |
| Superset/Dropset UI complessa | MEDIA | MEDIO | Range opzionale per tipi avanzati, default singolo |
| minReps > maxReps in input | MEDIA | BASSO | Validazione in picker + normalizzazione in fromJson |

---

## 📊 Stima Complessita' per Fase

| Fase | Descrizione | Ore | Criticita' |
|------|-------------|-----|------------|
| **FASE 1** | Core Data Models (8 classi) | 3-4h | CRITICAL |
| **FASE 2** | Conversioni Template ↔ Workout | 2-3h | CRITICAL |
| **FASE 3** | Bug Fix Workout Import | 0.5h | HIGH |
| **FASE 4** | UI Input Widgets (4 widget) | 5-6h | CRITICAL |
| **FASE 5** | UI Display (~10 widget) | 4-5h | HIGH |
| **FASE 6** | Rep Range Presets (JSON) | 1h | LOW |
| **FASE 7** | Analytics (opzionale) | 2-3h | LOW |
| **Testing** | Unit + Widget + Integration + Manual | 4-5h | CRITICAL |
| **TOTALE Core (Fasi 1-5 + Test)** | | **19-24h** | |
| **TOTALE Completo** | | **22-28h** | |

**Stima sviluppo core**: 3-4 giorni lavorativi
**Stima completa (con advanced + testing)**: 4-5 giorni

---

## 🚀 Roadmap Implementazione

### Sprint 1: Foundation (Giorno 1-2)
```
✅ FASE 1: Data models (8 classi)
✅ FASE 2: Conversioni template ↔ workout (4 flussi)
✅ FASE 3: Bug fix workout import
✅ Unit tests core (ExerciseSet, SetTemplate, conversioni)
```

### Sprint 2: UI Input (Giorno 2-3)
```
✅ FASE 4.1: RepsPickerModal con dual wheel
✅ FASE 4.2: MinimalSetEditSheet refactor
✅ FASE 4.3-4.4: QuickEditOverlay + EditSetModal
✅ Widget tests input
```

### Sprint 3: UI Display (Giorno 3-4)
```
✅ FASE 5.1-5.4: Display alta priorita' (live, template, superset)
✅ FASE 5.5-5.7: Display media priorita' (history, overlay)
✅ Widget tests display
```

### Sprint 4: Polish & Release (Giorno 4-5)
```
✅ FASE 5.8-5.11: Display bassa priorita'
✅ FASE 6: Rep presets JSON (opzionale)
✅ Integration tests
✅ Manual testing checklist completo
✅ Documentation update
✅ Performance check
✅ Beta release
```

### (Opzionale) Sprint 5: Advanced
```
FASE 7: Analytics (range band, % in range)
```

---

## ✅ Definition of Done

- [ ] Tutte le 8 classi FASE 1 implementate con nuovi campi
- [ ] 4 flussi conversione FASE 2 propagano range
- [ ] Bug fix import FASE 3 preserva range end-to-end
- [ ] 4 widget input FASE 4 supportano range picker
- [ ] ~10 widget display FASE 5 mostrano range con coloring
- [ ] Unit tests passano (coverage >80% su nuovo codice)
- [ ] Widget tests passano
- [ ] Integration test workflow completo funziona
- [ ] Manual testing checklist 100% completato (15 scenari)
- [ ] Nessun breaking change verificato
- [ ] Backward compatibility 100% (vecchi dati funzionano)
- [ ] `.claude/scripts/performance-check.sh` passa
- [ ] `flutter analyze` passa senza warning
- [ ] `flutter gen-l10n` aggiornato se nuove stringhe
- [ ] Documentazione aggiornata (INDEX.md, CHANGELOG)

---

## 📖 Diff vs Analisi Sonnet 4.5

| Aspetto | Sonnet 4.5 | Opus 4.6 |
|---------|------------|----------|
| Classi analizzate | 6 | **8** (+DropSetStage, RestPauseSet, RestPauseExercise) |
| Edge cases | 2 | **7** (min>max, min==max, solo min/max, null+range, ecc.) |
| Flussi conversione | 2 | **4** (incl. Cloud Function `_exerciseToJson`) |
| Punti modifica totali | 14 file | **~25 file** con line numbers esatti |
| Cloud Function | "non necessario" | **Analisi specifica passthrough JSON** |
| RepRangePreset | Non menzionato | **Analizzato con proposta JSON** |
| Superset/Dropset/RestPause | Superficiale | **Analisi profonda**: range ha senso? come gestire? |
| Display widgets | 5 | **~12** (incl. SupersetCard, DropsetModal, RestPauseModal) |
| Testing scenarios | 11 | **15+** con code examples dettagliati |
| Backward compat | "funziona" | **4 scenari documentati** con Firestore JSON |

---

**Piano generato da**: team rep-range-opus (Opus 4.6)
**Data**: 2026-02-15
**Versione**: 2.0
**Status**: ✅ Ready for Review & Implementation
