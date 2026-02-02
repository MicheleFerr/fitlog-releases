/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/errors
/// 🎯 Feature: ai_coach
/// 🔧 Type: error_handling
///
/// HealthKit Error Types & Handlers
///
/// **Error Categories**:
/// - Permission errors (denied, restricted, not determined)
/// - Platform errors (HealthKit not available)
/// - Sync errors (network, timeout, rate limit)
/// - Data errors (invalid format, missing data)
///
/// **User Experience**:
/// - Clear, non-technical error messages
/// - Actionable suggestions (e.g., "Open Settings")
/// - Automatic retry for transient errors
/// - Graceful degradation (continue without HealthKit)
library;

import 'package:flutter/foundation.dart';

/// Base class for all HealthKit-related errors
///
/// **Usage**:
/// ```dart
/// try {
///   await healthKitDatasource.initialize();
/// } catch (e) {
///   if (e is HealthKitError) {
///     // Handle specific error types
///   }
/// }
/// ```
sealed class HealthKitError implements Exception {
  const HealthKitError(this.message, {this.recoverySuggestion});

  final String message;
  final String? recoverySuggestion;

  @override
  String toString() => 'HealthKitError: $message';
}

// ==========================================
// PERMISSION ERRORS
// ==========================================

/// Permission denied by user
///
/// User explicitly denied HealthKit access in iOS settings
/// or during permission request dialog
///
/// **Recovery**: Ask user to open Settings > Privacy > Health
class HealthKitPermissionDeniedError extends HealthKitError {
  const HealthKitPermissionDeniedError()
    : super(
        'Health data access denied',
        recoverySuggestion:
            'Grant access in Settings > Privacy & Security > Health',
      );
}

/// Permission restricted by device policy
///
/// HealthKit access restricted by parental controls,
/// MDM policy, or device configuration
///
/// **Recovery**: Contact device administrator
class HealthKitPermissionRestrictedError extends HealthKitError {
  const HealthKitPermissionRestrictedError()
    : super(
        'Health data access restricted',
        recoverySuggestion:
            'HealthKit access is restricted by your device. Contact your device administrator.',
      );
}

/// Permission not yet determined
///
/// User hasn't been asked for HealthKit permissions yet
///
/// **Recovery**: Show consent dialog and request permissions
class HealthKitPermissionNotDeterminedError extends HealthKitError {
  const HealthKitPermissionNotDeterminedError()
    : super(
        'Health data permissions not configured',
        recoverySuggestion: 'Grant health data access to use AI Coach features',
      );
}

// ==========================================
// PLATFORM ERRORS
// ==========================================

/// HealthKit not available on this device
///
/// Device is not running iOS or iOS version too old
///
/// **Recovery**: Graceful degradation (disable HealthKit features)
class HealthKitNotAvailableError extends HealthKitError {
  const HealthKitNotAvailableError()
    : super(
        'Apple Health not available',
        recoverySuggestion:
            'HealthKit requires iOS 14.0 or later. AI Coach will work without health data.',
      );
}

/// HealthKit disabled in Settings
///
/// User turned off HealthKit in iOS Settings > Health
///
/// **Recovery**: Ask user to re-enable HealthKit in Settings
class HealthKitDisabledError extends HealthKitError {
  const HealthKitDisabledError()
    : super(
        'Apple Health is disabled',
        recoverySuggestion:
            'Enable Apple Health in Settings > Health to use these features',
      );
}

// ==========================================
// SYNC ERRORS
// ==========================================

/// Sync failed due to network error
///
/// No internet connection or Firebase unreachable
///
/// **Recovery**: Retry when connection restored (offline queue)
class HealthKitSyncNetworkError extends HealthKitError {
  const HealthKitSyncNetworkError()
    : super(
        'Sync failed: No internet connection',
        recoverySuggestion:
            'Health data will sync automatically when connection is restored',
      );
}

/// Sync failed due to timeout
///
/// Request took too long (> 30s)
///
/// **Recovery**: Retry sync later
class HealthKitSyncTimeoutError extends HealthKitError {
  const HealthKitSyncTimeoutError()
    : super(
        'Sync timed out',
        recoverySuggestion: 'Try syncing again in a few minutes',
      );
}

/// Sync failed due to rate limit
///
/// Too many sync requests in short time (Firebase quota exceeded)
///
/// **Recovery**: Wait and retry later
class HealthKitSyncRateLimitError extends HealthKitError {
  const HealthKitSyncRateLimitError()
    : super(
        'Sync rate limit exceeded',
        recoverySuggestion:
            'Try again in a few minutes. Background sync will continue.',
      );
}

/// Sync failed due to server error
///
/// Firebase error (500, 503, etc.)
///
/// **Recovery**: Retry with exponential backoff
class HealthKitSyncServerError extends HealthKitError {
  const HealthKitSyncServerError()
    : super(
        'Sync failed: Server error',
        recoverySuggestion:
            'We\'re working on it. Data will sync automatically later.',
      );
}

// ==========================================
// DATA ERRORS
// ==========================================

/// No health data available
///
/// HealthKit has no data for requested time range
///
/// **Recovery**: Graceful message (no action needed)
class HealthKitNoDataError extends HealthKitError {
  const HealthKitNoDataError(String dataType)
    : super(
        'No $dataType data available',
        recoverySuggestion: 'Start tracking $dataType in Apple Health app',
      );
}

/// Health data format invalid
///
/// Data from HealthKit is malformed or unexpected format
///
/// **Recovery**: Log error and skip invalid data
class HealthKitInvalidDataError extends HealthKitError {
  const HealthKitInvalidDataError()
    : super(
        'Invalid health data format',
        recoverySuggestion:
            'Try syncing again. If issue persists, contact support.',
      );
}

// ==========================================
// ERROR HANDLER
// ==========================================

/// HealthKit error handler with logging and recovery strategies
///
/// **Usage**:
/// ```dart
/// try {
///   await healthKitDatasource.initialize();
/// } catch (e) {
///   HealthKitErrorHandler.handle(
///     error: e,
///     onPermissionDenied: () => showPermissionDialog(),
///     onNotAvailable: () => disableHealthFeatures(),
///     onSyncError: () => queueForRetry(),
///   );
/// }
/// ```
class HealthKitErrorHandler {
  /// Handle HealthKit error with appropriate recovery strategy
  static void handle({
    required Object error,
    VoidCallback? onPermissionDenied,
    VoidCallback? onPermissionRestricted,
    VoidCallback? onNotAvailable,
    VoidCallback? onSyncError,
    VoidCallback? onDataError,
  }) {
    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('❌ [HealthKitErrorHandler] ${error.toString()}');
    }

    // Handle specific error types
    switch (error) {
      // Permission errors
      case HealthKitPermissionDeniedError():
        onPermissionDenied?.call();
      case HealthKitPermissionRestrictedError():
        onPermissionRestricted?.call();
      case HealthKitPermissionNotDeterminedError():
        // Request permissions again
        if (kDebugMode) {
          debugPrint('ℹ️ [HealthKitErrorHandler] Permissions not determined');
        }

      // Platform errors
      case HealthKitNotAvailableError():
      case HealthKitDisabledError():
        onNotAvailable?.call();

      // Sync errors (retry later)
      case HealthKitSyncNetworkError():
      case HealthKitSyncTimeoutError():
      case HealthKitSyncRateLimitError():
      case HealthKitSyncServerError():
        onSyncError?.call();

      // Data errors (skip and continue)
      case HealthKitNoDataError():
      case HealthKitInvalidDataError():
        onDataError?.call();

      // Unknown error
      default:
        if (kDebugMode) {
          debugPrint('⚠️ [HealthKitErrorHandler] Unknown error: $error');
        }
    }
  }

  /// Get user-friendly error message for UI display
  static String getUserMessage(Object error) {
    if (error is HealthKitError) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }

  /// Get recovery suggestion for UI display
  static String? getRecoverySuggestion(Object error) {
    if (error is HealthKitError) {
      return error.recoverySuggestion;
    }
    return null;
  }

  /// Check if error is retryable (sync errors)
  static bool isRetryable(Object error) {
    return error is HealthKitSyncNetworkError ||
        error is HealthKitSyncTimeoutError ||
        error is HealthKitSyncServerError;
  }

  /// Check if error is critical (requires immediate user action)
  static bool isCritical(Object error) {
    return error is HealthKitPermissionDeniedError ||
        error is HealthKitPermissionRestrictedError ||
        error is HealthKitNotAvailableError;
  }
}
