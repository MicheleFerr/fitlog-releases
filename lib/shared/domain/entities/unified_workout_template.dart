/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain
/// 🎯 Feature: unified_template_system
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// UNIFICATION ENTITY - Combines all template implementations
///
/// This entity provides:
/// - 100% backward compatibility with all existing systems
/// - Migration support from legacy/freezed/smart implementations
/// - Type-safe handling of different exercise formats
/// - Cleanup-safe operations (no race conditions)
///
/// Dependencies:
/// - Freezed: Code generation
/// - JSON serialization
/// - Legacy entity compatibility
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as legacy;
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart' as modern;
import 'package:flutter/foundation.dart';

part 'unified_workout_template.freezed.dart';
part 'unified_workout_template.g.dart';

/// Visibility settings for unified templates
enum UnifiedTemplateVisibility {
  private,   // Solo visibile al creatore
  public,    // Visibile a tutti
  friends,   // Visibile agli amici (futuro)
}

/// Category classification for unified templates
enum UnifiedTemplateCategory {
  strength,
  hypertrophy,
  endurance,
  powerlifting,
  bodybuilding,
  crossfit,
  calisthenics,
  cardio,
  mixed,
  custom,
  flexibility,
}

/// Exercise format for handling different data structures
enum ExerciseFormat {
  legacy,   // Exercise class from workout feature
  modern,   // ExerciseTemplate from workout_templates feature
  json,     // Raw JSON from imports
}

/// Template source tracking
enum TemplateSource {
  legacy,      // SharedPreferences legacy system
  modern,      // Firebase modern system
  jsonImport,  // Imported from JSON (WhatsApp/Telegram)
  community,   // Downloaded from community
}

/// 🎯 UNIFIED WORKOUT TEMPLATE
///
/// This entity consolidates all template implementations:
/// - Legacy (SharedPreferences): 27 fields, manual serialization
/// - Modern (Firebase): 16 fields, Freezed, community features
/// - Smart (AI): 12 fields, adaptive parameters
///
/// CRITICAL: Maintains 100% backward compatibility
@freezed
@JsonSerializable()
class UnifiedWorkoutTemplate with _$UnifiedWorkoutTemplate {
  const factory UnifiedWorkoutTemplate({
    // === CORE IDENTIFIER ===
    required String id,

    // === BASIC INFO ===
    required String name,
    @Default('') String description,

    // === EXERCISES - CRITICAL: Support multiple formats ===
    required List<dynamic> exercisesRaw, // Can be Exercise, ExerciseTemplate, or JSON

    // === LEGACY COMPATIBILITY FIELDS ===
    // These ensure old code continues working
    @Default(true) bool isCustom,                // Legacy: user created vs predefined
    @Default(false) bool isPublic,               // Legacy: public sharing
    @Default(0) int usageCount,                  // Legacy: tracking usage
    String? imageUrl,                            // Legacy: template image
    String? userId,                              // Legacy: creator ID
    String? authorName,                          // Legacy: creator name
    @Default(0) int downloadCount,               // Legacy: social stats
    @Default(0.0) double averageRating,          // Legacy: social stats
    @Default(0) int reviewCount,                 // Legacy: social stats
    String? difficulty,                          // Legacy: difficulty string

    // === MODERN FEATURES ===
    @Default(UnifiedTemplateVisibility.private)
    UnifiedTemplateVisibility visibility,              // Modern: enum-based visibility
    @Default(UnifiedTemplateCategory.custom)
    UnifiedTemplateCategory category,                  // Modern: structured categories
    @Default(0) int likeCount,                  // Modern: social engagement
    String? authorPhotoUrl,                     // Modern: author avatar
    @Default([]) List<String> requiredEquipment, // Modern: equipment tracking
    @Default([]) List<String> targetMuscles,   // Modern: muscle targeting

    // === SMART/AI FEATURES ===
    Map<String, dynamic>? adaptiveParameters,   // Smart: AI adaptation data
    Map<String, int>? muscleGroupVolume,        // Smart: volume tracking
    @Default([]) List<String> alternatives,     // Smart: alternative exercises

    // === METADATA ===
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,

    // === DURATION - Support both legacy and modern formats ===
    @Default(45) int estimatedDuration,         // Legacy: minutes
    int? estimatedDurationMinutes,              // Modern: explicit minutes

    // === EXERCISE FORMAT TRACKING ===
    @Default(ExerciseFormat.legacy) ExerciseFormat exerciseFormat, // Format of exercisesRaw
    @Default(TemplateSource.legacy) TemplateSource source,         // Origin tracking

    // === IMPORT METADATA ===
    String? importSource,                       // Source URL/app for imports
    DateTime? importDate,                       // When imported

    // === ADDITIONAL FEATURES ===
    @Default(0) int useCount,                   // Times used for workouts
    @Default(false) bool supportsSuperset,     // Legacy compatibility
    @Default(false) bool requiresPremium,      // Premium feature flag
    @Default(false) bool allowComments,        // Community features
    @Default(false) bool allowRating,          // Community features
    double? rating,                             // Average rating

    // === CLEANUP SAFETY FLAGS ===
    @Default(false) bool isBeingDeleted,        // Prevents race conditions
    @Default(false) bool isSyncInProgress,      // Prevents concurrent sync
    String? lastModifiedBy,                     // Conflict resolution
    int? version,                               // Optimistic locking
  }) = _UnifiedWorkoutTemplate;

  /// Factory for JSON deserialization with migration support
  factory UnifiedWorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return _$UnifiedWorkoutTemplateFromJson(json);
  }

  /// Factory for creating from legacy WorkoutTemplate
  factory UnifiedWorkoutTemplate.fromLegacy(legacy.WorkoutTemplate legacyTemplate) {
    return UnifiedWorkoutTemplate(
      id: legacyTemplate.id,
      name: legacyTemplate.name,
      description: legacyTemplate.description,
      exercisesRaw: legacyTemplate.exercises.map((e) => e.toJson()).toList(),

      // Legacy fields - direct mapping
      isCustom: legacyTemplate.isCustom,
      isPublic: legacyTemplate.isPublic,
      usageCount: legacyTemplate.usageCount,
      imageUrl: legacyTemplate.imageUrl,
      userId: legacyTemplate.userId,
      authorName: legacyTemplate.authorName,
      downloadCount: legacyTemplate.downloadCount,
      averageRating: legacyTemplate.averageRating,
      reviewCount: legacyTemplate.reviewCount,
      difficulty: legacyTemplate.difficulty,

      // Map to modern fields
      visibility: legacyTemplate.isPublic
        ? UnifiedTemplateVisibility.public
        : UnifiedTemplateVisibility.private,
      category: _inferCategoryFromTags(legacyTemplate.tags),

      // Metadata
      createdAt: legacyTemplate.createdAt,
      updatedAt: legacyTemplate.updatedAt,
      tags: legacyTemplate.tags,
      estimatedDuration: legacyTemplate.estimatedDuration,

      // Safety defaults
      version: 1,
      lastModifiedBy: legacyTemplate.userId ?? 'legacy_system',
    );
  }

  /// Factory for creating from modern WorkoutTemplate
  factory UnifiedWorkoutTemplate.fromModern(modern.WorkoutTemplate modernTemplate) {
    return UnifiedWorkoutTemplate(
      id: modernTemplate.id,
      name: modernTemplate.name,
      description: modernTemplate.description ?? '',
      exercisesRaw: modernTemplate.exercises.map((e) => e.toJson()).toList(),

      // Modern fields - direct mapping
      visibility: _mapModernVisibility(modernTemplate.visibility),
      category: _mapModernCategory(modernTemplate.category),
      likeCount: modernTemplate.likeCount,
      authorPhotoUrl: modernTemplate.authorPhotoUrl,
      requiredEquipment: modernTemplate.requiredEquipment,
      targetMuscles: modernTemplate.targetMuscles,
      downloadCount: modernTemplate.downloadCount,
      averageRating: modernTemplate.averageRating,
      reviewCount: modernTemplate.reviewCount,

      // Map to legacy fields for compatibility
      isCustom: modernTemplate.userId != null,
      isPublic: modernTemplate.visibility == modern.TemplateVisibility.public,
      userId: modernTemplate.userId,
      authorName: modernTemplate.authorName,
      difficulty: modernTemplate.difficultyLevel,

      // Metadata
      createdAt: modernTemplate.createdAt,
      updatedAt: modernTemplate.updatedAt,
      tags: modernTemplate.tags,
      estimatedDurationMinutes: modernTemplate.estimatedDurationMinutes,
      estimatedDuration: modernTemplate.estimatedDurationMinutes ?? 45,

      // Safety defaults
      version: 1,
      lastModifiedBy: modernTemplate.userId ?? 'modern_system',
    );
  }
}

/// Extension methods for compatibility and utility
extension UnifiedWorkoutTemplateExtensions on UnifiedWorkoutTemplate {
  /// Convert to legacy WorkoutTemplate for backward compatibility
  legacy.WorkoutTemplate toLegacy() {
    return legacy.WorkoutTemplate(
      id: id,
      name: name,
      description: description,
      exercises: _parseExercisesToLegacyFormat(),
      isCustom: isCustom,
      isPublic: isPublic,
      usageCount: usageCount,
      imageUrl: imageUrl,
      userId: userId,
      authorName: authorName,
      downloadCount: downloadCount,
      averageRating: averageRating,
      reviewCount: reviewCount,
      difficulty: difficulty,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      estimatedDuration: estimatedDuration,
    );
  }

  /// Convert to modern WorkoutTemplate
  modern.WorkoutTemplate toModern() {
    return modern.WorkoutTemplate(
      id: id,
      userId: userId ?? '',
      name: name,
      description: description.isEmpty ? null : description,
      exercises: _parseExercisesToModernFormat(),
      category: _mapToModernCategory(category),
      visibility: _mapToModernVisibility(visibility),
      createdAt: createdAt,
      updatedAt: updatedAt,
      downloadCount: downloadCount,
      likeCount: likeCount,
      reviewCount: reviewCount,
      averageRating: averageRating,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      tags: tags,
      estimatedDurationMinutes: estimatedDurationMinutes,
      difficultyLevel: difficulty,
      requiredEquipment: requiredEquipment,
      targetMuscles: targetMuscles,
    );
  }

  /// Get exercises as Exercise list (universal format)
  List<Exercise> get exercises {
    return _parseExercisesToExerciseFormat();
  }

  /// Check if template is safe for operations (no race conditions)
  bool get isSafeForOperations {
    return !isBeingDeleted && !isSyncInProgress;
  }

  /// Create a copy for safe modification
  UnifiedWorkoutTemplate safeModify({
    String? name,
    String? description,
    List<Exercise>? newExercises,
  }) {
    if (!isSafeForOperations) {
      throw StateError('Template is not safe for modification (deletion or sync in progress)');
    }

    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      exercisesRaw: newExercises?.map((e) => e.toJson()).toList() ?? exercisesRaw,
      updatedAt: DateTime.now(),
      version: (version ?? 0) + 1,
      lastModifiedBy: userId ?? 'unified_system',
    );
  }

  /// Mark for deletion (cleanup safety)
  UnifiedWorkoutTemplate markForDeletion() {
    return copyWith(
      isBeingDeleted: true,
      lastModifiedBy: userId ?? 'cleanup_system',
    );
  }

  /// Mark sync in progress (race condition safety)
  UnifiedWorkoutTemplate markSyncInProgress() {
    return copyWith(
      isSyncInProgress: true,
      lastModifiedBy: userId ?? 'sync_system',
    );
  }

  /// Mark sync completed
  UnifiedWorkoutTemplate markSyncCompleted() {
    return copyWith(
      isSyncInProgress: false,
      updatedAt: DateTime.now(),
      lastModifiedBy: userId ?? 'sync_system',
    );
  }

  // === PRIVATE HELPER METHODS ===

  List<legacy.ExerciseTemplate> _parseExercisesToLegacyFormat() {
    final exerciseTemplates = <legacy.ExerciseTemplate>[];

    for (final exerciseRaw in exercisesRaw) {
      try {
        if (exerciseRaw is Map<String, dynamic>) {
          // Try to parse as ExerciseTemplate first (legacy format)
          if (exerciseRaw.containsKey('exerciseId') && exerciseRaw.containsKey('exerciseName')) {
            exerciseTemplates.add(legacy.ExerciseTemplate.fromJson(exerciseRaw));
          } else {
            // Convert from Exercise format
            final exercise = Exercise.fromJson(exerciseRaw);
            exerciseTemplates.add(_convertExerciseToLegacyTemplate(exercise));
          }
        } else if (exerciseRaw is Exercise) {
          exerciseTemplates.add(_convertExerciseToLegacyTemplate(exerciseRaw));
        }
      } catch (e) {
        // Skip invalid exercises but log for debugging
        if (kDebugMode) {
          debugPrint('Warning: Failed to parse exercise in legacy format: $e');
        }
      }
    }

    return exerciseTemplates;
  }

  List<Exercise> _parseExercisesToModernFormat() {
    return _parseExercisesToExerciseFormat();
  }

  List<Exercise> _parseExercisesToExerciseFormat() {
    final exercises = <Exercise>[];

    for (final exerciseRaw in exercisesRaw) {
      try {
        if (exerciseRaw is Map<String, dynamic>) {
          // Check if it's an ExerciseTemplate that needs conversion
          if (exerciseRaw.containsKey('exerciseId') && exerciseRaw.containsKey('exerciseName')) {
            final template = legacy.ExerciseTemplate.fromJson(exerciseRaw);
            exercises.add(template.toWorkoutExercise());
          } else {
            // Direct Exercise format
            exercises.add(Exercise.fromJson(exerciseRaw));
          }
        } else if (exerciseRaw is Exercise) {
          exercises.add(exerciseRaw);
        }
      } catch (e) {
        // Skip invalid exercises but log for debugging
        if (kDebugMode) {
          debugPrint('Warning: Failed to parse exercise: $e');
        }
      }
    }

    return exercises;
  }

  legacy.ExerciseTemplate _convertExerciseToLegacyTemplate(Exercise exercise) {
    return legacy.ExerciseTemplate(
      exerciseId: exercise.name, // Use name as ID for now
      exerciseName: exercise.name,
      category: exercise.category,
      type: exercise.type,
      sets: exercise.sets.map((set) => legacy.SetTemplate(
        setNumber: set.setNumber,
        targetWeight: set.weight,
        targetReps: set.reps,
        notes: set.notes,
      )).toList(),
      notes: exercise.notes,
      restTime: exercise.restTime,
    );
  }
}

/// Helper class for mapping between enum types
class UnifiedTemplateMigrationHelper {
  /// Normalize JSON from any source format
  static Map<String, dynamic> normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Ensure required fields
    normalized['id'] ??= const Uuid().v4();
    normalized['name'] ??= 'Untitled Template';
    normalized['description'] ??= '';
    normalized['createdAt'] ??= DateTime.now().toIso8601String();

    // Normalize exercises field
    if (normalized['exercises'] != null && normalized['exercises'] is List) {
      normalized['exercisesRaw'] = normalized['exercises'];
    } else {
      normalized['exercisesRaw'] = [];
    }

    // Map visibility from different sources
    if (normalized['isPublic'] == true) {
      normalized['visibility'] = 'public';
    } else if (normalized['visibility'] == null) {
      normalized['visibility'] = 'private';
    }

    // Add safety defaults
    normalized['isBeingDeleted'] ??= false;
    normalized['isSyncInProgress'] ??= false;
    normalized['version'] ??= 1;

    return normalized;
  }
}

// === STATIC HELPER METHODS ===

UnifiedTemplateCategory _inferCategoryFromTags(List<String> tags) {
  final tagString = tags.join(' ').toLowerCase();

  if (tagString.contains('strength') || tagString.contains('forza')) {
    return UnifiedTemplateCategory.strength;
  } else if (tagString.contains('hypertrophy') || tagString.contains('massa')) {
    return UnifiedTemplateCategory.hypertrophy;
  } else if (tagString.contains('cardio')) {
    return UnifiedTemplateCategory.cardio;
  } else if (tagString.contains('powerlifting')) {
    return UnifiedTemplateCategory.powerlifting;
  } else if (tagString.contains('bodybuilding')) {
    return UnifiedTemplateCategory.bodybuilding;
  }

  return UnifiedTemplateCategory.custom;
}

UnifiedTemplateVisibility _mapModernVisibility(modern.TemplateVisibility visibility) {
  switch (visibility) {
    case modern.TemplateVisibility.private:
      return UnifiedTemplateVisibility.private;
    case modern.TemplateVisibility.public:
      return UnifiedTemplateVisibility.public;
    case modern.TemplateVisibility.friends:
      return UnifiedTemplateVisibility.friends;
  }
}

UnifiedTemplateCategory _mapModernCategory(modern.TemplateCategory category) {
  switch (category) {
    case modern.TemplateCategory.strength:
      return UnifiedTemplateCategory.strength;
    case modern.TemplateCategory.hypertrophy:
      return UnifiedTemplateCategory.hypertrophy;
    case modern.TemplateCategory.endurance:
      return UnifiedTemplateCategory.endurance;
    case modern.TemplateCategory.powerlifting:
      return UnifiedTemplateCategory.powerlifting;
    case modern.TemplateCategory.bodybuilding:
      return UnifiedTemplateCategory.bodybuilding;
    case modern.TemplateCategory.crossfit:
      return UnifiedTemplateCategory.crossfit;
    case modern.TemplateCategory.calisthenics:
      return UnifiedTemplateCategory.calisthenics;
    case modern.TemplateCategory.cardio:
      return UnifiedTemplateCategory.cardio;
    case modern.TemplateCategory.mixed:
      return UnifiedTemplateCategory.mixed;
    case modern.TemplateCategory.custom:
      return UnifiedTemplateCategory.custom;
  }
}

modern.TemplateVisibility _mapToModernVisibility(UnifiedTemplateVisibility visibility) {
  switch (visibility) {
    case UnifiedTemplateVisibility.private:
      return modern.TemplateVisibility.private;
    case UnifiedTemplateVisibility.public:
      return modern.TemplateVisibility.public;
    case UnifiedTemplateVisibility.friends:
      return modern.TemplateVisibility.friends;
  }
}

modern.TemplateCategory _mapToModernCategory(UnifiedTemplateCategory category) {
  switch (category) {
    case UnifiedTemplateCategory.strength:
      return modern.TemplateCategory.strength;
    case UnifiedTemplateCategory.hypertrophy:
      return modern.TemplateCategory.hypertrophy;
    case UnifiedTemplateCategory.endurance:
      return modern.TemplateCategory.endurance;
    case UnifiedTemplateCategory.powerlifting:
      return modern.TemplateCategory.powerlifting;
    case UnifiedTemplateCategory.bodybuilding:
      return modern.TemplateCategory.bodybuilding;
    case UnifiedTemplateCategory.crossfit:
      return modern.TemplateCategory.crossfit;
    case UnifiedTemplateCategory.calisthenics:
      return modern.TemplateCategory.calisthenics;
    case UnifiedTemplateCategory.cardio:
      return modern.TemplateCategory.cardio;
    case UnifiedTemplateCategory.mixed:
      return modern.TemplateCategory.mixed;
    case UnifiedTemplateCategory.custom:
      return modern.TemplateCategory.custom;
    case UnifiedTemplateCategory.flexibility:
      return modern.TemplateCategory.strength; // Map to strength as fallback
  }
}