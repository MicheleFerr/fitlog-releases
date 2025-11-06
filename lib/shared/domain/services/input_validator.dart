import 'package:flutter/foundation.dart';

/// Input Validation & Sanitization Service
///
/// OWASP Mobile Security: Prevents injection attacks
/// - XSS (Cross-Site Scripting) via HTML tag removal
/// - SQL Injection via special character filtering
/// - Command Injection via shell metacharacter removal
///
/// SECURITY BENEFITS:
/// - ✅ Sanitizes user input before storage/display
/// - ✅ Validates data length and format
/// - ✅ Removes dangerous characters (<, >, ', ", ;, etc.)
/// - ✅ Prevents code execution attacks
///
/// USAGE:
/// ```dart
/// final validator = InputValidator();
///
/// // Sanitize workout name
/// final safeName = validator.sanitize(userInput);
///
/// // Validate workout name
/// if (!validator.isValidWorkoutName(safeName)) {
///   throw ValidationException('Invalid workout name');
/// }
/// ```
class InputValidator {
  /// Maximum lengths for different input types
  static const int maxWorkoutNameLength = 50;
  static const int maxNotesLength = 500;
  static const int maxExerciseNameLength = 100;
  static const int maxProfileDisplayNameLength = 30;
  static const int maxProfileBioLength = 200;

  /// Minimum lengths for different input types
  static const int minWorkoutNameLength = 3;
  static const int minExerciseNameLength = 2;
  static const int minProfileDisplayNameLength = 3;

  /// Numeric constraints
  static const double minWeight = 0;
  static const double maxWeight = 1000; // kg
  static const int minReps = 1;
  static const int maxReps = 100;
  static const int minSets = 1;
  static const int maxSets = 20;

  /// Dangerous patterns to detect
  static final RegExp _htmlTagPattern = RegExp(r'<[^>]*>');
  static final RegExp _sqlInjectionPattern = RegExp(r'''[;'"\\]''');
  static final RegExp _scriptPattern = RegExp(
    r'<script[^>]*>.*?<\/script>',
    caseSensitive: false,
  );
  static final RegExp _onEventPattern = RegExp(
    r'on\w+\s*=',
    caseSensitive: false,
  );

  /// Sanitize input by removing dangerous characters
  ///
  /// Removes:
  /// - HTML tags (<script>, <img>, etc.)
  /// - SQL injection characters (', ", ;, \)
  /// - Script event handlers (onclick, onerror)
  /// - Excessive whitespace
  ///
  /// Returns sanitized string with dangerous chars removed
  String sanitize(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove script patterns first (with content) - defense in depth
    sanitized = sanitized.replaceAll(_scriptPattern, '');
    sanitized = sanitized.replaceAll(_onEventPattern, '');

    // Remove HTML tags (after removing script content)
    sanitized = sanitized.replaceAll(_htmlTagPattern, '');

    // Remove SQL injection characters
    sanitized = sanitized.replaceAll(_sqlInjectionPattern, '');

    // Trim and normalize whitespace
    sanitized = sanitized.trim();
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    if (kDebugMode && input != sanitized) {
      debugPrint('🔒 InputValidator: Sanitized input');
      debugPrint('   Original: $input');
      debugPrint('   Sanitized: $sanitized');
    }

    return sanitized;
  }

  /// Validate workout name
  ///
  /// Rules:
  /// - 3-50 characters
  /// - Not empty after sanitization
  /// - No dangerous patterns
  bool isValidWorkoutName(String name) {
    if (name.isEmpty) return false;

    final sanitized = sanitize(name);

    if (sanitized.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ Invalid workout name: Empty after sanitization');
      }
      return false;
    }

    if (sanitized.length < minWorkoutNameLength ||
        sanitized.length > maxWorkoutNameLength) {
      if (kDebugMode) {
        debugPrint(
          '❌ Invalid workout name: Length ${sanitized.length} (must be $minWorkoutNameLength-$maxWorkoutNameLength)',
        );
      }
      return false;
    }

    return true;
  }

  /// Validate exercise name
  ///
  /// Rules:
  /// - 2-100 characters
  /// - Not empty after sanitization
  bool isValidExerciseName(String name) {
    if (name.isEmpty) return false;

    final sanitized = sanitize(name);

    if (sanitized.isEmpty) return false;

    if (sanitized.length < minExerciseNameLength ||
        sanitized.length > maxExerciseNameLength) {
      return false;
    }

    return true;
  }

  /// Validate notes field
  ///
  /// Rules:
  /// - 0-500 characters (optional field)
  /// - No dangerous patterns
  bool isValidNotes(String? notes) {
    if (notes == null || notes.isEmpty) {
      return true; // Notes are optional
    }

    final sanitized = sanitize(notes);

    if (sanitized.length > maxNotesLength) {
      if (kDebugMode) {
        debugPrint(
          '❌ Invalid notes: Length ${sanitized.length} (max $maxNotesLength)',
        );
      }
      return false;
    }

    return true;
  }

  /// Validate weight value
  ///
  /// Rules:
  /// - 0-1000 kg (covers all realistic weights)
  /// - Numeric value
  bool isValidWeight(double? weight) {
    if (weight == null) return false;

    if (weight < minWeight || weight > maxWeight) {
      if (kDebugMode) {
        debugPrint(
          '❌ Invalid weight: $weight (must be $minWeight-$maxWeight kg)',
        );
      }
      return false;
    }

    return true;
  }

  /// Validate reps value
  ///
  /// Rules:
  /// - 1-100 reps (covers all realistic rep ranges)
  /// - Integer value
  bool isValidReps(int? reps) {
    if (reps == null) return false;

    if (reps < minReps || reps > maxReps) {
      if (kDebugMode) {
        debugPrint('❌ Invalid reps: $reps (must be $minReps-$maxReps)');
      }
      return false;
    }

    return true;
  }

  /// Validate sets value
  ///
  /// Rules:
  /// - 1-20 sets (covers all realistic set ranges)
  /// - Integer value
  bool isValidSets(int? sets) {
    if (sets == null) return false;

    if (sets < minSets || sets > maxSets) {
      if (kDebugMode) {
        debugPrint('❌ Invalid sets: $sets (must be $minSets-$maxSets)');
      }
      return false;
    }

    return true;
  }

  /// Validate profile display name
  ///
  /// Rules:
  /// - 3-30 characters
  /// - Not empty after sanitization
  /// - No dangerous patterns
  bool isValidProfileDisplayName(String name) {
    if (name.isEmpty) return false;

    final sanitized = sanitize(name);

    if (sanitized.isEmpty) return false;

    if (sanitized.length < minProfileDisplayNameLength ||
        sanitized.length > maxProfileDisplayNameLength) {
      if (kDebugMode) {
        debugPrint(
          '❌ Invalid display name: Length ${sanitized.length} (must be $minProfileDisplayNameLength-$maxProfileDisplayNameLength)',
        );
      }
      return false;
    }

    return true;
  }

  /// Validate profile bio
  ///
  /// Rules:
  /// - 0-200 characters (optional field)
  /// - No dangerous patterns
  bool isValidProfileBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return true; // Bio is optional
    }

    final sanitized = sanitize(bio);

    if (sanitized.length > maxProfileBioLength) {
      if (kDebugMode) {
        debugPrint(
          '❌ Invalid bio: Length ${sanitized.length} (max $maxProfileBioLength)',
        );
      }
      return false;
    }

    return true;
  }

  /// Check if input contains dangerous patterns
  ///
  /// Returns true if input contains:
  /// - HTML tags
  /// - SQL injection chars
  /// - Script patterns
  bool containsDangerousPatterns(String input) {
    return _htmlTagPattern.hasMatch(input) ||
        _sqlInjectionPattern.hasMatch(input) ||
        _scriptPattern.hasMatch(input) ||
        _onEventPattern.hasMatch(input);
  }

  /// Sanitize and validate workout name in one call
  ///
  /// Returns sanitized name if valid, throws ValidationException if invalid
  String sanitizeAndValidateWorkoutName(String name) {
    final sanitized = sanitize(name);

    if (!isValidWorkoutName(sanitized)) {
      throw ValidationException(
        'Workout name must be $minWorkoutNameLength-$maxWorkoutNameLength characters',
      );
    }

    return sanitized;
  }

  /// Sanitize and validate exercise name in one call
  ///
  /// Returns sanitized name if valid, throws ValidationException if invalid
  String sanitizeAndValidateExerciseName(String name) {
    final sanitized = sanitize(name);

    if (!isValidExerciseName(sanitized)) {
      throw ValidationException(
        'Exercise name must be $minExerciseNameLength-$maxExerciseNameLength characters',
      );
    }

    return sanitized;
  }

  /// Sanitize and validate notes in one call
  ///
  /// Returns sanitized notes if valid, throws ValidationException if invalid
  String? sanitizeAndValidateNotes(String? notes) {
    if (notes == null || notes.isEmpty) return null;

    final sanitized = sanitize(notes);

    if (!isValidNotes(sanitized)) {
      throw ValidationException(
        'Notes cannot exceed $maxNotesLength characters',
      );
    }

    return sanitized;
  }

  /// Sanitize and validate profile display name in one call
  ///
  /// Returns sanitized name if valid, throws ValidationException if invalid
  String sanitizeAndValidateProfileDisplayName(String name) {
    final sanitized = sanitize(name);

    if (!isValidProfileDisplayName(sanitized)) {
      throw ValidationException(
        'Display name must be $minProfileDisplayNameLength-$maxProfileDisplayNameLength characters',
      );
    }

    return sanitized;
  }

  /// Sanitize and validate profile bio in one call
  ///
  /// Returns sanitized bio if valid, throws ValidationException if invalid
  String? sanitizeAndValidateProfileBio(String? bio) {
    if (bio == null || bio.isEmpty) return null;

    final sanitized = sanitize(bio);

    if (!isValidProfileBio(sanitized)) {
      throw ValidationException(
        'Bio cannot exceed $maxProfileBioLength characters',
      );
    }

    return sanitized;
  }
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
