import 'package:flutter/foundation.dart';

/// Secure Logging Utility
///
/// Provides safe logging that:
/// - Only logs in debug mode (kDebugMode)
/// - Automatically sanitizes sensitive data (PII, passwords, tokens)
/// - Prevents accidental exposure of user data
/// - Complies with GDPR and privacy regulations
///
/// OWASP Mobile Top 10 2024: M9 - Insecure Data Storage
/// GDPR Article 5(1)(f): Data processed in a manner that ensures security
class SecureLogger {
  /// Patterns to detect and sanitize sensitive data
  static final List<RegExp> _sensitivePatterns = [
    // Email addresses
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    // Phone numbers (international format)
    RegExp(r'\b\+?[1-9]\d{1,14}\b'),
    // Credit card numbers
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
    // JWT tokens (base64 pattern with dots)
    RegExp(r'eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_.+/=]*'),
    // API keys (common patterns)
    RegExp(r'\b[A-Za-z0-9]{32,}\b'),
    // Firebase UID pattern
    RegExp(r'\b[A-Za-z0-9]{28}\b'),
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
    'email',
    'phone',
    'phoneNumber',
    'phone_number',
    'creditCard',
    'credit_card',
    'ssn',
    'dateOfBirth',
    'address',
    'latitude',
    'longitude',
    'location',
  ];

  /// Log a message with automatic sanitization
  ///
  /// Only logs in debug mode (kDebugMode)
  /// Sanitizes sensitive data before logging
  ///
  /// Example:
  /// ```dart
  /// SecureLogger.log('User logged in', metadata: {'userId': '12345'});
  /// // Output: "User logged in | userId: [REDACTED]"
  /// ```
  static void log(String message, {Map<String, dynamic>? metadata}) {
    if (!kDebugMode) return;

    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedMetadata = metadata != null ? _sanitizeMetadata(metadata) : null;

    if (sanitizedMetadata != null && sanitizedMetadata.isNotEmpty) {
      final metadataStr = sanitizedMetadata.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      debugPrint('$sanitizedMessage | $metadataStr');
    } else {
      debugPrint(sanitizedMessage);
    }
  }

  /// Log an info message
  static void info(String message, {Map<String, dynamic>? metadata}) {
    log('ℹ️ $message', metadata: metadata);
  }

  /// Log a warning message
  static void warning(String message, {Map<String, dynamic>? metadata}) {
    log('⚠️ $message', metadata: metadata);
  }

  /// Log an error message
  static void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    if (!kDebugMode) return;

    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedError = error != null ? _sanitizeMessage(error.toString()) : null;

    debugPrint('❌ $sanitizedMessage');
    if (sanitizedError != null) {
      debugPrint('   Error: $sanitizedError');
    }
    if (stackTrace != null && kDebugMode) {
      // Only log first 5 lines of stack trace to avoid spam
      final lines = stackTrace.toString().split('\n').take(5).join('\n');
      debugPrint('   Stack trace:\n$lines');
    }
    if (metadata != null) {
      final sanitizedMetadata = _sanitizeMetadata(metadata);
      final metadataStr = sanitizedMetadata.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      debugPrint('   Metadata: $metadataStr');
    }
  }

  /// Log a success message
  static void success(String message, {Map<String, dynamic>? metadata}) {
    log('✅ $message', metadata: metadata);
  }

  /// Sanitize a message string
  ///
  /// Replaces sensitive patterns with [REDACTED]
  static String _sanitizeMessage(String message) {
    var sanitized = message;

    // Replace sensitive patterns
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED]');
    }

    // Replace common sensitive words
    for (final field in _sensitiveFieldNames) {
      // Case-insensitive replacement
      final regex = RegExp('$field:\\s*\\S+', caseSensitive: false);
      sanitized = sanitized.replaceAll(regex, '$field: [REDACTED]');
    }

    return sanitized;
  }

  /// Sanitize metadata map
  ///
  /// Redacts values for sensitive field names
  static Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    final sanitized = <String, dynamic>{};

    for (final entry in metadata.entries) {
      final key = entry.key;
      final value = entry.value;

      // Check if field name is sensitive
      final isSensitive = _sensitiveFieldNames.any(
        (field) => key.toLowerCase().contains(field.toLowerCase()),
      );

      if (isSensitive) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String) {
        // Sanitize string values
        sanitized[key] = _sanitizeMessage(value);
      } else if (value is Map) {
        // Recursively sanitize nested maps
        sanitized[key] = _sanitizeMetadata(value.cast<String, dynamic>());
      } else if (value is List) {
        // Sanitize lists
        sanitized[key] = value.map((item) {
          if (item is String) {
            return _sanitizeMessage(item);
          } else if (item is Map) {
            return _sanitizeMetadata(item.cast<String, dynamic>());
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
}
