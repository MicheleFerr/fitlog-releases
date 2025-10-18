/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain/services
/// 🎯 Feature: shared
/// 🔧 Type: service interface
///
/// Service interface for analytics and telemetry
///
/// This abstraction allows swapping analytics providers:
/// - Firebase Analytics (production)
/// - Mixpanel (alternative)
/// - Custom analytics backend
/// - No-op implementation (testing, privacy mode)
library;

/// Service interface for analytics/telemetry
///
/// Provides unified API for tracking user behavior and app events
///
/// Example implementations:
/// - `FirebaseAnalyticsService` - Production analytics via Firebase
/// - `NoOpAnalyticsService` - Testing/privacy mode (does nothing)
/// - `MultiAnalyticsService` - Send to multiple providers
///
/// Example usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final analytics = ref.watch(analyticsServiceProvider);
///
///     // Track button click
///     onPressed: () {
///       analytics.logEvent('button_clicked', parameters: {
///         'button_name': 'start_workout',
///       });
///     }
///   }
/// }
/// ```
abstract class IAnalyticsService {
  /// Log custom event with optional parameters
  ///
  /// [name] - Event name (use snake_case)
  /// [parameters] - Optional event parameters (max 25 per Firebase limits)
  ///
  /// Example:
  /// ```dart
  /// await analytics.logEvent('exercise_search', parameters: {
  ///   'query': 'bench press',
  ///   'results_count': 15,
  ///   'user_boost_enabled': true,
  /// });
  /// ```
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});

  /// Log screen view
  ///
  /// [screenName] - Name of the screen (e.g., 'workout_detail', 'settings')
  /// [screenClass] - Optional screen class (widget name)
  ///
  /// Example:
  /// ```dart
  /// await analytics.logScreenView('workout_detail');
  /// ```
  Future<void> logScreenView(String screenName, {String? screenClass});

  /// Set user property (persistent across sessions)
  ///
  /// [name] - Property name (e.g., 'user_type', 'subscription_tier')
  /// [value] - Property value
  ///
  /// Example:
  /// ```dart
  /// await analytics.setUserProperty('subscription_tier', 'premium');
  /// ```
  Future<void> setUserProperty(String name, String value);

  /// Track search query and results
  ///
  /// [query] - Search query text
  /// [resultsCount] - Number of results returned
  /// [userBoostEnabled] - Whether user personalization was enabled
  /// [categoryBoostEnabled] - Whether category context was enabled
  ///
  /// This is a convenience method for tracking search behavior
  Future<void> trackSearch({
    required String query,
    required int resultsCount,
    required bool userBoostEnabled,
    required bool categoryBoostEnabled,
  });

  /// Track autocomplete selection
  ///
  /// [query] - Original search query
  /// [selectedExercise] - Name of selected exercise
  /// [matchScore] - Match quality (0.0-1.0)
  /// [position] - Position in results list (0-based)
  ///
  /// This is a convenience method for tracking autocomplete engagement
  Future<void> trackAutocompleteSelection({
    required String query,
    required String selectedExercise,
    required double matchScore,
    required int position,
  });

  /// Track preset selection (rep/set presets)
  ///
  /// [presetType] - Type of preset ('rep' or 'set')
  /// [presetId] - ID of selected preset
  /// [value] - Value of preset (number of reps/sets)
  ///
  /// This is a convenience method for tracking preset usage
  Future<void> trackPresetSelection({
    required String presetType,
    required String presetId,
    required int value,
  });
}

/// No-op analytics service (for testing or privacy mode)
///
/// Does nothing when called. Useful for:
/// - Unit tests (avoid real analytics calls)
/// - Privacy mode (user opts out of tracking)
/// - Development (avoid polluting analytics data)
///
/// Example:
/// ```dart
/// final analyticsProvider = Provider<IAnalyticsService>((ref) {
///   if (kDebugMode) {
///     return NoOpAnalyticsService(); // Don't track in dev
///   }
///   return FirebaseAnalyticsService();
/// });
/// ```
class NoOpAnalyticsService implements IAnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // No-op
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    // No-op
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    // No-op
  }

  @override
  Future<void> trackSearch({
    required String query,
    required int resultsCount,
    required bool userBoostEnabled,
    required bool categoryBoostEnabled,
  }) async {
    // No-op
  }

  @override
  Future<void> trackAutocompleteSelection({
    required String query,
    required String selectedExercise,
    required double matchScore,
    required int position,
  }) async {
    // No-op
  }

  @override
  Future<void> trackPresetSelection({
    required String presetType,
    required String presetId,
    required int value,
  }) async {
    // No-op
  }
}
