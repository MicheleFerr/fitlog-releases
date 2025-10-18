/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/services/analytics
/// 🎯 Feature: analytics
/// 🔧 Type: service interface
///
/// Analytics service interface for tracking user behavior and app performance
library;

/// Analytics service interface
///
/// Provides a unified API for tracking events, screen views, user properties,
/// and performance metrics across the application.
///
/// Implementations:
/// - [FirebaseAnalyticsService] - Production implementation using Firebase Analytics
/// - [MockAnalyticsService] - Testing/debug implementation with console logging
///
/// Usage:
/// ```dart
/// final analytics = ref.read(analyticsServiceProvider);
///
/// // Track event
/// await analytics.logEvent(
///   name: 'workout_completed',
///   parameters: {
///     'duration_seconds': 3600,
///     'exercise_count': 8,
///   },
/// );
///
/// // Track screen view
/// await analytics.logScreenView(
///   screenName: 'WorkoutDetailScreen',
///   screenClass: 'WorkoutDetailScreen',
/// );
///
/// // Set user property
/// await analytics.setUserProperty(
///   name: 'preferred_unit_system',
///   value: 'metric',
/// );
/// ```
abstract class IAnalyticsService {
  // ===== LIFECYCLE =====

  /// Initialize the analytics service
  ///
  /// Must be called before any other methods.
  /// Idempotent - safe to call multiple times.
  Future<void> initialize();

  /// Enable or disable analytics collection
  ///
  /// Used for privacy/GDPR compliance.
  /// When disabled, all tracking methods become no-ops.
  ///
  /// [enabled] - true to enable analytics, false to disable
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Check if analytics collection is currently enabled
  Future<bool> isAnalyticsCollectionEnabled();

  // ===== EVENT TRACKING =====

  /// Log a custom event
  ///
  /// [name] - Event name (max 40 chars, alphanumeric + underscore)
  /// [parameters] - Optional event parameters (max 25 parameters per event)
  ///
  /// Example:
  /// ```dart
  /// await analytics.logEvent(
  ///   name: 'preset_selected',
  ///   parameters: {
  ///     'preset_type': 'rep_range',
  ///     'preset_id': 'hypertrophy',
  ///     'screen': 'add_exercise_modal',
  ///   },
  /// );
  /// ```
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Log app open event
  ///
  /// Automatically tracked by some analytics platforms,
  /// but can be explicitly called for custom logic.
  Future<void> logAppOpen();

  /// Log screen view
  ///
  /// [screenName] - Name of the screen (e.g., 'WorkoutDetailScreen')
  /// [screenClass] - Class name of the screen (optional)
  ///
  /// Example:
  /// ```dart
  /// await analytics.logScreenView(
  ///   screenName: 'AddExerciseModal',
  ///   screenClass: 'AddExerciseModal',
  /// );
  /// ```
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  // ===== USER PROPERTIES =====

  /// Set a user property
  ///
  /// User properties are attributes you can set to describe segments of your user base.
  /// They persist across sessions.
  ///
  /// [name] - Property name (max 24 chars, alphanumeric + underscore)
  /// [value] - Property value (max 36 chars)
  ///
  /// Example:
  /// ```dart
  /// await analytics.setUserProperty(
  ///   name: 'preferred_unit_system',
  ///   value: 'metric',
  /// );
  /// ```
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Set the user ID
  ///
  /// [userId] - Unique identifier for the user (null to clear)
  Future<void> setUserId(String? userId);

  // ===== PERFORMANCE MONITORING =====

  /// Start a custom trace for performance monitoring
  ///
  /// [name] - Trace name (e.g., 'workout_save_operation')
  /// Returns a trace ID that must be passed to [stopTrace]
  ///
  /// Example:
  /// ```dart
  /// final traceId = await analytics.startTrace('workout_save');
  /// try {
  ///   await saveWorkout();
  /// } finally {
  ///   await analytics.stopTrace(traceId);
  /// }
  /// ```
  Future<String> startTrace(String name);

  /// Stop a custom trace
  ///
  /// [traceId] - ID returned from [startTrace]
  /// [metrics] - Optional custom metrics to attach to the trace
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
  });

  /// Record a network request for performance monitoring
  ///
  /// [url] - Request URL
  /// [httpMethod] - HTTP method (GET, POST, etc.)
  /// [requestPayloadSize] - Size of request payload in bytes
  /// [responsePayloadSize] - Size of response payload in bytes
  /// [httpResponseCode] - HTTP response code
  /// [responseTime] - Response time in milliseconds
  Future<void> logNetworkRequest({
    required String url,
    required String httpMethod,
    int? requestPayloadSize,
    int? responsePayloadSize,
    int? httpResponseCode,
    int? responseTime,
  });

  // ===== ECOMMERCE & MONETIZATION =====

  /// Log in-app purchase event
  ///
  /// [productId] - Product identifier
  /// [price] - Price in currency
  /// [currency] - Currency code (e.g., 'USD', 'EUR')
  /// [transactionId] - Unique transaction identifier
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  });

  // ===== DEBUG & TESTING =====

  /// Enable debug mode
  ///
  /// In debug mode, events are logged to console for verification.
  /// Should be enabled in debug builds, disabled in production.
  Future<void> setDebugMode(bool enabled);

  /// Reset analytics data (for testing only)
  ///
  /// Clears user ID and user properties.
  /// Use with caution - only for testing scenarios.
  Future<void> resetAnalyticsData();
}
