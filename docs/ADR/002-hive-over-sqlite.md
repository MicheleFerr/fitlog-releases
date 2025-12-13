# ADR-002: Hive over SQLite

## Status
Accepted

## Context

FitLog Pro needs local storage for:
- Workouts, templates, exercises
- User preferences and settings
- Offline-first functionality
- Cached data from cloud

Options considered:
- **SQLite** (sqflite) - Relational, mature, SQL queries
- **Hive** - NoSQL, pure Dart, fast
- **Isar** - NoSQL, native, powerful queries
- **ObjectBox** - NoSQL, native, reactive

## Decision

We chose **Hive CE** (`hive_ce_flutter: ^2.1.0`) as our local storage solution.

Note: We migrated from the abandoned `hive_flutter` to `hive_ce_flutter` (Community Edition) in November 2025.

## Consequences

### Pros

1. **Pure Dart**: No native dependencies, works everywhere Flutter runs
2. **Fast**: 10x faster than SQLite for simple read/write operations
3. **Simple API**: No SQL, just key-value with boxes
4. **Type-safe**: TypeAdapters for custom objects
5. **Encryption**: Built-in AES-256 encryption
6. **Lazy loading**: Load only what's needed

### Cons

1. **No complex queries**: Must load all and filter in memory
2. **Schema migrations**: Manual, no built-in migration system
3. **No relations**: Must manage foreign keys manually
4. **Memory**: Large datasets need careful management

### Implementation Patterns

```dart
// Centralized box management
class HiveBoxManager {
  static Future<Box<Workout>> get workoutBox =>
    Hive.openBox<Workout>('workouts');
}

// TypeAdapter for custom objects
@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  final String id;
  // ...
}

// Repository usage
class WorkoutRepository {
  Future<void> save(Workout workout) async {
    final box = await HiveBoxManager.workoutBox;
    await box.put(workout.id, workout);
  }
}
```

### Migration from hive_flutter

In November 2025, we migrated from the abandoned `hive_flutter` to `hive_ce_flutter`:
- Drop-in replacement, same API
- Active community maintenance
- Better Flutter 3.x support

## References

- [Hive CE documentation](https://pub.dev/packages/hive_ce_flutter)
- [HIVE_BOX_MANAGER_MIGRATION_REPORT.md](../TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_MIGRATION_REPORT.md)
