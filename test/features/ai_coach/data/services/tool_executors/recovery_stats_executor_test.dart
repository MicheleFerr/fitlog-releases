/// Unit tests for RecoveryStatsExecutor
///
/// Tests all paths of the single public method:
/// - getRecoveryData
///
/// Mocking strategy:
/// - WorkoutHistoryRepositoryEnhanced: mocktail Mock (avoids HiveBoxManager init)
/// - IHealthRepository: hand-written fake (avoids platform plugin issues)
/// - HealthKitDatasource: hand-written fake (avoids HealthKit platform channel)
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mocktail/mocktail.dart';

import 'package:health/health.dart' show HealthDataPoint;
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/recovery_stats_executor.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart'
    as health;
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Mocktail mock — uses `implements` to avoid invoking the real constructor,
// which would attempt to open HiveBoxManagerEnhanced and Firebase.
// ---------------------------------------------------------------------------

class MockWorkoutHistoryRepo extends Mock
    implements WorkoutHistoryRepositoryEnhanced {}

// ---------------------------------------------------------------------------
// Fake IHealthRepository — avoids platform plugin issues while providing full
// configurability for each test case.
// ---------------------------------------------------------------------------

class _FakeHealthRepository implements IHealthRepository {
  /// Configurable per-call results keyed by HealthDataType.
  /// Each call pops the first entry for the given type (or returns empty list).
  final Map<HealthDataType, List<fp.Either<Failure, List<health.BodyMeasurement>>>>
      _callQueue = {};

  /// Convenience: queue a successful measurement list for the given type.
  void returnMeasurements(
    HealthDataType type,
    List<health.BodyMeasurement> measurements,
  ) {
    _callQueue.putIfAbsent(type, () => []).add(fp.Right(measurements));
  }

  /// Convenience: queue a failure for the given type.
  void returnFailure(HealthDataType type, Failure failure) {
    _callQueue.putIfAbsent(type, () => []).add(fp.Left(failure));
  }

  @override
  Future<fp.Either<Failure, List<health.BodyMeasurement>>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queue = _callQueue[dataType];
    if (queue != null && queue.isNotEmpty) {
      return queue.removeAt(0);
    }
    // Default: return empty success so score computation can proceed.
    return fp.Right([]);
  }

  // ---- Unneeded interface methods — all return trivial values. --------------

  @override
  Future<fp.Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async =>
      fp.Right(const HealthPermissionStatus(permissions: {}));

  @override
  Future<fp.Either<Failure, HealthPermissionStatus>>
  checkPermissionStatus() async =>
      fp.Right(const HealthPermissionStatus(permissions: {}));

  @override
  Future<fp.Either<Failure, void>> syncWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, void>> syncHeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, void>> writeBodyWeight(
    health.BodyMeasurement measurement,
  ) async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, bool>> writeWorkout({
    required DateTime startTime,
    required DateTime endTime,
    int? totalCalories,
    String? workoutName,
  }) async =>
      const fp.Right(true);

  @override
  Future<fp.Either<Failure, HealthSyncStatus>> getLastSyncStatus(
    HealthDataType dataType,
  ) async =>
      fp.Left(const CacheFailure('not implemented in fake'));

  @override
  Future<fp.Either<Failure, List<HealthSyncStatus>>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  }) async =>
      fp.Right([]);

  @override
  Future<fp.Either<Failure, void>> retryFailedSync(
    HealthDataType dataType,
  ) async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, void>> clearSyncCache() async =>
      const fp.Right(null);

  @override
  Future<fp.Either<Failure, void>> installHealthConnect() async =>
      const fp.Right(null);
}

// ---------------------------------------------------------------------------
// Fake HealthKitDatasource — returns configurable analytics maps without
// touching any platform channel or HealthKit native code.
// ---------------------------------------------------------------------------

class _FakeHealthKitDatasource implements HealthKitDatasource {
  Map<String, dynamic> sleepAnalyticsResult = {'available': false};
  Map<String, dynamic> hrvAnalyticsResult = {'available': false};

  @override
  Future<Map<String, dynamic>> getSleepAnalytics({int days = 7}) async =>
      sleepAnalyticsResult;

  @override
  Future<Map<String, dynamic>> getHrvAnalytics({int days = 7}) async =>
      hrvAnalyticsResult;

  // ---- Other public HealthKitDatasource members — not exercised here -------

  @override
  bool get isAvailable => false;

  @override
  Future<bool> initialize() async => false;

  @override
  Future<bool> hasPermission(dynamic type) async => false;

  @override
  Future<HealthDataPoint?> getStepsToday() async => null;

  @override
  Future<HealthDataPoint?> getStepsThisWeek() async => null;

  @override
  Future<HealthDataPoint?> getStepsThisMonth() async => null;

  @override
  Future<HealthDataPoint?> getHeartRateToday() async => null;

  @override
  Future<HealthDataPoint?> getRestingHeartRate() async => null;

  @override
  Future<HealthDataPoint?> getHrvToday() async => null;

  @override
  Future<List<HealthDataPoint>> getHrvThisWeek() async => [];

  @override
  Future<List<HealthDataPoint>> getWorkoutsToday() async => [];

  @override
  Future<List<HealthDataPoint>> getWorkoutsThisWeek() async => [];

  @override
  Future<List<HealthDataPoint>> getWorkoutsThisMonth() async => [];

  @override
  Future<HealthDataPoint?> getActiveEnergyToday() async => null;

  @override
  Future<HealthDataPoint?> getExerciseTimeToday() async => null;

  @override
  Future<HealthDataPoint?> getSleepLastNight() async => null;

  @override
  Future<HealthDataPoint?> getTimeInBedLastNight() async => null;

  @override
  Future<List<HealthDataPoint>> getSleepThisWeek() async => [];

  @override
  Future<List<HealthDataPoint>> getInBedThisWeek() async => [];

  @override
  Future<bool> deleteAllHealthData() async => true;

  @override
  Future<Map<String, dynamic>> exportHealthData() async => {};
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

WorkoutHistoryDetail _makeWorkout({
  int daysAgo = 1,
  String name = 'Push Day',
  int durationMinutes = 60,
}) {
  final completedAt = DateTime.now().subtract(Duration(days: daysAgo));
  return WorkoutHistoryDetail(
    id: 'workout-$daysAgo-${name.hashCode}',
    userId: 'user-test-1',
    name: name,
    description: '',
    createdAt: completedAt,
    startedAt: completedAt,
    completedAt: completedAt,
    updatedAt: completedAt,
    duration: Duration(minutes: durationMinutes),
    exercises: [
      ExerciseHistoryDetail(
        id: 'ex-1',
        name: 'Bench Press',
        category: 'chest',
        sets: [
          SetHistoryDetail(
            setNumber: 1,
            weight: 100,
            reps: 8,
            rpe: 8,
            notes: null,
            isWarmup: false,
          ),
        ],
        exerciseData: const {},
      ),
    ],
    metadata: const {},
  );
}

/// Creates a BodyMeasurement for sleep duration (stored in minutes by HealthKit).
health.BodyMeasurement _makeSleepMeasurement(double hours) {
  return health.BodyMeasurement(
    value: hours * 60, // HealthKit stores sleep in minutes
    unit: health.MeasurementUnit.minutes,
    recordedAt: DateTime.now(),
    dataType: HealthDataType.sleep,
  );
}

/// Creates a BodyMeasurement for heart rate (bpm).
health.BodyMeasurement _makeHeartRateMeasurement(double bpm) {
  return health.BodyMeasurement(
    value: bpm,
    unit: health.MeasurementUnit.bpm,
    recordedAt: DateTime.now(),
    dataType: HealthDataType.heartRate,
  );
}

// ---------------------------------------------------------------------------
// Builder helper
// ---------------------------------------------------------------------------

RecoveryStatsExecutor _buildExecutor({
  Either<Failure, List<WorkoutHistoryDetail>> Function()? historyFn,
  _FakeHealthRepository? healthRepo,
  _FakeHealthKitDatasource? healthKitDatasource,
}) {
  final mockHistoryRepo = MockWorkoutHistoryRepo();
  final Either<Failure, List<WorkoutHistoryDetail>> historyResult =
      historyFn != null
      ? historyFn()
      : Right<Failure, List<WorkoutHistoryDetail>>([]);

  when(() => mockHistoryRepo.getWorkouts())
      .thenAnswer((_) async => historyResult);

  return RecoveryStatsExecutor(
    historyRepo: mockHistoryRepo,
    healthRepo: healthRepo,
    healthKitDatasource: healthKitDatasource,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-test-1';

  // =========================================================================
  // Basic functionality
  // =========================================================================

  group('RecoveryStatsExecutor - basic functionality', () {
    test('returns valid JSON with all required fields on success (no health data)',
        () async {
      final workouts = [_makeWorkout(daysAgo: 2), _makeWorkout(daysAgo: 5)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('workoutsLast7Days'), isTrue);
      expect(json.containsKey('daysSinceLastWorkout'), isTrue);
      expect(json.containsKey('recoveryStatus'), isTrue);
      expect(json.containsKey('recoveryScore'), isTrue);
      expect(json.containsKey('confidence'), isTrue);
      expect(json.containsKey('healthSignals'), isTrue);
      expect(json.containsKey('recommendation'), isTrue);
    });

    test('returns error JSON when history fetch fails', () async {
      final executor = _buildExecutor(
        historyFn: () => Left(const NetworkFailure('No network')),
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('No network'));
      expect(json['toolName'], equals('getRecoveryData'));
    });

    test('returns error JSON on unexpected exception (catch block)', () async {
      // Arrange: make getWorkouts() throw instead of returning Either.
      final mockHistoryRepo = MockWorkoutHistoryRepo();
      when(() => mockHistoryRepo.getWorkouts())
          .thenThrow(Exception('Unexpected crash'));

      final executor = RecoveryStatsExecutor(historyRepo: mockHistoryRepo);

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Unexpected crash'));
      expect(json['toolName'], equals('getRecoveryData'));
    });
  });

  // =========================================================================
  // Recovery score calculation — workout frequency
  // =========================================================================

  group('RecoveryStatsExecutor - score: workout frequency', () {
    test('score decreases by 25 when 6+ workouts in 7 days', () async {
      // 6 workouts within the last 7 days.
      // Base score = 70, no daysSince adjustment (last was today → -6),
      // frequency adjustment = -25 → raw = 70 - 25 - 6 = 39 → clamped 39.
      // We test relative to the no-workout baseline to isolate frequency.
      final workouts = List.generate(
        6,
        (i) => _makeWorkout(daysAgo: i + 1, name: 'W$i'),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      // With 6 workouts, daysSinceLastWorkout == 1 (no ±adjustment).
      // score = 70 - 25 = 45 → status amber.
      expect(json['workoutsLast7Days'], equals(6));
      expect(json['recoveryScore'], equals(45));
    });

    test('score decreases by 10 when 4-5 workouts in 7 days', () async {
      // 4 workouts in last 7 days, last one was 2 days ago (no daysSince adj).
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 3, name: 'W2'),
        _makeWorkout(daysAgo: 4, name: 'W3'),
        _makeWorkout(daysAgo: 5, name: 'W4'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      // score = 70 - 10 = 60 (daysSince == 2, no adjustment).
      expect(json['workoutsLast7Days'], equals(4));
      expect(json['recoveryScore'], equals(60));
    });

    test('score increases by 6 when <= 2 workouts in 7 days', () async {
      // 2 workouts, last was 4 days ago → +6 (freq) +8 (daysSince) = 70+14=84.
      final workouts = [
        _makeWorkout(daysAgo: 4, name: 'W1'),
        _makeWorkout(daysAgo: 6, name: 'W2'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['workoutsLast7Days'], lessThanOrEqualTo(2));
      // score = 70 + 6 (freq<=2) + 8 (daysSince>=3) = 84
      expect(json['recoveryScore'], equals(84));
    });

    test('score increases by 8 when daysSinceLastWorkout >= 3', () async {
      // 3 workouts, last was exactly 3 days ago.
      final workouts = [
        _makeWorkout(daysAgo: 3, name: 'W1'),
        _makeWorkout(daysAgo: 10, name: 'W2'), // outside 7-day window
        _makeWorkout(daysAgo: 14, name: 'W3'), // outside 7-day window
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      // recentWorkouts.length == 1 (only W1 is within 7 days) → freq <= 2 → +6
      // daysSinceLastWorkout == 3 → +8
      // score = 70 + 6 + 8 = 84
      expect(json['daysSinceLastWorkout'], equals(3));
      expect(json['recoveryScore'], equals(84));
    });

    test('score decreases by 6 when daysSinceLastWorkout == 0', () async {
      // Last workout completed today (0 days ago), 3 workouts total in 7 days
      // → frequency band: count==3 → no freq adjustment (not >=6, not 4-5, not <=2)
      // daysSince == 0 → -6
      // score = 70 - 6 = 64
      final workouts = [
        _makeWorkout(daysAgo: 0, name: 'Today'),
        _makeWorkout(daysAgo: 2, name: 'W2'),
        _makeWorkout(daysAgo: 4, name: 'W3'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['daysSinceLastWorkout'], equals(0));
      expect(json['recoveryScore'], equals(64));
    });
  });

  // =========================================================================
  // Recovery status thresholds
  // =========================================================================

  group('RecoveryStatsExecutor - recovery status', () {
    test('status is "green" when score >= 75', () async {
      // 0 workouts in 7 days, last workout 10 days ago.
      // score = 70 + 6 (freq<=2) + 8 (daysSince>=3) = 84
      final workouts = [_makeWorkout(daysAgo: 10)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('green'));
      expect(json['recoveryScore'], greaterThanOrEqualTo(75));
    });

    test('status is "amber" when score is 45-74', () async {
      // 4 workouts in last 7 days (score -10), last 2 days ago (no adj).
      // score = 70 - 10 = 60 → amber
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 3, name: 'W2'),
        _makeWorkout(daysAgo: 4, name: 'W3'),
        _makeWorkout(daysAgo: 5, name: 'W4'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('amber'));
      expect(json['recoveryScore'], inInclusiveRange(45, 74));
    });

    test('status is "red" when score < 45', () async {
      // 6 workouts in 7 days → -25, workout today → -6
      // score = 70 - 25 - 6 = 39 → red
      final workouts = List.generate(
        6,
        (i) => _makeWorkout(daysAgo: i, name: 'W$i'),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('red'));
      expect(json['recoveryScore'], lessThan(45));
    });
  });

  // =========================================================================
  // Health data integration via IHealthRepository
  // =========================================================================

  group('RecoveryStatsExecutor - health data integration', () {
    test('sleep < 6h decreases score by 18', () async {
      // Neutral workout scenario: 3 workouts, last was 2 days ago.
      // score base = 70 (count==3, daysSince==2 → no adjustments).
      // sleep 5h → -18 → score = 52
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealth = _FakeHealthRepository();
      // Queue: sleep call returns 5h (300 min in bpm unit... actually minutes).
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(5.0)],
      );
      // No heart rate data.
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      // 70 (base) - 18 (sleep<6h) = 52
      expect(json['recoveryScore'], equals(52));
      final healthSignals = json['healthSignals'] as Map<String, dynamic>;
      expect(healthSignals.containsKey('avgSleepHours'), isTrue);
    });

    test('sleep 7-9h increases score by 8', () async {
      // Neutral base: 3 workouts, last 2 days ago → score = 70.
      // sleep 8h → +8 → score = 78
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealth = _FakeHealthRepository();
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(8.0)],
      );
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryScore'], equals(78));
    });

    test('heart rate delta >= 6 decreases score by 12', () async {
      // Neutral base: 3 workouts, last 2 days ago → score = 70.
      // HR this week: 80 bpm, baseline: 70 bpm → delta = 10 >= 6 → -12
      // score = 70 - 12 = 58
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealth = _FakeHealthRepository();
      // First call: sleep → empty (no sleep adj).
      fakeHealth.returnMeasurements(HealthDataType.sleep, []);
      // Second call: heart rate this week (80 bpm).
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(80)],
      );
      // Third call: heart rate baseline (70 bpm).
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(70)],
      );

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryScore'], equals(58));
      final healthSignals = json['healthSignals'] as Map<String, dynamic>;
      expect(healthSignals.containsKey('heartRateDelta'), isTrue);
    });

    test('HRV ratio < 0.85 decreases score by 15', () async {
      // Neutral base: 3 workouts, last 2 days ago → score = 70.
      // HRV ratio 0.80 < 0.85 → -15 → score = 55
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealthKit = _FakeHealthKitDatasource();
      fakeHealthKit.hrvAnalyticsResult = {
        'available': true,
        'ratio_to_baseline': 0.80,
      };

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthKitDatasource: fakeHealthKit,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryScore'], equals(55));
      final healthSignals = json['healthSignals'] as Map<String, dynamic>;
      expect(healthSignals.containsKey('hrvRatioToBaseline'), isTrue);
    });

    test('HRV ratio > 1.10 increases score by 8', () async {
      // Neutral base: 3 workouts, last 2 days ago → score = 70.
      // HRV ratio 1.20 > 1.10 → +8 → score = 78
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealthKit = _FakeHealthKitDatasource();
      fakeHealthKit.hrvAnalyticsResult = {
        'available': true,
        'ratio_to_baseline': 1.20,
      };

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthKitDatasource: fakeHealthKit,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryScore'], equals(78));
    });
  });

  // =========================================================================
  // HealthKit datasource fallback
  // =========================================================================

  group('RecoveryStatsExecutor - HealthKitDatasource fallback', () {
    test(
      'uses HealthKitDatasource for sleep when healthRepo has no sleep data',
      () async {
        // No healthRepo → datasource is the only sleep source.
        // 3 workouts, last 2 days ago → base = 70.
        // Datasource sleep: 7h → +8 → score = 78
        final workouts = [
          _makeWorkout(daysAgo: 2, name: 'W1'),
          _makeWorkout(daysAgo: 4, name: 'W2'),
          _makeWorkout(daysAgo: 6, name: 'W3'),
        ];
        final fakeHealthKit = _FakeHealthKitDatasource();
        fakeHealthKit.sleepAnalyticsResult = {
          'available': true,
          'avg_sleep_hours': 7.0,
        };

        final executor = _buildExecutor(
          historyFn: () => Right(workouts),
          healthKitDatasource: fakeHealthKit,
        );

        final result = await executor.getRecoveryData({}, userId);
        final json = jsonDecode(result) as Map<String, dynamic>;

        final healthSignals = json['healthSignals'] as Map<String, dynamic>;
        expect(healthSignals.containsKey('avgSleepHours'), isTrue);
        // sleep 7h → +8 → 70 + 8 = 78
        expect(json['recoveryScore'], equals(78));
      },
    );

    test('gets HRV from HealthKitDatasource', () async {
      // 3 workouts, last 2 days ago → base = 70.
      // HRV ratio 0.90 (between 0.85 and 1.10) → no adjustment → score = 70.
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 4, name: 'W2'),
        _makeWorkout(daysAgo: 6, name: 'W3'),
      ];
      final fakeHealthKit = _FakeHealthKitDatasource();
      fakeHealthKit.hrvAnalyticsResult = {
        'available': true,
        'ratio_to_baseline': 0.90,
      };

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthKitDatasource: fakeHealthKit,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      final healthSignals = json['healthSignals'] as Map<String, dynamic>;
      expect(healthSignals.containsKey('hrvRatioToBaseline'), isTrue);
      // ratio 0.90 → in normal range → no score change → 70
      expect(json['recoveryScore'], equals(70));
    });
  });

  // =========================================================================
  // Confidence levels
  // =========================================================================

  group('RecoveryStatsExecutor - confidence levels', () {
    test('confidence is "high" with 3+ health signals', () async {
      // Provide sleep, this-week HR, and baseline HR so all 3 non-null signals fire.
      // confidenceSignals counts: avgSleepHours, currentHeartRate, baselineHeartRate
      // (3 signals → high).
      final workouts = [_makeWorkout(daysAgo: 2)];
      final fakeHealth = _FakeHealthRepository();
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(7.5)],
      );
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(65)],
      );
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(63)],
      );

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['confidence'], equals('high'));
    });

    test('confidence is "medium" with 1-2 signals', () async {
      // Provide only sleep (1 signal → medium).
      final workouts = [_makeWorkout(daysAgo: 2)];
      final fakeHealth = _FakeHealthRepository();
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(7.0)],
      );
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['confidence'], equals('medium'));
    });

    test('confidence is "low" with 0 signals (no health data)', () async {
      // No healthRepo, no datasource → 0 signals.
      final workouts = [_makeWorkout(daysAgo: 2)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['confidence'], equals('low'));
    });
  });

  // =========================================================================
  // Recommendations
  // =========================================================================

  group('RecoveryStatsExecutor - recommendations', () {
    test('red status returns rest day recommendation', () async {
      // 6 workouts in 7 days + today → score < 45 → red.
      final workouts = List.generate(
        6,
        (i) => _makeWorkout(daysAgo: i, name: 'W$i'),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('red'));
      expect(
        json['recommendation'].toString(),
        contains('recupero attivo'),
      );
    });

    test('amber status with poor sleep returns sleep recommendation', () async {
      // 4 workouts in 7 days → score = 70 - 10 = 60 → amber.
      // Plus poor sleep (<7h) → sleep recommendation path.
      final workouts = [
        _makeWorkout(daysAgo: 2, name: 'W1'),
        _makeWorkout(daysAgo: 3, name: 'W2'),
        _makeWorkout(daysAgo: 4, name: 'W3'),
        _makeWorkout(daysAgo: 5, name: 'W4'),
      ];
      final fakeHealth = _FakeHealthRepository();
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(6.0)], // 6h < 7h → poor sleep branch
      );
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);
      fakeHealth.returnMeasurements(HealthDataType.heartRate, []);

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('amber'));
      expect(
        json['recommendation'].toString(),
        contains('sonno'),
      );
    });

    test('green status with 4+ days since workout returns intensity recommendation',
        () async {
      // 1 workout 5 days ago → score = 70 + 6 (freq<=2) + 8 (daysSince>=3) = 84 → green.
      // daysSinceLastWorkout >= 4 → "Buona freschezza" path.
      final workouts = [_makeWorkout(daysAgo: 5)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryStatus'], equals('green'));
      expect(json['daysSinceLastWorkout'], greaterThanOrEqualTo(4));
      expect(
        json['recommendation'].toString(),
        contains('freschezza'),
      );
    });
  });

  // =========================================================================
  // Edge cases
  // =========================================================================

  group('RecoveryStatsExecutor - edge cases', () {
    test('empty workout list returns valid JSON', () async {
      final executor = _buildExecutor(historyFn: () => Right([]));

      final result = await executor.getRecoveryData({}, userId);

      expect(() => jsonDecode(result), returnsNormally);
      final json = jsonDecode(result) as Map<String, dynamic>;
      expect(json['workoutsLast7Days'], equals(0));
      // daysSinceLastWorkout stays -1 when workouts list is empty.
      expect(json['daysSinceLastWorkout'], equals(-1));
    });

    test('score is clamped between 0 and 100', () async {
      // Push score below 0: 6 workouts today (−25 freq, −6 daysSince),
      // plus poor sleep 4h (−18) and high HR delta (−12) and low HRV (−15).
      // Raw = 70 − 25 − 6 − 18 − 12 − 15 = −6 → clamped to 0.
      final workouts = List.generate(
        6,
        (i) => _makeWorkout(daysAgo: i, name: 'W$i'),
      );
      final fakeHealth = _FakeHealthRepository();
      fakeHealth.returnMeasurements(
        HealthDataType.sleep,
        [_makeSleepMeasurement(4.0)], // −18
      );
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(90)], // current 90
      );
      fakeHealth.returnMeasurements(
        HealthDataType.heartRate,
        [_makeHeartRateMeasurement(80)], // baseline 80 → delta 10 ≥ 6 → −12
      );

      final fakeHealthKit = _FakeHealthKitDatasource();
      // HRV will only be fetched if avgSleepHours is null from healthRepo.
      // Since healthRepo already provided sleep, datasource won't be called
      // for sleep but we pass HRV anyway (it will be skipped).
      fakeHealthKit.hrvAnalyticsResult = {'available': false};

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthRepo: fakeHealth,
        healthKitDatasource: fakeHealthKit,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      // score must never be negative.
      expect(json['recoveryScore'], greaterThanOrEqualTo(0));
      // score must never exceed 100.
      expect(json['recoveryScore'], lessThanOrEqualTo(100));
    });

    test('score is clamped at 100 when all signals are optimal', () async {
      // 0 recent workouts (but one 20 days ago), daysSince = 20 → +6 (freq) +8 (daysSince).
      // sleep 8h → +8, HRV ratio 1.5 > 1.10 → +8.
      // Raw = 70 + 6 + 8 + 8 + 8 = 100 → clamped at 100.
      final workouts = [_makeWorkout(daysAgo: 20)];
      final fakeHealthKit = _FakeHealthKitDatasource();
      fakeHealthKit.sleepAnalyticsResult = {
        'available': true,
        'avg_sleep_hours': 8.0,
      };
      fakeHealthKit.hrvAnalyticsResult = {
        'available': true,
        'ratio_to_baseline': 1.5,
      };

      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
        healthKitDatasource: fakeHealthKit,
      );

      final result = await executor.getRecoveryData({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['recoveryScore'], lessThanOrEqualTo(100));
    });
  });
}
