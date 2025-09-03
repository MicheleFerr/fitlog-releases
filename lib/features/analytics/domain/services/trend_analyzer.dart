import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

/// Types of trends that can be analyzed
enum TrendType {
  improving,    // Positive trend
  declining,    // Negative trend
  plateau,      // No significant change
  inconsistent, // Too variable to determine
}

/// Time periods for analysis
enum AnalysisPeriod {
  week,
  month,
  quarter,
  year,
}

/// Trend analysis result
class TrendAnalysis {
  final TrendType type;
  final double slope;          // Rate of change
  final double correlation;    // Strength of trend (0-1)
  final double currentValue;
  final double predictedValue; // Next period prediction
  final String recommendation;
  final Map<String, dynamic> metadata;

  TrendAnalysis({
    required this.type,
    required this.slope,
    required this.correlation,
    required this.currentValue,
    required this.predictedValue,
    required this.recommendation,
    this.metadata = const {},
  });

  /// Get percentage change
  double get percentageChange {
    if (currentValue == 0) return 0;
    return ((predictedValue - currentValue) / currentValue) * 100;
  }

  /// Check if trend is statistically significant
  bool get isSignificant => correlation.abs() > 0.7;
}

/// Service for analyzing workout trends
class TrendAnalyzer {
  /// Analyze volume trend over time
  static TrendAnalysis analyzeVolumeTrend(
    List<ExerciseActivity> activities,
    AnalysisPeriod period,
  ) {
    if (activities.isEmpty) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: 0,
        predictedValue: 0,
        recommendation: 'Start tracking workouts to see trends',
      );
    }

    // Group activities by period and calculate volume
    final volumeByPeriod = _groupVolumeByPeriod(activities, period);
    
    if (volumeByPeriod.length < 3) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: volumeByPeriod.isNotEmpty ? volumeByPeriod.values.last : 0,
        predictedValue: volumeByPeriod.isNotEmpty ? volumeByPeriod.values.last : 0,
        recommendation: 'Need more data to establish trend',
      );
    }

    // Perform linear regression
    final regression = _performLinearRegression(volumeByPeriod);
    
    // Determine trend type
    final trendType = _determineTrendType(regression.slope, regression.correlation);
    
    // Generate recommendation
    final recommendation = _generateVolumeRecommendation(trendType, regression.slope);
    
    return TrendAnalysis(
      type: trendType,
      slope: regression.slope,
      correlation: regression.correlation,
      currentValue: volumeByPeriod.values.last,
      predictedValue: regression.predictNext(),
      recommendation: recommendation,
      metadata: {
        'dataPoints': volumeByPeriod.length,
        'period': period.name,
      },
    );
  }

  /// Analyze strength progression for an exercise
  static TrendAnalysis analyzeStrengthTrend(
    List<ExerciseActivity> activities,
    String exerciseId,
  ) {
    final exerciseActivities = activities
        .where((a) => a.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (exerciseActivities.isEmpty) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: 0,
        predictedValue: 0,
        recommendation: 'No data for this exercise',
      );
    }

    // Calculate 1RM for each session
    final oneRMByDate = <DateTime, double>{};
    
    for (final activity in exerciseActivities) {
      double maxEstimated1RM = 0;
      
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        
        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          maxEstimated1RM = math.max(maxEstimated1RM, estimated1RM);
        }
      }
      
      if (maxEstimated1RM > 0) {
        oneRMByDate[activity.createdAt] = maxEstimated1RM;
      }
    }

    if (oneRMByDate.length < 3) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: oneRMByDate.isNotEmpty ? oneRMByDate.values.last : 0,
        predictedValue: oneRMByDate.isNotEmpty ? oneRMByDate.values.last : 0,
        recommendation: 'Need more sessions to establish trend',
      );
    }

    // Convert to indexed map for regression
    final indexedData = <int, double>{};
    var index = 0;
    for (final value in oneRMByDate.values) {
      indexedData[index++] = value;
    }

    final regression = _performLinearRegression(indexedData);
    final trendType = _determineTrendType(regression.slope, regression.correlation);
    final recommendation = _generateStrengthRecommendation(
      trendType,
      regression.slope,
      exerciseActivities.first.exerciseName,
    );

    return TrendAnalysis(
      type: trendType,
      slope: regression.slope,
      correlation: regression.correlation,
      currentValue: oneRMByDate.values.last,
      predictedValue: regression.predictNext(),
      recommendation: recommendation,
      metadata: {
        'exercise': exerciseActivities.first.exerciseName,
        'sessions': oneRMByDate.length,
      },
    );
  }

  /// Detect plateau in progress
  static PlateauDetection detectPlateau(
    List<ExerciseActivity> activities,
    String exerciseId,
  ) {
    final trend = analyzeStrengthTrend(activities, exerciseId);
    
    // Check for plateau conditions
    final isPlateaued = trend.type == TrendType.plateau ||
        (trend.type == TrendType.improving && trend.slope < 0.5) ||
        (trend.correlation < 0.3);
    
    if (!isPlateaued) {
      return PlateauDetection(
        isPlateaued: false,
        duration: 0,
        recommendation: 'Progress is on track',
      );
    }

    // Calculate plateau duration
    final exerciseActivities = activities
        .where((a) => a.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (exerciseActivities.length < 4) {
      return PlateauDetection(
        isPlateaued: false,
        duration: 0,
        recommendation: 'Need more data',
      );
    }

    // Find when plateau started
    var plateauStart = exerciseActivities.length - 1;
    final recentMax = trend.currentValue;
    
    for (var i = exerciseActivities.length - 2; i >= 0; i--) {
      final activity = exerciseActivities[i];
      double maxWeight = 0;
      
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        maxWeight = math.max(maxWeight, weight);
      }
      
      // If weight differs by more than 5%, plateau hasn't started yet
      if ((maxWeight - recentMax).abs() / recentMax > 0.05) {
        break;
      }
      plateauStart = i;
    }

    final plateauDuration = exerciseActivities.length - plateauStart;
    final daysSincePlateau = DateTime.now()
        .difference(exerciseActivities[plateauStart].createdAt)
        .inDays;

    return PlateauDetection(
      isPlateaued: true,
      duration: daysSincePlateau,
      sessionsInPlateau: plateauDuration,
      recommendation: _generatePlateauRecommendation(daysSincePlateau),
    );
  }

  /// Analyze workout frequency trend
  static TrendAnalysis analyzeFrequencyTrend(
    List<ExerciseActivity> activities,
  ) {
    if (activities.isEmpty) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: 0,
        predictedValue: 0,
        recommendation: 'Start tracking workouts',
      );
    }

    // Group by week and count unique workout days
    final workoutsByWeek = <int, int>{};
    final now = DateTime.now();
    
    for (final activity in activities) {
      final weeksDiff = now.difference(activity.createdAt).inDays ~/ 7;
      if (weeksDiff > 12) continue; // Last 12 weeks only
      
      final weekKey = 12 - weeksDiff;
      workoutsByWeek[weekKey] = (workoutsByWeek[weekKey] ?? 0) + 1;
    }

    if (workoutsByWeek.length < 3) {
      return TrendAnalysis(
        type: TrendType.inconsistent,
        slope: 0,
        correlation: 0,
        currentValue: (workoutsByWeek.values.lastOrNull ?? 0).toDouble(),
        predictedValue: (workoutsByWeek.values.lastOrNull ?? 0).toDouble(),
        recommendation: 'Need more weeks of data',
      );
    }

    // Convert to double map for regression
    final doubleWorkoutsByWeek = workoutsByWeek.map((k, v) => MapEntry(k, v.toDouble()));
    final regression = _performLinearRegression(doubleWorkoutsByWeek);
    final trendType = _determineTrendType(regression.slope, regression.correlation);
    final recommendation = _generateFrequencyRecommendation(trendType, regression.slope);

    return TrendAnalysis(
      type: trendType,
      slope: regression.slope,
      correlation: regression.correlation,
      currentValue: workoutsByWeek.values.last.toDouble(),
      predictedValue: regression.predictNext(),
      recommendation: recommendation,
    );
  }

  /// Predict next workout performance
  static PerformancePrediction predictNextWorkout(
    List<ExerciseActivity> activities,
    String exerciseId,
  ) {
    final strengthTrend = analyzeStrengthTrend(activities, exerciseId);
    final volumeTrend = analyzeVolumeTrend(activities, AnalysisPeriod.week);
    
    // Calculate suggested working weight (85% of predicted 1RM)
    final predicted1RM = strengthTrend.predictedValue;
    final workingWeight = predicted1RM * 0.85;
    
    // Suggest rep range based on recent performance
    final recentActivities = activities
        .where((a) => a.exerciseId == exerciseId)
        .take(3)
        .toList();
    
    final avgReps = recentActivities.isEmpty
        ? 8
        : recentActivities
            .expand((a) => a.sets)
            .where((s) => s.done && !s.isWarmup)
            .map((s) => int.tryParse(s.reps) ?? 0)
            .fold(0, (sum, r) => sum + r) ~/
            math.max(1, recentActivities.expand((a) => a.sets).length);
    
    return PerformancePrediction(
      predicted1RM: predicted1RM,
      suggestedWeight: workingWeight.roundToPlate(),
      suggestedReps: avgReps,
      confidenceLevel: strengthTrend.correlation,
      recommendation: _generateWorkoutRecommendation(
        strengthTrend.type,
        volumeTrend.type,
      ),
    );
  }

  // Helper methods
  
  static Map<int, double> _groupVolumeByPeriod(
    List<ExerciseActivity> activities,
    AnalysisPeriod period,
  ) {
    final grouped = <int, double>{};
    final now = DateTime.now();
    
    for (final activity in activities) {
      final periodKey = _getPeriodKey(activity.createdAt, now, period);
      if (periodKey < 0) continue;
      
      final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
      grouped[periodKey] = (grouped[periodKey] ?? 0) + volume;
    }
    
    return grouped;
  }

  static int _getPeriodKey(DateTime date, DateTime reference, AnalysisPeriod period) {
    final diff = reference.difference(date);
    
    switch (period) {
      case AnalysisPeriod.week:
        final weeks = diff.inDays ~/ 7;
        return weeks > 52 ? -1 : 52 - weeks;
      case AnalysisPeriod.month:
        final months = (reference.year - date.year) * 12 + (reference.month - date.month);
        return months > 12 ? -1 : 12 - months;
      case AnalysisPeriod.quarter:
        final quarters = ((reference.year - date.year) * 4) + 
            ((reference.month - 1) ~/ 3) - ((date.month - 1) ~/ 3);
        return quarters > 8 ? -1 : 8 - quarters;
      case AnalysisPeriod.year:
        final years = reference.year - date.year;
        return years > 5 ? -1 : 5 - years;
    }
  }

  static LinearRegression _performLinearRegression(Map<int, double> data) {
    if (data.isEmpty) {
      return LinearRegression(slope: 0, intercept: 0, correlation: 0);
    }

    final n = data.length;
    final keys = data.keys.toList()..sort();
    
    // Calculate means
    final xMean = keys.fold(0.0, (sum, x) => sum + x) / n;
    final yMean = data.values.fold(0.0, (sum, y) => sum + y) / n;
    
    // Calculate slope and correlation
    var numerator = 0.0;
    var denominatorX = 0.0;
    var denominatorY = 0.0;
    
    for (final x in keys) {
      final y = data[x]!;
      final xDiff = x - xMean;
      final yDiff = y - yMean;
      
      numerator += xDiff * yDiff;
      denominatorX += xDiff * xDiff;
      denominatorY += yDiff * yDiff;
    }
    
    if (denominatorX == 0) {
      return LinearRegression(slope: 0, intercept: yMean, correlation: 0);
    }
    
    final slope = numerator / denominatorX;
    final intercept = yMean - slope * xMean;
    
    final correlation = denominatorX * denominatorY == 0
        ? 0
        : numerator / math.sqrt(denominatorX * denominatorY);
    
    return LinearRegression(
      slope: slope,
      intercept: intercept,
      correlation: correlation.toDouble(),
      lastX: keys.last,
    );
  }

  static TrendType _determineTrendType(double slope, double correlation) {
    final absCorrelation = correlation.abs();
    
    // Weak correlation = inconsistent
    if (absCorrelation < 0.3) return TrendType.inconsistent;
    
    // Check slope magnitude
    final slopePercent = slope.abs();
    
    if (slopePercent < 1) return TrendType.plateau;
    if (slope > 0) return TrendType.improving;
    return TrendType.declining;
  }

  static String _generateVolumeRecommendation(TrendType type, double slope) {
    switch (type) {
      case TrendType.improving:
        if (slope > 10) {
          return 'Excellent progress! Consider a deload week soon to avoid overtraining';
        }
        return 'Good volume progression. Keep it up!';
      case TrendType.declining:
        return 'Volume is decreasing. Consider adding an extra set or exercise';
      case TrendType.plateau:
        return 'Volume has plateaued. Try progressive overload or new exercises';
      case TrendType.inconsistent:
        return 'Training volume is inconsistent. Try to maintain regular workouts';
    }
  }

  static String _generateStrengthRecommendation(
    TrendType type,
    double slope,
    String exerciseName,
  ) {
    switch (type) {
      case TrendType.improving:
        return 'Great strength gains on $exerciseName! Continue progressive overload';
      case TrendType.declining:
        return 'Strength declining on $exerciseName. Check recovery and form';
      case TrendType.plateau:
        return '$exerciseName has plateaued. Try different rep ranges or variations';
      case TrendType.inconsistent:
        return 'Inconsistent performance on $exerciseName. Focus on consistency';
    }
  }

  static String _generateFrequencyRecommendation(TrendType type, double slope) {
    switch (type) {
      case TrendType.improving:
        return 'Training frequency improving! Maintain this consistency';
      case TrendType.declining:
        return 'Training less frequently. Try to maintain regular schedule';
      case TrendType.plateau:
        return 'Consistent training frequency. Good job maintaining routine!';
      case TrendType.inconsistent:
        return 'Irregular training pattern. Set a fixed schedule for better results';
    }
  }

  static String _generatePlateauRecommendation(int daysSincePlateau) {
    if (daysSincePlateau < 14) {
      return 'Early plateau detected. Increase intensity or volume slightly';
    } else if (daysSincePlateau < 30) {
      return 'Plateau for ${daysSincePlateau} days. Consider deload then new program';
    } else {
      return 'Extended plateau. Time for program change or technique review';
    }
  }

  static String _generateWorkoutRecommendation(
    TrendType strengthTrend,
    TrendType volumeTrend,
  ) {
    if (strengthTrend == TrendType.improving && volumeTrend == TrendType.improving) {
      return 'All systems go! Push for a new PR today';
    } else if (strengthTrend == TrendType.plateau) {
      return 'Focus on perfect form and consider increasing volume';
    } else if (volumeTrend == TrendType.declining) {
      return 'Low recent volume. Start conservative and build up';
    } else {
      return 'Maintain current intensity and focus on consistency';
    }
  }
}

/// Linear regression result
class LinearRegression {
  final double slope;
  final double intercept;
  final double correlation;
  final int lastX;

  LinearRegression({
    required this.slope,
    required this.intercept,
    required this.correlation,
    this.lastX = 0,
  });

  double predictNext() {
    return slope * (lastX + 1) + intercept;
  }

  double predict(int x) {
    return slope * x + intercept;
  }
}

/// Plateau detection result
class PlateauDetection {
  final bool isPlateaued;
  final int duration; // Days
  final int sessionsInPlateau;
  final String recommendation;

  PlateauDetection({
    required this.isPlateaued,
    required this.duration,
    this.sessionsInPlateau = 0,
    required this.recommendation,
  });
}

/// Performance prediction for next workout
class PerformancePrediction {
  final double predicted1RM;
  final double suggestedWeight;
  final int suggestedReps;
  final double confidenceLevel;
  final String recommendation;

  PerformancePrediction({
    required this.predicted1RM,
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.confidenceLevel,
    required this.recommendation,
  });
}