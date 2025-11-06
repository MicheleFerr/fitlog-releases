import 'package:flutter/foundation.dart';

/// Template Input Validation
///
/// Validates and sanitizes template names and descriptions to prevent:
/// - XSS attacks (Cross-Site Scripting)
/// - SQL/NoSQL injection
/// - Path traversal attacks
/// - Malicious HTML/script injection
///
/// OWASP Mobile Top 10 2024:
/// - M4 - Insufficient Input/Output Validation
/// - M9 - Insecure Data Storage
///
/// GDPR Article 5(1)(f): Integrity and confidentiality
class TemplateValidator {
  /// Maximum length for template name
  static const int maxNameLength = 100;

  /// Minimum length for template name
  static const int minNameLength = 1;

  /// Maximum length for template description
  static const int maxDescriptionLength = 500;

  /// Dangerous HTML/script patterns to detect
  static final List<RegExp> _dangerousPatterns = [
    // Script tags
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
    RegExp(r'<script[^>]*>', caseSensitive: false),
    // Event handlers (onclick, onerror, etc.)
    RegExp(r'on\w+\s*=', caseSensitive: false),
    // JavaScript protocol
    RegExp(r'javascript:', caseSensitive: false),
    // Data URI with script
    RegExp(r'data:text/html', caseSensitive: false),
    // iframe injection
    RegExp(r'<iframe[^>]*>', caseSensitive: false),
    // SQL injection patterns
    RegExp(r"('|(\\')|(;)|(--)|(\/\*))", caseSensitive: false),
    // Path traversal
    RegExp(r'\.\./', caseSensitive: false),
    // Null bytes
    RegExp(r'\x00'),
  ];

  /// Validate template name
  ///
  /// Returns error message if invalid, null if valid
  ///
  /// Rules:
  /// - Not null or empty
  /// - Between 1-100 characters
  /// - No dangerous patterns (XSS, injection)
  /// - Trimmed whitespace
  static String? validateTemplateName(String? name) {
    // Null check
    if (name == null || name.isEmpty) {
      return 'Template name cannot be empty';
    }

    // Trim whitespace
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Template name cannot be only whitespace';
    }

    // Length check
    if (trimmed.length < minNameLength) {
      return 'Template name must be at least $minNameLength character';
    }

    if (trimmed.length > maxNameLength) {
      return 'Template name cannot exceed $maxNameLength characters';
    }

    // Check for dangerous patterns
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(trimmed)) {
        if (kDebugMode) {
          debugPrint('⚠️ Dangerous pattern detected in template name: ${pattern.pattern}');
        }
        return 'Template name contains invalid characters';
      }
    }

    // Check for HTML tags
    if (trimmed.contains('<') || trimmed.contains('>')) {
      return 'Template name cannot contain HTML tags';
    }

    return null; // Valid
  }

  /// Validate template description
  ///
  /// Returns error message if invalid, null if valid
  ///
  /// Rules:
  /// - Optional (can be empty)
  /// - Max 500 characters
  /// - No dangerous patterns
  static String? validateTemplateDescription(String? description) {
    // Allow empty description
    if (description == null || description.isEmpty) {
      return null;
    }

    final trimmed = description.trim();

    // Length check
    if (trimmed.length > maxDescriptionLength) {
      return 'Description cannot exceed $maxDescriptionLength characters';
    }

    // Check for dangerous patterns
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(trimmed)) {
        if (kDebugMode) {
          debugPrint('⚠️ Dangerous pattern detected in description: ${pattern.pattern}');
        }
        return 'Description contains invalid characters';
      }
    }

    return null; // Valid
  }

  /// Sanitize template name
  ///
  /// Removes dangerous characters and patterns
  /// Use this to clean user input before storage
  ///
  /// Returns sanitized string safe for storage
  static String sanitizeTemplateName(String name) {
    var sanitized = name.trim();

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove dangerous patterns
    for (final pattern in _dangerousPatterns) {
      sanitized = sanitized.replaceAll(pattern, '');
    }

    // Remove control characters (except newlines and tabs)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Normalize whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim again after sanitization
    sanitized = sanitized.trim();

    // Truncate if too long
    if (sanitized.length > maxNameLength) {
      sanitized = sanitized.substring(0, maxNameLength);
    }

    return sanitized;
  }

  /// Sanitize template description
  ///
  /// Removes dangerous characters and patterns
  /// Allows basic formatting (newlines)
  static String sanitizeTemplateDescription(String description) {
    var sanitized = description.trim();

    // Remove HTML tags (except basic formatting)
    sanitized = sanitized.replaceAll(RegExp(r'<(?!br|p|\/br|\/p)[^>]*>'), '');

    // Remove dangerous patterns
    for (final pattern in _dangerousPatterns) {
      sanitized = sanitized.replaceAll(pattern, '');
    }

    // Remove control characters (keep newlines)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Normalize multiple newlines to max 2
    sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Trim again
    sanitized = sanitized.trim();

    // Truncate if too long
    if (sanitized.length > maxDescriptionLength) {
      sanitized = sanitized.substring(0, maxDescriptionLength);
    }

    return sanitized;
  }

  /// Check if string contains dangerous patterns
  ///
  /// Returns true if dangerous, false if safe
  static bool containsDangerousPatterns(String input) {
    return _dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Validate exercise name
  ///
  /// Similar to template name but allows some special characters
  /// commonly used in exercise names (e.g., "Bench Press - Wide Grip")
  static String? validateExerciseName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Exercise name cannot be empty';
    }

    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'Exercise name cannot be only whitespace';
    }

    if (trimmed.length < minNameLength) {
      return 'Exercise name must be at least $minNameLength character';
    }

    if (trimmed.length > maxNameLength) {
      return 'Exercise name cannot exceed $maxNameLength characters';
    }

    // Check for dangerous patterns (more lenient than template name)
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(trimmed)) {
        return 'Exercise name contains invalid characters';
      }
    }

    return null; // Valid
  }

  /// Sanitize search query
  ///
  /// Removes dangerous patterns from user search input
  /// Prevents search-based injection attacks
  static String sanitizeSearchQuery(String query) {
    var sanitized = query.trim();

    // Remove SQL-like operators
    sanitized = sanitized.replaceAll(RegExp(r'(\bOR\b|\bAND\b)', caseSensitive: false), '');

    // Remove dangerous patterns
    for (final pattern in _dangerousPatterns) {
      sanitized = sanitized.replaceAll(pattern, '');
    }

    // Remove special regex characters that could cause issues
    final specialChars = [r'\', r'^', r'$', r'*', r'+', r'?', r'{', r'}', r'[', r']', r'|'];
    for (final char in specialChars) {
      sanitized = sanitized.replaceAll(char, '');
    }

    return sanitized.trim();
  }
}
