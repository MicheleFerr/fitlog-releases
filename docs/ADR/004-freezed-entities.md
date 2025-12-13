# ADR-004: Freezed for Domain Entities

## Status
Accepted

## Context

Domain entities need to be:
- **Immutable**: Prevent accidental mutations
- **Equatable**: Value-based equality for state comparison
- **Serializable**: JSON conversion for storage/API
- **Copyable**: Easy to create modified copies

Options:
- **Manual implementation**: Full control, lots of boilerplate
- **Equatable package**: Only equality, no serialization
- **Freezed**: Code generation for all features
- **Built Value**: Similar to Freezed, more verbose

## Decision

We use **Freezed** with **json_serializable** for all domain entities.

## Consequences

### Pros

1. **Zero boilerplate**: Generates ==, hashCode, toString, copyWith
2. **Immutability**: Compile-time enforced
3. **JSON serialization**: With json_serializable integration
4. **Union types**: For sealed class patterns
5. **Null safety**: Proper nullable field handling
6. **IDE support**: Great autocomplete

### Cons

1. **Build time**: Code generation adds build time
2. **Generated files**: `.freezed.dart` and `.g.dart` files in git
3. **Learning curve**: Annotation syntax to learn
4. **Debugging**: Generated code can be hard to debug

### Implementation Pattern

```dart
// Entity definition
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default([]) List<ExerciseActivity> exercises,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
    _$WorkoutFromJson(json);
}

// Usage
final workout = Workout(id: '1', name: 'Push Day', createdAt: DateTime.now());
final updated = workout.copyWith(name: 'Pull Day');
final json = workout.toJson();
```

### Where Used

| Layer | Uses Freezed? | Why |
|-------|--------------|-----|
| Domain entities | Yes | Core data structures |
| Data models | Sometimes | When different from domain |
| State classes | Yes | For state management |
| API responses | Yes | For JSON parsing |

### Build Commands

```bash
# Generate once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

## References

- [Freezed documentation](https://pub.dev/packages/freezed)
- [json_serializable](https://pub.dev/packages/json_serializable)
