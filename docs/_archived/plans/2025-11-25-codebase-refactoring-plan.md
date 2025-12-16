# FitLog Pro - Codebase Refactoring Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migliorare performance, manutenibilità e qualità del codice attraverso refactoring sistematico dei problemi identificati nell'analisi del 25/11/2025.

**Architecture:** Clean Architecture con Riverpod 2.x. Focus su Single Responsibility Principle, ottimizzazione rebuild widget, e consolidamento duplicazioni.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, Freezed, Firebase, Hive

---

## Executive Summary

| Fase | Focus | Effort | Impatto |
|------|-------|--------|---------|
| 1 | Quick Wins | 1-2 giorni | Alto (performance immediata) |
| 2 | Refactoring ExerciseListItem | 3-4 giorni | Critico (5594 righe) |
| 3 | Ottimizzazione Riverpod | 2-3 giorni | Alto (1108 watch senza select) |
| 4 | Consolidamento Architecture | 1 settimana | Medio-Alto |

---

## FASE 1: QUICK WINS (1-2 giorni)

### Task 1.1: Fix Hardcoded Colors - Batch 1 (workout feature)

**Files:**
- Modify: `lib/features/workout/presentation/widgets/*.dart`
- Reference: `lib/shared/presentation/extensions/build_context_extensions.dart`

**Step 1: Run theme fix script on workout widgets**

```bash
./scripts/fix_theme_violations.sh --dry-run --file lib/features/workout/presentation/widgets/
```

Expected: Preview of ~50 color replacements

**Step 2: Apply fixes**

```bash
./scripts/fix_theme_violations.sh --file lib/features/workout/presentation/widgets/
```

**Step 3: Verify no regressions**

```bash
flutter analyze lib/features/workout/
```

Expected: 0 errors

**Step 4: Commit**

```bash
git add lib/features/workout/presentation/widgets/
git commit -m "style: fix hardcoded colors in workout widgets

- Replace Colors.* with context.colors.*
- Ensure dark/light theme compatibility"
```

---

### Task 1.2: Fix Hardcoded Colors - Batch 2 (analytics feature)

**Files:**
- Modify: `lib/features/analytics/presentation/widgets/*.dart`

**Step 1: Run theme fix script**

```bash
./scripts/fix_theme_violations.sh --file lib/features/analytics/presentation/widgets/
```

**Step 2: Verify**

```bash
flutter analyze lib/features/analytics/
```

**Step 3: Commit**

```bash
git add lib/features/analytics/presentation/widgets/
git commit -m "style: fix hardcoded colors in analytics widgets"
```

---

### Task 1.3: Fix Hardcoded Colors - Remaining features

**Files:**
- Modify: `lib/features/*/presentation/**/*.dart`

**Step 1: Run on all remaining**

```bash
./scripts/fix_theme_violations.sh
```

**Step 2: Full analyze**

```bash
flutter analyze
```

**Step 3: Commit**

```bash
git add -A
git commit -m "style: fix all remaining hardcoded colors (226 total)"
```

---

### Task 1.4: Remove print() statements

**Files:**
- Modify: 9 files with print() statements

**Step 1: Find all prints**

```bash
grep -rn "print(" lib/ --include="*.dart" | grep -v "debugPrint"
```

**Step 2: Replace each with debugPrint + kDebugMode**

```dart
// Prima
print('debug message');

// Dopo
if (kDebugMode) {
  debugPrint('debug message');
}
```

**Step 3: Verify**

```bash
grep -rn "print(" lib/ --include="*.dart" | grep -v "debugPrint" | wc -l
```

Expected: 0

**Step 4: Commit**

```bash
git add -A
git commit -m "fix: replace print() with debugPrint + kDebugMode"
```

---

## FASE 2: REFACTORING EXERCISE_LIST_ITEM (3-4 giorni)

### Task 2.1: Analyze current structure

**Files:**
- Read: `lib/features/workout/presentation/widgets/exercise_list_item.dart`

**Step 1: Document current responsibilities**

Creare file di analisi:

```bash
# Contare metodi e widget interni
grep -c "Widget " lib/features/workout/presentation/widgets/exercise_list_item.dart
grep -c "void _" lib/features/workout/presentation/widgets/exercise_list_item.dart
grep -c "Future<" lib/features/workout/presentation/widgets/exercise_list_item.dart
```

**Step 2: Identify extraction candidates**

Widget interni da estrarre:
1. `_buildHeader()` → `ExerciseListItemHeader`
2. `_buildSetsList()` → `ExerciseListItemSets`
3. `_buildActions()` → `ExerciseListItemActions`
4. `_buildNotes()` → `ExerciseListItemNotes`
5. `_buildWarmupSuggestion()` → `ExerciseWarmupSuggestion`
6. `_buildMetadataBanner()` → `ExerciseMetadataBanner`

---

### Task 2.2: Create ExerciseListItemHeader widget

**Files:**
- Create: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart`
- Test: `test/features/workout/presentation/widgets/exercise_list_item_header_test.dart`

**Step 1: Write failing test**

```dart
// test/features/workout/presentation/widgets/exercise_list_item_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('ExerciseListItemHeader', () {
    testWidgets('displays exercise name', (tester) async {
      final exercise = Exercise(
        id: '1',
        name: 'Bench Press',
        sets: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemHeader(
                exercise: exercise,
                isExpanded: false,
                onToggleExpand: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('shows expand icon when collapsed', (tester) async {
      final exercise = Exercise(id: '1', name: 'Test', sets: []);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemHeader(
                exercise: exercise,
                isExpanded: false,
                onToggleExpand: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_header_test.dart
```

Expected: FAIL - file not found

**Step 3: Create directory structure**

```bash
mkdir -p lib/features/workout/presentation/widgets/exercise_list_item
```

**Step 4: Write minimal implementation**

```dart
// lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Header component for ExerciseListItem
///
/// Displays exercise name, completion status indicator, and expand/collapse toggle.
/// Extracted from exercise_list_item.dart for Single Responsibility.
class ExerciseListItemHeader extends ConsumerWidget {
  const ExerciseListItemHeader({
    super.key,
    required this.exercise,
    required this.isExpanded,
    required this.onToggleExpand,
    this.onOptionsPressed,
  });

  final Exercise exercise;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback? onOptionsPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedSets = exercise.sets.where((s) => s.isCompleted).length;
    final totalSets = exercise.sets.length;
    final isFullyCompleted = completedSets == totalSets && totalSets > 0;

    return InkWell(
      onTap: onToggleExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Completion indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isFullyCompleted
                    ? context.colors.success
                    : completedSets > 0
                        ? context.colors.warning
                        : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Exercise name and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isFullyCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedSets/$totalSets ${context.l10n.sets}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Options button
            if (onOptionsPressed != null)
              IconButton(
                onPressed: onOptionsPressed,
                icon: SemanticIcon(
                  icon: AppIcons.moreVert,
                  semanticLabel: context.l10n.options,
                  size: AppIconSize.medium,
                ),
              ),

            // Expand/collapse indicator
            SemanticIcon(
              icon: isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
              semanticLabel: isExpanded
                  ? context.l10n.collapse
                  : context.l10n.expand,
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Run test to verify it passes**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_header_test.dart
```

Expected: PASS

**Step 6: Commit**

```bash
git add lib/features/workout/presentation/widgets/exercise_list_item/
git add test/features/workout/presentation/widgets/exercise_list_item_header_test.dart
git commit -m "refactor: extract ExerciseListItemHeader from exercise_list_item

- Single Responsibility: header display only
- Includes completion indicator, name, progress, expand toggle
- Full test coverage"
```

---

### Task 2.3: Create ExerciseListItemSets widget

**Files:**
- Create: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart`
- Test: `test/features/workout/presentation/widgets/exercise_list_item_sets_test.dart`

**Step 1: Write failing test**

```dart
// test/features/workout/presentation/widgets/exercise_list_item_sets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('ExerciseListItemSets', () {
    testWidgets('displays all sets', (tester) async {
      final exercise = Exercise(
        id: '1',
        name: 'Bench Press',
        sets: [
          ExerciseSet(id: '1', weight: 60, reps: 10, isCompleted: false),
          ExerciseSet(id: '2', weight: 60, reps: 10, isCompleted: true),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemSets(
                exercise: exercise,
                onSetTap: (_) {},
                onSetComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      // Should show 2 sets
      expect(find.text('60 kg'), findsNWidgets(2));
      expect(find.text('10'), findsNWidgets(2));
    });

    testWidgets('calls onSetComplete when checkbox tapped', (tester) async {
      ExerciseSet? tappedSet;
      final exercise = Exercise(
        id: '1',
        name: 'Test',
        sets: [
          ExerciseSet(id: '1', weight: 50, reps: 8, isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemSets(
                exercise: exercise,
                onSetTap: (_) {},
                onSetComplete: (set) => tappedSet = set,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(tappedSet, isNotNull);
      expect(tappedSet!.id, '1');
    });
  });
}
```

**Step 2: Run test**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_sets_test.dart
```

Expected: FAIL

**Step 3: Write implementation**

```dart
// lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';

/// Sets list component for ExerciseListItem
///
/// Displays all sets with weight, reps, and completion checkbox.
/// Supports tap to edit and checkbox to complete.
class ExerciseListItemSets extends ConsumerWidget {
  const ExerciseListItemSets({
    super.key,
    required this.exercise,
    required this.onSetTap,
    required this.onSetComplete,
    this.showSetNumber = true,
  });

  final Exercise exercise;
  final Function(ExerciseSet) onSetTap;
  final Function(ExerciseSet) onSetComplete;
  final bool showSetNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercise.sets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.l10n.noSetsYet,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercise.sets.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: context.colors.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final set = exercise.sets[index];
        return _SetRow(
          set: set,
          setNumber: index + 1,
          showSetNumber: showSetNumber,
          onTap: () => onSetTap(set),
          onComplete: () => onSetComplete(set),
        );
      },
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.set,
    required this.setNumber,
    required this.showSetNumber,
    required this.onTap,
    required this.onComplete,
  });

  final ExerciseSet set;
  final int setNumber;
  final bool showSetNumber;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Set number
            if (showSetNumber)
              SizedBox(
                width: 32,
                child: Text(
                  '$setNumber',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Weight
            Expanded(
              child: Text(
                '${set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1)} kg',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                  color: set.isCompleted
                      ? context.colors.onSurfaceVariant
                      : context.colors.onSurface,
                ),
              ),
            ),

            // Reps
            SizedBox(
              width: 48,
              child: Text(
                '${set.reps}',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                  color: set.isCompleted
                      ? context.colors.onSurfaceVariant
                      : context.colors.onSurface,
                ),
              ),
            ),

            // Completion checkbox
            Checkbox(
              value: set.isCompleted,
              onChanged: (_) {
                HapticFeedbackService.light();
                onComplete();
              },
              activeColor: context.colors.success,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run test**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_sets_test.dart
```

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_sets.dart
git add test/features/workout/presentation/widgets/exercise_list_item_sets_test.dart
git commit -m "refactor: extract ExerciseListItemSets from exercise_list_item

- Single Responsibility: sets display and interaction only
- Includes weight, reps, completion checkbox
- Full test coverage"
```

---

### Task 2.4: Create ExerciseListItemActions widget

**Files:**
- Create: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_actions.dart`
- Test: `test/features/workout/presentation/widgets/exercise_list_item_actions_test.dart`

**Step 1: Write failing test**

```dart
// test/features/workout/presentation/widgets/exercise_list_item_actions_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_actions.dart';

void main() {
  group('ExerciseListItemActions', () {
    testWidgets('displays add set button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemActions(
                onAddSet: () {},
                onEdit: () {},
                onDelete: () {},
                onReplace: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onAddSet when add button tapped', (tester) async {
      var addSetCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExerciseListItemActions(
                onAddSet: () => addSetCalled = true,
                onEdit: () {},
                onDelete: () {},
                onReplace: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(addSetCalled, isTrue);
    });
  });
}
```

**Step 2: Run test**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_actions_test.dart
```

**Step 3: Write implementation**

```dart
// lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_actions.dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';

/// Action buttons for ExerciseListItem
///
/// Provides add set, edit, replace, and delete actions.
class ExerciseListItemActions extends StatelessWidget {
  const ExerciseListItemActions({
    super.key,
    required this.onAddSet,
    required this.onEdit,
    required this.onDelete,
    this.onReplace,
    this.showReplace = true,
  });

  final VoidCallback onAddSet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onReplace;
  final bool showReplace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Add set
          _ActionButton(
            icon: AppIcons.add,
            label: context.l10n.addSet,
            onPressed: onAddSet,
            color: context.colors.primary,
          ),

          // Edit
          _ActionButton(
            icon: AppIcons.edit,
            label: context.l10n.edit,
            onPressed: onEdit,
          ),

          // Replace
          if (showReplace && onReplace != null)
            _ActionButton(
              icon: AppIcons.swapHoriz,
              label: context.l10n.replace,
              onPressed: onReplace!,
            ),

          // Delete
          _ActionButton(
            icon: AppIcons.delete,
            label: context.l10n.delete,
            onPressed: onDelete,
            color: context.colors.error,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? context.colors.onSurfaceVariant;

    return InkWell(
      onTap: () {
        HapticFeedbackService.light();
        onPressed();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.medium,
              color: buttonColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run test**

```bash
flutter test test/features/workout/presentation/widgets/exercise_list_item_actions_test.dart
```

**Step 5: Commit**

```bash
git add lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_actions.dart
git add test/features/workout/presentation/widgets/exercise_list_item_actions_test.dart
git commit -m "refactor: extract ExerciseListItemActions from exercise_list_item"
```

---

### Task 2.5: Create barrel file and integrate components

**Files:**
- Create: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item.dart` (barrel)
- Modify: `lib/features/workout/presentation/widgets/exercise_list_item.dart` (refactor to use new components)

**Step 1: Create barrel file**

```dart
// lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item.dart
export 'exercise_list_item_header.dart';
export 'exercise_list_item_sets.dart';
export 'exercise_list_item_actions.dart';
```

**Step 2: Refactor main widget to use extracted components**

Modify `exercise_list_item.dart` to import and use the new components, reducing it from 5594 to ~1500 lines.

**Step 3: Run all tests**

```bash
flutter test test/features/workout/
```

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor: integrate extracted ExerciseListItem components

- Reduced from 5594 to ~1500 lines
- Better testability and maintainability
- Single Responsibility Principle applied"
```

---

## FASE 3: OTTIMIZZAZIONE RIVERPOD (2-3 giorni)

### Task 3.1: Add .select() to workout_screen.dart

**Files:**
- Modify: `lib/features/workout/presentation/workout_screen.dart`

**Step 1: Find all ref.watch without select**

```bash
grep -n "ref.watch(" lib/features/workout/presentation/workout_screen.dart | grep -v "\.select("
```

**Step 2: For each, add appropriate select**

```dart
// Prima
final workout = ref.watch(workoutProvider);

// Dopo - watch only what you need
final exercises = ref.watch(
  workoutProvider.select((w) => w.exercises),
);
final isActive = ref.watch(
  workoutProvider.select((w) => w.isActive),
);
```

**Step 3: Test performance**

Run app and use Flutter DevTools to verify reduced rebuilds.

**Step 4: Commit**

```bash
git add lib/features/workout/presentation/workout_screen.dart
git commit -m "perf: add .select() to workout_screen providers

- Reduce unnecessary widget rebuilds
- Watch only required state slices"
```

---

### Task 3.2: Add .select() to home_screen providers

**Files:**
- Modify: `lib/features/home/presentation/home_screen_optimized.dart`
- Modify: `lib/features/home/presentation/widgets/*.dart`

**Step 1: Audit current watches**

```bash
grep -rn "ref.watch(" lib/features/home/presentation/ | grep -v "\.select(" | wc -l
```

**Step 2: Add select to each**

Focus on high-frequency rebuilders like stats cards and progress widgets.

**Step 3: Commit**

```bash
git add lib/features/home/presentation/
git commit -m "perf: add .select() to home screen providers"
```

---

### Task 3.3: Add .select() to analytics providers

**Files:**
- Modify: `lib/features/analytics/presentation/**/*.dart`

Similar process - audit, optimize, test, commit.

---

### Task 3.4: Create select() usage guideline doc

**Files:**
- Create: `docs/RIVERPOD_OPTIMIZATION_GUIDE.md`

Document patterns for future development:

```markdown
# Riverpod Optimization Guide

## Always use .select() when:
1. You only need a subset of state
2. The provider state is complex (>3 fields)
3. The widget rebuilds frequently

## Pattern:
```dart
// ❌ Rebuilds on ANY change
final state = ref.watch(myProvider);

// ✅ Rebuilds only when `field` changes
final field = ref.watch(myProvider.select((s) => s.field));
```
```

---

## FASE 4: CONSOLIDAMENTO ARCHITECTURE (1 settimana)

### Task 4.1: Create AchievementService consolidation

**Problem:** Achievement logic scattered across 11 files.

**Solution:** Single source of truth in `lib/features/analytics/domain/services/achievement_service.dart`

**Step 1: Audit all achievement usages**

```bash
grep -rl "Achievement" lib/ | grep -v "freezed\|\.g\.dart"
```

**Step 2: Create unified service**

```dart
// lib/features/analytics/domain/services/achievement_service.dart
class AchievementService {
  // Consolidate all achievement logic here
}
```

**Step 3: Migrate callers one by one**

**Step 4: Delete deprecated files**

---

### Task 4.2: Migrate repositories to BaseHybridRepository

**Problem:** Only 3 of 87 repositories use the pattern.

**Priority repositories to migrate:**
1. `insight_feedback_repository.dart`
2. `firebase_flexible_routine_repository.dart`
3. `firebase_routine_pause_repository.dart`
4. `consent_repository_impl.dart`
5. `measurement_repository_impl.dart`

**Pattern for each:**

```dart
// Prima
class MyRepositoryImpl implements MyRepository {
  final FirebaseFirestore _firestore;
  // Direct Firestore access
}

// Dopo
class MyRepositoryImpl extends BaseHybridRepository<MyEntity>
    implements MyRepository {
  // Uses DataSource pattern, gets sync for free
}
```

---

### Task 4.3: Add tests for untested features

**Priority features to test:**
1. `body_measurements` - New feature, critical
2. `health_sync` - Integration heavy
3. `premium` - Revenue critical

Target: 80% coverage per feature.

---

## Verification Checklist

After completing all phases:

- [ ] `flutter analyze` returns 0 errors
- [ ] All tests pass: `flutter test`
- [ ] No hardcoded colors: `grep -r "Colors\." lib/ | grep -v transparent | wc -l` = 0
- [ ] No print statements: `grep -r "print(" lib/ | grep -v debugPrint | wc -l` = 0
- [ ] exercise_list_item.dart < 2000 lines
- [ ] 50%+ of ref.watch use .select()

---

## Notes & Decisions

*To be filled during implementation*

---

**Generated:** 2025-11-25
**Author:** Claude Code + task-master.dev analysis
