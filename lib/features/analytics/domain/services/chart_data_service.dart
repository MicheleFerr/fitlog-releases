/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Servizio che trasforma dati raw in dati pronti per grafici
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/chart_data.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// 📊 Servizio che trasforma dati raw in dati pronti per grafici
class ChartDataService {
  /// Genera serie temporale per volume totale settimanale
  static ChartSeries generateWeeklyVolumeChart(
    List<ExerciseActivity> activities,
  ) {
    // Raggruppa per settimana
    final weeklyData = <DateTime, double>{};

    for (final activity in activities) {
      final weekStart = _getWeekStart(activity.createdAt);
      final volume = _calculateActivityVolume(activity);
      weeklyData[weekStart] = (weeklyData[weekStart] ?? 0) + volume;
    }

    // Converti in ChartDataPoint
    final points = weeklyData.entries
        .map((e) => ChartDataPoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return ChartSeries(
      name: 'Volume Settimanale',
      dataPoints: points,
      color: context.colors.primary,
      showTrendline: true,
    );
  }

  /// Genera serie per progressione peso su esercizio specifico
  static ChartSeries generateWeightProgressionChart(
    List<ExerciseActivity> activities,
    String exerciseName,
  ) {
    final filtered = activities
        .where((a) => a.exerciseName.toLowerCase() == exerciseName.toLowerCase())
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final points = filtered.map((activity) {
      return ChartDataPoint(
        date: activity.createdAt,
        value: _getMaxWeight(activity),
        metadata: {
          'sets': activity.sets.length,
          'reps': activity.sets.isNotEmpty ? activity.sets.first.reps : 0,
        },
      );
    }).toList();

    return ChartSeries(
      name: exerciseName,
      dataPoints: points,
      color: context.colors.success,
      showTrendline: true,
    );
  }

  /// Genera dati heatmap frequenza
  static List<FrequencyHeatmapData> generateFrequencyHeatmap(
    List<ExerciseActivity> activities,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Conta workout per giorno
    final dailyWorkouts = <DateTime, int>{};
    final dailyIntensity = <DateTime, double>{};

    for (final activity in activities) {
      final day = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );

      dailyWorkouts[day] = (dailyWorkouts[day] ?? 0) + 1;
      dailyIntensity[day] =
          (dailyIntensity[day] ?? 0) + _calculateActivityVolume(activity);
    }

    // Normalizza intensità
    final maxIntensity = dailyIntensity.values.isEmpty
        ? 1.0
        : dailyIntensity.values.reduce((a, b) => a > b ? a : b);

    // Genera tutti i giorni nel range
    final heatmapData = <FrequencyHeatmapData>[];
    for (var day = startDate;
        day.isBefore(endDate);
        day = day.add(const Duration(days: 1))) {
      final workoutCount = dailyWorkouts[day] ?? 0;
      final intensity =
          workoutCount == 0 ? 0.0 : (dailyIntensity[day] ?? 0) / maxIntensity;

      heatmapData.add(FrequencyHeatmapData(
        date: day,
        workoutCount: workoutCount,
        intensity: intensity,
      ));
    }

    return heatmapData;
  }

  /// Calcola distribuzione volume per muscle group
  static List<MuscleVolumeDistribution> calculateMuscleDistribution(
    List<ExerciseActivity> weeklyActivities,
    Map<String, Exercise> exerciseDatabase,
  ) {
    // Usa AIVolumeCalculator esistente
    final volumeByMuscle = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
      weeklyActivities,
      exerciseDatabase,
    );

    final totalSets =
        volumeByMuscle.values.fold(0, (sum, vol) => sum + vol.totalSets);

    return volumeByMuscle.entries.map((entry) {
      final percentage =
          totalSets == 0 ? 0.0 : (entry.value.totalSets / totalSets) * 100;

      return MuscleVolumeDistribution(
        muscleGroup: entry.key,
        totalSets: entry.value.totalSets,
        percentage: percentage,
        isBalanced: entry.value.isOptimal,
      );
    }).toList()
      ..sort((a, b) => b.totalSets.compareTo(a.totalSets));
  }

  // Helper methods
  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static double _calculateActivityVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseDouble(set.weight);
        final reps = _parseDouble(set.reps);
        volume += weight * reps;
      }
    }
    return volume;
  }

  static double _getMaxWeight(ExerciseActivity activity) {
    double maxWeight = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseDouble(set.weight);
        if (weight > maxWeight) maxWeight = weight;
      }
    }
    return maxWeight;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
