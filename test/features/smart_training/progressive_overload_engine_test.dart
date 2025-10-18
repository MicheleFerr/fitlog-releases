import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/services/progressive_overload_engine.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_training_metrics.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('ProgressiveOverloadEngine', () {
    group('calculateOneRM', () {
      test('should calculate 1RM correctly with Epley formula', () {
        // Test basic Epley formula: 1RM = weight * (1 + reps/30)
        final oneRM = ProgressiveOverloadEngine.calculateOneRM(100, 5);
        expect(oneRM, closeTo(116.67, 0.1));
      });

      test('should return weight when reps is 1', () {
        final oneRM = ProgressiveOverloadEngine.calculateOneRM(100, 1);
        expect(oneRM, equals(100));
      });

      test('should adjust for RPE when provided', () {
        final oneRMWithRPE = ProgressiveOverloadEngine.calculateOneRM(100, 5, rpe: 8);
        final oneRMWithoutRPE = ProgressiveOverloadEngine.calculateOneRM(100, 5);
        
        // With RPE adjustment, 1RM should be different
        expect(oneRMWithRPE, isNot(equals(oneRMWithoutRPE)));
      });
    });

    group('calculateVolume', () {
      test('should calculate volume correctly for completed sets', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 100, reps: 10, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 100, reps: 8, isCompleted: true),
          ExerciseSet(setNumber: 3, weight: 80, reps: 12, isCompleted: false), // Not completed
        ];

        final volume = ProgressiveOverloadEngine.calculateVolume(sets);
        expect(volume, equals(1800)); // 100*10 + 100*8 = 1800
      });

      test('should exclude warmup sets by default', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 50, reps: 10, isWarmup: true, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 100, reps: 8, isCompleted: true),
        ];

        final volume = ProgressiveOverloadEngine.calculateVolume(sets);
        expect(volume, equals(800)); // Only 100*8, warmup excluded
      });

      test('should include warmup sets when specified', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 50, reps: 10, isWarmup: true, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 100, reps: 8, isCompleted: true),
        ];

        final volume = ProgressiveOverloadEngine.calculateVolume(sets, includeWarmup: true);
        expect(volume, equals(1300)); // 50*10 + 100*8 = 1300
      });
    });

    group('calculateAverageIntensity', () {
      test('should calculate average intensity correctly', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 80, reps: 8, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 90, reps: 6, isCompleted: true),
        ];
        const oneRM = 100.0;

        final avgIntensity = ProgressiveOverloadEngine.calculateAverageIntensity(sets, oneRM);
        expect(avgIntensity, equals(85.0)); // (80% + 90%) / 2 = 85%
      });

      test('should return 0 when oneRM is 0', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 100, reps: 8, isCompleted: true),
        ];

        final avgIntensity = ProgressiveOverloadEngine.calculateAverageIntensity(sets, 0);
        expect(avgIntensity, equals(0));
      });

      test('should exclude warmup sets', () {
        final sets = [
          ExerciseSet(setNumber: 1, weight: 50, reps: 10, isWarmup: true, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 80, reps: 8, isCompleted: true),
        ];
        const oneRM = 100.0;

        final avgIntensity = ProgressiveOverloadEngine.calculateAverageIntensity(sets, oneRM);
        expect(avgIntensity, equals(80.0)); // Only 80% from working set
      });
    });

    group('needsDeload', () {
      test('should return false with insufficient data', () {
        final metrics = [
          _createMockMetrics(fatigue: 8.0, readiness: 6.0, volume: 1000),
        ];

        final needsDeload = ProgressiveOverloadEngine.needsDeload(metrics);
        expect(needsDeload, isFalse);
      });

      test('should detect deload need with high fatigue', () {
        final metrics = [
          _createMockMetrics(fatigue: 8.5, readiness: 8.0, volume: 1000),
          _createMockMetrics(fatigue: 8.0, readiness: 7.5, volume: 1000),
          _createMockMetrics(fatigue: 7.5, readiness: 8.0, volume: 1000),
        ];

        final needsDeload = ProgressiveOverloadEngine.needsDeload(metrics);
        expect(needsDeload, isTrue);
      });

      test('should detect deload need with low readiness and volume decline', () {
        final metrics = [
          _createMockMetrics(fatigue: 7.0, readiness: 5.5, volume: 800),
          _createMockMetrics(fatigue: 6.5, readiness: 6.0, volume: 850),
          _createMockMetrics(fatigue: 6.0, readiness: 7.0, volume: 1000),
          _createMockMetrics(fatigue: 6.0, readiness: 7.5, volume: 1000),
        ];

        final needsDeload = ProgressiveOverloadEngine.needsDeload(metrics);
        expect(needsDeload, isTrue);
      });
    });

    group('calculateProgressRate', () {
      test('should return 0 with insufficient data', () {
        final metrics = [
          _createMockMetrics(volume: 1000),
          _createMockMetrics(volume: 1000),
        ];

        final progressRate = ProgressiveOverloadEngine.calculateProgressRate(metrics);
        expect(progressRate, equals(0.0));
      });

      test('should calculate positive progress rate', () {
        final now = DateTime.now();
        final metrics = [
          _createMockMetrics(volume: 1200, date: now),
          _createMockMetrics(volume: 1100, date: now.subtract(const Duration(days: 7))),
          _createMockMetrics(volume: 1050, date: now.subtract(const Duration(days: 14))),
          _createMockMetrics(volume: 1000, date: now.subtract(const Duration(days: 21))),
        ];

        final progressRate = ProgressiveOverloadEngine.calculateProgressRate(metrics);
        expect(progressRate, greaterThan(0)); // Should show positive progress
      });
    });

    group('generateOverloadRecommendations', () {
      test('should return basic recommendation with insufficient data', () {
        final metrics = [
          _createMockMetrics(volume: 1000),
        ];

        final recommendations = ProgressiveOverloadEngine.generateOverloadRecommendations(
          'Bench Press',
          metrics,
          null,
        );

        expect(recommendations, isNotEmpty);
        expect(recommendations.first.method, equals(OverloadMethod.volume));
        expect(recommendations.first.description, contains('Continue current training'));
      });

      test('should recommend volume increase with stagnant progression', () {
        final metrics = [
          _createMockMetrics(volume: 1000, averageIntensity: 75),
          _createMockMetrics(volume: 1000, averageIntensity: 75),
        ];

        final recommendations = ProgressiveOverloadEngine.generateOverloadRecommendations(
          'Bench Press',
          metrics,
          null,
        );

        final volumeRec = recommendations.where((r) => r.method == OverloadMethod.volume).firstOrNull;
        expect(volumeRec, isNotNull);
        expect(volumeRec!.description, contains('volume'));
      });

      test('should recommend intensity increase with low intensity', () {
        final metrics = [
          _createMockMetrics(volume: 1000, averageIntensity: 70),
          _createMockMetrics(volume: 1050, averageIntensity: 72),
        ];

        final recommendations = ProgressiveOverloadEngine.generateOverloadRecommendations(
          'Bench Press',
          metrics,
          null,
        );

        final intensityRec = recommendations.where((r) => r.method == OverloadMethod.intensity).firstOrNull;
        expect(intensityRec, isNotNull);
        expect(intensityRec!.description, contains('weight'));
      });
    });
  });
}

SmartTrainingMetrics _createMockMetrics({
  double fatigue = 5.0,
  double readiness = 8.0,
  double volume = 1000.0,
  double averageIntensity = 75.0,
  DateTime? date,
}) {
  return SmartTrainingMetrics(
    userId: 'test_user',
    date: date ?? DateTime.now(),
    volume: volume,
    totalSets: 10,
    totalReps: 80,
    averageIntensity: averageIntensity,
    trainingLoad: volume * (averageIntensity / 100),
    sessionDuration: 60,
    fatigueScore: fatigue,
    readinessScore: readiness,
    muscleGroupVolume: {'chest': volume / 2, 'arms': volume / 2},
    exerciseMetrics: [],
  );
}