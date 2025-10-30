import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';

/// Shared utility for mapping ExerciseCategory to MuscleGroup
///
/// This eliminates code duplication across analyzers and ensures
/// consistent categorization logic throughout the app.
///
/// Note: Cardio and "other" exercises return null as they shouldn't
/// be tracked in muscle group volume analysis.
class MuscleGroupMapper {
  /// Maps an ExerciseCategory to its corresponding MuscleGroup
  ///
  /// Returns null for cardio/other exercises that shouldn't be tracked
  /// in volume analysis
  static MuscleGroup? fromExerciseCategory(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return MuscleGroup.chest;
      case ExerciseCategory.back:
        return MuscleGroup.back;
      case ExerciseCategory.shoulders:
        return MuscleGroup.shoulders;
      case ExerciseCategory.arms:
        return MuscleGroup.arms;
      case ExerciseCategory.legs:
        return MuscleGroup.legs;
      case ExerciseCategory.abs:
        return MuscleGroup.core;
      case ExerciseCategory.cardio:
      case ExerciseCategory.other:
        // Cardio and uncategorized exercises are excluded from volume analysis
        return null;
    }
  }
}
