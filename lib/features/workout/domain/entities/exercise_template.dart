import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

part 'exercise_template.freezed.dart';
part 'exercise_template.g.dart';

/// Template for quick exercise logging with pre-filled sets
///
/// Reduces friction by remembering user's typical weight/reps/sets
/// Can be created manually or from last workout of an exercise
@freezed
abstract class ExerciseTemplate with _$ExerciseTemplate {
  const factory ExerciseTemplate({
    required String exerciseName,
    required double defaultWeight,
    required int defaultReps,
    required int defaultSets,
    String? notes,
  }) = _ExerciseTemplate;

  /// Create template from last workout of this exercise
  ///
  /// If no previous sets exist, returns template with default values
  /// Otherwise, calculates average weight/reps from completed non-warmup sets
  factory ExerciseTemplate.fromLastWorkout({
    required String exerciseName,
    required List<ExerciseSet> lastSets,
  }) {
    if (lastSets.isEmpty) {
      return ExerciseTemplate(
        exerciseName: exerciseName,
        defaultWeight: 20.0,
        defaultReps: 10,
        defaultSets: 3,
      );
    }

    // Use average of completed sets (excluding warmup)
    final completedSets = lastSets.where((s) => s.isCompleted && !s.isWarmup).toList();

    if (completedSets.isEmpty) {
      // If no completed sets, use all sets as fallback
      final avgWeight = lastSets.fold(0.0, (sum, s) => sum + (s.weight ?? 0)) / lastSets.length;
      final avgReps = (lastSets.fold(0, (sum, s) => sum + (s.reps ?? 0)) / lastSets.length).round();

      return ExerciseTemplate(
        exerciseName: exerciseName,
        defaultWeight: avgWeight,
        defaultReps: avgReps,
        defaultSets: lastSets.length,
      );
    }

    final avgWeight = completedSets.fold(0.0, (sum, s) => sum + (s.weight ?? 0)) / completedSets.length;
    final avgReps = (completedSets.fold(0, (sum, s) => sum + (s.reps ?? 0)) / completedSets.length).round();

    return ExerciseTemplate(
      exerciseName: exerciseName,
      defaultWeight: avgWeight,
      defaultReps: avgReps,
      defaultSets: completedSets.length,
    );
  }

  const ExerciseTemplate._();

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTemplateFromJson(json);

  /// Create pre-filled sets from template
  ///
  /// Returns list of ExerciseSet with template's default values
  /// Sets are numbered sequentially (1, 2, 3, ...)
  /// All sets are marked as not completed and not warmup
  List<ExerciseSet> createSets() {
    return List.generate(
      defaultSets,
      (index) => ExerciseSet(
        setNumber: index + 1,
        weight: defaultWeight,
        reps: defaultReps,
        isCompleted: false,
        isWarmup: false,
      ),
    );
  }
}
