/// MetricType enum - Defines all trackable body measurement metrics
///
/// Groups:
/// - Essential: Weight, Body Fat %, Height, Lean Mass, BMI, BMR
/// - Measurements: 13 Circumferences (Neck, Shoulders, Chest, Waist, etc.)
/// - Vitals: Body Temperature, Water Mass, Bone Mass
///
/// Based on fitness tracking industry best practices (2025 research)
enum MetricType {
  // ========== ESSENTIAL METRICS (Group 1) ==========
  /// Weight in kg or lbs
  weight,

  /// Body fat percentage (0-100%)
  bodyFatPercentage,

  /// Height in cm or inches
  height,

  /// Lean muscle mass in kg or lbs
  leanMass,

  /// Body Mass Index (calculated: weight / height²)
  bmi,

  /// Basal Metabolic Rate (calories/day)
  bmr,

  // ========== MEASUREMENTS - CIRCUMFERENCES (Group 2) ==========
  /// Neck circumference in cm or inches
  neckCircumference,

  /// Shoulder circumference in cm or inches
  shoulderCircumference,

  /// Chest circumference in cm or inches
  chestCircumference,

  /// Waist circumference in cm or inches
  waistCircumference,

  /// Abdomen circumference in cm or inches
  abdomenCircumference,

  /// Hip circumference in cm or inches
  hipCircumference,

  /// Left bicep circumference in cm or inches
  bicepLeftCircumference,

  /// Right bicep circumference in cm or inches
  bicepRightCircumference,

  /// Left forearm circumference in cm or inches
  forearmLeftCircumference,

  /// Right forearm circumference in cm or inches
  forearmRightCircumference,

  /// Left thigh circumference in cm or inches
  thighLeftCircumference,

  /// Right thigh circumference in cm or inches
  thighRightCircumference,

  /// Left calf circumference in cm or inches
  calfLeftCircumference,

  /// Right calf circumference in cm or inches
  calfRightCircumference,

  // ========== VITALS (Group 3) ==========
  /// Body temperature in Celsius or Fahrenheit
  bodyTemperature,

  /// Water mass percentage (0-100%)
  waterMass,

  /// Bone mass in kg or lbs
  boneMass;

  /// Get the metric group this metric belongs to
  MetricGroup get group {
    switch (this) {
      case MetricType.weight:
      case MetricType.bodyFatPercentage:
      case MetricType.height:
      case MetricType.leanMass:
      case MetricType.bmi:
      case MetricType.bmr:
        return MetricGroup.essential;

      case MetricType.neckCircumference:
      case MetricType.shoulderCircumference:
      case MetricType.chestCircumference:
      case MetricType.waistCircumference:
      case MetricType.abdomenCircumference:
      case MetricType.hipCircumference:
      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
        return MetricGroup.measurements;

      case MetricType.bodyTemperature:
      case MetricType.waterMass:
      case MetricType.boneMass:
        return MetricGroup.vitals;
    }
  }

  /// Get default unit for this metric type
  /// Returns unit in metric system (kg, cm, °C)
  String get defaultUnit {
    switch (this) {
      case MetricType.weight:
      case MetricType.leanMass:
      case MetricType.boneMass:
        return 'kg';

      case MetricType.bodyFatPercentage:
      case MetricType.waterMass:
        return '%';

      case MetricType.height:
      case MetricType.neckCircumference:
      case MetricType.shoulderCircumference:
      case MetricType.chestCircumference:
      case MetricType.waistCircumference:
      case MetricType.abdomenCircumference:
      case MetricType.hipCircumference:
      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
        return 'cm';

      case MetricType.bmi:
        return 'kg/m²';

      case MetricType.bmr:
        return 'kcal/day';

      case MetricType.bodyTemperature:
        return '°C';
    }
  }

  /// Get valid range for metric validation
  /// Returns (min, max) tuple for the metric value
  (double min, double max) get validRange {
    switch (this) {
      case MetricType.weight:
      case MetricType.leanMass:
        return (20.0, 300.0); // kg (reasonable human weight range)

      case MetricType.bodyFatPercentage:
      case MetricType.waterMass:
        return (0.0, 100.0); // percentage

      case MetricType.height:
        return (50.0, 250.0); // cm (reasonable human height range)

      case MetricType.neckCircumference:
        return (20.0, 60.0); // cm

      case MetricType.shoulderCircumference:
      case MetricType.chestCircumference:
        return (50.0, 200.0); // cm

      case MetricType.waistCircumference:
      case MetricType.abdomenCircumference:
      case MetricType.hipCircumference:
        return (40.0, 200.0); // cm

      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
        return (15.0, 80.0); // cm

      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
        return (15.0, 60.0); // cm

      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
        return (30.0, 120.0); // cm

      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
        return (20.0, 80.0); // cm

      case MetricType.bmi:
        return (10.0, 60.0); // BMI index

      case MetricType.bmr:
        return (800.0, 5000.0); // kcal/day

      case MetricType.bodyTemperature:
        return (30.0, 45.0); // °C (reasonable human temp range)

      case MetricType.boneMass:
        return (1.0, 10.0); // kg
    }
  }

  /// Whether this metric supports bilateral tracking (left/right)
  bool get isBilateral {
    switch (this) {
      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
        return true;
      default:
        return false;
    }
  }
}

/// MetricGroup - Consent groups for GDPR compliance
///
/// Used for Just-in-Time consent flow:
/// - Essential: Unlocked during onboarding (weight, body fat)
/// - Measurements: Unlocked when user needs circumferences
/// - Vitals: Unlocked when user needs advanced metrics
enum MetricGroup {
  /// Essential metrics (Weight, Body Fat, Height, Lean Mass, BMI, BMR)
  /// Required for basic tracking, requested during onboarding
  essential,

  /// Body measurements (13 circumferences)
  /// Unlocked via Just-in-Time consent when user taps "Track Measurements"
  measurements,

  /// Vital metrics (Body Temp, Water Mass, Bone Mass)
  /// Unlocked via Just-in-Time consent when user taps "Track Vitals"
  vitals,
}

/// MeasurementSource - Tracks where measurement data originated
enum MeasurementSource {
  /// Manually entered by user in app
  manual,

  /// Synced from Apple Health (iOS HealthKit)
  healthKit,

  /// Synced from Google Health Connect (Android)
  healthConnect,

  /// Imported from external file (CSV, JSON)
  imported,

  /// Calculated from other metrics (e.g., BMI from weight + height)
  calculated,
}
