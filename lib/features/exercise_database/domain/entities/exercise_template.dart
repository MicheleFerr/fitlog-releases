import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../workout/domain/entities/exercise.dart';

part 'exercise_template.freezed.dart';
part 'exercise_template.g.dart';

@freezed
class ExerciseTemplate with _$ExerciseTemplate {
  const factory ExerciseTemplate({
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
    Map<String, dynamic>? metadata,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExerciseTemplate;

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTemplateFromJson(json);
}

extension ExerciseTemplateExtension on ExerciseTemplate {
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