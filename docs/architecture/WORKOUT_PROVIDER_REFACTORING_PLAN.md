# Workout Provider Refactoring Plan

## Current State Analysis

**File**: `lib/features/workout/presentation/providers/workout_provider.dart`
**Lines**: 2,077 LOC
**Imports**: 83 (many direct dependencies)

### Problem

The `WorkoutProvider` contains significant business logic that should be delegated to domain UseCases. Despite having well-structured UseCases in `lib/features/workout/domain/usecases/`, the provider:

1. **Duplicates business logic** - validation, calculations, transformations
2. **Directly accesses infrastructure** - Firestore, Hive, Firebase Auth
3. **Violates Clean Architecture** - presentation layer bypassing domain layer
4. **Has excessive responsibilities** - save, complete, export, APRE, analytics, etc.

### Existing UseCases (Not Used)

```
lib/features/workout/domain/usecases/
├── complete_workout_usecase.dart    (327 LOC - comprehensive)
├── save_workout_usecase.dart        (186 LOC - validation + save)
├── update_exercise_set_usecase.dart
├── get_workouts_usecase.dart
├── get_recent_exercises.dart
└── get_exercise_chart_data.dart
```

## Methods to Refactor

### High Priority (Business Logic Heavy)

| Method | Lines | Suggested UseCase |
|--------|-------|-------------------|
| `_saveCompletedWorkoutToFirestore` | ~350 | `CompleteWorkoutUseCase` (exists) |
| `_autoCompleteRoutineDay` | ~40 | `AutoCompleteRoutineDayUseCase` |
| `_exportWorkoutData` | ~70 | `ExportWorkoutUseCase` |
| `_preCalculateAllAPREWeights` | ~100 | `CalculateAPREWeightsUseCase` |
| `_calculateAndSetBaseWeight` | ~80 | Move to APRE service |

### Medium Priority (State + Logic Mixed)

| Method | Lines | Notes |
|--------|-------|-------|
| `createWorkoutFromRoutine` | 25 | Could use factory |
| `replaceExercisesFromTemplate` | 30 | Template conversion logic |
| `startFromTemplate` | 200+ | Complex, needs breakdown |

## Refactoring Pattern

### Before (Current - Anti-Pattern)

```dart
// workout_provider.dart - 350+ lines of business logic
Future<void> _saveCompletedWorkoutToFirestore([BuildContext? context]) async {
  final workout = state;
  if (workout == null || !workout.isCompleted) return;

  // 83 imports, direct Firestore access, validation,
  // sanitization, transactions, analytics, achievements...
  // All in the provider!
}
```

### After (Recommended - Clean Architecture)

```dart
// workout_provider.dart - thin, delegates to UseCase
final completeWorkoutUseCaseProvider = Provider<CompleteWorkoutUseCase>((ref) {
  return CompleteWorkoutUseCase(ref.read(workoutRepositoryProvider));
});

class WorkoutNotifier extends StateNotifier<Workout?> {
  final CompleteWorkoutUseCase _completeWorkout;

  Future<void> completeWorkout(BuildContext? context) async {
    final workout = state;
    if (workout == null) return;

    final result = await _completeWorkout(CompleteWorkoutParams(
      workout: workout,
      userEmail: _authService.currentUser?.email ?? '',
    ));

    result.fold(
      (failure) => _handleFailure(context, failure),
      (success) => _handleSuccess(context, success),
    );
  }

  void _handleSuccess(BuildContext? context, CompleteWorkoutResult result) {
    state = result.completedWorkout;
    // UI feedback, navigation - presentation concerns only
  }
}
```

## Implementation Steps

### Phase 1: Add UseCase Providers (Low Risk)

```dart
// Add to workout_provider.dart or separate file
final completeWorkoutUseCaseProvider = Provider<CompleteWorkoutUseCase>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return CompleteWorkoutUseCase(repository);
});

final saveWorkoutUseCaseProvider = Provider<SaveWorkoutUseCase>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return SaveWorkoutUseCase(repository);
});
```

### Phase 2: Refactor Methods One-by-One (Medium Risk)

1. Start with `_saveCompletedWorkoutToFirestore` -> `CompleteWorkoutUseCase`
2. Extract analytics tracking to separate service
3. Extract achievement checking (already in UseCase)
4. Remove duplicated validation

### Phase 3: Clean Up (Low Risk)

1. Remove unused code paths
2. Reduce imports (from 83 to ~30)
3. Add proper error handling with Either

## Benefits

1. **Testability** - UseCases can be unit tested in isolation
2. **Maintainability** - Business logic in one place
3. **Reusability** - UseCases can be used from other providers
4. **Type Safety** - Either pattern for error handling
5. **Reduced Coupling** - Provider doesn't know about Firestore

## Risks

1. **Breaking Changes** - Existing behavior might change
2. **Testing Required** - Full regression testing needed
3. **Time Investment** - Significant refactoring effort

## Recommendation

**Start with Phase 1** - Add UseCase providers without changing existing code.
Then gradually migrate methods in **Phase 2** with proper testing.

---

*Generated: 2025-11-25*
*Status: Analysis Complete - Implementation Pending*
