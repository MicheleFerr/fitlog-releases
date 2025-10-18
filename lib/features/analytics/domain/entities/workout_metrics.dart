/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: analytics
/// 🔧 Type: entity
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - workout/domain/entities: Workout, Exercise, ExerciseSet
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';

/// Real-time workout metrics calculated during active workout
class WorkoutMetrics {

  const WorkoutMetrics({
    required this.workoutId,
    required this.calculatedAt,
    required this.totalVolume,
    required this.workingSetsVolume,
    required this.warmupVolume,
    required this.volumeByMuscleGroup,
    required this.totalSets,
    required this.completedSets,
    required this.workingSets,
    required this.warmupSets,
    required this.averageWeight,
    required this.averageRPE,
    required this.averageIntensity,
    required this.peakIntensity,
    required this.totalDuration,
    required this.workingTime,
    required this.restTime,
    required this.trainingDensity,
    required this.completionPercentage,
    required this.exercisesCompleted,
    required this.totalExercises,
    this.comparison,
    this.personalRecords = const [],
  });

  /// Create empty metrics for new workout
  factory WorkoutMetrics.empty(String workoutId) {
    return WorkoutMetrics(
      workoutId: workoutId,
      calculatedAt: DateTime.now(),
      totalVolume: 0,
      workingSetsVolume: 0,
      warmupVolume: 0,
      volumeByMuscleGroup: {},
      totalSets: 0,
      completedSets: 0,
      workingSets: 0,
      warmupSets: 0,
      averageWeight: 0,
      averageRPE: 0,
      averageIntensity: 0,
      peakIntensity: 0,
      totalDuration: Duration.zero,
      workingTime: Duration.zero,
      restTime: Duration.zero,
      trainingDensity: 0,
      completionPercentage: 0,
      exercisesCompleted: 0,
      totalExercises: 0,
    );
  }

  /// Calculate metrics from current workout state
  factory WorkoutMetrics.fromWorkout(Workout workout) {
    final now = DateTime.now();
    final allSets = workout.exercises
        .expand((exercise) => exercise.sets)
        .toList();
    
    final completedSets = allSets.where((set) => set.isCompleted).toList();
    final workingSets = completedSets.where((set) => !set.isWarmup).toList();
    final warmupSets = completedSets.where((set) => set.isWarmup).toList();
    
    // Calculate volume metrics
    final totalVolume = _calculateTotalVolume(completedSets);
    final workingSetsVolume = _calculateTotalVolume(workingSets);
    final warmupVolume = _calculateTotalVolume(warmupSets);
    final volumeByMuscleGroup = _calculateVolumeByMuscleGroup(workout.exercises);
    
    // Calculate intensity metrics
    final averageWeight = _calculateAverageWeight(workingSets);
    final averageRPE = _calculateAverageRPE(completedSets);
    final peakIntensity = _calculatePeakIntensity(workingSets);
    
    // Calculate duration metrics
    final totalDuration = workout.duration ?? Duration.zero;
    final workingTime = _calculateWorkingTime(completedSets);
    final restTime = totalDuration - workingTime;
    final trainingDensity = totalDuration.inMinutes > 0 
        ? totalVolume / totalDuration.inMinutes 
        : 0;
    
    return WorkoutMetrics(
      workoutId: workout.id,
      calculatedAt: now,
      totalVolume: totalVolume,
      workingSetsVolume: workingSetsVolume,
      warmupVolume: warmupVolume,
      volumeByMuscleGroup: volumeByMuscleGroup,
      totalSets: allSets.length,
      completedSets: completedSets.length,
      workingSets: workingSets.length,
      warmupSets: warmupSets.length,
      averageWeight: averageWeight,
      averageRPE: averageRPE,
      averageIntensity: 0.0, // TODO: Requires historical 1RM data
      peakIntensity: peakIntensity,
      totalDuration: totalDuration,
      workingTime: workingTime,
      restTime: restTime,
      trainingDensity: trainingDensity.toDouble(),
      completionPercentage: workout.progressPercentage,
      exercisesCompleted: workout.completedExercises,
      totalExercises: workout.exercises.length,
    );
  }
  final String workoutId;
  final DateTime calculatedAt;
  
  // Volume Metrics
  final double totalVolume;
  final double workingSetsVolume;
  final double warmupVolume;
  final Map<ExerciseCategory, double> volumeByMuscleGroup;
  
  // Set Metrics
  final int totalSets;
  final int completedSets;
  final int workingSets;
  final int warmupSets;
  
  // Intensity Metrics
  final double averageWeight;
  final double averageRPE;
  final double averageIntensity; // % of estimated 1RM
  final double peakIntensity;
  
  // Performance Metrics
  final Duration totalDuration;
  final Duration workingTime;
  final Duration restTime;
  final double trainingDensity; // volume per minute
  
  // Progress Metrics
  final double completionPercentage;
  final int exercisesCompleted;
  final int totalExercises;
  
  // Comparison Data
  final WorkoutComparison? comparison;
  final List<PersonalRecordAchieved> personalRecords;

  /// Get formatted volume string
  String get formattedVolume => '${totalVolume.toStringAsFixed(0)} kg';
  
  /// Get formatted training density
  String get formattedDensity => '${trainingDensity.toStringAsFixed(1)} kg/min';
  
  /// Get formatted duration
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Check if this is a strong workout (above average metrics)
  bool get isStrongWorkout {
    return totalVolume > 1000 && // Arbitrary threshold
           averageRPE >= 7.5 &&
           trainingDensity > 15;
  }

  /// Get workout quality score (0-100)
  double get qualityScore {
    double score = 0;
    
    // Volume contribution (40%)
    if (totalVolume > 0) {
      score += (totalVolume / 2000) * 40; // Normalize to ~2000kg max
    }
    
    // Intensity contribution (30%)
    if (averageRPE > 0) {
      score += ((averageRPE - 5) / 5) * 30; // RPE 5-10 normalized
    }
    
    // Completion contribution (20%)
    score += completionPercentage * 20;
    
    // Consistency contribution (10%)
    if (workingSets > 0) {
      final completionRate = completedSets / totalSets;
      score += completionRate * 10;
    }
    
    return score.clamp(0, 100);
  }

  WorkoutMetrics copyWith({
    DateTime? calculatedAt,
    double? totalVolume,
    double? workingSetsVolume,
    double? warmupVolume,
    Map<ExerciseCategory, double>? volumeByMuscleGroup,
    int? totalSets,
    int? completedSets,
    int? workingSets,
    int? warmupSets,
    double? averageWeight,
    double? averageRPE,
    double? averageIntensity,
    double? peakIntensity,
    Duration? totalDuration,
    Duration? workingTime,
    Duration? restTime,
    double? trainingDensity,
    double? completionPercentage,
    int? exercisesCompleted,
    int? totalExercises,
    WorkoutComparison? comparison,
    List<PersonalRecordAchieved>? personalRecords,
  }) {
    return WorkoutMetrics(
      workoutId: workoutId,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      totalVolume: totalVolume ?? this.totalVolume,
      workingSetsVolume: workingSetsVolume ?? this.workingSetsVolume,
      warmupVolume: warmupVolume ?? this.warmupVolume,
      volumeByMuscleGroup: volumeByMuscleGroup ?? this.volumeByMuscleGroup,
      totalSets: totalSets ?? this.totalSets,
      completedSets: completedSets ?? this.completedSets,
      workingSets: workingSets ?? this.workingSets,
      warmupSets: warmupSets ?? this.warmupSets,
      averageWeight: averageWeight ?? this.averageWeight,
      averageRPE: averageRPE ?? this.averageRPE,
      averageIntensity: averageIntensity ?? this.averageIntensity,
      peakIntensity: peakIntensity ?? this.peakIntensity,
      totalDuration: totalDuration ?? this.totalDuration,
      workingTime: workingTime ?? this.workingTime,
      restTime: restTime ?? this.restTime,
      trainingDensity: trainingDensity ?? this.trainingDensity,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      totalExercises: totalExercises ?? this.totalExercises,
      comparison: comparison ?? this.comparison,
      personalRecords: personalRecords ?? this.personalRecords,
    );
  }

  // Static helper methods
  
  static double _calculateTotalVolume(List<ExerciseSet> sets) {
    return sets.fold(0.0, (total, set) => total + set.volume);
  }
  
  static Map<ExerciseCategory, double> _calculateVolumeByMuscleGroup(
    List<Exercise> exercises,
  ) {
    final volumeByGroup = <ExerciseCategory, double>{};
    
    for (final exercise in exercises) {
      final exerciseVolume = _calculateTotalVolume(
        exercise.sets.where((set) => set.isCompleted).toList(),
      );
      
      volumeByGroup[exercise.category] = 
          (volumeByGroup[exercise.category] ?? 0) + exerciseVolume;
    }
    
    return volumeByGroup;
  }
  
  static double _calculateAverageWeight(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;

    final totalWeight = sets.fold(0.0, (total, set) => total + (set.weight ?? 0.0));
    return totalWeight / sets.length;
  }
  
  static double _calculateAverageRPE(List<ExerciseSet> sets) {
    final setsWithRPE = sets.where((set) => set.rpe != null).toList();
    if (setsWithRPE.isEmpty) return 0;
    
    final totalRPE = setsWithRPE.fold(0, (total, set) => total + (set.rpe ?? 0));
    return totalRPE / setsWithRPE.length;
  }
  
  static double _calculatePeakIntensity(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;

    return sets.fold(0.0, (peak, set) {
      final weight = set.weight ?? 0.0;
      final reps = set.reps ?? 0;
      final intensity = weight * reps;
      return intensity > peak ? intensity : peak;
    });
  }
  
  static Duration _calculateWorkingTime(List<ExerciseSet> sets) {
    // Estimate working time based on completed sets
    // Rough estimate: 30 seconds per set
    return Duration(seconds: sets.length * 30);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'calculatedAt': calculatedAt.toIso8601String(),
      'totalVolume': totalVolume,
      'workingSetsVolume': workingSetsVolume,
      'warmupVolume': warmupVolume,
      'totalSets': totalSets,
      'workingSets': workingSets,
      'warmupSets': warmupSets,
    };
    /*return {
      'workoutId': workoutId,
      'calculatedAt': calculatedAt.toIso8601String(),
      'totalVolume': totalVolume,
      'workingSetsVolume': workingSetsVolume,
      'warmupVolume': warmupVolume,
      'totalSets': totalSets,
      'workingSets': workingSets,
      'warmupSets': warmupSets,
      'totalReps': totalReps,
      'averageRepsPerSet': averageRepsPerSet,
      'maxConsecutiveSets': maxConsecutiveSets,
      'exercisesPerformed': exercisesPerformed,
      'uniqueExercises': uniqueExercises,
      'exerciseVariety': exerciseVariety,
      'targetCompletionRate': targetCompletionRate,
      'progressiveOverload': progressiveOverload,
      'intensityScore': intensityScore,
      'trainingDensity': trainingDensity,
      'fatigueIndex': fatigueIndex,
      'formConsistency': formConsistency,
      'workloadBalance': workloadBalance,
    };*/
  }

  static WorkoutMetrics fromJson(Map<String, dynamic> json) {
    // Simplified version
    return WorkoutMetrics(
      workoutId: json['workoutId'] ?? '',
      calculatedAt: DateTime.parse(json['calculatedAt']),
      totalVolume: (json['totalVolume'] ?? 0).toDouble(),
      workingSetsVolume: (json['workingSetsVolume'] ?? 0).toDouble(),
      warmupVolume: (json['warmupVolume'] ?? 0).toDouble(),
      volumeByMuscleGroup: {},
      totalSets: json['totalSets'] ?? 0,
      completedSets: json['completedSets'] ?? 0,
      workingSets: json['workingSets'] ?? 0,
      warmupSets: json['warmupSets'] ?? 0,
      averageWeight: (json['averageWeight'] ?? 0).toDouble(),
      averageRPE: (json['averageRPE'] ?? 0).toDouble(),
      averageIntensity: (json['averageIntensity'] ?? 0).toDouble(),
      peakIntensity: (json['peakIntensity'] ?? 0).toDouble(),
      totalDuration: json['totalDuration'] != null 
        ? Duration(seconds: json['totalDuration']) 
        : Duration.zero,
      workingTime: json['workingTime'] != null 
        ? Duration(seconds: json['workingTime']) 
        : Duration.zero,
      restTime: json['restTime'] != null 
        ? Duration(seconds: json['restTime']) 
        : Duration.zero,
      trainingDensity: (json['trainingDensity'] ?? 0).toDouble(),
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
      exercisesCompleted: json['exercisesCompleted'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
    );
  }
}

/// Comparison with previous similar workouts
class WorkoutComparison { // -100 to +100

  const WorkoutComparison({
    required this.comparisonId,
    required this.comparisonDate,
    required this.comparisonName,
    required this.volumeChange,
    required this.volumeChangePercentage,
    required this.intensityChange,
    required this.intensityChangePercentage,
    required this.durationChange,
    required this.densityChange,
    required this.improvementScore,
  });
  final String comparisonId;
  final DateTime comparisonDate;
  final String comparisonName;
  
  // Volume comparison
  final double volumeChange;
  final double volumeChangePercentage;
  
  // Intensity comparison
  final double intensityChange;
  final double intensityChangePercentage;
  
  // Performance comparison
  final Duration durationChange;
  final double densityChange;
  
  // Overall improvement score
  final double improvementScore;

  /// Check if this represents an improvement
  bool get isImprovement => improvementScore > 5;
  
  /// Check if performance was similar (within 5%)
  bool get isSimilar => improvementScore.abs() <= 5;
  
  /// Check if performance decreased
  bool get isRegression => improvementScore < -5;

  /// Get formatted volume change
  String get formattedVolumeChange {
    final sign = volumeChange >= 0 ? '+' : '';
    return '$sign${volumeChange.toStringAsFixed(0)} kg (${volumeChangePercentage.toStringAsFixed(1)}%)';
  }

  /// Get formatted intensity change
  String get formattedIntensityChange {
    final sign = intensityChange >= 0 ? '+' : '';
    return '$sign${intensityChange.toStringAsFixed(1)} RPE (${intensityChangePercentage.toStringAsFixed(1)}%)';
  }

  /// Get formatted duration change
  String get formattedDurationChange {
    final minutes = durationChange.inMinutes.abs();
    final sign = durationChange.isNegative ? '-' : '+';
    return '$sign${minutes}m';
  }
}

/// Personal record achieved during workout
class PersonalRecordAchieved {

  const PersonalRecordAchieved({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.newValue,
    this.previousValue,
    required this.achievedAt,
    this.context = const {},
  });
  final String exerciseId;
  final String exerciseName;
  final PRType type;
  final double newValue;
  final double? previousValue;
  final DateTime achievedAt;
  final Map<String, dynamic> context;

  /// Get improvement percentage
  double get improvementPercentage {
    if (previousValue == null || previousValue == 0) return 100;
    return ((newValue - previousValue!) / previousValue!) * 100;
  }

  /// Check if this is a significant PR (>2.5% improvement)
  bool get isSignificant => improvementPercentage > 2.5;

  /// Get formatted improvement
  String get formattedImprovement {
    return '+${improvementPercentage.toStringAsFixed(1)}%';
  }

  /// Get user-friendly type description
  String get typeDescription {
    switch (type) {
      case PRType.weight:
        return 'Max Weight';
      case PRType.reps:
        return 'Max Reps';
      case PRType.volume:
        return 'Volume PR';
      case PRType.oneRM:
        return '1RM Est.';
      case PRType.totalSets:
        return 'Most Sets';
      case PRType.duration:
        return 'Endurance';
    }
  }
}

// PRType enum is imported from pr_tracker.dart