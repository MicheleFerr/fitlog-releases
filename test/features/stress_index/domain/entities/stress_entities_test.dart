/// Stress Index entity tests - JSON round-trips for all .g.dart files,
/// computed properties, and enum extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

void main() {
  group('PersonalCalibration JSON', () {
    test('round-trip with all fields', () {
      final cal = PersonalCalibration(
        userId: 'u1',
        ageFactor: 0.9,
        trainingAgeFactor: 1.1,
        sexFactor: 0.95,
        hrvFactor: 0.85,
        sleepFactor: 1.2,
        injuryFactor: 1.1,
        baselineHrv: 55.0,
        baselineSleepHours: 7.5,
      );
      final json = cal.toJson();
      final restored = PersonalCalibration.fromJson(json);
      expect(restored.userId, 'u1');
      expect(restored.ageFactor, 0.9);
      expect(restored.trainingAgeFactor, 1.1);
      expect(restored.sexFactor, 0.95);
      expect(restored.hrvFactor, 0.85);
      expect(restored.sleepFactor, 1.2);
      expect(restored.injuryFactor, 1.1);
      expect(restored.baselineHrv, 55.0);
      expect(restored.baselineSleepHours, 7.5);
    });

    test('round-trip with defaults', () {
      final cal = PersonalCalibration(userId: 'u2');
      final json = cal.toJson();
      final restored = PersonalCalibration.fromJson(json);
      expect(restored.ageFactor, 1.0);
      expect(restored.trainingAgeFactor, 1.0);
      expect(restored.sexFactor, 1.0);
      expect(restored.hrvFactor, 1.0);
      expect(restored.sleepFactor, 1.0);
      expect(restored.injuryFactor, 1.0);
      expect(restored.baselineHrv, isNull);
      expect(restored.baselineSleepHours, isNull);
    });
  });

  group('MuscleStressData JSON', () {
    test('round-trip preserves all fields', () {
      final data = MuscleStressData(
        muscleId: 'PETT',
        displayName: 'Chest',
        stressScore: 65.0,
        setsCount: 12,
        totalVolume: 8400.0,
        avgRpe: 8.0,
        recoveryHours: 48,
        estimatedRecovery: DateTime(2025, 3, 3, 10, 0),
      );
      final json = data.toJson();
      final restored = MuscleStressData.fromJson(json);
      expect(restored.muscleId, 'PETT');
      expect(restored.displayName, 'Chest');
      expect(restored.stressScore, 65.0);
      expect(restored.setsCount, 12);
      expect(restored.totalVolume, 8400.0);
      expect(restored.avgRpe, 8.0);
      expect(restored.recoveryHours, 48);
      expect(restored.estimatedRecovery, DateTime(2025, 3, 3, 10, 0));
    });

    test('round-trip with null estimatedRecovery', () {
      final data = MuscleStressData(
        muscleId: 'LAT',
        displayName: 'Lats',
        stressScore: 30.0,
        setsCount: 6,
        totalVolume: 3600.0,
        avgRpe: 0,
        recoveryHours: 24,
        estimatedRecovery: null,
      );
      final restored = MuscleStressData.fromJson(data.toJson());
      expect(restored.estimatedRecovery, isNull);
      expect(restored.avgRpe, 0);
    });

    test('hasRpeData', () {
      expect(
        MuscleStressData(
          muscleId: 'PETT', displayName: 'C', stressScore: 50,
          setsCount: 5, totalVolume: 1000, avgRpe: 7.5,
          recoveryHours: 48, estimatedRecovery: null,
        ).hasRpeData,
        isTrue,
      );
      expect(
        MuscleStressData(
          muscleId: 'PETT', displayName: 'C', stressScore: 50,
          setsCount: 5, totalVolume: 1000, avgRpe: 0,
          recoveryHours: 48, estimatedRecovery: null,
        ).hasRpeData,
        isFalse,
      );
    });

    test('stressLevel categories', () {
      MuscleStressData make(double score) => MuscleStressData(
        muscleId: 'X', displayName: 'X', stressScore: score,
        setsCount: 1, totalVolume: 100, avgRpe: 0,
        recoveryHours: 24, estimatedRecovery: null,
      );
      expect(make(10).stressLevel, MuscleStressLevel.low);
      expect(make(19.9).stressLevel, MuscleStressLevel.low);
      expect(make(20).stressLevel, MuscleStressLevel.moderate);
      expect(make(39.9).stressLevel, MuscleStressLevel.moderate);
      expect(make(40).stressLevel, MuscleStressLevel.high);
      expect(make(59.9).stressLevel, MuscleStressLevel.high);
      expect(make(60).stressLevel, MuscleStressLevel.veryHigh);
      expect(make(100).stressLevel, MuscleStressLevel.veryHigh);
    });
  });

  group('MuscleReadinessData JSON', () {
    test('round-trip preserves all fields', () {
      final data = MuscleReadinessData(
        muscleId: 'QUAD',
        displayName: 'Quadriceps',
        recoveryPercent: 85.0,
        lastWorkedAt: DateTime(2025, 3, 1),
        hoursSinceWorkout: 48,
        lastWorkoutStress: 70.0,
        expectedStressFromWorkout: 65.0,
        isPrimaryMuscle: true,
        sleepModifier: -10.0,
        hrvModifier: 5.0,
        ageModifier: -5.0,
      );
      final json = data.toJson();
      final restored = MuscleReadinessData.fromJson(json);
      expect(restored.muscleId, 'QUAD');
      expect(restored.displayName, 'Quadriceps');
      expect(restored.recoveryPercent, 85.0);
      expect(restored.lastWorkedAt, DateTime(2025, 3, 1));
      expect(restored.hoursSinceWorkout, 48);
      expect(restored.lastWorkoutStress, 70.0);
      expect(restored.expectedStressFromWorkout, 65.0);
      expect(restored.isPrimaryMuscle, isTrue);
      expect(restored.sleepModifier, -10.0);
      expect(restored.hrvModifier, 5.0);
      expect(restored.ageModifier, -5.0);
    });

    test('round-trip with defaults', () {
      final data = MuscleReadinessData(
        muscleId: 'BIC',
        displayName: 'Biceps',
        recoveryPercent: 100.0,
        hoursSinceWorkout: 72,
      );
      final restored = MuscleReadinessData.fromJson(data.toJson());
      expect(restored.lastWorkoutStress, 0);
      expect(restored.expectedStressFromWorkout, 0);
      expect(restored.isPrimaryMuscle, isFalse);
      expect(restored.sleepModifier, 0);
      expect(restored.hrvModifier, 0);
      expect(restored.ageModifier, 0);
      expect(restored.lastWorkedAt, isNull);
    });

    test('state - fullyReady at 100%+', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 105, hoursSinceWorkout: 72,
      );
      expect(d.state, MuscleReadinessState.fullyReady);
      expect(d.isReady, isTrue);
    });

    test('state - ready at 90-99%', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 92, hoursSinceWorkout: 48,
      );
      expect(d.state, MuscleReadinessState.ready);
      expect(d.isReady, isTrue);
    });

    test('state - acceptable at 70-89%', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 75, hoursSinceWorkout: 36,
      );
      expect(d.state, MuscleReadinessState.acceptable);
      expect(d.isSuboptimal, isTrue);
    });

    test('state - underRecovered at 50-69%', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 55, hoursSinceWorkout: 24,
      );
      expect(d.state, MuscleReadinessState.underRecovered);
      expect(d.isSuboptimal, isTrue);
    });

    test('state - fatigued at <50%', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 40, hoursSinceWorkout: 12,
      );
      expect(d.state, MuscleReadinessState.fatigued);
      expect(d.shouldAvoid, isTrue);
    });

    test('totalModifier sums all modifiers', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 80, hoursSinceWorkout: 48,
        sleepModifier: -15, hrvModifier: 5, ageModifier: -10,
      );
      expect(d.totalModifier, -20);
      expect(d.hasSignificantModifiers, isTrue);
    });

    test('hasSignificantModifiers false for small modifiers', () {
      final d = MuscleReadinessData(
        muscleId: 'X', displayName: 'X', recoveryPercent: 80, hoursSinceWorkout: 48,
        sleepModifier: -3, hrvModifier: 2, ageModifier: -1,
      );
      expect(d.totalModifier, -2);
      expect(d.hasSignificantModifiers, isFalse);
    });
  });

  group('StressIndexResult JSON', () {
    test('round-trip preserves all fields', () {
      final result = StressIndexResult(
        primaryScore: 72.5,
        fallbackScore: 65.0,
        confidence: 0.85,
        muscleBreakdown: {
          'PETT': MuscleStressData(
            muscleId: 'PETT', displayName: 'Chest', stressScore: 70,
            setsCount: 12, totalVolume: 8400, avgRpe: 8,
            recoveryHours: 48, estimatedRecovery: null,
          ),
        },
        totalSets: 20,
        setsWithRpe: 17,
        workoutId: 'w1',
        workoutName: 'Push Day',
        workoutDate: DateTime(2025, 3, 1),
        calculatedAt: DateTime(2025, 3, 1, 18, 30),
        rawScore: 450.0,
      );
      final json = result.toJson();
      final restored = StressIndexResult.fromJson(json);
      expect(restored.primaryScore, 72.5);
      expect(restored.fallbackScore, 65.0);
      expect(restored.confidence, 0.85);
      expect(restored.totalSets, 20);
      expect(restored.setsWithRpe, 17);
      expect(restored.workoutId, 'w1');
      expect(restored.workoutName, 'Push Day');
      expect(restored.rawScore, 450.0);
      expect(restored.muscleBreakdown.length, 1);
      expect(restored.muscleBreakdown['PETT']!.stressScore, 70);
    });

    test('round-trip with null optional fields', () {
      final result = StressIndexResult(
        primaryScore: 50,
        fallbackScore: 45,
        confidence: 0.5,
        muscleBreakdown: {},
        totalSets: 10,
        setsWithRpe: 5,
        workoutId: 'w2',
        calculatedAt: DateTime(2025, 1, 1),
        rawScore: 200,
      );
      final restored = StressIndexResult.fromJson(result.toJson());
      expect(restored.workoutName, isNull);
      expect(restored.workoutDate, isNull);
    });
  });

  group('StressIndexResult computed properties', () {
    StressIndexResult make({
      double primaryScore = 50,
      double confidence = 0.8,
    }) => StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: 40,
      confidence: confidence,
      muscleBreakdown: {},
      totalSets: 10,
      setsWithRpe: 8,
      workoutId: 'w1',
      calculatedAt: DateTime(2025, 1, 1),
      rawScore: 200,
    );

    test('stressLevel categories', () {
      expect(make(primaryScore: 15).stressLevel, StressLevel.light);
      expect(make(primaryScore: 29).stressLevel, StressLevel.light);
      expect(make(primaryScore: 30).stressLevel, StressLevel.moderate);
      expect(make(primaryScore: 59).stressLevel, StressLevel.moderate);
      expect(make(primaryScore: 60).stressLevel, StressLevel.hard);
      expect(make(primaryScore: 79).stressLevel, StressLevel.hard);
      expect(make(primaryScore: 80).stressLevel, StressLevel.veryHard);
      expect(make(primaryScore: 100).stressLevel, StressLevel.veryHard);
    });

    test('displayScore uses primaryScore when confident', () {
      expect(make(primaryScore: 70, confidence: 0.6).displayScore, 70);
    });

    test('displayScore uses fallbackScore when not confident', () {
      final r = StressIndexResult(
        primaryScore: 70,
        fallbackScore: 50,
        confidence: 0.4,
        muscleBreakdown: {},
        totalSets: 10,
        setsWithRpe: 4,
        workoutId: 'w1',
        calculatedAt: DateTime(2025, 1, 1),
        rawScore: 200,
      );
      expect(r.displayScore, 50);
    });

    test('isHighConfidence at 80%+', () {
      expect(make(confidence: 0.8).isHighConfidence, isTrue);
      expect(make(confidence: 0.9).isHighConfidence, isTrue);
      expect(make(confidence: 0.79).isHighConfidence, isFalse);
    });

    test('isMediumConfidence at 50-79%', () {
      expect(make(confidence: 0.5).isMediumConfidence, isTrue);
      expect(make(confidence: 0.7).isMediumConfidence, isTrue);
      expect(make(confidence: 0.8).isMediumConfidence, isFalse);
      expect(make(confidence: 0.49).isMediumConfidence, isFalse);
    });

    test('isLowConfidence below 50%', () {
      expect(make(confidence: 0.49).isLowConfidence, isTrue);
      expect(make(confidence: 0.5).isLowConfidence, isFalse);
    });

    test('scoreRange single value when high confidence', () {
      expect(make(primaryScore: 70, confidence: 0.85).scoreRange, '70');
    });

    test('scoreRange shows range when not high confidence', () {
      final range = make(primaryScore: 70, confidence: 0.6).scoreRange;
      expect(range, '63-77');
    });
  });
}
