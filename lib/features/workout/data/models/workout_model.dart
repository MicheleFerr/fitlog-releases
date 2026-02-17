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
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
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
    final id =
        (data['id'] as String?) ??
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
            Map<String, dynamic>.from(exerciseJson as Map),
          );
          exercises.add(exercise);
        } catch (e) {
          // Log only in debug mode
          assert(() {
            debugPrint(
              '⚠️ [WorkoutModel] Failed to parse exercise in workout $id: $e',
            );
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

/// Data model for Exercise with full polymorphic support
class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.sets,
    this.restTime,
    this.restAfterExercise,
    this.tut,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    // RM Calculations
    this.calculated1RM,
    this.calculated3RM,
    this.calculated6RM,
    this.calculated10RM,
    this.lastCalculationDate,
    this.calculationMetadata,
    // RPE/RIR
    this.targetRPEMin,
    this.targetRPEMax,
    this.targetRIR,
    this.autoAdjustmentType,
    // Smart Workout Suggestion
    this.movementType,
    // Counting Mode
    this.countingMode,
    // Polymorphic data for subtypes
    this.supersetExercises,
    this.supersetSetsData,
    this.dropSetStages,
    this.restPauseWeight,
    this.restPauseTargetReps,
    this.restPauseSetsData,
  });

  /// Convert from domain entity with polymorphic dispatch
  factory ExerciseModel.fromDomain(Exercise exercise) {
    // Extract common fields from Exercise
    final autoAdjustmentTypeStr = exercise.autoAdjustmentType?.name;
    final movementTypeStr = exercise.movementType?.name;
    final countingModeStr = exercise.countingMode.name;

    // Handle polymorphic subtypes
    List<ExerciseModel>? supersetExercises;
    List<Map<String, dynamic>>? supersetSetsData;
    List<Map<String, dynamic>>? dropSetStages;
    double? restPauseWeight;
    int? restPauseTargetReps;
    List<Map<String, dynamic>>? restPauseSetsData;

    if (exercise is SupersetExercise) {
      supersetExercises = exercise.exercises
          .map((e) => ExerciseModel.fromDomain(e))
          .toList();
      supersetSetsData = exercise.supersetSets.map((s) => s.toJson()).toList();
    } else if (exercise is DropSetExercise) {
      dropSetStages = exercise.stages.map((s) => s.toJson()).toList();
    } else if (exercise is RestPauseExercise) {
      restPauseWeight = exercise.weight;
      restPauseTargetReps = exercise.targetReps;
      restPauseSetsData = exercise.restPauseSets
          .map((s) => s.toJson())
          .toList();
    }

    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      type: exercise.type.name,
      category: exercise.category.name,
      sets: exercise.sets
          .map((set) => ExerciseSetModel.fromDomain(set))
          .toList(),
      restTime: exercise.restTime,
      restAfterExercise: exercise.restAfterExercise,
      tut: exercise.tut,
      notes: exercise.notes,
      createdAt: exercise.createdAt,
      updatedAt: exercise.updatedAt,
      calculated1RM: exercise.calculated1RM,
      calculated3RM: exercise.calculated3RM,
      calculated6RM: exercise.calculated6RM,
      calculated10RM: exercise.calculated10RM,
      lastCalculationDate: exercise.lastCalculationDate,
      calculationMetadata: exercise.calculationMetadata,
      targetRPEMin: exercise.targetRPEMin,
      targetRPEMax: exercise.targetRPEMax,
      targetRIR: exercise.targetRIR,
      autoAdjustmentType: autoAdjustmentTypeStr,
      movementType: movementTypeStr,
      countingMode: countingModeStr,
      supersetExercises: supersetExercises,
      supersetSetsData: supersetSetsData,
      dropSetStages: dropSetStages,
      restPauseWeight: restPauseWeight,
      restPauseTargetReps: restPauseTargetReps,
      restPauseSetsData: restPauseSetsData,
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
      id =
          (exerciseData['id'] as String?) ??
          (data['id'] as String?) ??
          'unknown-${DateTime.now().millisecondsSinceEpoch}';
      name =
          (exerciseData['name'] as String?) ??
          (data['name'] as String?) ??
          'Unknown Exercise';
      notes = exerciseData['notes'] as String?;
    } else {
      id =
          (data['id'] as String?) ??
          'unknown-${DateTime.now().millisecondsSinceEpoch}';
      name = (data['name'] as String?) ?? 'Unknown Exercise';
      notes = data['notes'] as String?;
    }

    // Type field might not exist in Firebase, default to 'single'
    final type = (data['type'] as String?) ?? 'single';

    // Category might be null in Firebase - provide safe fallback
    final category = (data['category'] as String?) ?? 'other';

    // Parse sets with error handling - skip malformed sets instead of failing
    final sets = <ExerciseSetModel>[];
    final setsList = data['sets'] as List<dynamic>?;
    if (setsList != null) {
      for (final setJson in setsList) {
        try {
          final set = ExerciseSetModel.fromJson(
            Map<String, dynamic>.from(setJson as Map),
          );
          sets.add(set);
        } catch (e) {
          // Log only in debug mode
          assert(() {
            debugPrint(
              '⚠️ [ExerciseModel] Failed to parse set in exercise $id: $e',
            );
            debugPrint('📍 [ExerciseModel] Set data: $setJson');
            return true;
          }());
          // Skip this set and continue with others
        }
      }
    }

    // Parse polymorphic data
    List<ExerciseModel>? supersetExercises;
    List<Map<String, dynamic>>? supersetSetsData;
    List<Map<String, dynamic>>? dropSetStages;
    double? restPauseWeight;
    int? restPauseTargetReps;
    List<Map<String, dynamic>>? restPauseSetsData;

    if (type == 'superset') {
      final exercisesList = data['exercises'] as List<dynamic>?;
      if (exercisesList != null) {
        supersetExercises = exercisesList
            .map(
              (e) =>
                  ExerciseModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      final setsList = data['supersetSets'] as List<dynamic>?;
      if (setsList != null) {
        supersetSetsData = setsList
            .map((s) => Map<String, dynamic>.from(s as Map))
            .toList();
      }
    } else if (type == 'dropset') {
      final stagesList = data['stages'] as List<dynamic>?;
      if (stagesList != null) {
        dropSetStages = stagesList
            .map((s) => Map<String, dynamic>.from(s as Map))
            .toList();
      }
    } else if (type == 'restPause') {
      restPauseWeight = (data['weight'] as num?)?.toDouble();
      restPauseTargetReps = data['targetReps'] as int?;
      final rpSetsList = data['restPauseSets'] as List<dynamic>?;
      if (rpSetsList != null) {
        restPauseSetsData = rpSetsList
            .map((s) => Map<String, dynamic>.from(s as Map))
            .toList();
      }
    }

    return ExerciseModel(
      id: id,
      name: name,
      type: type,
      category: category,
      sets: sets,
      // Support both field names: 'restTime' (templates) and 'restTimeSeconds' (legacy)
      restTime: (data['restTime'] as int?) ?? (data['restTimeSeconds'] as int?),
      restAfterExercise: data['restAfterExercise'] as int?,
      tut: data['tut'] as String?,
      notes: notes,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
      // RM Calculations
      calculated1RM: (data['calculated1RM'] as num?)?.toDouble(),
      calculated3RM: (data['calculated3RM'] as num?)?.toDouble(),
      calculated6RM: (data['calculated6RM'] as num?)?.toDouble(),
      calculated10RM: (data['calculated10RM'] as num?)?.toDouble(),
      lastCalculationDate: _parseDateTime(data['lastCalculationDate']),
      calculationMetadata: data['calculationMetadata'] as String?,
      // RPE/RIR
      targetRPEMin: (data['targetRPEMin'] as num?)?.toDouble(),
      targetRPEMax: (data['targetRPEMax'] as num?)?.toDouble(),
      targetRIR: data['targetRIR'] as int?,
      autoAdjustmentType: data['autoAdjustmentType'] as String?,
      // Smart Workout
      movementType: data['movementType'] as String?,
      countingMode: data['countingMode'] as String?,
      // Polymorphic
      supersetExercises: supersetExercises,
      supersetSetsData: supersetSetsData,
      dropSetStages: dropSetStages,
      restPauseWeight: restPauseWeight,
      restPauseTargetReps: restPauseTargetReps,
      restPauseSetsData: restPauseSetsData,
    );
  }
  final String id;
  final String name;
  final String type;
  final String category;
  final List<ExerciseSetModel> sets;
  final int? restTime;
  final int? restAfterExercise;
  final String? tut;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // RM Calculations
  final double? calculated1RM;
  final double? calculated3RM;
  final double? calculated6RM;
  final double? calculated10RM;
  final DateTime? lastCalculationDate;
  final String? calculationMetadata;

  // RPE/RIR Autoregulation
  final double? targetRPEMin;
  final double? targetRPEMax;
  final int? targetRIR;
  final String? autoAdjustmentType;

  // Smart Workout Suggestion
  final String? movementType;

  // Counting Mode
  final String? countingMode;

  // Polymorphic data
  final List<ExerciseModel>? supersetExercises;
  final List<Map<String, dynamic>>? supersetSetsData;
  final List<Map<String, dynamic>>? dropSetStages;
  final double? restPauseWeight;
  final int? restPauseTargetReps;
  final List<Map<String, dynamic>>? restPauseSetsData;

  /// Whether this exercise is completed (all sets completed)
  bool get isCompleted => sets.isNotEmpty && sets.every((s) => s.isCompleted);

  /// Total volume across all completed sets
  double get totalVolume =>
      sets.where((s) => s.isCompleted).fold(0.0, (sum, s) => sum + s.volume);

  Exercise toDomain() {
    // Parse enums
    final exerciseType = ExerciseType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ExerciseType.single,
    );
    final exerciseCategory = ExerciseCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => ExerciseCategory.other,
    );

    // Parse nullable enums
    final autoAdjType = autoAdjustmentType != null
        ? AutoAdjustmentType.values.firstWhere(
            (e) => e.name == autoAdjustmentType,
            orElse: () => AutoAdjustmentType.rpe,
          )
        : null;
    final moveType = movementType != null
        ? MovementType.values.firstWhere(
            (e) => e.name == movementType,
            orElse: () => MovementType.isolationLight,
          )
        : null;
    final countMode = countingMode != null
        ? ExerciseCountingMode.fromString(countingMode)
        : ExerciseCountingMode.weighted;

    // Handle polymorphic conversion
    if (type == 'superset' && supersetExercises != null) {
      // Fallback: if supersetSetsData is null, reconstruct from sets
      List<SupersetSet> supersetSetsList;
      if (supersetSetsData != null && supersetSetsData!.isNotEmpty) {
        supersetSetsList = supersetSetsData!
            .map((s) => SupersetSet.fromJson(s))
            .toList();
      } else {
        // Fallback: create one SupersetSet per set in the exercise
        supersetSetsList = sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return SupersetSet(
            setNumber: index + 1,
            exerciseData: {
              for (var exercise in supersetExercises!)
                exercise.id: SupersetExerciseData(
                  exerciseId: exercise.id,
                  exerciseName: exercise.name,
                  targetWeight: set.weight?.toDouble(),
                  targetReps: set.reps,
                  targetMinReps: set.minReps,
                  targetMaxReps: set.maxReps,
                ),
            },
          );
        }).toList();
      }

      return SupersetExercise(
        id: id,
        name: name,
        exercises: supersetExercises!.map((e) => e.toDomain()).toList(),
        supersetSets: supersetSetsList,
        notes: notes,
        restTime: restTime,
        restAfterExercise: restAfterExercise,
        tut: tut,
        // Advanced fields
        autoAdjustmentType: autoAdjType,
        calculated1RM: calculated1RM,
        calculated3RM: calculated3RM,
        calculated6RM: calculated6RM,
        calculated10RM: calculated10RM,
        lastCalculationDate: lastCalculationDate,
        calculationMetadata: calculationMetadata,
        targetRPEMin: targetRPEMin,
        targetRPEMax: targetRPEMax,
        targetRIR: targetRIR,
        countingMode: countMode,
        movementType: moveType,
      );
    } else if (type == 'dropset' && dropSetStages != null) {
      return DropSetExercise(
        id: id,
        name: name,
        category: exerciseCategory,
        stages: dropSetStages!.map((s) => DropSetStage.fromJson(s)).toList(),
        notes: notes,
        restTime: restTime,
        restAfterExercise: restAfterExercise,
        tut: tut,
        // Advanced fields
        autoAdjustmentType: autoAdjType,
        calculated1RM: calculated1RM,
        calculated3RM: calculated3RM,
        calculated6RM: calculated6RM,
        calculated10RM: calculated10RM,
        lastCalculationDate: lastCalculationDate,
        calculationMetadata: calculationMetadata,
        targetRPEMin: targetRPEMin,
        targetRPEMax: targetRPEMax,
        targetRIR: targetRIR,
        countingMode: countMode,
        movementType: moveType,
      );
    } else if (type == 'restPause' && restPauseSetsData != null) {
      return RestPauseExercise(
        id: id,
        name: name,
        category: exerciseCategory,
        weight: restPauseWeight ?? 0.0,
        targetReps: restPauseTargetReps ?? 0,
        restPauseSets: restPauseSetsData!
            .map((s) => RestPauseSet.fromJson(s))
            .toList(),
        notes: notes,
        restTime: restTime,
        restAfterExercise: restAfterExercise,
        tut: tut,
        // Advanced fields
        autoAdjustmentType: autoAdjType,
        calculated1RM: calculated1RM,
        calculated3RM: calculated3RM,
        calculated6RM: calculated6RM,
        calculated10RM: calculated10RM,
        lastCalculationDate: lastCalculationDate,
        calculationMetadata: calculationMetadata,
        targetRPEMin: targetRPEMin,
        targetRPEMax: targetRPEMax,
        targetRIR: targetRIR,
        countingMode: countMode,
        movementType: moveType,
      );
    }

    // Default: base Exercise
    return Exercise(
      id: id,
      name: name,
      type: exerciseType,
      category: exerciseCategory,
      sets: sets.map((setModel) => setModel.toDomain()).toList(),
      restTime: restTime,
      restAfterExercise: restAfterExercise,
      tut: tut,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      autoAdjustmentType: autoAdjType,
      calculated1RM: calculated1RM,
      calculated3RM: calculated3RM,
      calculated6RM: calculated6RM,
      calculated10RM: calculated10RM,
      lastCalculationDate: lastCalculationDate,
      calculationMetadata: calculationMetadata,
      targetRPEMin: targetRPEMin,
      targetRPEMax: targetRPEMax,
      targetRIR: targetRIR,
      countingMode: countMode,
      movementType: moveType,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'sets': sets.map((e) => e.toJson()).toList(),
      'restTimeSeconds': restTime,
      'restAfterExercise': restAfterExercise,
      'tut': tut,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // RM Calculations
      'calculated1RM': calculated1RM,
      'calculated3RM': calculated3RM,
      'calculated6RM': calculated6RM,
      'calculated10RM': calculated10RM,
      'lastCalculationDate': lastCalculationDate?.toIso8601String(),
      'calculationMetadata': calculationMetadata,
      // RPE/RIR
      'targetRPEMin': targetRPEMin,
      'targetRPEMax': targetRPEMax,
      'targetRIR': targetRIR,
      'autoAdjustmentType': autoAdjustmentType,
      // Smart Workout
      'movementType': movementType,
      'countingMode': countingMode,
    };

    // Add polymorphic data based on type
    if (type == 'superset') {
      json['exercises'] = supersetExercises?.map((e) => e.toJson()).toList();
      json['supersetSets'] = supersetSetsData;
    } else if (type == 'dropset') {
      json['stages'] = dropSetStages;
    } else if (type == 'restPause') {
      json['weight'] = restPauseWeight;
      json['targetReps'] = restPauseTargetReps;
      json['restPauseSets'] = restPauseSetsData;
    }

    return json;
  }

  /// Create a copy with modified fields
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    List<ExerciseSetModel>? sets,
    int? restTime,
    int? restAfterExercise,
    String? tut,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? calculated1RM,
    double? calculated3RM,
    double? calculated6RM,
    double? calculated10RM,
    DateTime? lastCalculationDate,
    String? calculationMetadata,
    double? targetRPEMin,
    double? targetRPEMax,
    int? targetRIR,
    String? autoAdjustmentType,
    String? movementType,
    String? countingMode,
    List<ExerciseModel>? supersetExercises,
    List<Map<String, dynamic>>? supersetSetsData,
    List<Map<String, dynamic>>? dropSetStages,
    double? restPauseWeight,
    int? restPauseTargetReps,
    List<Map<String, dynamic>>? restPauseSetsData,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      restAfterExercise: restAfterExercise ?? this.restAfterExercise,
      tut: tut ?? this.tut,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      calculated1RM: calculated1RM ?? this.calculated1RM,
      calculated3RM: calculated3RM ?? this.calculated3RM,
      calculated6RM: calculated6RM ?? this.calculated6RM,
      calculated10RM: calculated10RM ?? this.calculated10RM,
      lastCalculationDate: lastCalculationDate ?? this.lastCalculationDate,
      calculationMetadata: calculationMetadata ?? this.calculationMetadata,
      targetRPEMin: targetRPEMin ?? this.targetRPEMin,
      targetRPEMax: targetRPEMax ?? this.targetRPEMax,
      targetRIR: targetRIR ?? this.targetRIR,
      autoAdjustmentType: autoAdjustmentType ?? this.autoAdjustmentType,
      movementType: movementType ?? this.movementType,
      countingMode: countingMode ?? this.countingMode,
      supersetExercises: supersetExercises ?? this.supersetExercises,
      supersetSetsData: supersetSetsData ?? this.supersetSetsData,
      dropSetStages: dropSetStages ?? this.dropSetStages,
      restPauseWeight: restPauseWeight ?? this.restPauseWeight,
      restPauseTargetReps: restPauseTargetReps ?? this.restPauseTargetReps,
      restPauseSetsData: restPauseSetsData ?? this.restPauseSetsData,
    );
  }
}

/// Data model for ExerciseSet with complete field mapping
class ExerciseSetModel {
  const ExerciseSetModel({
    required this.id,
    required this.setNumber,
    this.weight,
    this.reps,
    this.minReps,
    this.maxReps,
    this.restTime,
    this.rpe,
    this.notes,
    this.completedAt,
    this.isCompletedLegacy = false,
    // TUT & Advanced Tracking
    this.setDurationMillis,
    this.setStartedAt,
    this.actualReps,
    this.isWarmup = false,
    this.seconds,
    this.distance, // ✅ Added for cardio support
    // ✅ Rest Timer Tracking
    this.restTimerSkipped = false,
    this.restTimerSecondsRemaining,
    this.restTimerSecondsAdded,
    this.actualRestSeconds,
  });

  factory ExerciseSetModel.fromDomain(ExerciseSet exerciseSet) {
    return ExerciseSetModel(
      id: exerciseSet.id,
      setNumber: exerciseSet.setNumber,
      weight: exerciseSet.weight,
      reps: exerciseSet.reps,
      minReps: exerciseSet.minReps,
      maxReps: exerciseSet.maxReps,
      restTime: exerciseSet.restTime, // ✅ FIX: Added missing restTime
      rpe: exerciseSet.rpe,
      notes: exerciseSet.notes,
      completedAt: exerciseSet.completedAt,
      setDurationMillis: exerciseSet.setDurationMillis,
      setStartedAt: exerciseSet.setStartedAt,
      actualReps: exerciseSet.actualReps,
      isWarmup: exerciseSet.isWarmup,
      seconds: exerciseSet.seconds,
      distance: exerciseSet.distance, // ✅ Added
      // ✅ Rest Timer Tracking
      restTimerSkipped: exerciseSet.restTimerSkipped,
      restTimerSecondsRemaining: exerciseSet.restTimerSecondsRemaining,
      restTimerSecondsAdded: exerciseSet.restTimerSecondsAdded,
      actualRestSeconds: exerciseSet.actualRestSeconds,
    );
  }

  factory ExerciseSetModel.fromJson(Map<dynamic, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // Firebase structure: setNumber, weight, reps, restSeconds, rpe, isWarmup, isDropSet, isFailure
    // NO id, NO volume, NO isCompleted in Firebase
    final id =
        (data['id'] as String?) ??
        'set-${DateTime.now().millisecondsSinceEpoch}';
    final setNumber = (data['setNumber'] as int?) ?? 0;

    final weight = (data['weight'] as num?)?.toDouble();
    final reps = data['reps'] as int?;

    // Firebase has 'restSeconds' not 'restTimeSeconds'
    final restTime =
        (data['restSeconds'] as int?) ?? (data['restTimeSeconds'] as int?);

    // isCompleted doesn't exist in Firebase
    // For historical workouts (from Firebase), ALL sets should be considered completed
    // since these are workouts that have already been finished
    final isCompletedFromJson = data['isCompleted'] as bool? ?? true;

    // Determine completedAt from data, or mark as legacy completed
    final DateTime? completedAt = _parseDateTime(data['completedAt']);
    // Legacy data: set was marked completed but has no timestamp
    final isLegacyCompleted = completedAt == null && isCompletedFromJson;

    final minReps = data['minReps'] as int?;
    final maxReps = data['maxReps'] as int?;

    return ExerciseSetModel(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      minReps: minReps,
      maxReps: maxReps,
      restTime: restTime,
      rpe: data['rpe'] as int?,
      notes: data['notes'] as String?,
      completedAt: completedAt,
      isCompletedLegacy: isLegacyCompleted,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: (data['setDurationMillis'] as num?)?.toDouble(),
      setStartedAt: _parseDateTime(data['setStartedAt']),
      actualReps: data['actualReps'] as int?,
      isWarmup: data['isWarmup'] as bool? ?? false,
      seconds: data['seconds'] as int?,
      distance: (data['distance'] as num?)?.toDouble(), // ✅ Added
      // ✅ Rest Timer Tracking
      restTimerSkipped: data['restTimerSkipped'] as bool? ?? false,
      restTimerSecondsRemaining: data['restTimerSecondsRemaining'] as int?,
      restTimerSecondsAdded: data['restTimerSecondsAdded'] as int?,
      actualRestSeconds: data['actualRestSeconds'] as int?,
    );
  }
  final String id;
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? minReps;
  final int? maxReps;
  final int? restTime;
  final int? rpe;
  final String? notes;
  final DateTime? completedAt;
  /// True when legacy data had isCompleted=true but no completedAt timestamp
  final bool isCompletedLegacy;
  // ✅ TUT & Advanced Tracking Fields
  final double? setDurationMillis;
  final DateTime? setStartedAt;
  final int? actualReps;
  final bool isWarmup;
  final int? seconds;
  final double? distance; // ✅ Added for cardio support
  // ✅ Rest Timer Tracking
  final bool restTimerSkipped;
  final int? restTimerSecondsRemaining;
  final int? restTimerSecondsAdded;
  final int? actualRestSeconds;

  /// Whether this set has been completed (from completedAt or legacy flag)
  bool get isCompleted => completedAt != null || isCompletedLegacy;

  /// Total volume for this set (weight × reps), or 0 if either is null
  double get volume => (weight ?? 0) * (reps ?? 0);

  ExerciseSet toDomain() {
    return ExerciseSet(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      minReps: minReps,
      maxReps: maxReps,
      isCompleted: isCompleted, // From completedAt or legacy flag
      rpe: rpe,
      notes: notes,
      completedAt: completedAt,
      setDurationMillis: setDurationMillis,
      setStartedAt: setStartedAt,
      actualReps: actualReps,
      isWarmup: isWarmup,
      seconds: seconds,
      distance: distance, // ✅ Added
      restTime: restTime, // ✅ FIX: Added missing restTime
      // ✅ Rest Timer Tracking
      restTimerSkipped: restTimerSkipped,
      restTimerSecondsRemaining: restTimerSecondsRemaining,
      restTimerSecondsAdded: restTimerSecondsAdded,
      actualRestSeconds: actualRestSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      if (minReps != null) 'minReps': minReps,
      if (maxReps != null) 'maxReps': maxReps,
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
      'distance': distance, // ✅ Added
      // ✅ Rest Timer Tracking
      'restTimerSkipped': restTimerSkipped,
      if (restTimerSecondsRemaining != null) 'restTimerSecondsRemaining': restTimerSecondsRemaining,
      if (restTimerSecondsAdded != null) 'restTimerSecondsAdded': restTimerSecondsAdded,
      if (actualRestSeconds != null) 'actualRestSeconds': actualRestSeconds,
    };
  }

  /// Create a copy with modified fields
  ExerciseSetModel copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    int? minReps,
    int? maxReps,
    int? restTime,
    int? rpe,
    String? notes,
    DateTime? completedAt,
    bool? isCompletedLegacy,
    double? setDurationMillis,
    DateTime? setStartedAt,
    int? actualReps,
    bool? isWarmup,
    int? seconds,
    double? distance,
    // ✅ Rest Timer Tracking
    bool? restTimerSkipped,
    int? restTimerSecondsRemaining,
    int? restTimerSecondsAdded,
    int? actualRestSeconds,
  }) {
    return ExerciseSetModel(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      restTime: restTime ?? this.restTime,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      // If a real completedAt is set, clear legacy flag
      isCompletedLegacy: completedAt != null ? false : (isCompletedLegacy ?? this.isCompletedLegacy),
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      setStartedAt: setStartedAt ?? this.setStartedAt,
      actualReps: actualReps ?? this.actualReps,
      isWarmup: isWarmup ?? this.isWarmup,
      seconds: seconds ?? this.seconds,
      distance: distance ?? this.distance,
      // ✅ Rest Timer Tracking
      restTimerSkipped: restTimerSkipped ?? this.restTimerSkipped,
      restTimerSecondsRemaining: restTimerSecondsRemaining ?? this.restTimerSecondsRemaining,
      restTimerSecondsAdded: restTimerSecondsAdded ?? this.restTimerSecondsAdded,
      actualRestSeconds: actualRestSeconds ?? this.actualRestSeconds,
    );
  }
}
