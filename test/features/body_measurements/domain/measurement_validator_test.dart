import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/validators/measurement_validator.dart';

void main() {
  late MeasurementValidator validator;

  setUp(() {
    validator = MeasurementValidator();
  });

  // Helper to build a simple Measurement for validateMeasurement tests
  Measurement _buildMeasurement({
    required MetricType type,
    required double value,
  }) {
    return Measurement(
      id: 'test',
      userId: 'user',
      metricType: type,
      value: value,
      unit: type.defaultUnit,
      timestamp: DateTime(2025, 1, 1),
      source: MeasurementSource.manual,
    );
  }

  // Helper to create a list of historical weight measurements
  List<Measurement> _weightHistory(List<double> values) {
    return values.indexed.map((entry) {
      final (i, v) = entry;
      return Measurement(
        id: 'h-$i',
        userId: 'user',
        metricType: MetricType.weight,
        value: v,
        unit: 'kg',
        timestamp: DateTime(2025, 1, i + 1),
        source: MeasurementSource.manual,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // validateWeight
  // ---------------------------------------------------------------------------
  group('validateWeight', () {
    test('valid weight returns isValid true', () {
      expect(validator.validateWeight(75.0).isValid, isTrue);
      expect(validator.validateWeight(20.0).isValid, isTrue);
      expect(validator.validateWeight(300.0).isValid, isTrue);
    });

    test('weight below minimum (20.0) returns invalid', () {
      final result = validator.validateWeight(19.9);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('20.0'));
    });

    test('weight above maximum (300.0) returns invalid', () {
      final result = validator.validateWeight(300.1);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('300.0'));
    });

    test('error message includes the invalid value', () {
      final result = validator.validateWeight(10.0);

      expect(result.errorMessage, contains('10.0'));
    });
  });

  // ---------------------------------------------------------------------------
  // validateBodyFat
  // ---------------------------------------------------------------------------
  group('validateBodyFat', () {
    test('valid body fat percentage returns isValid true', () {
      expect(validator.validateBodyFat(20.0).isValid, isTrue);
      expect(validator.validateBodyFat(3.0).isValid, isTrue);
      expect(validator.validateBodyFat(60.0).isValid, isTrue);
    });

    test('body fat below 3.0 returns invalid', () {
      expect(validator.validateBodyFat(2.9).isValid, isFalse);
    });

    test('body fat above 60.0 returns invalid', () {
      expect(validator.validateBodyFat(60.1).isValid, isFalse);
    });

    test('error message includes percentage sign', () {
      final result = validator.validateBodyFat(1.0);

      expect(result.errorMessage, contains('%'));
    });
  });

  // ---------------------------------------------------------------------------
  // validateHeight
  // ---------------------------------------------------------------------------
  group('validateHeight', () {
    test('valid height returns isValid true', () {
      expect(validator.validateHeight(170.0).isValid, isTrue);
      expect(validator.validateHeight(50.0).isValid, isTrue);
      expect(validator.validateHeight(250.0).isValid, isTrue);
    });

    test('height below 50.0 returns invalid', () {
      expect(validator.validateHeight(49.9).isValid, isFalse);
    });

    test('height above 250.0 returns invalid', () {
      expect(validator.validateHeight(250.1).isValid, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // validateBMI
  // ---------------------------------------------------------------------------
  group('validateBMI', () {
    test('valid BMI returns isValid true', () {
      expect(validator.validateBMI(22.5).isValid, isTrue);
      expect(validator.validateBMI(10.0).isValid, isTrue);
      expect(validator.validateBMI(60.0).isValid, isTrue);
    });

    test('BMI below 10 returns invalid', () {
      expect(validator.validateBMI(9.9).isValid, isFalse);
    });

    test('BMI above 60 returns invalid', () {
      expect(validator.validateBMI(60.1).isValid, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // validateBMR
  // ---------------------------------------------------------------------------
  group('validateBMR', () {
    test('valid BMR returns isValid true', () {
      expect(validator.validateBMR(1800.0).isValid, isTrue);
      expect(validator.validateBMR(800.0).isValid, isTrue);
      expect(validator.validateBMR(5000.0).isValid, isTrue);
    });

    test('BMR below 800 returns invalid', () {
      expect(validator.validateBMR(799.9).isValid, isFalse);
    });

    test('BMR above 5000 returns invalid', () {
      expect(validator.validateBMR(5000.1).isValid, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // validateBodyTemperature
  // ---------------------------------------------------------------------------
  group('validateBodyTemperature', () {
    test('valid body temperature returns isValid true', () {
      expect(validator.validateBodyTemperature(37.0).isValid, isTrue);
      expect(validator.validateBodyTemperature(30.0).isValid, isTrue);
      expect(validator.validateBodyTemperature(45.0).isValid, isTrue);
    });

    test('temperature below 30 returns invalid', () {
      expect(validator.validateBodyTemperature(29.9).isValid, isFalse);
    });

    test('temperature above 45 returns invalid', () {
      expect(validator.validateBodyTemperature(45.1).isValid, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // validateCircumference
  // ---------------------------------------------------------------------------
  group('validateCircumference', () {
    test('valid waist returns isValid true', () {
      expect(
        validator
            .validateCircumference(80.0, MetricType.waistCircumference)
            .isValid,
        isTrue,
      );
    });

    test('waist below 40.0 returns invalid', () {
      expect(
        validator
            .validateCircumference(39.9, MetricType.waistCircumference)
            .isValid,
        isFalse,
      );
    });

    test('neck above 60.0 returns invalid', () {
      expect(
        validator
            .validateCircumference(60.1, MetricType.neckCircumference)
            .isValid,
        isFalse,
      );
    });

    test('valid bicep returns isValid true', () {
      expect(
        validator
            .validateCircumference(35.0, MetricType.bicepLeftCircumference)
            .isValid,
        isTrue,
      );
    });

    test('error message contains metric type name', () {
      final result = validator.validateCircumference(
        5.0,
        MetricType.neckCircumference,
      );

      expect(result.errorMessage, contains('neckCircumference'));
    });
  });

  // ---------------------------------------------------------------------------
  // validateMeasurement (dispatch method)
  // ---------------------------------------------------------------------------
  group('validateMeasurement', () {
    test('validates weight measurement correctly', () {
      final valid = _buildMeasurement(type: MetricType.weight, value: 80.0);
      final invalid = _buildMeasurement(type: MetricType.weight, value: 5.0);

      expect(validator.validateMeasurement(valid).isValid, isTrue);
      expect(validator.validateMeasurement(invalid).isValid, isFalse);
    });

    test('validates bodyFatPercentage measurement correctly', () {
      final valid = _buildMeasurement(
        type: MetricType.bodyFatPercentage,
        value: 15.0,
      );
      final invalid = _buildMeasurement(
        type: MetricType.bodyFatPercentage,
        value: 1.0,
      );

      expect(validator.validateMeasurement(valid).isValid, isTrue);
      expect(validator.validateMeasurement(invalid).isValid, isFalse);
    });

    test('validates height measurement correctly', () {
      final valid = _buildMeasurement(type: MetricType.height, value: 175.0);
      final invalid = _buildMeasurement(type: MetricType.height, value: 10.0);

      expect(validator.validateMeasurement(valid).isValid, isTrue);
      expect(validator.validateMeasurement(invalid).isValid, isFalse);
    });

    test('validates bmi measurement correctly', () {
      final valid = _buildMeasurement(type: MetricType.bmi, value: 22.0);
      expect(validator.validateMeasurement(valid).isValid, isTrue);
    });

    test('validates bmr measurement correctly', () {
      final valid = _buildMeasurement(type: MetricType.bmr, value: 2000.0);
      expect(validator.validateMeasurement(valid).isValid, isTrue);
    });

    test('validates bodyTemperature measurement correctly', () {
      final valid = _buildMeasurement(
        type: MetricType.bodyTemperature,
        value: 36.6,
      );
      expect(validator.validateMeasurement(valid).isValid, isTrue);
    });

    test('validates leanMass via weight validator', () {
      final valid = _buildMeasurement(type: MetricType.leanMass, value: 60.0);
      final invalid = _buildMeasurement(type: MetricType.leanMass, value: 10.0);

      expect(validator.validateMeasurement(valid).isValid, isTrue);
      expect(validator.validateMeasurement(invalid).isValid, isFalse);
    });

    test('validates waterMass via bodyFat validator', () {
      final valid = _buildMeasurement(type: MetricType.waterMass, value: 55.0);
      expect(validator.validateMeasurement(valid).isValid, isTrue);
    });

    test('validates circumference measurement correctly', () {
      final valid = _buildMeasurement(
        type: MetricType.chestCircumference,
        value: 95.0,
      );
      final invalid = _buildMeasurement(
        type: MetricType.chestCircumference,
        value: 10.0,
      );

      expect(validator.validateMeasurement(valid).isValid, isTrue);
      expect(validator.validateMeasurement(invalid).isValid, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // isOutlier
  // ---------------------------------------------------------------------------
  group('isOutlier', () {
    test('returns false when history has fewer than 3 measurements', () {
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 300.0,
      );
      final history = _weightHistory([70.0, 71.0]);

      expect(validator.isOutlier(measurement, history), isFalse);
    });

    test('returns false for normal value within 3 standard deviations', () {
      // Consistent history: 70, 71, 72, 73, 74 kg
      final history = _weightHistory([70.0, 71.0, 72.0, 73.0, 74.0]);
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 72.0, // right in the middle
      );

      expect(validator.isOutlier(measurement, history), isFalse);
    });

    test('returns true for extreme value more than 3 standard deviations away',
        () {
      // Tight cluster: 70, 70, 70, 70, 70 → stdDev ≈ 0
      // stdDev = 0 means division by zero is avoided only if value == mean
      // Use a slightly spread history to avoid 0 stdDev edge case
      final history = _weightHistory([70.0, 71.0, 69.0, 70.5, 70.0]);
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 200.0, // extreme outlier — far from ~70 kg cluster
      );

      expect(validator.isOutlier(measurement, history), isTrue);
    });

    test('filters history to same metric type', () {
      // History contains weight + bodyFat, but measurement is bodyFat
      // Only bodyFat history should be used (< 3), so result = false
      final weightHistory = _weightHistory([70.0, 71.0, 72.0]);
      final bodyFatMeasurement = _buildMeasurement(
        type: MetricType.bodyFatPercentage,
        value: 99.0, // extreme, but history has 0 matching entries
      );

      // bodyFatMeasurement against weight history → 0 matching → false
      expect(
        validator.isOutlier(bodyFatMeasurement, weightHistory),
        isFalse,
      );
    });

    test('uses custom threshold when provided', () {
      // Moderate outlier: 2 std deviations away
      final history = _weightHistory([70.0, 72.0, 68.0, 71.0, 69.0]);
      // Mean ≈ 70, std ≈ ~1.4
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 73.0, // ~2 std devs away — not an outlier at threshold 3
      );

      // At default threshold (3.0): not outlier
      expect(validator.isOutlier(measurement, history), isFalse);

      // At lower threshold (1.0): should be outlier
      expect(
        validator.isOutlier(measurement, history, threshold: 1.0),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getOutlierStats
  // ---------------------------------------------------------------------------
  group('getOutlierStats', () {
    test('returns sensible defaults when history has fewer than 3 items', () {
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 75.0,
      );
      final stats = validator.getOutlierStats(measurement, []);

      expect(stats.mean, 75.0);
      expect(stats.stdDev, 0.0);
      expect(stats.zScore, 0.0);
      expect(stats.isOutlier, isFalse);
    });

    test('calculates mean correctly', () {
      final history = _weightHistory([70.0, 80.0, 90.0]);
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 80.0,
      );

      final stats = validator.getOutlierStats(measurement, history);

      expect(stats.mean, closeTo(80.0, 0.001));
    });

    test('calculates isOutlier flag for extreme value', () {
      final history = _weightHistory([70.0, 71.0, 69.0, 70.5, 70.0]);
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 200.0,
      );

      final stats = validator.getOutlierStats(measurement, history);

      expect(stats.isOutlier, isTrue);
      expect(stats.zScore, greaterThan(3.0));
      expect(stats.stdDev, greaterThan(0.0));
    });

    test('calculates isOutlier false for normal value', () {
      final history = _weightHistory([70.0, 71.0, 72.0, 73.0, 74.0]);
      final measurement = _buildMeasurement(
        type: MetricType.weight,
        value: 72.0,
      );

      final stats = validator.getOutlierStats(measurement, history);

      expect(stats.isOutlier, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // ValidationResult
  // ---------------------------------------------------------------------------
  group('ValidationResult', () {
    test('valid result has isValid true and null errorMessage', () {
      final result = ValidationResult.valid();

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('invalid result has isValid false and non-null errorMessage', () {
      const message = 'Value out of range';
      final result = ValidationResult.invalid(message);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, message);
    });

    test('valid result toString contains "valid"', () {
      final result = ValidationResult.valid();

      expect(result.toString(), contains('valid'));
    });

    test('invalid result toString contains error message', () {
      final result = ValidationResult.invalid('Too low');

      expect(result.toString(), contains('Too low'));
    });
  });

  // ---------------------------------------------------------------------------
  // OutlierStats
  // ---------------------------------------------------------------------------
  group('OutlierStats', () {
    test('stores all properties correctly', () {
      const stats = OutlierStats(
        mean: 72.5,
        stdDev: 1.5,
        zScore: 4.2,
        isOutlier: true,
      );

      expect(stats.mean, 72.5);
      expect(stats.stdDev, 1.5);
      expect(stats.zScore, 4.2);
      expect(stats.isOutlier, isTrue);
    });
  });
}
