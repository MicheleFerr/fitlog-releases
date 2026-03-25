import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/validation/template_validator.dart';

/// Generates readable fallback names for workout templates.
class TemplateNameGenerator {
  static const String defaultFallbackName = 'Workout Template';

  static String generateFromExercises(
    List<Exercise> exercises, {
    String fallbackName = defaultFallbackName,
  }) {
    return generateFromExerciseNames(
      exercises.map((exercise) => exercise.name),
      fallbackName: fallbackName,
    );
  }

  static String generateFromTemplateExercises(
    List<ExerciseTemplate> exercises, {
    String fallbackName = defaultFallbackName,
  }) {
    return generateFromExerciseNames(
      exercises.map((exercise) => exercise.exerciseName),
      fallbackName: fallbackName,
    );
  }

  static String generateFromExerciseNames(
    Iterable<String> rawNames, {
    String fallbackName = defaultFallbackName,
  }) {
    final normalizedNames = <String>[];
    final seen = <String>{};

    for (final rawName in rawNames) {
      final normalized = _normalizeExerciseName(rawName);
      if (normalized.isEmpty) continue;

      final dedupeKey = normalized.toLowerCase();
      if (!seen.add(dedupeKey)) continue;

      normalizedNames.add(normalized);
      if (normalizedNames.length == 2) break;
    }

    if (normalizedNames.isEmpty) {
      final sanitizedFallback = TemplateValidator.sanitizeTemplateName(
        fallbackName,
      );
      return sanitizedFallback.isNotEmpty
          ? sanitizedFallback
          : defaultFallbackName;
    }

    final generatedName = normalizedNames.join(' + ');
    final sanitizedName = TemplateValidator.sanitizeTemplateName(generatedName);

    if (sanitizedName.isNotEmpty) {
      return sanitizedName;
    }

    final sanitizedFallback = TemplateValidator.sanitizeTemplateName(
      fallbackName,
    );
    return sanitizedFallback.isNotEmpty
        ? sanitizedFallback
        : defaultFallbackName;
  }

  static String _normalizeExerciseName(String rawName) {
    var normalized = rawName.trim();
    if (normalized.isEmpty) return '';

    normalized = normalized.replaceAll(
      RegExp(
        r'\s*[-–]\s*(drop\s*set|dropset|rest[\s-]?pause)$',
        caseSensitive: false,
      ),
      '',
    );

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return TemplateValidator.sanitizeTemplateName(normalized);
  }
}
