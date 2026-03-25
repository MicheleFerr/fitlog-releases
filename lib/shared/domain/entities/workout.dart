import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

enum WorkoutStatus { planned, inProgress, completed, paused }

@freezed
abstract class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    @Default([]) List<Exercise> exercises,
    @Default(WorkoutStatus.planned) WorkoutStatus status,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? templateId,

    // 🆕 Pre-load management
    @Default(false) bool isPreloaded,
    DateTime? preloadExpiry,
    bool? exercisesModified,

    // 🆕 Analytics tracking
    String? sessionId,
  }) = _Workout;

  const Workout._();

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  static int _totalSetsForExercise(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return exercise.supersetSets.length;
    }
    if (exercise is DropSetExercise) {
      return exercise.stages.length;
    }
    if (exercise is RestPauseExercise) {
      return exercise.restPauseSets.length;
    }
    return exercise.sets.length;
  }

  static int _completedSetsForExercise(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return exercise.supersetSets.where((set) => set.isCompleted).length;
    }
    if (exercise is DropSetExercise) {
      return exercise.stages.where((stage) => stage.isCompleted).length;
    }
    if (exercise is RestPauseExercise) {
      return exercise.restPauseSets.where((set) => set.isCompleted).length;
    }
    return exercise.sets.where((set) => set.isCompleted).length;
  }

  static double _completedVolumeForExercise(Exercise exercise) {
    if (exercise is SupersetExercise) {
      return exercise.supersetSets
          .where((set) => set.isCompleted)
          .fold<double>(0.0, (total, set) {
            final roundVolume = set.exerciseData.values.fold<double>(
              0.0,
              (roundTotal, data) {
                final weight = data.actualWeight ?? data.targetWeight ?? 0.0;
                final reps = data.actualReps ?? data.targetReps ?? 0;
                return roundTotal + (weight * reps);
              },
            );
            return total + roundVolume;
          });
    }
    if (exercise is DropSetExercise) {
      return exercise.stages
          .where((stage) => stage.isCompleted)
          .fold<double>(
            0.0,
            (total, stage) => total + (stage.weight * stage.effectiveReps),
          );
    }
    if (exercise is RestPauseExercise) {
      return exercise.restPauseSets
          .where((set) => set.isCompleted)
          .fold<double>(
            0.0,
            (total, set) => total + (exercise.weight * set.effectiveReps),
          );
    }
    return exercise.sets
        .where((set) => set.isCompleted)
        .fold<double>(0.0, (total, set) => total + set.volume);
  }

  // Computed properties
  Duration? get duration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  int get completedExercises {
    return exercises.where((exercise) => exercise.isCompleted).length;
  }

  int get totalSets {
    return exercises.fold(
      0,
      (total, exercise) => total + _totalSetsForExercise(exercise),
    );
  }

  int get completedSets {
    return exercises.fold(
      0,
      (total, exercise) => total + _completedSetsForExercise(exercise),
    );
  }

  double get completedVolume {
    return exercises.fold(
      0.0,
      (total, exercise) => total + _completedVolumeForExercise(exercise),
    );
  }

  double get progressPercentage {
    if (totalSets == 0) return 0.0;
    return completedSets / totalSets;
  }

  bool get isActive => status == WorkoutStatus.inProgress;
  bool get isCompleted => status == WorkoutStatus.completed;

  /// Alias for endTime - used by recovery_insight feature
  DateTime? get completedAt => endTime;

  // Helper methods
  Workout addExercise(Exercise exercise) {
    return copyWith(
      exercises: [...exercises, exercise],
      updatedAt: DateTime.now(),
    );
  }

  /// Insert exercise at specific position
  Workout insertExerciseAt(int index, Exercise exercise) {
    final newExercises = List<Exercise>.from(exercises);
    // Clamp index to valid range
    final safeIndex = index.clamp(0, newExercises.length);
    newExercises.insert(safeIndex, exercise);
    return copyWith(exercises: newExercises, updatedAt: DateTime.now());
  }

  Workout removeExercise(String exerciseId) {
    return copyWith(
      exercises: exercises.where((e) => e.id != exerciseId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Workout updateExercise(String exerciseId, Exercise updatedExercise) {
    return copyWith(
      exercises: exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList(),
      updatedAt: DateTime.now(),
    );
  }

  Workout startWorkout() {
    return copyWith(
      status: WorkoutStatus.inProgress,
      startTime: DateTime.now(),
      endTime: null,
      updatedAt: DateTime.now(),
      // 🐛 BUG FIX: Clear preload flags when starting workout
      // Without this, cleanup timer kills active workouts after preloadExpiry
      isPreloaded: false,
      preloadExpiry: null,
    );
  }

  Workout completeWorkout() {
    final completedAt = status == WorkoutStatus.paused
        ? DateTime.now()
        : (endTime ?? DateTime.now());
    return copyWith(
      status: WorkoutStatus.completed,
      endTime: completedAt,
      updatedAt: DateTime.now(),
    );
  }

  Workout pauseWorkout() {
    final pausedAt = DateTime.now();
    return copyWith(
      status: WorkoutStatus.paused,
      endTime: pausedAt,
      updatedAt: pausedAt,
    );
  }

  Workout resumeWorkout() {
    final resumedAt = DateTime.now();
    final adjustedStartTime =
        startTime != null && endTime != null ? startTime!.add(resumedAt.difference(endTime!)) : startTime;
    return copyWith(
      status: WorkoutStatus.inProgress,
      startTime: adjustedStartTime,
      endTime: null,
      updatedAt: resumedAt,
      // 🐛 BUG FIX: Clear preload flags when resuming workout (safety measure)
      isPreloaded: false,
      preloadExpiry: null,
    );
  }
}

extension WorkoutExtensions on Workout {
  /// Check if pre-loaded workout has expired
  bool get isExpired {
    if (!isPreloaded || preloadExpiry == null) return false;
    return DateTime.now().isAfter(preloadExpiry!);
  }
}

/// Static exercise suggestions database organized by category.
///
/// **⚠️ NAMING CLARIFICATION**: This class was previously named `WorkoutTemplate`
/// which caused confusion with the actual template entities:
/// - `lib/shared/domain/entities/workout_template.dart` (user templates)
/// - `lib/features/workout_templates/domain/entities/workout_template.dart` (community templates)
///
/// This class provides STATIC exercise name suggestions for autocomplete/picker UI.
/// It is NOT a workout template entity.
class ExerciseSuggestions {
  static const Map<ExerciseCategory, List<String>> exerciseDatabase = {
    ExerciseCategory.chest: [
      'Panca Piana',
      'Panca Inclinata',
      'Dips',
      'Pectoral Machine',
      'Croci',
      'Push-up',
      'Panca Declinata',
    ],
    ExerciseCategory.back: [
      'Trazioni',
      'Lat Machine',
      'Rematore',
      'Pulley',
      'Stacchi',
      'T-Bar Row',
      'Hyperextensions',
    ],
    ExerciseCategory.shoulders: [
      'Shoulder Press',
      'Alzate Laterali',
      'Alzate Posteriori',
      'Arnold Press',
      'Upright Row',
      'Face Pull',
      'Pike Push-up',
    ],
    ExerciseCategory.arms: [
      'Curl Bilanciere',
      'Tricep Dips',
      'Hammer Curl',
      'French Press',
      'Curl Manubri',
      'Tricep Pushdown',
      'Close Grip Bench',
    ],
    ExerciseCategory.legs: [
      'Squat',
      'Leg Press',
      'Stacchi Rumeni',
      'Leg Curl',
      'Leg Extension',
      'Affondi',
      'Calf Raises',
    ],
    ExerciseCategory.abs: [
      'Plank',
      'Crunch',
      'Russian Twist',
      'Mountain Climbers',
      'Bicycle Crunch',
      'Dead Bug',
      'Leg Raises',
    ],
  };

  static List<String> getExercisesForCategory(ExerciseCategory category) {
    return exerciseDatabase[category] ?? [];
  }

  static List<String> searchExercises(String query) {
    final allExercises = exerciseDatabase.values
        .expand((exercises) => exercises)
        .toList();

    return allExercises
        .where(
          (exercise) => exercise.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
