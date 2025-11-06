# APRE System Improvements - Design Document

**Date**: 2025-11-06
**Status**: ✅ Approved
**Related**: `lib/features/workout/presentation/widgets/auto_adjustment_modal.dart`, `lib/features/workout/domain/services/apre_auto_regulation_service.dart`

---

## 📋 Executive Summary

This document outlines improvements to the APRE (Auto-Regulated Progressive Resistance Exercise) system based on user feedback from manual testing. The improvements focus on:

1. **Protocol Auto-Selection Refinement**: Update thresholds to better match rep ranges (1-5→APRE-3, 6-8→APRE-6, 9+→APRE-10)
2. **Reps Inconsistency Detection**: Prevent APRE usage when sets have too different rep counts (>4 reps range)
3. **User Guidance**: Info Card with clear CTAs when APRE is unavailable

**Rationale**: The current system is too conservative (10 reps→APRE-6) and doesn't handle inconsistent reps, leading to suboptimal protocol selection and potential user confusion.

---

## 🎯 Design Goals

1. **Accuracy**: Protocol selection should match user's actual training intent (10 reps = endurance → APRE-10)
2. **Safety**: Block APRE when reps are inconsistent (3, 8, 12 reps = unclear intent)
3. **User Guidance**: Clear explanation + actionable CTAs when APRE is unavailable
4. **Maintainability**: Simple threshold logic with comprehensive tests

---

## 📊 Section 1: Protocol Auto-Selection Thresholds

### Current Behavior (Problematic)

```dart
// lib/features/workout/domain/services/apre_auto_regulation_service.dart:90
static int selectProtocolFromTargetReps(int targetReps) {
  if (targetReps <= 5) return 3;  // APRE-3 (Strength)
  if (targetReps <= 10) return 6; // APRE-6 (Hypertrophy) ❌ TOO WIDE
  return 10;                       // APRE-10 (Endurance)
}
```

**Problem**: 10 reps should be endurance training (APRE-10), not hypertrophy (APRE-6).

### New Behavior (Approved)

```dart
static int selectProtocolFromTargetReps(int targetReps) {
  if (targetReps <= 5) return 3;  // APRE-3 (Strength: 1-5 reps)
  if (targetReps <= 8) return 6;  // APRE-6 (Hypertrophy: 6-8 reps) ✅ REFINED
  return 10;                       // APRE-10 (Endurance: 9+ reps)
}
```

**Rationale**:
- **1-5 reps**: Strength focus (heavy weight, low reps) → APRE-3
- **6-8 reps**: Hypertrophy focus (moderate weight, moderate reps) → APRE-6
- **9+ reps**: Endurance focus (lighter weight, high reps) → APRE-10

**Scientific Basis**: Aligns with standard strength training periodization (NSCA guidelines).

---

## 🔍 Section 2: Reps Inconsistency Detection

### Problem Statement

Users may create sets with wildly different rep counts (e.g., 3, 8, 12 reps). APRE requires consistent intent - you can't train for strength AND endurance simultaneously.

### Detection Algorithm

```dart
// Check if reps are too inconsistent for APRE
bool _hasInconsistentReps() {
  final validSets = widget.exercise.sets
      .where((set) => set.reps != null && set.reps! > 0 && !set.isWarmup)
      .toList();

  if (validSets.length < 2) return false; // Need 2+ sets to compare

  final repsValues = validSets.map((s) => s.reps!).toList();
  final minReps = repsValues.reduce(min);
  final maxReps = repsValues.reduce(max);
  final repsRange = maxReps - minReps;

  return repsRange > 4; // Threshold: 4 reps difference
}
```

### Threshold Justification: 4 Reps

**Why 4 reps?**
- ✅ **Flexible**: Allows 8, 10, 12 reps (range: 4) → valid for APRE-10
- ✅ **Strict enough**: Blocks 3, 8, 12 reps (range: 9) → too inconsistent
- ✅ **User-friendly**: Not overly restrictive (most users naturally vary ±2 reps per set)

**Examples**:
| Sets | Min | Max | Range | APRE Allowed? |
|------|-----|-----|-------|---------------|
| 8, 10, 12 | 8 | 12 | 4 | ✅ Yes (exactly at threshold) |
| 3, 3, 5 | 3 | 5 | 2 | ✅ Yes (consistent strength) |
| 10, 12, 12 | 10 | 12 | 2 | ✅ Yes (consistent endurance) |
| 3, 8, 12 | 3 | 12 | 9 | ❌ No (mixed strength/endurance) |
| 5, 10, 15 | 5 | 15 | 10 | ❌ No (too varied) |

### User Behavior

When inconsistent reps detected:
1. **Auto-disable APRE**: Radio button disabled + Info Card shown
2. **Provide guidance**: Show current reps, explain requirement, suggest fix
3. **Actionable CTAs**: "Modifica Set" (primary) + "Usa RPE" (secondary)

**Legal Consideration**: Auto-disabling (vs. warning + allowing) protects developer from liability if user ignores warning and gets injured from inappropriate APRE protocol.

---

## 🎨 Section 3: Warning Card UI Design

### Complete Info Card Component

```dart
// Shown when _hasInconsistentReps() == true
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.colors.errorContainer,
    border: Border.all(color: context.colors.error, width: 1.5),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🔴 Header
      Row(
        children: [
          Icon(AppIcons.error, size: AppIconSize.medium, color: context.colors.error),
          const SizedBox(width: 8),
          Text(
            context.l10n.apreNotAvailable,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onErrorContainer,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // 📝 Body - Current Reps Display
      Text(
        context.l10n.apreInconsistentRepsMessage(_repsDisplay, _repsRange),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onErrorContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),

      // 📋 Requirement
      Text(
        context.l10n.apreRequiresConsistentReps,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onErrorContainer,
        ),
      ),
      const SizedBox(height: 12),

      // 💡 Suggestion
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(AppIcons.lightbulb, size: AppIconSize.small, color: context.colors.tertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.apreSuggestConsistentReps,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 🎯 CTA Buttons
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _handleModifySets,
              icon: Icon(AppIcons.edit, size: AppIconSize.small),
              label: Text(context.l10n.modifySets),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleUseRPE,
              icon: Icon(AppIcons.gauge, size: AppIconSize.small),
              label: Text(context.l10n.useRPE),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.onErrorContainer,
                side: BorderSide(color: context.colors.onErrorContainer),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)
```

### State Fields Needed

```dart
bool _hasInconsistentReps = false;
String _repsDisplay = '';  // e.g., "3, 8, 12"
int _repsRange = 0;        // e.g., 9
```

### Button Handlers

```dart
void _handleModifySets() {
  // Close modal → user returns to workout screen to edit sets
  Navigator.pop(context);
}

void _handleUseRPE() {
  // Switch to RPE mode without closing modal
  setState(() {
    _adjustmentType = AutoAdjustmentType.rpe;
  });
}
```

---

## 🌍 Section 4: Localization Keys

### New Keys Required

#### English (`assets/i18n/app_en.arb`)

```json
{
  "apreNotAvailable": "APRE Not Available",
  "@apreNotAvailable": {
    "description": "Header for APRE unavailable warning when reps are inconsistent"
  },

  "apreInconsistentRepsMessage": "Your sets: {reps} (range: {range} reps)",
  "@apreInconsistentRepsMessage": {
    "description": "Shows user's current reps and range. Example: 'Your sets: 3, 8, 12 (range: 9 reps)'",
    "placeholders": {
      "reps": {
        "type": "String",
        "example": "3, 8, 12"
      },
      "range": {
        "type": "int",
        "example": "9"
      }
    }
  },

  "apreRequiresConsistentReps": "APRE requires max 4 reps difference between sets for accurate auto-regulation.",
  "@apreRequiresConsistentReps": {
    "description": "Explains APRE consistency requirement"
  },

  "apreSuggestConsistentReps": "💡 Suggestion: Use 8, 10, 10 reps to enable APRE",
  "@apreSuggestConsistentReps": {
    "description": "Example of consistent reps that would enable APRE"
  },

  "modifySets": "Modify Sets",
  "@modifySets": {
    "description": "Button to close modal and edit sets on workout screen"
  },

  "useRPE": "Use RPE",
  "@useRPE": {
    "description": "Button to switch to RPE mode instead of APRE"
  }
}
```

#### Italian (`assets/i18n/app_it.arb`)

```json
{
  "apreNotAvailable": "APRE Non Disponibile",
  "apreInconsistentRepsMessage": "I tuoi set: {reps} (range: {range} reps)",
  "apreRequiresConsistentReps": "APRE richiede max 4 reps di differenza tra i set per una regolazione accurata.",
  "apreSuggestConsistentReps": "💡 Suggerimento: Usa 8, 10, 10 reps per attivare APRE",
  "modifySets": "Modifica Set",
  "useRPE": "Usa RPE"
}
```

---

## 🧪 Section 5: Testing Strategy

### 5.1 Unit Tests

**File**: `test/features/workout/domain/services/apre_auto_regulation_service_test.dart`

```dart
group('selectProtocolFromTargetReps - Updated Thresholds', () {
  test('should select APRE-3 for 1-5 reps', () {
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(1), 3);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(3), 3);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(5), 3);
  });

  test('should select APRE-6 for 6-8 reps', () {
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(6), 6);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(7), 6);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(8), 6);
  });

  test('should select APRE-10 for 9+ reps', () {
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(9), 10);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(10), 10);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(12), 10);
    expect(APREAutoRegulationService.selectProtocolFromTargetReps(15), 10);
  });
});
```

**File**: `test/features/workout/presentation/widgets/auto_adjustment_modal_test.dart` (new tests)

```dart
group('Reps Inconsistency Detection', () {
  testWidgets('should allow APRE when reps range <= 4', (tester) async {
    final exercise = Exercise(
      sets: [
        ExerciseSet(reps: 8),
        ExerciseSet(reps: 10),
        ExerciseSet(reps: 12),
      ],
    );

    await tester.pumpWidget(makeTestableWidget(
      AutoAdjustmentModal(exercise: exercise, onSave: (_) {}),
    ));

    // Should NOT show warning card
    expect(find.text('APRE Non Disponibile'), findsNothing);

    // APRE radio should be enabled
    final radioFinder = find.byWidgetPredicate(
      (widget) => widget is Radio && widget.value == AutoAdjustmentType.apre,
    );
    final Radio radio = tester.widget(radioFinder);
    expect(radio.onChanged, isNotNull); // Enabled
  });

  testWidgets('should block APRE when reps range > 4', (tester) async {
    final exercise = Exercise(
      sets: [
        ExerciseSet(reps: 3),
        ExerciseSet(reps: 8),
        ExerciseSet(reps: 12),
      ],
    );

    await tester.pumpWidget(makeTestableWidget(
      AutoAdjustmentModal(exercise: exercise, onSave: (_) {}),
    ));

    // Should show warning card
    expect(find.text('APRE Non Disponibile'), findsOneWidget);
    expect(find.text('I tuoi set: 3, 8, 12 (range: 9 reps)'), findsOneWidget);

    // APRE radio should be disabled
    final radioFinder = find.byWidgetPredicate(
      (widget) => widget is Radio && widget.value == AutoAdjustmentType.apre,
    );
    final Radio radio = tester.widget(radioFinder);
    expect(radio.onChanged, isNull); // Disabled
  });
});
```

### 5.2 Widget Tests

**File**: `test/features/workout/presentation/widgets/auto_adjustment_modal_warning_card_test.dart` (new file)

```dart
testWidgets('Warning card should show correct reps and range', (tester) async {
  final exercise = Exercise(
    sets: [
      ExerciseSet(reps: 5),
      ExerciseSet(reps: 10),
      ExerciseSet(reps: 15),
    ],
  );

  await tester.pumpWidget(makeTestableWidget(
    AutoAdjustmentModal(exercise: exercise, onSave: (_) {}),
  ));

  expect(find.text('I tuoi set: 5, 10, 15 (range: 10 reps)'), findsOneWidget);
});

testWidgets('Modifica Set button should close modal', (tester) async {
  // ... setup ...

  await tester.tap(find.text('Modifica Set'));
  await tester.pumpAndSettle();

  // Modal should be closed
  expect(find.byType(AutoAdjustmentModal), findsNothing);
});

testWidgets('Usa RPE button should switch to RPE mode', (tester) async {
  // ... setup ...

  await tester.tap(find.text('Usa RPE'));
  await tester.pumpAndSettle();

  // RPE radio should be selected
  final rpeRadioFinder = find.byWidgetPredicate(
    (widget) => widget is Radio && widget.value == AutoAdjustmentType.rpe,
  );
  final Radio rpeRadio = tester.widget(rpeRadioFinder);
  expect(rpeRadio.groupValue, AutoAdjustmentType.rpe);
});
```

### 5.3 Integration Tests

**Scenario**: User tries to enable APRE with inconsistent reps, sees warning, modifies sets, then successfully enables APRE.

```dart
testWidgets('Full flow: inconsistent reps → modify → enable APRE', (tester) async {
  // 1. Start with inconsistent reps (3, 8, 12)
  final exercise = Exercise(
    sets: [
      ExerciseSet(reps: 3),
      ExerciseSet(reps: 8),
      ExerciseSet(reps: 12),
    ],
  );

  // 2. Open modal
  await tester.pumpWidget(makeTestableWidget(
    AutoAdjustmentModal(exercise: exercise, onSave: (_) {}),
  ));

  // 3. Verify warning shown
  expect(find.text('APRE Non Disponibile'), findsOneWidget);

  // 4. Tap "Modifica Set"
  await tester.tap(find.text('Modifica Set'));
  await tester.pumpAndSettle();

  // 5. Modal closed → user edits sets externally
  // (simulate by creating new exercise with consistent reps)
  final updatedExercise = exercise.copyWith(
    sets: [
      ExerciseSet(reps: 8),
      ExerciseSet(reps: 10),
      ExerciseSet(reps: 12),
    ],
  );

  // 6. Reopen modal with updated exercise
  await tester.pumpWidget(makeTestableWidget(
    AutoAdjustmentModal(exercise: updatedExercise, onSave: (_) {}),
  ));

  // 7. Verify warning NOT shown, APRE enabled
  expect(find.text('APRE Non Disponibile'), findsNothing);

  final radioFinder = find.byWidgetPredicate(
    (widget) => widget is Radio && widget.value == AutoAdjustmentType.apre,
  );
  final Radio radio = tester.widget(radioFinder);
  expect(radio.onChanged, isNotNull); // Enabled
});
```

### 5.4 Manual Testing Checklist

#### Test Case 1: Protocol Auto-Selection (9+ reps)
1. Create exercise "Bench Press"
2. Add 3 sets: 10, 10, 12 reps
3. Open "Regolazione Automatica" modal
4. **Expect**: APRE-10 auto-selected (not APRE-6)
5. **Verify**: Banner shows "Protocol auto-selected based on reps"

#### Test Case 2: Consistent Reps (Allowed)
1. Create exercise "Squat"
2. Add 3 sets: 8, 10, 12 reps (range: 4)
3. Open modal
4. **Expect**: APRE radio enabled, NO warning card
5. **Verify**: Can select APRE and save

#### Test Case 3: Inconsistent Reps (Blocked)
1. Create exercise "Deadlift"
2. Add 3 sets: 3, 8, 12 reps (range: 9)
3. Open modal
4. **Expect**: APRE radio disabled, warning card shown
5. **Verify**: Card shows "I tuoi set: 3, 8, 12 (range: 9 reps)"
6. Tap "Modifica Set" → modal closes
7. Edit sets to 8, 10, 10 reps
8. Reopen modal
9. **Expect**: APRE now enabled

#### Test Case 4: RPE Fallback
1. Create exercise with inconsistent reps
2. Open modal → see warning
3. Tap "Usa RPE" button
4. **Expect**: RPE radio selected, no longer blocked
5. **Verify**: Can configure RPE and save

#### Test Case 5: Edge Cases
- **Warmup sets ignored**: 3 warmup + 3 working sets (10, 10, 12) → APRE allowed
- **Single set**: Only 1 set → no inconsistency check (need 2+ sets)
- **Exactly 4 reps range**: 8, 10, 12 → APRE allowed (threshold inclusive)
- **Exactly 5 reps range**: 8, 10, 13 → APRE blocked

---

## 📝 Implementation Checklist

- [ ] Add 6 localization keys to `app_en.arb` and `app_it.arb`
- [ ] Run `flutter gen-l10n`
- [ ] Update `selectProtocolFromTargetReps()` threshold (≤8 for APRE-6)
- [ ] Add state fields: `_hasInconsistentReps`, `_repsDisplay`, `_repsRange`
- [ ] Implement `_detectRepsInconsistency()` method
- [ ] Call detection in `initState()`
- [ ] Add conditional warning card UI
- [ ] Implement `_handleModifySets()` and `_handleUseRPE()` handlers
- [ ] Disable APRE radio when `_hasInconsistentReps == true`
- [ ] Update unit tests for new thresholds
- [ ] Add widget tests for warning card
- [ ] Add integration test for full flow
- [ ] Run manual test checklist
- [ ] Update `flutter analyze` (should pass)

---

## 🔗 Related Documentation

- **APRE System Overview**: `docs/UX_FLOWS/workout_session/APRE_AUTO_REGULATION_SYSTEM.md`
- **Design System Guidelines**: `docs/DESIGN_GUIDELINES.md`
- **Localization Guide**: `docs/LOCALIZATION_GUIDE.md`
- **Testing Standards**: `docs/TESTING_STANDARDS.md`

---

## ✅ Approval

**Design Approved By**: User (michele)
**Date**: 2025-11-06
**Status**: Ready for Implementation

---

## 📌 Notes

- **Legal Consideration**: Auto-disabling APRE (vs. warning + allowing) protects developer from liability
- **User Feedback**: "io direi cmq di eliminare quella possibilità [test set]" → removed in previous fix
- **Future Enhancement**: Could add "smart fix" button that auto-adjusts reps to nearest consistent range (e.g., 3, 8, 12 → suggest 8, 8, 10)
