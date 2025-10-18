import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';

/// Scientific muscle volume classification service
///
/// Based on research:
/// - Baz-Valle et al. (2022): Muscle activation patterns in compound exercises
/// - Schoenfeld et al. (2017): Volume recommendations per muscle group
/// - Klisarić et al. (2021): Primary vs secondary muscle involvement
///
/// Primary volume: muscle is the main target (weight × 1.0)
/// Secondary volume: muscle is synergist/stabilizer (weight × 0.5)
class MuscleVolumeClassifier {
  /// Calculate volume distribution with primary/secondary distinction
  static Map<MuscleGroup, VolumeDistribution> calculateVolumeDistribution(
    List<Exercise> exercises,
  ) {
    final distribution = <MuscleGroup, VolumeDistribution>{
      MuscleGroup.chest: VolumeDistribution(),
      MuscleGroup.back: VolumeDistribution(),
      MuscleGroup.shoulders: VolumeDistribution(),
      MuscleGroup.arms: VolumeDistribution(),
      MuscleGroup.legs: VolumeDistribution(),
      MuscleGroup.core: VolumeDistribution(),
    };

    for (final exercise in exercises) {
      final volume = _calculateExerciseVolume(exercise);

      // Get primary and secondary muscle groups
      final primaryMuscles = _getPrimaryMuscles(exercise);
      final secondaryMuscles = _getSecondaryMuscles(exercise);

      // Distribute primary volume (full weight)
      for (final muscle in primaryMuscles) {
        distribution[muscle]!.primaryVolume += volume;
      }

      // Distribute secondary volume (50% weight per research)
      for (final muscle in secondaryMuscles) {
        distribution[muscle]!.secondaryVolume += volume * 0.5;
      }
    }

    return distribution;
  }

  /// Get primary muscle groups for an exercise
  static List<MuscleGroup> _getPrimaryMuscles(Exercise exercise) {
    final muscles = <MuscleGroup>[];

    switch (exercise.category) {
      case ExerciseCategory.chest:
        muscles.add(MuscleGroup.chest);
        break;
      case ExerciseCategory.back:
        muscles.add(MuscleGroup.back);
        break;
      case ExerciseCategory.shoulders:
        muscles.add(MuscleGroup.shoulders);
        break;
      case ExerciseCategory.arms:
        muscles.add(MuscleGroup.arms);
        break;
      case ExerciseCategory.legs:
        muscles.add(MuscleGroup.legs);
        break;
      case ExerciseCategory.abs:
        muscles.add(MuscleGroup.core);
        break;
      case ExerciseCategory.cardio:
      case ExerciseCategory.other:
        // No primary muscle for cardio
        break;
    }

    return muscles;
  }

  /// Get secondary muscle groups based on exercise type and biomechanics
  ///
  /// Based on EMG studies (Baz-Valle 2022, Schoenfeld 2017):
  /// - Chest exercises activate front delts, triceps
  /// - Back exercises activate rear delts, biceps
  /// - Shoulder presses activate triceps, upper chest
  /// - Compound leg exercises activate core, lower back
  static List<MuscleGroup> _getSecondaryMuscles(Exercise exercise) {
    final muscles = <MuscleGroup>[];
    final name = exercise.name.toLowerCase();

    switch (exercise.category) {
      case ExerciseCategory.chest:
        // Chest exercises activate shoulders (front delts) and arms (triceps)
        muscles.add(MuscleGroup.shoulders);
        if (_isCompound(name, exercise)) {
          muscles.add(MuscleGroup.arms); // Triceps in pressing
        }
        break;

      case ExerciseCategory.back:
        // Back exercises activate rear delts and biceps
        muscles.add(MuscleGroup.shoulders);
        if (_isPulling(name)) {
          muscles.add(MuscleGroup.arms); // Biceps in pulling
        }
        break;

      case ExerciseCategory.shoulders:
        // Shoulder presses activate triceps and upper chest
        if (_isPressing(name)) {
          muscles.add(MuscleGroup.arms); // Triceps
          muscles.add(MuscleGroup.chest); // Upper chest
        }
        break;

      case ExerciseCategory.arms:
        // Isolated arm work has minimal secondary activation
        break;

      case ExerciseCategory.legs:
        // Compound leg exercises heavily activate core
        if (_isCompound(name, exercise)) {
          muscles.add(MuscleGroup.core);
        }
        break;

      case ExerciseCategory.abs:
        // Core exercises may activate legs (hip flexors)
        break;

      case ExerciseCategory.cardio:
      case ExerciseCategory.other:
        break;
    }

    return muscles;
  }

  static bool _isCompound(String name, Exercise exercise) {
    final compoundKeywords = [
      'press', 'bench', 'squat', 'deadlift', 'row',
      'pull', 'dip', 'pushup', 'push up', 'lunge'
    ];
    return compoundKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _isPulling(String name) {
    final pullingKeywords = ['pull', 'row', 'chin', 'curl', 'lat'];
    return pullingKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _isPressing(String name) {
    final pressingKeywords = ['press', 'push', 'dip'];
    return pressingKeywords.any((keyword) => name.contains(keyword));
  }

  static double _calculateExerciseVolume(Exercise exercise) {
    return exercise.sets.fold(0.0, (sum, set) {
      if (!set.isCompleted) return sum;
      final weight = set.weight ?? 0;
      final reps = set.actualReps ?? set.reps ?? 0;
      return sum + (weight * reps);
    });
  }
}

/// Volume distribution for a muscle group
class VolumeDistribution {

  VolumeDistribution({
    this.primaryVolume = 0,
    this.secondaryVolume = 0,
  });
  double primaryVolume;
  double secondaryVolume;

  /// Total weighted volume (primary + 50% secondary)
  double get totalWeightedVolume => primaryVolume + secondaryVolume;

  /// Raw total (primary + secondary at full weight)
  double get totalRawVolume => primaryVolume + (secondaryVolume * 2);

  /// Percentage of volume from primary exercises
  double get primaryPercentage {
    if (totalWeightedVolume == 0) return 0;
    return (primaryVolume / totalWeightedVolume * 100);
  }
}
