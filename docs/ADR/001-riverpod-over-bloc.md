# ADR-001: Riverpod over BLoC

## Status
Accepted

## Context

When starting FitLog Pro, we needed to choose a state management solution for Flutter. The main candidates were:
- **BLoC** (Business Logic Component) - Flutter's most popular pattern
- **Riverpod** - Evolution of Provider with compile-time safety
- **GetX** - All-in-one solution with navigation/DI
- **Redux** - Predictable state container

## Decision

We chose **Riverpod 2.x** (`flutter_riverpod: ^2.6.1`) as our state management solution.

## Consequences

### Pros

1. **Compile-time safety**: Providers are type-safe, errors caught at compile time
2. **No BuildContext required**: Can access providers from anywhere (services, tests)
3. **Less boilerplate**: No need for Events/States classes like BLoC
4. **Auto-dispose**: Providers clean up automatically when not watched
5. **Testing**: Easy to override providers in tests
6. **Caching**: Built-in caching with `ref.keepAlive()`
7. **Code generation**: Optional `@riverpod` annotation for less boilerplate

### Cons

1. **Learning curve**: Different mental model from Provider/BLoC
2. **Ecosystem**: Fewer tutorials/packages compared to BLoC
3. **Migration**: Provider users need to learn new patterns
4. **Debugging**: Less tooling than BLoC (DevTools)

### Implementation Patterns

```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Async data
final workoutsProvider = FutureProvider<List<Workout>>((ref) async {
  return ref.read(workoutRepository).getAll();
});

// Complex state with StateNotifier
final workoutStateProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>(
  (ref) => WorkoutNotifier(ref.read(workoutRepository)),
);
```

## References

- [Riverpod documentation](https://riverpod.dev/)
- [Flutter state management comparison](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
