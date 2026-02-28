import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

void main() {
  // ---------------------------------------------------------------------------
  // MetricGroup assignment
  // ---------------------------------------------------------------------------
  group('MetricType.group', () {
    test('essential metrics return MetricGroup.essential', () {
      expect(MetricType.weight.group, MetricGroup.essential);
      expect(MetricType.bodyFatPercentage.group, MetricGroup.essential);
      expect(MetricType.height.group, MetricGroup.essential);
      expect(MetricType.leanMass.group, MetricGroup.essential);
      expect(MetricType.bmi.group, MetricGroup.essential);
      expect(MetricType.bmr.group, MetricGroup.essential);
    });

    test('circumference metrics return MetricGroup.measurements', () {
      expect(MetricType.neckCircumference.group, MetricGroup.measurements);
      expect(MetricType.shoulderCircumference.group, MetricGroup.measurements);
      expect(MetricType.chestCircumference.group, MetricGroup.measurements);
      expect(MetricType.waistCircumference.group, MetricGroup.measurements);
      expect(MetricType.abdomenCircumference.group, MetricGroup.measurements);
      expect(MetricType.hipCircumference.group, MetricGroup.measurements);
      expect(MetricType.bicepLeftCircumference.group, MetricGroup.measurements);
      expect(MetricType.bicepRightCircumference.group, MetricGroup.measurements);
      expect(MetricType.forearmLeftCircumference.group, MetricGroup.measurements);
      expect(MetricType.forearmRightCircumference.group, MetricGroup.measurements);
      expect(MetricType.thighLeftCircumference.group, MetricGroup.measurements);
      expect(MetricType.thighRightCircumference.group, MetricGroup.measurements);
      expect(MetricType.calfLeftCircumference.group, MetricGroup.measurements);
      expect(MetricType.calfRightCircumference.group, MetricGroup.measurements);
    });

    test('vital metrics return MetricGroup.vitals', () {
      expect(MetricType.bodyTemperature.group, MetricGroup.vitals);
      expect(MetricType.waterMass.group, MetricGroup.vitals);
      expect(MetricType.boneMass.group, MetricGroup.vitals);
    });
  });

  // ---------------------------------------------------------------------------
  // Default units
  // ---------------------------------------------------------------------------
  group('MetricType.defaultUnit', () {
    test('weight metrics default to kg', () {
      expect(MetricType.weight.defaultUnit, 'kg');
      expect(MetricType.leanMass.defaultUnit, 'kg');
      expect(MetricType.boneMass.defaultUnit, 'kg');
    });

    test('percentage metrics default to %', () {
      expect(MetricType.bodyFatPercentage.defaultUnit, '%');
      expect(MetricType.waterMass.defaultUnit, '%');
    });

    test('height and circumferences default to cm', () {
      expect(MetricType.height.defaultUnit, 'cm');
      expect(MetricType.neckCircumference.defaultUnit, 'cm');
      expect(MetricType.waistCircumference.defaultUnit, 'cm');
      expect(MetricType.bicepLeftCircumference.defaultUnit, 'cm');
      expect(MetricType.calfRightCircumference.defaultUnit, 'cm');
    });

    test('bmi defaults to kg/m²', () {
      expect(MetricType.bmi.defaultUnit, 'kg/m²');
    });

    test('bmr defaults to kcal/day', () {
      expect(MetricType.bmr.defaultUnit, 'kcal/day');
    });

    test('body temperature defaults to °C', () {
      expect(MetricType.bodyTemperature.defaultUnit, '°C');
    });
  });

  // ---------------------------------------------------------------------------
  // Valid ranges
  // ---------------------------------------------------------------------------
  group('MetricType.validRange', () {
    test('weight range is (20.0, 300.0)', () {
      final (min, max) = MetricType.weight.validRange;
      expect(min, 20.0);
      expect(max, 300.0);
    });

    test('leanMass shares weight range', () {
      expect(MetricType.leanMass.validRange, MetricType.weight.validRange);
    });

    test('bodyFatPercentage range is (0.0, 100.0)', () {
      final (min, max) = MetricType.bodyFatPercentage.validRange;
      expect(min, 0.0);
      expect(max, 100.0);
    });

    test('waterMass shares bodyFat range', () {
      expect(
        MetricType.waterMass.validRange,
        MetricType.bodyFatPercentage.validRange,
      );
    });

    test('height range is (50.0, 250.0)', () {
      final (min, max) = MetricType.height.validRange;
      expect(min, 50.0);
      expect(max, 250.0);
    });

    test('bmi range is (10.0, 60.0)', () {
      final (min, max) = MetricType.bmi.validRange;
      expect(min, 10.0);
      expect(max, 60.0);
    });

    test('bmr range is (800.0, 5000.0)', () {
      final (min, max) = MetricType.bmr.validRange;
      expect(min, 800.0);
      expect(max, 5000.0);
    });

    test('bodyTemperature range is (30.0, 45.0)', () {
      final (min, max) = MetricType.bodyTemperature.validRange;
      expect(min, 30.0);
      expect(max, 45.0);
    });

    test('neckCircumference range is (20.0, 60.0)', () {
      final (min, max) = MetricType.neckCircumference.validRange;
      expect(min, 20.0);
      expect(max, 60.0);
    });

    test('waistCircumference range is (40.0, 200.0)', () {
      final (min, max) = MetricType.waistCircumference.validRange;
      expect(min, 40.0);
      expect(max, 200.0);
    });

    test('boneMass range is (1.0, 10.0)', () {
      final (min, max) = MetricType.boneMass.validRange;
      expect(min, 1.0);
      expect(max, 10.0);
    });
  });

  // ---------------------------------------------------------------------------
  // isBilateral
  // ---------------------------------------------------------------------------
  group('MetricType.isBilateral', () {
    test('bilateral metrics return true', () {
      expect(MetricType.bicepLeftCircumference.isBilateral, isTrue);
      expect(MetricType.bicepRightCircumference.isBilateral, isTrue);
      expect(MetricType.forearmLeftCircumference.isBilateral, isTrue);
      expect(MetricType.forearmRightCircumference.isBilateral, isTrue);
      expect(MetricType.thighLeftCircumference.isBilateral, isTrue);
      expect(MetricType.thighRightCircumference.isBilateral, isTrue);
      expect(MetricType.calfLeftCircumference.isBilateral, isTrue);
      expect(MetricType.calfRightCircumference.isBilateral, isTrue);
    });

    test('non-bilateral metrics return false', () {
      expect(MetricType.weight.isBilateral, isFalse);
      expect(MetricType.height.isBilateral, isFalse);
      expect(MetricType.bodyFatPercentage.isBilateral, isFalse);
      expect(MetricType.waistCircumference.isBilateral, isFalse);
      expect(MetricType.chestCircumference.isBilateral, isFalse);
      expect(MetricType.bmi.isBilateral, isFalse);
      expect(MetricType.bmr.isBilateral, isFalse);
      expect(MetricType.bodyTemperature.isBilateral, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // MetricGroup enum values
  // ---------------------------------------------------------------------------
  group('MetricGroup', () {
    test('has 3 values', () {
      expect(MetricGroup.values.length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // MeasurementSource enum values
  // ---------------------------------------------------------------------------
  group('MeasurementSource', () {
    test('has 5 values', () {
      expect(MeasurementSource.values.length, 5);
    });

    test('contains expected sources', () {
      expect(MeasurementSource.values, contains(MeasurementSource.manual));
      expect(MeasurementSource.values, contains(MeasurementSource.healthKit));
      expect(MeasurementSource.values, contains(MeasurementSource.calculated));
      expect(MeasurementSource.values, contains(MeasurementSource.imported));
    });
  });
}
