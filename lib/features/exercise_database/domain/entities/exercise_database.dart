import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_database.freezed.dart';
part 'exercise_database.g.dart';

@freezed
class ExerciseDatabase with _$ExerciseDatabase {
  const factory ExerciseDatabase({
    required String id,
    required String name,
    String? category,
    String? equipment,
    List<String>? primaryMuscleGroups,
    List<String>? secondaryMuscleGroups,
    String? difficulty,
    String? instructions,
    String? imageUrl,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  }) = _ExerciseDatabase;

  factory ExerciseDatabase.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDatabaseFromJson(json);
}