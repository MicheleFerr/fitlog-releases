import 'package:uuid/uuid.dart';

/// Comprehensive training metrics for smart analysis
class SmartTrainingMetrics {
  final String id;
  final String userId;
  final DateTime date;
  final double volume; // Total volume (weight * reps)
  final int totalSets;
  final int totalReps;
  final double averageIntensity; // Average %1RM
  final double trainingLoad; // Volume * Intensity
  final int sessionDuration; // Minutes
  final double fatigueScore; // 1-10 scale
  final double readinessScore; // 1-10 scale
  final Map<String, double> muscleGroupVolume; // Volume per muscle group
  final List<ExerciseMetrics> exerciseMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  SmartTrainingMetrics({
    String? id,
    required this.userId,
    required this.date,
    required this.volume,
    required this.totalSets,
    required this.totalReps,
    required this.averageIntensity,
    required this.trainingLoad,
    required this.sessionDuration,
    required this.fatigueScore,
    required this.readinessScore,
    required this.muscleGroupVolume,
    required this.exerciseMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  SmartTrainingMetrics copyWith({
    String? userId,
    DateTime? date,
    double? volume,
    int? totalSets,
    int? totalReps,
    double? averageIntensity,
    double? trainingLoad,
    int? sessionDuration,
    double? fatigueScore,
    double? readinessScore,
    Map<String, double>? muscleGroupVolume,
    List<ExerciseMetrics>? exerciseMetrics,
    DateTime? updatedAt,
  }) {
    return SmartTrainingMetrics(
      id: id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      volume: volume ?? this.volume,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      averageIntensity: averageIntensity ?? this.averageIntensity,
      trainingLoad: trainingLoad ?? this.trainingLoad,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      readinessScore: readinessScore ?? this.readinessScore,
      muscleGroupVolume: muscleGroupVolume ?? this.muscleGroupVolume,
      exerciseMetrics: exerciseMetrics ?? this.exerciseMetrics,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'volume': volume,
      'totalSets': totalSets,
      'totalReps': totalReps,
      'averageIntensity': averageIntensity,
      'trainingLoad': trainingLoad,
      'sessionDuration': sessionDuration,
      'fatigueScore': fatigueScore,
      'readinessScore': readinessScore,
      'muscleGroupVolume': muscleGroupVolume,
      'exerciseMetrics': exerciseMetrics.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SmartTrainingMetrics.fromJson(Map<String, dynamic> json) {
    return SmartTrainingMetrics(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      volume: (json['volume'] as num).toDouble(),
      totalSets: json['totalSets'],
      totalReps: json['totalReps'],
      averageIntensity: (json['averageIntensity'] as num).toDouble(),
      trainingLoad: (json['trainingLoad'] as num).toDouble(),
      sessionDuration: json['sessionDuration'],
      fatigueScore: (json['fatigueScore'] as num).toDouble(),
      readinessScore: (json['readinessScore'] as num).toDouble(),
      muscleGroupVolume: Map<String, double>.from(json['muscleGroupVolume']),
      exerciseMetrics: (json['exerciseMetrics'] as List)
          .map((e) => ExerciseMetrics.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Exercise-specific metrics for analysis
class ExerciseMetrics {
  final String exerciseName;
  final String category;
  final double volume;
  final double maxWeight;
  final double averageWeight;
  final int totalSets;
  final int totalReps;
  final double averageRPE;
  final double estimatedOneRM;
  final double intensityScore; // Based on %1RM
  final List<SetMetrics> setMetrics;

  ExerciseMetrics({
    required this.exerciseName,
    required this.category,
    required this.volume,
    required this.maxWeight,
    required this.averageWeight,
    required this.totalSets,
    required this.totalReps,
    required this.averageRPE,
    required this.estimatedOneRM,
    required this.intensityScore,
    required this.setMetrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'category': category,
      'volume': volume,
      'maxWeight': maxWeight,
      'averageWeight': averageWeight,
      'totalSets': totalSets,
      'totalReps': totalReps,
      'averageRPE': averageRPE,
      'estimatedOneRM': estimatedOneRM,
      'intensityScore': intensityScore,
      'setMetrics': setMetrics.map((s) => s.toJson()).toList(),
    };
  }

  factory ExerciseMetrics.fromJson(Map<String, dynamic> json) {
    return ExerciseMetrics(
      exerciseName: json['exerciseName'],
      category: json['category'],
      volume: (json['volume'] as num).toDouble(),
      maxWeight: (json['maxWeight'] as num).toDouble(),
      averageWeight: (json['averageWeight'] as num).toDouble(),
      totalSets: json['totalSets'],
      totalReps: json['totalReps'],
      averageRPE: (json['averageRPE'] as num).toDouble(),
      estimatedOneRM: (json['estimatedOneRM'] as num).toDouble(),
      intensityScore: (json['intensityScore'] as num).toDouble(),
      setMetrics: (json['setMetrics'] as List)
          .map((s) => SetMetrics.fromJson(s))
          .toList(),
    );
  }
}

/// Individual set metrics
class SetMetrics {
  final int setNumber;
  final double weight;
  final int targetReps;
  final int actualReps;
  final int rpe;
  final double estimatedOneRM;
  final double intensityPercent; // %1RM
  final double volume;
  final bool isWarmup;

  SetMetrics({
    required this.setNumber,
    required this.weight,
    required this.targetReps,
    required this.actualReps,
    required this.rpe,
    required this.estimatedOneRM,
    required this.intensityPercent,
    required this.volume,
    required this.isWarmup,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'rpe': rpe,
      'estimatedOneRM': estimatedOneRM,
      'intensityPercent': intensityPercent,
      'volume': volume,
      'isWarmup': isWarmup,
    };
  }

  factory SetMetrics.fromJson(Map<String, dynamic> json) {
    return SetMetrics(
      setNumber: json['setNumber'],
      weight: (json['weight'] as num).toDouble(),
      targetReps: json['targetReps'],
      actualReps: json['actualReps'],
      rpe: json['rpe'],
      estimatedOneRM: (json['estimatedOneRM'] as num).toDouble(),
      intensityPercent: (json['intensityPercent'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      isWarmup: json['isWarmup'],
    );
  }
}

/// Training phase for periodization
enum TrainingPhase {
  hypertrophy,
  strength,
  power,
  endurance,
  deload,
  maintenance,
}

/// Training status indicators
enum TrainingStatus {
  fresh,
  ready,
  moderate,
  fatigued,
  overtrained,
}

/// Progressive overload method
enum OverloadMethod {
  volume,
  intensity,
  frequency,
  density,
  range,
}