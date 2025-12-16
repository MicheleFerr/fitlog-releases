# FitLog Pro - Architecture Deep Dive

> **Last Updated**: 2024-12-16

---

## Table of Contents

1. [Clean Architecture](#clean-architecture)
2. [Data Flow](#data-flow)
3. [State Management (Riverpod)](#state-management-riverpod)
4. [Storage Architecture](#storage-architecture)
5. [Error Handling](#error-handling)
6. [Security & Compliance](#security--compliance)
7. [Performance Patterns](#performance-patterns)
8. [iOS Integration](#ios-integration)

---

## Clean Architecture

### Layer Separation

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Screens, Widgets, Providers (Riverpod)                     │
│  Depends on: Domain                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  Entities (Freezed), Repository Interfaces, Services        │
│  Depends on: Nothing (pure Dart)                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  Repository Implementations, DataSources, Models            │
│  Depends on: Domain (implements interfaces)                 │
└─────────────────────────────────────────────────────────────┘
```

### Per-Feature Structure

```
lib/features/{feature_name}/
├── domain/               # Business Logic Layer
│   ├── entities/         # Business objects (Freezed)
│   ├── repositories/     # Repository interfaces
│   └── services/         # Domain services
│
├── data/                 # Data Layer
│   ├── models/           # Data transfer objects
│   ├── repositories/     # Repository implementations
│   ├── datasources/      # Remote/Local data sources
│   └── services/         # Data services
│
└── presentation/         # UI Layer
    ├── providers/        # Riverpod providers
    ├── screens/          # Full screens
    └── widgets/          # Reusable widgets
```

### Dependency Rules

```dart
// ✅ CORRECT: Presentation depends on Domain
class WorkoutScreen extends ConsumerWidget {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  // Uses domain interface, not data implementation
}

// ✅ CORRECT: Data implements Domain
class HybridWorkoutRepository implements WorkoutRepository {
  // Domain interface implemented by data layer
}

// ❌ WRONG: Domain depends on Data
class Workout {
  // Never import Hive, Firestore, etc. in domain
}
```

---

## Data Flow

### Request Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Screen    │────▶│  Provider   │────▶│ Repository  │
│   (Widget)  │◀────│  (Riverpod) │◀────│ (Interface) │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                    ┌──────────────────────────┤
                    ▼                          ▼
             ┌─────────────┐           ┌─────────────┐
             │    Hive     │           │  Firestore  │
             │   (Local)   │           │   (Cloud)   │
             └─────────────┘           └─────────────┘
```

### Hybrid Storage Strategy

```dart
// BaseHybridRepository pattern
abstract class BaseHybridRepository<T> {
  // 1. Always save locally first (instant)
  Future<void> saveLocally(T item);

  // 2. Queue for cloud sync if premium
  Future<void> queueForSync(T item);

  // 3. Process sync queue in background
  Future<void> processSyncQueue();
}

// Implementation
class HybridWorkoutRepository extends BaseHybridRepository<Workout> {
  @override
  Future<Either<Failure, void>> save(Workout workout) async {
    // 1. Save to Hive (always)
    await hiveBox.put(workout.id, workout.toModel());

    // 2. If premium, queue for Firestore sync
    if (userTier.hasCloudSync) {
      await syncQueue.add(SyncOperation.save(workout));
    }

    return Right(null);
  }
}
```

### Cache-First Pattern

```dart
// FirestoreCacheFirstMixin
mixin FirestoreCacheFirstMixin {
  Future<T?> getCacheFirst<T>(
    DocumentReference ref,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // 1. Try cache first (instant, works offline)
    try {
      final cached = await ref.get(GetOptions(source: Source.cache));
      if (cached.exists) return fromJson(cached.data()!);
    } catch (_) {}

    // 2. Fallback to server
    final server = await ref.get(GetOptions(source: Source.server));
    return server.exists ? fromJson(server.data()!) : null;
  }
}
```

---

## State Management (Riverpod)

### Provider Types

```dart
// 1. Provider - Static service/repository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return HybridExerciseRepository(ref);
});

// 2. StateProvider - Simple UI state
final selectedExerciseProvider = StateProvider<Exercise?>((ref) => null);

// 3. FutureProvider - Async data fetching
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getAll();
});

// 4. StreamProvider - Real-time updates
final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchAll();
});

// 5. NotifierProvider - Complex state + logic
final workoutNotifierProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(() {
  return WorkoutNotifier();
});
```

### Provider Organization

```dart
// Feature-specific providers in presentation/providers/
// lib/features/workout/presentation/providers/workout_providers.dart

// Repository provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return HybridWorkoutRepository(
    hiveBox: ref.watch(hiveBoxProvider('workouts')),
    firestore: ref.watch(firestoreProvider),
    userTier: ref.watch(userTierProvider),
  );
});

// State provider (auto-dispose for memory efficiency)
final activeWorkoutProvider = StateProvider.autoDispose<Workout?>((ref) => null);

// Derived provider (combines multiple sources)
final workoutSummaryProvider = Provider<WorkoutSummary>((ref) {
  final workout = ref.watch(activeWorkoutProvider);
  final exercises = ref.watch(exercisesProvider);
  return WorkoutSummary.calculate(workout, exercises);
});
```

### Provider Best Practices

```dart
// ✅ Auto-dispose for screen-specific state
final screenStateProvider = StateProvider.autoDispose<ScreenState>((ref) => ScreenState.initial);

// ✅ Family for parameterized providers
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((ref, id) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getById(id);
});

// ✅ Select for granular rebuilds
Widget build(BuildContext context, WidgetRef ref) {
  // Only rebuilds when name changes, not entire workout
  final name = ref.watch(workoutProvider.select((w) => w?.name));
  return Text(name ?? 'No workout');
}

// ❌ WRONG: Watching entire object when only needing one field
final workout = ref.watch(workoutProvider); // Rebuilds on ANY change
```

---

## Storage Architecture

### Hive Box Organization

```dart
// lib/core/data/hive_box_names.dart

class HiveBoxNames {
  // Workout data
  static const workouts = 'workouts';
  static const workoutDrafts = 'workout_drafts';
  static const workoutSummaries = 'workout_summaries';

  // Templates
  static const templates = 'templates';
  static const templatesSyncQueue = 'templates_sync_queue';

  // Exercise database
  static const exercises = 'exercises';
  static const exerciseUsage = 'exercise_usage';
  static const customExercises = 'custom_exercises';

  // User data
  static const userProfile = 'user_profile_cache';
  static const userSettings = 'user_settings';
  static const privacyConsent = 'privacy_consent';

  // Analytics
  static const analyticsCache = 'analytics_cache';
  static const streakData = 'streak_data';
}
```

### Hive Encryption

```dart
// lib/core/security/hive_encryption_manager.dart

class HiveEncryptionManager {
  static const _encryptionKeyName = 'hive_encryption_key';
  final FlutterSecureStorage _secureStorage;

  /// Get or create encryption cipher for sensitive boxes
  Future<HiveCipher> getEncryptionCipher() async {
    // Try to get existing key
    String? keyString = await _secureStorage.read(key: _encryptionKeyName);

    if (keyString == null) {
      // Generate new 256-bit AES key
      final key = Hive.generateSecureKey();
      keyString = base64Encode(key);
      await _secureStorage.write(key: _encryptionKeyName, value: keyString);
    }

    return HiveAesCipher(base64Decode(keyString));
  }
}

// Usage: Encrypted boxes for sensitive data
final encryptedBox = await Hive.openBox(
  'privacy_consent',
  encryptionCipher: await encryptionManager.getEncryptionCipher(),
);
```

### Sync Queue Pattern

```dart
// Sync queue for offline-first with eventual consistency
class SyncQueue {
  final Box<SyncOperation> _queue;

  Future<void> add(SyncOperation op) async {
    await _queue.put(op.id, op);
  }

  Future<void> processQueue() async {
    final operations = _queue.values.toList();
    for (final op in operations) {
      try {
        await _executeOperation(op);
        await _queue.delete(op.id);
      } catch (e) {
        // Increment retry count, skip if max retries exceeded
        if (op.retryCount < 3) {
          await _queue.put(op.id, op.copyWith(retryCount: op.retryCount + 1));
        } else {
          await _queue.delete(op.id);
          // Log failure for manual review
        }
      }
    }
  }
}
```

---

## Error Handling

### Either Pattern

```dart
// lib/shared/domain/either/either.dart

abstract class Either<L, R> {
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  Either<L, T> map<T>(T Function(R) mapper);
  Either<L, T> flatMap<T>(Either<L, T> Function(R) mapper);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
}

// Usage in repositories
Future<Either<Failure, Workout>> getWorkout(String id) async {
  try {
    final workout = await _datasource.get(id);
    if (workout == null) {
      return Left(NotFoundFailure('Workout not found'));
    }
    return Right(workout);
  } on FirebaseException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

// Usage in presentation
ref.watch(workoutProvider).when(
  data: (either) => either.fold(
    (failure) => ErrorWidget(failure.message),
    (workout) => WorkoutCard(workout),
  ),
  loading: () => LoadingIndicator(),
  error: (e, _) => ErrorWidget(e.toString()),
);
```

### Failure Hierarchy

```dart
// lib/shared/domain/failures/failure.dart

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure(this.message, [this.code]);
}

// Specific failure types
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error']) : super(message, 'NETWORK');
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentication failed']) : super(message, 'AUTH');
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(String message, {this.fieldErrors}) : super(message, 'VALIDATION');
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error']) : super(message, 'CACHE');
}

class QuotaExceededFailure extends Failure {
  final int current;
  final int limit;
  const QuotaExceededFailure(this.current, this.limit)
      : super('Quota exceeded ($current/$limit)', 'QUOTA');
}
```

### Error Handler

```dart
// lib/core/errors/error_handler.dart

class ErrorHandler {
  static final instance = ErrorHandler._();
  ErrorHandler._();

  void handle(Object error, {
    required BuildContext context,
    StackTrace? stackTrace,
    VoidCallback? retry,
  }) {
    final errorType = _categorize(error);
    final severity = _determineSeverity(errorType);

    // Log
    AppLogger.error('Error: $error', error, stackTrace);

    // Report to crash analytics
    if (severity >= ErrorSeverity.high) {
      _reportToCrashlytics(error, stackTrace);
    }

    // Show UI feedback
    switch (severity) {
      case ErrorSeverity.low:
        // Just log, no UI
        break;
      case ErrorSeverity.medium:
        SnackBarService.showError(context, _getLocalizedMessage(error));
        break;
      case ErrorSeverity.high:
        _showErrorDialog(context, error, retry);
        break;
      case ErrorSeverity.critical:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ErrorScreen(error: error)),
        );
        break;
    }
  }
}
```

---

## Security & Compliance

### GDPR Compliance

```dart
// lib/shared/domain/privacy/privacy_manager.dart

class PrivacyManager {
  // Consent types (GDPR Article 7)
  static const consentTypes = [
    ConsentType.essential,      // Always required
    ConsentType.analytics,      // Optional
    ConsentType.marketing,      // Optional
    ConsentType.personalization // Optional
  ];

  Future<bool> hasConsent(ConsentType type) async {
    if (type == ConsentType.essential) return true;
    return _consentBox.get(type.name) ?? false;
  }

  Future<void> setConsent(ConsentType type, bool granted) async {
    await _consentBox.put(type.name, granted);
    await _auditLog.record(
      action: granted ? 'consent_granted' : 'consent_withdrawn',
      consentType: type.name,
      timestamp: DateTime.now(),
    );
  }
}
```

### Rate Limiting

```dart
// lib/shared/domain/security/rate_limiter.dart

class RateLimiter {
  final int maxRequests;
  final Duration window;
  final List<DateTime> _requests = [];

  // Presets
  static final strict = RateLimiter(maxRequests: 5, window: Duration(seconds: 10));
  static final moderate = RateLimiter(maxRequests: 10, window: Duration(seconds: 1));
  static final lenient = RateLimiter(maxRequests: 30, window: Duration(milliseconds: 500));

  bool canMakeRequest() {
    _cleanOldRequests();
    return _requests.length < maxRequests;
  }

  void recordRequest() {
    _requests.add(DateTime.now());
  }

  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(window);
    _requests.removeWhere((r) => r.isBefore(cutoff));
  }
}
```

### Session Timeout

```dart
// lib/shared/domain/auth/session_timeout_service.dart

class SessionTimeoutService {
  static const timeout = Duration(minutes: 30);
  static const warningBefore = Duration(minutes: 1);

  Timer? _timeoutTimer;
  Timer? _warningTimer;

  void recordActivity() {
    _resetTimers();
  }

  void _resetTimers() {
    _timeoutTimer?.cancel();
    _warningTimer?.cancel();

    _warningTimer = Timer(timeout - warningBefore, () {
      _emitWarning(remainingSeconds: warningBefore.inSeconds);
    });

    _timeoutTimer = Timer(timeout, () {
      _emitExpired();
      _logout();
    });
  }
}
```

---

## Performance Patterns

### Provider Optimization

```dart
// lib/core/performance/performance_optimizer.dart

class PerformanceOptimizer {
  static final _rebuildCounts = <String, int>{};
  static const _excessiveRebuildThreshold = 5;
  static const _trackingWindow = Duration(seconds: 10);

  static void trackRebuild(String providerName) {
    _rebuildCounts[providerName] = (_rebuildCounts[providerName] ?? 0) + 1;

    if (_rebuildCounts[providerName]! > _excessiveRebuildThreshold) {
      AppLogger.warning('Excessive rebuilds detected: $providerName');
    }

    // Reset after tracking window
    Future.delayed(_trackingWindow, () {
      _rebuildCounts[providerName] = 0;
    });
  }
}

// Usage: Track rebuilds in development
Widget build(BuildContext context, WidgetRef ref) {
  if (kDebugMode) {
    PerformanceOptimizer.trackRebuild('WorkoutScreen');
  }
  // ...
}
```

### Lazy Loading

```dart
// Lazy provider initialization
final heavyServiceProvider = Provider<HeavyService>((ref) {
  // Only created when first accessed
  return HeavyService();
});

// Family for parameterized lazy loading
final exerciseDetailsProvider = FutureProvider.family.autoDispose<ExerciseDetails, String>(
  (ref, exerciseId) async {
    // Only fetches when this specific exercise is needed
    final repo = ref.watch(exerciseRepositoryProvider);
    return repo.getDetails(exerciseId);
  },
);
```

### Debouncing

```dart
// Search debouncing
class ExerciseSearchNotifier extends StateNotifier<List<Exercise>> {
  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }
}
```

---

## iOS Integration

### Live Activity Architecture

```
Flutter App
    │
    │ MethodChannel('com.gymbro/live_activity')
    ▼
┌─────────────────────────────────────────┐
│         iOS Native (Swift)              │
│  LiveActivityTimerLiveActivity.swift    │
│         ActivityKit Framework           │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│         Lock Screen / Dynamic Island    │
│         Timer Widget Display            │
└─────────────────────────────────────────┘
```

### Platform Channel

```dart
// lib/features/timer/data/services/live_activity_service.dart

class LiveActivityService {
  static const _channel = MethodChannel('com.gymbro/live_activity');

  Future<bool> startActivity({
    required int seconds,
    required String exerciseName,
    required int setNumber,
  }) async {
    try {
      final result = await _channel.invokeMethod('startActivity', {
        'seconds': seconds,
        'exerciseName': exerciseName,
        'setNumber': setNumber,
      });
      return result == true;
    } catch (e) {
      AppLogger.error('Failed to start Live Activity', e);
      return false;
    }
  }

  Future<void> updateActivity({required int remainingSeconds}) async {
    await _channel.invokeMethod('updateActivity', {
      'remainingSeconds': remainingSeconds,
    });
  }

  Future<void> endActivity() async {
    await _channel.invokeMethod('endActivity');
  }
}
```

### Swift Implementation

```swift
// ios/Runner/LiveActivityTimer/LiveActivityTimerLiveActivity.swift

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var exerciseName: String
        var setNumber: Int
    }
}

@available(iOS 16.1, *)
struct LiveActivityTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Lock screen / banner UI
            VStack {
                Text(context.state.exerciseName)
                Text("\(context.state.remainingSeconds)s")
                    .font(.largeTitle)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
            } compactLeading: {
                // Compact leading
            } compactTrailing: {
                // Compact trailing
            } minimal: {
                // Minimal view
            }
        }
    }
}
```

---

## See Also

- [INDEX.md](INDEX.md) - Codebase navigation
- [core/README.md](core/README.md) - Core modules documentation
- [shared/README.md](shared/README.md) - Shared modules documentation
- [../DEVELOPMENT_RULES.md](../DEVELOPMENT_RULES.md) - Development rules
- [../CODE_PATTERNS.md](../CODE_PATTERNS.md) - Code patterns
