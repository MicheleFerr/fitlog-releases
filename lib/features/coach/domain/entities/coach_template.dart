/// Coach Template Entity
///
/// Represents a workout template owned by a coach that can be assigned to athletes.
/// Uses Link model - athletes get references, coach retains ownership.
///
/// **Layer**: Domain
/// **Feature**: Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

part 'coach_template.freezed.dart';
part 'coach_template.g.dart';

/// JSON converter for ExerciseTemplate list
class ExerciseTemplateListConverter
    implements JsonConverter<List<ExerciseTemplate>, List<dynamic>> {
  const ExerciseTemplateListConverter();

  @override
  List<ExerciseTemplate> fromJson(List<dynamic> json) {
    return json
        .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<ExerciseTemplate> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

/// A workout template created by a coach for athletes
@freezed
abstract class CoachTemplate with _$CoachTemplate {
  const factory CoachTemplate({
    /// Unique template ID
    required String id,

    /// Coach who owns this template
    required String coachId,

    /// Template name
    required String name,

    /// Optional description
    String? description,

    /// List of exercises in this template
    @ExerciseTemplateListConverter()
    @Default([])
    List<ExerciseTemplate> exercises,

    /// Estimated workout duration in minutes
    @Default(45) int estimatedDuration,

    /// Tags for categorization (e.g., "push", "pull", "legs")
    @Default([]) List<String> tags,

    /// Difficulty level (beginner, intermediate, advanced)
    String? difficulty,

    /// When the template was created
    required DateTime createdAt,

    /// When the template was last updated
    required DateTime updatedAt,

    /// List of athlete IDs this template is assigned to
    @Default([]) List<String> assignedTo,

    /// Whether this template is archived
    @Default(false) bool isArchived,

    /// Optional notes for the coach
    String? coachNotes,
  }) = _CoachTemplate;

  /// Create from a WorkoutTemplate
  factory CoachTemplate.fromWorkoutTemplate({
    required WorkoutTemplate template,
    required String coachId,
  }) {
    return CoachTemplate(
      id: template.id,
      coachId: coachId,
      name: template.name,
      description: template.description,
      exercises: template.exercises,
      estimatedDuration: template.estimatedDuration,
      tags: template.tags,
      difficulty: template.difficulty,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  factory CoachTemplate.fromJson(Map<String, dynamic> json) =>
      _$CoachTemplateFromJson(json);

  const CoachTemplate._();

  /// Number of athletes this template is assigned to
  int get assignedCount => assignedTo.length;

  /// Whether this template has any assignments
  bool get hasAssignments => assignedTo.isNotEmpty;

  /// Check if assigned to a specific athlete
  bool isAssignedTo(String athleteId) => assignedTo.contains(athleteId);

  /// Convert to a WorkoutTemplate for starting a workout
  WorkoutTemplate toWorkoutTemplate() {
    return WorkoutTemplate(
      id: id,
      name: name,
      description: description ?? '',
      exercises: exercises,
      estimatedDuration: estimatedDuration,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isCustom: true,
      userId: coachId,
      difficulty: difficulty,
    );
  }
}
