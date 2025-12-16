# Warmup System v2 - Implementation Plan

**For Claude: REQUIRED SUB-SKILL: Use superpowers:executing-plans**

**Generated**: 2025-01-26
**Design Document**: `docs/plans/2025-01-26-warmup-system-v2-design.md`
**Status**: Ready for implementation

---

## Overview

Implement science-based warmup system v2 with:
1. New algorithm (last set 80% per research)
2. Plate calculator button in workout header
3. Redesigned WarmupSuggestionCard with plate visualization
4. Customization mini-modal
5. Cleanup dead code

---

## Phase 1: Warmup Calculator Service

### Task 1.1: Create WarmupCalculatorService

**Files**: `lib/features/workout/domain/services/warmup_calculator_service.dart`

**Steps**:

1. Write test file first:

```dart
// lib/features/workout/domain/services/warmup_calculator_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';

void main() {
  group('WarmupCalculatorService', () {
    late WarmupCalculatorService service;

    setUp(() {
      service = WarmupCalculatorService();
    });

    group('calculateWarmupSets', () {
      test('returns empty list for weight <= 0', () {
        final result = service.calculateWarmupSets(0, isBarbell: true);
        expect(result, isEmpty);
      });

      test('returns minimal warmup for light weight (<40kg)', () {
        final result = service.calculateWarmupSets(35, isBarbell: true);
        expect(result.length, 1);
        expect(result.first.weight, 20); // Just bar
      });

      test('returns 3 sets for medium weight (40-80kg)', () {
        final result = service.calculateWarmupSets(60, isBarbell: true);
        expect(result.length, 3);
        expect(result.last.percentage, 80);
      });

      test('returns 4 sets for heavy weight (80-120kg)', () {
        final result = service.calculateWarmupSets(100, isBarbell: true);
        expect(result.length, 4);
        expect(result[0].weight, 20); // Bar
        expect(result[1].percentage, 40);
        expect(result[2].percentage, 60);
        expect(result[3].percentage, 80);
      });

      test('returns 5 sets for very heavy weight (>120kg)', () {
        final result = service.calculateWarmupSets(150, isBarbell: true);
        expect(result.length, 5);
        expect(result.last.percentage, 80);
      });

      test('does not include bar set for non-barbell exercises', () {
        final result = service.calculateWarmupSets(60, isBarbell: false);
        expect(result.every((s) => s.weight != 20), true);
      });
    });

    group('roundToAvailablePlates', () {
      test('rounds to nearest 2.5kg increment by default', () {
        expect(service.roundToAvailablePlates(47.3), 47.5);
        expect(service.roundToAvailablePlates(46.2), 45.0);
      });

      test('respects custom plate increments', () {
        expect(
          service.roundToAvailablePlates(47.3, availablePlates: [20, 10, 5]),
          50.0,
        );
      });
    });

    group('isLikelyBarbellExercise', () {
      test('returns true for squat variations', () {
        expect(service.isLikelyBarbellExercise('Back Squat'), true);
        expect(service.isLikelyBarbellExercise('Front Squat'), true);
      });

      test('returns true for bench press', () {
        expect(service.isLikelyBarbellExercise('Bench Press'), true);
        expect(service.isLikelyBarbellExercise('Incline Bench'), true);
      });

      test('returns true for deadlift', () {
        expect(service.isLikelyBarbellExercise('Deadlift'), true);
        expect(service.isLikelyBarbellExercise('Romanian Deadlift'), true);
      });

      test('returns false for dumbbell exercises', () {
        expect(service.isLikelyBarbellExercise('Dumbbell Curl'), false);
        expect(service.isLikelyBarbellExercise('Dumbbell Press'), false);
      });

      test('returns false for cable exercises', () {
        expect(service.isLikelyBarbellExercise('Cable Fly'), false);
        expect(service.isLikelyBarbellExercise('Cable Row'), false);
      });

      test('returns false for machine exercises', () {
        expect(service.isLikelyBarbellExercise('Machine Press'), false);
        expect(service.isLikelyBarbellExercise('Leg Press Machine'), false);
      });
    });
  });
}
```

2. Run test (should fail):
```bash
flutter test lib/features/workout/domain/services/warmup_calculator_service_test.dart
```

3. Implement service:

```dart
// lib/features/workout/domain/services/warmup_calculator_service.dart
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_suggestion_card.dart';

/// Science-based warmup calculator service.
///
/// Based on peer-reviewed research:
/// - PMC - Revisiting the 'Whys' and 'Hows' of the Warm-Up (2024)
/// - ScienceDirect - High-load and low-volume warm-up increases performance
/// - PMC - The Role of Specific Warm-up during Bench Press and Squat
///
/// Key findings: Last warmup set at 80% (not 90%) maximizes PAP effect.
class WarmupCalculatorService {
  static const double defaultBarbellWeight = 20.0;
  static const List<double> defaultPlates = [25, 20, 15, 10, 5, 2.5, 1.25];

  /// Calculate warmup sets based on target weight.
  ///
  /// Protocol based on scientific research:
  /// - Light (<40kg): 1 set (bar or 50%)
  /// - Medium (40-80kg): 3 sets (bar, 50%, 80%)
  /// - Heavy (80-120kg): 4 sets (bar, 40%, 60%, 80%)
  /// - Very heavy (>120kg): 5 sets (bar, 40%, 55%, 70%, 80%)
  List<WarmupSet> calculateWarmupSets(
    double targetWeight, {
    required bool isBarbell,
    List<double>? availablePlates,
  }) {
    if (targetWeight <= 0) return [];

    final plates = availablePlates ?? defaultPlates;

    if (targetWeight < 40) {
      // Light weight: minimal warmup
      return isBarbell
          ? [const WarmupSet(weight: 20, reps: 8, percentage: 0)]
          : [
              WarmupSet(
                weight: roundToAvailablePlates(targetWeight * 0.5, availablePlates: plates),
                reps: 8,
                percentage: 50,
              ),
            ];
    }

    if (targetWeight <= 80) {
      // Medium weight: 3 sets
      return [
        if (isBarbell) const WarmupSet(weight: 20, reps: 5, percentage: 0),
        WarmupSet(
          weight: roundToAvailablePlates(targetWeight * 0.50, availablePlates: plates),
          reps: 5,
          percentage: 50,
        ),
        WarmupSet(
          weight: roundToAvailablePlates(targetWeight * 0.80, availablePlates: plates),
          reps: 3,
          percentage: 80,
        ),
      ];
    }

    if (targetWeight <= 120) {
      // Heavy weight: 4 sets
      return [
        if (isBarbell) const WarmupSet(weight: 20, reps: 5, percentage: 0),
        WarmupSet(
          weight: roundToAvailablePlates(targetWeight * 0.40, availablePlates: plates),
          reps: 5,
          percentage: 40,
        ),
        WarmupSet(
          weight: roundToAvailablePlates(targetWeight * 0.60, availablePlates: plates),
          reps: 3,
          percentage: 60,
        ),
        WarmupSet(
          weight: roundToAvailablePlates(targetWeight * 0.80, availablePlates: plates),
          reps: 2,
          percentage: 80,
        ),
      ];
    }

    // Very heavy weight (>120kg): 5 sets
    return [
      if (isBarbell) const WarmupSet(weight: 20, reps: 5, percentage: 0),
      WarmupSet(
        weight: roundToAvailablePlates(targetWeight * 0.40, availablePlates: plates),
        reps: 5,
        percentage: 40,
      ),
      WarmupSet(
        weight: roundToAvailablePlates(targetWeight * 0.55, availablePlates: plates),
        reps: 3,
        percentage: 55,
      ),
      WarmupSet(
        weight: roundToAvailablePlates(targetWeight * 0.70, availablePlates: plates),
        reps: 2,
        percentage: 70,
      ),
      WarmupSet(
        weight: roundToAvailablePlates(targetWeight * 0.80, availablePlates: plates),
        reps: 1,
        percentage: 80,
      ),
    ];
  }

  /// Round weight to nearest available plate increment.
  double roundToAvailablePlates(
    double weight, {
    List<double>? availablePlates,
  }) {
    final plates = availablePlates ?? defaultPlates;
    if (plates.isEmpty) return weight;

    final smallestPlate = plates.last;
    final increment = smallestPlate * 2; // Per side = total increment

    return (weight / increment).round() * increment;
  }

  /// Detect if exercise is likely a barbell exercise.
  bool isLikelyBarbellExercise(String exerciseName) {
    final lower = exerciseName.toLowerCase();

    // Non-barbell keywords (check first - more specific)
    const nonBarbellKeywords = [
      'dumbbell', 'manubr', 'cable', 'cavo', 'machine',
      'macchina', 'curl', 'fly', 'raise', 'extension',
      'pulldown', 'pushdown', 'kickback', 'lateral',
    ];

    if (nonBarbellKeywords.any((k) => lower.contains(k))) return false;

    // Barbell keywords
    const barbellKeywords = [
      'squat', 'bench', 'deadlift', 'press', 'row',
      'clean', 'snatch', 'jerk', 'barbell', 'bilanciere',
    ];

    if (barbellKeywords.any((k) => lower.contains(k))) return true;

    // Default: not barbell (safer assumption)
    return false;
  }

  /// Calculate plates needed per side for a given weight.
  Map<double, int> calculatePlatesPerSide(
    double totalWeight, {
    double barbellWeight = 20.0,
    List<double>? availablePlates,
  }) {
    final plates = availablePlates ?? defaultPlates;
    final plateCounts = <double, int>{};

    var weightPerSide = (totalWeight - barbellWeight) / 2;
    if (weightPerSide <= 0) return plateCounts;

    for (final plate in plates) {
      final count = (weightPerSide / plate).floor();
      if (count > 0) {
        plateCounts[plate] = count;
        weightPerSide -= count * plate;
      }
    }

    return plateCounts;
  }
}
```

4. Run test (should pass):
```bash
flutter test lib/features/workout/domain/services/warmup_calculator_service_test.dart
```

5. Run analyze:
```bash
flutter analyze
```

6. Commit:
```bash
git add lib/features/workout/domain/services/warmup_calculator_service.dart
git add lib/features/workout/domain/services/warmup_calculator_service_test.dart
git commit -m "feat(warmup): add science-based WarmupCalculatorService

- Implement calculateWarmupSets with research-based protocol
- Last set at 80% (not 90%) per PMC/ScienceDirect studies
- Add roundToAvailablePlates for gym plate constraints
- Add isLikelyBarbellExercise detection
- Add calculatePlatesPerSide for plate visualization
- Include comprehensive unit tests"
```

---

## Phase 2: Localizations

### Task 2.1: Add Warmup Localizations

**Files**:
- `lib/shared/presentation/l10n/arb/app_en.arb`
- `lib/shared/presentation/l10n/arb/app_it.arb`

**Steps**:

1. Add to `app_en.arb`:

```json
{
  "warmupRecommended": "Recommended Warmup",
  "@warmupRecommended": {
    "description": "Title for warmup suggestion card"
  },
  "warmupSetsTarget": "{count} sets · Target {weight}kg",
  "@warmupSetsTarget": {
    "description": "Warmup sets count and target weight",
    "placeholders": {
      "count": {"type": "int"},
      "weight": {"type": "double"}
    }
  },
  "warmupEmptyBar": "Empty bar",
  "@warmupEmptyBar": {
    "description": "Label for empty barbell warmup set"
  },
  "warmupPerSide": "{plates} per side",
  "@warmupPerSide": {
    "description": "Plates per side description",
    "placeholders": {
      "plates": {"type": "String"}
    }
  },
  "warmupCustomize": "Customize",
  "@warmupCustomize": {
    "description": "Button to customize warmup sets"
  },
  "warmupAddAll": "Add All",
  "@warmupAddAll": {
    "description": "Button to add all warmup sets"
  },
  "warmupCustomizeTitle": "Customize Warmup",
  "@warmupCustomizeTitle": {
    "description": "Title for warmup customization modal"
  },
  "warmupAddSet": "Add Set",
  "@warmupAddSet": {
    "description": "Button to add another warmup set"
  },
  "warmupSetNumber": "Set {number}",
  "@warmupSetNumber": {
    "description": "Label for warmup set number",
    "placeholders": {
      "number": {"type": "int"}
    }
  },
  "warmupScienceBased": "Based on scientific research",
  "@warmupScienceBased": {
    "description": "Note indicating warmup is science-based"
  },
  "plateCalculator": "Plate Calculator",
  "@plateCalculator": {
    "description": "Title for plate calculator"
  },
  "nextSetWeight": "Next set: {weight}kg",
  "@nextSetWeight": {
    "description": "Weight of next set to do",
    "placeholders": {
      "weight": {"type": "double"}
    }
  }
}
```

2. Add to `app_it.arb`:

```json
{
  "warmupRecommended": "Riscaldamento Consigliato",
  "warmupSetsTarget": "{count} set · Target {weight}kg",
  "warmupEmptyBar": "Bilanciere vuoto",
  "warmupPerSide": "{plates} per lato",
  "warmupCustomize": "Personalizza",
  "warmupAddAll": "Aggiungi Tutti",
  "warmupCustomizeTitle": "Personalizza Riscaldamento",
  "warmupAddSet": "Aggiungi Set",
  "warmupSetNumber": "Set {number}",
  "warmupScienceBased": "Basato su ricerca scientifica",
  "plateCalculator": "Calcolatore Piatti",
  "nextSetWeight": "Prossimo set: {weight}kg"
}
```

3. Generate localizations:
```bash
flutter gen-l10n
```

4. Verify no errors:
```bash
flutter analyze
```

5. Commit:
```bash
git add lib/shared/presentation/l10n/arb/app_en.arb
git add lib/shared/presentation/l10n/arb/app_it.arb
git add lib/shared/presentation/l10n/generated/
git commit -m "feat(l10n): add warmup system v2 localizations

- Add EN/IT translations for warmup card
- Add plate calculator localizations
- Add customization modal strings"
```

---

## Phase 3: Warmup Customization Modal

### Task 3.1: Create WarmupCustomizationModal

**Files**: `lib/features/workout/presentation/widgets/warmup_customization_modal.dart`

**Steps**:

1. Create modal widget:

```dart
// lib/features/workout/presentation/widgets/warmup_customization_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_suggestion_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal for customizing warmup sets before adding them.
class WarmupCustomizationModal extends StatefulWidget {
  const WarmupCustomizationModal({
    super.key,
    required this.initialSets,
    required this.onConfirm,
  });

  final List<WarmupSet> initialSets;
  final void Function(List<WarmupSet>) onConfirm;

  /// Show the modal as a bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<WarmupSet> initialSets,
    required void Function(List<WarmupSet>) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WarmupCustomizationModal(
        initialSets: initialSets,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<WarmupCustomizationModal> createState() => _WarmupCustomizationModalState();
}

class _WarmupCustomizationModalState extends State<WarmupCustomizationModal> {
  late List<_EditableWarmupSet> _sets;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets.map((s) => _EditableWarmupSet(
      weightController: TextEditingController(text: s.weight.toStringAsFixed(1)),
      repsController: TextEditingController(text: s.reps.toString()),
      percentage: s.percentage,
    )).toList();
  }

  @override
  void dispose() {
    for (final set in _sets) {
      set.weightController.dispose();
      set.repsController.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _sets.add(_EditableWarmupSet(
        weightController: TextEditingController(text: '20.0'),
        repsController: TextEditingController(text: '5'),
        percentage: 0,
      ));
    });
    HapticFeedback.lightImpact();
  }

  void _removeSet(int index) {
    if (_sets.length <= 1) return;

    setState(() {
      _sets[index].weightController.dispose();
      _sets[index].repsController.dispose();
      _sets.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _confirm() {
    final result = <WarmupSet>[];

    for (final set in _sets) {
      final weight = double.tryParse(set.weightController.text) ?? 0;
      final reps = int.tryParse(set.repsController.text) ?? 0;

      if (weight > 0 && reps > 0) {
        result.add(WarmupSet(
          weight: weight,
          reps: reps,
          percentage: set.percentage,
        ));
      }
    }

    widget.onConfirm(result);
    Navigator.of(context).pop();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.warmupCustomizeTitle,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: SemanticIcon(
                      icon: AppIcons.close,
                      semanticLabel: l10n.close,
                      size: AppIconSize.medium,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sets list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _sets.length,
                itemBuilder: (context, index) => _buildSetRow(context, index, l10n),
              ),
            ),

            // Add set button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextButton.icon(
                onPressed: _addSet,
                icon: const SemanticIcon(
                  icon: AppIcons.add,
                  semanticLabel: 'Add',
                  size: AppIconSize.small,
                ),
                label: Text(l10n.warmupAddSet),
              ),
            ),

            const Divider(height: 1),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _confirm,
                      child: Text(l10n.confirm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, int index, AppLocalizations l10n) {
    final set = _sets[index];

    return Dismissible(
      key: ValueKey(index),
      direction: _sets.length > 1
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => _removeSet(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: context.colors.error,
        child: SemanticIcon(
          icon: AppIcons.delete,
          semanticLabel: l10n.delete,
          size: AppIconSize.medium,
          color: context.colors.onError,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Row(
          children: [
            // Set number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Weight input
            Expanded(
              flex: 2,
              child: TextField(
                controller: set.weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.weight,
                  suffixText: 'kg',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Reps input
            Expanded(
              child: TextField(
                controller: set.repsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: l10n.reps,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableWarmupSet {
  _EditableWarmupSet({
    required this.weightController,
    required this.repsController,
    required this.percentage,
  });

  final TextEditingController weightController;
  final TextEditingController repsController;
  final int percentage;
}
```

2. Run analyze:
```bash
flutter analyze
```

3. Commit:
```bash
git add lib/features/workout/presentation/widgets/warmup_customization_modal.dart
git commit -m "feat(warmup): add WarmupCustomizationModal widget

- Create modal for editing warmup set weights/reps
- Add swipe-to-delete for removing sets
- Add button to add extra sets
- Follow design system patterns (AppSpacing, context.colors)
- Include proper localizations"
```

---

## Phase 4: Redesign WarmupSuggestionCard

### Task 4.1: Refactor WarmupSuggestionCard

**Files**: `lib/features/workout/presentation/widgets/warmup_suggestion_card.dart`

**Steps**:

1. Rewrite the card widget with new design and algorithm integration:

```dart
// lib/features/workout/presentation/widgets/warmup_suggestion_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_customization_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Science-based warmup suggestion card with plate visualization.
class WarmupSuggestionCard extends ConsumerStatefulWidget {
  const WarmupSuggestionCard({
    super.key,
    required this.workingWeight,
    required this.targetReps,
    required this.onAddWarmupSets,
    this.onDismiss,
    required this.exerciseName,
  });

  final double workingWeight;
  final int targetReps;
  final Function(List<ExerciseSet>) onAddWarmupSets;
  final VoidCallback? onDismiss;
  final String exerciseName;

  @override
  ConsumerState<WarmupSuggestionCard> createState() => _WarmupSuggestionCardState();
}

class _WarmupSuggestionCardState extends ConsumerState<WarmupSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  List<WarmupSet> _warmupSets = [];

  final WarmupCalculatorService _calculator = WarmupCalculatorService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _calculateWarmupSets();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateWarmupSets() {
    final config = ref.read(appConfigProvider);
    final availablePlates = config.availablePlates;
    final isBarbell = _calculator.isLikelyBarbellExercise(widget.exerciseName);

    _warmupSets = _calculator.calculateWarmupSets(
      widget.workingWeight,
      isBarbell: isBarbell,
      availablePlates: availablePlates,
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void _openCustomizationModal() {
    WarmupCustomizationModal.show(
      context: context,
      initialSets: _warmupSets,
      onConfirm: (customizedSets) {
        setState(() {
          _warmupSets = customizedSets;
        });
      },
    );
  }

  void _addAllWarmupSets() {
    final l10n = AppLocalizations.of(context);

    final sets = _warmupSets.map((warmup) {
      return ExerciseSet(
        setNumber: 0, // Will be assigned by parent
        reps: warmup.reps,
        weight: warmup.weight,
        isCompleted: false,
        isWarmup: true,
      );
    }).toList();

    widget.onAddWarmupSets(sets);
    _toggleExpanded();

    HapticFeedback.mediumImpact();

    SnackBarService.showSuccess(
      context,
      l10n.warmupSetsAdded('${sets.length}'),
    );
  }

  String _formatPlatesPerSide(double weight) {
    final config = ref.read(appConfigProvider);
    final availablePlates = config.availablePlates ?? WarmupCalculatorService.defaultPlates;

    final plates = _calculator.calculatePlatesPerSide(
      weight,
      availablePlates: availablePlates,
    );

    if (plates.isEmpty) return '';

    final parts = <String>[];
    for (final entry in plates.entries) {
      final plateStr = entry.key % 1 == 0
          ? entry.key.toInt().toString()
          : entry.key.toStringAsFixed(1);
      parts.add('${entry.value}×$plateStr');
    }

    return parts.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_warmupSets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          // Collapsed header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: SemanticIcon(
                        icon: AppIcons.localFireDepartment,
                        semanticLabel: l10n.warmup,
                        size: AppIconSize.small,
                        color: context.colors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.warmupRecommended,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.warmupSetsTarget(
                              _warmupSets.length,
                              widget.workingWeight,
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                      color: context.colors.onSurfaceVariant,
                      size: AppIconSize.medium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Warmup sets list
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      children: _warmupSets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final warmupSet = entry.value;
                        final isEmptyBar = warmupSet.weight == 20 && warmupSet.percentage == 0;
                        final platesPerSide = isEmptyBar ? '' : _formatPlatesPerSide(warmupSet.weight);

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Row(
                            children: [
                              // Set number badge
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.xxs),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: context.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),

                              // Weight and reps
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEmptyBar
                                          ? '${l10n.warmupEmptyBar} × ${warmupSet.reps}'
                                          : '${warmupSet.weight.toStringAsFixed(warmupSet.weight % 1 == 0 ? 0 : 1)}kg × ${warmupSet.reps}',
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (platesPerSide.isNotEmpty)
                                      Text(
                                        l10n.warmupPerSide(platesPerSide),
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: context.colors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Percentage badge
                              if (warmupSet.percentage > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppSpacing.xxs),
                                  ),
                                  child: Text(
                                    '${warmupSet.percentage}%',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Science note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.science,
                          semanticLabel: l10n.warmupScienceBased,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            l10n.warmupScienceBased,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),
                  const Divider(height: 1),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _openCustomizationModal,
                            child: Text(l10n.warmupCustomize),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addAllWarmupSets,
                            icon: const SemanticIcon(
                              icon: AppIcons.add,
                              semanticLabel: 'Add',
                              size: AppIconSize.tiny,
                            ),
                            label: Text(l10n.warmupAddAll),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a single warmup set with weight, reps, and percentage.
class WarmupSet {
  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });

  final double weight;
  final int reps;
  final int percentage;
}
```

2. Run analyze:
```bash
flutter analyze
```

3. Test in both light and dark mode manually.

4. Commit:
```bash
git add lib/features/workout/presentation/widgets/warmup_suggestion_card.dart
git commit -m "feat(warmup): redesign WarmupSuggestionCard with science-based algorithm

- Integrate WarmupCalculatorService for science-based warmup
- Add plate visualization per side
- Add 'Customize' button to open customization modal
- Add 'Add All' button to add all warmup sets
- Show percentage badges for each set
- Add science-based note
- Follow design system (AppSpacing, context.colors, SemanticIcon)
- Support both light and dark themes"
```

---

## Phase 5: Plate Calculator in Workout Header

### Task 5.1: Add Plate Calculator Button to Workout Header

**Files**: `lib/features/workout/presentation/workout_screen.dart`

**Steps**:

1. Add method to get next set weight (add around line 270, before build method):

```dart
/// Get the weight of the next incomplete set.
double? _getNextSetWeight() {
  final workout = ref.read(currentWorkoutProvider);
  if (workout == null) return null;

  for (final exercise in workout.exercises) {
    for (final set in exercise.sets) {
      if (!set.isCompleted && !set.isWarmup && set.weight != null && set.weight! > 0) {
        return set.weight;
      }
    }
  }
  return null;
}

/// Show plate calculator bottom sheet.
void _showPlateCalculator(BuildContext context, double weight) {
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.calculate,
                  semanticLabel: l10n.plateCalculator,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.plateCalculator,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Plate calculator widget
          Expanded(
            child: PlateCalculatorWidget(
              targetWeight: weight,
              onWeightChanged: (newWeight) {
                // Optional: update the set weight
              },
            ),
          ),
        ],
      ),
    ),
  );
}
```

2. Add import at top of file:
```dart
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';
```

3. Add calculator button in actions (around line 301, after reorder button):

```dart
actions: [
  // Plate calculator button (NEW)
  if (isActive && hasExercises)
    Builder(
      builder: (context) {
        final nextWeight = _getNextSetWeight();
        if (nextWeight == null) return const SizedBox.shrink();

        return IconButton(
          onPressed: () => _showPlateCalculator(context, nextWeight),
          icon: const SemanticIcon(
            icon: AppIcons.calculate,
            semanticLabel: 'Plate Calculator',
            size: AppIconSize.medium,
          ),
          tooltip: AppLocalizations.of(context).nextSetWeight(nextWeight),
        );
      },
    ),
  // Existing reorder button
  if (isActive && hasExercises)
    IconButton(
      // ... existing code
    ),
  // ... rest of existing actions
],
```

4. Run analyze:
```bash
flutter analyze
```

5. Test manually:
   - Start a workout with exercises that have weights
   - Verify calculator icon appears in header
   - Tap icon and verify plate calculator shows
   - Verify it shows correct weight for next incomplete set

6. Commit:
```bash
git add lib/features/workout/presentation/workout_screen.dart
git commit -m "feat(workout): add plate calculator button to workout header

- Add calculator icon in AppBar actions
- Show plate calculator in bottom sheet on tap
- Auto-detect next incomplete set weight
- Only show when workout is active with exercises
- Tooltip shows next set weight"
```

---

## Phase 6: Cleanup Dead Code

### Task 6.1: Delete warmup_progression_v2.dart

**Files**: `lib/features/workout/presentation/widgets/warmup_progression_v2.dart`

**Steps**:

1. Verify file is not imported anywhere:
```bash
grep -r "warmup_progression_v2" lib/
```

2. Delete the file:
```bash
rm lib/features/workout/presentation/widgets/warmup_progression_v2.dart
```

3. Run analyze to confirm no broken imports:
```bash
flutter analyze
```

4. Commit:
```bash
git add -A
git commit -m "chore(cleanup): delete unused warmup_progression_v2.dart

Dead code removal - widget was never imported or used.
Functionality migrated to redesigned WarmupSuggestionCard."
```

---

## Phase 7: Final Verification

### Task 7.1: Full Test & Analyze

**Steps**:

1. Run full analyze:
```bash
flutter analyze
```

2. Run all tests:
```bash
flutter test
```

3. Test manually:
   - [ ] Open workout with exercises
   - [ ] Verify warmup card appears for heavy exercises (≥40kg)
   - [ ] Expand warmup card, verify plate visualization
   - [ ] Tap "Personalizza", verify modal opens
   - [ ] Edit weights/reps in modal, confirm changes
   - [ ] Tap "Aggiungi Tutti", verify sets added
   - [ ] Tap plate calculator icon in header
   - [ ] Verify plate calculator shows correct weight
   - [ ] Test in light and dark mode
   - [ ] Test in English and Italian

4. Final commit if any fixes needed:
```bash
git add -A
git commit -m "fix(warmup): final adjustments from manual testing"
```

---

## Summary

| Phase | Tasks | Est. Time |
|-------|-------|-----------|
| 1. Calculator Service | 1.1 | 30 min |
| 2. Localizations | 2.1 | 15 min |
| 3. Customization Modal | 3.1 | 30 min |
| 4. Card Redesign | 4.1 | 45 min |
| 5. Header Button | 5.1 | 30 min |
| 6. Cleanup | 6.1 | 5 min |
| 7. Verification | 7.1 | 20 min |
| **Total** | **7 tasks** | **~3 hours** |
