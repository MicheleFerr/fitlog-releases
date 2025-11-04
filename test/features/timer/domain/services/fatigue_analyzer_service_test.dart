import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/fatigue_analyzer_service.dart';

void main() {
  late FatigueAnalyzerService service;

  setUp(() {
    service = FatigueAnalyzerService();
  });

  group('calculateRealTimeFatigue', () {
    test('should return 0.0 when velocity data has less than 3 entries', () {
      final velocities = [1.0, 2.0];
      final timestamps = [
        DateTime.now(),
        DateTime.now().add(const Duration(seconds: 1)),
      ];

      final result = service.calculateRealTimeFatigue(velocities, timestamps);

      expect(result, 0.0);
    });

    test('should calculate fatigue for valid velocity and timestamp data', () {
      // Decrescente: velocità che diminuisce (segno di fatica)
      final velocities = [2.0, 1.8, 1.6, 1.4, 1.2];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 3)),
      );

      final result = service.calculateRealTimeFatigue(velocities, timestamps);

      // Dovrebbe essere > 0 dato che c'è perdita di velocità
      expect(result, greaterThan(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });

    test('should clamp result between 0 and 100', () {
      final velocities = [10.0, 5.0, 2.0, 1.0, 0.5];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 2)),
      );

      final result = service.calculateRealTimeFatigue(velocities, timestamps);

      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });

    test('should handle constant velocity (no fatigue)', () {
      final velocities = [2.0, 2.0, 2.0, 2.0, 2.0];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 3)),
      );

      final result = service.calculateRealTimeFatigue(velocities, timestamps);

      // Con velocità costante, dovrebbe essere basso/zero
      expect(result, lessThan(10.0));
    });

    test('should handle negative velocities (absolute values)', () {
      final velocities = [-2.0, -1.8, -1.6, -1.4, -1.2];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 3)),
      );

      final result = service.calculateRealTimeFatigue(velocities, timestamps);

      expect(result, greaterThan(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });
  });

  group('calculateSetFatigue', () {
    test('should return 0.0 when velocity data has less than 3 entries', () async {
      final velocities = [1.0, 2.0];
      final timestamps = [
        DateTime.now(),
        DateTime.now().add(const Duration(seconds: 1)),
      ];

      final result = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
      );

      expect(result, 0.0);
    });

    test('should calculate comprehensive fatigue without weight', () async {
      final velocities = [2.0, 1.9, 1.7, 1.5, 1.3];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 4)),
      );

      final result = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
      );

      expect(result, greaterThan(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });

    test('should calculate fatigue with weight parameter', () async {
      final velocities = [2.5, 2.3, 2.0, 1.7, 1.5];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 3)),
      );

      final result = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
        weight: 100.0,
      );

      expect(result, greaterThan(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });

    test('should handle extreme fatigue scenario', () async {
      // Velocità che crolla drasticamente
      final velocities = [3.0, 2.5, 2.0, 1.0, 0.5];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 5)),
      );

      final result = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
        weight: 150.0,
      );

      // Dovrebbe essere alto dato il crollo di velocità
      expect(result, greaterThan(30.0));
      expect(result, lessThanOrEqualTo(100.0));
    });

    test('should be clamped between 0 and 100', () async {
      final velocities = [10.0, 8.0, 5.0, 2.0, 0.1];
      final timestamps = List.generate(
        5,
        (i) => DateTime.now().add(Duration(seconds: i * 2)),
      );

      final result = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
        weight: 200.0,
      );

      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThanOrEqualTo(100.0));
    });
  });

  group('predictOptimalRestTime', () {
    test('should return base rest time for squat with low fatigue', () {
      final result = service.predictOptimalRestTime(15.0, 'squat');

      // Squat base = 180s, fatigue < 20 = 0.8x multiplier = 144s
      expect(result.inSeconds, 144);
    });

    test('should return increased rest time for high fatigue', () {
      final result = service.predictOptimalRestTime(85.0, 'bench_press');

      // Bench base = 120s, fatigue > 80 = 2.0x multiplier = 240s
      expect(result.inSeconds, 240);
    });

    test('should handle deadlift with moderate fatigue', () {
      final result = service.predictOptimalRestTime(55.0, 'deadlift');

      // Deadlift base = 240s, fatigue 40-60 = 1.2x multiplier = 288s
      expect(result.inSeconds, 288);
    });

    test('should handle case insensitive exercise type', () {
      final result1 = service.predictOptimalRestTime(50.0, 'SQUAT');
      final result2 = service.predictOptimalRestTime(50.0, 'squat');

      expect(result1, result2);
    });

    test('should use default rest time for unknown exercise', () {
      final result = service.predictOptimalRestTime(25.0, 'unknown_exercise');

      // Default = 120s, fatigue 20-40 = 1.0x multiplier = 120s
      expect(result.inSeconds, 120);
    });

    test('should handle all exercise types', () {
      final exercises = [
        'squat',
        'deadlift',
        'bench_press',
        'overhead_press',
        'row',
        'curl',
        'isolation',
      ];

      for (final exercise in exercises) {
        final result = service.predictOptimalRestTime(50.0, exercise);
        expect(result.inSeconds, greaterThan(0));
      }
    });

    test('should scale rest time with fatigue levels', () {
      const exercise = 'bench_press';

      final lowFatigue = service.predictOptimalRestTime(10.0, exercise);
      final medFatigue = service.predictOptimalRestTime(50.0, exercise);
      final highFatigue = service.predictOptimalRestTime(85.0, exercise);

      // Rest dovrebbe aumentare con la fatica
      expect(lowFatigue.inSeconds, lessThan(medFatigue.inSeconds));
      expect(medFatigue.inSeconds, lessThan(highFatigue.inSeconds));
    });
  });

  group('getFatigueRecommendation', () {
    test('should recommend stopping for extreme fatigue (>90)', () {
      final result = service.getFatigueRecommendation(95.0, 3, 5);

      expect(result.action, FatigueAction.stopSet);
      expect(result.priority, FatiguePriority.critical);
      expect(result.weightAdjustment, -15.0);
      expect(result.restRecommendation, const Duration(minutes: 5));
      expect(result.message, contains('Extreme fatigue'));
    });

    test('should recommend considering ending for high fatigue (>75)', () {
      final result = service.getFatigueRecommendation(80.0, 2, 5);

      expect(result.action, FatigueAction.considerEnding);
      expect(result.priority, FatiguePriority.high);
      expect(result.weightAdjustment, -10.0);
      expect(result.restRecommendation, const Duration(minutes: 3));
      expect(result.message, contains('High fatigue'));
    });

    test('should recommend monitoring for moderate fatigue (>50)', () {
      final result = service.getFatigueRecommendation(60.0, 2, 5);

      expect(result.action, FatigueAction.monitor);
      expect(result.priority, FatiguePriority.medium);
      expect(result.weightAdjustment, -5.0);
      expect(result.restRecommendation, const Duration(minutes: 2));
      expect(result.message, contains('Moderate fatigue'));
    });

    test('should recommend proceeding for low fatigue (<=50)', () {
      final result = service.getFatigueRecommendation(30.0, 1, 5);

      expect(result.action, FatigueAction.proceed);
      expect(result.priority, FatiguePriority.low);
      expect(result.weightAdjustment, 0.0);
      expect(result.restRecommendation, const Duration(seconds: 90));
      expect(result.message, contains('Low fatigue'));
    });

    test('should handle edge case at exactly 90', () {
      final result = service.getFatigueRecommendation(90.0, 3, 5);

      expect(result.action, FatigueAction.considerEnding);
      expect(result.priority, FatiguePriority.high);
    });

    test('should handle edge case at exactly 75', () {
      final result = service.getFatigueRecommendation(75.0, 2, 5);

      expect(result.action, FatigueAction.monitor);
      expect(result.priority, FatiguePriority.medium);
    });

    test('should handle edge case at exactly 50', () {
      final result = service.getFatigueRecommendation(50.0, 1, 5);

      expect(result.action, FatigueAction.proceed);
      expect(result.priority, FatiguePriority.low);
    });

    test('should handle zero fatigue', () {
      final result = service.getFatigueRecommendation(0.0, 1, 5);

      expect(result.action, FatigueAction.proceed);
      expect(result.priority, FatiguePriority.low);
    });

    test('should handle 100% fatigue', () {
      final result = service.getFatigueRecommendation(100.0, 4, 5);

      expect(result.action, FatigueAction.stopSet);
      expect(result.priority, FatiguePriority.critical);
    });
  });

  group('FatigueRecommendation', () {
    test('should create recommendation with all fields', () {
      const recommendation = FatigueRecommendation(
        action: FatigueAction.monitor,
        message: 'Test message',
        restRecommendation: Duration(minutes: 2),
        weightAdjustment: -5.0,
        priority: FatiguePriority.medium,
      );

      expect(recommendation.action, FatigueAction.monitor);
      expect(recommendation.message, 'Test message');
      expect(recommendation.restRecommendation, const Duration(minutes: 2));
      expect(recommendation.weightAdjustment, -5.0);
      expect(recommendation.priority, FatiguePriority.medium);
    });
  });

  group('FatigueAction Enum', () {
    test('should have all expected values', () {
      expect(FatigueAction.values.length, 4);
      expect(FatigueAction.values, contains(FatigueAction.proceed));
      expect(FatigueAction.values, contains(FatigueAction.monitor));
      expect(FatigueAction.values, contains(FatigueAction.considerEnding));
      expect(FatigueAction.values, contains(FatigueAction.stopSet));
    });
  });

  group('FatiguePriority Enum', () {
    test('should have all expected values', () {
      expect(FatiguePriority.values.length, 4);
      expect(FatiguePriority.values, contains(FatiguePriority.low));
      expect(FatiguePriority.values, contains(FatiguePriority.medium));
      expect(FatiguePriority.values, contains(FatiguePriority.high));
      expect(FatiguePriority.values, contains(FatiguePriority.critical));
    });
  });

  group('Integration Tests', () {
    test('should provide consistent recommendations across complete workout set', () {
      // Simula un set completo con fatica crescente
      final service = FatigueAnalyzerService();

      final velocities1 = [2.0, 2.0, 1.9];
      final timestamps1 = List.generate(3, (i) => DateTime.now().add(Duration(seconds: i * 3)));
      final fatigue1 = service.calculateRealTimeFatigue(velocities1, timestamps1);
      final rec1 = service.getFatigueRecommendation(fatigue1, 1, 5);

      expect(rec1.action, FatigueAction.proceed);

      final velocities2 = [2.0, 1.9, 1.7, 1.5];
      final timestamps2 = List.generate(4, (i) => DateTime.now().add(Duration(seconds: i * 3)));
      final fatigue2 = service.calculateRealTimeFatigue(velocities2, timestamps2);

      // Fatica dovrebbe aumentare
      expect(fatigue2, greaterThan(fatigue1));
    });

    test('should handle complete workflow from data to recommendation', () async {
      final service = FatigueAnalyzerService();

      // Dati realistici
      final velocities = [2.2, 2.1, 1.9, 1.7, 1.5];
      final timestamps = List.generate(5, (i) => DateTime.now().add(Duration(seconds: i * 4)));

      // Calcolo fatica
      final fatigue = await service.calculateSetFatigue(
        velocityData: velocities,
        repTimestamps: timestamps,
        weight: 100.0,
      );

      // Predizione rest
      final restTime = service.predictOptimalRestTime(fatigue, 'bench_press');

      // Raccomandazione
      final recommendation = service.getFatigueRecommendation(fatigue, 2, 5);

      // Verifica coerenza
      expect(fatigue, greaterThan(0.0));
      expect(restTime.inSeconds, greaterThan(0));
      expect(recommendation.action, isA<FatigueAction>());
    });
  });
}
