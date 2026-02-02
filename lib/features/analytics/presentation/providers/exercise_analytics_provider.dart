/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/providers
/// Feature: analytics
/// Type: provider
///
/// ExerciseAnalytics Provider - Computes and caches exercise analytics data
///
/// **Key Features**:
/// - FutureProvider.family for exercise-specific analytics
/// - Cached correlation calculations (computed once, not on each sheet open)
/// - Async computation to prevent UI jank
///
/// **Usage**:
/// ```dart
/// final analytics = ref.watch(exerciseAnalyticsProvider(exerciseId));
/// analytics.when(
///   data: (data) => _buildCharts(data),
///   loading: () => LoadingIndicator(),
///   error: (e, _) => ErrorWidget(e),
/// );
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_analytics_data.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/correlation_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/scientific_metrics_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';

/// Provider for exercise analytics data with cached correlations
///
/// Uses FutureProvider.family to compute analytics per exercise.
/// Correlations are calculated ONCE when the provider is first accessed,
/// not on each bottom sheet open (Critical Fix #2 from design doc).
final exerciseAnalyticsProvider =
    FutureProvider.family<ExerciseAnalyticsData?, String>((
      ref,
      exerciseId,
    ) async {
      // Get exercise metrics from existing provider
      final metrics = ref.watch(exerciseMetricsProvider(exerciseId));

      if (metrics == null || metrics.totalSessions < 1) {
        return null;
      }

      // Extract data for calculations
      final sets = metrics.allSets;
      if (sets.isEmpty) return null;

      // Build chart data points
      final weightHistory = <ChartDataPoint>[];
      final volumeHistory = <ChartDataPoint>[];
      final rpeHistory = <ChartDataPoint>[];

      // Group sets by session date for better chart representation
      final sessionsByDate = <DateTime, List<ExerciseSetData>>{};
      for (final set in sets) {
        final dateKey = DateTime(set.date.year, set.date.month, set.date.day);
        sessionsByDate.putIfAbsent(dateKey, () => []).add(set);
      }

      // Process each session
      var sessionIndex = 0;
      final sortedDates = sessionsByDate.keys.toList()..sort();

      for (final date in sortedDates) {
        final sessionSets = sessionsByDate[date]!;
        sessionIndex++;

        // Calculate session aggregates
        final maxWeight = sessionSets.fold<double>(
          0,
          (max, set) => set.weight > max ? set.weight : max,
        );
        final totalVolume = sessionSets.fold<double>(
          0,
          (sum, set) => sum + set.volume,
        );

        // Get average RPE for session (if any sets have RPE)
        final setsWithRpe = sessionSets.where((s) => s.rpe != null);
        final avgRpe = setsWithRpe.isNotEmpty
            ? setsWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) /
                  setsWithRpe.length
            : null;

        // Get representative reps (from heaviest set)
        final heaviestSet = sessionSets.reduce(
          (a, b) => a.weight > b.weight ? a : b,
        );

        weightHistory.add(
          ChartDataPoint(
            date: date,
            value: maxWeight,
            rpe: avgRpe?.round(),
            reps: heaviestSet.reps,
            sessionIndex: sessionIndex,
          ),
        );

        volumeHistory.add(
          ChartDataPoint(
            date: date,
            value: totalVolume,
            sessionIndex: sessionIndex,
          ),
        );

        if (avgRpe != null) {
          rpeHistory.add(
            ChartDataPoint(
              date: date,
              value: avgRpe,
              rpe: avgRpe.round(),
              sessionIndex: sessionIndex,
            ),
          );
        }
      }

      // Calculate correlations (async for performance with large datasets)
      final correlations = await _calculateCorrelations(
        weightHistory: weightHistory,
        volumeHistory: volumeHistory,
        rpeHistory: rpeHistory,
      );

      // Calculate trend using existing TrendAnalyzer (simplified)
      final trend = _calculateTrend(weightHistory, volumeHistory);

      // Calculate progressive overload
      final overload = _calculateOverload(volumeHistory);

      // Calculate intensity (1RM estimation)
      final intensity = _calculateIntensity(
        metrics.maxWeight,
        sets.isNotEmpty ? sets.last.reps : 0,
      );

      // Calculate data span
      final firstDate = sortedDates.first;
      final lastDate = sortedDates.last;
      final dataSpanDays = lastDate.difference(firstDate).inDays;

      return ExerciseAnalyticsData(
        exerciseId: exerciseId,
        exerciseName: metrics.exerciseName,
        weightHistory: weightHistory,
        volumeHistory: volumeHistory,
        rpeHistory: rpeHistory,
        trend: trend,
        overload: overload,
        intensity: intensity,
        correlations: correlations,
        lastUpdated: DateTime.now(),
        sessionCount: sessionIndex,
        dataSpanDays: dataSpanDays,
      );
    });

/// Calculate correlations using the CorrelationCalculator service
Future<CorrelationResults> _calculateCorrelations({
  required List<ChartDataPoint> weightHistory,
  required List<ChartDataPoint> volumeHistory,
  required List<ChartDataPoint> rpeHistory,
}) async {
  // Need at least 3 data points for meaningful correlation
  if (rpeHistory.length < 3) {
    return CorrelationResults.empty();
  }

  // Align data by session index for correlation calculation
  final alignedWeights = <double>[];
  final alignedVolumes = <double>[];
  final alignedRpes = <double>[];

  for (final rpePoint in rpeHistory) {
    final weightPoint = weightHistory.firstWhere(
      (w) => w.sessionIndex == rpePoint.sessionIndex,
      orElse: () => ChartDataPoint(date: DateTime.now(), value: 0),
    );
    final volumePoint = volumeHistory.firstWhere(
      (v) => v.sessionIndex == rpePoint.sessionIndex,
      orElse: () => ChartDataPoint(date: DateTime.now(), value: 0),
    );

    if (weightPoint.value > 0 && volumePoint.value > 0) {
      alignedWeights.add(weightPoint.value);
      alignedVolumes.add(volumePoint.value);
      alignedRpes.add(rpePoint.value);
    }
  }

  if (alignedRpes.length < 3) {
    return CorrelationResults.empty();
  }

  // Calculate correlations using async method for large datasets
  return CorrelationCalculator.calculateAllCorrelations(
    weights: alignedWeights,
    volumes: alignedVolumes,
    rpes: alignedRpes,
  );
}

/// Calculate trend using simplified logic
TrendAnalysis _calculateTrend(
  List<ChartDataPoint> weightHistory,
  List<ChartDataPoint> volumeHistory,
) {
  if (weightHistory.length < 3) {
    return TrendAnalysis(
      type: TrendType.inconsistent,
      slope: 0,
      correlation: 0,
      currentValue: weightHistory.isNotEmpty ? weightHistory.last.value : 0,
      predictedValue: weightHistory.isNotEmpty ? weightHistory.last.value : 0,
      recommendation: 'Need more data to establish trend',
    );
  }

  // Simple linear regression for weight progression
  final n = weightHistory.length;
  final xMean = (n - 1) / 2;
  final yMean = weightHistory.fold<double>(0, (sum, p) => sum + p.value) / n;

  var numerator = 0.0;
  var denomX = 0.0;
  var denomY = 0.0;

  for (var i = 0; i < n; i++) {
    final xDiff = i - xMean;
    final yDiff = weightHistory[i].value - yMean;
    numerator += xDiff * yDiff;
    denomX += xDiff * xDiff;
    denomY += yDiff * yDiff;
  }

  final slope = denomX > 0 ? numerator / denomX : 0.0;
  final correlation = (denomX > 0 && denomY > 0)
      ? numerator / (denomX * denomY)
      : 0.0;

  // Determine trend type
  TrendType type;
  String recommendation;

  if (correlation.abs() < 0.3) {
    type = TrendType.inconsistent;
    recommendation = 'Training pattern is inconsistent. Focus on consistency.';
  } else if (slope.abs() < 0.5) {
    type = TrendType.plateau;
    recommendation =
        'Weight has plateaued. Try different rep ranges or variations.';
  } else if (slope > 0) {
    type = TrendType.improving;
    recommendation = 'Great progress! Continue progressive overload.';
  } else {
    type = TrendType.declining;
    recommendation = 'Weight declining. Check recovery and form.';
  }

  // Calculate average volume
  final avgVolume = volumeHistory.isNotEmpty
      ? volumeHistory.fold<double>(0, (sum, p) => sum + p.value) /
            volumeHistory.length
      : 0.0;

  return TrendAnalysis(
    type: type,
    slope: slope,
    correlation: correlation,
    currentValue: weightHistory.last.value,
    predictedValue: weightHistory.last.value + slope,
    recommendation: recommendation,
    averageVolume: avgVolume,
  );
}

/// Calculate progressive overload metrics
ProgressiveOverloadData _calculateOverload(List<ChartDataPoint> volumeHistory) {
  if (volumeHistory.length < 2) {
    return ProgressiveOverloadData.noBaseline();
  }

  final currentVolume = volumeHistory.last.value;
  final previousVolume = volumeHistory[volumeHistory.length - 2].value;

  if (previousVolume == 0) {
    return ProgressiveOverloadData.noBaseline();
  }

  final overloadPercent =
      ((currentVolume - previousVolume) / previousVolume) * 100;

  // Determine status based on intermediate user thresholds (1-3%)
  OverloadStatus status;
  if (overloadPercent < 0) {
    status = OverloadStatus.belowTarget;
  } else if (overloadPercent <= 5) {
    status = OverloadStatus.optimal;
  } else {
    status = OverloadStatus.aboveTarget;
  }

  return ProgressiveOverloadData(
    currentPercent: overloadPercent,
    targetMin: 1.0,
    targetMax: 3.0,
    status: status,
    userLevel: 'intermediate',
    currentVolume: currentVolume,
    previousVolume: previousVolume,
  );
}

/// Calculate intensity (1RM estimation) using scientific formulas
IntensityData _calculateIntensity(double weight, int reps) {
  if (weight <= 0 || reps <= 0) {
    return IntensityData.empty();
  }

  final result = ScientificMetricsService.calculateRelativeIntensity(
    weight: weight,
    reps: reps,
  );

  return IntensityData(
    estimated1RM: result.estimated1RM,
    currentWeight: weight,
    currentReps: reps,
    percentOf1RM: result.percentOf1RM,
    formula: result.formula,
    confidence: result.reliability,
    zone: result.zone,
  );
}
