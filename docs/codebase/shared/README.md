# Shared Modules Documentation

> **Location**: `lib/shared/` | **Components**: 125+

---

## Overview

The shared layer contains cross-cutting concerns and reusable components used across the entire FitLog Pro application. Follows Clean Architecture with separated domain, data, and presentation layers.

---

## Config

**Location**: `lib/shared/config/`

### Purpose
Feature flags and environment configuration.

### Key Files

| File | Purpose |
|------|---------|
| `feature_flags.dart` | Global toggleable features |

### Main Classes

```dart
class FeatureFlags {
  /// Velocity tracking via sensors (~40% battery drain)
  static const enableVelocityTracking = false;

  /// Debug visualization for RepaintBoundary
  static const enableRepaintRainbow = false;
}
```

---

## Constants

**Location**: `lib/shared/constants/`

### Purpose
Centralized Firestore schema definitions.

### Key Files

| File | Purpose |
|------|---------|
| `firestore_constants.dart` | Complete Firestore schema mapping |

### Main Classes

```dart
// Collections
class FirestoreCollections {
  static const String users = 'users';
  static const String workouts = 'workouts';
  static const String exercises = 'exercises';
  static const String analytics = 'analytics';
  static const String workoutMetrics = 'workoutMetrics';
  static const String templates = 'templates';
  static const String community = 'community';
  static const String feedback = 'feedback';
  // ... 20+ more
}

// Field names
class FirestoreFields {
  static const String userId = 'userId';
  static const String workoutName = 'workoutName';
  static const String sets = 'sets';
  static const String completedAt = 'completedAt';
  // ... 50+ more
}

// User subcollections
class FirestoreUserSubcollections {
  static const String workouts = 'workouts';
  static const String templates = 'templates';
  static const String customExercises = 'customExercises';
}

// Helper function
String userSubcollectionPath(String userId, String subcollection) {
  return '${FirestoreCollections.users}/$userId/$subcollection';
}
```

### Benefits
- Type-safe field references (prevents typos)
- Single source of truth for schema
- Easy refactoring

---

## Data Layer

**Location**: `lib/shared/data/`

### Purpose
External data sources, repositories, local storage, and network configuration.

### Subdirectories

| Directory | Purpose |
|-----------|---------|
| `datasources/` | Local/remote data access |
| `models/` | JSON serializable DTOs |
| `repositories/` | Hybrid repository implementations |
| `mixins/` | Reusable data behaviors |
| `services/` | Data operation services |
| `network/` | HTTP/network configuration |

### Key Datasources

```dart
// Weight settings
class WeightSettingsDatasource {
  Future<WeightSettings> get();
  Future<void> save(WeightSettings settings);
}

// Feedback settings
class FeedbackSettingsDatasource {
  Future<FeedbackSettings> get();
  Future<void> save(FeedbackSettings settings);
}
```

### Key Models

```dart
@JsonSerializable()
class WeightSettingsModel {
  final String userId;
  final String weightUnit; // 'kg' | 'lbs'
  final int decimals;
}

@JsonSerializable()
class FeedbackSettingsModel {
  final bool hapticEnabled;
  final String hapticIntensity; // 'light' | 'medium' | 'heavy'
}
```

### Key Repositories

```dart
// Hybrid app configuration repository
class HybridAppConfigRepository extends BaseHybridRepository<UserAppConfig> {
  // FREE users: local only
  // PREMIUM users: local + cloud sync
}
```

### Key Mixins

```dart
/// Cache-first query strategy
mixin FirestoreCacheFirstMixin {
  Future<T?> getCacheFirst<T>(
    DocumentReference ref,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // 1. Try cache (instant, offline)
    try {
      final cached = await ref.get(GetOptions(source: Source.cache));
      if (cached.exists) return fromJson(cached.data()!);
    } catch (_) {}

    // 2. Fallback to server
    final server = await ref.get(GetOptions(source: Source.server));
    return server.exists ? fromJson(server.data()!) : null;
  }
}

/// Safe scroll controller cleanup
mixin SafeScrollControllerMixin {
  final List<ScrollController> _controllers = [];

  ScrollController createScrollController() {
    final controller = ScrollController();
    _controllers.add(controller);
    return controller;
  }

  void disposeScrollControllers() {
    for (final c in _controllers) c.dispose();
  }
}

/// Rate-limited Firestore operations
mixin RateLimitedFirestoreMixin {
  final RateLimiter _rateLimiter = RateLimiter.moderate;

  Future<T> rateLimitedOperation<T>(Future<T> Function() operation) async {
    if (!_rateLimiter.canMakeRequest()) {
      throw RateLimitExceededException();
    }
    _rateLimiter.recordRequest();
    return operation();
  }
}
```

### Key Services

| Service | Purpose |
|---------|---------|
| `HttpClientWithLogging` | HTTP requests with logging |
| `SecureHttpClient` | SSL pinning, cert validation |
| `RetryQueueService` | Exponential backoff retry |
| `FirestoreBatchWriter` | Batch operations with chunking |
| `ConsentService` | GDPR consent (Hive storage) |
| `InterstitialAdService` | Google Mobile Ads |
| `RewardedAdService` | Rewarded ad callbacks |
| `GifCacheManager` | Image caching |

---

## Domain Layer

**Location**: `lib/shared/domain/`

### Purpose
Business logic, entities, failure handling, and security.

### Subdirectories

| Directory | Purpose |
|-----------|---------|
| `entities/` | Domain models |
| `failures/` | Error hierarchy |
| `either/` | Functional error handling |
| `security/` | Rate limiting, validation |
| `auth/` | Session management |
| `privacy/` | GDPR compliance |
| `services/` | Business logic services |

### Failure Hierarchy

```dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure(this.message, [this.code]);
}

// Specific failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error'])
      : super(message, 'NETWORK');
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Auth failed'])
      : super(message, 'AUTH');
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(String message, {this.fieldErrors})
      : super(message, 'VALIDATION');
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error'])
      : super(message, 'CACHE');
}

class QuotaExceededFailure extends Failure {
  final int current;
  final int limit;
  const QuotaExceededFailure(this.current, this.limit)
      : super('Quota exceeded ($current/$limit)', 'QUOTA');
}
```

### Either Pattern

```dart
abstract class Either<L, R> {
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  Either<L, T> map<T>(T Function(R) mapper);
  Either<L, T> flatMap<T>(Either<L, T> Function(R) mapper);
  bool get isRight;
  bool get isLeft;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

// Usage
Future<Either<Failure, Workout>> getWorkout(String id) async {
  try {
    final workout = await _datasource.get(id);
    return Right(workout);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// Consuming
result.fold(
  (failure) => showError(failure.message),
  (workout) => displayWorkout(workout),
);
```

### Security

```dart
/// Token bucket rate limiter (OWASP M1 compliance)
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
}

/// Input validation (OWASP injection prevention)
class InputValidator {
  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Strip HTML
        .replaceAll(RegExp(r'[<>"\']'), '') // Remove dangerous chars
        .trim();
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }
}
```

### Auth & Privacy

```dart
/// Session timeout (GDPR/HIPAA compliance)
class SessionTimeoutService {
  static const timeout = Duration(minutes: 30);
  static const warningBefore = Duration(minutes: 1);

  Timer? _timeoutTimer;
  Timer? _warningTimer;

  void recordActivity() => _resetTimers();

  void _resetTimers() {
    _timeoutTimer?.cancel();
    _warningTimer?.cancel();

    _warningTimer = Timer(timeout - warningBefore, _emitWarning);
    _timeoutTimer = Timer(timeout, _handleTimeout);
  }
}

/// Privacy manager (GDPR Article 7)
class PrivacyManager {
  Future<bool> hasConsent(ConsentType type);
  Future<void> setConsent(ConsentType type, bool granted);
  Future<void> recordConsentWithdrawal(ConsentType type);
}

enum ConsentType {
  essential,      // Required, always true
  analytics,      // Optional
  marketing,      // Optional
  personalization // Optional
}
```

### Key Domain Services

| Service | Purpose |
|---------|---------|
| `InputValidator` | Input validation/sanitization |
| `TemplateValidator` | Workout template validation |
| `BatteryMonitorService` | Battery status tracking |
| `PlateCalculatorService` | Weightlifting plate calculations |
| `RequestThrottler` | Request rate limiting |
| `SecureLogger` | Sensitive data redaction |

---

## Presentation Layer

**Location**: `lib/shared/presentation/`

### Purpose
UI components, state management, and user interaction.

### Subdirectories

| Directory | Purpose |
|-----------|---------|
| `theme/` | Design system (colors, icons, spacing) |
| `l10n/` | Localization |
| `extensions/` | BuildContext extensions |
| `providers/` | Global providers |
| `services/` | UI services |
| `screens/` | Shared screens |
| `widgets/` | Component library (40+) |

### Theme & Design System

```dart
/// Centralized icons (315+ uses)
class AppIcons {
  // Core fitness
  static const IconData workout = Icons.fitness_center;
  static const IconData cardio = Icons.directions_run;
  static const IconData timer = Icons.timer;
  static const IconData rest = Icons.pause_circle_outline;

  // Actions
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.save;

  // Navigation
  static const IconData home = Icons.home;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;

  // Status
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber;
  static const IconData info = Icons.info_outline;

  // ... 50+ more semantic mappings
}

/// Icon sizes
class AppIconSize {
  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
  static const double xlarge = 48.0;
  static const double xxlarge = 64.0;
}

/// Consistent spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Custom colors beyond Material
extension AppColors on ColorScheme {
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF81C784)
      : const Color(0xFF4CAF50);

  Color get warning => brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFFF9800);
}
```

### BuildContext Extensions

```dart
/// Essential context extensions
extension BuildContextExtensions on BuildContext {
  /// Access color scheme: context.colors.primary
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Access localizations: context.l10n.title
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Access text theme: context.textTheme.bodyMedium
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access full theme: context.theme
  ThemeData get theme => Theme.of(this);

  /// Screen size helpers
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
}
```

### Providers

```dart
/// App configuration
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

/// Theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('en', 'US'));

/// Weight settings
final weightSettingsProvider = NotifierProvider<WeightSettingsNotifier, WeightSettings>(
  WeightSettingsNotifier.new,
);

/// Feedback settings
final feedbackSettingsProvider = NotifierProvider<FeedbackSettingsNotifier, FeedbackSettings>(
  FeedbackSettingsNotifier.new,
);
```

### UI Services

```dart
/// Centralized snackbar management
class SnackBarService {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(BuildContext context, String message);
  static void showWarning(BuildContext context, String message);
  static void showCustom(BuildContext context, String message, {
    String? actionLabel,
    VoidCallback? onAction,
  });
}

/// Haptic feedback
class HapticFeedbackService {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
}
```

### Widget Library (40+ Components)

#### Containers & Layouts

| Widget | Purpose |
|--------|---------|
| `PressableCard` | Tap feedback card |
| `GradientActionCard` | Gradient background card |
| `ExpandableCard` | Collapsible card |
| `MaterialScrollList` | Optimized scrolling |

#### Indicators & Feedback

| Widget | Purpose |
|--------|---------|
| `LoadingIndicator` | **Unified loading** (replaces CircularProgressIndicator) |
| `SyncProgressIndicator` | Sync status with progress |
| `SyncStatusToast` | Sync state notification |
| `RPEIndicator` | Rate of Perceived Exertion scale |
| `BadgedIcon` | Icon with badge counter |
| `SemanticIcon` | Icon with accessibility labels |

#### Interactive Elements

| Widget | Purpose |
|--------|---------|
| `InteractiveElement` | Pressable with visual feedback |
| `ExpandableFAB` | Multi-action floating button |
| `DraggableActionButton` | Draggable action button |

#### Overlays & Guidance

| Widget | Purpose |
|--------|---------|
| `ErrorBoundary` | Global error handling |
| `AppLifecycleManager` | Lifecycle monitoring |
| `BetaModeBanner` | Beta version indicator |
| `DebugScreenNameOverlay` | Screen name debug |
| `DraggableTutorialOverlay` | Tutorial guidance |

#### Premium & Ads

| Widget | Purpose |
|--------|---------|
| `AdaptiveBannerAd` | Responsive ad container |
| `PremiumActionButton` | Premium feature button |
| `PremiumFeatureCard` | Premium upsell card |

#### Empty States & Info

| Widget | Purpose |
|--------|---------|
| `EnhancedEmptyState` | Rich empty state UI |
| `FooterDisclaimer` | Legal/disclaimer text |
| `InfoTooltip` | Information tooltip |
| `SkeletonLoader` | Skeleton loading placeholder |

#### Accessibility & Privacy

| Widget | Purpose |
|--------|---------|
| `ConsentDialog` | GDPR consent UI |

---

## Utils

**Location**: `lib/shared/utils/`

### Purpose
Pure utility functions for common tasks.

### Key Files

| File | Purpose |
|------|---------|
| `safe_parsing.dart` | Type-safe parsing with fallbacks |
| `accessibility_utils.dart` | A11y helpers |
| `contrast_checker.dart` | WCAG contrast compliance |
| `simple_markdown_parser.dart` | Markdown → rich text |
| `timer_logger.dart` | Performance profiling |

### Safe Parsing

```dart
/// Prevents FormatException crashes from corrupted data
Color parseColorSafe(String? colorString, {Color fallback = Colors.grey}) {
  if (colorString == null) return fallback;
  try {
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  } catch (_) {
    return fallback;
  }
}

int parseIntSafe(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double parseDoubleSafe(dynamic value, {
  double fallback = 0.0,
  double? min,
  double? max,
}) {
  double result = fallback;
  if (value is double) result = value;
  else if (value is int) result = value.toDouble();
  else if (value is String) result = double.tryParse(value) ?? fallback;

  if (min != null && result < min) result = min;
  if (max != null && result > max) result = max;
  return result;
}

DateTime? parseDateTimeSafe(dynamic value, {DateTime? fallback}) {
  if (value == null) return fallback;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? fallback;
  return fallback;
}

T parseEnumSafe<T>(String? value, List<T> enumValues, {required T fallback}) {
  if (value == null) return fallback;
  return enumValues.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => fallback,
  );
}
```

---

## Usage Patterns

### Correct Imports

```dart
// Theme & Colors
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/color_scheme_extensions.dart';

// Usage
context.colors.primary     // Primary color
context.colors.success     // Success green
context.colors.error       // Error red
context.l10n.title         // Localized text
context.textTheme.bodyLarge // Text style

// Icons
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

// Usage
Icon(AppIcons.workout, size: AppIconSize.medium)

// Loading
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

// Usage
LoadingIndicator()  // NOT CircularProgressIndicator()

// Snackbar
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

// Usage
SnackBarService.showSuccess(context, 'Saved!')  // NOT ScaffoldMessenger
```

### iOS Build Compliance

```dart
// ✅ CORRECT
Text(context.l10n.title)

// ❌ WRONG - iOS build error!
const Text(context.l10n.title)
```

---

## Cross-Layer Dependencies

```
Domain → Data
  Domain Entities ← Data Models (serialization)
  Domain Failures ← Data Services (exception mapping)

Domain → Presentation
  AppConfig (Entity) ← AppConfigProvider (UI state)
  WeightSettings (Entity) ← WeightSettingsProvider (UI state)

Data → Presentation
  HybridAppConfigRepository → AppConfigNotifier
  DataSource (Hive) → SharedPreferencesProvider

All Layers → Utils
  safe_parsing, accessibility_utils used everywhere
  BuildContextExtensions, AppIcons used in presentation
```

---

## Design Patterns

### 1. Either Pattern (Functional Programming)
All operations return `Either<Failure, Success>`, eliminating exceptions for expected errors.

### 2. Hybrid Repository Pattern
FREE tier uses local-only, PREMIUM tier adds cloud sync - single API for both.

### 3. Cache-First Strategy
Read from cache first (instant), fallback to server on miss.

### 4. Token Bucket Rate Limiting
Prevents API abuse and Firebase cost explosion.

### 5. Safe Parsing
All external data validated before use with fallbacks.

### 6. Centralized Resources
Icons, colors, text unified through AppIcons, context.colors, context.l10n.

---

## Security Implementation

### OWASP Coverage
- **M1 (Platform Usage)**: RateLimiter prevents API abuse
- **M2 (Data Storage)**: Hive encryption, SharedPreferences
- **M3 (Communication)**: SecureHttpClient with SSL pinning
- **M4 (Authentication)**: SessionTimeoutService, RBAC
- **M7 (Client Injection)**: InputValidator sanitizes all input

### Compliance
- **GDPR**: PrivacyManager consent tracking, data minimization
- **HIPAA**: SessionTimeoutService for health data protection

---

## See Also

- [INDEX.md](../INDEX.md) - Codebase navigation
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture patterns
- [core/README.md](../core/README.md) - Core modules
