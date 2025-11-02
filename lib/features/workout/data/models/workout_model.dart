/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/models
/// 🎯 Feature: workout
/// 🔧 Type: model
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Domain entities
/// - JSON serialization
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper function to parse DateTime from various formats
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  
  if (value is DateTime) {
    return value;
  }
  
  if (value is Timestamp) {
    return value.toDate();
  }
  
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  
  // Try to call toDate() method if it exists (for Firestore Timestamp)
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return null;
  }
}

/// Data model for Workout with JSON serialization
class WorkoutModel {

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.exercises,
    required this.status,
    this.startTime,
    this.endTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from domain entity
  factory WorkoutModel.fromDomain(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      name: workout.name,
      exercises: workout.exercises
          .map((exercise) => ExerciseModel.fromDomain(exercise))
          .toList(),
      status: workout.status.name,
      startTime: workout.startTime,
      endTime: workout.endTime,
      notes: workout.notes,
      createdAt: workout.createdAt,
      updatedAt: workout.updatedAt,
    );
  }

  /// Convert from JSON (Firestore/Hive)
  /// Handles both Map<String, dynamic> and Map<dynamic, dynamic> from Hive
  factory WorkoutModel.fromJson(Map<dynamic, dynamic> json) {
    // Cast to Map<String, dynamic> for type safety
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // CRITICAL: Handle null values robustly - Firebase data may have nulls
    final id = (data['id'] as String?) ??
               'workout-${DateTime.now().millisecondsSinceEpoch}';
    final name = (data['name'] as String?) ?? 'Unnamed Workout';
    // Many Firebase workouts have status=null, treat as 'completed' for analytics
    final status = (data['status'] as String?) ?? 'completed';

    // Parse exercises with error handling - skip malformed exercises instead of failing
    final exercises = <ExerciseModel>[];
    final exercisesList = data['exercises'] as List<dynamic>?;
    if (exercisesList != null) {
      for (final exerciseJson in exercisesList) {
        try {
          final exercise = ExerciseModel.fromJson(
              Map<String, dynamic>.from(exerciseJson as Map));
          exercises.add(exercise);
        } catch (e) {
          // Log only in debug mode
          assert(() {
            debugPrint('⚠️ [WorkoutModel] Failed to parse exercise in workout $id: $e');
            debugPrint('📍 [WorkoutModel] Exercise data: $exerciseJson');
            return true;
          }());
          // Skip this exercise and continue with others
        }
      }
    }

    return WorkoutModel(
      id: id,
      name: name,
      exercises: exercises,
      status: status,
      startTime: _parseDateTime(data['startTime']),
      endTime: _parseDateTime(data['endTime']),
      notes: data['notes'] as String?,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
    );
  }
  final String id;
  final String name;
  final List<ExerciseModel> exercises;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convert to domain entity
  Workout toDomain() {
    return Workout(
      id: id,
      name: name,
      exercises: exercises
          .map((exerciseModel) => exerciseModel.toDomain())
          .toList(),
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => WorkoutStatus.planned,
      ),
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a copy with modified fields
  WorkoutModel copyWith({
    String? id,
    String? name,
    List<ExerciseModel>? exercises,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Data model for Exercise
class ExerciseModel {

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.sets,
    this.restTime,
    this.tut,
    this.notes,
    required this.isCompleted,
    required this.totalVolume,
    this.completedAt,
    required this.createdAt,
  });

  factory ExerciseModel.fromDomain(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      type: exercise.type.name,
      category: exercise.category.name,
      sets: exercise.sets
          .map((set) => ExerciseSetModel.fromDomain(set))
          .toList(),
      restTime: exercise.restTime,
      tut: exercise.tut,
      notes: exercise.notes,
      isCompleted: exercise.isCompleted,
      totalVolume: exercise.totalVolume,
      completedAt: exercise.completedAt,
      createdAt: exercise.createdAt,
    );
  }

  factory ExerciseModel.fromJson(Map<dynamic, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // Handle nested Firebase structure with exerciseData map
    final exerciseData = data['exerciseData'] as Map<String, dynamic>?;

    // Extract fields from exerciseData if nested, otherwise from root
    // CRITICAL: Handle null values robustly - Firebase data may have nulls
    final String id;
    final String name;
    final String? notes;

    if (exerciseData != null) {
      // Use null-aware operators and provide fallbacks for required fields
      id = (exerciseData['id'] as String?) ??
           (data['id'] as String?) ??
           'unknown-${DateTime.now().millisecondsSinceEpoch}';
      name = (exerciseData['name'] as String?) ??
             (data['name'] as String?) ??
             'Unknown Exercise';
      notes = exerciseData['notes'] as String?;
    } else {
      id = (data['id'] as String?) ??
           'unknown-${DateTime.now().millisecondsSinceEpoch}';
      name = (data['name'] as String?) ?? 'Unknown Exercise';
      notes = data['notes'] as String?;
    }

    // Type field might not exist in Firebase, default to 'strength'
    final type = (data['type'] as String?) ?? 'strength';

    // Category might be null in Firebase - provide safe fallback
    final category = (data['category'] as String?) ?? 'other';

    // Parse sets with error handling - skip malformed sets instead of failing
    final sets = <ExerciseSetModel>[];
    final setsList = data['sets'] as List<dynamic>?;
    if (setsList != null) {
      for (final setJson in setsList) {
        try {
          final set = ExerciseSetModel.fromJson(
              Map<String, dynamic>.from(setJson as Map));
          sets.add(set);
        } catch (e) {
          // Log only in debug mode
          assert(() {
            debugPrint('⚠️ [ExerciseModel] Failed to parse set in exercise $id: $e');
            debugPrint('📍 [ExerciseModel] Set data: $setJson');
            return true;
          }());
          // Skip this set and continue with others
        }
      }
    }

    return ExerciseModel(
      id: id,
      name: name,
      type: type,
      category: category,
      sets: sets,
      restTime: data['restTimeSeconds'] as int?,
      tut: data['tut'] as String?,
      notes: notes,
      isCompleted: data['isCompleted'] as bool? ?? false,
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0.0,
      completedAt: _parseDateTime(data['completedAt']),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }
  final String id;
  final String name;
  final String type;
  final String category;
  final List<ExerciseSetModel> sets;
  final int? restTime;
  final String? tut;
  final String? notes;
  final bool isCompleted;
  final double totalVolume;
  final DateTime? completedAt;
  final DateTime createdAt;

  Exercise toDomain() {
    return Exercise(
      id: id,
      name: name,
      type: ExerciseType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ExerciseType.single,
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => ExerciseCategory.chest,
      ),
      sets: sets.map((setModel) => setModel.toDomain()).toList(),
      restTime: restTime,
      tut: tut,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'sets': sets.map((e) => e.toJson()).toList(),
      'restTimeSeconds': restTime,
      'tut': tut,
      'notes': notes,
      'isCompleted': isCompleted,
      'totalVolume': totalVolume,
      'completedAt': completedAt,
      'createdAt': createdAt,
    };
  }

  /// Create a copy with modified fields
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    List<ExerciseSetModel>? sets,
    int? restTime,
    String? tut,
    String? notes,
    bool? isCompleted,
    double? totalVolume,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      tut: tut ?? this.tut,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      totalVolume: totalVolume ?? this.totalVolume,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Data model for ExerciseSet
class ExerciseSetModel {               // Manual seconds input (backward compat)

  const ExerciseSetModel({
    required this.id,
    required this.setNumber,
    this.weight,           // Made nullable
    this.reps,            // Made nullable
    required this.volume,
    required this.isCompleted,
    this.restTime,
    this.rpe,
    this.notes,
    this.completedAt,
    // ✅ TUT & Advanced Tracking
    this.setDurationMillis,
    this.setStartedAt,
    this.actualReps,
    this.isWarmup = false,
    this.seconds,
  });

  factory ExerciseSetModel.fromDomain(ExerciseSet exerciseSet) {
    return ExerciseSetModel(
      id: exerciseSet.id,
      setNumber: exerciseSet.setNumber,
      weight: exerciseSet.weight,
      reps: exerciseSet.reps,
      volume: (exerciseSet.weight ?? 0) * (exerciseSet.reps ?? 0), // Calculate volume
      isCompleted: exerciseSet.isCompleted,
      rpe: exerciseSet.rpe,
      notes: exerciseSet.notes,
      completedAt: exerciseSet.completedAt,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: exerciseSet.setDurationMillis,
      setStartedAt: exerciseSet.setStartedAt,
      actualReps: exerciseSet.actualReps,
      isWarmup: exerciseSet.isWarmup,
      seconds: exerciseSet.seconds,
    );
  }

  factory ExerciseSetModel.fromJson(Map<dynamic, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // Firebase structure: setNumber, weight, reps, restSeconds, rpe, isWarmup, isDropSet, isFailure
    // NO id, NO volume, NO isCompleted in Firebase
    final id = (data['id'] as String?) ??
               'set-${DateTime.now().millisecondsSinceEpoch}';
    final setNumber = (data['setNumber'] as int?) ?? 0;

    final weight = (data['weight'] as num?)?.toDouble();
    final reps = data['reps'] as int?;

    // Calculate volume from weight * reps (Firebase doesn't store it)
    final volume = ((weight ?? 0.0) * (reps ?? 0).toDouble());

    // Firebase has 'restSeconds' not 'restTimeSeconds'
    final restTime = (data['restSeconds'] as int?) ?? (data['restTimeSeconds'] as int?);

    // isCompleted doesn't exist in Firebase
    // For historical workouts (from Firebase), ALL sets should be considered completed
    // since these are workouts that have already been finished
    final isCompleted = data['isCompleted'] as bool? ?? true;

    return ExerciseSetModel(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      volume: volume,
      isCompleted: isCompleted,
      restTime: restTime,
      rpe: data['rpe'] as int?,
      notes: data['notes'] as String?,
      completedAt: _parseDateTime(data['completedAt']),
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: (data['setDurationMillis'] as num?)?.toDouble(),
      setStartedAt: _parseDateTime(data['setStartedAt']),
      actualReps: data['actualReps'] as int?,
      isWarmup: data['isWarmup'] as bool? ?? false,
      seconds: data['seconds'] as int?,
    );
  }
  final String id;
  final int setNumber;
  final double? weight;  // Made nullable to match domain entity
  final int? reps;       // Made nullable to match domain entity
  final double volume;
  final bool isCompleted;
  final int? restTime;
  final int? rpe;
  final String? notes;
  final DateTime? completedAt;
  // ✅ TUT & Advanced Tracking Fields
  final double? setDurationMillis;  // Duration in milliseconds (TUT)
  final DateTime? setStartedAt;     // Timestamp when set started
  final int? actualReps;            // Actual reps completed (vs planned reps)
  final bool isWarmup;              // Warmup flag
  final int? seconds;

  ExerciseSet toDomain() {
    final domainSet = ExerciseSet(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      isCompleted: isCompleted,
      rpe: rpe,
      notes: notes,
      completedAt: completedAt,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: setDurationMillis,
      setStartedAt: setStartedAt,
      actualReps: actualReps,
      isWarmup: isWarmup,
      seconds: seconds,
    );
    return domainSet;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'volume': volume,
      'isCompleted': isCompleted,
      'restTimeSeconds': restTime,
      'rpe': rpe,
      'notes': notes,
      'completedAt': completedAt?.toIso8601String(),
      // ✅ TUT & Advanced Tracking Fields
      'setDurationMillis': setDurationMillis,
      'setStartedAt': setStartedAt?.toIso8601String(),
      'actualReps': actualReps,
      'isWarmup': isWarmup,
      'seconds': seconds,
    };
  }

  /// Create a copy with modified fields
  ExerciseSetModel copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    double? volume,
    bool? isCompleted,
    int? restTime,
    int? rpe,
    String? notes,
    DateTime? completedAt,
    // ✅ TUT & Advanced Tracking Fields
    double? setDurationMillis,
    DateTime? setStartedAt,
    int? actualReps,
    bool? isWarmup,
    int? seconds,
  }) {
    return ExerciseSetModel(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      volume: volume ?? this.volume,
      isCompleted: isCompleted ?? this.isCompleted,
      restTime: restTime ?? this.restTime,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      setStartedAt: setStartedAt ?? this.setStartedAt,
      actualReps: actualReps ?? this.actualReps,
      isWarmup: isWarmup ?? this.isWarmup,
      seconds: seconds ?? this.seconds,
    );
  }
}