import '../entities/measurement.dart';
import '../entities/metric_type.dart';
import 'dart:math' as math;

/// MeasurementValidator - Domain validation logic for measurements
///
/// Implements data quality gates:
/// - Range validation (realistic human measurements)
/// - Outlier detection (>3 standard deviations from user history)
/// - Unit consistency validation
/// - Measurement integrity checks
///
/// **GDPR Compliance**: Data minimization through quality gates
/// - Reject junk/spam data (prevents database pollution)
/// - Only accept realistic measurements (enhances data quality)
/// - Protects user privacy (no absurd values that might leak sensitive info)
///
/// Example:
/// ```dart
/// final validator = MeasurementValidator();
///
/// // Validate weight
/// final weightResult = validator.validateWeight(75.5);
/// if (!weightResult.isValid) {
///   print(weightResult.errorMessage); // "Weight out of range (20-300 kg)"
/// }
///
/// // Detect outliers
/// final isOutlier = validator.isOutlier(newMeasurement, history);
/// if (isOutlier) {
///   showWarningDialog('This measurement is unusual. Please double-check.');
/// }
/// ```
class MeasurementValidator {
  /// Validate weight measurement
  ///
  /// **Valid range**: 20-300 kg (realistic human weight)
  ///
  /// Returns:
  /// - ValidationResult.valid() if weight in range
  /// - ValidationResult.invalid() with error message if out of range
  ///
  /// Example:
  /// ```dart
  /// validator.validateWeight(75.5); // Valid
  /// validator.validateWeight(15.0); // Invalid: too low
  /// validator.validateWeight(350.0); // Invalid: too high
  /// ```
  ValidationResult validateWeight(double kg) {
    const min = 20.0;
    const max = 300.0;

    if (kg < min || kg > max) {
      return ValidationResult.invalid(
        'Weight must be between $min and $max kg (got: $kg)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate body fat percentage
  ///
  /// **Valid range**: 3-60% (realistic human body fat)
  /// - Essential fat: 3-5% (athletes)
  /// - Normal: 15-25% (average person)
  /// - Obese: >30% (medical concern)
  /// - Max: 60% (extreme obesity)
  ///
  /// Returns:
  /// - ValidationResult.valid() if body fat in range
  /// - ValidationResult.invalid() with error message if out of range
  ///
  /// Example:
  /// ```dart
  /// validator.validateBodyFat(20.5); // Valid
  /// validator.validateBodyFat(2.0); // Invalid: too low (dangerous)
  /// validator.validateBodyFat(65.0); // Invalid: too high (unrealistic)
  /// ```
  ValidationResult validateBodyFat(double percentage) {
    const min = 3.0;
    const max = 60.0;

    if (percentage < min || percentage > max) {
      return ValidationResult.invalid(
        'Body fat must be between $min% and $max% (got: $percentage%)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate circumference measurement (neck, chest, waist, arms, legs, etc.)
  ///
  /// **Valid range varies by body part**:
  /// - Neck: 20-60 cm
  /// - Shoulders, Chest: 50-200 cm
  /// - Waist, Abdomen, Hips: 40-200 cm
  /// - Biceps: 15-80 cm
  /// - Forearms: 15-60 cm
  /// - Thighs: 30-120 cm
  /// - Calves: 20-80 cm
  ///
  /// Returns:
  /// - ValidationResult.valid() if circumference in range
  /// - ValidationResult.invalid() with error message if out of range
  ///
  /// Example:
  /// ```dart
  /// validator.validateCircumference(35.0, MetricType.waistCircumference); // Valid
  /// validator.validateCircumference(10.0, MetricType.bicepLeftCircumference); // Invalid: too small
  /// ```
  ValidationResult validateCircumference(double cm, MetricType type) {
    final (min, max) = type.validRange;

    if (cm < min || cm > max) {
      return ValidationResult.invalid(
        '${type.name} must be between $min and $max cm (got: $cm)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate Basal Metabolic Rate (BMR)
  ///
  /// **Valid range**: 800-5000 kcal/day
  /// - Low: 800-1200 kcal (sedentary small person)
  /// - Average: 1500-2500 kcal (typical adult)
  /// - High: 3000-5000 kcal (athlete, large person)
  ///
  /// Returns:
  /// - ValidationResult.valid() if BMR in range
  /// - ValidationResult.invalid() with error message if out of range
  ///
  /// Example:
  /// ```dart
  /// validator.validateBMR(1800.0); // Valid
  /// validator.validateBMR(600.0); // Invalid: too low (dangerous)
  /// validator.validateBMR(6000.0); // Invalid: too high (unrealistic)
  /// ```
  ValidationResult validateBMR(double kcal) {
    const min = 800.0;
    const max = 5000.0;

    if (kcal < min || kcal > max) {
      return ValidationResult.invalid(
        'BMR must be between $min and $max kcal/day (got: $kcal)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate body temperature
  ///
  /// **Valid range**: 30-45°C (realistic human temperature)
  /// - Hypothermia: <35°C
  /// - Normal: 36.5-37.5°C
  /// - Fever: 38-40°C
  /// - Hyperthermia: >41°C (medical emergency)
  ///
  /// Returns:
  /// - ValidationResult.valid() if temperature in range
  /// - ValidationResult.invalid() with error message if out of range
  ///
  /// Example:
  /// ```dart
  /// validator.validateBodyTemperature(37.0); // Valid
  /// validator.validateBodyTemperature(25.0); // Invalid: too low
  /// validator.validateBodyTemperature(50.0); // Invalid: too high
  /// ```
  ValidationResult validateBodyTemperature(double celsius) {
    const min = 30.0;
    const max = 45.0;

    if (celsius < min || celsius > max) {
      return ValidationResult.invalid(
        'Body temperature must be between $min and $max°C (got: $celsius)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate height
  ///
  /// **Valid range**: 50-250 cm
  /// - Shortest adult: ~60 cm
  /// - Average: 150-180 cm
  /// - Tallest human: ~250 cm
  ///
  /// Returns:
  /// - ValidationResult.valid() if height in range
  /// - ValidationResult.invalid() with error message if out of range
  ValidationResult validateHeight(double cm) {
    const min = 50.0;
    const max = 250.0;

    if (cm < min || cm > max) {
      return ValidationResult.invalid(
        'Height must be between $min and $max cm (got: $cm)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate BMI (Body Mass Index)
  ///
  /// **Valid range**: 10-60
  /// - Underweight: <18.5
  /// - Normal: 18.5-24.9
  /// - Overweight: 25-29.9
  /// - Obese: 30+
  ///
  /// Returns:
  /// - ValidationResult.valid() if BMI in range
  /// - ValidationResult.invalid() with error message if out of range
  ValidationResult validateBMI(double bmi) {
    const min = 10.0;
    const max = 60.0;

    if (bmi < min || bmi > max) {
      return ValidationResult.invalid(
        'BMI must be between $min and $max (got: $bmi)',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate measurement based on metric type
  ///
  /// Convenience method that routes to specific validators.
  ///
  /// Parameters:
  /// - [measurement]: Measurement to validate
  ///
  /// Returns:
  /// - ValidationResult with isValid flag and optional error message
  ///
  /// Example:
  /// ```dart
  /// final result = validator.validateMeasurement(measurement);
  /// if (!result.isValid) {
  ///   showErrorDialog(result.errorMessage);
  ///   return;
  /// }
  /// // Proceed to save measurement
  /// ```
  ValidationResult validateMeasurement(Measurement measurement) {
    switch (measurement.metricType) {
      case MetricType.weight:
      case MetricType.leanMass:
      case MetricType.boneMass:
        return validateWeight(measurement.value);

      case MetricType.bodyFatPercentage:
      case MetricType.waterMass:
        return validateBodyFat(measurement.value);

      case MetricType.height:
        return validateHeight(measurement.value);

      case MetricType.bmi:
        return validateBMI(measurement.value);

      case MetricType.bmr:
        return validateBMR(measurement.value);

      case MetricType.bodyTemperature:
        return validateBodyTemperature(measurement.value);

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
        return validateCircumference(measurement.value, measurement.metricType);
    }
  }

  /// Detect if measurement is an outlier (>3 standard deviations from history)
  ///
  /// **Statistical Outlier Detection**:
  /// - Calculate mean and standard deviation of user's measurement history
  /// - If new measurement is >3 std deviations away → outlier
  /// - Warns user to double-check value (might be typo)
  ///
  /// **GDPR**: Data quality improvement (garbage in, garbage out)
  ///
  /// Parameters:
  /// - [measurement]: New measurement to check
  /// - [history]: User's historical measurements for this metric type
  /// - [threshold]: Number of standard deviations (default: 3.0)
  ///
  /// Returns:
  /// - true: Measurement is outlier (warn user)
  /// - false: Measurement is within normal range
  ///
  /// Example:
  /// ```dart
  /// final history = await measurementRepo.getMeasurements(
  ///   userId,
  ///   filterByType: MetricType.weight,
  /// );
  ///
  /// if (validator.isOutlier(newMeasurement, history)) {
  ///   showWarningDialog(
  ///     'This weight (${newMeasurement.value} kg) is unusual for you. '
  ///     'Your average is ${_calculateMean(history)} kg. '
  ///     'Please double-check.',
  ///   );
  /// }
  /// ```
  bool isOutlier(
    Measurement measurement,
    List<Measurement> history, {
    double threshold = 3.0,
  }) {
    // Need at least 3 historical measurements for meaningful statistics
    if (history.length < 3) {
      return false; // Not enough data to determine outliers
    }

    // Filter history to same metric type
    final relevantHistory = history
        .where((m) => m.metricType == measurement.metricType)
        .toList();

    if (relevantHistory.length < 3) {
      return false;
    }

    // Calculate mean
    final values = relevantHistory.map((m) => m.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    // Calculate standard deviation
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    // Check if measurement is >threshold std deviations away
    final zScore = (measurement.value - mean).abs() / stdDev;
    return zScore > threshold;
  }

  /// Get outlier statistics for a measurement
  ///
  /// Returns detailed statistics for UI display:
  /// - mean: Average value from history
  /// - stdDev: Standard deviation
  /// - zScore: How many std deviations away
  /// - isOutlier: Boolean flag
  ///
  /// Example:
  /// ```dart
  /// final stats = validator.getOutlierStats(measurement, history);
  /// if (stats.isOutlier) {
  ///   showWarningDialog(
  ///     'Value: ${measurement.value} ${measurement.unit}\n'
  ///     'Your average: ${stats.mean.toStringAsFixed(1)} ${measurement.unit}\n'
  ///     'Z-score: ${stats.zScore.toStringAsFixed(2)} (${stats.zScore > 0 ? '+' : ''})',
  ///   );
  /// }
  /// ```
  OutlierStats getOutlierStats(
    Measurement measurement,
    List<Measurement> history,
  ) {
    if (history.length < 3) {
      return OutlierStats(
        mean: measurement.value,
        stdDev: 0.0,
        zScore: 0.0,
        isOutlier: false,
      );
    }

    final relevantHistory = history
        .where((m) => m.metricType == measurement.metricType)
        .toList();

    if (relevantHistory.length < 3) {
      return OutlierStats(
        mean: measurement.value,
        stdDev: 0.0,
        zScore: 0.0,
        isOutlier: false,
      );
    }

    final values = relevantHistory.map((m) => m.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    final zScore = (measurement.value - mean).abs() / stdDev;
    final isOutlier = zScore > 3.0;

    return OutlierStats(
      mean: mean,
      stdDev: stdDev,
      zScore: zScore,
      isOutlier: isOutlier,
    );
  }
}

/// ValidationResult - Result of validation operation
class ValidationResult {
  /// Whether validation passed
  final bool isValid;

  /// Error message if validation failed (null if valid)
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  /// Create valid result
  factory ValidationResult.valid() {
    return const ValidationResult._(isValid: true);
  }

  /// Create invalid result with error message
  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult._(isValid: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    if (isValid) return 'ValidationResult.valid()';
    return 'ValidationResult.invalid("$errorMessage")';
  }
}

/// OutlierStats - Statistical data for outlier detection
class OutlierStats {
  /// Mean (average) value from historical measurements
  final double mean;

  /// Standard deviation from historical measurements
  final double stdDev;

  /// Z-score (number of standard deviations away from mean)
  final double zScore;

  /// Whether this measurement is an outlier (>3 std dev)
  final bool isOutlier;

  const OutlierStats({
    required this.mean,
    required this.stdDev,
    required this.zScore,
    required this.isOutlier,
  });
}
