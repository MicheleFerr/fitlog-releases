/// PersonalCalibration entity tests - Banister FFM model, computed properties.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';

void main() {
  group('CalibrationQuality', () {
    test('has 4 values', () {
      expect(CalibrationQuality.values.length, 4);
    });
  });

  group('PersonalCalibration', () {
    test('default values', () {
      final cal = PersonalCalibration(userId: 'u1');
      expect(cal.ageFactor, 1.0);
      expect(cal.trainingAgeFactor, 1.0);
      expect(cal.sexFactor, 1.0);
      expect(cal.hrvFactor, 1.0);
      expect(cal.sleepFactor, 1.0);
      expect(cal.injuryFactor, 1.0);
      expect(cal.confidenceLevel, 0.5);
      expect(cal.dataPointsUsed, 0);
    });

    test('tau1Modifier', () {
      final cal = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.9,
        trainingAgeFactor: 1.2,
        sexFactor: 0.95,
      );
      expect(cal.tau1Modifier, closeTo(0.9 * 1.2 * 0.95, 0.001));
    });

    test('tau2Modifier', () {
      final cal = PersonalCalibration(
        userId: 'u1',
        hrvFactor: 0.8,
        sleepFactor: 1.4,
        injuryFactor: 1.3,
      );
      expect(cal.tau2Modifier, closeTo(0.8 * 1.4 * 1.3, 0.001));
    });

    test('personalTau1Hours with default modifiers', () {
      final cal = PersonalCalibration(userId: 'u1');
      expect(cal.personalTau1Hours, 1008.0); // 42 days
    });

    test('personalTau2Hours with default modifiers', () {
      final cal = PersonalCalibration(userId: 'u1');
      expect(cal.personalTau2Hours, 240.0); // 10 days
    });

    test('personalTau1Hours with modified factors', () {
      final cal = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.8,
        trainingAgeFactor: 0.9,
        sexFactor: 1.0,
      );
      expect(cal.personalTau1Hours, closeTo(1008.0 * 0.8 * 0.9, 0.1));
    });

    test('hasHealthKitData', () {
      expect(
        PersonalCalibration(userId: 'u1').hasHealthKitData,
        isFalse,
      );
      expect(
        PersonalCalibration(userId: 'u1', baselineHrv: 65).hasHealthKitData,
        isTrue,
      );
      expect(
        PersonalCalibration(userId: 'u1', baselineSleepHours: 7.5).hasHealthKitData,
        isTrue,
      );
    });

    test('isHighConfidence', () {
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.7).isHighConfidence,
        isTrue,
      );
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.69).isHighConfidence,
        isFalse,
      );
    });

    test('quality tiers', () {
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.85).quality,
        CalibrationQuality.excellent,
      );
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.65).quality,
        CalibrationQuality.good,
      );
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.45).quality,
        CalibrationQuality.fair,
      );
      expect(
        PersonalCalibration(userId: 'u1', confidenceLevel: 0.3).quality,
        CalibrationQuality.poor,
      );
    });

    test('JSON round-trip', () {
      final cal = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.9,
        hrvFactor: 1.2,
        confidenceLevel: 0.75,
        dataPointsUsed: 10,
        baselineHrv: 55.0,
      );
      final json = cal.toJson();
      final restored = PersonalCalibration.fromJson(json);
      expect(restored.userId, 'u1');
      expect(restored.ageFactor, 0.9);
      expect(restored.hrvFactor, 1.2);
      expect(restored.confidenceLevel, 0.75);
      expect(restored.dataPointsUsed, 10);
      expect(restored.baselineHrv, 55.0);
    });
  });
}
