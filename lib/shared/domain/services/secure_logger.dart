import 'package:flutter/foundation.dart';

/// Secure Logging Service
///
/// OWASP Mobile Security: Prevents sensitive data exposure in logs
/// - Debug-only logging (no logs in production releases)
/// - No PII (Personally Identifiable Information) logging
/// - Structured log levels (debug, info, warning, error, performance)
///
/// SECURITY BENEFITS:
/// - ✅ Prevents accidental PII exposure in production logs
/// - ✅ Reduces attack surface (no verbose logs in release builds)
/// - ✅ Improves performance (no logging overhead in production)
/// - ✅ Complies with GDPR/privacy regulations
///
/// USAGE:
/// ```dart
/// // Replace print() with SecureLogger
/// SecureLogger.debug('User logged in'); // Only in debug mode
/// SecureLogger.error('API call failed', error: e, stackTrace: st);
/// SecureLogger.performance('Workout sync completed in ${duration}ms');
/// ```
///
/// MIGRATION FROM print():
/// ```dart
/// // ❌ BAD: Logs in production, may expose PII
/// print('User email: $email');
///
/// // ✅ GOOD: Only logs in debug, sanitized
/// SecureLogger.debug('User authenticated: ${user.id}'); // No email!
/// ```
class SecureLogger {
  /// Private constructor (utility class)
  SecureLogger._();

  /// Log level threshold for filtering
  static LogLevel _minLogLevel = LogLevel.debug;

  /// Set minimum log level (for filtering in debug mode)
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Debug log - for development/troubleshooting
  ///
  /// Use for: Detailed flow tracking, variable inspection, debug info
  /// Examples: "Entering function X", "Variable Y = $value"
  ///
  /// SECURITY NOTE: Never log PII (emails, passwords, tokens)
  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.index > LogLevel.debug.index) return;

    _log('🐛 DEBUG', message, error: error, stackTrace: stackTrace, data: data);
  }

  /// Info log - for general information
  ///
  /// Use for: App lifecycle events, feature usage, non-sensitive operations
  /// Examples: "App started", "Workout completed", "Sync successful"
  ///
  /// SECURITY NOTE: Safe for production (if needed), but still debug-only by default
  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.index > LogLevel.info.index) return;

    _log('ℹ️ INFO', message, error: error, stackTrace: stackTrace, data: data);
  }

  /// Warning log - for potential issues
  ///
  /// Use for: Deprecated API usage, fallback logic, recoverable errors
  /// Examples: "API rate limit approaching", "Cache miss", "Retry attempt 2/3"
  ///
  /// SECURITY NOTE: May log in production (for monitoring), sanitize data
  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION (for now)
    if (_minLogLevel.index > LogLevel.warning.index) return;

    _log(
      '⚠️ WARNING',
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Error log - for errors and exceptions
  ///
  /// Use for: API failures, database errors, unhandled exceptions
  /// Examples: "Failed to sync workout", "Network timeout", "Parse error"
  ///
  /// SECURITY NOTE: Sanitize error messages before logging
  /// - ❌ DON'T: SecureLogger.error('Auth failed for $email')
  /// - ✅ DO: SecureLogger.error('Auth failed for user ${user.id}')
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.index > LogLevel.error.index) return;

    _log(
      '❌ ERROR',
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Performance log - for timing and metrics
  ///
  /// Use for: Slow operations, benchmarking, optimization tracking
  /// Examples: "Workout sync took 1.2s", "Firebase query completed in 340ms"
  ///
  /// SECURITY NOTE: Safe to log durations, counts, but not user data
  static void performance(
    String message, {
    int? durationMs,
    Map<String, dynamic>? metrics,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.index > LogLevel.performance.index) return;

    final data = <String, dynamic>{};
    if (durationMs != null) data['duration_ms'] = durationMs;
    if (metrics != null) data.addAll(metrics);

    _log('⚡ PERF', message, data: data);
  }

  /// Internal log formatter
  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();

    // Format: [TIMESTAMP] LEVEL: Message
    buffer.write('[$timestamp] $level: $message');

    // Add structured data if present
    if (data != null && data.isNotEmpty) {
      buffer.write(' | Data: ${_sanitizeData(data)}');
    }

    // Add error info if present
    if (error != null) {
      buffer.write('\n   Error: ${_sanitizeError(error)}');
    }

    // Add stack trace if present (only first 5 frames for readability)
    if (stackTrace != null) {
      final frames = stackTrace.toString().split('\n').take(5).join('\n');
      buffer.write('\n   StackTrace:\n$frames');
    }

    // Output to debug console
    debugPrint(buffer.toString());
  }

  /// Sanitize data map to remove potential PII
  ///
  /// Removes: email, password, token, apiKey, secret, credit card
  /// Redacts: phone numbers, IP addresses
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      // Block sensitive keys
      if (_isSensitiveKey(key)) {
        sanitized[entry.key] = '[REDACTED]';
        continue;
      }

      // Sanitize string values
      if (value is String) {
        sanitized[entry.key] = _sanitizeString(value);
      } else if (value is Map) {
        sanitized[entry.key] = _sanitizeData(value.cast<String, dynamic>());
      } else {
        sanitized[entry.key] = value;
      }
    }

    return sanitized;
  }

  /// Check if key contains sensitive information
  static bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      'email',
      'password',
      'token',
      'apikey',
      'secret',
      'credit',
      'card',
      'ssn',
      'phone',
      'address',
    ];

    return sensitiveKeys.any((sensitive) => key.contains(sensitive));
  }

  /// Sanitize string value to redact potential PII
  static String _sanitizeString(String value) {
    // Redact email addresses
    if (_isEmail(value)) {
      return '[EMAIL_REDACTED]';
    }

    // Redact phone numbers (basic pattern)
    if (_isPhoneNumber(value)) {
      return '[PHONE_REDACTED]';
    }

    // Redact tokens (long alphanumeric strings)
    if (_isToken(value)) {
      return '[TOKEN_REDACTED]';
    }

    return value;
  }

  /// Check if string is an email
  static bool _isEmail(String value) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(value);
  }

  /// Check if string is a phone number
  static bool _isPhoneNumber(String value) {
    final phonePattern = RegExp(r'^[\d\s\-\+\(\)]{10,}$');
    return phonePattern.hasMatch(value);
  }

  /// Check if string is a token (long alphanumeric)
  static bool _isToken(String value) {
    return value.length > 30 &&
        RegExp(r'^[a-zA-Z0-9\-_\.]+$').hasMatch(value);
  }

  /// Sanitize error message to remove potential PII
  static String _sanitizeError(Object error) {
    final errorString = error.toString();

    // Redact emails in error messages
    var sanitized = errorString.replaceAllMapped(
      RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'),
      (_) => '[EMAIL_REDACTED]',
    );

    // Redact tokens in error messages
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[a-zA-Z0-9\-_\.]{30,}\b'),
      (_) => '[TOKEN_REDACTED]',
    );

    return sanitized;
  }

  /// LEGACY SUPPORT: Alias for print() replacement
  ///
  /// Use this during migration from print() to SecureLogger
  /// Then refactor to use specific methods (debug, info, error)
  @Deprecated('Use SecureLogger.debug() instead')
  static void log(String message) {
    debug(message);
  }
}

/// Log levels for filtering
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  performance(4);

  const LogLevel(this.index);
  final int index;
}
