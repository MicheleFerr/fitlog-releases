import 'package:flutter/foundation.dart';

/// 🔐 UNIFIED Secure Logging Service
///
/// **SINGLE SOURCE OF TRUTH** for security-aware logging.
/// Consolidates 3 previous implementations:
/// - `core/utils/secure_logger.dart` (now deprecated)
/// - `shared/utils/secure_logger.dart` (now deprecated)
/// - `shared/domain/services/secure_logger.dart` (THIS FILE - canonical)
///
/// OWASP Mobile Security: Prevents sensitive data exposure in logs
/// - Debug-only logging (no logs in production releases)
/// - No PII (Personally Identifiable Information) logging
/// - Structured log levels (debug, info, warning, error, performance)
/// - Automatic sanitization of emails, passwords, tokens, etc.
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

  // ============================================================================
  // LOG LEVEL FILTERING
  // ============================================================================

  /// Log level threshold for filtering
  static SecureLogLevel _minLogLevel = SecureLogLevel.debug;

  /// Set minimum log level (for filtering in debug mode)
  static void setMinLogLevel(SecureLogLevel level) {
    _minLogLevel = level;
  }

  // ============================================================================
  // SENSITIVE DATA PATTERNS
  // ============================================================================

  /// Patterns to detect and sanitize sensitive data (comprehensive list)
  static final List<RegExp> _sensitivePatterns = [
    // Email addresses
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    // Phone numbers (international format)
    RegExp(r'\b\+?[1-9]\d{1,14}\b'),
    // Credit card numbers
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
    // JWT tokens (base64 pattern with dots)
    RegExp(r'eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_.+/=]*'),
    // API keys (common patterns - 32+ chars)
    RegExp(r'\b[A-Za-z0-9]{32,}\b'),
    // Firebase UID pattern (28 chars)
    RegExp(r'\b[A-Za-z0-9]{28}\b'),
    // Generic UID pattern
    RegExp(r'uid["\s:]+[\w-]+', caseSensitive: false),
    // Token pattern
    RegExp(r'token["\s:]+[\w.-]+', caseSensitive: false),
    // Password pattern
    RegExp(r'password["\s:]+[\w!@#$%^&*]+', caseSensitive: false),
    // API key pattern
    RegExp(r'(api[_-]?key|apikey)["\s:]+[\w-]+', caseSensitive: false),
    // Authorization header
    RegExp(r'authorization["\s:]+[\w.-]+', caseSensitive: false),
  ];

  /// Common field names containing sensitive data
  static final List<String> _sensitiveFieldNames = [
    'password',
    'token',
    'apiKey',
    'api_key',
    'secret',
    'userId',
    'user_id',
    'uid',
    'email',
    'phone',
    'phoneNumber',
    'phone_number',
    'creditCard',
    'credit_card',
    'ssn',
    'dateOfBirth',
    'date_of_birth',
    'address',
    'latitude',
    'longitude',
    'location',
    'authorization',
  ];

  // ============================================================================
  // LOGGING METHODS
  // ============================================================================

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
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.severity > SecureLogLevel.debug.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log('🐛 DEBUG', message, error: error, stackTrace: stackTrace, metadata: effectiveMetadata);
  }

  /// Info log - for general information
  ///
  /// Use for: App lifecycle events, feature usage, non-sensitive operations
  /// Examples: "App started", "Workout completed", "Sync successful"
  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.severity > SecureLogLevel.info.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log('ℹ️ INFO', message, error: error, stackTrace: stackTrace, metadata: effectiveMetadata);
  }

  /// Warning log - for potential issues
  ///
  /// Use for: Deprecated API usage, fallback logic, recoverable errors
  /// Examples: "API rate limit approaching", "Cache miss", "Retry attempt 2/3"
  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.severity > SecureLogLevel.warning.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log(
      '⚠️ WARNING',
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: effectiveMetadata,
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
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return; // NO LOGS IN PRODUCTION
    if (_minLogLevel.severity > SecureLogLevel.error.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log(
      '❌ ERROR',
      message,
      error: error,
      stackTrace: stackTrace,
      metadata: effectiveMetadata,
    );
  }

  /// Success log - for successful operations
  ///
  /// Use for: Completed tasks, successful saves, confirmations
  /// Examples: "Workout saved", "Sync completed", "Profile updated"
  static void success(
    String message, {
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return;
    if (_minLogLevel.severity > SecureLogLevel.info.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log('✅ SUCCESS', message, metadata: effectiveMetadata);
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
    if (_minLogLevel.severity > SecureLogLevel.performance.severity) return;

    final metadata = <String, dynamic>{};
    if (durationMs != null) metadata['duration_ms'] = durationMs;
    if (metrics != null) metadata.addAll(metrics);

    _log('⚡ PERF', message, metadata: metadata);
  }

  /// Verbose log - for highly detailed debugging (use sparingly)
  ///
  /// Use for: Timer ticks, frequent events, detailed tracing
  /// Warning: Can create log spam
  static void verbose(
    String message, {
    Map<String, dynamic>? metadata,
    @Deprecated('Use metadata instead') Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return;
    if (_minLogLevel.severity > SecureLogLevel.debug.severity) return;

    // Support both 'metadata' and deprecated 'data' parameter
    final effectiveMetadata = metadata ?? data;
    _log('🔍 VERBOSE', message, metadata: effectiveMetadata);
  }

  // ============================================================================
  // LOG HELPERS (for backward compatibility)
  // ============================================================================

  /// Simple log method (backward compatibility with old API)
  ///
  /// Use this during migration from print() to SecureLogger
  /// Then refactor to use specific methods (debug, info, error)
  static void log(String message, {bool sanitize = true, Map<String, dynamic>? metadata}) {
    if (!kDebugMode) return;

    final sanitizedMessage = sanitize ? _sanitizeMessage(message) : message;
    final sanitizedMetadata = metadata != null ? _sanitizeData(metadata) : null;

    if (sanitizedMetadata != null && sanitizedMetadata.isNotEmpty) {
      final metadataStr = sanitizedMetadata.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      debugPrint('$sanitizedMessage | $metadataStr');
    } else {
      debugPrint(sanitizedMessage);
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if a string contains sensitive data
  ///
  /// Useful for preventing accidental logging of sensitive data
  static bool containsSensitiveData(String text) {
    return _sensitivePatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Manually redact a value
  ///
  /// Use this to explicitly redact specific values
  static String redact(String value) {
    return '[REDACTED]';
  }

  /// Get a safe substring for logging
  ///
  /// Returns first and last N characters, redacting the middle
  /// Useful for IDs that need partial visibility for debugging
  ///
  /// Example:
  /// ```dart
  /// SecureLogger.partialRedact('abc123def456', show: 3)
  /// // Returns: "abc...456"
  /// ```
  static String partialRedact(String value, {int show = 4}) {
    if (value.length <= show * 2) {
      return '[REDACTED]';
    }

    final start = value.substring(0, show);
    final end = value.substring(value.length - show);
    return '$start...$end';
  }

  // ============================================================================
  // INTERNAL LOG FORMATTER
  // ============================================================================

  /// Internal log formatter
  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();

    // Sanitize message
    final sanitizedMessage = _sanitizeMessage(message);

    // Format: [TIMESTAMP] LEVEL: Message
    buffer.write('[$timestamp] $level: $sanitizedMessage');

    // Add structured metadata if present
    if (metadata != null && metadata.isNotEmpty) {
      final sanitizedMetadata = _sanitizeData(metadata);
      buffer.write(' | Metadata: $sanitizedMetadata');
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

  // ============================================================================
  // SANITIZATION METHODS
  // ============================================================================

  /// Sanitize a message string
  ///
  /// Replaces sensitive patterns with [REDACTED]
  static String _sanitizeMessage(String message) {
    var sanitized = message;

    // Replace sensitive patterns
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED]');
    }

    // Replace common sensitive words with values
    for (final field in _sensitiveFieldNames) {
      // Case-insensitive replacement for field: value patterns
      final regex = RegExp('$field:\\s*\\S+', caseSensitive: false);
      sanitized = sanitized.replaceAll(regex, '$field: [REDACTED]');
    }

    return sanitized;
  }

  /// Sanitize data map to remove potential PII
  ///
  /// Removes: email, password, token, apiKey, secret, credit card
  /// Redacts: phone numbers, IP addresses
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final keyLower = key.toLowerCase();
      final value = entry.value;

      // Check if field name is sensitive
      final isSensitive = _sensitiveFieldNames.any(
        (field) => keyLower.contains(field.toLowerCase()),
      );

      if (isSensitive) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String) {
        // Sanitize string values
        sanitized[key] = _sanitizeString(value);
      } else if (value is Map) {
        // Recursively sanitize nested maps
        sanitized[key] = _sanitizeData(value.cast<String, dynamic>());
      } else if (value is List) {
        // Sanitize lists
        sanitized[key] = value.map((item) {
          if (item is String) {
            return _sanitizeString(item);
          } else if (item is Map) {
            return _sanitizeData(item.cast<String, dynamic>());
          }
          return item;
        }).toList();
      } else {
        // Keep non-sensitive primitive values
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Sanitize string value to redact potential PII
  static String _sanitizeString(String value) {
    // Redact email addresses
    if (_isEmail(value)) {
      return '[EMAIL_REDACTED]';
    }

    // Redact phone numbers
    if (_isPhoneNumber(value)) {
      return '[PHONE_REDACTED]';
    }

    // Redact tokens (long alphanumeric strings)
    if (_isToken(value)) {
      return '[TOKEN_REDACTED]';
    }

    // Apply pattern-based sanitization
    return _sanitizeMessage(value);
  }

  /// Check if string is an email
  static bool _isEmail(String value) {
    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
}

// ============================================================================
// LOG LEVEL ENUM
// ============================================================================

/// Log levels for filtering (renamed to avoid conflicts)
enum SecureLogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  performance(4);

  const SecureLogLevel(this.severity);
  final int severity;
}

// ============================================================================
// MIXIN FOR EASY INTEGRATION
// ============================================================================

/// Mixin per aggiungere facilmente logging sicuro a qualsiasi classe.
///
/// Esempio:
/// ```dart
/// class MyService with SecureLoggingMixin {
///   void doSomething() {
///     logInfo('Doing something');
///     try {
///       // ...
///     } catch (e, st) {
///       logError('Failed', e, st);
///     }
///   }
/// }
/// ```
mixin SecureLoggingMixin {
  void logDebug(String message) => SecureLogger.debug(message);
  void logInfo(String message) => SecureLogger.info(message);
  void logWarning(String message) => SecureLogger.warning(message);
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      SecureLogger.error(message, error: error, stackTrace: stackTrace);
  void logSuccess(String message) => SecureLogger.success(message);
  void logVerbose(String message) => SecureLogger.verbose(message);
}

// ============================================================================
// BACKWARD COMPATIBILITY - LogLevel alias
// ============================================================================

/// @deprecated Use [SecureLogLevel] instead
///
/// This typedef exists for backward compatibility with code that used
/// the old LogLevel enum from this file.
@Deprecated('Use SecureLogLevel instead')
typedef LogLevel = SecureLogLevel;
