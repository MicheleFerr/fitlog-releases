import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';

part 'body_measurement.freezed.dart';
part 'body_measurement.g.dart';

/// Represents a single body measurement data point from health sources.
///
/// Generic entity used for:
/// - Body weight (kg/lbs)
/// - Body fat percentage (%)
/// - Lean body mass (kg)
/// - Future: Heart rate, BMI, etc.
///
/// Sources: FitLog (manual entry), HealthKit (iOS), Health Connect (Android)
@freezed
abstract class BodyMeasurement with _$BodyMeasurement {
  const factory BodyMeasurement({
    /// Numeric value of the measurement
    required double value,

    /// Unit of measurement (kg, lbs, percent, etc.)
    required MeasurementUnit unit,

    /// When the measurement was recorded (timestamp)
    required DateTime recordedAt,

    /// Type of health data this measurement represents
    required HealthDataType dataType,

    /// Source of the measurement
    /// - 'FitLog': Manual entry in app
    /// - 'HealthKit': Synced from Apple Health (iOS)
    /// - 'Health Connect': Synced from Health Connect (Android)
    String? source,
  }) = _BodyMeasurement;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementFromJson(json);
}

/// Enum representing different units of measurement for body data
enum MeasurementUnit {
  /// Kilograms (metric)
  kilograms,

  /// Pounds (imperial)
  pounds,

  /// Percentage (for body fat %)
  percent,

  /// Minutes (for workout duration)
  /// Note: HealthKit workouts stored as measurements with duration
  minutes,

  /// Beats per minute (for heart rate - Phase 2)
  bpm,
}

/// Extension methods for [BodyMeasurement]
extension BodyMeasurementExtension on BodyMeasurement {
  /// Converts the measurement value to kilograms (if applicable).
  ///
  /// Conversion rates:
  /// - 1 lb = 0.453592 kg
  /// - Already kg → returns value as-is
  ///
  /// Throws [UnsupportedError] if unit is not weight-related
  double toKilograms() {
    switch (unit) {
      case MeasurementUnit.kilograms:
        return value; // Already in kg
      case MeasurementUnit.pounds:
        return value * 0.453592; // Convert lbs → kg
      case MeasurementUnit.percent:
      case MeasurementUnit.minutes:
      case MeasurementUnit.bpm:
        throw UnsupportedError('Cannot convert ${unit.name} to kilograms');
    }
  }

  /// Converts the measurement value to pounds (if applicable).
  ///
  /// Conversion rates:
  /// - 1 kg = 2.20462 lbs
  /// - Already lbs → returns value as-is
  ///
  /// Throws [UnsupportedError] if unit is not weight-related
  double toPounds() {
    switch (unit) {
      case MeasurementUnit.kilograms:
        return value * 2.20462; // Convert kg → lbs
      case MeasurementUnit.pounds:
        return value; // Already in lbs
      case MeasurementUnit.percent:
      case MeasurementUnit.minutes:
      case MeasurementUnit.bpm:
        throw UnsupportedError('Cannot convert ${unit.name} to pounds');
    }
  }

  /// Returns true if this measurement is from a health sync source
  /// (HealthKit or Health Connect) rather than manual entry
  bool get isSyncedFromHealth =>
      source == 'HealthKit' || source == 'Health Connect';

  /// Returns true if this measurement is a manual entry from FitLog
  bool get isManualEntry => source == 'FitLog' || source == null;

  /// Returns the localization key for the unit display
  String get unitDisplayKey {
    switch (unit) {
      case MeasurementUnit.kilograms:
        return 'unitKilograms'; // "kg"
      case MeasurementUnit.pounds:
        return 'unitPounds'; // "lbs"
      case MeasurementUnit.percent:
        return 'unitPercent'; // "%"
      case MeasurementUnit.minutes:
        return 'unitMinutes'; // "min"
      case MeasurementUnit.bpm:
        return 'unitBpm'; // "bpm"
    }
  }
}
