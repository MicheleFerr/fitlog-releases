/// Enum representing different types of health data that can be synced
/// with Apple Health (iOS) or Health Connect (Android 14+).
///
/// Future-proof design: MVP includes workout + bodyWeight,
/// Phase 2+ will add bodyFat, leanMass, heartRate, etc.
enum HealthDataType {
  /// Workout session data (duration, type, calories)
  /// MVP - Phase 1
  workout,

  /// Body weight measurements in kg or lbs
  /// MVP - Phase 1
  bodyWeight,

  /// Body height measurements in meters or cm
  /// MVP - Phase 1.1 (added for onboarding import)
  height,

  /// Body fat percentage
  /// Phase 2
  bodyFat,

  /// Lean body mass in kg
  /// Phase 2
  leanMass,

  /// Heart rate data (resting, active)
  /// Phase 2
  heartRate,

  /// Sleep tracking data
  /// Phase 3
  sleep,

  /// Nutrition and calorie intake
  /// Phase 3
  nutrition,
}

/// Extension methods for [HealthDataType]
extension HealthDataTypeExtension on HealthDataType {
  /// Returns the localization key for this data type's display name.
  ///
  /// Usage: `context.l10n.translate(dataType.displayNameKey)`
  ///
  /// Keys are defined in assets/i18n/app_en.arb and app_it.arb
  /// (will be added in Task 4.4 - Localization)
  String get displayNameKey {
    switch (this) {
      case HealthDataType.workout:
        return 'healthDataTypeWorkout';
      case HealthDataType.bodyWeight:
        return 'healthDataTypeBodyWeight';
      case HealthDataType.height:
        return 'healthDataTypeHeight';
      case HealthDataType.bodyFat:
        return 'healthDataTypeBodyFat';
      case HealthDataType.leanMass:
        return 'healthDataTypeLeanMass';
      case HealthDataType.heartRate:
        return 'healthDataTypeHeartRate';
      case HealthDataType.sleep:
        return 'healthDataTypeSleep';
      case HealthDataType.nutrition:
        return 'healthDataTypeNutrition';
    }
  }

  /// Returns true if this data type is part of the MVP (Phase 1)
  bool get isMvp {
    return this == HealthDataType.workout ||
        this == HealthDataType.bodyWeight ||
        this == HealthDataType.height;
  }

  /// Returns the phase number when this feature will be implemented
  int get phaseNumber {
    switch (this) {
      case HealthDataType.workout:
      case HealthDataType.bodyWeight:
      case HealthDataType.height:
        return 1; // MVP
      case HealthDataType.bodyFat:
      case HealthDataType.leanMass:
      case HealthDataType.heartRate:
        return 2;
      case HealthDataType.sleep:
      case HealthDataType.nutrition:
        return 3;
    }
  }
}
