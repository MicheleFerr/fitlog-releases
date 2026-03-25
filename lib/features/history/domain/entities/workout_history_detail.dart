/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: history
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Complete workout history entity with full exercise details
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

DateTime? _parseFirestoreDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Complete workout history with all exercise details
class WorkoutHistoryDetail {
  // ID of the workout template used

  const WorkoutHistoryDetail({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.startedAt,
    required this.completedAt,
    required this.updatedAt,
    required this.duration,
    required this.exercises,
    required this.metadata,
    this.templateId,
  });

  /// Create empty workout for deletion
  factory WorkoutHistoryDetail.empty({required String id}) {
    return WorkoutHistoryDetail(
      id: id,
      userId: '',
      name: '',
      description: '',
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      duration: Duration.zero,
      exercises: [],
      metadata: {},
    );
  }

  /// Create from Firestore document
  factory WorkoutHistoryDetail.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = _parseFirestoreDate(data['createdAt']) ?? DateTime.now();
    final startedAt =
        _parseFirestoreDate(data['startedAt']) ??
        _parseFirestoreDate(data['startTime']) ??
        createdAt;
    final completedAt =
        _parseFirestoreDate(data['completedAt']) ??
        _parseFirestoreDate(data['endTime']) ??
        DateTime.now();
    final durationMinutes =
        (data['durationMinutes'] as num?)?.toInt() ??
        completedAt.difference(startedAt).inMinutes;

    return WorkoutHistoryDetail(
      id: doc.id,
      userId: data['userId'] ?? doc.reference.parent.parent?.id ?? '',
      name: data['name'] ?? 'Unknown Workout',
      description: data['description'] ?? '',
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      updatedAt: _parseFirestoreDate(data['updatedAt']) ?? DateTime.now(),
      duration: Duration(minutes: durationMinutes),
      exercises:
          (data['exercises'] as List<dynamic>?)
              ?.map(
                (e) => ExerciseHistoryDetail.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      templateId: data['templateId'] as String?,
    );
  }

  /// Create from local Map
  factory WorkoutHistoryDetail.fromMap(Map<dynamic, dynamic> map) {
    final createdAt =
        _parseFirestoreDate(map['createdAt']) ??
        _parseFirestoreDate(map['startTime']) ??
        DateTime.now();
    final startedAt =
        _parseFirestoreDate(map['startedAt']) ??
        _parseFirestoreDate(map['startTime']) ??
        createdAt;
    final completedAt =
        _parseFirestoreDate(map['completedAt']) ??
        _parseFirestoreDate(map['endTime']) ??
        createdAt;
    final updatedAt = _parseFirestoreDate(map['updatedAt']) ?? completedAt;
    final rawDurationMinutes = (map['durationMinutes'] as num?)?.toInt();

    return WorkoutHistoryDetail(
      id: map['id'] ?? '',
      userId: map['userId'] ?? map['_userId'] ?? '',
      name: map['name'] ?? 'Unknown Workout',
      description: map['description'] ?? '',
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      updatedAt: updatedAt,
      duration: Duration(
        minutes:
            rawDurationMinutes ??
            (completedAt.isAfter(startedAt)
                ? completedAt.difference(startedAt).inMinutes
                : 0),
      ),
      exercises:
          (map['exercises'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ExerciseHistoryDetail.fromMap(e as Map<dynamic, dynamic>),
              )
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      templateId: map['templateId'] as String?,
    );
  }
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime startedAt;
  final DateTime completedAt;
  final DateTime updatedAt;
  final Duration duration;
  final List<ExerciseHistoryDetail> exercises;
  final Map<String, dynamic> metadata;
  final String? templateId;

  /// Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'metadata': metadata,
      'templateId': templateId,
    };
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'startTime': Timestamp.fromDate(startedAt),
      'startedAt': Timestamp.fromDate(startedAt),
      'endTime': Timestamp.fromDate(completedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'updatedAt': Timestamp.fromDate(
        DateTime.now(),
      ), // Always update timestamp
      'status': 'completed',
      'durationMinutes': duration.inMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'metadata': metadata,
      'templateId': templateId,
    };
  }

  /// Calculated properties
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  }

  int get totalReps {
    return exercises.fold(0, (sum, exercise) => sum + exercise.totalReps);
  }

  double get averageRPE {
    final allSets = exercises.expand((e) => e.sets).where((s) => s.rpe > 0);
    if (allSets.isEmpty) return 0.0;
    return allSets.map((s) => s.rpe).reduce((a, b) => a + b) / allSets.length;
  }

  /// Health imports are not considered first-party app workouts and must stay
  /// out of the workout history shown by the app.
  bool get isHealthImportedWorkout {
    final source = metadata['source']?.toString().toLowerCase();
    final healthSource = metadata['healthSource']?.toString().toLowerCase();

    return source == 'apple_health_import' ||
        source == 'healthkit_import' ||
        source == 'health_connect_import' ||
        healthSource == 'healthkit' ||
        healthSource == 'health connect';
  }

  /// Create copy with modifications
  WorkoutHistoryDetail copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    Duration? duration,
    List<ExerciseHistoryDetail>? exercises,
    Map<String, dynamic>? metadata,
    String? templateId,
  }) {
    return WorkoutHistoryDetail(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      metadata: metadata ?? this.metadata,
      templateId: templateId ?? this.templateId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutHistoryDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert to Workout entity for editing
  Workout toWorkout() {
    return Workout(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      startTime: startedAt,
      endTime: completedAt,
      status: WorkoutStatus.completed,
      exercises: exercises.map((e) => e.toExercise()).toList(),
    );
  }
}

/// Exercise history with complete details
class ExerciseHistoryDetail {
  const ExerciseHistoryDetail({
    required this.id,
    required this.name,
    required this.category,
    this.notes,
    required this.sets,
    required this.exerciseData,
  });

  /// Create from Map
  factory ExerciseHistoryDetail.fromMap(Map<dynamic, dynamic> map) {
    // Extract and normalize exerciseData to convert old muscle names to canonical
    final rawExerciseData = map['exerciseData'] as Map<dynamic, dynamic>? ?? {};
    final normalizedExerciseData = _normalizeExerciseData(
      Map<String, dynamic>.from(rawExerciseData),
    );

    return ExerciseHistoryDetail(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      notes: map['notes'],
      sets:
          (map['sets'] as List<dynamic>?)
              ?.map((s) => SetHistoryDetail.fromMap(s as Map<dynamic, dynamic>))
              .toList() ??
          [],
      exerciseData: normalizedExerciseData,
    );
  }

  /// Normalize exerciseData to convert old muscle names to canonical
  ///
  /// Converts legacy muscle abbreviations (FEMOR, BIC, LOMBAR, etc.) to
  /// canonical 4-letter standard (FEMO, BICI, LOMB) using MuscleAbbreviationMapper.
  ///
  /// **Fields normalized**:
  /// - `focus`: List<String> of primary muscles
  /// - `muscoliSecondari`: List<String> of secondary muscles
  ///
  /// **Example**:
  /// ```dart
  /// {
  ///   'focus': ['FEMOR', 'GLUT'],  // Old
  ///   'muscoliSecondari': ['BIC', 'LOMBAR']
  /// }
  /// // After normalization:
  /// {
  ///   'focus': ['FEMO', 'GLUT'],   // New canonical
  ///   'muscoliSecondari': ['BICI', 'LOMB']
  /// }
  /// ```
  static Map<String, dynamic> _normalizeExerciseData(
    Map<String, dynamic> data,
  ) {
    final normalized = Map<String, dynamic>.from(data);

    // Normalize focus field (primary muscles)
    if (normalized['focus'] != null) {
      final focus = normalized['focus'];
      if (focus is List) {
        normalized['focus'] = focus
            .map(
              (muscle) => MuscleAbbreviationMapper.normalizeToCanonicalId(
                muscle.toString(),
              ),
            )
            .toList();
      } else if (focus is String) {
        // Handle comma-separated string format
        final muscles = focus
            .split(',')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty);
        normalized['focus'] = muscles
            .map(
              (muscle) =>
                  MuscleAbbreviationMapper.normalizeToCanonicalId(muscle),
            )
            .toList();
      }
    }

    // Normalize muscoliSecondari field (secondary muscles)
    if (normalized['muscoliSecondari'] != null) {
      final secondary = normalized['muscoliSecondari'];
      if (secondary is List) {
        normalized['muscoliSecondari'] = secondary
            .map(
              (muscle) => MuscleAbbreviationMapper.normalizeToCanonicalId(
                muscle.toString(),
              ),
            )
            .toList();
      } else if (secondary is String) {
        // Handle comma-separated string format
        final muscles = secondary
            .split(',')
            .map((m) => m.trim())
            .where((m) => m.isNotEmpty);
        normalized['muscoliSecondari'] = muscles
            .map(
              (muscle) =>
                  MuscleAbbreviationMapper.normalizeToCanonicalId(muscle),
            )
            .toList();
      }
    }

    return normalized;
  }

  final String id;
  final String name;
  final String category;
  final String? notes;
  final List<SetHistoryDetail> sets;
  final Map<String, dynamic> exerciseData;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'notes': notes,
      'sets': sets.map((s) => s.toMap()).toList(),
      'exerciseData': exerciseData,
    };
  }

  /// Calculated properties
  ///
  /// Total volume for this exercise across all sets.
  /// - Weighted exercises: sum of (weight × reps) for each set
  /// - Bodyweight exercises: sum of reps (rep count as volume proxy)
  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + set.volume);
  }

  int get totalReps {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }

  double get maxWeight {
    if (sets.isEmpty) return 0.0;
    return sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }

  double get averageRPE {
    final setsWithRPE = sets.where((s) => s.rpe > 0);
    if (setsWithRPE.isEmpty) return 0.0;
    return setsWithRPE.map((s) => s.rpe).reduce((a, b) => a + b) /
        setsWithRPE.length;
  }

  /// Create copy with modifications
  ExerciseHistoryDetail copyWith({
    String? id,
    String? name,
    String? category,
    String? notes,
    List<SetHistoryDetail>? sets,
    Map<String, dynamic>? exerciseData,
  }) {
    return ExerciseHistoryDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
      exerciseData: exerciseData ?? this.exerciseData,
    );
  }

  /// Convert to Exercise entity for editing
  Exercise toExercise() {
    // 🔧 FIX: Read countingMode from exerciseData for bodyweight volume calculation
    final countingModeStr = exerciseData['countingMode'] as String?;
    final countingMode = ExerciseCountingMode.fromString(countingModeStr);

    return Exercise(
      id: id,
      databaseExerciseId:
          exerciseData['databaseExerciseId'] as String? ?? id,
      name: name,
      type: ExerciseType.single,
      category: _parseCategory(category),
      sets: sets.map((s) => s.toExerciseSet()).toList(),
      notes: notes,
      countingMode: countingMode,
    );
  }

  ExerciseCategory _parseCategory(String categoryString) {
    return ExerciseCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == categoryString.toLowerCase(),
      orElse: () => ExerciseCategory.other,
    );
  }
}

/// Set history with complete details
class SetHistoryDetail {
  // Actual reps completed (vs planned reps)

  const SetHistoryDetail({
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.rpe,
    this.restSeconds,
    this.notes,
    this.isWarmup = false,
    this.isDropSet = false,
    this.isFailure = false,
    // ✅ TUT & Advanced Tracking
    this.setDurationMillis,
    this.setStartedAt,
    this.completedAt,
    this.actualReps,
  });

  /// Create from Map
  factory SetHistoryDetail.fromMap(Map<dynamic, dynamic> map) {
    return SetHistoryDetail(
      setNumber: map['setNumber'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      reps: map['reps'] ?? 0,
      rpe: map['rpe'] ?? 0,
      restSeconds: map['restSeconds'],
      notes: map['notes'],
      isWarmup: map['isWarmup'] ?? false,
      isDropSet: map['isDropSet'] ?? false,
      isFailure: map['isFailure'] ?? false,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: (map['setDurationMillis'] as num?)?.toDouble(),
      setStartedAt: _parseFirestoreDate(map['setStartedAt']),
      completedAt: _parseFirestoreDate(map['completedAt']),
      actualReps: (map['actualReps'] as num?)?.toInt(),
    );
  }
  final int setNumber;
  final double weight;
  final int reps;
  final int rpe; // Rate of Perceived Exertion (1-10)
  final int? restSeconds;
  final String? notes;
  final bool isWarmup;
  final bool isDropSet;
  final bool isFailure;
  // ✅ TUT & Advanced Tracking Fields
  final double? setDurationMillis; // Duration in milliseconds (TUT)
  final DateTime? setStartedAt; // Timestamp when set started
  final DateTime? completedAt; // Timestamp when set completed
  final int? actualReps;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'restSeconds': restSeconds,
      'notes': notes,
      'isWarmup': isWarmup,
      'isDropSet': isDropSet,
      'isFailure': isFailure,
      // ✅ TUT & Advanced Tracking Fields
      'setDurationMillis': setDurationMillis,
      'setStartedAt': setStartedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'actualReps': actualReps,
    };
  }

  /// Calculated properties
  ///
  /// Volume for this set.
  /// - Weighted exercises (weight > 0): volume = weight × reps
  /// - Bodyweight exercises (weight = 0): volume = reps (rep count as proxy)
  double get volume => weight > 0 ? weight * reps : reps.toDouble();

  /// Estimated 1RM using Epley formula
  double get estimated1RM {
    if (reps <= 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  /// Create copy with modifications
  SetHistoryDetail copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    int? rpe,
    int? restSeconds,
    String? notes,
    bool? isWarmup,
    bool? isDropSet,
    bool? isFailure,
    // ✅ TUT & Advanced Tracking Fields
    double? setDurationMillis,
    DateTime? setStartedAt,
    DateTime? completedAt,
    int? actualReps,
  }) {
    return SetHistoryDetail(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropSet: isDropSet ?? this.isDropSet,
      isFailure: isFailure ?? this.isFailure,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      setStartedAt: setStartedAt ?? this.setStartedAt,
      completedAt: completedAt ?? this.completedAt,
      actualReps: actualReps ?? this.actualReps,
    );
  }

  /// Convert to ExerciseSet for editing
  ExerciseSet toExerciseSet() {
    return ExerciseSet(
      id: '$setNumber',
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      actualReps: actualReps ?? reps,
      rpe: rpe,
      isCompleted: true,
      isWarmup: isWarmup,
      // ✅ TUT & Advanced Tracking Fields
      setDurationMillis: setDurationMillis,
      setStartedAt: setStartedAt,
      completedAt: completedAt,
    );
  }
}
