import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

enum WorkoutStatus {
  planned,
  inProgress,
  completed,
  paused,
}

@freezed
class Workout with _$Workout {
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

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

  // Computed properties
  Duration? get duration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  int get completedExercises {
    return exercises.where((exercise) =>
      exercise.sets.isNotEmpty &&
      exercise.sets.every((set) => set.isCompleted)
    ).length;
  }

  int get totalSets {
    return exercises.fold(0, (total, exercise) => total + exercise.sets.length);
  }

  int get completedSets {
    return exercises.fold(0, (total, exercise) =>
      total + exercise.sets.where((set) => set.isCompleted).length
    );
  }

  double get progressPercentage {
    if (totalSets == 0) return 0.0;
    return completedSets / totalSets;
  }

  bool get isActive => status == WorkoutStatus.inProgress;
  bool get isCompleted => status == WorkoutStatus.completed;

  // Helper methods
  Workout addExercise(Exercise exercise) {
    return copyWith(
      exercises: [...exercises, exercise],
      updatedAt: DateTime.now(),
    );
  }

  Workout removeExercise(String exerciseId) {
    return copyWith(
      exercises: exercises.where((e) => e.id != exerciseId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Workout updateExercise(String exerciseId, Exercise updatedExercise) {
    return copyWith(
      exercises: exercises.map((e) =>
        e.id == exerciseId ? updatedExercise : e
      ).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Workout startWorkout() {
    return copyWith(
      status: WorkoutStatus.inProgress,
      startTime: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Workout completeWorkout() {
    return copyWith(
      status: WorkoutStatus.completed,
      endTime: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Workout pauseWorkout() {
    return copyWith(
      status: WorkoutStatus.paused,
      updatedAt: DateTime.now(),
    );
  }

  Workout resumeWorkout() {
    return copyWith(
      status: WorkoutStatus.inProgress,
      updatedAt: DateTime.now(),
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

// Pre-built workout templates
class WorkoutTemplate {
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
        .where((exercise) =>
            exercise.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
