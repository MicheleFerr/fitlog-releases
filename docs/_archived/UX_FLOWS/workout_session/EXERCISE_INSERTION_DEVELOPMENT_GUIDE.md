# 🔧 EXERCISE INSERTION DEVELOPMENT GUIDE

> **For**: Flutter Developers implementing exercise insertion features
>
> **Purpose**: Rules of Engagement (ROE) for modifying exercise insertion flow, state management, and customization

---

## 📋 Quick Navigation

- [1. Architecture Overview](#1-architecture-overview)
- [2. Modal Structure](#2-modal-structure)
- [3. State Management](#3-state-management)
- [4. Exercise Types Implementation](#4-exercise-types-implementation)
- [5. Customization and Settings](#5-customization-and-settings)
- [6. Data Persistence](#6-data-persistence)
- [7. UI/UX Guidelines](#7-uiux-guidelines)
- [8. Performance Requirements](#8-performance-requirements)
- [9. Testing Requirements](#9-testing-requirements)
- [10. Pre-Commit Checklist](#10-pre-commit-checklist)

---

## 1. Architecture Overview

### **Modal Stack Architecture**

```
AddExerciseModal (1,502 lines)
├── Single Exercise Tab
│   ├── ExerciseSearchScreen (Database browse)
│   ├── ExerciseCustomizationScreen (Sets/reps/weight)
│   └── Confirmation flow
│
└── Advanced Tab
    ├── SupersetBuilderWidget (2-4 exercises)
    ├── DropSetConfiguration (3-5 stages)
    └── RestPauseConfiguration (Mini-sets)
```

### **Key File Locations**

| Component | Path | Lines |
|-----------|------|-------|
| Main Modal | `lib/features/workout/presentation/widgets/add_exercise_modal.dart` | 1,502 |
| Enhanced Alt | `lib/features/workout/presentation/widgets/enhanced_add_exercise_modal.dart` | ~ |
| Search Screen | `lib/features/exercise_database/presentation/exercise_search_screen.dart` | ~ |
| Customization | `lib/features/exercise_database/presentation/widgets/exercise_customization_screen.dart` | ~ |
| Superset Builder | `lib/features/workout/presentation/widgets/superset_builder_widget.dart` | ~ |
| Notifier | `lib/features/workout/presentation/providers/workout_provider.dart` | 35+ providers |

---

## 2. Modal Structure

### **AddExerciseModal Implementation Template**

```dart
class AddExerciseModal extends ConsumerWidget {
  final Function(Exercise) onExerciseAdded;

  const AddExerciseModal({
    required this.onExerciseAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ MUST USE BuildContext extensions
    final colors = context.colors;
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // ✅ Handle bar for dragging
              _buildHandleBar(context),

              // ✅ Tab navigation
              TabBar(
                labelText: [context.l10n.single, context.l10n.advanced],
                onTap: (index) {
                  // Handle tab change
                },
              ),

              // ✅ Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSingleTab(context, ref),
                    _buildAdvancedTab(context, ref),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSingleTab(BuildContext context, WidgetRef ref) {
    // ✅ SINGLE EXERCISE FLOW
    return Column(
      children: [
        // 1. Browse database
        Expanded(
          child: ExerciseSearchScreen(
            onExerciseSelected: (exercise) {
              // 2. Navigate to customization
              _showCustomizationScreen(context, exercise);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab(BuildContext context, WidgetRef ref) {
    // ✅ ADVANCED EXERCISE TYPES
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: context.l10n.superset),
              Tab(text: context.l10n.dropset),
              Tab(text: context.l10n.restPause),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SupersetBuilderWidget(
                  onExerciseAdded: onExerciseAdded,
                ),
                DropSetBuilderWidget(
                  onExerciseAdded: onExerciseAdded,
                ),
                RestPauseBuilderWidget(
                  onExerciseAdded: onExerciseAdded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomizationScreen(
    BuildContext context,
    Exercise exercise,
  ) async {
    // ✅ Navigate to customization with the selected exercise
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseCustomizationScreen(
          exercise: exercise,
        ),
      ),
    );

    if (result != null) {
      onExerciseAdded(result);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
```

---

## 3. State Management

### **Exercise Insertion Providers (MANDATORY)**

```dart
// ✅ Provider for dynamic sets management
final exerciseSetsProvider = StateNotifierProvider<
  ExerciseSetsNotifier,
  List<ExerciseSet>
>((ref) {
  return ExerciseSetsNotifier();
});

// ✅ Notifier implementation
class ExerciseSetsNotifier extends StateNotifier<List<ExerciseSet>> {
  ExerciseSetsNotifier() : super([
    ExerciseSet(setNumber: 1),
    ExerciseSet(setNumber: 2),
    ExerciseSet(setNumber: 3),
  ]);

  void addSet() {
    final newSet = ExerciseSet(setNumber: state.length + 1);
    state = [...state, newSet];
  }

  void removeSet(int index) {
    if (state.length <= 1) return; // ✅ Minimum 1 set required
    state = state.whereIndexed((i, _) => i != index).toList();
  }

  void updateSet(int index, ExerciseSet updated) {
    state = state.whereIndexed((i, _) {
      return i == index ? updated : state[i];
    }).toList();
  }

  void reset() {
    state = [
      ExerciseSet(setNumber: 1),
      ExerciseSet(setNumber: 2),
      ExerciseSet(setNumber: 3),
    ];
  }
}

// ✅ Provider for superset exercises
final supersetExercisesProvider = StateNotifierProvider<
  SupersetExercisesNotifier,
  List<Exercise>
>((ref) {
  return SupersetExercisesNotifier();
});

// ✅ Provider for category selection
final selectedExerciseCategoryProvider = StateProvider<ExerciseCategory>(
  (ref) => ExerciseCategory.chest,
);

// ✅ Provider for exercise type
final selectedExerciseTypeProvider = StateProvider<ExerciseType>(
  (ref) => ExerciseType.single,
);

// ✅ CRITICAL: Watch only what you need
// In ExerciseCustomizationScreen:
final sets = ref.watch(
  exerciseSetsProvider.select((s) => s) // Only sets
);

final category = ref.watch(
  selectedExerciseCategoryProvider.select((c) => c) // Only category
);
```

### **Workout State Provider (Integration)**

```dart
// In workout_provider.dart

final currentWorkoutProvider = StateNotifierProvider<
  CurrentWorkoutNotifier,
  Workout?
>((ref) {
  return CurrentWorkoutNotifier(ref);
});

class CurrentWorkoutNotifier extends StateNotifier<Workout?> {
  final Ref ref;

  CurrentWorkoutNotifier(this.ref) : super(null);

  // ✅ PRIMARY: Add exercise to workout
  Future<void> addExercise(Exercise exercise) async {
    if (state == null) return;

    try {
      // 1. If APRE enabled, auto-calculate weight
      Exercise updatedExercise = exercise;
      if (exercise.useAPRE) {
        updatedExercise = await _calculateAPREWeight(exercise);
      }

      // 2. Add to workout
      state = state!.addExercise(updatedExercise);

      // 3. Auto-save to Hive
      await _saveCurrentWorkoutLocally();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error adding exercise: $e');
      }
      rethrow;
    }
  }

  // ✅ Add superset to workout
  Future<void> addSuperset(SupersetExercise superset) async {
    if (state == null) return;

    try {
      // Convert SupersetExercise to Exercise with type=superset
      final exercise = Exercise(
        id: const Uuid().v4(),
        name: _generateSupersetName(superset.exercises),
        exerciseType: ExerciseType.superset,
        supersetExercises: superset,
        category: superset.exercises.first.category,
      );

      state = state!.addExercise(exercise);
      await _saveCurrentWorkoutLocally();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error adding superset: $e');
      }
      rethrow;
    }
  }

  // ✅ APRE weight calculation
  Future<Exercise> _calculateAPREWeight(Exercise exercise) async {
    try {
      // 1. Fetch user's exercise history
      final history = await ref
          .read(exerciseHistoryProvider.future)
          .then((h) => h.forExercise(exercise.id));

      // 2. Calculate 1RM from history
      final estimated1RM = _calculate1RM(history);

      // 3. Get percentage based on protocol
      final percentage = _getPercentageForProtocol(exercise.apreProtocol);

      // 4. Return exercise with calculated weight
      return exercise.copyWith(
        sets: exercise.sets.map((set) {
          return set.copyWith(
            weight: (estimated1RM * percentage / 100).roundToNearest(2.5),
          );
        }).toList(),
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ APRE calculation failed: $e');
      }
      // Fallback: return original exercise
      return exercise;
    }
  }

  double _calculate1RM(ExerciseHistory history) {
    // ✅ Epley Formula: 1RM = weight × (1 + reps/30)
    if (history.isEmpty) return 100; // Default fallback

    final lastSet = history.last;
    return lastSet.weight * (1 + lastSet.reps / 30);
  }

  String _generateSupersetName(List<Exercise> exercises) {
    // ✅ Generate readable name
    // E.g: "Push + Pull + Legs"
    return exercises
        .map((e) => e.name.split(' ').first)
        .join(' + ');
  }

  Future<void> _saveCurrentWorkoutLocally() async {
    // ✅ Save to Hive immediately (no wait)
    try {
      final box = await Hive.openBox<Workout>('workouts');
      if (state != null) {
        await box.put('current_workout', state!);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Hive save failed: $e');
      }
    }
  }
}
```

---

## 4. Exercise Types Implementation

### **Superset Exercise (2+ exercises back-to-back)**

```dart
// ✅ Data model
class SupersetExercise {
  final String id;
  final String name;
  final List<Exercise> exercises; // 2-4 exercises
  final List<SupersetRound> rounds;
  final Duration restBetweenExercises; // Time between exercises in set
  final Duration restBetweenRounds; // Time between rounds

  SupersetExercise({
    String? id,
    required this.name,
    required this.exercises,
    List<SupersetRound>? rounds,
    this.restBetweenExercises = const Duration(seconds: 0),
    this.restBetweenRounds = const Duration(seconds: 120),
  }) :
    id = id ?? const Uuid().v4(),
    rounds = rounds ?? [
      SupersetRound(roundNumber: 1),
      SupersetRound(roundNumber: 2),
      SupersetRound(roundNumber: 3),
    ];

  // ✅ Calculate total volume
  int get totalVolume {
    return rounds.fold(0, (sum, round) {
      return sum + round.getTotalReps();
    });
  }
}

// ✅ Implementation template
class SupersetBuilderWidget extends ConsumerWidget {
  final Function(SupersetExercise) onExerciseAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedExercises = ref.watch(supersetExercisesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ STEP 1: Select exercises (2-4)
            Text(context.l10n.selectExercises),
            SizedBox(height: 16),
            ..._buildExerciseSlots(context, ref, selectedExercises),

            // ✅ STEP 2: Configure rounds
            SizedBox(height: 24),
            Text(context.l10n.numberOfRounds),
            SizedBox(height: 8),
            _buildRoundsInput(context, ref),

            // ✅ STEP 3: Rest between exercises
            SizedBox(height: 24),
            Text(context.l10n.restBetweenExercises),
            SizedBox(height: 8),
            _buildRestInput(context, ref),

            // ✅ STEP 4: Confirm button
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: selectedExercises.length >= 2
                  ? () => _confirmSuperset(context, ref)
                  : null,
              icon: Icon(Icons.add),
              label: Text(context.l10n.addSuperset),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExerciseSlots(
    BuildContext context,
    WidgetRef ref,
    List<Exercise> selected,
  ) {
    return [
      for (int i = 0; i < 4; i++)
        _buildExerciseSlot(context, ref, i, selected),
    ];
  }

  Widget _buildExerciseSlot(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<Exercise> selected,
  ) {
    // ✅ Each slot shows selected exercise or "Add" button
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: selected.length > index
          ? _buildSelectedExercise(context, ref, index, selected[index])
          : _buildAddExerciseButton(context, ref, index),
    );
  }

  Widget _buildAddExerciseButton(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _showExerciseSelection(context, ref, index),
      icon: Icon(Icons.add),
      label: Text('${context.l10n.exercise} ${index + 1}'),
    );
  }

  void _confirmSuperset(BuildContext context, WidgetRef ref) {
    // ✅ Create SupersetExercise and add to workout
    final exercises = ref.read(supersetExercisesProvider);
    final rounds = 3; // Configurable

    final superset = SupersetExercise(
      name: _generateName(exercises),
      exercises: exercises,
      rounds: List.generate(
        rounds,
        (i) => SupersetRound(roundNumber: i + 1),
      ),
    );

    onExerciseAdded(superset);

    // ✅ Reset state
    ref.read(supersetExercisesProvider.notifier).clear();

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
```

### **Drop Set Exercise (Progressive weight reduction)**

```dart
// ✅ Data model
class DropSetExercise {
  final String id;
  final String name;
  final Exercise baseExercise;
  final List<DropSetStage> stages; // 3-5 stages

  DropSetExercise({
    String? id,
    required this.name,
    required this.baseExercise,
    List<DropSetStage>? stages,
  }) :
    id = id ?? const Uuid().v4(),
    stages = stages ?? [
      DropSetStage(
        stageNumber: 1,
        weight: baseExercise.sets.first.weight,
        label: '🔴 ${context.l10n.heavy}',
      ),
      DropSetStage(
        stageNumber: 2,
        weight: baseExercise.sets.first.weight * 0.8,
        label: '🟡 ${context.l10n.medium}',
      ),
      DropSetStage(
        stageNumber: 3,
        weight: baseExercise.sets.first.weight * 0.6,
        label: '🟢 ${context.l10n.light}',
      ),
    ];
}

class DropSetStage {
  final int stageNumber;
  final double weight;
  final String label;
  final int? targetReps;
  int actualReps = 0;
  bool isCompleted = false;

  DropSetStage({
    required this.stageNumber,
    required this.weight,
    required this.label,
    this.targetReps,
  });
}

// ✅ Implementation
class DropSetBuilderWidget extends ConsumerWidget {
  final Function(DropSetExercise) onExerciseAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ STEP 1: Select base exercise
            _buildExerciseSelector(context, ref),

            SizedBox(height: 24),

            // ✅ STEP 2: Configure stages
            Text(context.l10n.configureStages),
            SizedBox(height: 16),
            _buildStagesConfiguration(context, ref),

            SizedBox(height: 32),

            // ✅ STEP 3: Add button
            ElevatedButton.icon(
              onPressed: () => _confirmDropSet(context, ref),
              icon: Icon(Icons.add),
              label: Text(context.l10n.addDropSet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagesConfiguration(
    BuildContext context,
    WidgetRef ref,
  ) {
    // ✅ Show 3-5 stages with weight pickers
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          _buildStageRow(context, ref, i),
      ],
    );
  }

  Widget _buildStageRow(
    BuildContext context,
    WidgetRef ref,
    int stageIndex,
  ) {
    // ✅ Each stage shows:
    // - Label (Heavy, Medium, Light)
    // - Weight picker
    // - Reps field

    final labels = [
      '🔴 ${context.l10n.heavy}',
      '🟡 ${context.l10n.medium}',
      '🟢 ${context.l10n.light}',
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(labels[stageIndex]),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '${context.l10n.weight} (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '${context.l10n.reps}',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### **Rest-Pause Exercise (Mini-sets with pauses)**

```dart
// ✅ Data model
class RestPauseExercise {
  final String id;
  final String name;
  final double weight; // Single weight, all mini-sets use same
  final int targetReps;
  final List<RestPauseMiniSet> miniSets;
  final Duration restBetweenMiniSets;

  RestPauseExercise({
    String? id,
    required this.name,
    required this.weight,
    required this.targetReps,
    List<RestPauseMiniSet>? miniSets,
    this.restBetweenMiniSets = const Duration(seconds: 15),
  }) :
    id = id ?? const Uuid().v4(),
    miniSets = miniSets ?? [
      RestPauseMiniSet(miniSetNumber: 1),
      RestPauseMiniSet(miniSetNumber: 2),
      RestPauseMiniSet(miniSetNumber: 3),
    ];

  // ✅ Total volume
  int get totalReps {
    return miniSets.fold(0, (sum, ms) => sum + (ms.actualReps ?? 0));
  }
}

// ✅ Implementation
class RestPauseBuilderWidget extends ConsumerWidget {
  final Function(RestPauseExercise) onExerciseAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Select exercise first
            _buildExerciseSelector(context, ref),

            SizedBox(height: 24),

            // ✅ Weight
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${context.l10n.weight} (kg)',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // ✅ Target reps
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${context.l10n.targetReps}',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // ✅ Number of mini-sets
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${context.l10n.numberOfMiniSets}',
                helperText: 'Usually 3-4',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // ✅ Rest between mini-sets
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${context.l10n.restBetweenMiniSets} (seconds)',
                helperText: 'Usually 15-30 seconds',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () => _confirmRestPause(context, ref),
              icon: Icon(Icons.add),
              label: Text(context.l10n.addRestPause),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Customization and Settings

### **ExerciseCustomizationScreen Template**

```dart
class ExerciseCustomizationScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseCustomizationScreen({required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch sets from provider
    final sets = ref.watch(exerciseSetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ✅ Exercise info
          _buildExerciseInfo(context),

          SizedBox(height: 24),

          // ✅ Sets configuration
          Text(
            context.l10n.configureSets,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: 16),

          // ✅ Dynamic sets list
          ...sets.asMap().entries.map((entry) {
            return _buildSetRow(context, ref, entry.key, entry.value);
          }),

          SizedBox(height: 16),

          // ✅ Add/remove set buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(exerciseSetsProvider.notifier).addSet();
                },
                icon: Icon(Icons.add),
                label: Text(context.l10n.addSet),
              ),
              SizedBox(width: 8),
              if (sets.length > 1)
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(exerciseSetsProvider.notifier)
                        .removeSet(sets.length - 1);
                  },
                  icon: Icon(Icons.remove),
                  label: Text(context.l10n.removeSet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.error,
                  ),
                ),
            ],
          ),

          SizedBox(height: 24),

          // ✅ Notes field
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.notes,
              border: OutlineInputBorder(),
              maxLines: 3,
            ),
          ),

          SizedBox(height: 32),

          // ✅ Confirm button
          ElevatedButton.icon(
            onPressed: () => _confirmExercise(context, ref),
            icon: Icon(Icons.check),
            label: Text(context.l10n.addToWorkout),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    BuildContext context,
    WidgetRef ref,
    int index,
    ExerciseSet set,
  ) {
    // ✅ Each set shows weight, reps, rest time
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // ✅ Set number
            Text('${context.l10n.set} ${index + 1}:'),
            SizedBox(width: 12),

            // ✅ Weight picker
            Expanded(
              child: _buildWeightPicker(context, ref, index, set),
            ),

            // ✅ Reps picker
            Expanded(
              child: _buildRepsPicker(context, ref, index, set),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPicker(
    BuildContext context,
    WidgetRef ref,
    int index,
    ExerciseSet set,
  ) {
    // ✅ Can use wheel picker or text field
    // Recommendation: Wheel picker for UX
    return TextField(
      keyboardType: TextInputType.number,
      controller: TextEditingController(
        text: set.weight?.toStringAsFixed(1) ?? '0',
      ),
      decoration: InputDecoration(
        labelText: '${context.l10n.weight} (kg)',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        final weight = double.tryParse(value);
        if (weight != null) {
          final updated = set.copyWith(weight: weight);
          ref.read(exerciseSetsProvider.notifier)
              .updateSet(index, updated);
        }
      },
    );
  }

  Widget _buildRepsPicker(
    BuildContext context,
    WidgetRef ref,
    int index,
    ExerciseSet set,
  ) {
    // ✅ Quick presets: 5, 8, 10, 12, 15
    return TextField(
      keyboardType: TextInputType.number,
      controller: TextEditingController(
        text: set.reps?.toString() ?? '0',
      ),
      decoration: InputDecoration(
        labelText: context.l10n.reps,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        final reps = int.tryParse(value);
        if (reps != null) {
          final updated = set.copyWith(reps: reps);
          ref.read(exerciseSetsProvider.notifier)
              .updateSet(index, updated);
        }
      },
    );
  }

  void _confirmExercise(BuildContext context, WidgetRef ref) {
    // ✅ VALIDATION
    final sets = ref.read(exerciseSetsProvider);

    if (sets.isEmpty) {
      SnackBarService.showError(context, context.l10n.atLeastOneSet);
      return;
    }

    if (sets.any((s) => s.weight == null || s.reps == null)) {
      SnackBarService.showError(context, context.l10n.fillAllFields);
      return;
    }

    // ✅ CREATE UPDATED EXERCISE
    final updated = exercise.copyWith(sets: sets);

    // ✅ RETURN AND CLOSE
    Navigator.of(context).pop(updated);
  }
}
```

---

## 6. Data Persistence

### **Save Flow (MANDATORY)**

```dart
// ✅ When exercise added, ALWAYS save locally first
Future<void> _saveCurrentWorkoutLocally() async {
  try {
    // 1. ALWAYS save to Hive FIRST (instant)
    final box = await Hive.openBox<Workout>('workouts');
    if (state != null) {
      await box.put('current_workout', state!);
    }

    // 2. IF premium user, sync cloud in BACKGROUND (non-blocking)
    if (_isPremiumUser()) {
      _syncToFirebaseInBackground();
    }

  } on HiveError catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Hive save error: $e');
    }
  }
}

// ✅ Background Firebase sync
void _syncToFirebaseInBackground() {
  // Don't await - just fire and forget
  _repo.syncCurrentWorkoutToFirebase(state!).then((_) {
    if (kDebugMode) {
      debugPrint('✅ Synced to Firebase');
    }
  }).catchError((e) {
    if (kDebugMode) {
      debugPrint('⚠️ Firebase sync failed: $e');
    }
    // Don't rethrow - background operation
  });
}
```

---

## 7. UI/UX Guidelines

### **Localization (MANDATORY)**

```dart
// ✅ All strings must use context.l10n
addExerciseTitle              // "Add Exercise"
selectCategory               // "Select Category"
exerciseWeight               // "Exercise Weight"
setsLabel                    // "Sets"
repsLabel                    // "Reps"
restTime                     // "Rest Time"
tabSingle                    // "Single"
tabAdvanced                  // "Advanced"
tabSuperset                  // "Superset"
tabDropSet                   // "Drop Set"
tabRestPause                 // "Rest-Pause"

// Add to app_en.arb and app_it.arb
// Run: flutter gen-l10n
```

### **Theme Colors (MANDATORY)**

```dart
// ✅ Use context.colors, NOT hardcoded
Container(
  color: context.colors.surface,
  child: Text(
    'Exercise',
    style: TextStyle(
      color: context.colors.onSurface,
    ),
  ),
)

// Category colors (consistent)
Color _getCategoryColor(ExerciseCategory cat) {
  switch (cat) {
    case ExerciseCategory.chest:
      return Color(0xFFEF5350); // Red
    case ExerciseCategory.back:
      return Color(0xFF42A5F5); // Blue
    // ... etc
  }
}
```

### **Responsive Design**

```dart
// ✅ Use extensions for responsive layout
final isMobile = context.screenWidth < 600;
final padding = isMobile ? 8.0 : 16.0;

// Modal should be full-height on mobile, smaller on tablet
final modalHeight = isMobile ? 0.95 : 0.85;
```

---

## 8. Performance Requirements

### **Mandatory Optimizations**

```dart
// ✅ Use const where possible
const SizedBox(height: 16)

// ✅ Debounce weight/reps input (500ms)
final debouncedWeightInput = Future.delayed(
  Duration(milliseconds: 500),
  () => updateWeight(value),
);

// ✅ Lazy load exercise database
// Don't load all 500+ exercises at once
// Load in batches on scroll

// ✅ Cache exercise search results
// Don't re-search if query is same

// ✅ Pagination for modal
// Load 20 exercises, load more on scroll
```

### **Performance Metrics**

| Metric | Target |
|--------|--------|
| Modal open | < 300ms |
| Search response | < 100ms |
| Exercise select | < 100ms |
| Customization render | < 200ms |
| Add to workout | < 500ms |
| Total flow | < 2 seconds |

---

## 9. Testing Requirements

### **Unit Test Template**

```dart
void main() {
  group('ExerciseInsertion', () {
    // ✅ Test adding exercise
    test('should add exercise to workout', () async {
      final workout = Workout(name: 'Test');
      final exercise = Exercise(name: 'Bench Press');

      final updated = workout.addExercise(exercise);

      expect(updated.exercises.length, 1);
      expect(updated.exercises.first.name, 'Bench Press');
    });

    // ✅ Test APRE calculation
    test('should calculate APRE weight correctly', () {
      final exercise = Exercise(
        useAPRE: true,
        apreProtocol: ApreProtocol.three,
      );
      final history = [ExerciseHistory(weight: 100, reps: 3)];

      final calculated = calculateAPREWeight(exercise, history);

      expect(calculated, lessThan(100)); // Should be % of 1RM
    });

    // ✅ Test superset
    test('should create superset with 2+ exercises', () {
      final ex1 = Exercise(name: 'Bench');
      final ex2 = Exercise(name: 'Rows');

      final superset = SupersetExercise(
        exercises: [ex1, ex2],
      );

      expect(superset.exercises.length, 2);
    });

    // ✅ Test drop set
    test('should reduce weight progressively in drop set', () {
      final dropset = DropSetExercise(
        baseWeight: 100,
      );

      expect(dropset.stages[0].weight, 100);
      expect(dropset.stages[1].weight, 80);
      expect(dropset.stages[2].weight, 60);
    });
  });
}
```

### **Widget Test Template**

```dart
void main() {
  group('ExerciseCustomizationScreen', () {
    testWidgets('should display exercise name', (tester) async {
      final exercise = Exercise(name: 'Bench Press');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ExerciseCustomizationScreen(exercise: exercise),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('should add set when button tapped', (tester) async {
      await tester.pumpWidget(/* ... */);

      final initialSets = find.byType(SetRow).evaluate().length;

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final newSets = find.byType(SetRow).evaluate().length;
      expect(newSets, initialSets + 1);
    });

    testWidgets('should update weight in provider', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        ProviderScope(
          container: container,
          child: MaterialApp(home: Scaffold(body: CustomizationScreen())),
        ),
      );

      await tester.enterText(find.byType(WeightField), '95.0');
      await tester.pumpAndSettle();

      final sets = container.read(exerciseSetsProvider);
      expect(sets.first.weight, 95.0);
    });
  });
}
```

---

## 10. Pre-Commit Checklist

Before committing exercise insertion changes:

### **Code Quality**
- [ ] 🔍 `flutter analyze` passes (0 errors)
- [ ] 🧪 All tests pass
- [ ] 📋 No hardcoded strings (use `context.l10n.*`)
- [ ] 🎨 No hardcoded colors (use `context.colors.*`)
- [ ] ✏️ No `print()` (use `debugPrint()` with `kDebugMode`)
- [ ] 📦 Imports use `package:` syntax

### **Localization**
- [ ] 🌍 New strings in `app_en.arb`
- [ ] 🇮🇹 New strings in `app_it.arb`
- [ ] ⚙️ Ran `flutter gen-l10n`
- [ ] ✅ All l10n keys are used

### **Theme & UI**
- [ ] 🎨 All colors use `context.colors.*`
- [ ] 📱 All text styles use `context.textTheme.*`
- [ ] 🧪 Widget tested in light AND dark mode
- [ ] 📐 Modal responsive on phone + tablet

### **State Management**
- [ ] 🔄 Using proper Riverpod patterns
- [ ] 📡 Hybrid storage pattern followed
- [ ] ✅ Error handling with Either/AsyncValue
- [ ] 🔒 No race conditions

### **Performance**
- [ ] ⚡ Used `const` where applicable
- [ ] 📊 Using `.select()` (not watching entire provider)
- [ ] 🖼️ Images lazy-loaded
- [ ] 💾 No memory leaks

### **Testing**
- [ ] ✅ Unit tests for business logic
- [ ] ✅ Widget tests for UI
- [ ] ✅ Integration tests for flow
- [ ] ✅ Test localization (EN + IT)

### **Security**
- [ ] 🔐 Input sanitized (no XSS)
- [ ] ✔️ User authentication verified
- [ ] 🚫 No API keys in code
- [ ] 🔒 Validation on all inputs

### **Documentation**
- [ ] 📖 Complex logic has comments
- [ ] 🎯 This guide was followed
- [ ] 📚 Architecture decisions documented

### **Git**
- [ ] 📝 Commit message follows format
- [ ] 🚫 No build files committed
- [ ] 📋 Related files grouped logically

---

## Example Commit

```bash
git add .
git commit -m "feat: implement exercise insertion modal with superset, dropset, rest-pause support

- Add AddExerciseModal with Single/Advanced tabs
- Implement SupersetBuilderWidget (2-4 exercises)
- Implement DropSetBuilderWidget (3-5 stages)
- Implement RestPauseBuilderWidget (mini-sets)
- Add APRE auto-weight calculation
- Integrate with ExerciseSearchScreen
- Add Italian/English localizations
- 100% test coverage
- Performance: < 2s total flow time
"
```

---

**Version**: 1.0
**Last Updated**: Ottobre 2025
**Audience**: Flutter Developers
**Related Files**:
- `EXERCISE_INSERTION_SYSTEM_OVERVIEW.md` - Non-technical overview
- `EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md` - Settings & toggles
- `CLAUDE.md` - General project rules
