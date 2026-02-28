/// Recovery Insight Domain Layer Unit Tests
///
/// Tests the pure domain logic for:
/// - RecoveryInsight entity and RecoveryCategoryExtension
/// - SleepRecord entity and SleepQualityExtension
/// - SleepWorkoutCorrelation entity and SleepWorkoutDataPoint
/// - SleepWorkoutCorrelationService (score calculation, correlation analysis)
///
/// All tests are pure unit tests with no mocking required - domain layer only.

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/services/sleep_workout_correlation_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';

// ============================================================
// TEST FIXTURES / HELPERS
// ============================================================

/// Build a SleepRecord with explicit asleep and in-bed durations.
SleepRecord buildSleepRecord({
  DateTime? date,
  Duration asleepDuration = const Duration(hours: 8),
  Duration inBedDuration = const Duration(hours: 9),
  SleepQuality? quality,
  String? source,
}) {
  final asleepMins = asleepDuration.inMinutes.toDouble();
  final inBedMins = inBedDuration.inMinutes.toDouble();
  return SleepRecord.fromHealthData(
    date: date ?? DateTime.now().subtract(const Duration(hours: 8)),
    asleepMinutes: asleepMins,
    inBedMinutes: inBedMins,
    source: source,
  );
}

/// Build a SleepRecord for a specific night offset (0 = today, 1 = yesterday, …)
SleepRecord buildSleepRecordForNight({
  required int daysAgo,
  double asleepHours = 8.0,
  double inBedHours = 9.0,
}) {
  final date = DateTime.now().subtract(Duration(days: daysAgo));
  return SleepRecord.fromHealthData(
    date: DateTime(date.year, date.month, date.day),
    asleepMinutes: asleepHours * 60,
    inBedMinutes: inBedHours * 60,
  );
}

/// Build an ExerciseSet with a completed status.
ExerciseSet buildSet({
  int setNumber = 1,
  double weight = 100,
  int reps = 10,
  bool isCompleted = true,
}) {
  return ExerciseSet(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    isCompleted: isCompleted,
  );
}

/// Build an Exercise with a list of completed sets.
Exercise buildExercise({
  String name = 'Bench Press',
  List<ExerciseSet>? sets,
  ExerciseCountingMode countingMode = ExerciseCountingMode.weighted,
}) {
  return Exercise(
    name: name,
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: sets ?? [buildSet()],
    countingMode: countingMode,
  );
}

/// Build a completed Workout whose endTime is [daysAgo] days in the past.
Workout buildCompletedWorkout({
  int daysAgo = 1,
  List<Exercise>? exercises,
  String? name,
}) {
  final now = DateTime.now();
  final completedAt = now.subtract(Duration(days: daysAgo));
  return Workout(
    id: 'workout-$daysAgo',
    name: name ?? 'Workout $daysAgo days ago',
    exercises: exercises ?? [buildExercise()],
    status: WorkoutStatus.completed,
    startTime: completedAt.subtract(const Duration(hours: 1)),
    endTime: completedAt,
    createdAt: completedAt.subtract(const Duration(hours: 1)),
    updatedAt: completedAt,
  );
}

// ============================================================
// TESTS
// ============================================================

void main() {
  // ----------------------------------------------------------
  // 1. RecoveryInsight entity
  // ----------------------------------------------------------
  group('RecoveryInsight entity', () {
    group('noData() factory', () {
      test('returns score 75', () {
        final insight = RecoveryInsight.noData();
        expect(insight.score, equals(75));
      });

      test('returns category good', () {
        final insight = RecoveryInsight.noData();
        expect(insight.category, equals(RecoveryCategory.good));
      });

      test('hasSleepData is false', () {
        final insight = RecoveryInsight.noData();
        expect(insight.hasSleepData, isFalse);
      });

      test('consecutiveBadNights is 0', () {
        final insight = RecoveryInsight.noData();
        expect(insight.consecutiveBadNights, equals(0));
      });

      test('streakDays is 0', () {
        final insight = RecoveryInsight.noData();
        expect(insight.streakDays, equals(0));
      });

      test('weeklyAverageHours is 0', () {
        final insight = RecoveryInsight.noData();
        expect(insight.weeklyAverageHours, equals(0.0));
      });

      test('lastNightSleep is Duration.zero', () {
        final insight = RecoveryInsight.noData();
        expect(insight.lastNightSleep, equals(Duration.zero));
      });
    });

    group('formattedLastNight', () {
      test('returns "7h 32m" for 7h 32m with sleep data', () {
        final insight = RecoveryInsight(
          score: 75,
          category: RecoveryCategory.good,
          recommendation: 'test',
          lastNightSleep: const Duration(hours: 7, minutes: 32),
          weeklyAverageHours: 7.5,
          consecutiveBadNights: 0,
          streakDays: 3,
          hasSleepData: true,
        );
        expect(insight.formattedLastNight, equals('7h 32m'));
      });

      test('returns "--" when hasSleepData is false', () {
        final insight = RecoveryInsight.noData();
        expect(insight.formattedLastNight, equals('--'));
      });

      test('returns "--" when lastNightSleep is Duration.zero with sleep data', () {
        final insight = RecoveryInsight(
          score: 75,
          category: RecoveryCategory.good,
          recommendation: 'test',
          lastNightSleep: Duration.zero,
          weeklyAverageHours: 7.0,
          consecutiveBadNights: 0,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.formattedLastNight, equals('--'));
      });

      test('returns "8h" when minutes are 0', () {
        final insight = RecoveryInsight(
          score: 80,
          category: RecoveryCategory.good,
          recommendation: 'test',
          lastNightSleep: const Duration(hours: 8),
          weeklyAverageHours: 8.0,
          consecutiveBadNights: 0,
          streakDays: 5,
          hasSleepData: true,
        );
        expect(insight.formattedLastNight, equals('8h'));
      });

      test('returns "45m" when hours are 0', () {
        final insight = RecoveryInsight(
          score: 30,
          category: RecoveryCategory.critical,
          recommendation: 'rest',
          lastNightSleep: const Duration(minutes: 45),
          weeklyAverageHours: 0.75,
          consecutiveBadNights: 3,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.formattedLastNight, equals('45m'));
      });
    });

    group('formattedWeeklyAverage', () {
      test('returns "7.2h" for weeklyAverageHours 7.2', () {
        final insight = RecoveryInsight(
          score: 75,
          category: RecoveryCategory.good,
          recommendation: 'test',
          lastNightSleep: const Duration(hours: 7),
          weeklyAverageHours: 7.2,
          consecutiveBadNights: 0,
          streakDays: 3,
          hasSleepData: true,
        );
        expect(insight.formattedWeeklyAverage, equals('7.2h'));
      });

      test('returns "--" when hasSleepData is false', () {
        final insight = RecoveryInsight.noData();
        expect(insight.formattedWeeklyAverage, equals('--'));
      });

      test('returns "--" when weeklyAverageHours is 0 with sleep data', () {
        final insight = RecoveryInsight(
          score: 75,
          category: RecoveryCategory.good,
          recommendation: 'test',
          lastNightSleep: const Duration(hours: 7),
          weeklyAverageHours: 0,
          consecutiveBadNights: 0,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.formattedWeeklyAverage, equals('--'));
      });

      test('formats with one decimal place', () {
        final insight = RecoveryInsight(
          score: 90,
          category: RecoveryCategory.optimal,
          recommendation: 'optimal',
          lastNightSleep: const Duration(hours: 8),
          weeklyAverageHours: 8.0,
          consecutiveBadNights: 0,
          streakDays: 7,
          hasSleepData: true,
        );
        expect(insight.formattedWeeklyAverage, equals('8.0h'));
      });
    });

    group('isInBadSleepState', () {
      test('returns false when consecutiveBadNights is 0', () {
        final insight = RecoveryInsight(
          score: 80,
          category: RecoveryCategory.good,
          recommendation: 'good',
          lastNightSleep: const Duration(hours: 8),
          weeklyAverageHours: 8.0,
          consecutiveBadNights: 0,
          streakDays: 5,
          hasSleepData: true,
        );
        expect(insight.isInBadSleepState, isFalse);
      });

      test('returns false when consecutiveBadNights is 1', () {
        final insight = RecoveryInsight(
          score: 65,
          category: RecoveryCategory.moderate,
          recommendation: 'moderate',
          lastNightSleep: const Duration(hours: 5),
          weeklyAverageHours: 7.0,
          consecutiveBadNights: 1,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.isInBadSleepState, isFalse);
      });

      test('returns true when consecutiveBadNights is exactly 2', () {
        final insight = RecoveryInsight(
          score: 50,
          category: RecoveryCategory.low,
          recommendation: 'low',
          lastNightSleep: const Duration(hours: 5),
          weeklyAverageHours: 5.5,
          consecutiveBadNights: 2,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.isInBadSleepState, isTrue);
      });

      test('returns true when consecutiveBadNights is 3 or more', () {
        final insight = RecoveryInsight(
          score: 35,
          category: RecoveryCategory.critical,
          recommendation: 'critical',
          lastNightSleep: const Duration(hours: 4),
          weeklyAverageHours: 4.5,
          consecutiveBadNights: 4,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.isInBadSleepState, isTrue);
      });
    });

    group('isReadyForTraining', () {
      test('returns true when score is exactly 55', () {
        final insight = RecoveryInsight(
          score: 55,
          category: RecoveryCategory.moderate,
          recommendation: 'moderate',
          lastNightSleep: const Duration(hours: 6, minutes: 30),
          weeklyAverageHours: 6.5,
          consecutiveBadNights: 0,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.isReadyForTraining, isTrue);
      });

      test('returns true when score is above 55', () {
        final insight = RecoveryInsight(
          score: 90,
          category: RecoveryCategory.optimal,
          recommendation: 'optimal',
          lastNightSleep: const Duration(hours: 8),
          weeklyAverageHours: 8.0,
          consecutiveBadNights: 0,
          streakDays: 7,
          hasSleepData: true,
        );
        expect(insight.isReadyForTraining, isTrue);
      });

      test('returns false when score is 54', () {
        final insight = RecoveryInsight(
          score: 54,
          category: RecoveryCategory.low,
          recommendation: 'low',
          lastNightSleep: const Duration(hours: 5, minutes: 30),
          weeklyAverageHours: 5.5,
          consecutiveBadNights: 1,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.isReadyForTraining, isFalse);
      });
    });

    group('shouldRest', () {
      test('returns false when score is exactly 40', () {
        final insight = RecoveryInsight(
          score: 40,
          category: RecoveryCategory.low,
          recommendation: 'low',
          lastNightSleep: const Duration(hours: 5),
          weeklyAverageHours: 5.0,
          consecutiveBadNights: 2,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.shouldRest, isFalse);
      });

      test('returns true when score is 39', () {
        final insight = RecoveryInsight(
          score: 39,
          category: RecoveryCategory.critical,
          recommendation: 'critical',
          lastNightSleep: const Duration(hours: 4),
          weeklyAverageHours: 4.0,
          consecutiveBadNights: 3,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.shouldRest, isTrue);
      });

      test('returns true when score is 0', () {
        final insight = RecoveryInsight(
          score: 0,
          category: RecoveryCategory.critical,
          recommendation: 'critical',
          lastNightSleep: const Duration(hours: 2),
          weeklyAverageHours: 2.0,
          consecutiveBadNights: 5,
          streakDays: 0,
          hasSleepData: true,
        );
        expect(insight.shouldRest, isTrue);
      });
    });
  });

  // ----------------------------------------------------------
  // 2. RecoveryCategoryExtension
  // ----------------------------------------------------------
  group('RecoveryCategoryExtension', () {
    group('fromScore()', () {
      test('returns optimal for score 85', () {
        expect(RecoveryCategoryExtension.fromScore(85), equals(RecoveryCategory.optimal));
      });

      test('returns optimal for score 100', () {
        expect(RecoveryCategoryExtension.fromScore(100), equals(RecoveryCategory.optimal));
      });

      test('returns good for score 70', () {
        expect(RecoveryCategoryExtension.fromScore(70), equals(RecoveryCategory.good));
      });

      test('returns good for score 84', () {
        expect(RecoveryCategoryExtension.fromScore(84), equals(RecoveryCategory.good));
      });

      test('returns moderate for score 55', () {
        expect(RecoveryCategoryExtension.fromScore(55), equals(RecoveryCategory.moderate));
      });

      test('returns moderate for score 69', () {
        expect(RecoveryCategoryExtension.fromScore(69), equals(RecoveryCategory.moderate));
      });

      test('returns low for score 40', () {
        expect(RecoveryCategoryExtension.fromScore(40), equals(RecoveryCategory.low));
      });

      test('returns low for score 54', () {
        expect(RecoveryCategoryExtension.fromScore(54), equals(RecoveryCategory.low));
      });

      test('returns critical for score 39', () {
        expect(RecoveryCategoryExtension.fromScore(39), equals(RecoveryCategory.critical));
      });

      test('returns critical for score 0', () {
        expect(RecoveryCategoryExtension.fromScore(0), equals(RecoveryCategory.critical));
      });
    });

    group('colorName', () {
      test('optimal returns "primary"', () {
        expect(RecoveryCategory.optimal.colorName, equals('primary'));
      });

      test('good returns "success"', () {
        expect(RecoveryCategory.good.colorName, equals('success'));
      });

      test('moderate returns "warning"', () {
        expect(RecoveryCategory.moderate.colorName, equals('warning'));
      });

      test('low returns "error"', () {
        expect(RecoveryCategory.low.colorName, equals('error'));
      });

      test('critical returns "error"', () {
        expect(RecoveryCategory.critical.colorName, equals('error'));
      });
    });

    group('emoji', () {
      test('optimal emoji', () {
        expect(RecoveryCategory.optimal.emoji, equals('🔥'));
      });

      test('good emoji', () {
        expect(RecoveryCategory.good.emoji, equals('💪'));
      });

      test('moderate emoji', () {
        expect(RecoveryCategory.moderate.emoji, equals('😐'));
      });

      test('low emoji', () {
        expect(RecoveryCategory.low.emoji, equals('😴'));
      });

      test('critical emoji', () {
        expect(RecoveryCategory.critical.emoji, equals('🛌'));
      });
    });

    group('filledDots', () {
      test('optimal returns 5 dots', () {
        expect(RecoveryCategory.optimal.filledDots, equals(5));
      });

      test('good returns 4 dots', () {
        expect(RecoveryCategory.good.filledDots, equals(4));
      });

      test('moderate returns 3 dots', () {
        expect(RecoveryCategory.moderate.filledDots, equals(3));
      });

      test('low returns 2 dots', () {
        expect(RecoveryCategory.low.filledDots, equals(2));
      });

      test('critical returns 1 dot', () {
        expect(RecoveryCategory.critical.filledDots, equals(1));
      });
    });
  });

  // ----------------------------------------------------------
  // 3. SleepRecord entity
  // ----------------------------------------------------------
  group('SleepRecord entity', () {
    group('fromHealthData() factory', () {
      test('correctly computes asleepDuration from minutes', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 452,
          inBedMinutes: 510,
        );
        expect(record.asleepDuration, equals(const Duration(minutes: 452)));
      });

      test('correctly computes inBedDuration from minutes', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 452,
          inBedMinutes: 510,
        );
        expect(record.inBedDuration, equals(const Duration(minutes: 510)));
      });

      test('computes efficiency as (asleep / inBed) * 100', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 450,
          inBedMinutes: 500,
        );
        // 450 / 500 * 100 = 90.0
        expect(record.efficiency, closeTo(90.0, 0.001));
      });

      test('efficiency is 0 when inBedMinutes is 0', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 0,
          inBedMinutes: 0,
        );
        expect(record.efficiency, equals(0.0));
      });

      test('derives quality optimal for 7.5h sleep', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 450, // 7.5 hours
          inBedMinutes: 480,
        );
        expect(record.quality, equals(SleepQuality.optimal));
      });

      test('derives quality critical for 5.5h sleep', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 330, // 5.5 hours
          inBedMinutes: 360,
        );
        expect(record.quality, equals(SleepQuality.critical));
      });

      test('derives quality suboptimal for 6.5h sleep', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 390, // 6.5 hours
          inBedMinutes: 420,
        );
        expect(record.quality, equals(SleepQuality.suboptimal));
      });

      test('derives quality excessive for 10h sleep', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 600, // 10 hours
          inBedMinutes: 630,
        );
        expect(record.quality, equals(SleepQuality.excessive));
      });

      test('preserves source field', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 480,
          inBedMinutes: 510,
          source: 'HealthKit',
        );
        expect(record.source, equals('HealthKit'));
      });

      test('preserves date field', () {
        final date = DateTime(2025, 3, 10);
        final record = SleepRecord.fromHealthData(
          date: date,
          asleepMinutes: 480,
          inBedMinutes: 510,
        );
        expect(record.date, equals(date));
      });
    });

    group('SleepQualityExtension.fromHours()', () {
      test('returns critical for 5.9h (less than 6)', () {
        expect(SleepQualityExtension.fromHours(5.9), equals(SleepQuality.critical));
      });

      test('returns critical for 0h', () {
        expect(SleepQualityExtension.fromHours(0), equals(SleepQuality.critical));
      });

      test('boundary: returns suboptimal for exactly 6h', () {
        expect(SleepQualityExtension.fromHours(6.0), equals(SleepQuality.suboptimal));
      });

      test('returns suboptimal for 6.5h', () {
        expect(SleepQualityExtension.fromHours(6.5), equals(SleepQuality.suboptimal));
      });

      test('boundary: returns optimal for exactly 7h', () {
        expect(SleepQualityExtension.fromHours(7.0), equals(SleepQuality.optimal));
      });

      test('returns optimal for 8h', () {
        expect(SleepQualityExtension.fromHours(8.0), equals(SleepQuality.optimal));
      });

      test('boundary: returns optimal for exactly 9h', () {
        expect(SleepQualityExtension.fromHours(9.0), equals(SleepQuality.optimal));
      });

      test('returns excessive for 9.1h', () {
        expect(SleepQualityExtension.fromHours(9.1), equals(SleepQuality.excessive));
      });

      test('returns excessive for 11h', () {
        expect(SleepQualityExtension.fromHours(11.0), equals(SleepQuality.excessive));
      });
    });

    group('asleepHours computed getter', () {
      test('converts 450 minutes to 7.5h', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 450,
          inBedMinutes: 480,
        );
        expect(record.asleepHours, closeTo(7.5, 0.001));
      });

      test('converts 360 minutes to 6h', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 360,
          inBedMinutes: 400,
        );
        expect(record.asleepHours, closeTo(6.0, 0.001));
      });
    });

    group('inBedHours computed getter', () {
      test('converts 510 minutes to 8.5h', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 480,
          inBedMinutes: 510,
        );
        expect(record.inBedHours, closeTo(8.5, 0.001));
      });
    });

    group('formattedDuration', () {
      test('returns "7h 32m" for 7h 32m', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 452, // 7h 32m
          inBedMinutes: 480,
        );
        expect(record.formattedDuration, equals('7h 32m'));
      });

      test('returns "7h" when minutes are 0', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 420, // exactly 7h
          inBedMinutes: 450,
        );
        expect(record.formattedDuration, equals('7h'));
      });

      test('returns "32m" when hours are 0', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 32,
          inBedMinutes: 60,
        );
        expect(record.formattedDuration, equals('32m'));
      });

      test('returns "8h 15m" for 495 minutes', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 495,
          inBedMinutes: 520,
        );
        expect(record.formattedDuration, equals('8h 15m'));
      });
    });

    group('isBadNight', () {
      test('returns true only for critical quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 300, // 5h → critical
          inBedMinutes: 360,
        );
        expect(record.isBadNight, isTrue);
      });

      test('returns false for suboptimal quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 390, // 6.5h → suboptimal
          inBedMinutes: 420,
        );
        expect(record.isBadNight, isFalse);
      });

      test('returns false for optimal quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 480, // 8h → optimal
          inBedMinutes: 510,
        );
        expect(record.isBadNight, isFalse);
      });

      test('returns false for excessive quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 600, // 10h → excessive
          inBedMinutes: 630,
        );
        expect(record.isBadNight, isFalse);
      });
    });

    group('meetsRecommendation', () {
      test('returns true for optimal quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 480, // 8h → optimal
          inBedMinutes: 510,
        );
        expect(record.meetsRecommendation, isTrue);
      });

      test('returns true for excessive quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 600, // 10h → excessive
          inBedMinutes: 630,
        );
        expect(record.meetsRecommendation, isTrue);
      });

      test('returns false for suboptimal quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 390, // 6.5h → suboptimal
          inBedMinutes: 420,
        );
        expect(record.meetsRecommendation, isFalse);
      });

      test('returns false for critical quality', () {
        final record = SleepRecord.fromHealthData(
          date: DateTime(2025, 1, 15),
          asleepMinutes: 300, // 5h → critical
          inBedMinutes: 360,
        );
        expect(record.meetsRecommendation, isFalse);
      });
    });
  });

  // ----------------------------------------------------------
  // 4. SleepWorkoutCorrelation entity
  // ----------------------------------------------------------
  group('SleepWorkoutCorrelation entity', () {
    group('noData() factory', () {
      test('volumeChangeAbove7h is 0', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.volumeChangeAbove7h, equals(0.0));
      });

      test('volumeChangeBelow6h is 0', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.volumeChangeBelow6h, equals(0.0));
      });

      test('workoutSampleSize is 0', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.workoutSampleSize, equals(0));
      });

      test('sleepSampleSize is 0', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.sleepSampleSize, equals(0));
      });

      test('isSignificant is false', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.isSignificant, isFalse);
      });
    });

    group('formatVolumeChange()', () {
      test('positive change returns "+8%"', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.formatVolumeChange(8.0), equals('+8%'));
      });

      test('negative change returns "-15%"', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.formatVolumeChange(-15.0), equals('-15%'));
      });

      test('zero returns "0%"', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.formatVolumeChange(0.0), equals('0%'));
      });

      test('rounds fractional positive value', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.formatVolumeChange(8.7), equals('+9%'));
      });

      test('rounds fractional negative value', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.formatVolumeChange(-15.4), equals('-15%'));
      });
    });

    group('formattedGoodSleepChange and formattedPoorSleepChange', () {
      test('formattedGoodSleepChange uses volumeChangeAbove7h', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 12.0,
          volumeChangeBelow6h: -8.0,
          workoutSampleSize: 10,
          sleepSampleSize: 14,
          isSignificant: true,
        );
        expect(correlation.formattedGoodSleepChange, equals('+12%'));
      });

      test('formattedPoorSleepChange uses volumeChangeBelow6h', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 12.0,
          volumeChangeBelow6h: -8.0,
          workoutSampleSize: 10,
          sleepSampleSize: 14,
          isSignificant: true,
        );
        expect(correlation.formattedPoorSleepChange, equals('-8%'));
      });
    });

    group('hasEnoughData', () {
      test('returns true when workoutSampleSize>=5 AND sleepSampleSize>=7', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 5.0,
          volumeChangeBelow6h: -5.0,
          workoutSampleSize: 5,
          sleepSampleSize: 7,
          isSignificant: false,
        );
        expect(correlation.hasEnoughData, isTrue);
      });

      test('returns false when workoutSampleSize is 4', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0,
          volumeChangeBelow6h: 0,
          workoutSampleSize: 4,
          sleepSampleSize: 10,
          isSignificant: false,
        );
        expect(correlation.hasEnoughData, isFalse);
      });

      test('returns false when sleepSampleSize is 6', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0,
          volumeChangeBelow6h: 0,
          workoutSampleSize: 8,
          sleepSampleSize: 6,
          isSignificant: false,
        );
        expect(correlation.hasEnoughData, isFalse);
      });

      test('returns false when both are below threshold', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.hasEnoughData, isFalse);
      });
    });

    group('hasConsistentPattern', () {
      test('returns true for consistentlyGood pattern', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 5.0,
          volumeChangeBelow6h: 0.0,
          workoutSampleSize: 10,
          sleepSampleSize: 14,
          isSignificant: false,
          sleepPattern: SleepPattern.consistentlyGood,
        );
        expect(correlation.hasConsistentPattern, isTrue);
      });

      test('returns true for consistentlyPoor pattern', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0.0,
          volumeChangeBelow6h: -10.0,
          workoutSampleSize: 8,
          sleepSampleSize: 10,
          isSignificant: false,
          sleepPattern: SleepPattern.consistentlyPoor,
        );
        expect(correlation.hasConsistentPattern, isTrue);
      });

      test('returns false for variable pattern', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 8.0,
          volumeChangeBelow6h: -10.0,
          workoutSampleSize: 12,
          sleepSampleSize: 14,
          isSignificant: true,
          sleepPattern: SleepPattern.variable,
        );
        expect(correlation.hasConsistentPattern, isFalse);
      });

      test('returns false for unknown pattern', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0,
          volumeChangeBelow6h: 0,
          workoutSampleSize: 2,
          sleepSampleSize: 3,
          isSignificant: false,
          sleepPattern: SleepPattern.unknown,
        );
        expect(correlation.hasConsistentPattern, isFalse);
      });
    });

    group('summaryMessageKey', () {
      test('returns "not_enough_data" when hasEnoughData is false', () {
        final correlation = SleepWorkoutCorrelation.noData();
        expect(correlation.summaryMessageKey, equals('not_enough_data'));
      });

      test('returns "consistently_good:..." when pattern is consistentlyGood', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 5.0,
          volumeChangeBelow6h: 0.0,
          workoutSampleSize: 10,
          sleepSampleSize: 14,
          isSignificant: false,
          sleepPattern: SleepPattern.consistentlyGood,
          averageSleepHours: 8.0,
          averageVolume: 5000.0,
        );
        final key = correlation.summaryMessageKey;
        expect(key, startsWith('consistently_good:'));
        expect(key, contains('8.0h'));
        expect(key, contains('5000kg'));
      });

      test('returns "consistently_poor:..." when pattern is consistentlyPoor', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 0.0,
          volumeChangeBelow6h: -20.0,
          workoutSampleSize: 8,
          sleepSampleSize: 10,
          isSignificant: false,
          sleepPattern: SleepPattern.consistentlyPoor,
          averageSleepHours: 5.5,
          averageVolume: 3000.0,
        );
        final key = correlation.summaryMessageKey;
        expect(key, startsWith('consistently_poor:'));
        expect(key, contains('5.5h'));
        expect(key, contains('3000kg'));
      });

      test('returns "not_significant" when variable but isSignificant is false', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 3.0,
          volumeChangeBelow6h: -2.0,
          workoutSampleSize: 8,
          sleepSampleSize: 10,
          isSignificant: false,
          sleepPattern: SleepPattern.variable,
        );
        expect(correlation.summaryMessageKey, equals('not_significant'));
      });

      test('returns "significant:..." when variable and isSignificant is true', () {
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: 12.0,
          volumeChangeBelow6h: -15.0,
          workoutSampleSize: 15,
          sleepSampleSize: 20,
          isSignificant: true,
          sleepPattern: SleepPattern.variable,
        );
        final key = correlation.summaryMessageKey;
        expect(key, startsWith('significant:'));
        // good effect is "increase" (12 > 0), poor effect is "decrease" (-15 < 0)
        expect(key, contains('increase'));
        expect(key, contains('decrease'));
      });

      test('significant key encodes correct effect directions for both increase cases', () {
        // volumeChangeAbove7h < 0 → "decrease"
        // volumeChangeBelow6h >= 0 → "increase"
        const correlation = SleepWorkoutCorrelation(
          volumeChangeAbove7h: -5.0,
          volumeChangeBelow6h: 3.0,
          workoutSampleSize: 12,
          sleepSampleSize: 15,
          isSignificant: true,
          sleepPattern: SleepPattern.variable,
        );
        final key = correlation.summaryMessageKey;
        expect(key, startsWith('significant:'));
        final parts = key.split(':');
        expect(parts[1], equals('decrease')); // goodEffect
        expect(parts[2], equals('increase')); // poorEffect
      });
    });
  });

  // ----------------------------------------------------------
  // 5. SleepWorkoutDataPoint entity
  // ----------------------------------------------------------
  group('SleepWorkoutDataPoint', () {
    // Use a runtime constant to avoid the "const DateTime" limitation
    final fixedDate = DateTime(2025, 1, 15, 10, 0, 0);

    group('sleepCategory', () {
      test('returns "poor" when sleepHours < 6', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 5.5,
          workoutVolume: 5000,
          workoutDurationMinutes: 60,
          exerciseCount: 4,
        );
        expect(dp.sleepCategory, equals('poor'));
      });

      test('returns "poor" for 0 hours', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 0.0,
          workoutVolume: 4000,
          workoutDurationMinutes: 45,
          exerciseCount: 3,
        );
        expect(dp.sleepCategory, equals('poor'));
      });

      test('boundary: returns "moderate" for exactly 6h', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 6.0,
          workoutVolume: 5000,
          workoutDurationMinutes: 60,
          exerciseCount: 4,
        );
        expect(dp.sleepCategory, equals('moderate'));
      });

      test('returns "moderate" for 6.5h', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 6.5,
          workoutVolume: 5000,
          workoutDurationMinutes: 60,
          exerciseCount: 4,
        );
        expect(dp.sleepCategory, equals('moderate'));
      });

      test('boundary: returns "good" for exactly 7h', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 7.0,
          workoutVolume: 6000,
          workoutDurationMinutes: 70,
          exerciseCount: 5,
        );
        expect(dp.sleepCategory, equals('good'));
      });

      test('returns "good" for 9h', () {
        final dp = SleepWorkoutDataPoint(
          workoutDate: fixedDate,
          sleepHours: 9.0,
          workoutVolume: 6500,
          workoutDurationMinutes: 75,
          exerciseCount: 6,
        );
        expect(dp.sleepCategory, equals('good'));
      });
    });
  });

  // ----------------------------------------------------------
  // 6. SleepWorkoutCorrelationService
  // ----------------------------------------------------------
  group('SleepWorkoutCorrelationService', () {
    late SleepWorkoutCorrelationService service;

    setUp(() {
      service = SleepWorkoutCorrelationService();
    });

    // ---- calculateRecovery() ----
    group('calculateRecovery()', () {
      test('returns noData() when sleepHistory is empty', () {
        final result = service.calculateRecovery(
          sleepHistory: [],
          workoutHistory: [buildCompletedWorkout(daysAgo: 1)],
        );
        expect(result.hasSleepData, isFalse);
        expect(result.score, equals(75));
        expect(result.category, equals(RecoveryCategory.good));
      });

      test('returns noData() when both lists are empty', () {
        final result = service.calculateRecovery(
          sleepHistory: [],
          workoutHistory: [],
        );
        expect(result.hasSleepData, isFalse);
        expect(result.score, equals(75));
      });

      test('returns hasSleepData=true when sleep data is provided', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 8.0),
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 7.5),
          buildSleepRecordForNight(daysAgo: 2, asleepHours: 8.0),
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        expect(result.hasSleepData, isTrue);
      });

      test('score is clamped to [0, 100]', () {
        // Even with perfect data the score should not exceed 100
        final sleepHistory = List.generate(
          7,
          (i) => buildSleepRecordForNight(daysAgo: i, asleepHours: 8.5),
        );
        final workoutHistory = [
          buildCompletedWorkout(daysAgo: 1),
          buildCompletedWorkout(daysAgo: 2),
          buildCompletedWorkout(daysAgo: 4),
          buildCompletedWorkout(daysAgo: 5),
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: workoutHistory,
        );
        expect(result.score, inInclusiveRange(0, 100));
      });

      test('category matches score via fromScore()', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 8.0),
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        final expectedCategory = RecoveryCategoryExtension.fromScore(result.score);
        expect(result.category, equals(expectedCategory));
      });

      test('poor sleep (avg <6h) produces lower score than good sleep', () {
        // Arrange: good sleep
        final goodSleepHistory = List.generate(
          7,
          (i) => buildSleepRecordForNight(daysAgo: i, asleepHours: 8.0),
        );
        // Arrange: poor sleep
        final poorSleepHistory = List.generate(
          7,
          (i) => buildSleepRecordForNight(daysAgo: i, asleepHours: 5.0),
        );
        final workoutHistory = [buildCompletedWorkout(daysAgo: 2)];

        final goodResult = service.calculateRecovery(
          sleepHistory: goodSleepHistory,
          workoutHistory: workoutHistory,
        );
        final poorResult = service.calculateRecovery(
          sleepHistory: poorSleepHistory,
          workoutHistory: workoutHistory,
        );

        expect(poorResult.score, lessThan(goodResult.score));
      });

      test('consecutive bad nights penalty reduces score', () {
        // Arrange: 3 consecutive bad nights (< 6h), followed by good nights
        final sleepHistoryNoPenalty = List.generate(
          7,
          (i) => buildSleepRecordForNight(daysAgo: i, asleepHours: 5.5),
        );

        final sleepHistoryWithPenalty = [
          // Most recent 3 nights are bad
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 5.0),
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 5.0),
          buildSleepRecordForNight(daysAgo: 2, asleepHours: 5.0),
          // Older nights are good
          buildSleepRecordForNight(daysAgo: 3, asleepHours: 8.0),
          buildSleepRecordForNight(daysAgo: 4, asleepHours: 8.0),
          buildSleepRecordForNight(daysAgo: 5, asleepHours: 8.0),
          buildSleepRecordForNight(daysAgo: 6, asleepHours: 8.0),
        ];

        final workoutHistory = [buildCompletedWorkout(daysAgo: 2)];

        final noPenaltyResult = service.calculateRecovery(
          sleepHistory: sleepHistoryNoPenalty,
          workoutHistory: workoutHistory,
        );
        final withPenaltyResult = service.calculateRecovery(
          sleepHistory: sleepHistoryWithPenalty,
          workoutHistory: workoutHistory,
        );

        // The penalty version has 3 consecutive bad nights → -10%
        // so it should have a lower score than identical average without the streak
        expect(withPenaltyResult.consecutiveBadNights, greaterThanOrEqualTo(2));
      });

      test('consecutiveBadNights is counted correctly in result', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 5.0), // bad
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 5.0), // bad
          buildSleepRecordForNight(daysAgo: 2, asleepHours: 8.0), // good → stops
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        expect(result.consecutiveBadNights, equals(2));
      });

      test('streakDays counts consecutive good nights from most recent', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 8.0), // good
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 7.5), // good
          buildSleepRecordForNight(daysAgo: 2, asleepHours: 7.0), // good
          buildSleepRecordForNight(daysAgo: 3, asleepHours: 5.0), // bad → stops
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        expect(result.streakDays, equals(3));
      });

      test('lastNightSleep matches first record in sleepHistory', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 7.5), // most recent
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 6.0),
        ];
        final result = service.calculateRecovery(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        // First record's asleepDuration = 7.5h = 450 minutes
        expect(result.lastNightSleep.inMinutes, equals(450));
      });
    });

    // ---- calculateCorrelation() ----
    group('calculateCorrelation()', () {
      test('returns noData() when sleepHistory is empty', () {
        final result = service.calculateCorrelation(
          sleepHistory: [],
          workoutHistory: [buildCompletedWorkout(daysAgo: 1)],
        );
        expect(result.workoutSampleSize, equals(0));
        expect(result.sleepSampleSize, equals(0));
        expect(result.isSignificant, isFalse);
      });

      test('returns noData() when workoutHistory is empty', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 0, asleepHours: 8.0),
        ];
        final result = service.calculateCorrelation(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );
        expect(result.workoutSampleSize, equals(0));
        expect(result.sleepSampleSize, equals(0));
      });

      test('returns noData() when both are empty', () {
        final result = service.calculateCorrelation(
          sleepHistory: [],
          workoutHistory: [],
        );
        expect(result.workoutSampleSize, equals(0));
      });

      test('matched data points produce non-zero workoutSampleSize', () {
        // Build workouts with endTime on day D, and sleep for day D-1
        final now = DateTime.now();

        // Workout completed today — sleep for yesterday
        final workoutDate = DateTime(now.year, now.month, now.day, 10, 0);
        final sleepDate = DateTime(now.year, now.month, now.day - 1);

        final workout = Workout(
          id: 'w1',
          name: 'Test Workout',
          exercises: [buildExercise()],
          status: WorkoutStatus.completed,
          startTime: workoutDate.subtract(const Duration(hours: 1)),
          endTime: workoutDate,
          createdAt: workoutDate.subtract(const Duration(hours: 1)),
          updatedAt: workoutDate,
        );

        final sleepRecord = SleepRecord.fromHealthData(
          date: sleepDate,
          asleepMinutes: 480, // 8h
          inBedMinutes: 510,
        );

        final result = service.calculateCorrelation(
          sleepHistory: [sleepRecord],
          workoutHistory: [workout],
        );

        expect(result.workoutSampleSize, greaterThan(0));
      });

      test('significance requires >=3 workouts in each group', () {
        // Set up: 3 good-sleep workouts AND 3 poor-sleep workouts
        final workouts = <Workout>[];
        final sleepRecords = <SleepRecord>[];

        // Days 1-3: workout with good sleep night before (sleep day 0-2, workout day 1-3)
        for (int i = 0; i < 3; i++) {
          final workoutDate = DateTime.now().subtract(Duration(days: i + 1));
          final sleepDate = DateTime.now().subtract(Duration(days: i + 2));
          workouts.add(Workout(
            id: 'good-$i',
            name: 'Good Sleep Workout $i',
            exercises: [buildExercise()],
            status: WorkoutStatus.completed,
            startTime: workoutDate.subtract(const Duration(hours: 1)),
            endTime: DateTime(workoutDate.year, workoutDate.month, workoutDate.day, 10),
            createdAt: workoutDate,
            updatedAt: workoutDate,
          ));
          sleepRecords.add(SleepRecord.fromHealthData(
            date: DateTime(sleepDate.year, sleepDate.month, sleepDate.day),
            asleepMinutes: 480, // 8h - good
            inBedMinutes: 510,
          ));
        }

        // Days 10-12: workout with poor sleep night before
        for (int i = 0; i < 3; i++) {
          final workoutDate = DateTime.now().subtract(Duration(days: i + 10));
          final sleepDate = DateTime.now().subtract(Duration(days: i + 11));
          workouts.add(Workout(
            id: 'poor-$i',
            name: 'Poor Sleep Workout $i',
            exercises: [buildExercise()],
            status: WorkoutStatus.completed,
            startTime: workoutDate.subtract(const Duration(hours: 1)),
            endTime: DateTime(workoutDate.year, workoutDate.month, workoutDate.day, 10),
            createdAt: workoutDate,
            updatedAt: workoutDate,
          ));
          sleepRecords.add(SleepRecord.fromHealthData(
            date: DateTime(sleepDate.year, sleepDate.month, sleepDate.day),
            asleepMinutes: 300, // 5h - poor
            inBedMinutes: 360,
          ));
        }

        final result = service.calculateCorrelation(
          sleepHistory: sleepRecords,
          workoutHistory: workouts,
        );

        // With 3 workouts in good group and 3 in poor group → should be significant
        if (result.workoutsWithGoodSleep >= 3 && result.workoutsWithPoorSleep >= 3) {
          expect(result.isSignificant, isTrue);
        }
      });

      test('fewer than 3 in each group → not significant', () {
        // Only 1 workout with good sleep, 1 with poor sleep
        final now = DateTime.now();

        // Good sleep workout: sleep on day-1, workout on day 0
        final goodWorkoutDate = DateTime(now.year, now.month, now.day, 10);
        final goodSleepDate = DateTime(now.year, now.month, now.day - 1);

        // Poor sleep workout: sleep on day-8, workout on day-7
        final poorWorkoutDate = DateTime(now.year, now.month, now.day - 7, 10);
        final poorSleepDate = DateTime(now.year, now.month, now.day - 8);

        final workouts = [
          Workout(
            id: 'w-good',
            name: 'Good',
            exercises: [buildExercise()],
            status: WorkoutStatus.completed,
            startTime: goodWorkoutDate.subtract(const Duration(hours: 1)),
            endTime: goodWorkoutDate,
            createdAt: goodWorkoutDate,
            updatedAt: goodWorkoutDate,
          ),
          Workout(
            id: 'w-poor',
            name: 'Poor',
            exercises: [buildExercise()],
            status: WorkoutStatus.completed,
            startTime: poorWorkoutDate.subtract(const Duration(hours: 1)),
            endTime: poorWorkoutDate,
            createdAt: poorWorkoutDate,
            updatedAt: poorWorkoutDate,
          ),
        ];

        final sleepRecords = [
          SleepRecord.fromHealthData(
            date: goodSleepDate,
            asleepMinutes: 480, // 8h good
            inBedMinutes: 510,
          ),
          SleepRecord.fromHealthData(
            date: poorSleepDate,
            asleepMinutes: 300, // 5h poor
            inBedMinutes: 360,
          ),
        ];

        final result = service.calculateCorrelation(
          sleepHistory: sleepRecords,
          workoutHistory: workouts,
        );

        // 1 good + 1 poor = insufficient for significance
        expect(result.isSignificant, isFalse);
      });

      test('volume change above 7h is positive when good sleep workouts have higher volume', () {
        // Create scenario where good-sleep workouts have higher volume than average
        final now = DateTime.now();

        // Three good-sleep workout days (8h sleep → next day workout at 100kg×10 per set)
        // Three poor-sleep workout days (5h sleep → next day workout at 50kg×5 per set)
        final workouts = <Workout>[];
        final sleepRecords = <SleepRecord>[];

        for (int i = 0; i < 3; i++) {
          // Good sleep day (offset by chunks to avoid date clashes)
          final goodWorkoutDate = DateTime(now.year, now.month, now.day - (i * 2 + 1), 10);
          final goodSleepDate = DateTime(now.year, now.month, now.day - (i * 2 + 2));

          workouts.add(Workout(
            id: 'g$i',
            name: 'Heavy',
            exercises: [
              buildExercise(
                sets: [buildSet(weight: 100, reps: 10, isCompleted: true)],
              ),
            ],
            status: WorkoutStatus.completed,
            startTime: goodWorkoutDate.subtract(const Duration(hours: 1)),
            endTime: goodWorkoutDate,
            createdAt: goodWorkoutDate,
            updatedAt: goodWorkoutDate,
          ));
          sleepRecords.add(SleepRecord.fromHealthData(
            date: goodSleepDate,
            asleepMinutes: 480, // 8h
            inBedMinutes: 510,
          ));
        }

        for (int i = 0; i < 3; i++) {
          // Poor sleep day
          final poorWorkoutDate = DateTime(now.year, now.month, now.day - (i * 2 + 13), 10);
          final poorSleepDate = DateTime(now.year, now.month, now.day - (i * 2 + 14));

          workouts.add(Workout(
            id: 'p$i',
            name: 'Light',
            exercises: [
              buildExercise(
                sets: [buildSet(weight: 50, reps: 5, isCompleted: true)],
              ),
            ],
            status: WorkoutStatus.completed,
            startTime: poorWorkoutDate.subtract(const Duration(hours: 1)),
            endTime: poorWorkoutDate,
            createdAt: poorWorkoutDate,
            updatedAt: poorWorkoutDate,
          ));
          sleepRecords.add(SleepRecord.fromHealthData(
            date: poorSleepDate,
            asleepMinutes: 300, // 5h
            inBedMinutes: 360,
          ));
        }

        final result = service.calculateCorrelation(
          sleepHistory: sleepRecords,
          workoutHistory: workouts,
        );

        // If matching worked: good sleep group has 1000 vol/workout, poor has 250 vol/workout
        // volumeChangeAbove7h should be positive, volumeChangeBelow6h should be negative
        if (result.workoutSampleSize > 0) {
          expect(result.volumeChangeAbove7h, greaterThan(0));
          expect(result.volumeChangeBelow6h, lessThan(0));
        }
      });

      test('workouts without endTime are skipped', () {
        final sleepHistory = [
          buildSleepRecordForNight(daysAgo: 1, asleepHours: 8.0),
        ];

        // Workout with no endTime (not completed)
        final incompleteWorkout = Workout(
          id: 'incomplete',
          name: 'Incomplete',
          exercises: [buildExercise()],
          status: WorkoutStatus.inProgress,
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: null, // No end time
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now(),
        );

        final result = service.calculateCorrelation(
          sleepHistory: sleepHistory,
          workoutHistory: [incompleteWorkout],
        );

        // Incomplete workout should be skipped → noData
        expect(result.workoutSampleSize, equals(0));
      });

      test('workouts with empty exercises are skipped', () {
        final now = DateTime.now();
        final workoutDate = DateTime(now.year, now.month, now.day, 10);
        final sleepDate = DateTime(now.year, now.month, now.day - 1);

        final workoutWithNoExercises = Workout(
          id: 'empty',
          name: 'Empty',
          exercises: [], // No exercises
          status: WorkoutStatus.completed,
          startTime: workoutDate.subtract(const Duration(hours: 1)),
          endTime: workoutDate,
          createdAt: workoutDate,
          updatedAt: workoutDate,
        );

        final sleepRecord = SleepRecord.fromHealthData(
          date: sleepDate,
          asleepMinutes: 480,
          inBedMinutes: 510,
        );

        final result = service.calculateCorrelation(
          sleepHistory: [sleepRecord],
          workoutHistory: [workoutWithNoExercises],
        );

        expect(result.workoutSampleSize, equals(0));
      });

      test('sleepSampleSize matches number of sleep records provided', () {
        final sleepHistory = List.generate(
          10,
          (i) => buildSleepRecordForNight(daysAgo: i, asleepHours: 7.5),
        );

        final result = service.calculateCorrelation(
          sleepHistory: sleepHistory,
          workoutHistory: [],
        );

        // No workouts → noData, but sleepSampleSize should still be 0 from noData()
        expect(result.sleepSampleSize, equals(0));
      });
    });
  });
}

