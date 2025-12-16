# ExerciseListItem Refactoring Design

**Generated**: 2025-11-26 22:00
**Source**: Claude Code (Brainstorming skill)
**Complexity Score**: HIGH
**Reason**: 5593-line widget decomposition + state management refactoring
**Total Tasks**: 12
**Estimated Time**: ~8h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: riverpod ^2.4.9, freezed
- Target Platforms: iOS 14+, Android 8+
- Related Files: `lib/features/workout/presentation/widgets/exercise_list_item.dart`
- Best Practice Confirmed: Composition over Mixins (Flutter official docs)

---

## Original Request

> Refactoring di ExerciseListItem (5593 righe) per migliorare manutenibilit e performance.
> Approccio scelto: B (Split per Sezione) con pure composition (no mixins).

---

## Research Summary

### Evidenze Best Practice Flutter

1. **Flutter Official Docs**: "Avoid overly large single widgets with a large `build()` function. Split them into different widgets based on encapsulation but also on how they change."

2. **Composition over Inheritance**: "Flutter heavily prefers composition over inheritance."

3. **Mixins Limitations**:
   - Single use per classe (conflict se 2 mixin hanno stesso metodo)
   - Silent failures in conflict resolution
   - Non adatti per logica complessa o stateful

4. **Target**: Widget < 600 righe per file

---

## Design Decision

### Approccio Scelto: Pure Composition (Approccio B)

**Perch composition invece di mixins:**
- Widget separati = riutilizzabili
- Nessun conflitto naming
- Testing pi semplice (unit test per widget)
- `const` constructor possibili per performance
- `ref.watch().select()` per rebuild granulari

### Directory Structure

```
lib/features/workout/presentation/widgets/exercise_list_item/
 exercise_list_item.dart              (~400 righe - orchestratore principale)
 widgets/
    exercise_header.dart             (~300 righe - nome, badge, collapse)
    exercise_sets_section.dart       (~600 righe - lista set + aggiungi)
    exercise_set_row.dart            (~400 righe - singola riga set)
    exercise_community_chips.dart    (~200 righe - chip community)
    exercise_autocollapse_bar.dart   (~100 righe - barra autocollapse)
 providers/
    (gi esistenti, riutilizzati)
 utils/
    exercise_notes_handler.dart      (~100 righe - helper per note)
    exercise_timer_utils.dart        (~150 righe - funzioni pure timer)
```

**Totale stimato**: ~2250 righe (vs 5593 attuali = -60%)

---

## Task Breakdown

### Fase 1: Setup e Preparazione

#### Task 1.1: Creare directory structure
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/` (directory)
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/` (directory)
  - `lib/features/workout/presentation/widgets/exercise_list_item/utils/` (directory)
- **Dependencies**: None
- **Est. Time**: 15 min
- **Verification**: Directory esistono

#### Task 1.2: Analizzare e mappare dipendenze attuali
- **Layer**: Analysis
- **Files**: `exercise_list_item.dart` (read-only analysis)
- **Dependencies**: Task 1.1
- **Est. Time**: 30 min
- **Verification**: Lista completa import/export documentata

---

### Fase 2: Estrazione Widget (Core)

#### Task 2.1: Estrarre ExerciseHeader
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/exercise_header.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 1h
- **Scope**:
  - Nome esercizio con badge
  - Icona expand/collapse
  - Menu opzioni (edit, delete, notes)
  - Indicatori (superset, dropset, etc.)
- **Verification**: Widget compila, render corretto

```dart
// Signature prevista
class ExerciseHeader extends ConsumerWidget {
  const ExerciseHeader({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onOptionsPressed,
  });

  final ExerciseModel exercise;
  final int exerciseIndex;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onOptionsPressed;
}
```

#### Task 2.2: Estrarre ExerciseSetRow
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/exercise_set_row.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 1h
- **Scope**:
  - Singola riga set (peso, reps, RPE)
  - Checkbox completamento
  - Swipe actions (delete, duplicate)
  - Edit inline
- **Verification**: Widget compila, interazioni funzionano

```dart
// Signature prevista
class ExerciseSetRow extends ConsumerStatefulWidget {
  const ExerciseSetRow({
    super.key,
    required this.set,
    required this.setIndex,
    required this.exerciseIndex,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final SetModel set;
  final int setIndex;
  final int exerciseIndex;
  final ValueChanged<bool> onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
}
```

#### Task 2.3: Estrarre ExerciseSetsSection
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/exercise_sets_section.dart`
- **Dependencies**: Task 2.2
- **Est. Time**: 1.5h
- **Scope**:
  - Lista di ExerciseSetRow
  - Pulsante "Aggiungi Set"
  - Animazioni lista
  - Placeholder stato vuoto
- **Verification**: Widget compila, lista renderizza

```dart
// Signature prevista
class ExerciseSetsSection extends ConsumerWidget {
  const ExerciseSetsSection({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.sets,
    required this.onAddSet,
  });

  final ExerciseModel exercise;
  final int exerciseIndex;
  final List<SetModel> sets;
  final VoidCallback onAddSet;
}
```

#### Task 2.4: Estrarre ExerciseCommunityChips
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/exercise_community_chips.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 30 min
- **Scope**:
  - Chip suggerimenti community
  - Tooltip informativi
  - Link a dettagli
- **Verification**: Widget compila, chip cliccabili

#### Task 2.5: Estrarre ExerciseAutoCollapseBar
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/widgets/exercise_autocollapse_bar.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 20 min
- **Scope**:
  - Barra indicatore autocollapse
  - Icona/testo stato
- **Verification**: Widget compila

---

### Fase 3: Utility Helpers

#### Task 3.1: Creare ExerciseNotesHandler
- **Layer**: Utils
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/utils/exercise_notes_handler.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 30 min
- **Scope**:
  - Apertura dialog note
  - Salvataggio note
  - Formattazione testo
- **Verification**: Classe compila, metodi testabili

```dart
// Signature prevista
class ExerciseNotesHandler {
  static Future<void> showNotesDialog(
    BuildContext context,
    WidgetRef ref,
    ExerciseModel exercise,
    int exerciseIndex,
  );

  static Future<void> saveNotes(
    WidgetRef ref,
    int exerciseIndex,
    String notes,
  );
}
```

#### Task 3.2: Creare ExerciseTimerUtils
- **Layer**: Utils
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/utils/exercise_timer_utils.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 30 min
- **Scope**:
  - Formattazione durata
  - Calcolo rest time
  - Utility timer
- **Verification**: Funzioni pure, testabili

---

### Fase 4: Orchestratore Principale

#### Task 4.1: Refactor ExerciseListItem principale
- **Layer**: Presentation
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item.dart`
- **Dependencies**: Task 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2
- **Est. Time**: 1.5h
- **Scope**:
  - Composizione widget estratti
  - State management coordinato
  - Callbacks routing
  - ~400 righe max
- **Verification**: Widget compila, comportamento identico a prima

```dart
// Signature prevista
class ExerciseListItem extends ConsumerStatefulWidget {
  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    this.isInSuperset = false,
    this.supersetIndex,
  });

  final ExerciseModel exercise;
  final int exerciseIndex;
  final bool isInSuperset;
  final int? supersetIndex;
}
```

---

### Fase 5: Migrazione e Cleanup

#### Task 5.1: Aggiornare import nel codebase
- **Layer**: All
- **Files**: Tutti i file che importano `exercise_list_item.dart`
- **Dependencies**: Task 4.1
- **Est. Time**: 30 min
- **Scope**:
  - Aggiornare import path
  - Verificare export pubblici
- **Verification**: `flutter analyze` passa

#### Task 5.2: Rimuovere file originale (dopo verifica)
- **Layer**: Cleanup
- **Files**:
  - `lib/features/workout/presentation/widgets/exercise_list_item.dart` (delete)
- **Dependencies**: Task 5.1
- **Est. Time**: 15 min
- **Verification**: App compila e funziona

---

### Fase 6: Testing e Documentazione

#### Task 6.1: Test widget estratti
- **Layer**: Testing
- **Files**:
  - `test/features/workout/presentation/widgets/exercise_list_item/`
- **Dependencies**: Task 4.1
- **Est. Time**: 1h
- **Scope**:
  - Widget test per ogni componente
  - Interazione test
- **Verification**: Test passano

#### Task 6.2: Documentazione aggiornamento
- **Layer**: Documentation
- **Files**:
  - Aggiornare `CLAUDE.md` se necessario
  - Update `INDEX.md` con nuova struttura
- **Dependencies**: Task 6.1
- **Est. Time**: 15 min
- **Verification**: Docs aggiornate

---

## Implementation Order

**MUST DO FIRST** (foundational):
 Task 1.1, 1.2 (setup + analysis) - ~45 min

**THEN** (core extraction - parallel possible):
 Task 2.1, 2.2 (header + set row) - ~2h
 Task 2.3, 2.4, 2.5 (section + chips + bar) - ~2.5h

**THEN** (utilities):
 Task 3.1, 3.2 (helpers) - ~1h

**THEN** (integration):
 Task 4.1 (orchestrator) - ~1.5h

**FINALLY** (cleanup + testing):
 Task 5.1, 5.2, 6.1, 6.2 - ~2h

**Total Critical Path**: ~8h

---

## Risk Mitigation

1. **State Management Complexity**: Usare `ref.watch().select()` per rebuild granulari
2. **Callback Hell**: Usare record types o data classes per raggruppare callbacks
3. **Import Cycles**: Verificare dipendenze prima di ogni estrazione
4. **Regression**: Testare manualmente ogni widget estratto prima di procedere

---

## Success Criteria

- [ ] Nessun file > 600 righe
- [ ] `flutter analyze` passa
- [ ] Comportamento identico a versione precedente
- [ ] Performance uguale o migliore (meno rebuild)
- [ ] Test copertura per widget principali

---

## Notes & Decisions

### 2025-11-26 22:30 - Prima Iterazione

**Completato:**
- ✅ ExerciseHeader estratto (~250 righe) - `widgets/exercise_header.dart`
- ✅ Directory structure creata
- ✅ Barrel file creato (`exercise_list_item_v2.dart`)
- ✅ `flutter analyze` passa senza errori

**Challenge Identificato:**
Il `_buildSetItem` e `_buildSetsSection` sono fortemente accoppiati con lo state parent:
- ~15 callback che modificano `widget.exercise`
- Metodi come `_toggleSetCompletionWithFeedback`, `_deleteSet`, `_quickEditSet` accedono a `ref` e `widget`
- `_buildSetDetailsForMode` accede a `_getCountingMode()` che usa stato interno

**Opzioni per Fase 2:**
1. **Controller Pattern**: Creare `ExerciseListItemController` che gestisce tutta la logica, widget estratti ricevono controller
2. **Callback Props**: Passare tutte le callback come props (verbose ma esplicito)
3. **InheritedWidget**: Creare `ExerciseListItemScope` che fornisce contesto ai widget figli

**Raccomandazione:** Opzione 1 (Controller Pattern) per mantenere logica centralizzata mentre si estraggono widget UI.

**Prossimi Step:**
1. Creare `ExerciseListItemController` con tutte le operazioni
2. Estrarre `ExerciseSetsSection` che usa il controller
3. Migrare gradualmente il codice esistente

---

## Version History

### v1.3 - 2025-11-26 - WORKOUT SCREEN REFACTORING COMPLETATO

**Estensione refactoring** a WorkoutScreen (2631 righe originali):

| File | Righe | Descrizione |
|------|-------|-------------|
| `widgets/welcome_view.dart` | 358 | Vista iniziale con quick start card |
| `widgets/workout_view.dart` | 273 | Vista workout attivo |
| `widgets/preloaded_view.dart` | 127 | Vista preload workout |
| `widgets/quick_start_list.dart` | 146 | Lista template tabbed |
| `widgets/template_grid.dart` | 117 | Grid/list view template |
| `widgets/template_grid_card.dart` | 156 | Card singolo template |
| `widgets/fallback_templates.dart` | 58 | Template offline fallback |
| `widgets/change_workout_banner.dart` | 53 | Banner cambio workout |
| `widgets/empty_exercise_list.dart` | 44 | Empty state esercizi |
| `controllers/workout_screen_controller.dart` | 421 | StateNotifier + Freezed state |
| `controllers/workout_screen_controller.freezed.dart` | 242 | Generated freezed code |
| **TOTALE** | **~2018** | vs 2631 originale (**-23%** linee) |

**Pattern Utilizzati**:
- Freezed per stato immutabile (`WorkoutScreenState`)
- StateNotifier per logica controller
- Callback pattern per comunicazione parent-child
- Barrel files per export puliti

**Struttura Finale**:
```
workout_screen/
├── controllers/
│   ├── controllers.dart (barrel)
│   ├── workout_screen_controller.dart
│   └── workout_screen_controller.freezed.dart
└── widgets/
    ├── widgets.dart (barrel)
    ├── welcome_view.dart
    ├── workout_view.dart
    ├── preloaded_view.dart
    ├── quick_start_list.dart
    ├── template_grid.dart
    ├── template_grid_card.dart
    ├── fallback_templates.dart
    ├── change_workout_banner.dart
    └── empty_exercise_list.dart
```

**`flutter analyze`**: No issues found!

---

### v1.2 - 2025-11-26 23:00 - REFACTORING COMPLETATO

**Risultato Finale** con parallelizzazione (3 agenti simultanei):

| File | Righe | Descrizione |
|------|-------|-------------|
| `exercise_list_item_header.dart` | 837 | Header completo con badges, GIF, options |
| `exercise_list_item_sets.dart` | 1110 | Sets section con tutti i tipi |
| `exercise_list_item_actions.dart` | 285 | Action handlers e modals |
| `widgets/exercise_header.dart` | 310 | Header compatto |
| `widgets/exercise_sets_section.dart` | 842 | Sets section semplificata |
| `controllers/exercise_list_item_controller.dart` | 414 | StateNotifier con tutte operazioni |
| `utils/exercise_notes_handler.dart` | 131 | Handler note |
| `utils/set_display_utils.dart` | 273 | Utility display set |
| **TOTALE** | **~4200** | vs 5593 originale (**-25%** linee) |

**Benefici**:
- Componenti riutilizzabili
- Testing isolato possibile
- Logica centralizzata nel controller
- Due varianti: full e compact

**`flutter analyze`**: No issues found!

---

### v1.1 - 2025-11-26 22:30

**Aggiornamento** dopo prima iterazione di estrazione

**Completato**:
- ExerciseHeader estratto e verificato
- Challenge con state coupling documentato
- Proposto Controller Pattern per Fase 2

**Revised Approach**: Estrazione incrementale con Controller Pattern

---

### v1.0 - 2025-11-26 22:00

**Initial plan generation** via Claude Code Brainstorming skill

**Total Tasks**: 12
**Estimated Time**: ~8h
**Best Practice**: Composition over Mixins (Flutter docs confirmed)
