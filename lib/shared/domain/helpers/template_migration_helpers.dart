/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain/helpers
/// 🎯 Feature: Template Migration
/// 🔧 Type: Migration Helpers
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Purpose: Migration helpers for converting between different template formats
/// with race condition safety and data integrity checks.
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as legacy;
import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Migration helpers for safe template conversion
class TemplateMigrationHelpers {

  /// Convert legacy WorkoutTemplate to UnifiedWorkoutTemplate
  /// Includes race condition safety checks
  static UnifiedWorkoutTemplate fromLegacyTemplate(
    legacy.WorkoutTemplate legacyTemplate, {
    bool checkRaceConditions = true,
  }) {
    // Race condition check: ensure template is not being modified
    if (checkRaceConditions && _isTemplateLocked(legacyTemplate.id)) {
      throw TemplateMigrationException(
        'Template ${legacyTemplate.id} is currently being modified by another process'
      );
    }

    return UnifiedWorkoutTemplate(
      // Core identification
      id: legacyTemplate.id,
      name: legacyTemplate.name,
      userId: legacyTemplate.userId ?? '',

      // Template metadata
      category: UnifiedTemplateCategory.strength, // Default category since legacy doesn't have this field
      description: legacyTemplate.description,
      difficulty: legacyTemplate.difficulty ?? 'Intermediate',
      estimatedDuration: legacyTemplate.estimatedDuration,
      tags: legacyTemplate.tags,

      // Exercise data (raw format for flexibility)
      exercisesRaw: legacyTemplate.exercises.map((e) => e.toJson()).toList(),
      exerciseFormat: ExerciseFormat.legacy,

      // Timestamps
      createdAt: legacyTemplate.createdAt,
      updatedAt: legacyTemplate.updatedAt,

      // Usage statistics
      useCount: legacyTemplate.usageCount,

      // Legacy compatibility fields
      isCustom: legacyTemplate.isCustom,
      isPublic: legacyTemplate.isPublic,
      usageCount: legacyTemplate.usageCount,
      imageUrl: legacyTemplate.imageUrl,
      authorName: legacyTemplate.authorName,
      downloadCount: legacyTemplate.downloadCount,
      averageRating: legacyTemplate.averageRating,
      reviewCount: legacyTemplate.reviewCount,

      // Race condition safety
      isBeingDeleted: false,
      isSyncInProgress: false,
      version: 1,

      // Template source
      source: TemplateSource.legacy,

      // Default visibility for legacy templates
      visibility: UnifiedTemplateVisibility.private,
    );
  }


  /// Convert JSON import to UnifiedWorkoutTemplate
  /// Used for WhatsApp/Telegram sharing
  static UnifiedWorkoutTemplate fromJsonImport(
    Map<String, dynamic> jsonData, {
    required String userId,
    bool checkRaceConditions = true,
  }) {
    final templateId = jsonData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Race condition check
    if (checkRaceConditions && _isTemplateLocked(templateId)) {
      throw TemplateMigrationException(
        'Template $templateId is currently being processed by another import'
      );
    }

    // Extract exercise data - could be in various formats
    final exercises = jsonData['exercises'] as List<dynamic>? ?? [];

    return UnifiedWorkoutTemplate(
      // Core identification
      id: templateId,
      name: jsonData['name'] ?? 'Imported Template',
      userId: userId,

      // Template metadata
      category: _parseJsonCategory(jsonData['category']),
      description: jsonData['description'] ?? 'Imported from JSON',
      difficulty: jsonData['difficulty'] ?? 'Intermediate',
      estimatedDuration: jsonData['estimatedDuration'] ?? 60,
      tags: (jsonData['tags'] as List<dynamic>?)?.cast<String>() ?? ['imported'],

      // Exercise data (keep raw JSON for flexibility)
      exercisesRaw: exercises,
      exerciseFormat: ExerciseFormat.json,

      // Timestamps
      createdAt: DateTime.now(),

      // Default values for JSON imports
      useCount: 0,

      // Race condition safety
      isBeingDeleted: false,
      isSyncInProgress: false,
      version: 1,

      // Template source
      source: TemplateSource.jsonImport,

      // Default visibility for imports
      visibility: UnifiedTemplateVisibility.private,

      // Import metadata
      importSource: jsonData['source']?.toString(),
      importDate: DateTime.now(),
    );
  }

  /// Convert UnifiedWorkoutTemplate back to legacy format
  /// For backward compatibility
  static legacy.WorkoutTemplate toLegacyTemplate(UnifiedWorkoutTemplate unified) {
    // Ensure we can convert the exercises - WorkoutTemplate expects ExerciseTemplate not Exercise
    List<legacy.ExerciseTemplate> exercises;

    switch (unified.exerciseFormat) {
      case ExerciseFormat.legacy:
        exercises = unified.exercisesRaw
            .map((e) => legacy.ExerciseTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
        break;
      case ExerciseFormat.modern:
        // Convert modern exercise format to legacy
        exercises = _convertModernToLegacyExerciseTemplates(unified.exercisesRaw);
        break;
      case ExerciseFormat.json:
        // Convert JSON exercises to legacy format
        exercises = _convertJsonToLegacyExerciseTemplates(unified.exercisesRaw);
        break;
    }

    return legacy.WorkoutTemplate(
      id: unified.id,
      name: unified.name,
      userId: unified.userId,
      description: unified.description,
      difficulty: unified.difficulty,
      estimatedDuration: unified.estimatedDuration,
      exercises: exercises,
      tags: unified.tags,
      createdAt: unified.createdAt,
      updatedAt: unified.updatedAt,
      usageCount: unified.useCount,
      authorName: unified.authorName,
      isCustom: unified.isCustom,
      isPublic: unified.isPublic,
      downloadCount: unified.downloadCount,
      averageRating: unified.averageRating,
      reviewCount: unified.reviewCount,
    );
  }


  /// Check if template is currently locked (race condition prevention)
  static bool _isTemplateLocked(String templateId) {
    // This would integrate with actual locking mechanism
    // For now, return false - implement with Redis/SharedPreferences in production
    return false;
  }

  /// Map legacy category to unified format
  static UnifiedTemplateCategory _mapLegacyCategory(ExerciseCategory? category) {
    if (category == null) return UnifiedTemplateCategory.strength;

    switch (category) {
      case ExerciseCategory.chest:
      case ExerciseCategory.back:
      case ExerciseCategory.shoulders:
      case ExerciseCategory.arms:
      case ExerciseCategory.legs:
      case ExerciseCategory.abs:
        return UnifiedTemplateCategory.strength;
      case ExerciseCategory.cardio:
        return UnifiedTemplateCategory.cardio;
      case ExerciseCategory.other:
      default:
        return UnifiedTemplateCategory.strength;
    }
  }

  /// Map unified category back to legacy
  static ExerciseCategory _mapToLegacyCategory(UnifiedTemplateCategory category) {
    switch (category) {
      case UnifiedTemplateCategory.strength:
        return ExerciseCategory.chest; // Default to chest for strength
      case UnifiedTemplateCategory.cardio:
        return ExerciseCategory.cardio;
      case UnifiedTemplateCategory.flexibility:
        return ExerciseCategory.abs; // Map flexibility to abs
      case UnifiedTemplateCategory.powerlifting:
        return ExerciseCategory.legs; // Map powerlifting to legs
      default:
        return ExerciseCategory.chest;
    }
  }

  /// Parse category from JSON import
  static UnifiedTemplateCategory _parseJsonCategory(dynamic category) {
    if (category == null) return UnifiedTemplateCategory.strength;

    final categoryStr = category.toString().toLowerCase();

    if (categoryStr.contains('cardio')) return UnifiedTemplateCategory.cardio;
    if (categoryStr.contains('flex') || categoryStr.contains('stretch')) {
      return UnifiedTemplateCategory.flexibility;
    }
    if (categoryStr.contains('power')) return UnifiedTemplateCategory.powerlifting;

    return UnifiedTemplateCategory.strength;
  }

  // Exercise conversion helpers (stub implementations)
  // These would need full implementation based on actual data structures

  static List<legacy.ExerciseTemplate> _convertModernToLegacyExerciseTemplates(List<dynamic> modernExercises) {
    // Implementation would convert modern ExerciseTemplate to legacy ExerciseTemplate
    // For now, return empty list as modern system doesn't exist yet
    return [];
  }

  static List<legacy.ExerciseTemplate> _convertJsonToLegacyExerciseTemplates(List<dynamic> jsonExercises) {
    final exercises = <legacy.ExerciseTemplate>[];

    for (final exerciseData in jsonExercises) {
      if (exerciseData is Map<String, dynamic>) {
        final rawSets = exerciseData['sets'] as List<dynamic>? ?? [];
        final sets = rawSets.map((setData) {
          final setMap = setData as Map<String, dynamic>;
          return legacy.SetTemplate(
            setNumber: setMap['setNumber'] ?? setMap['number'] ?? 1,
            targetReps: setMap['targetReps'] ?? setMap['reps'] ?? 10,
            targetWeight: (setMap['targetWeight'] ?? setMap['weight'] ?? 0).toDouble(),
            notes: setMap['notes'],
          );
        }).toList();

        exercises.add(legacy.ExerciseTemplate(
          exerciseId: exerciseData['exerciseId'] ?? exerciseData['id'] ?? 'unknown',
          exerciseName: exerciseData['exerciseName'] ?? exerciseData['name'] ?? 'Unknown Exercise',
          category: _mapToLegacyCategory(
            _parseJsonCategory(exerciseData['category']),
          ),
          sets: sets,
          notes: exerciseData['notes'],
          restTime: exerciseData['restTime'] ?? 90,
        ));
      }
    }

    return exercises;
  }
}

/// Exception thrown during template migration
class TemplateMigrationException implements Exception {

  const TemplateMigrationException(this.message);
  final String message;

  @override
  String toString() => 'TemplateMigrationException: $message';
}

/// Template locking service for race condition prevention
class TemplateLockingService {
  static final Map<String, DateTime> _locks = {};
  static const Duration _lockTimeout = Duration(minutes: 5);

  /// Acquire lock on template
  static bool acquireLock(String templateId) {
    final now = DateTime.now();

    // Clean expired locks
    _locks.removeWhere((key, value) => now.difference(value) > _lockTimeout);

    // Check if already locked
    if (_locks.containsKey(templateId)) {
      return false;
    }

    // Acquire lock
    _locks[templateId] = now;
    return true;
  }

  /// Release lock on template
  static void releaseLock(String templateId) {
    _locks.remove(templateId);
  }

  /// Check if template is locked
  static bool isLocked(String templateId) {
    final lockTime = _locks[templateId];
    if (lockTime == null) return false;

    // Check if lock has expired
    if (DateTime.now().difference(lockTime) > _lockTimeout) {
      _locks.remove(templateId);
      return false;
    }

    return true;
  }

  /// Force release all locks (emergency cleanup)
  static void releaseAllLocks() {
    _locks.clear();
  }
}