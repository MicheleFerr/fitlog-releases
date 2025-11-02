/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: workout
/// 🔧 Type: entity (Chart Data Point)
/// 🌍 Localization: N/A (Domain entity)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies: None (Pure domain entity)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data_point.freezed.dart';
part 'chart_data_point.g.dart';

/// Domain entity rappresenta un punto dati per il grafico metrica
///
/// Immutabile con Freezed per garantire purezza del domain layer.
/// Usato da:
/// - GetExerciseChartData use case
/// - ExerciseChartRepository
/// - Presentation layer per rendering grafico
@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    /// Data del punto (workout date)
    required DateTime date,

    /// Valore della metrica (peso/reps/rpe/tut)
    required double value,
  }) = _ChartDataPoint;

  /// Factory per JSON deserialization (se necessario per caching futuro)
  factory ChartDataPoint.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointFromJson(json);
}
