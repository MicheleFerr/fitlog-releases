/**
 * 🔐 SECURITY: Conditional Logger
 *
 * Provides safe logging with automatic kDebugMode guards and log levels.
 *
 * **Security Benefits**:
 * - Logs NEVER appear in production (automatic kDebugMode check)
 * - No need for manual if (kDebugMode) wrappers
 * - Consistent logging format across the app
 * - Log levels for filtering (debug, info, warning, error)
 * - Zero performance overhead in release builds (compiler optimization)
 *
 * **Usage**:
 * ```dart
 * import 'package:gymbro_flutter_new/core/utils/app_logger.dart';
 *
 * AppLogger.debug('Debug message');
 * AppLogger.info('Info message');
 * AppLogger.warning('Warning message');
 * AppLogger.error('Error message');
 * ```
 *
 * **Migration from debugPrint**:
 * ```dart
 * // OLD (manual guard):
 * if (kDebugMode) {
 *   debugPrint('message');
 * }
 *
 * // NEW (automatic guard):
 * AppLogger.debug('message');
 * ```
 *
 * **Performance**:
 * - In release builds: All logging code is removed by tree-shaking
 * - In debug builds: Same performance as debugPrint
 * - No string interpolation overhead in release (dead code elimination)
 *
 * @see https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html
 */

import 'package:flutter/foundation.dart';

/// Conditional logger with automatic kDebugMode guards
///
/// Provides safe logging that never appears in production builds.
/// All methods automatically check kDebugMode internally.
class AppLogger {
  // Private constructor to prevent instantiation (utility class)
  AppLogger._();

  /// Log debug-level message
  ///
  /// Use for:
  /// - Development debugging
  /// - Verbose state changes
  /// - Internal implementation details
  ///
  /// Example:
  /// ```dart
  /// AppLogger.debug('User tapped button');
  /// AppLogger.debug('Cache hit: $key');
  /// ```
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '🔍 [$tag]' : '🔍';
      debugPrint('$prefix $message');
    }
  }

  /// Log info-level message
  ///
  /// Use for:
  /// - Important state transitions
  /// - Successful operations
  /// - User actions
  ///
  /// Example:
  /// ```dart
  /// AppLogger.info('Workout started');
  /// AppLogger.info('Exercise completed: ${exercise.name}');
  /// ```
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? 'ℹ️ [$tag]' : 'ℹ️';
      debugPrint('$prefix $message');
    }
  }

  /// Log warning-level message
  ///
  /// Use for:
  /// - Recoverable errors
  /// - Deprecated API usage
  /// - Performance warnings
  ///
  /// Example:
  /// ```dart
  /// AppLogger.warning('Cache miss, falling back to network');
  /// AppLogger.warning('Slow operation took ${duration}ms');
  /// ```
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '⚠️ [$tag]' : '⚠️';
      debugPrint('$prefix $message');
    }
  }

  /// Log error-level message
  ///
  /// Use for:
  /// - Exceptions and errors
  /// - Failed operations
  /// - Data validation failures
  ///
  /// Example:
  /// ```dart
  /// AppLogger.error('Failed to save workout: $error');
  /// AppLogger.error('Invalid input: ${validation.error}');
  /// ```
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final prefix = tag != null ? '❌ [$tag]' : '❌';
      debugPrint('$prefix $message');

      if (error != null) {
        debugPrint('$prefix Error: $error');
      }

      if (stackTrace != null) {
        debugPrint('$prefix Stack trace: $stackTrace');
      }
    }
  }

  /// Log security-related event
  ///
  /// Use for:
  /// - Authentication attempts
  /// - Permission checks
  /// - Data encryption/decryption
  ///
  /// Example:
  /// ```dart
  /// AppLogger.security('User logged in');
  /// AppLogger.security('Admin role verified');
  /// ```
  static void security(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '🔐 [$tag]' : '🔐';
      debugPrint('$prefix $message');
    }
  }

  /// Log performance metric
  ///
  /// Use for:
  /// - Timing measurements
  /// - Memory usage
  /// - Operation counts
  ///
  /// Example:
  /// ```dart
  /// AppLogger.performance('Query completed in ${duration}ms');
  /// AppLogger.performance('Memory usage: ${bytes}MB');
  /// ```
  static void performance(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '⚡ [$tag]' : '⚡';
      debugPrint('$prefix $message');
    }
  }

  /// Log network request/response
  ///
  /// Use for:
  /// - API calls
  /// - Firebase operations
  /// - Network errors
  ///
  /// Example:
  /// ```dart
  /// AppLogger.network('GET /api/workouts - 200 OK');
  /// AppLogger.network('Firebase write: workouts/$userId');
  /// ```
  static void network(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '🌐 [$tag]' : '🌐';
      debugPrint('$prefix $message');
    }
  }
}
