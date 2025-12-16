# Core Modules Documentation

> **Location**: `lib/core/` | **Modules**: 15

---

## Overview

Core modules provide app-wide infrastructure including analytics, authentication, caching, configuration, data persistence, error handling, navigation, performance monitoring, security, and utilities.

---

## Analytics

**Location**: `lib/core/analytics/`

### Purpose
Centralized analytics event tracking infrastructure for user behavior and app performance monitoring.

### Key Files

| File | Purpose |
|------|---------|
| `analytics_constants.dart` | Event names, parameters, user properties |
| `trackers/workout_event_tracker.dart` | Workout lifecycle tracking |
| `trackers/preset_selection_tracker.dart` | Preset selection events |
| `trackers/timer_event_tracker.dart` | Timer events |
| `trackers/patch_event_tracker.dart` | Exercise patch events |

### Main Classes

```dart
// Event constants (50+ predefined)
class AnalyticsEvents {
  static const workoutStarted = 'workout_started';
  static const workoutCompleted = 'workout_completed';
  static const exerciseAdded = 'exercise_added';
  static const setCompleted = 'set_completed';
  // ... 50+ more
}

// Parameter keys (70+)
class AnalyticsParameters {
  static const workoutId = 'workout_id';
  static const duration = 'duration';
  static const exerciseCount = 'exercise_count';
  // ... 70+ more
}

// User properties for segmentation
class AnalyticsUserProperties {
  static const userTier = 'user_tier';
  static const experienceLevel = 'experience_level';
  static const unitSystem = 'unit_system';
}

// Workout event tracker
class WorkoutEventTracker {
  Future<void> trackWorkoutStarted({
    required String workoutId,
    String? templateId,
  });

  Future<void> trackWorkoutCompleted({
    required String workoutId,
    required Duration duration,
    required int exerciseCount,
  });
}
```

### Dependencies
- Firebase Analytics
- Riverpod providers

---

## Auth

**Location**: `lib/core/auth/`

### Purpose
Secure authentication and admin role management using Firebase Custom Claims.

### Key Files

| File | Purpose |
|------|---------|
| `admin_status_provider.dart` | Riverpod providers for admin status |
| `admin_role_helper.dart` | Admin role operations |

### Main Classes

```dart
// Providers
final adminStatusProvider = FutureProvider<bool>((ref) async {
  // Checks custom claims from Firebase ID token
});

final isAdminProvider = Provider<bool>((ref) {
  // Synchronous fallback (returns false if loading/error)
});

// Helper class
class AdminRoleHelper {
  static Future<bool> isCurrentUserAdmin();
  static Future<bool> isUserAdmin(String uid);
  static Future<void> grantAdminRole(String email);
  static Future<void> revokeAdminRole(String email);
  static Future<void> forceTokenRefresh();
}
```

### Security Features
- Server-side validation via custom claims (cannot be forged)
- Rate limiting on admin operations
- Security event logging

---

## Cache

**Location**: `lib/core/cache/`

### Purpose
User-scoped cache key management for multi-user data isolation.

### Key Files

| File | Purpose |
|------|---------|
| `user_cache_key_manager.dart` | Cache key generation |

### Main Classes

```dart
class UserCacheKeyManager {
  // Singleton factory
  factory UserCacheKeyManager() => _instance;

  // Template keys
  String get templatesCacheKey => '${_userId}_templates';
  String get templatesLastSyncKey => '${_userId}_templates_last_sync';

  // Analytics keys
  String get analyticsStatsKey => '${_userId}_analytics_stats';
  String workoutHistoryKey() => '${_userId}_workout_history';

  // Generic
  String userScopedKey(String key) => '${_userId}_$key';
}

// Global instance
final userCacheKeys = UserCacheKeyManager();
```

### Benefits
- Per-user cache isolation (preserves cache for returning users)
- Reduces Firebase reads by ~60%
- Supports multi-account scenarios

---

## Config

**Location**: `lib/core/config/`

### Purpose
Environment configuration and service initialization.

### Key Files

| File | Purpose |
|------|---------|
| `environment_config.dart` | Load .env variables |
| `firebase_config.dart` | Platform-specific Firebase options |
| `admob_config.dart` | AdMob configuration |
| `schema_versions.dart` | Hive schema versions |

### Main Classes

```dart
// Environment configuration
class EnvironmentConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // Firebase keys (iOS)
  static String get iosApiKey => dotenv.get('IOS_API_KEY');
  static String get iosAppId => dotenv.get('IOS_APP_ID');

  // Firebase keys (Android)
  static String get androidApiKey => dotenv.get('ANDROID_API_KEY');
  static String get androidAppId => dotenv.get('ANDROID_APP_ID');

  // Environment detection
  static bool get isDevelopment => dotenv.get('ENV') == 'development';
  static bool get isProduction => dotenv.get('ENV') == 'production';
}

// Firebase configuration factory
class FirebaseConfig {
  static FirebaseOptions fromEnvironment() {
    if (Platform.isIOS) {
      return FirebaseOptions(
        apiKey: EnvironmentConfig.iosApiKey,
        appId: EnvironmentConfig.iosAppId,
        // ...
      );
    }
    // Handle other platforms...
  }
}
```

### Security
- Loads from `.env` (not in version control)
- Masks sensitive values in debug output

---

## Data

**Location**: `lib/core/data/`

### Purpose
Local storage management and hybrid repository pattern.

### Key Files

| File | Purpose |
|------|---------|
| `hive_box_manager_enhanced.dart` | Box lifecycle management |
| `hive_box_names.dart` | Centralized box names |
| `repositories/base_hybrid_repository.dart` | **CRITICAL** base repository |
| `repositories/optimized_base_hybrid_repository.dart` | 24-hour caching variant |
| `hive_migration_service.dart` | Schema migrations |

### Main Classes

```dart
// Enhanced box manager with corruption recovery
class HiveBoxManagerEnhanced {
  Future<Box<T>> openBox<T>(String name, {HiveCipher? cipher});
  Future<void> closeBox(String name);
  Future<void> closeAllBoxes();
}

// Box names registry
class HiveBoxNames {
  static const workouts = 'workouts';
  static const templates = 'templates';
  static const exercises = 'exercises';
  static const userProfile = 'user_profile_cache';
  static const privacyConsent = 'privacy_consent';
  // ... 30+ more
}

// CRITICAL: Base repository for all features
abstract class BaseHybridRepository<T> {
  // Abstract methods to implement
  Map<String, dynamic> toJson(T entity);
  T fromJson(Map<String, dynamic> json);
  String getId(T entity);
  ValidationResult validate(T entity);

  // Provided implementations
  Future<Either<Failure, void>> save(T entity);
  Future<Either<Failure, T?>> getById(String id);
  Future<Either<Failure, List<T>>> getAll();
  Future<Either<Failure, void>> delete(String id);
  Stream<SyncEvent> get syncEvents;
}
```

### Sync Events

```dart
enum SyncEventType {
  saved,
  updated,
  deleted,
  synced,
  syncFailed,
  syncRequested,
}

class SyncEvent {
  final SyncEventType type;
  final String entityId;
  final DateTime timestamp;
}
```

### Critical Notes
- **DO NOT** close Hive boxes manually (managed by HiveBoxManagerEnhanced)
- Always extend `BaseHybridRepository` for new repositories
- Memory-safe async disposal pattern included

---

## Domain

**Location**: `lib/core/domain/`

### Purpose
Core domain entities and business logic.

### Key Files

| File | Purpose |
|------|---------|
| `entities/user_tier.dart` | XP/tier system |

### Main Classes

```dart
// Enhanced enum with embedded entitlements
enum UserTier {
  starter(0, 4, true, false, false),
  bronze(500, 5, true, false, false),
  silver(2000, 5, true, false, false),
  gold(5000, 6, true, false, false),
  platinum(15000, 7, false, true, true);

  const UserTier(
    this.xpRequired,
    this.maxTemplates,
    this.showsBannerAds,
    this.hasCloudSync,
    this.hasProAnalytics,
  );

  final int xpRequired;
  final int maxTemplates;
  final bool showsBannerAds;
  final bool hasCloudSync;
  final bool hasProAnalytics;

  // Factory from XP
  static UserTier fromXP(int xp) {
    if (xp >= platinum.xpRequired) return platinum;
    if (xp >= gold.xpRequired) return gold;
    // ...
  }

  // Progression helpers
  UserTier? get next;
  int get xpToNextTier;
  double progressToNext(int currentXP);
}
```

---

## Errors

**Location**: `lib/core/errors/`

### Purpose
Centralized error handling and user feedback.

### Key Files

| File | Purpose |
|------|---------|
| `error_handler.dart` | Main error handler |
| `error_aware_provider.dart` | Enhanced provider wrapper |

### Main Classes

```dart
// Error types
enum ErrorType {
  network,
  authentication,
  firebase,
  validation,
  permission,
  storage,
  unknown,
}

// Severity levels
enum ErrorSeverity {
  low,     // Log only
  medium,  // Toast notification
  high,    // Dialog
  critical, // Full-screen error
}

// Error handler singleton
class ErrorHandler {
  static final instance = ErrorHandler._();

  void handle(Object error, {
    required BuildContext context,
    StackTrace? stackTrace,
    VoidCallback? retry,
  }) {
    final type = _categorize(error);
    final severity = _determineSeverity(type);

    // 1. Log
    AppLogger.error('Error: $error', error, stackTrace);

    // 2. Report to crash analytics (high+ severity)
    if (severity >= ErrorSeverity.high) {
      _reportToCrashlytics(error, stackTrace);
    }

    // 3. Show appropriate UI feedback
    switch (severity) {
      case ErrorSeverity.medium:
        SnackBarService.showError(context, message);
        break;
      case ErrorSeverity.high:
        _showErrorDialog(context, error, retry);
        break;
      case ErrorSeverity.critical:
        Navigator.pushReplacement(context, ErrorScreen(error));
        break;
    }
  }
}

// Full-screen error widget
class ErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
}
```

---

## Extensions

**Location**: `lib/core/extensions/`

### Purpose
Utility extensions on core Flutter types.

### Provides
- Build context extensions (theme, localization)
- List/String/DateTime extensions
- Numeric utilities

---

## Navigation

**Location**: `lib/core/navigation/`

### Purpose
Router configuration and navigation orchestration.

### Key Files

| File | Purpose |
|------|---------|
| `app_router.dart` | GoRouter configuration |
| `app_routes.dart` | Route constants |
| `main_shell.dart` | Bottom navigation shell |
| `analytics_route_observer.dart` | Screen view tracking |

### Main Classes

```dart
// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Auth-aware redirect logic
      final authState = ref.read(authStateProvider);
      if (authState == AuthState.unauthenticated) {
        return '/login';
      }
      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),

      // StatefulShellRoute for persistent navigation
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          // Branch 0: Home
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
          ]),
          // Branch 1: Workout
          StatefulShellBranch(routes: [
            GoRoute(path: '/workout', builder: (_, __) => WorkoutScreen()),
          ]),
          // Branch 2: Profile
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});

// Route constants
class AppRoutes {
  static const home = '/home';
  static const workout = '/workout';
  static const profile = '/profile';
  static const login = '/login';
  // ...
}
```

### Features
- Auth-aware redirect logic
- RBAC permission checking
- Session activity recording
- Deep linking support
- State preservation across tab switches

---

## Performance

**Location**: `lib/core/performance/`

### Purpose
Performance monitoring and optimization tools.

### Key Files

| File | Purpose |
|------|---------|
| `performance_optimizer.dart` | Rebuild tracking |
| `lazy_loading_list.dart` | Virtual scrolling |

### Main Classes

```dart
class PerformanceOptimizer {
  static void trackRebuild(String providerName) {
    // Track provider rebuild counts
    // Warn if >5 rebuilds in 10 seconds
  }
}

// Optimized consumer with tracking
class OptimizedConsumer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      PerformanceOptimizer.trackRebuild(runtimeType.toString());
    }
    return buildOptimized(context, ref);
  }

  Widget buildOptimized(BuildContext context, WidgetRef ref);
}
```

---

## Providers

**Location**: `lib/core/providers/`

### Purpose
Riverpod providers for core services.

### Key Files

| File | Purpose |
|------|---------|
| `analytics_provider.dart` | Analytics service |
| `analytics_initialization_provider.dart` | Startup initialization |
| `firebase_providers.dart` | Firebase instances |
| `tier_entitlements_provider.dart` | User tier checking |

### Main Providers

```dart
final analyticsServiceProvider = Provider<IAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

final workoutTrackerProvider = Provider<WorkoutEventTracker>((ref) {
  return WorkoutEventTracker(ref.watch(analyticsServiceProvider));
});

final analyticsInitializationProvider = FutureProvider<void>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  await analytics.initialize();
  // Set user properties
});
```

---

## Security

**Location**: `lib/core/security/`

### Purpose
Security-critical functionality (encryption, app attestation).

### Key Files

| File | Purpose |
|------|---------|
| `hive_encryption_manager.dart` | AES-256 encryption |
| `app_check_config.dart` | Firebase App Check |

### Main Classes

```dart
class HiveEncryptionManager {
  final FlutterSecureStorage _secureStorage;

  /// Get or create AES-256 cipher for sensitive boxes
  Future<HiveCipher> getEncryptionCipher() async {
    String? keyString = await _secureStorage.read(key: _keyName);

    if (keyString == null) {
      // Generate new 256-bit key
      final key = Hive.generateSecureKey();
      keyString = base64Encode(key);
      await _secureStorage.write(key: _keyName, value: keyString);
    }

    return HiveAesCipher(base64Decode(keyString));
  }

  Future<void> deleteEncryptionKey();
  Future<bool> hasEncryptionKey();
  Future<void> rotateEncryptionKey();
}
```

### Encrypted Boxes
- `privacy_consent`
- `user_settings`
- `user_profile_cache`
- GDPR-sensitive data

---

## Services

**Location**: `lib/core/services/`

### Purpose
Business logic service implementations.

### Key Files

| File | Purpose |
|------|---------|
| `analytics/i_analytics_service.dart` | Analytics interface |
| `analytics/firebase_analytics_service.dart` | Firebase implementation |
| `analytics/mock_analytics_service.dart` | Testing implementation |
| `rate_limiter.dart` | Rate limit handler |

### Main Classes

```dart
// Analytics interface
abstract class IAnalyticsService {
  Future<void> initialize();
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);
  Future<void> logScreenView(String screenName);
  Future<void> setUserProperty(String name, String? value);
  Future<void> setUserId(String? userId);
  Future<void> startTrace(String name);
  Future<void> stopTrace(String name);
}

// Rate limit handler
class RateLimitHandler {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;

  Future<T> execute<T>(Future<T> Function() operation);
}
```

---

## UI

**Location**: `lib/core/ui/`

### Purpose
Core UI utilities and animations.

### Key Files

| File | Purpose |
|------|---------|
| `animations.dart` | Animation definitions |

---

## Utils

**Location**: `lib/core/utils/`

### Purpose
General-purpose utilities and helpers.

### Key Files

| File | Purpose |
|------|---------|
| `app_logger.dart` | Conditional logging |
| `debug_logger.dart` | Debug-only logging |
| `production_logger.dart` | Production-safe logging |
| `memory_leak_detector.dart` | Memory leak detection |
| `disposable_resources_mixin.dart` | Resource cleanup |

### Main Classes

```dart
// Conditional logger (auto-strips in release)
class AppLogger {
  static void debug(String message, [String? tag]) {
    if (kDebugMode) debugPrint('[DEBUG${tag != null ? ':$tag' : ''}] $message');
  }

  static void info(String message, [String? tag]);
  static void warning(String message, [String? tag]);
  static void error(String message, [Object? error, StackTrace? stack]);
  static void security(String message);
  static void performance(String message);
}

// Resource cleanup mixin
mixin DisposableResourcesMixin {
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];

  void addTimer(Timer timer) => _timers.add(timer);
  void addSubscription(StreamSubscription sub) => _subscriptions.add(sub);

  void disposeResources() {
    for (final timer in _timers) timer.cancel();
    for (final sub in _subscriptions) sub.cancel();
    _timers.clear();
    _subscriptions.clear();
  }
}
```

---

## Import Hierarchy

```
analytics
├── services/analytics
└── providers

auth
├── domain (user profile)
└── services (Cloud Functions)

data
├── hive_box_manager_enhanced
├── hive_box_names
├── domain (user tier)
└── security (encryption)

config
└── used in main.dart

navigation
├── all features
└── providers (RBAC, session)

errors
├── all layers
└── localization

performance
├── providers
└── widgets

security
└── data layer

utils
└── everywhere
```

---

## See Also

- [INDEX.md](../INDEX.md) - Codebase navigation
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture patterns
- [shared/README.md](../shared/README.md) - Shared modules
