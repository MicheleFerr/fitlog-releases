/// Stress Index Entities Tests
///
/// Tests JSON round-trip, computed properties, and entity behaviour for:
/// - PersonalCalibration
/// - StressIndexResult
/// - MuscleReadinessData
/// - MuscleStressData
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PersonalCalibration
  // ---------------------------------------------------------------------------

  group('PersonalCalibration', () {
    test('creates default calibration with defaultFor factory', () {
      final calibration = PersonalCalibration.defaultFor('user-123');

      expect(calibration.userId, equals('user-123'));
      expect(calibration.ageFactor, equals(1.0));
      expect(calibration.trainingAgeFactor, equals(1.0));
      expect(calibration.sexFactor, equals(1.0));
      expect(calibration.hrvFactor, equals(1.0));
      expect(calibration.sleepFactor, equals(1.0));
      expect(calibration.injuryFactor, equals(1.0));
      expect(calibration.confidenceLevel, equals(0.5));
      expect(calibration.dataPointsUsed, equals(0));
      expect(calibration.lastUpdated, isNotNull);
    });

    test('tau1Modifier multiplies age × trainingAge × sex factors', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.9,
        trainingAgeFactor: 1.1,
        sexFactor: 0.95,
      );

      expect(
        calibration.tau1Modifier,
        closeTo(0.9 * 1.1 * 0.95, 0.0001),
      );
    });

    test('tau2Modifier multiplies hrv × sleep × injury factors', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        hrvFactor: 1.2,
        sleepFactor: 1.3,
        injuryFactor: 1.1,
      );

      expect(
        calibration.tau2Modifier,
        closeTo(1.2 * 1.3 * 1.1, 0.0001),
      );
    });

    test('personalTau1Hours = 1008 × tau1Modifier', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.9,
        trainingAgeFactor: 1.0,
        sexFactor: 1.0,
      );

      expect(calibration.personalTau1Hours, closeTo(1008.0 * 0.9, 0.01));
    });

    test('personalTau2Hours = 240 × tau2Modifier', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        sleepFactor: 1.2,
      );

      expect(calibration.personalTau2Hours, closeTo(240.0 * 1.2, 0.01));
    });

    test('hasHealthKitData returns false when no baseline values', () {
      final calibration = PersonalCalibration(userId: 'u1');

      expect(calibration.hasHealthKitData, isFalse);
    });

    test('hasHealthKitData returns true when baselineHrv set', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        baselineHrv: 65.0,
      );

      expect(calibration.hasHealthKitData, isTrue);
    });

    test('hasHealthKitData returns true when baselineSleepHours set', () {
      final calibration = PersonalCalibration(
        userId: 'u1',
        baselineSleepHours: 7.5,
      );

      expect(calibration.hasHealthKitData, isTrue);
    });

    test('isHighConfidence returns true when confidenceLevel >= 0.7', () {
      final high = PersonalCalibration(userId: 'u1', confidenceLevel: 0.8);
      final low = PersonalCalibration(userId: 'u1', confidenceLevel: 0.6);

      expect(high.isHighConfidence, isTrue);
      expect(low.isHighConfidence, isFalse);
    });

    group('quality property', () {
      test('excellent when confidenceLevel >= 0.8', () {
        final c = PersonalCalibration(userId: 'u1', confidenceLevel: 0.85);
        expect(c.quality, equals(CalibrationQuality.excellent));
      });

      test('good when confidenceLevel in [0.6, 0.8)', () {
        final c = PersonalCalibration(userId: 'u1', confidenceLevel: 0.65);
        expect(c.quality, equals(CalibrationQuality.good));
      });

      test('fair when confidenceLevel in [0.4, 0.6)', () {
        final c = PersonalCalibration(userId: 'u1', confidenceLevel: 0.45);
        expect(c.quality, equals(CalibrationQuality.fair));
      });

      test('poor when confidenceLevel < 0.4', () {
        final c = PersonalCalibration(userId: 'u1', confidenceLevel: 0.2);
        expect(c.quality, equals(CalibrationQuality.poor));
      });
    });

    group('JSON round-trip', () {
      test('serialises and deserialises with defaults', () {
        final original = PersonalCalibration.defaultFor('user-456');
        final json = original.toJson();
        final restored = PersonalCalibration.fromJson(json);

        expect(restored.userId, equals(original.userId));
        expect(restored.ageFactor, equals(original.ageFactor));
        expect(restored.confidenceLevel, equals(original.confidenceLevel));
        expect(restored.dataPointsUsed, equals(original.dataPointsUsed));
      });

      test('serialises and deserialises with all optional fields', () {
        final now = DateTime(2025, 6, 1, 12);
        final original = PersonalCalibration(
          userId: 'u2',
          ageFactor: 0.85,
          trainingAgeFactor: 1.15,
          sexFactor: 0.95,
          hrvFactor: 0.9,
          sleepFactor: 1.1,
          injuryFactor: 1.2,
          baselineHrv: 55.0,
          baselineSleepHours: 7.0,
          baselineRestingHr: 58.0,
          lastUpdated: now,
          dataPointsUsed: 42,
          confidenceLevel: 0.78,
        );

        final json = original.toJson();
        final restored = PersonalCalibration.fromJson(json);

        expect(restored.userId, equals('u2'));
        expect(restored.ageFactor, equals(0.85));
        expect(restored.hrvFactor, equals(0.9));
        expect(restored.baselineHrv, equals(55.0));
        expect(restored.dataPointsUsed, equals(42));
        expect(restored.confidenceLevel, equals(0.78));
      });

      test('handles null optional fields in JSON', () {
        final json = {
          'userId': 'u3',
          'ageFactor': 1.0,
          'trainingAgeFactor': 1.0,
          'sexFactor': 1.0,
          'hrvFactor': 1.0,
          'sleepFactor': 1.0,
          'injuryFactor': 1.0,
          'dataPointsUsed': 0,
          'confidenceLevel': 0.5,
        };

        final calibration = PersonalCalibration.fromJson(json);

        expect(calibration.baselineHrv, isNull);
        expect(calibration.baselineSleepHours, isNull);
        expect(calibration.baselineRestingHr, isNull);
        expect(calibration.lastUpdated, isNull);
      });
    });

    test('copyWith creates new instance with updated field', () {
      final original = PersonalCalibration.defaultFor('u1');
      final updated = original.copyWith(confidenceLevel: 0.95);

      expect(updated.confidenceLevel, equals(0.95));
      expect(updated.userId, equals('u1'));
      expect(original.confidenceLevel, equals(0.5)); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // MuscleStressData
  // ---------------------------------------------------------------------------

  group('MuscleStressData', () {
    MuscleStressData makeData({
      String muscleId = 'PETT',
      String displayName = 'Chest',
      double stressScore = 50.0,
      int setsCount = 3,
      double totalVolume = 1800.0,
      double avgRpe = 7.5,
      int recoveryHours = 48,
      DateTime? estimatedRecovery,
    }) {
      return MuscleStressData(
        muscleId: muscleId,
        displayName: displayName,
        stressScore: stressScore,
        setsCount: setsCount,
        totalVolume: totalVolume,
        avgRpe: avgRpe,
        recoveryHours: recoveryHours,
        estimatedRecovery:
            estimatedRecovery ?? DateTime.now().add(const Duration(hours: 48)),
      );
    }

    test('hasRpeData returns true when avgRpe > 0', () {
      final data = makeData(avgRpe: 7.5);
      expect(data.hasRpeData, isTrue);
    });

    test('hasRpeData returns false when avgRpe == 0', () {
      final data = makeData(avgRpe: 0);
      expect(data.hasRpeData, isFalse);
    });

    group('stressLevel', () {
      test('low when stressScore < 20', () {
        expect(makeData(stressScore: 10).stressLevel, MuscleStressLevel.low);
      });

      test('moderate when stressScore in [20, 40)', () {
        expect(
          makeData(stressScore: 30).stressLevel,
          MuscleStressLevel.moderate,
        );
      });

      test('high when stressScore in [40, 60)', () {
        expect(makeData(stressScore: 55).stressLevel, MuscleStressLevel.high);
      });

      test('veryHigh when stressScore >= 60', () {
        expect(
          makeData(stressScore: 75).stressLevel,
          MuscleStressLevel.veryHigh,
        );
      });
    });

    group('JSON round-trip', () {
      test('serialises and deserialises correctly', () {
        final now = DateTime(2025, 3, 15, 10);
        final original = MuscleStressData(
          muscleId: 'LAT',
          displayName: 'Lats',
          stressScore: 45.5,
          setsCount: 4,
          totalVolume: 2400.0,
          avgRpe: 8.0,
          recoveryHours: 56,
          estimatedRecovery: now,
        );

        final json = original.toJson();
        final restored = MuscleStressData.fromJson(json);

        expect(restored.muscleId, equals('LAT'));
        expect(restored.displayName, equals('Lats'));
        expect(restored.stressScore, equals(45.5));
        expect(restored.setsCount, equals(4));
        expect(restored.totalVolume, equals(2400.0));
        expect(restored.avgRpe, equals(8.0));
        expect(restored.recoveryHours, equals(56));
        expect(restored.estimatedRecovery, equals(now));
      });

      test('serialises and deserialises with null estimatedRecovery', () {
        final original = MuscleStressData(
          muscleId: 'QUAD',
          displayName: 'Quadriceps',
          stressScore: 25.0,
          setsCount: 2,
          totalVolume: 1200.0,
          avgRpe: 0,
          recoveryHours: 36,
          estimatedRecovery: null,
        );

        final json = original.toJson();
        final restored = MuscleStressData.fromJson(json);

        expect(restored.estimatedRecovery, isNull);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // MuscleReadinessData
  // ---------------------------------------------------------------------------

  group('MuscleReadinessData', () {
    MuscleReadinessData makeReadiness({
      String muscleId = 'PETT',
      String displayName = 'Chest',
      double recoveryPercent = 85.0,
      int hoursSinceWorkout = 48,
      DateTime? lastWorkedAt,
      double lastWorkoutStress = 50.0,
      double expectedStressFromWorkout = 40.0,
      bool isPrimaryMuscle = true,
      double sleepModifier = 0.0,
      double hrvModifier = 0.0,
      double ageModifier = 0.0,
    }) {
      return MuscleReadinessData(
        muscleId: muscleId,
        displayName: displayName,
        recoveryPercent: recoveryPercent,
        hoursSinceWorkout: hoursSinceWorkout,
        lastWorkedAt: lastWorkedAt,
        lastWorkoutStress: lastWorkoutStress,
        expectedStressFromWorkout: expectedStressFromWorkout,
        isPrimaryMuscle: isPrimaryMuscle,
        sleepModifier: sleepModifier,
        hrvModifier: hrvModifier,
        ageModifier: ageModifier,
      );
    }

    group('state property', () {
      test('fullyReady when recoveryPercent >= 100', () {
        expect(makeReadiness(recoveryPercent: 110).state, MuscleReadinessState.fullyReady);
        expect(makeReadiness(recoveryPercent: 100).state, MuscleReadinessState.fullyReady);
      });

      test('ready when recoveryPercent in [90, 100)', () {
        expect(makeReadiness(recoveryPercent: 95).state, MuscleReadinessState.ready);
        expect(makeReadiness(recoveryPercent: 90).state, MuscleReadinessState.ready);
      });

      test('acceptable when recoveryPercent in [70, 90)', () {
        expect(makeReadiness(recoveryPercent: 80).state, MuscleReadinessState.acceptable);
        expect(makeReadiness(recoveryPercent: 70).state, MuscleReadinessState.acceptable);
      });

      test('underRecovered when recoveryPercent in [50, 70)', () {
        expect(makeReadiness(recoveryPercent: 60).state, MuscleReadinessState.underRecovered);
        expect(makeReadiness(recoveryPercent: 50).state, MuscleReadinessState.underRecovered);
      });

      test('fatigued when recoveryPercent < 50', () {
        expect(makeReadiness(recoveryPercent: 30).state, MuscleReadinessState.fatigued);
        expect(makeReadiness(recoveryPercent: 0).state, MuscleReadinessState.fatigued);
      });
    });

    group('computed booleans', () {
      test('isReady when fullyReady or ready', () {
        expect(makeReadiness(recoveryPercent: 105).isReady, isTrue);
        expect(makeReadiness(recoveryPercent: 92).isReady, isTrue);
        expect(makeReadiness(recoveryPercent: 80).isReady, isFalse);
      });

      test('isSuboptimal when acceptable or underRecovered', () {
        expect(makeReadiness(recoveryPercent: 80).isSuboptimal, isTrue);
        expect(makeReadiness(recoveryPercent: 55).isSuboptimal, isTrue);
        expect(makeReadiness(recoveryPercent: 95).isSuboptimal, isFalse);
        expect(makeReadiness(recoveryPercent: 30).isSuboptimal, isFalse);
      });

      test('shouldAvoid when fatigued', () {
        expect(makeReadiness(recoveryPercent: 30).shouldAvoid, isTrue);
        expect(makeReadiness(recoveryPercent: 60).shouldAvoid, isFalse);
      });
    });

    test('totalModifier sums all modifier factors', () {
      final data = makeReadiness(
        sleepModifier: -10.0,
        hrvModifier: -5.0,
        ageModifier: -3.0,
      );

      expect(data.totalModifier, closeTo(-18.0, 0.001));
    });

    test('hasSignificantModifiers returns true when abs(totalModifier) > 10', () {
      final significant = makeReadiness(sleepModifier: -15.0);
      final minor = makeReadiness(sleepModifier: -5.0);

      expect(significant.hasSignificantModifiers, isTrue);
      expect(minor.hasSignificantModifiers, isFalse);
    });

    group('JSON round-trip', () {
      test('serialises and deserialises required fields', () {
        final now = DateTime(2025, 3, 1, 8);
        final original = MuscleReadinessData(
          muscleId: 'BICEP',
          displayName: 'Biceps',
          recoveryPercent: 78.5,
          hoursSinceWorkout: 36,
          lastWorkedAt: now,
          lastWorkoutStress: 35.0,
          expectedStressFromWorkout: 30.0,
          isPrimaryMuscle: false,
          sleepModifier: -8.0,
          hrvModifier: 3.0,
          ageModifier: -2.0,
        );

        final json = original.toJson();
        final restored = MuscleReadinessData.fromJson(json);

        expect(restored.muscleId, equals('BICEP'));
        expect(restored.recoveryPercent, equals(78.5));
        expect(restored.hoursSinceWorkout, equals(36));
        expect(restored.lastWorkedAt, equals(now));
        expect(restored.lastWorkoutStress, equals(35.0));
        expect(restored.sleepModifier, equals(-8.0));
        expect(restored.isPrimaryMuscle, isFalse);
      });

      test('handles null lastWorkedAt', () {
        final original = MuscleReadinessData(
          muscleId: 'TRAP',
          displayName: 'Traps',
          recoveryPercent: 100.0,
          hoursSinceWorkout: 0,
        );

        final json = original.toJson();
        final restored = MuscleReadinessData.fromJson(json);

        expect(restored.lastWorkedAt, isNull);
      });
    });

    test('copyWith updates specific fields', () {
      final original = makeReadiness(recoveryPercent: 75.0);
      final updated = original.copyWith(recoveryPercent: 90.0, sleepModifier: -5.0);

      expect(updated.recoveryPercent, equals(90.0));
      expect(updated.sleepModifier, equals(-5.0));
      expect(updated.muscleId, equals(original.muscleId));
    });
  });

  // ---------------------------------------------------------------------------
  // StressIndexResult
  // ---------------------------------------------------------------------------

  group('StressIndexResult', () {
    MuscleStressData makeMuscleData(String muscleId, double score) {
      return MuscleStressData(
        muscleId: muscleId,
        displayName: muscleId,
        stressScore: score,
        setsCount: 3,
        totalVolume: 900.0,
        avgRpe: 7.0,
        recoveryHours: 48,
        estimatedRecovery: DateTime.now().add(const Duration(hours: 48)),
      );
    }

    StressIndexResult makeResult({
      double primaryScore = 55.0,
      double fallbackScore = 50.0,
      double confidence = 0.8,
      int totalSets = 4,
      int setsWithRpe = 3,
      Map<String, MuscleStressData>? muscleBreakdown,
    }) {
      return StressIndexResult(
        primaryScore: primaryScore,
        fallbackScore: fallbackScore,
        confidence: confidence,
        muscleBreakdown: muscleBreakdown ??
            {'PETT': makeMuscleData('PETT', 55.0)},
        totalSets: totalSets,
        setsWithRpe: setsWithRpe,
        workoutId: 'workout-1',
        calculatedAt: DateTime(2025, 3, 1),
        rawScore: 120.0,
      );
    }

    group('displayScore', () {
      test('returns primaryScore when confidence >= 0.5', () {
        final result = makeResult(
          primaryScore: 60.0,
          fallbackScore: 50.0,
          confidence: 0.6,
        );

        expect(result.displayScore, equals(60.0));
      });

      test('returns fallbackScore when confidence < 0.5', () {
        final result = makeResult(
          primaryScore: 60.0,
          fallbackScore: 50.0,
          confidence: 0.3,
        );

        expect(result.displayScore, equals(50.0));
      });

      test('returns primaryScore exactly at 0.5 confidence', () {
        final result = makeResult(
          primaryScore: 60.0,
          fallbackScore: 50.0,
          confidence: 0.5,
        );

        expect(result.displayScore, equals(60.0));
      });
    });

    group('confidence categories', () {
      test('isHighConfidence when >= 0.80', () {
        expect(makeResult(confidence: 0.85).isHighConfidence, isTrue);
        expect(makeResult(confidence: 0.80).isHighConfidence, isTrue);
        expect(makeResult(confidence: 0.79).isHighConfidence, isFalse);
      });

      test('isMediumConfidence when in [0.50, 0.80)', () {
        expect(makeResult(confidence: 0.65).isMediumConfidence, isTrue);
        expect(makeResult(confidence: 0.50).isMediumConfidence, isTrue);
        expect(makeResult(confidence: 0.80).isMediumConfidence, isFalse);
        expect(makeResult(confidence: 0.49).isMediumConfidence, isFalse);
      });

      test('isLowConfidence when < 0.50', () {
        expect(makeResult(confidence: 0.3).isLowConfidence, isTrue);
        expect(makeResult(confidence: 0.0).isLowConfidence, isTrue);
        expect(makeResult(confidence: 0.5).isLowConfidence, isFalse);
      });
    });

    group('stressLevel', () {
      test('light when displayScore < 30', () {
        final result = makeResult(primaryScore: 20.0, confidence: 1.0);
        expect(result.stressLevel, StressLevel.light);
      });

      test('moderate when displayScore in [30, 60)', () {
        final result = makeResult(primaryScore: 45.0, confidence: 1.0);
        expect(result.stressLevel, StressLevel.moderate);
      });

      test('hard when displayScore in [60, 80)', () {
        final result = makeResult(primaryScore: 70.0, confidence: 1.0);
        expect(result.stressLevel, StressLevel.hard);
      });

      test('veryHard when displayScore >= 80', () {
        final result = makeResult(primaryScore: 90.0, confidence: 1.0);
        expect(result.stressLevel, StressLevel.veryHard);
      });
    });

    group('scoreRange', () {
      test('returns exact score when high confidence', () {
        final result = makeResult(primaryScore: 65.0, confidence: 0.90);
        expect(result.scoreRange, equals('65'));
      });

      test('returns range when low or medium confidence', () {
        final result = makeResult(primaryScore: 50.0, confidence: 0.4);
        // displayScore = fallbackScore (50.0), range = 45-55
        final rangeStr = result.scoreRange;
        expect(rangeStr, contains('-'));
      });
    });

    group('JSON round-trip', () {
      test('serialises and deserialises correctly', () {
        final now = DateTime(2025, 3, 15, 14, 30);
        final workoutDate = DateTime(2025, 3, 14);
        final original = StressIndexResult(
          primaryScore: 62.5,
          fallbackScore: 58.0,
          confidence: 0.75,
          muscleBreakdown: {
            'PETT': makeMuscleData('PETT', 60.0),
            'LAT': makeMuscleData('LAT', 45.0),
          },
          totalSets: 8,
          setsWithRpe: 6,
          workoutId: 'w-abc-123',
          workoutName: 'Push Day',
          workoutDate: workoutDate,
          calculatedAt: now,
          rawScore: 150.0,
        );

        final json = original.toJson();
        final restored = StressIndexResult.fromJson(json);

        expect(restored.primaryScore, equals(62.5));
        expect(restored.fallbackScore, equals(58.0));
        expect(restored.confidence, equals(0.75));
        expect(restored.totalSets, equals(8));
        expect(restored.setsWithRpe, equals(6));
        expect(restored.workoutId, equals('w-abc-123'));
        expect(restored.workoutName, equals('Push Day'));
        expect(restored.workoutDate, equals(workoutDate));
        expect(restored.calculatedAt, equals(now));
        expect(restored.rawScore, equals(150.0));
        expect(restored.muscleBreakdown.length, equals(2));
        expect(restored.muscleBreakdown['PETT']?.stressScore, equals(60.0));
      });

      test('handles null optional fields', () {
        final original = makeResult();
        final json = original.toJson();
        final restored = StressIndexResult.fromJson(json);

        expect(restored.workoutName, isNull);
        expect(restored.workoutDate, isNull);
      });
    });
  });
}
