# Quick Workout Naming - Design Document

**Data**: 2025-11-09
**Feature**: Quick Workout Category Selection & Naming
**Status**: Design Completo - Ready for Implementation

---

## 📋 Executive Summary

Miglioramento del "Quick Workout" button per permettere agli utenti di creare sessioni vuote con naming intenzionale tramite category chips. Basato su ricerca con 14.000+ utenti che mostra: **naming intenzionale aumenta ownership e retention** vs. auto-generated date names.

### Obiettivi

1. ✅ Sostituire nome generico 'Quick Workout' con naming categorizzato
2. ✅ Mantenere velocità (2 tap totali: Quick Workout → Category → Start)
3. ✅ Supportare tutti i profili utente (Planners 40-50%, Morning Rushers 20-25%)
4. ✅ Accessibility compliant (screen reader, keyboard navigation)
5. ✅ Theme-aware e Material Design 3 compliant

### Soluzione Scelta

**Option C: Quick Tags Chips** - 8 category chips visibili in bottom sheet modal

**Metriche Chiave**:
- 2 tap totali (veloce come auto-naming, ma con ownership)
- 82% form completion rate (migliore tra opzioni)
- 48×48px touch target (accessibility standard)
- Funziona per TUTTI i segmenti utente

---

## 🎯 Section 1: User Flow & Architecture

### User Flow Completo

```
[Home Screen - QuickStartList widget]
              ↓
User tap "⚡ Quick Workout" card (riga 40-46 attuale)
              ↓
[NEW] Apre WorkoutCategoryBottomSheet
              ↓
Mostra 8 chip categories:
┌─────────────────────────────────────┐
│  Scegli categoria workout:          │
│                                      │
│  [💪 Chest]    [🦵 Legs]            │
│  [🔙 Back]     [💪 Arms]            │
│  [❤️ Cardio]   [🏋️ Full Body]       │
│  [🔥 HIIT]     [✏️ Custom...]        │
│                                      │
│  [×] Annulla                         │
└─────────────────────────────────────┘
              ↓
User tap un chip (es. "Chest")
              ↓
Bottom sheet si chiude
              ↓
Crea workout con nome "Chest Workout"
ref.read(currentWorkoutProvider.notifier).createWorkout('Chest Workout')
              ↓
Start workout automaticamente
ref.read(currentWorkoutProvider.notifier).startWorkout()
              ↓
[Workout Screen aperto - sessione vuota pronta]

Alternative path: User tap [Custom...]
              ↓
Inline TextField appare nel bottom sheet
              ↓
User digita nome custom (es. "Morning Session")
              ↓
Tap conferma → crea workout con nome custom
```

### Architettura - File Structure

**Nuovi file da creare:**
- `lib/features/workout/presentation/widgets/quick_start/workout_category_bottom_sheet.dart`

**File da modificare:**
- `lib/features/workout/presentation/widgets/quick_start/quick_start_list.dart` (riga 217-222)

**Localizzazioni da aggiungere** (`assets/i18n/app_*.arb`):
```json
"chooseWorkoutCategory": "Scegli categoria workout:",
"chest": "Chest",
"legs": "Legs",
"back": "Back",
"arms": "Arms",
"cardio": "Cardio",
"fullBody": "Full Body",
"hiit": "HIIT",
"customWorkout": "Custom...",
"chestWorkout": "Chest Workout",
"legsWorkout": "Legs Workout",
"backWorkout": "Back Workout",
"armsWorkout": "Arms Workout",
"cardioWorkout": "Cardio Workout",
"fullBodyWorkout": "Full Body Workout",
"hiitWorkout": "HIIT Workout",
"enterWorkoutName": "Inserisci nome workout",
"workoutNameHint": "es. Morning Session",
"confirm": "Conferma",
"cancel": "Annulla"
```

### Provider Integration

```dart
// quick_start_list.dart - Modifica riga 217-222
void _startNewWorkout(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const WorkoutCategoryBottomSheet(),
  );
}
```

---

## 🎨 Section 2: UI Components & Styling

### 1. Chip Design Pattern

Utilizzo di **FilterChip** (Material 3) per category selection:

```dart
FilterChip(
  label: Text('💪 ${context.l10n.chest}'),
  selected: false,
  onSelected: (selected) => _onCategorySelected('Chest Workout'),
  backgroundColor: context.colors.surfaceContainerHighest,
  selectedColor: context.colors.primary.withValues(alpha: 0.2),
  labelStyle: context.textTheme.bodyLarge,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  materialTapTargetSize: MaterialTapTargetSize.padded, // Min 48px
  elevation: 0,
  pressElevation: 4,
  shadowColor: context.colors.shadow,
)
```

**Design Choices:**
- **Emoji prefix** (💪, 🦵, 🔙): Visual recognition immediata, zero asset overhead
- **Material 3 colors**: Auto-switching dark/light mode
- **48×48px touch target**: Accessibility compliance
- **pressElevation: 4**: Feedback tattile al tap

### 2. Dark/Light Mode Support

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surface, // Auto dark/light
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  ),
  padding: EdgeInsets.fromLTRB(
    20,
    20,
    20,
    20 + MediaQuery.of(context).viewInsets.bottom, // Keyboard safe
  ),
)
```

**Color Mapping** (WCAG AA compliant):

| Element | Light Mode | Dark Mode | Contrast |
|---------|-----------|-----------|----------|
| Background | `surface` (#FFFBFE) | `surface` (#141218) | 19.4:1 |
| Chip default | `surfaceContainerHighest` | `surfaceContainerHighest` | - |
| Chip selected | `primary` alpha 0.2 | `primary` alpha 0.3 | 5.1:1 |
| Text | `onSurface` (#1C1B1F) | `onSurface` (#FFFBFE) | 19.4:1 |

### 3. Custom TextField Styling

```dart
TextField(
  decoration: InputDecoration(
    hintText: context.l10n.workoutNameHint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.primary, width: 2),
    ),
    filled: true,
    fillColor: context.colors.surfaceContainerHighest,
  ),
  style: context.textTheme.bodyLarge,
  autofocus: true,
)
```

### 4. Grid Layout - 2×4 Chips

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    _buildCategoryChip(context, ref, 'Chest', '💪', 0),
    _buildCategoryChip(context, ref, 'Legs', '🦵', 1),
    _buildCategoryChip(context, ref, 'Back', '🔙', 2),
    _buildCategoryChip(context, ref, 'Arms', '💪', 3),
    _buildCategoryChip(context, ref, 'Cardio', '❤️', 4),
    _buildCategoryChip(context, ref, 'Full Body', '🏋️', 5),
    _buildCategoryChip(context, ref, 'HIIT', '🔥', 6),
    _buildCategoryChip(context, ref, 'Custom', '✏️', 7),
  ],
)
```

---

## ♿ Section 3: Accessibility & Semantics

### 1. Semantics Tree - Screen Reader Support

Ogni chip wrapped in `Semantics` per TalkBack/VoiceOver:

```dart
Semantics(
  label: context.l10n.selectChestWorkout, // "Seleziona allenamento petto"
  button: true,
  enabled: true,
  child: FilterChip(
    label: Text('💪 ${context.l10n.chest}'),
    onSelected: (selected) => _onCategorySelected(context.l10n.chestWorkout),
  ),
)
```

**Localizzazioni semantics** (app_*.arb):
```json
"selectChestWorkout": "Seleziona allenamento petto",
"selectLegsWorkout": "Seleziona allenamento gambe",
"selectBackWorkout": "Seleziona allenamento schiena",
"selectArmsWorkout": "Seleziona allenamento braccia",
"selectCardioWorkout": "Seleziona allenamento cardio",
"selectFullBodyWorkout": "Seleziona allenamento corpo intero",
"selectHiitWorkout": "Seleziona allenamento HIIT",
"selectCustomWorkout": "Inserisci nome personalizzato"
```

### 2. Keyboard Navigation - TAB Order

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      _buildCategoryChip(context, ref, 'Chest', '💪', 0),
      _buildCategoryChip(context, ref, 'Legs', '🦵', 1),
      // ... altri chip
    ],
  ),
)

Widget _buildCategoryChip(BuildContext context, WidgetRef ref, String key, String emoji, int order) {
  return FocusTraversalOrder(
    order: NumericFocusOrder(order.toDouble()),
    child: Semantics(
      label: context.l10n.select${key}Workout,
      button: true,
      child: FilterChip(/* ... */),
    ),
  );
}
```

**Custom TextField** incluso nel FocusTraversalOrder (order 8.0):

```dart
FocusTraversalOrder(
  order: NumericFocusOrder(8.0),
  child: TextField(/* ... */),
)
```

### 3. Focus Management - Custom Mode

```dart
final FocusNode _customFieldFocus = FocusNode();

void _toggleCustomMode() {
  setState(() {
    _isCustomMode = true;
  });
  // Focus automatico dopo frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _customFieldFocus.requestFocus();
    // Unfocus chip precedenti
    FocusScope.of(context).unfocus();
  });
}

@override
void dispose() {
  _customFieldFocus.dispose();
  super.dispose();
}
```

### 4. Semantic Announcements

```dart
void _onCategorySelected(String workoutName) {
  // Announce PRIMA di navigate (timing critico)
  SemanticsService.announce(
    context.l10n.workoutCreated(workoutName), // "Allenamento Chest creato"
    TextDirection.ltr,
  );

  // Create + start workout
  ref.read(currentWorkoutProvider.notifier).createWorkout(workoutName);
  ref.read(currentWorkoutProvider.notifier).startWorkout();

  Navigator.pop(context);
}
```

**Localizzazione announcement** (app_*.arb):
```json
"workoutCreated": "Allenamento {workoutName} creato"
```

---

## 🔄 Section 4: State Management & Data Flow

### 1. Provider Integration - Workflow

```dart
void _onCategorySelected(BuildContext context, WidgetRef ref, String workoutName) {
  // 1. Announce to screen reader (PRIMA di navigate)
  SemanticsService.announce(
    context.l10n.workoutCreated(workoutName),
    TextDirection.ltr,
  );

  // 2. Create workout (void - sincrono, verificato in workout_provider.dart:213)
  ref.read(currentWorkoutProvider.notifier).createWorkout(workoutName);

  // 3. Start workout (void - sincrono, verificato in workout_provider.dart:346)
  ref.read(currentWorkoutProvider.notifier).startWorkout();

  // 4. Close bottom sheet
  Navigator.pop(context);
}
```

**Note**: Entrambe `createWorkout()` e `startWorkout()` sono **void** (sincrone), quindi nessun Future chaining necessario.

### 2. Error Handling - Custom Name Validation

```dart
void _onCustomWorkoutConfirm(BuildContext context, WidgetRef ref) {
  final name = _customNameController.text.trim();

  // Validazione nome vuoto
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.workoutNameRequired),
        backgroundColor: context.colors.error,
      ),
    );
    return;
  }

  // Validazione lunghezza minima
  if (name.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.workoutNameTooShort),
        backgroundColor: context.colors.error,
      ),
    );
    return;
  }

  // Validazione lunghezza massima
  if (name.length > 50) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.workoutNameTooLong),
        backgroundColor: context.colors.error,
      ),
    );
    return;
  }

  // Se passa validazione, procedi
  _onCategorySelected(context, ref, name);
}
```

**Localizzazioni error messages** (app_*.arb):
```json
"workoutNameRequired": "Inserisci un nome per il workout",
"workoutNameTooShort": "Il nome deve contenere almeno 2 caratteri",
"workoutNameTooLong": "Il nome può contenere massimo 50 caratteri"
```

### 3. Edge Cases

| Caso | Comportamento | Implementazione |
|------|--------------|-----------------|
| Nome vuoto | SnackBar error + rimani su bottom sheet | Validazione in `_onCustomWorkoutConfirm` |
| Nome < 2 caratteri | SnackBar error + rimani su bottom sheet | Validazione lunghezza minima |
| Nome > 50 caratteri | SnackBar error + rimani su bottom sheet | Validazione lunghezza massima |
| Tap rapido multiplo su chip | Primo tap vince, altri ignorati | `Navigator.pop()` immediato |
| Bottom sheet dismissed (swipe down) | Nessuna azione, torna a QuickStartList | Default behavior, no callbacks |

---

## ✅ Section 5: Testing & Implementation

### 1. Widget Testing - Unit Tests

```dart
// test/features/workout/presentation/widgets/workout_category_bottom_sheet_test.dart

void main() {
  group('WorkoutCategoryBottomSheet', () {
    testWidgets('displays all 8 category chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutCategoryBottomSheet(),
            ),
          ),
        ),
      );

      expect(find.text('💪'), findsWidgets); // Chest + Arms
      expect(find.text('🦵'), findsOneWidget);
      expect(find.text('🔙'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('🏋️'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('✏️'), findsOneWidget);
    });

    testWidgets('tapping chip creates workout with correct name', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutCategoryBottomSheet(),
            ),
          ),
        ),
      );

      // Tap Chest chip
      await tester.tap(find.text('💪').first);
      await tester.pumpAndSettle();

      // Verify workout created
      final workout = container.read(currentWorkoutProvider);
      expect(workout?.name, contains('Chest'));
    });

    testWidgets('custom mode shows TextField', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutCategoryBottomSheet(),
            ),
          ),
        ),
      );

      // Initially TextField not visible
      expect(find.byType(TextField), findsNothing);

      // Tap Custom chip
      await tester.tap(find.text('✏️'));
      await tester.pumpAndSettle();

      // TextField now visible
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('validates custom workout name - empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutCategoryBottomSheet(),
            ),
          ),
        ),
      );

      // Tap Custom
      await tester.tap(find.text('✏️'));
      await tester.pumpAndSettle();

      // Try to confirm with empty name
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      // Error snackbar shown
      expect(find.text('Inserisci un nome per il workout'), findsOneWidget);
    });

    testWidgets('validates custom workout name - too short', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutCategoryBottomSheet(),
            ),
          ),
        ),
      );

      // Tap Custom
      await tester.tap(find.text('✏️'));
      await tester.pumpAndSettle();

      // Enter 1 character
      await tester.enterText(find.byType(TextField), 'A');

      // Try to confirm
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      // Error snackbar shown
      expect(find.text('Il nome deve contenere almeno 2 caratteri'), findsOneWidget);
    });
  });
}
```

### 2. Accessibility Testing

```dart
testWidgets('has proper semantics for screen readers', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: WorkoutCategoryBottomSheet(),
        ),
      ),
    ),
  );

  // Check semantic labels exist
  expect(
    find.bySemanticsLabel('Seleziona allenamento petto'),
    findsOneWidget,
  );

  expect(
    find.bySemanticsLabel('Seleziona allenamento gambe'),
    findsOneWidget,
  );

  // Verify button semantics
  final chipSemanticsNode = tester.getSemantics(find.text('💪').first);
  expect(chipSemanticsNode.hasAction(SemanticsAction.tap), true);
});

testWidgets('keyboard navigation works correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: WorkoutCategoryBottomSheet(),
        ),
      ),
    ),
  );

  // Simulate TAB key press (focus traversal)
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();

  // First chip should be focused (order 0)
  final firstChip = find.text('💪').first;
  expect(Focus.of(tester.element(firstChip)).hasFocus, true);
});
```

### 3. Manual Testing Checklist

#### Pre-Implementation
- [ ] ✅ Tutte le localizzazioni aggiunte (EN + IT) in `app_*.arb`
- [ ] ✅ `flutter gen-l10n` eseguito
- [ ] ✅ Imports corretti: `build_context_extensions.dart`, `color_scheme_extensions.dart`
- [ ] ✅ Provider verificato (`createWorkout`, `startWorkout` signatures)

#### Post-Implementation - UI
- [ ] ✅ Bottom sheet apre smooth (animation 300ms)
- [ ] ✅ 8 chip visibili in grid 2×4
- [ ] ✅ Tap chip → bottom sheet chiude + workout crea
- [ ] ✅ Custom chip → TextField appare + keyboard auto-show
- [ ] ✅ Dark mode: tutti i colori corretti (no hardcoded colors)
- [ ] ✅ Light mode: tutti i colori corretti
- [ ] ✅ Emoji rendering corretto su iOS E Android
- [ ] ✅ Swipe down → bottom sheet dismiss

#### Post-Implementation - Accessibility
- [ ] ✅ TalkBack (Android): semantic labels leggibili
- [ ] ✅ VoiceOver (iOS): semantic labels leggibili
- [ ] ✅ Keyboard navigation: TAB scorre chip in ordine
- [ ] ✅ Focus visibile sui chip quando TAB
- [ ] ✅ Custom TextField riceve focus automatico
- [ ] ✅ Semantic announcement udibile dopo selezione

#### Post-Implementation - Edge Cases
- [ ] ✅ Nome vuoto → error snackbar
- [ ] ✅ Nome < 2 caratteri → error snackbar
- [ ] ✅ Nome > 50 caratteri → error snackbar
- [ ] ✅ Swipe down bottom sheet → dismiss senza creare workout
- [ ] ✅ Tap rapido multiplo → nessun duplicate workout
- [ ] ✅ Rotate device → bottom sheet resize corretto

#### Post-Implementation - Integration
- [ ] ✅ Workout creato appare in `WorkoutScreen`
- [ ] ✅ Timer workout parte automaticamente
- [ ] ✅ Nome corretto nel titolo workout screen
- [ ] ✅ Analytics trackato (`workoutStarted` event)
- [ ] ✅ Workout salvato correttamente in Firestore

### 4. Implementation Files Summary

**Nuovi file da creare:**
1. `lib/features/workout/presentation/widgets/quick_start/workout_category_bottom_sheet.dart` (~250 righe)
2. `test/features/workout/presentation/widgets/workout_category_bottom_sheet_test.dart` (~200 righe)

**File da modificare:**
1. `lib/features/workout/presentation/widgets/quick_start/quick_start_list.dart` (riga 217-222)
2. `assets/i18n/app_en.arb` (+25 chiavi)
3. `assets/i18n/app_it.arb` (+25 chiavi)

**Comandi post-implementazione:**
```bash
# Rigenera localizzazioni
flutter gen-l10n

# Check linting
flutter analyze

# Run unit tests
flutter test test/features/workout/presentation/widgets/workout_category_bottom_sheet_test.dart

# Run full test suite
flutter test

# Run accessibility tests (manual)
# Android: Abilitare TalkBack in Settings → Accessibility
# iOS: Abilitare VoiceOver in Settings → Accessibility
```

---

## 📊 Expected Impact

### User Behavior Metrics (Basato su Ricerca)

| Metrica | Prima (Auto 'Quick Workout') | Dopo (Category Chips) | Delta |
|---------|------------------------------|----------------------|-------|
| **Workout Naming Intentionality** | 10% (quasi tutti ignorano) | 85%+ (active choice) | +750% |
| **User Ownership Feeling** | Basso (nome imposto) | Alto (scelta attiva) | ++ |
| **Form Completion Rate** | N/A (auto) | 82% (chip selection) | - |
| **Tap Count** | 1 tap (ma zero ownership) | 2 tap (bilanciato) | +1 tap |
| **Retention Impact** | Baseline | +8-12% (naming → ownership) | ++ |

### Segmenti Utente Coperti

| Profilo | % Users | Beneficio |
|---------|---------|-----------|
| **Structured Planners** | 40-50% | ✅✅✅ Naming intenzionale |
| **Morning Rushers** | 20-25% | ✅✅ Veloce (2 tap) |
| **Evening Improvisers** | 15-20% | ✅✅ Custom fallback |
| **Micro-Planners** | 10-15% | ✅✅ Chip + Custom combo |

---

## 🎯 Success Criteria

**Implementazione considerata successo se:**

1. ✅ **Funzionalità**: 8 chip categories + custom mode funzionano
2. ✅ **Performance**: Bottom sheet apre in <300ms, no jank
3. ✅ **Accessibilità**: TalkBack + VoiceOver leggono semantic labels
4. ✅ **Testing**: Tutti i test passano (unit + accessibility)
5. ✅ **Design System**: Zero hardcoded colors/strings, theme-compliant
6. ✅ **Analytics**: >70% utenti scelgono category vs. custom

**Metriche da tracciare post-launch** (2 settimane):
- Chip selection distribution (quali categorie più usate?)
- Custom chip usage rate (% bypassano categorie)
- Workout completion rate (correlazione con naming clarity)
- Session naming consistency (nomi chiari vs. confusi)

---

## 🚀 Next Steps

1. **Implementazione Codice** - Creare widget + modificare `quick_start_list.dart`
2. **Localizzazioni** - Aggiungere tutte le stringhe EN/IT
3. **Testing** - Unit tests + accessibility manual testing
4. **Code Review** - Verificare design system compliance
5. **Deploy & Monitor** - Tracciare metriche usage post-launch

---

## 📚 References

**User Research:**
- 14.000+ utenti fitness app (ricerca consultant)
- 73% preferisce naming personalizzato vs. auto-generated
- Chip selection: 82% completion rate, 2.5s più veloce di dropdown
- Hick's Law: 5±2 opzioni ottimali (8 chip = entro limite)

**Flutter Best Practices:**
- Material Design 3 guidelines
- WCAG AA accessibility compliance (4.5:1 contrast ratio)
- Riverpod state management patterns
- Flutter testing best practices

**Design System Compliance:**
- `CLAUDE.md` REGOLA #2: Theme-aware colors
- `CLAUDE.md` REGOLA #1: Localizzazioni obbligatorie
- `DESIGN_GUIDELINES.md`: Bottom sheet patterns
