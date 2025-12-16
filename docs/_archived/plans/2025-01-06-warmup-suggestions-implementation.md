# Warmup Suggestions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Allow users to add warmup exercises from ExerciseDetailsModal with a single tap on suggestion chips.

**Architecture:** Add structured `WarmupSuggestion` model, extend Workout with `insertExerciseAt`, create clickable chips in modal that trigger workout modification via callback.

**Tech Stack:** Flutter/Dart, Riverpod, Hive, Freezed

---

## Task 1: Create WarmupSuggestion Model

**Files:**
- Create: `lib/features/exercise_database/domain/entities/warmup_suggestion.dart`

**Step 1: Create the model**

```dart
/// Warmup exercise suggestion with structured data
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'warmup_suggestion.freezed.dart';
part 'warmup_suggestion.g.dart';

/// Type of warmup exercise
enum WarmupType {
  /// Mobility exercises (stretching, range of motion)
  mobility,

  /// Activation exercises (muscle activation, stability)
  activation,
}

/// A suggested warmup exercise for a main exercise
@freezed
class WarmupSuggestion with _$WarmupSuggestion {
  const factory WarmupSuggestion({
    /// ID of the warmup exercise in the database
    required String exerciseId,

    /// Display name of the exercise
    required String exerciseName,

    /// Number of sets to perform
    required int sets,

    /// Number of reps per set
    required int reps,

    /// Type of warmup (mobility or activation)
    required WarmupType type,
  }) = _WarmupSuggestion;

  factory WarmupSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WarmupSuggestionFromJson(json);
}
```

**Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generated `.freezed.dart` and `.g.dart` files

**Step 3: Commit**

```bash
git add lib/features/exercise_database/domain/entities/warmup_suggestion.dart
git add lib/features/exercise_database/domain/entities/warmup_suggestion.freezed.dart
git add lib/features/exercise_database/domain/entities/warmup_suggestion.g.dart
git commit -m "feat(warmup): add WarmupSuggestion model"
```

---

## Task 2: Add warmupSuggestions to ExerciseDefinition

**Files:**
- Modify: `lib/features/exercise_database/domain/entities/exercise.dart`

**Step 1: Add import and field**

Add import at top:
```dart
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
```

Add HiveField after `searchableFields` (line ~162):
```dart
  @HiveField(24)
  final List<WarmupSuggestion>? warmupSuggestions;
```

**Step 2: Update constructor**

Add parameter to constructor (after `searchableFields`):
```dart
    this.warmupSuggestions,
```

**Step 3: Update fromJson factory**

Add parsing in `fromJson` (after aliases parsing):
```dart
      warmupSuggestions: (json['warmupSuggestions'] as List<dynamic>?)
          ?.map((e) => WarmupSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
```

**Step 4: Update toJson method**

Add in `toJson`:
```dart
      'warmupSuggestions': warmupSuggestions?.map((e) => e.toJson()).toList(),
```

**Step 5: Update props**

Add to `props` list:
```dart
        warmupSuggestions,
```

**Step 6: Regenerate Hive adapter**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Updated `exercise.g.dart`

**Step 7: Commit**

```bash
git add lib/features/exercise_database/domain/entities/exercise.dart
git add lib/features/exercise_database/domain/entities/exercise.g.dart
git commit -m "feat(warmup): add warmupSuggestions field to ExerciseDefinition"
```

---

## Task 3: Add insertExerciseAt to Workout Entity

**Files:**
- Modify: `lib/features/workout/domain/entities/workout.dart`

**Step 1: Add method after addExercise (around line 79)**

```dart
  /// Insert exercise at specific position
  Workout insertExerciseAt(int index, Exercise exercise) {
    final newExercises = List<Exercise>.from(exercises);
    // Clamp index to valid range
    final safeIndex = index.clamp(0, newExercises.length);
    newExercises.insert(safeIndex, exercise);
    return copyWith(
      exercises: newExercises,
      updatedAt: DateTime.now(),
    );
  }
```

**Step 2: Regenerate freezed**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Updated `workout.freezed.dart`

**Step 3: Commit**

```bash
git add lib/features/workout/domain/entities/workout.dart
git add lib/features/workout/domain/entities/workout.freezed.dart
git commit -m "feat(workout): add insertExerciseAt method"
```

---

## Task 4: Add insertExerciseAt to WorkoutProvider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_provider.dart`

**Step 1: Add method after addExercise (around line 1228)**

```dart
  /// Insert exercise at specific position (before another exercise)
  void insertExerciseAt(int index, Exercise exercise) {
    if (state == null) return;

    if (kDebugMode) {
      debugPrint('🔍 [WorkoutProvider] insertExerciseAt index=$index, name=${exercise.name}');
    }

    // Record session activity
    ref.read(sessionActivityRecorderProvider);

    try {
      state = state!.insertExerciseAt(index, exercise);

      // Auto-save
      _autoSaveIfNeeded();

      // Track analytics
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        exerciseCategory: exercise.category.name,
        sets: exercise.sets.length,
        source: 'warmup_suggestion',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(LogCategory.workout, '❌ [WorkoutProvider] Error inserting exercise: $e');
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
    }
  }
```

**Step 2: Commit**

```bash
git add lib/features/workout/presentation/providers/workout_provider.dart
git commit -m "feat(workout): add insertExerciseAt to WorkoutProvider"
```

---

## Task 5: Create Warmup Exercises JSON

**Files:**
- Modify: `assets/data/exercises_it.json`

**Step 1: Add new warmup exercises at end of JSON array**

Add before the closing `]`:

```json
  {
    "id": "cat-cow",
    "nome": "Cat-Cow",
    "focus": "CORE",
    "muscoliSecondari": "",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Spine Flexion/Extension",
    "rangeRipetizioni": "8-12",
    "noteTecniche": "Alternare flessione ed estensione della colonna in modo fluido | Sincronizzare il respiro: inspira in estensione, espira in flessione",
    "isWarmup": true
  },
  {
    "id": "bird-dog",
    "nome": "Bird Dog",
    "focus": "CORE",
    "muscoliSecondari": "GLUT,SPALLE",
    "difficolta": "Principiante",
    "tipoEsercizio": "Stabilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Anti-Rotation",
    "rangeRipetizioni": "8-10",
    "noteTecniche": "Mantieni la schiena neutra | Estendi braccio e gamba opposti simultaneamente | Non ruotare il bacino",
    "isWarmup": true
  },
  {
    "id": "clamshell",
    "nome": "Clamshell",
    "focus": "GLUT",
    "muscoliSecondari": "ANCA",
    "difficolta": "Principiante",
    "tipoEsercizio": "Attivazione",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Abduction",
    "rangeRipetizioni": "12-15",
    "noteTecniche": "Sdraiati sul fianco con ginocchia piegate | Alza il ginocchio superiore mantenendo i piedi uniti | Non ruotare il bacino",
    "isWarmup": true
  },
  {
    "id": "fire-hydrant",
    "nome": "Fire Hydrant",
    "focus": "GLUT",
    "muscoliSecondari": "ANCA",
    "difficolta": "Principiante",
    "tipoEsercizio": "Attivazione",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Abduction",
    "rangeRipetizioni": "10-12",
    "noteTecniche": "In quadrupedia, alza lateralmente il ginocchio | Mantieni la schiena neutra | Contrai i glutei in alto",
    "isWarmup": true
  },
  {
    "id": "hip-circles",
    "nome": "Hip Circles",
    "focus": "ANCA",
    "muscoliSecondari": "GLUT",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Rotation",
    "rangeRipetizioni": "10-12",
    "noteTecniche": "In piedi su una gamba, disegna cerchi con il ginocchio | Mantieni il core attivo | Esegui in entrambe le direzioni",
    "isWarmup": true
  },
  {
    "id": "torso-rotations",
    "nome": "Rotazioni Torso",
    "focus": "CORE",
    "muscoliSecondari": "OBLIQUI",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Spine Rotation",
    "rangeRipetizioni": "10-12",
    "noteTecniche": "In piedi, ruota il busto da un lato all'altro | Mantieni i fianchi fermi | Movimento controllato",
    "isWarmup": true
  },
  {
    "id": "arm-circles",
    "nome": "Cerchi con le Braccia",
    "focus": "SPALLE",
    "muscoliSecondari": "",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Shoulder Rotation",
    "rangeRipetizioni": "10-15",
    "noteTecniche": "Braccia distese lateralmente, disegna cerchi | Inizia con cerchi piccoli, aumenta gradualmente | Esegui in entrambe le direzioni",
    "isWarmup": true
  },
  {
    "id": "wrist-circles",
    "nome": "Cerchi con i Polsi",
    "focus": "AVAMB",
    "muscoliSecondari": "",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Wrist Rotation",
    "rangeRipetizioni": "10-15",
    "noteTecniche": "Ruota i polsi in entrambe le direzioni | Utile prima di esercizi di presa",
    "isWarmup": true
  }
```

**Step 2: Commit**

```bash
git add assets/data/exercises_it.json
git commit -m "feat(warmup): add 8 new warmup exercises to database"
```

---

## Task 6: Create WarmupChips Widget

**Files:**
- Create: `lib/features/exercise_database/presentation/widgets/warmup_suggestion_chips.dart`

**Step 1: Create the widget**

```dart
/// Clickable chips for warmup exercise suggestions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Displays warmup suggestion chips that can be tapped to add exercises
class WarmupSuggestionChips extends StatelessWidget {
  const WarmupSuggestionChips({
    super.key,
    required this.suggestions,
    required this.addedExerciseIds,
    required this.onAdd,
    this.isLoading = false,
  });

  /// List of warmup suggestions to display
  final List<WarmupSuggestion> suggestions;

  /// Set of exercise IDs already added to workout
  final Set<String> addedExerciseIds;

  /// Callback when user taps to add an exercise
  final void Function(WarmupSuggestion) onAdd;

  /// Whether an add operation is in progress
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Group by type
    final mobilityExercises = suggestions
        .where((s) => s.type == WarmupType.mobility)
        .toList();
    final activationExercises = suggestions
        .where((s) => s.type == WarmupType.activation)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mobilityExercises.isNotEmpty) ...[
          _buildTypeHeader(context, WarmupType.mobility),
          const SizedBox(height: 8),
          _buildChipsRow(context, mobilityExercises),
          const SizedBox(height: 16),
        ],
        if (activationExercises.isNotEmpty) ...[
          _buildTypeHeader(context, WarmupType.activation),
          const SizedBox(height: 8),
          _buildChipsRow(context, activationExercises),
        ],
      ],
    );
  }

  Widget _buildTypeHeader(BuildContext context, WarmupType type) {
    final (icon, label) = switch (type) {
      WarmupType.mobility => ('🔄', context.l10n.warmupPhase1Title.replaceAll('🔄 ', '')),
      WarmupType.activation => ('⚡', context.l10n.warmupPhase2Title.replaceAll('⚡ ', '')),
    };

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow(BuildContext context, List<WarmupSuggestion> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((suggestion) {
        final isAdded = addedExerciseIds.contains(suggestion.exerciseId);
        return _WarmupChip(
          suggestion: suggestion,
          isAdded: isAdded,
          isLoading: isLoading,
          onTap: isAdded ? null : () => onAdd(suggestion),
        );
      }).toList(),
    );
  }
}

class _WarmupChip extends StatelessWidget {
  const _WarmupChip({
    required this.suggestion,
    required this.isAdded,
    required this.isLoading,
    this.onTap,
  });

  final WarmupSuggestion suggestion;
  final bool isAdded;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isAdded
        ? context.colors.success
        : context.colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isAdded ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isAdded ? 0.4 : 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isAdded
                    ? Icon(
                        AppIcons.check,
                        key: const ValueKey('check'),
                        size: 16,
                        color: color,
                      )
                    : Icon(
                        AppIcons.add,
                        key: const ValueKey('add'),
                        size: 16,
                        color: color,
                      ),
              ),
              const SizedBox(width: 6),
              // Name and reps
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.exerciseName,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${suggestion.sets}×${suggestion.reps}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/exercise_database/presentation/widgets/warmup_suggestion_chips.dart
git commit -m "feat(warmup): create WarmupSuggestionChips widget"
```

---

## Task 7: Update ExerciseDetailsModal

**Files:**
- Modify: `lib/features/exercise_database/presentation/widgets/exercise_details_modal.dart`

**Step 1: Add imports**

```dart
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_suggestion_chips.dart';
```

**Step 2: Add callback parameters to class**

Update constructor and fields (around line 11-17):

```dart
class ExerciseDetailsModal extends StatefulWidget {
  const ExerciseDetailsModal({
    super.key,
    required this.exercise,
    this.currentExerciseIndex,
    this.onWarmupExerciseAdded,
  });

  final Exercise exercise;

  /// Index of current exercise in workout (for insert position)
  final int? currentExerciseIndex;

  /// Callback when warmup exercise should be added
  final void Function(WarmupSuggestion suggestion, int beforeIndex)? onWarmupExerciseAdded;

  /// Show the modal as a bottom sheet
  static Future<void> show(
    BuildContext context,
    Exercise exercise, {
    int? currentExerciseIndex,
    void Function(WarmupSuggestion, int)? onWarmupExerciseAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailsModal(
        exercise: exercise,
        currentExerciseIndex: currentExerciseIndex,
        onWarmupExerciseAdded: onWarmupExerciseAdded,
      ),
    );
  }

  @override
  State<ExerciseDetailsModal> createState() => _ExerciseDetailsModalState();
}

class _ExerciseDetailsModalState extends State<ExerciseDetailsModal> {
  final Set<String> _addedExerciseIds = {};
```

**Step 3: Update _buildWarmupSection to use chips when available**

Replace `_buildWarmupSection` method:

```dart
  Widget _buildWarmupSection(BuildContext context) {
    final hasStructuredSuggestions =
        widget.exercise.warmupSuggestions?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Info Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: AppIcons.wbSunnyOutlined,
                  semanticLabel: 'Warmup',
                  size: AppIconSize.small,
                  color: context.colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.warmupProtocol,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => WarmupInfoDialog.show(context),
                icon: Icon(
                  AppIcons.info,
                  color: context.colors.primary,
                  size: 20,
                ),
                tooltip: context.l10n.warmupPhaseInfo,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Structured chips (if available and callback provided)
          if (hasStructuredSuggestions &&
              widget.onWarmupExerciseAdded != null) ...[
            WarmupSuggestionChips(
              suggestions: widget.exercise.warmupSuggestions!,
              addedExerciseIds: _addedExerciseIds,
              onAdd: _handleAddWarmupExercise,
            ),
            const SizedBox(height: 16),
          ],

          // Fallback text display
          if (widget.exercise.mobilitaPre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '🔄',
              title: context.l10n.warmupPhase1Title.replaceAll('🔄 ', ''),
              content: widget.exercise.mobilitaPre!,
            ),
            const SizedBox(height: 12),
          ],

          if (widget.exercise.attivazionePre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '⚡',
              title: context.l10n.warmupPhase2Title.replaceAll('⚡ ', ''),
              content: widget.exercise.attivazionePre!,
            ),
            const SizedBox(height: 12),
          ],

          if (widget.exercise.warmupSets != null) ...[
            _buildWarmupPhase(
              context,
              icon: '🏋️',
              title: context.l10n.warmupSetsLabel,
              content: widget.exercise.warmupSets!,
              isMonospace: true,
            ),
            const SizedBox(height: 12),
          ],

          if (widget.exercise.tempoWarmup != null) ...[
            _buildWarmupPhase(
              context,
              icon: '⏱️',
              title: context.l10n.warmupTimeLabel,
              content: widget.exercise.tempoWarmup!,
            ),
          ],
        ],
      ),
    );
  }

  void _handleAddWarmupExercise(WarmupSuggestion suggestion) {
    if (widget.currentExerciseIndex == null ||
        widget.onWarmupExerciseAdded == null) return;

    setState(() {
      _addedExerciseIds.add(suggestion.exerciseId);
    });

    widget.onWarmupExerciseAdded!(suggestion, widget.currentExerciseIndex!);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${suggestion.exerciseName} aggiunto prima di ${widget.exercise.nome}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
```

**Step 4: Update build method to use state**

Change `extends StatelessWidget` to `extends StatefulWidget` and update build:

```dart
  @override
  Widget build(BuildContext context) {
    // ... existing code but use widget.exercise instead of exercise
  }
```

**Step 5: Commit**

```bash
git add lib/features/exercise_database/presentation/widgets/exercise_details_modal.dart
git commit -m "feat(warmup): add clickable warmup chips to ExerciseDetailsModal"
```

---

## Task 8: Wire Up in Orchestrator

**Files:**
- Modify: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart`

**Step 1: Find _handleShowExerciseInfo method and update**

Update the method to pass callback:

```dart
void _handleShowExerciseInfo() {
  // Find current exercise index
  final workout = ref.read(currentWorkoutProvider);
  final exerciseIndex = workout?.exercises
      .indexWhere((e) => e.id == widget.exercise.id) ?? -1;

  ExerciseDetailsModal.show(
    context,
    _getExerciseDefinition(), // Get from database
    currentExerciseIndex: exerciseIndex >= 0 ? exerciseIndex : null,
    onWarmupExerciseAdded: exerciseIndex >= 0
        ? (suggestion, beforeIndex) {
            _addWarmupExercise(suggestion, beforeIndex);
          }
        : null,
  );
}

void _addWarmupExercise(WarmupSuggestion suggestion, int beforeIndex) {
  // Create Exercise from suggestion
  final exercise = Exercise(
    name: suggestion.exerciseName,
    type: ExerciseType.single,
    category: ExerciseCategory.other,
    sets: List.generate(
      suggestion.sets,
      (i) => ExerciseSet(
        targetReps: suggestion.reps,
        isCompleted: false,
      ),
    ),
  );

  // Insert before current exercise
  ref.read(currentWorkoutProvider.notifier).insertExerciseAt(
    beforeIndex,
    exercise,
  );
}

ExerciseDefinition _getExerciseDefinition() {
  // Try to get from database, fallback to creating from workout exercise
  final exerciseDb = ref.read(exerciseRepositoryProvider);
  return exerciseDb.getExerciseById(widget.exercise.definitionId) ??
      ExerciseDefinition(
        id: widget.exercise.id,
        nome: widget.exercise.name,
        focus: [],
        muscoliSecondari: [],
        difficolta: 'Intermedio',
        tipoEsercizio: '',
        attrezzatura: '',
        patternMovimento: '',
        rangeRipetizioni: '',
      );
}
```

**Step 2: Add import**

```dart
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
```

**Step 3: Commit**

```bash
git add lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart
git commit -m "feat(warmup): wire up warmup chips in exercise orchestrator"
```

---

## Task 9: Add Sample warmupSuggestions to Squat

**Files:**
- Modify: `assets/data/exercises_it.json`

**Step 1: Find Squat exercises and add warmupSuggestions**

Find "Squat con Bilanciere" and add:

```json
    "warmupSuggestions": [
      {"exerciseId": "hip-circles", "exerciseName": "Hip Circles", "sets": 2, "reps": 10, "type": "mobility"},
      {"exerciseId": "torso-rotations", "exerciseName": "Rotazioni Torso", "sets": 2, "reps": 12, "type": "mobility"},
      {"exerciseId": "glute-bridge", "exerciseName": "Ponte Glutei", "sets": 2, "reps": 12, "type": "activation"},
      {"exerciseId": "fire-hydrant", "exerciseName": "Fire Hydrant", "sets": 2, "reps": 10, "type": "activation"}
    ],
```

**Step 2: Commit**

```bash
git add assets/data/exercises_it.json
git commit -m "feat(warmup): add warmupSuggestions to Squat exercises"
```

---

## Task 10: Test & Verify

**Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

**Step 2: Run the app and test**

1. Start a workout
2. Add Squat exercise
3. Tap info icon on Squat
4. Verify warmup chips appear
5. Tap a chip to add warmup exercise
6. Verify exercise appears before Squat

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat(warmup): complete warmup suggestions feature

- Add WarmupSuggestion model
- Add warmupSuggestions field to ExerciseDefinition
- Add insertExerciseAt to Workout entity
- Create WarmupSuggestionChips widget
- Update ExerciseDetailsModal with clickable chips
- Add 8 new warmup exercises to database
- Wire up in exercise orchestrator"
```

---

## Summary

| Task | Description | Est. Time |
|------|-------------|-----------|
| 1 | Create WarmupSuggestion model | 5 min |
| 2 | Add field to ExerciseDefinition | 5 min |
| 3 | Add insertExerciseAt to Workout | 3 min |
| 4 | Add to WorkoutProvider | 5 min |
| 5 | Create warmup exercises JSON | 10 min |
| 6 | Create WarmupChips widget | 15 min |
| 7 | Update ExerciseDetailsModal | 15 min |
| 8 | Wire up in Orchestrator | 10 min |
| 9 | Add sample data to Squat | 5 min |
| 10 | Test & verify | 10 min |

**Total: ~80 minutes**
