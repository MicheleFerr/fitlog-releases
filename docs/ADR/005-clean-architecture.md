# ADR-005: Clean Architecture Pattern

## Status
Accepted

## Context

As FitLog Pro grew, we needed a clear structure for:
- Separating business logic from UI
- Testing individual components
- Replacing implementations (e.g., switching databases)
- Onboarding new developers

## Decision

We adopted **Clean Architecture** with three layers per feature:
- **Presentation**: UI, state management, user interaction
- **Domain**: Business logic, entities, use cases
- **Data**: External services, storage, APIs

## Consequences

### Pros

1. **Testability**: Each layer can be tested in isolation
2. **Flexibility**: Easy to swap implementations
3. **Clarity**: Clear boundaries and responsibilities
4. **Scalability**: New features follow the same pattern
5. **Dependency rule**: Inner layers don't know outer layers

### Cons

1. **Boilerplate**: More files and folders
2. **Over-engineering**: Simple features may not need all layers
3. **Learning curve**: Team needs to understand the pattern
4. **Indirection**: More jumps to trace code flow

### Structure

```
lib/
├── core/                 # Shared infrastructure
│   ├── data/            # Base repositories, Hive manager
│   ├── navigation/      # GoRouter setup
│   ├── providers/       # Global providers
│   └── utils/           # Logging, helpers
│
├── features/
│   └── {feature_name}/
│       ├── domain/
│       │   ├── entities/        # Business objects (Freezed)
│       │   ├── repositories/    # Repository interfaces
│       │   ├── services/        # Domain services
│       │   └── usecases/        # Business logic
│       │
│       ├── data/
│       │   ├── datasources/     # Local/Remote data access
│       │   ├── models/          # Data transfer objects
│       │   ├── repositories/    # Repository implementations
│       │   └── services/        # Data services
│       │
│       └── presentation/
│           ├── providers/       # Riverpod providers
│           ├── screens/         # Full-page widgets
│           └── widgets/         # Reusable components
│
└── shared/              # Cross-feature shared code
    ├── domain/          # Shared entities, converters
    ├── presentation/    # Shared widgets, themes
    └── widgets/         # Common UI components
```

### Dependency Rule

```
Presentation → Domain ← Data
     ↓            ↑        ↓
   Widgets    Entities   Hive/Firebase
```

- **Domain** knows nothing about Presentation or Data
- **Presentation** depends on Domain (entities, use cases)
- **Data** implements Domain interfaces

### When to Use Full Pattern

| Feature Complexity | Layers to Use |
|-------------------|---------------|
| Simple (settings toggle) | Just Presentation |
| Medium (preferences) | Presentation + Data |
| Complex (workouts) | All three layers |

### Repository Pattern

```dart
// Domain layer - interface
abstract class WorkoutRepository {
  Future<List<Workout>> getAll();
  Future<void> save(Workout workout);
}

// Data layer - implementation
class HybridWorkoutRepositoryImpl implements WorkoutRepository {
  final HiveBoxManager _hive;
  final FirestoreService _firestore;

  @override
  Future<List<Workout>> getAll() async {
    // Implementation details hidden from domain
  }
}
```

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
