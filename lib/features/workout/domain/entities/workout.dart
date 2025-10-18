import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

enum WorkoutStatus {
  planned,
  inProgress,
  completed,
  paused,
}

class Workout { // ID del template di origine (se creato da template)

  Workout({
    String? id,
    required this.name,
    List<Exercise>? exercises,
    this.status = WorkoutStatus.planned,
    this.startTime,
    this.endTime,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.templateId,
  }) :
    id = id ?? const Uuid().v4(),
    exercises = exercises ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      exercises: (json['exercises'] as List?)
          ?.map((exerciseJson) => Exercise.fromJson(exerciseJson))
          .toList() ?? [],
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutStatus.planned,
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      templateId: json['templateId'],
    );
  }
  final String id;
  final String name;
  final List<Exercise> exercises;
  final WorkoutStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? templateId;

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

  Workout copyWith({
    String? name,
    List<Exercise>? exercises,
    WorkoutStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    DateTime? updatedAt,
    String? templateId,
  }) {
    return Workout(
      id: id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      templateId: templateId ?? this.templateId,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'status': status.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'templateId': templateId,
    };
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