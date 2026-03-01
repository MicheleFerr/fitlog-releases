/// Recovery Insight entities JSON round-trip tests.
/// Covers .g.dart generated code for SleepRecord, SleepWorkoutCorrelation,
/// SleepWorkoutDataPoint, and RecoveryInsight.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';

void main() {
  group('SleepRecord JSON', () {
    test('round-trip preserves all fields', () {
      final record = SleepRecord(
        date: DateTime(2025, 3, 1),
        asleepDuration: const Duration(hours: 7, minutes: 30),
        inBedDuration: const Duration(hours: 8, minutes: 15),
        efficiency: 90.9,
        quality: SleepQuality.optimal,
        source: 'HealthKit',
      );
      final json = record.toJson();
      final restored = SleepRecord.fromJson(json);

      expect(restored.date, record.date);
      expect(restored.asleepDuration, record.asleepDuration);
      expect(restored.inBedDuration, record.inBedDuration);
      expect(restored.efficiency, record.efficiency);
      expect(restored.quality, record.quality);
      expect(restored.source, record.source);
    });

    test('round-trip with null source', () {
      final record = SleepRecord(
        date: DateTime(2025, 3, 1),
        asleepDuration: const Duration(hours: 5),
        inBedDuration: const Duration(hours: 6),
        efficiency: 83.3,
        quality: SleepQuality.critical,
      );
      final json = record.toJson();
      final restored = SleepRecord.fromJson(json);
      expect(restored.source, isNull);
      expect(restored.quality, SleepQuality.critical);
    });

    test('all SleepQuality values round-trip', () {
      for (final quality in SleepQuality.values) {
        final record = SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 7),
          inBedDuration: const Duration(hours: 8),
          efficiency: 87.5,
          quality: quality,
        );
        final restored = SleepRecord.fromJson(record.toJson());
        expect(restored.quality, quality);
      }
    });

    test('fromJson with explicit JSON map', () {
      final json = {
        'date': '2025-03-01T00:00:00.000',
        'asleepDuration': const Duration(hours: 6).inMicroseconds,
        'inBedDuration': const Duration(hours: 7).inMicroseconds,
        'efficiency': 85.7,
        'quality': 'suboptimal',
        'source': 'Health Connect',
      };
      final record = SleepRecord.fromJson(json);
      expect(record.quality, SleepQuality.suboptimal);
      expect(record.source, 'Health Connect');
    });
  });

  group('SleepRecord computed properties', () {
    test('formattedDuration hours and minutes', () {
      final r = SleepRecord(
        date: DateTime(2025, 1, 1),
        asleepDuration: const Duration(hours: 7, minutes: 32),
        inBedDuration: const Duration(hours: 8),
        efficiency: 94.0,
        quality: SleepQuality.optimal,
      );
      expect(r.formattedDuration, '7h 32m');
    });

    test('formattedDuration hours only', () {
      final r = SleepRecord(
        date: DateTime(2025, 1, 1),
        asleepDuration: const Duration(hours: 8),
        inBedDuration: const Duration(hours: 9),
        efficiency: 88.9,
        quality: SleepQuality.optimal,
      );
      expect(r.formattedDuration, '8h');
    });

    test('formattedDuration minutes only', () {
      final r = SleepRecord(
        date: DateTime(2025, 1, 1),
        asleepDuration: const Duration(minutes: 45),
        inBedDuration: const Duration(hours: 1),
        efficiency: 75.0,
        quality: SleepQuality.critical,
      );
      expect(r.formattedDuration, '45m');
    });

    test('asleepHours and inBedHours', () {
      final r = SleepRecord(
        date: DateTime(2025, 1, 1),
        asleepDuration: const Duration(hours: 7, minutes: 30),
        inBedDuration: const Duration(hours: 8, minutes: 30),
        efficiency: 88.2,
        quality: SleepQuality.optimal,
      );
      expect(r.asleepHours, 7.5);
      expect(r.inBedHours, 8.5);
    });

    test('isBadNight', () {
      expect(
        SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 5),
          inBedDuration: const Duration(hours: 6),
          efficiency: 83.3,
          quality: SleepQuality.critical,
        ).isBadNight,
        isTrue,
      );
      expect(
        SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 7),
          inBedDuration: const Duration(hours: 8),
          efficiency: 87.5,
          quality: SleepQuality.optimal,
        ).isBadNight,
        isFalse,
      );
    });

    test('meetsRecommendation', () {
      expect(
        SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 7),
          inBedDuration: const Duration(hours: 8),
          efficiency: 87.5,
          quality: SleepQuality.optimal,
        ).meetsRecommendation,
        isTrue,
      );
      expect(
        SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 10),
          inBedDuration: const Duration(hours: 11),
          efficiency: 90.9,
          quality: SleepQuality.excessive,
        ).meetsRecommendation,
        isTrue,
      );
      expect(
        SleepRecord(
          date: DateTime(2025, 1, 1),
          asleepDuration: const Duration(hours: 6, minutes: 30),
          inBedDuration: const Duration(hours: 7),
          efficiency: 92.9,
          quality: SleepQuality.suboptimal,
        ).meetsRecommendation,
        isFalse,
      );
    });
  });

  group('SleepQualityExtension', () {
    test('fromHours boundaries', () {
      expect(SleepQualityExtension.fromHours(5.9), SleepQuality.critical);
      expect(SleepQualityExtension.fromHours(6.0), SleepQuality.suboptimal);
      expect(SleepQualityExtension.fromHours(6.9), SleepQuality.suboptimal);
      expect(SleepQualityExtension.fromHours(7.0), SleepQuality.optimal);
      expect(SleepQualityExtension.fromHours(9.0), SleepQuality.optimal);
      expect(SleepQualityExtension.fromHours(9.1), SleepQuality.excessive);
    });

    test('colorName for all values', () {
      expect(SleepQuality.critical.colorName, 'error');
      expect(SleepQuality.suboptimal.colorName, 'warning');
      expect(SleepQuality.optimal.colorName, 'success');
      expect(SleepQuality.excessive.colorName, 'warning');
    });
  });

  group('SleepRecord.fromHealthData', () {
    test('calculates efficiency and quality', () {
      final r = SleepRecord.fromHealthData(
        date: DateTime(2025, 1, 1),
        asleepMinutes: 420, // 7h
        inBedMinutes: 480, // 8h
        source: 'HealthKit',
      );
      expect(r.efficiency, 87.5);
      expect(r.quality, SleepQuality.optimal);
      expect(r.asleepDuration, const Duration(hours: 7));
      expect(r.inBedDuration, const Duration(hours: 8));
      expect(r.source, 'HealthKit');
    });

    test('zero inBedMinutes gives 0 efficiency', () {
      final r = SleepRecord.fromHealthData(
        date: DateTime(2025, 1, 1),
        asleepMinutes: 0,
        inBedMinutes: 0,
      );
      expect(r.efficiency, 0.0);
    });

    test('critical quality for short sleep', () {
      final r = SleepRecord.fromHealthData(
        date: DateTime(2025, 1, 1),
        asleepMinutes: 300, // 5h
        inBedMinutes: 360,
      );
      expect(r.quality, SleepQuality.critical);
    });
  });

  group('SleepWorkoutCorrelation JSON', () {
    test('round-trip preserves all fields', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 8.5,
        volumeChangeBelow6h: -15.2,
        workoutSampleSize: 20,
        sleepSampleSize: 28,
        isSignificant: true,
        periodDays: 60,
        workoutsWithGoodSleep: 12,
        workoutsWithPoorSleep: 5,
        sleepPattern: SleepPattern.variable,
        averageSleepHours: 7.2,
        averageVolume: 5400.0,
      );
      final json = corr.toJson();
      final restored = SleepWorkoutCorrelation.fromJson(json);

      expect(restored.volumeChangeAbove7h, corr.volumeChangeAbove7h);
      expect(restored.volumeChangeBelow6h, corr.volumeChangeBelow6h);
      expect(restored.workoutSampleSize, corr.workoutSampleSize);
      expect(restored.sleepSampleSize, corr.sleepSampleSize);
      expect(restored.isSignificant, corr.isSignificant);
      expect(restored.periodDays, corr.periodDays);
      expect(restored.workoutsWithGoodSleep, corr.workoutsWithGoodSleep);
      expect(restored.workoutsWithPoorSleep, corr.workoutsWithPoorSleep);
      expect(restored.sleepPattern, corr.sleepPattern);
      expect(restored.averageSleepHours, corr.averageSleepHours);
      expect(restored.averageVolume, corr.averageVolume);
    });

    test('round-trip with defaults', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 0,
        volumeChangeBelow6h: 0,
        workoutSampleSize: 3,
        sleepSampleSize: 5,
        isSignificant: false,
      );
      final json = corr.toJson();
      final restored = SleepWorkoutCorrelation.fromJson(json);
      expect(restored.periodDays, 30);
      expect(restored.workoutsWithGoodSleep, 0);
      expect(restored.workoutsWithPoorSleep, 0);
      expect(restored.sleepPattern, SleepPattern.unknown);
      expect(restored.averageSleepHours, 0.0);
      expect(restored.averageVolume, 0.0);
    });

    test('all SleepPattern values round-trip', () {
      for (final pattern in SleepPattern.values) {
        final corr = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0,
          volumeChangeBelow6h: 0,
          workoutSampleSize: 10,
          sleepSampleSize: 10,
          isSignificant: false,
          sleepPattern: pattern,
        );
        final restored = SleepWorkoutCorrelation.fromJson(corr.toJson());
        expect(restored.sleepPattern, pattern);
      }
    });
  });

  group('SleepWorkoutCorrelation computed properties', () {
    test('noData factory', () {
      final corr = SleepWorkoutCorrelation.noData();
      expect(corr.volumeChangeAbove7h, 0);
      expect(corr.volumeChangeBelow6h, 0);
      expect(corr.workoutSampleSize, 0);
      expect(corr.sleepSampleSize, 0);
      expect(corr.isSignificant, isFalse);
      expect(corr.hasEnoughData, isFalse);
    });

    test('hasEnoughData thresholds', () {
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 5, sleepSampleSize: 7, isSignificant: false,
        ).hasEnoughData,
        isTrue,
      );
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 4, sleepSampleSize: 7, isSignificant: false,
        ).hasEnoughData,
        isFalse,
      );
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 5, sleepSampleSize: 6, isSignificant: false,
        ).hasEnoughData,
        isFalse,
      );
    });

    test('formatVolumeChange', () {
      final corr = SleepWorkoutCorrelation.noData();
      expect(corr.formatVolumeChange(8.5), '+9%');
      expect(corr.formatVolumeChange(-15.2), '-15%');
      expect(corr.formatVolumeChange(0), '0%');
    });

    test('formattedGoodSleepChange and formattedPoorSleepChange', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10.3,
        volumeChangeBelow6h: -22.7,
        workoutSampleSize: 20,
        sleepSampleSize: 28,
        isSignificant: true,
      );
      expect(corr.formattedGoodSleepChange, '+10%');
      expect(corr.formattedPoorSleepChange, '-23%');
    });

    test('hasConsistentPattern', () {
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
          sleepPattern: SleepPattern.consistentlyGood,
        ).hasConsistentPattern,
        isTrue,
      );
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
          sleepPattern: SleepPattern.consistentlyPoor,
        ).hasConsistentPattern,
        isTrue,
      );
      expect(
        SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
          workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
          sleepPattern: SleepPattern.variable,
        ).hasConsistentPattern,
        isFalse,
      );
    });

    test('formattedAverageSleep and formattedAverageVolume', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
        workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
        averageSleepHours: 7.2, averageVolume: 5400.0,
      );
      expect(corr.formattedAverageSleep, '7.2h');
      expect(corr.formattedAverageVolume, '5400kg');
    });

    test('summaryMessageKey - not enough data', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 0, volumeChangeBelow6h: 0,
        workoutSampleSize: 3, sleepSampleSize: 5, isSignificant: false,
      );
      expect(corr.summaryMessageKey, 'not_enough_data');
    });

    test('summaryMessageKey - consistently good', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 8, volumeChangeBelow6h: 0,
        workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
        sleepPattern: SleepPattern.consistentlyGood,
        averageSleepHours: 7.5, averageVolume: 4000,
      );
      expect(corr.summaryMessageKey, contains('consistently_good'));
    });

    test('summaryMessageKey - consistently poor', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 0, volumeChangeBelow6h: -20,
        workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
        sleepPattern: SleepPattern.consistentlyPoor,
        averageSleepHours: 5.2, averageVolume: 3000,
      );
      expect(corr.summaryMessageKey, contains('consistently_poor'));
    });

    test('summaryMessageKey - not significant', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 3, volumeChangeBelow6h: -5,
        workoutSampleSize: 10, sleepSampleSize: 10, isSignificant: false,
        sleepPattern: SleepPattern.variable,
      );
      expect(corr.summaryMessageKey, 'not_significant');
    });

    test('summaryMessageKey - significant variable', () {
      final corr = SleepWorkoutCorrelation(
        volumeChangeAbove7h: 10, volumeChangeBelow6h: -20,
        workoutSampleSize: 15, sleepSampleSize: 20, isSignificant: true,
        sleepPattern: SleepPattern.variable,
      );
      expect(corr.summaryMessageKey, contains('significant'));
      expect(corr.summaryMessageKey, contains('increase'));
      expect(corr.summaryMessageKey, contains('decrease'));
    });
  });

  group('SleepWorkoutDataPoint JSON', () {
    test('round-trip preserves all fields', () {
      final point = SleepWorkoutDataPoint(
        workoutDate: DateTime(2025, 3, 1),
        sleepHours: 7.5,
        workoutVolume: 12000,
        workoutDurationMinutes: 65,
        exerciseCount: 6,
        averageRpe: 7.5,
      );
      final json = point.toJson();
      final restored = SleepWorkoutDataPoint.fromJson(json);

      expect(restored.workoutDate, point.workoutDate);
      expect(restored.sleepHours, point.sleepHours);
      expect(restored.workoutVolume, point.workoutVolume);
      expect(restored.workoutDurationMinutes, point.workoutDurationMinutes);
      expect(restored.exerciseCount, point.exerciseCount);
      expect(restored.averageRpe, point.averageRpe);
    });

    test('round-trip with null averageRpe', () {
      final point = SleepWorkoutDataPoint(
        workoutDate: DateTime(2025, 3, 1),
        sleepHours: 6.0,
        workoutVolume: 8000,
        workoutDurationMinutes: 45,
        exerciseCount: 4,
      );
      final restored = SleepWorkoutDataPoint.fromJson(point.toJson());
      expect(restored.averageRpe, isNull);
    });

    test('sleepCategory', () {
      expect(
        SleepWorkoutDataPoint(
          workoutDate: DateTime(2025, 1, 1), sleepHours: 5.5,
          workoutVolume: 0, workoutDurationMinutes: 0, exerciseCount: 0,
        ).sleepCategory,
        'poor',
      );
      expect(
        SleepWorkoutDataPoint(
          workoutDate: DateTime(2025, 1, 1), sleepHours: 6.5,
          workoutVolume: 0, workoutDurationMinutes: 0, exerciseCount: 0,
        ).sleepCategory,
        'moderate',
      );
      expect(
        SleepWorkoutDataPoint(
          workoutDate: DateTime(2025, 1, 1), sleepHours: 7.5,
          workoutVolume: 0, workoutDurationMinutes: 0, exerciseCount: 0,
        ).sleepCategory,
        'good',
      );
    });
  });

  group('RecoveryInsight JSON', () {
    test('round-trip preserves all fields', () {
      final insight = RecoveryInsight(
        score: 85,
        category: RecoveryCategory.optimal,
        recommendation: 'Great recovery!',
        lastNightSleep: const Duration(hours: 8, minutes: 15),
        weeklyAverageHours: 7.8,
        consecutiveBadNights: 0,
        streakDays: 5,
        calculatedAt: DateTime(2025, 3, 1, 8, 0),
        hasSleepData: true,
        baseScore: 90.0,
        sleepModifier: 1.05,
        consecutivePenalty: 1.0,
      );
      final json = insight.toJson();
      final restored = RecoveryInsight.fromJson(json);

      expect(restored.score, insight.score);
      expect(restored.category, insight.category);
      expect(restored.recommendation, insight.recommendation);
      expect(restored.lastNightSleep, insight.lastNightSleep);
      expect(restored.weeklyAverageHours, insight.weeklyAverageHours);
      expect(restored.consecutiveBadNights, insight.consecutiveBadNights);
      expect(restored.streakDays, insight.streakDays);
      expect(restored.calculatedAt, insight.calculatedAt);
      expect(restored.hasSleepData, insight.hasSleepData);
      expect(restored.baseScore, insight.baseScore);
      expect(restored.sleepModifier, insight.sleepModifier);
      expect(restored.consecutivePenalty, insight.consecutivePenalty);
    });

    test('round-trip with correlation', () {
      final insight = RecoveryInsight(
        score: 70,
        category: RecoveryCategory.good,
        recommendation: 'Normal workout recommended',
        lastNightSleep: const Duration(hours: 7),
        weeklyAverageHours: 7.0,
        consecutiveBadNights: 0,
        streakDays: 3,
        correlation: SleepWorkoutCorrelation(
          volumeChangeAbove7h: 5,
          volumeChangeBelow6h: -10,
          workoutSampleSize: 15,
          sleepSampleSize: 20,
          isSignificant: true,
        ),
      );
      final json = insight.toJson();
      final restored = RecoveryInsight.fromJson(json);
      expect(restored.correlation, isNotNull);
      expect(restored.correlation!.volumeChangeAbove7h, 5);
      expect(restored.correlation!.isSignificant, isTrue);
    });

    test('round-trip with null optional fields', () {
      final insight = RecoveryInsight(
        score: 50,
        category: RecoveryCategory.low,
        recommendation: 'Rest',
        lastNightSleep: const Duration(hours: 5),
        weeklyAverageHours: 5.5,
        consecutiveBadNights: 3,
        streakDays: 0,
      );
      final json = insight.toJson();
      final restored = RecoveryInsight.fromJson(json);
      expect(restored.correlation, isNull);
      expect(restored.calculatedAt, isNull);
    });

    test('all RecoveryCategory values round-trip', () {
      for (final cat in RecoveryCategory.values) {
        final insight = RecoveryInsight(
          score: 50,
          category: cat,
          recommendation: 'test',
          lastNightSleep: Duration.zero,
          weeklyAverageHours: 0,
          consecutiveBadNights: 0,
          streakDays: 0,
        );
        final restored = RecoveryInsight.fromJson(insight.toJson());
        expect(restored.category, cat);
      }
    });
  });

  group('RecoveryInsight computed properties', () {
    test('noData factory', () {
      final insight = RecoveryInsight.noData();
      expect(insight.score, 75);
      expect(insight.category, RecoveryCategory.good);
      expect(insight.hasSleepData, isFalse);
      expect(insight.lastNightSleep, Duration.zero);
    });

    test('formattedLastNight with data', () {
      expect(
        RecoveryInsight(
          score: 80, category: RecoveryCategory.good,
          recommendation: '', lastNightSleep: const Duration(hours: 7, minutes: 32),
          weeklyAverageHours: 7, consecutiveBadNights: 0, streakDays: 0,
        ).formattedLastNight,
        '7h 32m',
      );
    });

    test('formattedLastNight hours only', () {
      expect(
        RecoveryInsight(
          score: 80, category: RecoveryCategory.good,
          recommendation: '', lastNightSleep: const Duration(hours: 8),
          weeklyAverageHours: 7, consecutiveBadNights: 0, streakDays: 0,
        ).formattedLastNight,
        '8h',
      );
    });

    test('formattedLastNight minutes only', () {
      expect(
        RecoveryInsight(
          score: 30, category: RecoveryCategory.critical,
          recommendation: '', lastNightSleep: const Duration(minutes: 45),
          weeklyAverageHours: 5, consecutiveBadNights: 3, streakDays: 0,
        ).formattedLastNight,
        '45m',
      );
    });

    test('formattedLastNight with no data', () {
      expect(RecoveryInsight.noData().formattedLastNight, '--');
    });

    test('formattedWeeklyAverage', () {
      expect(
        RecoveryInsight(
          score: 80, category: RecoveryCategory.good,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 7.2, consecutiveBadNights: 0, streakDays: 0,
        ).formattedWeeklyAverage,
        '7.2h',
      );
    });

    test('formattedWeeklyAverage no data', () {
      expect(RecoveryInsight.noData().formattedWeeklyAverage, '--');
    });

    test('isInBadSleepState', () {
      expect(
        RecoveryInsight(
          score: 40, category: RecoveryCategory.low,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 5, consecutiveBadNights: 2, streakDays: 0,
        ).isInBadSleepState,
        isTrue,
      );
      expect(
        RecoveryInsight(
          score: 60, category: RecoveryCategory.moderate,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 6, consecutiveBadNights: 1, streakDays: 0,
        ).isInBadSleepState,
        isFalse,
      );
    });

    test('isReadyForTraining', () {
      expect(
        RecoveryInsight(
          score: 55, category: RecoveryCategory.moderate,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 0, consecutiveBadNights: 0, streakDays: 0,
        ).isReadyForTraining,
        isTrue,
      );
      expect(
        RecoveryInsight(
          score: 54, category: RecoveryCategory.low,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 0, consecutiveBadNights: 0, streakDays: 0,
        ).isReadyForTraining,
        isFalse,
      );
    });

    test('shouldRest', () {
      expect(
        RecoveryInsight(
          score: 39, category: RecoveryCategory.critical,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 0, consecutiveBadNights: 0, streakDays: 0,
        ).shouldRest,
        isTrue,
      );
      expect(
        RecoveryInsight(
          score: 40, category: RecoveryCategory.low,
          recommendation: '', lastNightSleep: Duration.zero,
          weeklyAverageHours: 0, consecutiveBadNights: 0, streakDays: 0,
        ).shouldRest,
        isFalse,
      );
    });
  });

  group('RecoveryCategoryExtension', () {
    test('fromScore boundaries', () {
      expect(RecoveryCategoryExtension.fromScore(100), RecoveryCategory.optimal);
      expect(RecoveryCategoryExtension.fromScore(85), RecoveryCategory.optimal);
      expect(RecoveryCategoryExtension.fromScore(84), RecoveryCategory.good);
      expect(RecoveryCategoryExtension.fromScore(70), RecoveryCategory.good);
      expect(RecoveryCategoryExtension.fromScore(69), RecoveryCategory.moderate);
      expect(RecoveryCategoryExtension.fromScore(55), RecoveryCategory.moderate);
      expect(RecoveryCategoryExtension.fromScore(54), RecoveryCategory.low);
      expect(RecoveryCategoryExtension.fromScore(40), RecoveryCategory.low);
      expect(RecoveryCategoryExtension.fromScore(39), RecoveryCategory.critical);
      expect(RecoveryCategoryExtension.fromScore(0), RecoveryCategory.critical);
    });

    test('colorName for all categories', () {
      expect(RecoveryCategory.optimal.colorName, 'primary');
      expect(RecoveryCategory.good.colorName, 'success');
      expect(RecoveryCategory.moderate.colorName, 'warning');
      expect(RecoveryCategory.low.colorName, 'error');
      expect(RecoveryCategory.critical.colorName, 'error');
    });

    test('emoji for all categories', () {
      expect(RecoveryCategory.optimal.emoji, isNotEmpty);
      expect(RecoveryCategory.good.emoji, isNotEmpty);
      expect(RecoveryCategory.moderate.emoji, isNotEmpty);
      expect(RecoveryCategory.low.emoji, isNotEmpty);
      expect(RecoveryCategory.critical.emoji, isNotEmpty);
    });

    test('filledDots for all categories', () {
      expect(RecoveryCategory.optimal.filledDots, 5);
      expect(RecoveryCategory.good.filledDots, 4);
      expect(RecoveryCategory.moderate.filledDots, 3);
      expect(RecoveryCategory.low.filledDots, 2);
      expect(RecoveryCategory.critical.filledDots, 1);
    });
  });
}
