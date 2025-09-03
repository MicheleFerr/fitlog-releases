/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/models
 * 🎯 Feature: workout
 * 🔧 Type: model
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Domain entities
 * - JSON serialization
 */

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
  final String id;
  final String name;
  final List<ExerciseModel> exercises;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  /// Convert from JSON (Firestore/Hive)
  /// Handles both Map<String, dynamic> and Map<dynamic, dynamic> from Hive
  factory WorkoutModel.fromJson(Map<dynamic, dynamic> json) {
    // Cast to Map<String, dynamic> for type safety
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    
    return WorkoutModel(
      id: data['id'] as String,
      name: data['name'] as String,
      exercises: (data['exercises'] as List<dynamic>?)
          ?.map((exerciseJson) => ExerciseModel.fromJson(
              Map<String, dynamic>.from(exerciseJson as Map)))
          .toList() ?? [],
      status: data['status'] as String,
      startTime: _parseDateTime(data['startTime']),
      endTime: _parseDateTime(data['endTime']),
      notes: data['notes'] as String?,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
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
}

/// Data model for Exercise
class ExerciseModel {
  final String id;
  final String name;
  final String type;
  final String category;
  final List<ExerciseSetModel> sets;
  final int? restTime;
  final String? notes;
  final bool isCompleted;
  final double totalVolume;
  final DateTime? completedAt;
  final DateTime createdAt;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.sets,
    this.restTime,
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
      notes: exercise.notes,
      isCompleted: exercise.isCompleted,
      totalVolume: exercise.totalVolume,
      completedAt: exercise.completedAt,
      createdAt: exercise.createdAt,
    );
  }

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
      notes: notes,
      isCompleted: isCompleted,
      totalVolume: totalVolume,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  factory ExerciseModel.fromJson(Map<dynamic, dynamic> json) {
    // Cast to Map<String, dynamic> for type safety
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    
    return ExerciseModel(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      category: data['category'] as String,
      sets: (data['sets'] as List<dynamic>?)
          ?.map((setJson) => ExerciseSetModel.fromJson(
              Map<String, dynamic>.from(setJson as Map)))
          .toList() ?? [],
      restTime: data['restTimeSeconds'] as int?,
      notes: data['notes'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      totalVolume: (data['totalVolume'] as num?)?.toDouble() ?? 0.0,
      completedAt: _parseDateTime(data['completedAt']),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
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
      'notes': notes,
      'isCompleted': isCompleted,
      'totalVolume': totalVolume,
      'completedAt': completedAt,
      'createdAt': createdAt,
    };
  }
}

/// Data model for ExerciseSet
class ExerciseSetModel {
  final String id;
  final int setNumber;
  final double weight;
  final int reps;
  final double volume;
  final bool isCompleted;
  final int? restTime;
  final int? rpe;
  final String? notes;
  final DateTime? completedAt;

  const ExerciseSetModel({
    required this.id,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.volume,
    required this.isCompleted,
    this.restTime,
    this.rpe,
    this.notes,
    this.completedAt,
  });

  factory ExerciseSetModel.fromDomain(ExerciseSet exerciseSet) {
    return ExerciseSetModel(
      id: exerciseSet.id,
      setNumber: exerciseSet.setNumber,
      weight: exerciseSet.weight,
      reps: exerciseSet.reps,
      volume: exerciseSet.volume,
      isCompleted: exerciseSet.isCompleted,
      restTime: exerciseSet.restTime,
      rpe: exerciseSet.rpe,
      notes: exerciseSet.notes,
      completedAt: exerciseSet.completedAt,
    );
  }

  ExerciseSet toDomain() {
    return ExerciseSet(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      volume: volume,
      isCompleted: isCompleted,
      restTime: restTime,
      rpe: rpe,
      notes: notes,
      completedAt: completedAt,
    );
  }

  factory ExerciseSetModel.fromJson(Map<dynamic, dynamic> json) {
    // Cast to Map<String, dynamic> for type safety
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    
    return ExerciseSetModel(
      id: data['id'] as String,
      setNumber: data['setNumber'] as int,
      weight: (data['weight'] as num).toDouble(),
      reps: data['reps'] as int,
      volume: (data['volume'] as num?)?.toDouble() ?? 0.0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      restTime: data['restTimeSeconds'] as int?,
      rpe: data['rpe'] as int?,
      notes: data['notes'] as String?,
      completedAt: _parseDateTime(data['completedAt']),
    );
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
      'completedAt': completedAt,
    };
  }
}