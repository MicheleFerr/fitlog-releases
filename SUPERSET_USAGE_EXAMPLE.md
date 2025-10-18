# 🏋️ Superset Usage Example - Correct Round Logic

## Complete Example: Panca Piana + Overhead Press (3 Rounds)

### Initial Setup

```dart
// Create superset with 2 exercises and 3 rounds
final superset = SupersetExercise(
  name: "Panca Piana + Overhead Press",
  exercises: [
    Exercise(
      id: "1234_bench",
      name: "Panca Piana",
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [],
    ),
    Exercise(
      id: "1234_overhead",
      name: "Overhead Press",
      type: ExerciseType.single,
      category: ExerciseCategory.shoulders,
      sets: [],
    ),
  ],
  supersetSets: [
    // Round 1
    SupersetSet(
      id: "superset_round_1234567890_0_1",
      setNumber: 1,  // ✅ Unique identifier for Round 1
      exerciseData: {
        "1234_bench": SupersetExerciseData(
          exerciseId: "1234_bench",
          exerciseName: "Panca Piana",
          targetWeight: 60.0,
          targetReps: 8,
          isCompleted: false,
        ),
        "1234_overhead": SupersetExerciseData(
          exerciseId: "1234_overhead",
          exerciseName: "Overhead Press",
          targetWeight: 40.0,
          targetReps: 10,
          isCompleted: false,
        ),
      },
      isCompleted: false,
    ),

    // Round 2
    SupersetSet(
      id: "superset_round_1234567890_1_2",
      setNumber: 2,  // ✅ Unique identifier for Round 2
      exerciseData: {
        "1234_bench": SupersetExerciseData(
          exerciseId: "1234_bench",
          exerciseName: "Panca Piana",
          targetWeight: 65.0,
          targetReps: 6,
          isCompleted: false,
        ),
        "1234_overhead": SupersetExerciseData(
          exerciseId: "1234_overhead",
          exerciseName: "Overhead Press",
          targetWeight: 42.5,
          targetReps: 8,
          isCompleted: false,
        ),
      },
      isCompleted: false,
    ),

    // Round 3
    SupersetSet(
      id: "superset_round_1234567890_2_3",
      setNumber: 3,  // ✅ Unique identifier for Round 3
      exerciseData: {
        "1234_bench": SupersetExerciseData(
          exerciseId: "1234_bench",
          exerciseName: "Panca Piana",
          targetWeight: 70.0,
          targetReps: 4,
          isCompleted: false,
        ),
        "1234_overhead": SupersetExerciseData(
          exerciseId: "1234_overhead",
          exerciseName: "Overhead Press",
          targetWeight: 45.0,
          targetReps: 6,
          isCompleted: false,
        ),
      },
      isCompleted: false,
    ),
  ],
  restTime: 90, // 90 seconds rest after each round
);
```

## Step-by-Step Execution

### 1️⃣ User Starts Round 1

```dart
// UI opens SupersetSequentialExecutionSheet with roundIndex = 0
showModalBottomSheet(
  context: context,
  builder: (context) => SupersetSequentialExecutionSheet(
    superset: superset,
    roundIndex: 0,  // Round 1
    onRoundCompleted: (completedRound) {
      // Update only Round 1
      ref.read(currentWorkoutProvider.notifier)
        .updateSupersetSet(superset.id, completedRound);
    },
  ),
);
```

### 2️⃣ User Completes Panca Piana (Exercise 1)

```dart
// QuickEdit opens for Panca Piana
// User enters: 60kg, 8 reps, RPE 7
final updatedPanca = SupersetExerciseData(
  exerciseId: "1234_bench",
  exerciseName: "Panca Piana",
  targetWeight: 60.0,
  targetReps: 8,
  actualWeight: 60.0,   // ✅ User entered
  actualReps: 8,        // ✅ User entered
  rpe: 7,               // ✅ User entered
  isCompleted: true,    // ✅ Now completed
);
```

### 3️⃣ User Completes Overhead Press (Exercise 2)

```dart
// QuickEdit opens for Overhead Press
// User enters: 40kg, 10 reps, RPE 8
final updatedOverhead = SupersetExerciseData(
  exerciseId: "1234_overhead",
  exerciseName: "Overhead Press",
  targetWeight: 40.0,
  targetReps: 10,
  actualWeight: 40.0,   // ✅ User entered
  actualReps: 10,       // ✅ User entered
  rpe: 8,               // ✅ User entered
  isCompleted: true,    // ✅ Now completed
);
```

### 4️⃣ Round 1 Completion

```dart
// Both exercises complete → create completed SupersetSet
final completedRound1 = SupersetSet(
  id: "superset_round_1234567890_0_1",  // ✅ Same ID as original
  setNumber: 1,                          // ✅ Identifies Round 1
  exerciseData: {
    "1234_bench": updatedPanca,
    "1234_overhead": updatedOverhead,
  },
  isCompleted: true,                     // ✅ Round complete
  completedAt: DateTime.now(),           // ✅ Timestamp
);

// Update provider
ref.read(currentWorkoutProvider.notifier)
  .updateSupersetSet(superset.id, completedRound1);
```

### 5️⃣ Provider Updates ONLY Round 1

```dart
// workout_provider.dart - updateSupersetSet method
void updateSupersetSet(String exerciseId, SupersetSet updatedSupersetSet) {
  final updatedExercises = state!.exercises.map((exercise) {
    if (exercise.id == exerciseId && exercise is SupersetExercise) {
      final updatedSupersetSets = exercise.supersetSets.map((set) {
        // ✅ FIX: Compare by setNumber
        if (set.setNumber == updatedSupersetSet.setNumber) {
          // setNumber = 1 matches ONLY Round 1
          return updatedSupersetSet;  // Replace Round 1
        }
        return set;  // Round 2 and 3 unchanged
      }).toList();
      return exercise.copyWith(supersetSets: updatedSupersetSets);
    }
    return exercise;
  }).toList();

  state = state!.copyWith(exercises: updatedExercises);
}
```

### 6️⃣ State After Round 1

```dart
// ✅ CORRECT: Only Round 1 is completed
superset.supersetSets = [
  SupersetSet(
    setNumber: 1,
    isCompleted: true,     // ✅ COMPLETED
    exerciseData: {
      "1234_bench": { actualWeight: 60.0, actualReps: 8, rpe: 7, isCompleted: true },
      "1234_overhead": { actualWeight: 40.0, actualReps: 10, rpe: 8, isCompleted: true },
    },
  ),
  SupersetSet(
    setNumber: 2,
    isCompleted: false,    // ✅ STILL INCOMPLETE
    exerciseData: { ... }, // Original data unchanged
  ),
  SupersetSet(
    setNumber: 3,
    isCompleted: false,    // ✅ STILL INCOMPLETE
    exerciseData: { ... }, // Original data unchanged
  ),
];
```

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│              SUPERSET: Panca + Overhead             │
│                    3 Rounds, 90s rest               │
└─────────────────────────────────────────────────────┘

ROUND 1 (setNumber: 1) ✅ COMPLETED
├── Panca Piana    → 60kg × 8 reps  RPE:7 ✅
├── Overhead Press → 40kg × 10 reps RPE:8 ✅
└── Rest 90s ⏱️

ROUND 2 (setNumber: 2) ⬜ INCOMPLETE
├── Panca Piana    → 65kg × 6 reps  ⬜
├── Overhead Press → 42.5kg × 8 reps ⬜
└── Rest 90s

ROUND 3 (setNumber: 3) ⬜ INCOMPLETE
├── Panca Piana    → 70kg × 4 reps  ⬜
└── Overhead Press → 45kg × 6 reps  ⬜
```

## Key Points

### ✅ What Works Now (AFTER FIX)

1. **Round Independence**: Each round completes separately
2. **Correct Identification**: `setNumber` uniquely identifies rounds
3. **Data Integrity**: No cross-contamination between rounds
4. **Predictable Behavior**: Round N completion only affects Round N

### ❌ What Was Broken (BEFORE FIX)

1. **All rounds shared same ID**: `DateTime.now().millisecondsSinceEpoch`
2. **ID comparison matched all rounds**: `set.id == updatedSupersetSet.id`
3. **All rounds updated together**: Completing Round 1 marked all as complete
4. **Unpredictable behavior**: Data structure was inconsistent

## Testing Scenarios

### Scenario 1: Complete Rounds in Order

```dart
// Complete Round 1 → ✅ Only Round 1 marked
// Complete Round 2 → ✅ Only Round 2 marked
// Complete Round 3 → ✅ Only Round 3 marked
```

### Scenario 2: Skip and Come Back

```dart
// Complete Round 1 → ✅ Round 1 marked
// Skip to Round 3  → ✅ Round 3 marked, Round 2 still incomplete
// Go back to Round 2 → ✅ Round 2 marked independently
```

### Scenario 3: Undo Completion

```dart
// Complete Round 2 → ✅ Round 2 marked
// Undo Round 2    → ✅ Only Round 2 unmarked, others unchanged
```

## Code Usage in UI

### Display Round Status

```dart
// Show round completion in SupersetCard
Widget _buildRoundIndicator(SupersetSet round) {
  return Container(
    decoration: BoxDecoration(
      color: round.isCompleted
        ? Colors.green.withOpacity(0.2)
        : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(
          round.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: round.isCompleted ? Colors.green : Colors.grey,
        ),
        Text('Round ${round.setNumber}'),
        Text('${round.completedExercisesCount}/${round.exerciseData.length} completed'),
      ],
    ),
  );
}
```

### Execute Round

```dart
// Start execution for specific round
void _startRound(BuildContext context, SupersetExercise superset, int roundIndex) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SupersetSequentialExecutionSheet(
      superset: superset,
      roundIndex: roundIndex,  // 0, 1, or 2
      onRoundCompleted: (completedRound) {
        // Provider uses setNumber to update correct round
        ref.read(currentWorkoutProvider.notifier)
          .updateSupersetSet(superset.id, completedRound);
      },
    ),
  );
}
```

## Summary

The fix ensures **each round is independent** and identified by its `setNumber` (1, 2, 3), making the superset logic predictable, maintainable, and correct.

✅ **Round 1 completion → Only Round 1 marked**
✅ **Round 2 completion → Only Round 2 marked**
✅ **Round 3 completion → Only Round 3 marked**
