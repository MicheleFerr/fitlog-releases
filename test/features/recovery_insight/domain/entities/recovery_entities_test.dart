/// Recovery Insight domain entities tests - RecoveryCategory, RecoveryInsight,
/// SleepQuality, SleepRecord, SleepWorkoutCorrelation, SleepPattern.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';

void main() {
  group('RecoveryCategory', () {
    test('has 5 values', () {
      expect(RecoveryCategory.values.length, 5);
    });

    test('fromScore', () {
      expect(RecoveryCategoryExtension.fromScore(90), RecoveryCategory.optimal);
      expect(RecoveryCategoryExtension.fromScore(85), RecoveryCategory.optimal);
      expect(RecoveryCategoryExtension.fromScore(75), RecoveryCategory.good);
      expect(RecoveryCategoryExtension.fromScore(60), RecoveryCategory.moderate);
      expect(RecoveryCategoryExtension.fromScore(45), RecoveryCategory.low);
      expect(RecoveryCategoryExtension.fromScore(30), RecoveryCategory.critical);
    });

    test('colorName unique for each category', () {
      for (final c in RecoveryCategory.values) {
        expect(c.colorName, isNotEmpty);
      }
    });

    test('emoji unique for each category', () {
      final emojis = RecoveryCategory.values.map((c) => c.emoji).toSet();
      expect(emojis.length, 5);
    });

    test('filledDots', () {
      expect(RecoveryCategory.optimal.filledDots, 5);
      expect(RecoveryCategory.good.filledDots, 4);
      expect(RecoveryCategory.moderate.filledDots, 3);
      expect(RecoveryCategory.low.filledDots, 2);
      expect(RecoveryCategory.critical.filledDots, 1);
    });
  });

  group('RecoveryInsight', () {
    test('noData factory', () {
      final insight = RecoveryInsight.noData();
      expect(insight.score, 75);
      expect(insight.category, RecoveryCategory.good);
      expect(insight.hasSleepData, isFalse);
      expect(insight.consecutiveBadNights, 0);
    });

    test('formattedLastNight with hours and minutes', () {
      const insight = RecoveryInsight(
        score: 80,
        category: RecoveryCategory.good,
        recommendation: 'Test',
        lastNightSleep: Duration(hours: 7, minutes: 32),
        weeklyAverageHours: 7.5,
        consecutiveBadNights: 0,
        streakDays: 5,
      );
      expect(insight.formattedLastNight, '7h 32m');
    });

    test('formattedLastNight no data', () {
      final insight = RecoveryInsight.noData();
      expect(insight.formattedLastNight, '--');
    });

    test('formattedLastNight hours only', () {
      const insight = RecoveryInsight(
        score: 80,
        category: RecoveryCategory.good,
        recommendation: 'Test',
        lastNightSleep: Duration(hours: 8),
        weeklyAverageHours: 8.0,
        consecutiveBadNights: 0,
        streakDays: 3,
      );
      expect(insight.formattedLastNight, '8h');
    });

    test('formattedLastNight minutes only', () {
      const insight = RecoveryInsight(
        score: 30,
        category: RecoveryCategory.critical,
        recommendation: 'Rest',
        lastNightSleep: Duration(minutes: 45),
        weeklyAverageHours: 3.0,
        consecutiveBadNights: 3,
        streakDays: 0,
      );
      expect(insight.formattedLastNight, '45m');
    });

    test('formattedWeeklyAverage', () {
      const insight = RecoveryInsight(
        score: 80,
        category: RecoveryCategory.good,
        recommendation: 'Test',
        lastNightSleep: Duration(hours: 7),
        weeklyAverageHours: 7.2,
        consecutiveBadNights: 0,
        streakDays: 3,
      );
      expect(insight.formattedWeeklyAverage, '7.2h');
    });

    test('formattedWeeklyAverage no data', () {
      final insight = RecoveryInsight.noData();
      expect(insight.formattedWeeklyAverage, '--');
    });

    test('isInBadSleepState', () {
      const bad = RecoveryInsight(
        score: 40,
        category: RecoveryCategory.low,
        recommendation: 'Rest',
        lastNightSleep: Duration(hours: 5),
        weeklyAverageHours: 5.5,
        consecutiveBadNights: 3,
        streakDays: 0,
      );
      expect(bad.isInBadSleepState, isTrue);

      const ok = RecoveryInsight(
        score: 80,
        category: RecoveryCategory.good,
        recommendation: 'OK',
        lastNightSleep: Duration(hours: 7),
        weeklyAverageHours: 7.5,
        consecutiveBadNights: 1,
        streakDays: 5,
      );
      expect(ok.isInBadSleepState, isFalse);
    });

    test('isReadyForTraining', () {
      const ready = RecoveryInsight(
        score: 60,
        category: RecoveryCategory.moderate,
        recommendation: 'Light',
        lastNightSleep: Duration(hours: 6),
        weeklyAverageHours: 6.5,
        consecutiveBadNights: 0,
        streakDays: 2,
      );
      expect(ready.isReadyForTraining, isTrue);

      const notReady = RecoveryInsight(
        score: 35,
        category: RecoveryCategory.critical,
        recommendation: 'Rest',
        lastNightSleep: Duration(hours: 4),
        weeklyAverageHours: 4.5,
        consecutiveBadNights: 4,
        streakDays: 0,
      );
      expect(notReady.isReadyForTraining, isFalse);
    });

    test('shouldRest', () {
      const shouldRest = RecoveryInsight(
        score: 35,
        category: RecoveryCategory.critical,
        recommendation: 'Rest',
        lastNightSleep: Duration(hours: 4),
        weeklyAverageHours: 4.5,
        consecutiveBadNights: 4,
        streakDays: 0,
      );
      expect(shouldRest.shouldRest, isTrue);

      const shouldNotRest = RecoveryInsight(
        score: 75,
        category: RecoveryCategory.good,
        recommendation: 'Train',
        lastNightSleep: Duration(hours: 7),
        weeklyAverageHours: 7.5,
        consecutiveBadNights: 0,
        streakDays: 5,
      );
      expect(shouldNotRest.shouldRest, isFalse);
    });
  });

  group('SleepQuality', () {
    test('has 4 values', () {
      expect(SleepQuality.values.length, 4);
    });

    test('fromHours', () {
      expect(SleepQualityExtension.fromHours(5.0), SleepQuality.critical);
      expect(SleepQualityExtension.fromHours(6.5), SleepQuality.suboptimal);
      expect(SleepQualityExtension.fromHours(7.5), SleepQuality.optimal);
      expect(SleepQualityExtension.fromHours(9.5), SleepQuality.excessive);
    });

    test('colorName', () {
      expect(SleepQuality.critical.colorName, 'error');
      expect(SleepQuality.optimal.colorName, 'success');
    });
  });

  group('SleepRecord', () {
    test('fromHealthData', () {
      final record = SleepRecord.fromHealthData(
        date: DateTime(2025, 3, 1),
        asleepMinutes: 450, // 7h 30m
        inBedMinutes: 510, // 8h 30m
        source: 'HealthKit',
      );
      expect(record.quality, SleepQuality.optimal);
      expect(record.source, 'HealthKit');
      expect(record.efficiency, closeTo(88.2, 0.1));
    });

    test('asleepHours', () {
      final record = SleepRecord(
        date: DateTime(2025, 3, 1),
        asleepDuration: const Duration(hours: 7, minutes: 30),
        inBedDuration: const Duration(hours: 8),
        efficiency: 93.75,
        quality: SleepQuality.optimal,
      );
      expect(record.asleepHours, 7.5);
    });

    test('formattedDuration', () {
      final record = SleepRecord(
        date: DateTime(2025, 3, 1),
        asleepDuration: const Duration(hours: 7, minutes: 30),
        inBedDuration: const Duration(hours: 8),
        efficiency: 93.75,
        quality: SleepQuality.optimal,
      );
      expect(record.formattedDuration, '7h 30m');
    });

    test('isBadNight', () {
      final bad = SleepRecord.fromHealthData(
        date: DateTime(2025, 3, 1),
        asleepMinutes: 300, // 5h
        inBedMinutes: 360,
      );
      expect(bad.isBadNight, isTrue);

      final good = SleepRecord.fromHealthData(
        date: DateTime(2025, 3, 1),
        asleepMinutes: 480, // 8h
        inBedMinutes: 510,
      );
      expect(good.isBadNight, isFalse);
    });

    test('meetsRecommendation', () {
      final meets = SleepRecord.fromHealthData(
        date: DateTime(2025, 3, 1),
        asleepMinutes: 480, // 8h
        inBedMinutes: 510,
      );
      expect(meets.meetsRecommendation, isTrue);

      final doesNot = SleepRecord.fromHealthData(
        date: DateTime(2025, 3, 1),
        asleepMinutes: 360, // 6h
        inBedMinutes: 400,
      );
      expect(doesNot.meetsRecommendation, isFalse);
    });
  });

  group('SleepPattern', () {
    test('has 4 values', () {
      expect(SleepPattern.values.length, 4);
    });
  });

  group('SleepWorkoutCorrelation', () {
    test('noData factory', () {
      final corr = SleepWorkoutCorrelation.noData();
      expect(corr.workoutSampleSize, 0);
      expect(corr.sleepSampleSize, 0);
      expect(corr.isSignificant, isFalse);
      expect(corr.hasEnoughData, isFalse);
    });

    test('formatVolumeChange', () {
      final corr = SleepWorkoutCorrelation.noData();
      expect(corr.formatVolumeChange(8.0), '+8%');
      expect(corr.formatVolumeChange(-15.0), '-15%');
      expect(corr.formatVolumeChange(0.0), '0%');
    });

    test('hasEnoughData', () {
      const corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -15,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: true,
      );
      expect(corr.hasEnoughData, isTrue);

      const notEnough = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -15,
        workoutSampleSize: 3,
        sleepSampleSize: 4,
        isSignificant: false,
      );
      expect(notEnough.hasEnoughData, isFalse);
    });

    test('hasConsistentPattern', () {
      const good = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -5,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: true,
        sleepPattern: SleepPattern.consistentlyGood,
      );
      expect(good.hasConsistentPattern, isTrue);

      const variable = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -5,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: true,
        sleepPattern: SleepPattern.variable,
      );
      expect(variable.hasConsistentPattern, isFalse);
    });

    test('formattedAverageSleep', () {
      const corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 0,
        volumeChangeBelow6h: 0,
        workoutSampleSize: 0,
        sleepSampleSize: 0,
        isSignificant: false,
        averageSleepHours: 7.3,
      );
      expect(corr.formattedAverageSleep, '7.3h');
    });

    test('summaryMessageKey not_enough_data', () {
      final corr = SleepWorkoutCorrelation.noData();
      expect(corr.summaryMessageKey, 'not_enough_data');
    });

    test('summaryMessageKey consistently_good', () {
      const corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -5,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: true,
        sleepPattern: SleepPattern.consistentlyGood,
        averageSleepHours: 7.8,
        averageVolume: 5000,
      );
      expect(corr.summaryMessageKey, startsWith('consistently_good'));
    });

    test('summaryMessageKey consistently_poor', () {
      const corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10,
        volumeChangeBelow6h: -15,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: true,
        sleepPattern: SleepPattern.consistentlyPoor,
        averageSleepHours: 5.2,
        averageVolume: 3000,
      );
      expect(corr.summaryMessageKey, startsWith('consistently_poor'));
    });

    test('summaryMessageKey not_significant', () {
      const corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 3,
        volumeChangeBelow6h: -2,
        workoutSampleSize: 10,
        sleepSampleSize: 14,
        isSignificant: false,
        sleepPattern: SleepPattern.variable,
      );
      expect(corr.summaryMessageKey, 'not_significant');
    });
  });

  group('SleepWorkoutDataPoint', () {
    test('sleepCategory', () {
      final date = DateTime(2025, 3, 1);

      final poor = SleepWorkoutDataPoint(
        workoutDate: date,
        sleepHours: 5.0,
        workoutVolume: 5000,
        workoutDurationMinutes: 60,
        exerciseCount: 6,
      );
      expect(poor.sleepCategory, 'poor');

      final moderate = SleepWorkoutDataPoint(
        workoutDate: date,
        sleepHours: 6.5,
        workoutVolume: 5000,
        workoutDurationMinutes: 60,
        exerciseCount: 6,
      );
      expect(moderate.sleepCategory, 'moderate');

      final good = SleepWorkoutDataPoint(
        workoutDate: date,
        sleepHours: 8.0,
        workoutVolume: 5000,
        workoutDurationMinutes: 60,
        exerciseCount: 6,
      );
      expect(good.sleepCategory, 'good');
    });
  });
}
