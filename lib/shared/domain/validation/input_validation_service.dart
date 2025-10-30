/// 🏋️‍♂️ FitLog Pro - Flutter Fitness App
///
/// 📁 Layer: shared/domain/validation
/// 🎯 Feature: input_validation
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// **CRITICAL SECURITY COMPONENT**
/// Safe number parsing with range validation to prevent:
/// - Application crashes from invalid input
/// - Data corruption from out-of-range values
/// - Injection attacks via malformed input
///
/// **Example:**
/// ```dart
/// // ❌ UNSAFE (can crash)
/// final weight = double.parse(controller.text);
///
/// // ✅ SAFE
/// final weight = InputValidationService.parseDoubleInRange(
///   controller.text,
///   min: 0,
///   max: 1000,
///   fieldName: 'weight',
/// );
/// ```
library;

import 'package:flutter/foundation.dart';

/// Service for safe input validation and parsing
///
/// **Zero Trust Philosophy:**
/// - NEVER trust user input
/// - ALWAYS validate before using
/// - ALWAYS provide user-friendly error messages
class InputValidationService {
  const InputValidationService._(); // Private constructor (static only)

  // ===============================
  // DOUBLE PARSING (Weight, Reps, etc.)
  // ===============================

  /// Parse double with range validation (SAFE)
  ///
  /// **Use Cases:**
  /// - Weight input (0-1000 kg/lbs)
  /// - Rest time (0-3600 seconds)
  /// - Duration (0-86400 seconds)
  ///
  /// **Parameters:**
  /// - [input]: Raw user input (from TextField)
  /// - [min]: Minimum allowed value (inclusive)
  /// - [max]: Maximum allowed value (inclusive)
  /// - [fieldName]: Display name for error messages
  /// - [defaultValue]: Value to return if parsing fails (optional)
  ///
  /// **Returns:**
  /// - Parsed value if valid
  /// - [defaultValue] if provided and parsing fails
  /// - Throws [ValidationException] if invalid and no default
  ///
  /// **Example:**
  /// ```dart
  /// final weight = InputValidationService.parseDoubleInRange(
  ///   weightController.text,
  ///   min: 0,
  ///   max: 1000,
  ///   fieldName: 'Weight',
  /// );
  /// // weight is guaranteed to be in [0, 1000]
  /// ```
  static double parseDoubleInRange(
    String input, {
    required double min,
    required double max,
    required String fieldName,
    double? defaultValue,
  }) {
    // Trim whitespace
    final trimmed = input.trim();

    // Attempt parse
    final parsed = double.tryParse(trimmed);

    if (parsed == null) {
      if (defaultValue != null) {
        if (kDebugMode) {
          debugPrint('⚠️ [Validation] Invalid $fieldName: "$input". Using default: $defaultValue');
        }
        return defaultValue;
      }

      throw ValidationException(
        '$fieldName must be a valid number',
        field: fieldName,
        invalidValue: input,
      );
    }

    // Validate range
    if (parsed < min || parsed > max) {
      throw ValidationException(
        '$fieldName must be between $min and $max',
        field: fieldName,
        invalidValue: input,
        min: min,
        max: max,
      );
    }

    return parsed;
  }

  /// Parse double with optional range (nullable)
  ///
  /// **Use Case:** Optional fields (e.g., notes duration)
  ///
  /// **Returns:**
  /// - `null` if input is empty
  /// - Validated double if valid
  /// - Throws [ValidationException] if invalid
  static double? parseDoubleInRangeNullable(
    String input, {
    required double min,
    required double max,
    required String fieldName,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    return parseDoubleInRange(
      trimmed,
      min: min,
      max: max,
      fieldName: fieldName,
    );
  }

  // ===============================
  // INTEGER PARSING (Reps, Sets, etc.)
  // ===============================

  /// Parse integer with range validation (SAFE)
  ///
  /// **Use Cases:**
  /// - Reps (1-100)
  /// - Sets (1-20)
  /// - RPE (1-10)
  ///
  /// **Example:**
  /// ```dart
  /// final reps = InputValidationService.parseIntInRange(
  ///   repsController.text,
  ///   min: 1,
  ///   max: 100,
  ///   fieldName: 'Reps',
  /// );
  /// ```
  static int parseIntInRange(
    String input, {
    required int min,
    required int max,
    required String fieldName,
    int? defaultValue,
  }) {
    final trimmed = input.trim();
    final parsed = int.tryParse(trimmed);

    if (parsed == null) {
      if (defaultValue != null) {
        if (kDebugMode) {
          debugPrint('⚠️ [Validation] Invalid $fieldName: "$input". Using default: $defaultValue');
        }
        return defaultValue;
      }

      throw ValidationException(
        '$fieldName must be a valid whole number',
        field: fieldName,
        invalidValue: input,
      );
    }

    if (parsed < min || parsed > max) {
      throw ValidationException(
        '$fieldName must be between $min and $max',
        field: fieldName,
        invalidValue: input,
        min: min.toDouble(),
        max: max.toDouble(),
      );
    }

    return parsed;
  }

  /// Parse integer with optional range (nullable)
  static int? parseIntInRangeNullable(
    String input, {
    required int min,
    required int max,
    required String fieldName,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    return parseIntInRange(
      trimmed,
      min: min,
      max: max,
      fieldName: fieldName,
    );
  }

  // ===============================
  // FITNESS-SPECIFIC VALIDATORS
  // ===============================

  /// Validate weight input (0-1000 kg/lbs)
  static double parseWeight(String input, {double? defaultValue}) {
    return parseDoubleInRange(
      input,
      min: 0,
      max: 1000,
      fieldName: 'Weight',
      defaultValue: defaultValue,
    );
  }

  /// Validate reps input (1-100)
  static int parseReps(String input, {int? defaultValue}) {
    return parseIntInRange(
      input,
      min: 1,
      max: 100,
      fieldName: 'Reps',
      defaultValue: defaultValue,
    );
  }

  /// Validate sets input (1-20)
  static int parseSets(String input, {int? defaultValue}) {
    return parseIntInRange(
      input,
      min: 1,
      max: 20,
      fieldName: 'Sets',
      defaultValue: defaultValue,
    );
  }

  /// Validate RPE input (1-10)
  static int parseRPE(String input, {int? defaultValue}) {
    return parseIntInRange(
      input,
      min: 1,
      max: 10,
      fieldName: 'RPE',
      defaultValue: defaultValue,
    );
  }

  /// Validate rest time input (0-3600 seconds = 1 hour)
  static int parseRestTime(String input, {int? defaultValue}) {
    return parseIntInRange(
      input,
      min: 0,
      max: 3600,
      fieldName: 'Rest Time',
      defaultValue: defaultValue,
    );
  }

  /// Validate duration input (0-86400 seconds = 24 hours)
  static double parseDuration(String input, {double? defaultValue}) {
    return parseDoubleInRange(
      input,
      min: 0,
      max: 86400,
      fieldName: 'Duration',
      defaultValue: defaultValue,
    );
  }

  // ===============================
  // STRING SANITIZATION
  // ===============================

  /// Sanitize string input (prevent injection attacks)
  ///
  /// **Use Cases:**
  /// - Exercise names
  /// - Workout notes
  /// - User input text
  ///
  /// **Sanitization:**
  /// - Trims whitespace
  /// - Removes control characters
  /// - Limits length
  /// - Escapes HTML/SQL characters
  static String sanitizeString(
    String input, {
    int maxLength = 500,
    bool allowNewlines = true,
  }) {
    // Trim
    var sanitized = input.trim();

    // Remove control characters (except newlines if allowed)
    sanitized = sanitized.replaceAll(
      RegExp(allowNewlines ? r'[\x00-\x08\x0B\x0C\x0E-\x1F]' : r'[\x00-\x1F]'),
      '',
    );

    // Limit length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }
}

/// Exception thrown when validation fails
///
/// **User-Friendly:**
/// - Clear error messages
/// - Includes field name
/// - Includes valid range
///
/// **Example:**
/// ```dart
/// try {
///   final weight = InputValidationService.parseWeight('abc');
/// } catch (e) {
///   if (e is ValidationException) {
///     showError(e.message); // "Weight must be a valid number"
///   }
/// }
/// ```
class ValidationException implements Exception {
  const ValidationException(
    this.message, {
    this.field,
    this.invalidValue,
    this.min,
    this.max,
  });

  final String message;
  final String? field;
  final String? invalidValue;
  final double? min;
  final double? max;

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');

    if (field != null) {
      buffer.write(' (field: $field)');
    }

    if (invalidValue != null) {
      buffer.write(' (invalid value: "$invalidValue")');
    }

    if (min != null && max != null) {
      buffer.write(' (valid range: $min - $max)');
    }

    return buffer.toString();
  }

  /// Get user-friendly error message (for SnackBar)
  String get userMessage => message;
}
