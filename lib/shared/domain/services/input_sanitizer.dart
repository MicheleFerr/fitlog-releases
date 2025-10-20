/// 🔒 Input Sanitizer Service
///
/// Previene XSS, injection attacks e valida input utente.
/// Usare SEMPRE prima di salvare contenuto generato da utenti.
library;

class InputSanitizer {
  /// Sanitize user-generated text (workout names, notes, etc.)
  static String sanitizeText(String input, {int maxLength = 1000}) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // 1. Trim whitespace
    sanitized = sanitized.trim();

    // 2. Limita lunghezza
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    // 3. Remove HTML tags (basic XSS prevention)
    sanitized = _stripHtmlTags(sanitized);

    // 4. Escape special characters
    sanitized = _escapeHtml(sanitized);

    // 5. Remove control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // 6. Normalize unicode
    sanitized = _normalizeUnicode(sanitized);

    return sanitized;
  }

  /// Sanitize workout/exercise names (più restrittivo)
  static String sanitizeName(String input, {int maxLength = 100}) {
    String sanitized = sanitizeText(input, maxLength: maxLength);

    // Permetti solo caratteri alfanumerici, spazi, e alcuni simboli
    // In character class [], non serve escape per: ()/.&,
    // Solo - deve essere escaped o messo all'inizio/fine
    sanitized = sanitized.replaceAll(
      RegExp(r'[^\w\s\-()/&.,]', unicode: true),
      '',
    );

    return sanitized;
  }

  /// Validate and sanitize numbers
  static double? sanitizeNumber(String input, {double? min, double? max}) {
    final sanitized = input.trim().replaceAll(',', '.');

    final number = double.tryParse(sanitized);
    if (number == null) return null;

    // Apply bounds
    if (min != null && number < min) return min;
    if (max != null && number > max) return max;

    return number;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Sanitize URL (per esercizi con video)
  static String? sanitizeUrl(String url) {
    if (url.isEmpty) return null;

    final sanitized = url.trim();

    // Check if valid URL format
    final uri = Uri.tryParse(sanitized);
    if (uri == null) return null;

    // Only allow https (security)
    if (uri.scheme != 'https') return null;

    // Whitelist allowed domains (opzionale)
    // final allowedDomains = ['youtube.com', 'youtu.be', 'vimeo.com'];
    // if (!allowedDomains.any((domain) => uri.host.endsWith(domain))) {
    //   return null;
    // }

    return sanitized;
  }

  /// Strip HTML tags
  static String _stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

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
    // Basic normalization - rimuovi zero-width characters
    return input
        .replaceAll('\u200B', '') // Zero-width space
        .replaceAll('\u200C', '') // Zero-width non-joiner
        .replaceAll('\u200D', '') // Zero-width joiner
        .replaceAll('\uFEFF', ''); // Zero-width no-break space
  }

  /// Validate workout data before save
  static ValidationResult validateWorkoutData({
    required String workoutName,
    String? notes,
    required List<String> exerciseNames,
  }) {
    final errors = <String>[];

    // Workout name
    if (workoutName.isEmpty) {
      errors.add('Workout name cannot be empty');
    } else if (workoutName.length > 100) {
      errors.add('Workout name too long (max 100 characters)');
    }

    // Notes
    if (notes != null && notes.length > 5000) {
      errors.add('Notes too long (max 5000 characters)');
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
}

/// Validation result
class ValidationResult {

  ValidationResult({required this.isValid, required this.errors});
  final bool isValid;
  final List<String> errors;
}

/// Example usage:
///
/// ```dart
/// // Sanitize workout name
/// final workoutName = InputSanitizer.sanitizeName(userInput);
///
/// // Sanitize notes
/// final notes = InputSanitizer.sanitizeText(userNotes);
///
/// // Validate before save
/// final validation = InputSanitizer.validateWorkoutData(
///   workoutName: workoutName,
///   notes: notes,
///   exerciseNames: exercises.map((e) => e.name).toList(),
/// );
///
/// if (!validation.isValid) {
///   // Show errors
///   SnackBarService.showError(context, validation.errors.join('\n'));
///   return;
/// }
///
/// // Safe to save
/// await repository.save(...);
/// ```
