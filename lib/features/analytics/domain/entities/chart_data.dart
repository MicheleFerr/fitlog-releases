/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Data models per grafici e visualizzazioni analytics
library;

import 'package:flutter/material.dart';

/// 📊 Data point per grafici temporali
class ChartDataPoint {
  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.metadata,
  });

  final DateTime date;
  final double value;
  final String? label;
  final Map<String, dynamic>? metadata;
}

/// 📈 Serie di dati per un esercizio/muscle group
class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.dataPoints,
    required this.color,
    this.showTrendline = false,
  });

  final String name;
  final List<ChartDataPoint> dataPoints;
  final Color color;
  final bool showTrendline;

  /// Calcola trendline con regressione lineare
  List<ChartDataPoint> get trendline {
    if (dataPoints.length < 2) return [];

    // Linear regression: y = mx + b
    final n = dataPoints.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = dataPoints[i].value;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - m * sumX) / n;

    return List.generate(n, (i) {
      return ChartDataPoint(
        date: dataPoints[i].date,
        value: m * i + b,
      );
    });
  }

  /// Percentuale di crescita totale
  double get growthPercentage {
    if (dataPoints.isEmpty || dataPoints.length < 2) return 0;
    final first = dataPoints.first.value;
    final last = dataPoints.last.value;
    if (first == 0) return 0;
    return ((last - first) / first) * 100;
  }
}

/// 🗓️ Dati per frequency heatmap
class FrequencyHeatmapData {
  const FrequencyHeatmapData({
    required this.date,
    required this.workoutCount,
    required this.intensity,
  });

  final DateTime date;
  final int workoutCount;
  final double intensity; // 0.0-1.0

  /// Colore basato su intensità
  Color get color {
    if (workoutCount == 0) return Colors.grey.shade200;
    if (intensity < 0.3) return Colors.green.shade200;
    if (intensity < 0.6) return Colors.green.shade400;
    if (intensity < 0.8) return Colors.green.shade600;
    return Colors.green.shade800;
  }
}

/// 📊 Distribuzione volume per muscle group
class MuscleVolumeDistribution {
  const MuscleVolumeDistribution({
    required this.muscleGroup,
    required this.totalSets,
    required this.percentage,
    required this.isBalanced,
  });

  final String muscleGroup;
  final int totalSets;
  final double percentage;
  final bool isBalanced; // Entro MEV-MAV

  Color get statusColor {
    if (isBalanced) return Colors.green;
    if (totalSets < 10) return Colors.orange; // Undertrained
    return Colors.red; // Overtrained
  }
}
