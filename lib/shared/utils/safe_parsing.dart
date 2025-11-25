/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/utils
/// 🎯 Feature: parsing_safety
/// 🔧 Type: utility
///
/// SAFE PARSING UTILITIES
/// Prevents FormatException crashes from invalid user data or corrupted database values
///
/// **Why This Exists**:
/// - November 2024: App crashed with `FormatException: Invalid radix-16 number FFblue`
/// - Root cause: `int.parse('FFblue', radix: 16)` without validation
/// - Solution: Safe parsing with fallback values
///
/// **Usage**:
/// ```dart
/// // ✅ SAFE - Won't crash on invalid input
/// final color = parseColorSafe('#2196F3', fallback: context.colors.primary);
/// final age = parseIntSafe(userInput, fallback: 0);
/// final date = parseDateTimeSafe(jsonDate, fallback: DateTime.now());
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Parse color from hex string with fallback
///
/// Supports:
/// - Hex codes: "#2196F3", "2196F3"
/// - Named colors: "blue", "red", "green", etc.
/// - Invalid input → fallback color
///
/// **Example**:
/// ```dart
/// // Valid hex
/// final blue = parseColorSafe('#2196F3'); // → Material Blue 500
///
/// // Named color (legacy support)
/// final red = parseColorSafe('red'); // → Material Red 500
///
/// // Invalid input → fallback
/// final invalid = parseColorSafe('invalid', fallback: context.colors.surfaceVariant); // → grey
/// ```
Color parseColorSafe(
  String? colorString, {
  Color fallback = const Color(0xFF2196F3), // Material Blue 500
}) {
  if (colorString == null || colorString.isEmpty) return fallback;

  // Handle named colors (legacy support for existing databases)
  final namedColors = {
    'blue': '2196F3', // Material Blue 500
    'red': 'F44336', // Material Red 500
    'green': '4CAF50', // Material Green 500
    'purple': '9C27B0', // Material Purple 500
    'orange': 'FF9800', // Material Orange 500
    'teal': '009688', // Material Teal 500
    'pink': 'E91E63', // Material Pink 500
    'indigo': '3F51B5', // Material Indigo 500
  };

  // Convert named color to hex if needed
  final hexColor =
      namedColors[colorString.toLowerCase()] ?? colorString;

  // Parse hex color
  try {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseColorSafe: Invalid color "$colorString", using fallback');
    }
    return fallback;
  }
}

/// Parse integer from string with fallback
///
/// **Example**:
/// ```dart
/// // Valid input
/// final age = parseIntSafe('25'); // → 25
///
/// // Invalid input → fallback
/// final invalid = parseIntSafe('abc', fallback: 0); // → 0
///
/// // Null → fallback
/// final nullValue = parseIntSafe(null, fallback: -1); // → -1
/// ```
int parseIntSafe(
  dynamic value, {
  int fallback = 0,
}) {
  if (value == null) return fallback;

  try {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    return fallback;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseIntSafe: Invalid int "$value", using fallback');
    }
    return fallback;
  }
}

/// Parse double from string with fallback
///
/// **Example**:
/// ```dart
/// // Valid input
/// final weight = parseDoubleSafe('75.5'); // → 75.5
///
/// // Invalid input → fallback
/// final invalid = parseDoubleSafe('abc', fallback: 0.0); // → 0.0
///
/// // Range validation
/// final clamped = parseDoubleSafe('150', min: 0, max: 100); // → 100.0
/// ```
double parseDoubleSafe(
  dynamic value, {
  double fallback = 0.0,
  double? min,
  double? max,
}) {
  if (value == null) return fallback;

  try {
    double result;
    if (value is double) {
      result = value;
    } else if (value is int) {
      result = value.toDouble();
    } else if (value is String) {
      result = double.parse(value);
    } else {
      return fallback;
    }

    // Apply min/max constraints if specified
    if (min != null && result < min) return min;
    if (max != null && result > max) return max;

    return result;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseDoubleSafe: Invalid double "$value", using fallback');
    }
    return fallback;
  }
}

/// Parse DateTime from string with fallback
///
/// Supports:
/// - ISO 8601: "2024-01-15T10:30:00.000Z"
/// - Date only: "2024-01-15"
/// - Invalid input → fallback
///
/// **Example**:
/// ```dart
/// // Valid ISO 8601
/// final date = parseDateTimeSafe('2024-01-15T10:30:00.000Z');
///
/// // Invalid → fallback to now
/// final invalid = parseDateTimeSafe('invalid'); // → DateTime.now()
///
/// // Custom fallback
/// final old = parseDateTimeSafe(null, fallback: DateTime(2000, 1, 1));
/// ```
DateTime parseDateTimeSafe(
  dynamic value, {
  DateTime? fallback,
}) {
  final defaultFallback = fallback ?? DateTime.now();

  if (value == null) return defaultFallback;

  try {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return defaultFallback;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseDateTimeSafe: Invalid DateTime "$value", using fallback');
    }
    return defaultFallback;
  }
}

/// Parse date from "YYYY-MM-DD" string to DateTime with fallback
///
/// **Example**:
/// ```dart
/// // Valid date string
/// final date = parseDateFromString('2024-01-15'); // → DateTime(2024, 1, 15)
///
/// // Invalid → fallback to today
/// final invalid = parseDateFromString('invalid'); // → today
/// ```
DateTime parseDateFromString(
  String? dateString, {
  DateTime? fallback,
}) {
  final defaultFallback = fallback ?? DateTime.now();

  if (dateString == null || dateString.isEmpty) return defaultFallback;

  try {
    final parts = dateString.split('-');
    if (parts.length != 3) return defaultFallback;

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    return DateTime(year, month, day);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseDateFromString: Invalid date "$dateString", using fallback');
    }
    return defaultFallback;
  }
}

/// Parse boolean from dynamic value with fallback
///
/// **Example**:
/// ```dart
/// // Valid inputs
/// parseBoolSafe(true); // → true
/// parseBoolSafe('true'); // → true
/// parseBoolSafe(1); // → true
/// parseBoolSafe('yes'); // → true
///
/// // Invalid → fallback
/// parseBoolSafe('invalid', fallback: false); // → false
/// ```
bool parseBoolSafe(
  dynamic value, {
  bool fallback = false,
}) {
  if (value == null) return fallback;

  try {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') return true;
      if (lower == 'false' || lower == 'no' || lower == '0') return false;
    }
    return fallback;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseBoolSafe: Invalid bool "$value", using fallback');
    }
    return fallback;
  }
}

/// Parse enum from string with fallback
///
/// **Example**:
/// ```dart
/// enum Status { pending, active, completed }
///
/// // Valid enum string
/// final status = parseEnumSafe(
///   'active',
///   Status.values,
///   fallback: Status.pending,
/// ); // → Status.active
///
/// // Invalid → fallback
/// final invalid = parseEnumSafe(
///   'invalid',
///   Status.values,
///   fallback: Status.pending,
/// ); // → Status.pending
/// ```
T parseEnumSafe<T>(
  String? value,
  List<T> enumValues, {
  required T fallback,
}) {
  if (value == null || value.isEmpty) return fallback;

  try {
    return enumValues.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => fallback,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ parseEnumSafe: Invalid enum "$value", using fallback');
    }
    return fallback;
  }
}
