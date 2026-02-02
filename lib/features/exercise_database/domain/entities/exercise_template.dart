/// Exercise Definition Template Entity
///
/// Template for creating exercise definitions from the database catalog.
/// This is for DEFINITION templates (catalog exercises), NOT for
/// workout quick-logging presets.
///
/// For workout quick-logging templates, see:
/// `lib/features/workout/domain/entities/exercise_template.dart`
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

part 'exercise_template.freezed.dart';
part 'exercise_template.g.dart';

/// @deprecated Use [ExerciseDefinitionTemplate] instead to avoid naming conflicts
/// with workout ExerciseTemplate entity.
///
/// This typedef exists for backward compatibility during migration.
@Deprecated(
  'Use ExerciseDefinitionTemplate instead - avoids naming conflict with workout ExerciseTemplate',
)
typedef ExerciseTemplate = ExerciseDefinitionTemplate;

@freezed
abstract class ExerciseDefinitionTemplate with _$ExerciseDefinitionTemplate {
  const factory ExerciseDefinitionTemplate({
    required String id,
    required String name,
    required String description,
    required ExerciseCategory category,
    required ExerciseType type,
    required List<String> muscleGroups,
    required List<String> equipment,
    List<String>? instructions,
    String? imageUrl,
    String? videoUrl,
    String? difficulty,
    Map<String, dynamic>? metadata,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExerciseDefinitionTemplate;

  factory ExerciseDefinitionTemplate.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDefinitionTemplateFromJson(json);
}

extension ExerciseDefinitionTemplateExtension on ExerciseDefinitionTemplate {
  /// Convert template to Exercise for adding to workout
  Exercise toExercise() {
    return Exercise(
      name: name,
      category: category,
      type: type,
      sets: [], // Empty sets initially
      notes: instructions?.join('\n'),
    );
  }
}
