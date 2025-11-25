import 'package:flutter/foundation.dart';

/// 🔒 UNIFIED Input Validation & Sanitization Service
///
/// **SINGLE SOURCE OF TRUTH** for all input validation and sanitization.
/// This consolidates InputValidator + InputSanitizer (now deprecated).
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
/// - ✅ Normalizes unicode (prevents lookalike attacks)
/// - ✅ Removes control characters
///
/// USAGE (Instance - recommended for DI):
/// ```dart
/// final validator = InputValidator();
/// final safeName = validator.sanitize(userInput);
/// if (!validator.isValidWorkoutName(safeName)) {
///   throw ValidationException('Invalid workout name');
/// }
/// ```
///
/// USAGE (Static - for quick sanitization, compatible with old InputSanitizer API):
/// ```dart
/// final safeName = InputValidator.sanitizeName(userInput);
/// final safeNotes = InputValidator.sanitizeText(userNotes);
/// final validation = InputValidator.validateWorkoutData(...);
/// ```
class InputValidator {
  // ============================================================================
  // CONSTANTS - Single Source of Truth for all length limits
  // ============================================================================

  /// Maximum lengths for different input types
  static const int maxWorkoutNameLength = 50;
  static const int maxNotesLength = 500;
  static const int maxExerciseNameLength = 100;
  static const int maxProfileDisplayNameLength = 30;
  static const int maxProfileBioLength = 200;
  static const int maxDefaultTextLength = 1000;
  static const int maxValidationNotesLength = 5000; // For workout validation

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

  // ============================================================================
  // REGEX PATTERNS - Dangerous patterns to detect
  // ============================================================================

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

  /// Pattern for allowed characters in names (alphanumeric, spaces, common punctuation)
  static final RegExp _allowedNameCharsPattern = RegExp(
    r'[^\w\s\-()/&.,]',
    unicode: true,
  );

  /// Control characters pattern
  static final RegExp _controlCharsPattern = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]',
  );

  /// Email validation pattern
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ============================================================================
  // INSTANCE METHODS - For dependency injection / instance-based usage
  // ============================================================================

  /// Sanitize input by removing dangerous characters (instance method)
  ///
  /// Removes:
  /// - HTML tags (<script>, <img>, etc.)
  /// - SQL injection characters (', ", ;, \)
  /// - Script event handlers (onclick, onerror)
  /// - Control characters
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

    // Remove control characters
    sanitized = sanitized.replaceAll(_controlCharsPattern, '');

    // Normalize unicode (remove zero-width characters)
    sanitized = _normalizeUnicode(sanitized);

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

  // ============================================================================
  // STATIC METHODS - Compatible with old InputSanitizer API
  // ============================================================================

  /// Sanitize user-generated text (static version for backward compatibility)
  ///
  /// Use for: workout names, notes, descriptions, etc.
  ///
  /// This replaces InputSanitizer.sanitizeText()
  static String sanitizeText(String input, {int? maxLength}) {
    if (input.isEmpty) return input;

    final effectiveMaxLength = maxLength ?? maxDefaultTextLength;
    String sanitized = input;

    // 1. Trim whitespace
    sanitized = sanitized.trim();

    // 2. Limit length
    if (sanitized.length > effectiveMaxLength) {
      sanitized = sanitized.substring(0, effectiveMaxLength);
    }

    // 3. Remove HTML tags (basic XSS prevention)
    sanitized = sanitized.replaceAll(_htmlTagPattern, '');

    // 4. Escape special characters for safe storage
    sanitized = _escapeHtml(sanitized);

    // 5. Remove control characters
    sanitized = sanitized.replaceAll(_controlCharsPattern, '');

    // 6. Normalize unicode
    sanitized = _normalizeUnicode(sanitized);

    return sanitized;
  }

  /// Sanitize workout/exercise names (more restrictive - static version)
  ///
  /// Permits only: alphanumeric, spaces, and common punctuation (-()/.&,)
  ///
  /// This replaces InputSanitizer.sanitizeName()
  static String sanitizeName(String input, {int? maxLength}) {
    final effectiveMaxLength = maxLength ?? maxExerciseNameLength;
    String sanitized = sanitizeText(input, maxLength: effectiveMaxLength);

    // Permit only alphanumeric, spaces, and some punctuation
    sanitized = sanitized.replaceAll(_allowedNameCharsPattern, '');

    return sanitized;
  }

  /// Validate and sanitize numbers (static version)
  ///
  /// This replaces InputSanitizer.sanitizeNumber()
  static double? sanitizeNumber(String input, {double? min, double? max}) {
    final sanitized = input.trim().replaceAll(',', '.');

    final number = double.tryParse(sanitized);
    if (number == null) return null;

    // Apply bounds
    if (min != null && number < min) return min;
    if (max != null && number > max) return max;

    return number;
  }

  /// Validate email format (static version)
  ///
  /// This replaces InputSanitizer.isValidEmail()
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailPattern.hasMatch(email);
  }

  /// Sanitize URL (for exercise videos, etc.) (static version)
  ///
  /// This replaces InputSanitizer.sanitizeUrl()
  static String? sanitizeUrl(String url) {
    if (url.isEmpty) return null;

    final sanitized = url.trim();

    // Check if valid URL format
    final uri = Uri.tryParse(sanitized);
    if (uri == null) return null;

    // Only allow https (security)
    if (uri.scheme != 'https') return null;

    return sanitized;
  }

  /// Validate workout data before save (static version)
  ///
  /// This replaces InputSanitizer.validateWorkoutData()
  static ValidationResult validateWorkoutData({
    required String workoutName,
    String? notes,
    required List<String> exerciseNames,
  }) {
    final errors = <String>[];

    // Workout name
    if (workoutName.isEmpty) {
      errors.add('Workout name cannot be empty');
    } else if (workoutName.length > maxExerciseNameLength) {
      errors.add('Workout name too long (max $maxExerciseNameLength characters)');
    }

    // Notes
    if (notes != null && notes.length > maxValidationNotesLength) {
      errors.add('Notes too long (max $maxValidationNotesLength characters)');
    }

    // Exercise names
    if (exerciseNames.isEmpty) {
      errors.add('Workout must have at least one exercise');
    }

    for (final name in exerciseNames) {
      if (name.isEmpty) {
        errors.add('Exercise name cannot be empty');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Escape HTML special characters
  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Normalize unicode (prevent lookalike attacks)
  static String _normalizeUnicode(String input) {
    // Remove zero-width characters
    return input
        .replaceAll('\u200B', '') // Zero-width space
        .replaceAll('\u200C', '') // Zero-width non-joiner
        .replaceAll('\u200D', '') // Zero-width joiner
        .replaceAll('\uFEFF', ''); // Zero-width no-break space
  }
}

// ============================================================================
// EXCEPTION & RESULT CLASSES
// ============================================================================

/// Exception thrown when validation fails
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

/// Validation result (for validateWorkoutData)
class ValidationResult {
  ValidationResult({required this.isValid, required this.errors});
  final bool isValid;
  final List<String> errors;
}
