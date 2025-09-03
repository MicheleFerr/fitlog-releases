import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';

/// Calculator for various volume metrics
class VolumeCalculator {
  /// Calculate total volume (sets × reps × weight)
  static double calculateTotalVolume(List<ExerciseActivitySet> sets) {
    if (sets.isEmpty) return 0;
    
    return sets.fold(0.0, (total, set) {
      if (!set.done) return total;
      
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      
      // Adjust for warmup sets (count at 50% value)
      final multiplier = set.isWarmup ? 0.5 : 1.0;
      
      return total + (weight * reps * multiplier);
    });
  }

  /// Calculate tonnage (total weight moved)
  static double calculateTonnage(List<ExerciseActivitySet> sets) {
    return calculateTotalVolume(sets);
  }

  /// Calculate average intensity (average weight used)
  static double calculateAverageIntensity(List<ExerciseActivitySet> sets) {
    if (sets.isEmpty) return 0;
    
    final workingSets = sets.where((set) => set.done && !set.isWarmup).toList();
    if (workingSets.isEmpty) return 0;
    
    final totalWeight = workingSets.fold(0.0, (total, set) {
      return total + (double.tryParse(set.weight) ?? 0);
    });
    
    return totalWeight / workingSets.length;
  }

  /// Calculate volume per muscle group
  static Map<String, double> calculateVolumeByMuscleGroup(
    List<ExerciseActivity> activities,
  ) {
    final volumeByGroup = <String, double>{};
    
    for (final activity in activities) {
      final muscleGroup = _categorizeExercise(activity.exerciseName);
      final volume = calculateTotalVolume(activity.sets);
      
      volumeByGroup[muscleGroup] = (volumeByGroup[muscleGroup] ?? 0) + volume;
    }
    
    return volumeByGroup;
  }

  /// Calculate weekly volume
  static Map<int, double> calculateWeeklyVolume(
    List<ExerciseActivity> activities,
  ) {
    final now = DateTime.now();
    final weeklyVolume = <int, double>{};
    
    for (final activity in activities) {
      final weekNumber = _getWeekNumber(activity.createdAt, now);
      if (weekNumber > 52) continue; // Only last year
      
      final volume = calculateTotalVolume(activity.sets);
      weeklyVolume[weekNumber] = (weeklyVolume[weekNumber] ?? 0) + volume;
    }
    
    return weeklyVolume;
  }

  /// Calculate daily volume for last 30 days
  static Map<DateTime, double> calculateDailyVolume(
    List<ExerciseActivity> activities,
  ) {
    final dailyVolume = <DateTime, double>{};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    for (final activity in activities) {
      if (activity.createdAt.isBefore(thirtyDaysAgo)) continue;
      
      final date = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      
      final volume = calculateTotalVolume(activity.sets);
      dailyVolume[date] = (dailyVolume[date] ?? 0) + volume;
    }
    
    return dailyVolume;
  }

  /// Calculate volume progression (% change over periods)
  static VolumeProgression calculateProgression(
    List<ExerciseActivity> activities,
  ) {
    final now = DateTime.now();
    
    // Calculate for different periods
    final thisWeek = _calculatePeriodVolume(
      activities,
      now.subtract(const Duration(days: 7)),
      now,
    );
    
    final lastWeek = _calculatePeriodVolume(
      activities,
      now.subtract(const Duration(days: 14)),
      now.subtract(const Duration(days: 7)),
    );
    
    final thisMonth = _calculatePeriodVolume(
      activities,
      DateTime(now.year, now.month, 1),
      now,
    );
    
    final lastMonth = _calculatePeriodVolume(
      activities,
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 1).subtract(const Duration(days: 1)),
    );
    
    return VolumeProgression(
      weeklyChange: _calculatePercentageChange(lastWeek, thisWeek),
      monthlyChange: _calculatePercentageChange(lastMonth, thisMonth),
      currentWeekVolume: thisWeek,
      currentMonthVolume: thisMonth,
    );
  }

  /// Calculate training density (volume per minute)
  static double calculateTrainingDensity(
    List<ExerciseActivitySet> sets,
    Duration workoutDuration,
  ) {
    if (workoutDuration.inMinutes == 0) return 0;
    
    final totalVolume = calculateTotalVolume(sets);
    return totalVolume / workoutDuration.inMinutes;
  }

  /// Calculate effective reps (adjusted for RPE/effort)
  static int calculateEffectiveReps(List<ExerciseActivitySet> sets) {
    return sets.fold(0, (total, set) {
      if (!set.done) return total;
      
      final reps = int.tryParse(set.actualReps ?? set.reps) ?? 0;
      
      // Adjust based on effort level (1-5 scale)
      // Effort 5 (max) = 100%, Effort 1 (easy) = 60%
      final effortMultiplier = 0.6 + (set.effort * 0.1);
      
      // Warmup sets count as 50% effective
      final warmupMultiplier = set.isWarmup ? 0.5 : 1.0;
      
      return total + (reps * effortMultiplier * warmupMultiplier).round();
    });
  }

  /// Calculate relative volume (volume per body weight)
  static double calculateRelativeVolume(
    double totalVolume,
    double bodyWeight,
  ) {
    if (bodyWeight <= 0) return 0;
    return totalVolume / bodyWeight;
  }

  /// Get volume statistics
  static VolumeStats getVolumeStats(List<ExerciseActivity> activities) {
    if (activities.isEmpty) {
      return VolumeStats.empty();
    }
    
    final volumes = activities.map((a) => calculateTotalVolume(a.sets)).toList();
    volumes.sort();
    
    final total = volumes.fold(0.0, (sum, v) => sum + v);
    final average = total / volumes.length;
    
    // Calculate median
    final median = volumes.length.isOdd
        ? volumes[volumes.length ~/ 2]
        : (volumes[volumes.length ~/ 2 - 1] + volumes[volumes.length ~/ 2]) / 2;
    
    // Calculate standard deviation
    final squaredDiffs = volumes.map((v) => (v - average) * (v - average));
    final avgSquaredDiff = squaredDiffs.fold(0.0, (sum, v) => sum + v) / volumes.length;
    final stdDev = avgSquaredDiff > 0 ? avgSquaredDiff.toString() : '0';
    
    return VolumeStats(
      total: total,
      average: average,
      median: median,
      min: volumes.first,
      max: volumes.last,
      standardDeviation: double.tryParse(stdDev) ?? 0,
      count: volumes.length,
    );
  }

  // Helper methods
  
  static String _categorizeExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('chest') || name.contains('bench') || name.contains('fly')) {
      return 'Chest';
    } else if (name.contains('back') || name.contains('row') || name.contains('pull')) {
      return 'Back';
    } else if (name.contains('shoulder') || name.contains('press') || name.contains('delt')) {
      return 'Shoulders';
    } else if (name.contains('squat') || name.contains('leg') || name.contains('calf')) {
      return 'Legs';
    } else if (name.contains('bicep') || name.contains('tricep') || name.contains('curl')) {
      return 'Arms';
    } else if (name.contains('ab') || name.contains('core') || name.contains('plank')) {
      return 'Core';
    } else {
      return 'Other';
    }
  }

  static int _getWeekNumber(DateTime date, DateTime reference) {
    final diff = reference.difference(date).inDays;
    return diff ~/ 7;
  }

  static double _calculatePeriodVolume(
    List<ExerciseActivity> activities,
    DateTime start,
    DateTime end,
  ) {
    return activities
        .where((a) => a.createdAt.isAfter(start) && a.createdAt.isBefore(end))
        .fold(0.0, (sum, a) => sum + calculateTotalVolume(a.sets));
  }

  static double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100 : 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}

/// Volume progression data
class VolumeProgression {
  final double weeklyChange;
  final double monthlyChange;
  final double currentWeekVolume;
  final double currentMonthVolume;

  const VolumeProgression({
    required this.weeklyChange,
    required this.monthlyChange,
    required this.currentWeekVolume,
    required this.currentMonthVolume,
  });

  bool get isImproving => weeklyChange > 0 && monthlyChange > 0;
  bool get isPlateau => weeklyChange.abs() < 5 && monthlyChange.abs() < 5;
}

/// Volume statistics
class VolumeStats {
  final double total;
  final double average;
  final double median;
  final double min;
  final double max;
  final double standardDeviation;
  final int count;

  const VolumeStats({
    required this.total,
    required this.average,
    required this.median,
    required this.min,
    required this.max,
    required this.standardDeviation,
    required this.count,
  });

  factory VolumeStats.empty() {
    return const VolumeStats(
      total: 0,
      average: 0,
      median: 0,
      min: 0,
      max: 0,
      standardDeviation: 0,
      count: 0,
    );
  }

  double get coefficientOfVariation {
    if (average == 0) return 0;
    return (standardDeviation / average) * 100;
  }
}