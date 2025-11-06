/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: workout
/// 🔧 Type: entity (immutable value object)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies: None (pure domain)
library;

/// Chart data point entity
///
/// Immutable value object rappresenta un singolo punto dati per chart
class ChartDataPoint {

  const ChartDataPoint({
    required this.date,
    required this.value,
  });
  final DateTime date;
  final double value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          value == other.value;

  @override
  int get hashCode => date.hashCode ^ value.hashCode;

  @override
  String toString() => 'ChartDataPoint(date: $date, value: $value)';
}
