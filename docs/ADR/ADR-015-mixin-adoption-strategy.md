# ADR-015: Firebase/Hive Mixin Adoption Strategy

## Status
**Proposed** | 2026-01-01

## Context

We created three reusable abstractions to reduce code duplication:

| Abstraction | Purpose | Potential Adopters |
|-------------|---------|-------------------|
| `FirebaseErrorMapperMixin` | Standardized Firebase error → Failure mapping | 16+ repositories |
| `FirestoreTimeoutMixin` | Configurable timeout handling | 181+ timeout patterns |
| `BaseHiveLocalDatasource<T>` | Generic Hive CRUD operations | 3 datasources |

**Problem**: Current repositories return direct values, not `Either<Failure, T>`.
The mixins expect functional error handling patterns.

## Decision

### Option A: Full Migration (Recommended for new code)

Convert repositories to return `Either<Failure, T>`:

```dart
// BEFORE
class StressIndexRepository {
  Future<StressIndexResult?> getForWorkout(String workoutId) async {
    try {
      final json = _localBox?.get(workoutId);
      if (json == null) return null;
      return StressIndexResult.fromJson(json);
    } catch (e) {
      debugPrint('Failed: $e');
      return null;  // Error swallowed!
    }
  }
}

// AFTER
class StressIndexRepository with FirebaseErrorMapperMixin {
  Future<Either<Failure, StressIndexResult?>> getForWorkout(String workoutId) async {
    return handleFirebaseOperation(() async {
      final json = _localBox?.get(workoutId);
      if (json == null) return null;
      return StressIndexResult.fromJson(json);
    }, operationName: 'getForWorkout');
  }
}
```

**Benefits**:
- Proper error propagation
- Consistent failure types
- Caller can handle errors explicitly
- Matches modern Dart patterns

### Option B: Gradual Adoption (For existing code)

Keep current signatures, use mixins internally:

```dart
class StressIndexRepository with FirebaseErrorMapperMixin {
  // Keep existing signature for backward compatibility
  Future<StressIndexResult?> getForWorkout(String workoutId) async {
    final result = await handleFirebaseOperation(() async {
      final json = _localBox?.get(workoutId);
      if (json == null) return null;
      return StressIndexResult.fromJson(json);
    }, operationName: 'getForWorkout');

    return result.fold(
      (failure) {
        // Log and return null for backward compatibility
        debugPrint('Error: ${failure.message}');
        return null;
      },
      (value) => value,
    );
  }
}
```

**Benefits**:
- No breaking changes
- Immediate logging/monitoring benefits
- Gradual migration path

## Adoption Priority

### Phase 1: High-Value Migrations (This Week)
1. `stress_index_repository.dart` - Small, focused, good reference
2. `streak_repository.dart` - Similar pattern
3. `insight_feedback_repository.dart` - Simple CRUD

### Phase 2: Hive Datasources (Next)
1. `exercise_cache_manager.dart` → extend `BaseHiveLocalDatasource<CachedExercise>`
2. Measurement datasources → extend base class

### Phase 3: Complex Repositories (Gradual)
1. `firebase_workout_template_repository.dart` - 1,033 lines, complex
2. `exercise_activity_repository.dart` - Heavy usage

## Implementation Checklist

For each repository migration:
- [ ] Add `with FirebaseErrorMapperMixin` to class declaration
- [ ] Import `package:fpdart/fpdart.dart` and `failures/failure.dart`
- [ ] Replace try-catch blocks with `handleFirebaseOperation()`
- [ ] Update interface if changing return types
- [ ] Add tests for error scenarios
- [ ] Update all callers if return type changed

## Consequences

### Positive
- 50%+ reduction in try-catch boilerplate
- Consistent error logging format
- Proper failure type propagation
- Testable error handling

### Negative
- Breaking changes if changing return types (Option A)
- Learning curve for Either pattern
- Need to update all callers

## References
- `lib/core/data/mixins/firebase_error_mapper_mixin.dart`
- `lib/core/data/mixins/firestore_timeout_mixin.dart`
- `lib/core/data/datasources/base_hive_local_datasource.dart`
