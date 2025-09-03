import 'package:equatable/equatable.dart';

/// Model representing an analytics activity (workout session)
class AnalyticsActivity extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final List<AnalyticsSet> sets;
  final double totalVolume;
  final int totalReps;
  final double maxWeight;
  final double? averageIntensity;
  final int? duration;
  final String? workoutId;
  final Map<String, dynamic>? metadata;

  const AnalyticsActivity({
    required this.id,
    required this.userId,
    required this.date,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.totalVolume,
    required this.totalReps,
    required this.maxWeight,
    this.averageIntensity,
    this.duration,
    this.workoutId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        exerciseId,
        exerciseName,
        muscleGroup,
        sets,
        totalVolume,
        totalReps,
        maxWeight,
        averageIntensity,
        duration,
        workoutId,
        metadata,
      ];

  /// Create from Firestore document
  factory AnalyticsActivity.fromMap(Map<String, dynamic> map) {
    return AnalyticsActivity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      muscleGroup: map['muscleGroup'] as String,
      sets: (map['sets'] as List<dynamic>)
          .map((s) => AnalyticsSet.fromMap(s as Map<String, dynamic>))
          .toList(),
      totalVolume: (map['totalVolume'] as num).toDouble(),
      totalReps: map['totalReps'] as int,
      maxWeight: (map['maxWeight'] as num).toDouble(),
      averageIntensity: (map['averageIntensity'] as num?)?.toDouble(),
      duration: map['duration'] as int?,
      workoutId: map['workoutId'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'sets': sets.map((s) => s.toMap()).toList(),
      'totalVolume': totalVolume,
      'totalReps': totalReps,
      'maxWeight': maxWeight,
      'averageIntensity': averageIntensity,
      'duration': duration,
      'workoutId': workoutId,
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  AnalyticsActivity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    List<AnalyticsSet>? sets,
    double? totalVolume,
    int? totalReps,
    double? maxWeight,
    double? averageIntensity,
    int? duration,
    String? workoutId,
    Map<String, dynamic>? metadata,
  }) {
    return AnalyticsActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      totalVolume: totalVolume ?? this.totalVolume,
      totalReps: totalReps ?? this.totalReps,
      maxWeight: maxWeight ?? this.maxWeight,
      averageIntensity: averageIntensity ?? this.averageIntensity,
      duration: duration ?? this.duration,
      workoutId: workoutId ?? this.workoutId,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Model representing a single set in an activity
class AnalyticsSet extends Equatable {
  final double weight;
  final int reps;
  final double? rpe;
  final int? restTime;
  final bool? isDropSet;
  final bool? isFailure;
  final String? notes;

  const AnalyticsSet({
    required this.weight,
    required this.reps,
    this.rpe,
    this.restTime,
    this.isDropSet,
    this.isFailure,
    this.notes,
  });

  @override
  List<Object?> get props => [
        weight,
        reps,
        rpe,
        restTime,
        isDropSet,
        isFailure,
        notes,
      ];

  /// Create from map
  factory AnalyticsSet.fromMap(Map<String, dynamic> map) {
    return AnalyticsSet(
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      rpe: (map['rpe'] as num?)?.toDouble(),
      restTime: map['restTime'] as int?,
      isDropSet: map['isDropSet'] as bool?,
      isFailure: map['isFailure'] as bool?,
      notes: map['notes'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'restTime': restTime,
      'isDropSet': isDropSet,
      'isFailure': isFailure,
      'notes': notes,
    };
  }

  /// Calculate volume for this set
  double get volume => weight * reps;
  
  /// Get estimated 1RM from this set
  double get estimated1RM {
    if (reps == 1) return weight;
    if (reps > 30) return 0; // Too many reps for accurate estimate
    
    // Using Brzycki formula
    return weight * (36 / (37 - reps));
  }

  /// Create copy with updated fields
  AnalyticsSet copyWith({
    double? weight,
    int? reps,
    double? rpe,
    int? restTime,
    bool? isDropSet,
    bool? isFailure,
    String? notes,
  }) {
    return AnalyticsSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      restTime: restTime ?? this.restTime,
      isDropSet: isDropSet ?? this.isDropSet,
      isFailure: isFailure ?? this.isFailure,
      notes: notes ?? this.notes,
    );
  }
}