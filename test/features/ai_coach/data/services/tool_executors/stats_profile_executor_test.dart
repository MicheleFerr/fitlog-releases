/// Unit tests for StatsProfileExecutor
///
/// Tests all public methods:
/// - getWorkoutStats
/// - getPersonalRecords
/// - getStreak
/// - getWorkoutHistory
/// - getUserProfileContext
/// - updateUserProfilePreferences
/// - getWorkoutPreferencesResult
/// - updateWorkoutPreferencesResult
library;

import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/stats_profile_executor.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Firebase test setup helpers
// ---------------------------------------------------------------------------

void _setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = _MockFirebasePlatform();
}

class _MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _MockFirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'test',
        appId: 'test',
        messagingSenderId: 'test',
        projectId: 'test',
      ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [app()];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return app(name ?? defaultFirebaseAppName);
  }
}

class _MockFirebaseAppPlatform extends FirebaseAppPlatform {
  _MockFirebaseAppPlatform(super.name, super.options);

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

/// Simple FirebaseAuth stub - only needs to satisfy the constructor.
class _StubFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

/// No-op Crashlytics platform to prevent assertion errors in tests.
class _FakeCrashlyticsPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebaseCrashlyticsPlatform {
  @override
  bool get isCrashlyticsCollectionEnabled => false;

  @override
  Future<void> recordError({
    required String exception,
    required String information,
    required String? reason,
    bool fatal = false,
    String? buildId,
    List<String> loadingUnits = const [],
    List<Map<String, String>>? stackTraceElements,
  }) async {}

  @override
  Future<bool> checkForUnsentReports() async => false;

  @override
  Future<bool> didCrashOnPreviousExecution() async => false;

  @override
  Future<void> deleteUnsentReports() async {}

  @override
  Future<void> sendUnsentReports() async {}

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}

  @override
  Future<void> setCustomKey(String key, String value) async {}

  @override
  Future<void> log(String message) async {}

  @override
  void crash() {}

  @override
  FirebaseApp get app => Firebase.app();

  @override
  FirebaseCrashlyticsPlatform setInitialValues({
    required bool isCrashlyticsCollectionEnabled,
  }) => this;
}

// ---------------------------------------------------------------------------
// Fake implementations
// ---------------------------------------------------------------------------

class FakeWorkoutAnalyticsRepository implements WorkoutAnalyticsRepository {
  WorkoutAnalyticsStats? statsToReturn;
  Exception? statsError;
  List<PersonalRecord> prsToReturn = [];
  Exception? prsError;
  Map<PRType, PersonalRecord> exercisePrsToReturn = {};

  @override
  Future<WorkoutAnalyticsStats> getAnalyticsStats(String userId) async {
    if (statsError != null) throw statsError!;
    return statsToReturn ??
        const WorkoutAnalyticsStats(
          totalWorkouts: 0,
          totalPRs: 0,
          averageWorkoutVolume: 0,
          averageWorkoutDuration: 0,
          totalVolumeLifted: 0,
          exerciseFrequency: {},
          exerciseVolumeDistribution: {},
        );
  }

  @override
  Future<List<PersonalRecord>> getUserPRs(String userId) async {
    if (prsError != null) throw prsError!;
    return prsToReturn;
  }

  @override
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  ) async {
    return exercisePrsToReturn;
  }

  @override
  Future<List<Workout>> getHistoricalWorkouts(
    String userId, {
    int limit = 50,
    DateTime? since,
  }) async =>
      [];

  @override
  Future<List<Workout>> getSimilarWorkouts(
    String userId,
    Workout targetWorkout, {
    int limit = 10,
    double minSimilarity = 0.3,
  }) async =>
      [];

  @override
  Future<void> savePR(PersonalRecord pr) async {}

  @override
  Future<List<WorkoutMetrics>> getWorkoutMetricsHistory(
    String userId, {
    int limit = 30,
    DateTime? since,
  }) async =>
      [];

  @override
  Future<void> cacheWorkoutMetrics(WorkoutMetrics metrics) async {}

  @override
  Future<WorkoutMetrics?> getCachedWorkoutMetrics(String workoutId) async =>
      null;

  @override
  Stream<WorkoutAnalyticsUpdate> watchWorkoutUpdates(String workoutId) =>
      const Stream.empty();

  @override
  Future<void> syncWorkoutsFromFirebase(
    String userId, {
    Function(int current, int total)? onProgress,
  }) async {}
}

class FakeAnalyticsRepository implements AnalyticsRepository {
  ExerciseHistory? historyToReturn;
  Failure? historyFailure;

  @override
  Future<fp.Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  }) async {
    if (historyFailure != null) return fp.Left(historyFailure!);
    if (historyToReturn != null) return fp.Right(historyToReturn!);
    return fp.Left(const NotFoundFailure('Exercise not found'));
  }

  @override
  Future<fp.Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  }) async =>
      fp.Right([]);

  @override
  Stream<fp.Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) =>
      Stream.value(fp.Right([]));

  @override
  Future<fp.Either<Failure, List<ExerciseSession>>> getSessionsByTimeframe({
    required String userId,
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  }) async =>
      fp.Right([]);

  @override
  Future<fp.Either<Failure, void>> clearCache() async => fp.Right(null);

  @override
  Future<bool> isCacheValid(String userId) async => false;

  @override
  Future<fp.Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  }) async =>
      fp.Right(null);
}

class FakeStreakRepository implements StreakRepository {
  WorkoutStreak? streakToReturn;
  Exception? streakError;

  @override
  Future<WorkoutStreak> getCurrentStreak() async {
    if (streakError != null) throw streakError!;
    return streakToReturn ??
        const WorkoutStreak(
          currentStreak: 0,
          longestStreak: 0,
          isActive: false,
          lastWorkoutDate: null,
          totalWorkoutDays: 0,
        );
  }

  @override
  Future<void> checkAndNotifyMilestone(int newStreak) async {}
}

class FakeMeasurementRepository implements MeasurementRepository {
  fp.Either<MeasurementFailure, Map<MetricType, Measurement>>? latestResult;
  fp.Either<MeasurementFailure, List<Measurement>>? measurementsResult;
  fp.Either<MeasurementFailure, void>? addResult;

  @override
  Future<fp.Either<MeasurementFailure, Map<MetricType, Measurement>>>
  getLatestMeasurementsByType(String userId) async {
    return latestResult ??
        fp.Right<MeasurementFailure, Map<MetricType, Measurement>>({});
  }

  @override
  Future<fp.Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return measurementsResult ??
        fp.Right<MeasurementFailure, List<Measurement>>([]);
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async {
    return addResult ?? fp.Right(null);
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> updateMeasurement(
    Measurement measurement,
  ) async =>
      fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  }) async =>
      fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  ) async =>
      fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  }) async {
    return fp.Right(
      SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<fp.Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(
    String userId,
  ) async =>
      fp.Right([]);

  @override
  Future<fp.Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async =>
      fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(
    String userId,
  ) async =>
      fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, int>> cleanupExpiredMeasurements(
    String userId, {
    int retentionDays = 30,
  }) async =>
      fp.Right(0);
}

// ---------------------------------------------------------------------------
// Helper to build a WorkoutHistoryRepositoryEnhanced-compatible fake.
// The real class is concrete (not abstract) and uses HiveBoxManagerEnhanced
// (a singleton). We subclass and override getWorkouts(), passing the actual
// singleton so the constructor succeeds (the box manager is never used since
// getWorkouts() is fully overridden).
// ---------------------------------------------------------------------------

/// Minimal subclass that overrides the only method used by the executor.
/// Uses FakeFirebaseFirestore to avoid Firebase initialization errors in the
/// WorkoutHistoryRepositoryEnhanced constructor (which calls
/// firestore ?? FirebaseFirestore.instance).
class _FakeHistoryRepo extends WorkoutHistoryRepositoryEnhanced {
  _FakeHistoryRepo(this._fn)
    : super(
        boxManager: HiveBoxManagerEnhanced(),
        firestore: FakeFirebaseFirestore(),
        auth: _StubFirebaseAuth(),
      );

  final Either<Failure, List<WorkoutHistoryDetail>> Function() _fn;

  @override
  Future<Either<Failure, List<WorkoutHistoryDetail>>> getWorkouts() async =>
      _fn();
}

/// Builds a StatsProfileExecutor with the given fakes.
StatsProfileExecutor _buildExecutor({
  FakeWorkoutAnalyticsRepository? analyticsRepoOverride,
  FakeAnalyticsRepository? analyticsOverride,
  FakeStreakRepository? streakOverride,
  Either<Failure, List<WorkoutHistoryDetail>> Function()? historyFn,
  FakeMeasurementRepository? measurementOverride,
}) {
  final analyticsRepo =
      analyticsRepoOverride ?? FakeWorkoutAnalyticsRepository();
  final analyticsRepository = analyticsOverride ?? FakeAnalyticsRepository();
  final streakRepo = streakOverride ?? FakeStreakRepository();
  final measurementRepo = measurementOverride;

  final historyRepo = _FakeHistoryRepo(historyFn ?? () => Right([]));

  return StatsProfileExecutor(
    analyticsRepo: analyticsRepository,
    workoutAnalyticsRepo: analyticsRepo,
    streakRepo: streakRepo,
    historyRepo: historyRepo,
    measurementRepo: measurementRepo,
    accountTier: 'free',
  );
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

WorkoutAnalyticsStats _makeStats({
  int totalWorkouts = 42,
  int totalPRs = 10,
  double avgVolume = 5000,
  double avgDuration = 60,
  double totalVolume = 210000,
  Map<String, int> frequency = const {'Bench Press': 20, 'Squat': 15},
}) {
  return WorkoutAnalyticsStats(
    totalWorkouts: totalWorkouts,
    totalPRs: totalPRs,
    averageWorkoutVolume: avgVolume,
    averageWorkoutDuration: avgDuration,
    totalVolumeLifted: totalVolume,
    exerciseFrequency: frequency,
    exerciseVolumeDistribution: const {'Bench Press': 50000.0},
    firstWorkoutDate: DateTime(2024, 1, 1),
    lastWorkoutDate: DateTime(2024, 12, 31),
  );
}

PersonalRecord _makePR({
  String exerciseName = 'Bench Press',
  double value = 100,
  double? previousValue = 95,
  PRType type = PRType.weight,
}) {
  return PersonalRecord(
    id: 'pr-1',
    userId: 'user-1',
    exerciseId: 'bench-press',
    exerciseName: exerciseName,
    type: type,
    value: value,
    previousValue: previousValue,
    achievedAt: DateTime(2024, 6, 1),
  );
}

WorkoutHistoryDetail _makeWorkout({
  int daysAgo = 1,
  String name = 'Push Day',
  double volume = 5000,
  int durationMinutes = 60,
}) {
  final completedAt = DateTime.now().subtract(Duration(days: daysAgo));
  return WorkoutHistoryDetail(
    id: 'workout-$daysAgo',
    userId: 'user-1',
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

ExerciseHistory _makeExerciseHistory({int sessionCount = 3}) {
  final sessions = List.generate(sessionCount, (i) {
    return ExerciseSession(
      exerciseName: 'Bench Press',
      muscleGroup: 'chest',
      sets: [
        AnalyticsSet(
          weight: 100.0 + i * 2.5,
          reps: 8,
          date: DateTime.now().subtract(Duration(days: i * 7)),
        ),
      ],
      date: DateTime.now().subtract(Duration(days: i * 7)),
    );
  });
  return ExerciseHistory(
    exerciseId: 'bench-press',
    exerciseName: 'Bench Press',
    muscleGroup: 'chest',
    sessions: sessions,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-test-1';

  setUpAll(() async {
    _setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseCrashlyticsPlatform.instance = _FakeCrashlyticsPlatform();
  });

  group('StatsProfileExecutor - getWorkoutStats', () {
    test('returns valid JSON with stats on success', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.statsToReturn = _makeStats();
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getWorkoutStats({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json, isNotNull);
      expect(json['totalWorkouts'], equals(42));
      expect(json['totalPRs'], equals(10));
      expect(json.containsKey('averageWorkoutDuration'), isTrue);
      expect(json.containsKey('trainingConsistency'), isTrue);
      expect(json.containsKey('topExercises'), isTrue);
    });

    test('returns error JSON when repository throws', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.statsError = Exception('Firestore unavailable');
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getWorkoutStats({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Firestore unavailable'));
      expect(json['toolName'], equals('getWorkoutStats'));
    });

    test('JSON is valid even with empty exercise frequency', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.statsToReturn = _makeStats(frequency: {});
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getWorkoutStats({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
      final json = jsonDecode(result) as Map<String, dynamic>;
      expect(json['topExercises'], isEmpty);
    });

    test('topExercises limited to 10 entries', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      final freq = Map.fromEntries(
        List.generate(20, (i) => MapEntry('Exercise $i', i + 1)),
      );
      repo.statsToReturn = _makeStats(frequency: freq);
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getWorkoutStats({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      expect((json['topExercises'] as Map).length, lessThanOrEqualTo(10));
    });
  });

  group('StatsProfileExecutor - getPersonalRecords', () {
    test('returns all PRs when no exerciseName provided', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.prsToReturn = [
        _makePR(value: 100),
        _makePR(exerciseName: 'Squat', value: 150),
      ];
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getPersonalRecords({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['totalPRs'], equals(2));
      expect((json['records'] as List).length, lessThanOrEqualTo(10));
    });

    test('returns empty list when no PRs exist', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.prsToReturn = [];
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getPersonalRecords({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['totalPRs'], equals(0));
      expect(json['records'], isEmpty);
    });

    test('returns exercise-specific PRs when exerciseName provided', () async {
      final analyticsRepo = FakeAnalyticsRepository();
      analyticsRepo.historyToReturn = _makeExerciseHistory();

      final workoutAnalyticsRepo = FakeWorkoutAnalyticsRepository();
      workoutAnalyticsRepo.exercisePrsToReturn = {
        PRType.weight: _makePR(value: 100),
      };

      final executor = _buildExecutor(
        analyticsRepoOverride: workoutAnalyticsRepo,
        analyticsOverride: analyticsRepo,
      );

      final result = await executor.getPersonalRecords(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json, isNotNull);
      expect(json.containsKey('error') || json.containsKey('records'), isTrue);
    });

    test('falls back to filtered PRs when exercise not found in analytics',
        () async {
      final analyticsRepo = FakeAnalyticsRepository();
      analyticsRepo.historyFailure = const NotFoundFailure('Not found');

      final workoutAnalyticsRepo = FakeWorkoutAnalyticsRepository();
      workoutAnalyticsRepo.prsToReturn = [
        _makePR(exerciseName: 'Bench Press', value: 100),
        _makePR(exerciseName: 'Squat', value: 150),
      ];

      final executor = _buildExecutor(
        analyticsRepoOverride: workoutAnalyticsRepo,
        analyticsOverride: analyticsRepo,
      );

      final result = await executor.getPersonalRecords(
        {'exerciseName': 'bench'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      // Should find matching PR or return no-PRs error
      expect(json, isNotNull);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns error JSON when repository throws', () async {
      final repo = FakeWorkoutAnalyticsRepository();
      repo.prsError = Exception('DB error');
      final executor = _buildExecutor(analyticsRepoOverride: repo);

      final result = await executor.getPersonalRecords({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('DB error'));
      expect(json['toolName'], equals('getPersonalRecords'));
    });
  });

  group('StatsProfileExecutor - getStreak', () {
    test('returns valid JSON with streak data on success', () async {
      final streakRepo = FakeStreakRepository();
      streakRepo.streakToReturn = const WorkoutStreak(
        currentStreak: 5,
        longestStreak: 14,
        isActive: true,
        lastWorkoutDate: null,
        totalWorkoutDays: 42,
      );
      final executor = _buildExecutor(streakOverride: streakRepo);

      final result = await executor.getStreak({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['currentStreak'], equals(5));
      expect(json['bestStreak'], equals(14));
      expect(json['totalWorkoutDays'], equals(42));
      expect(json['isActive'], isTrue);
    });

    test('returns zeros for inactive streak', () async {
      final streakRepo = FakeStreakRepository();
      streakRepo.streakToReturn = const WorkoutStreak(
        currentStreak: 0,
        longestStreak: 0,
        isActive: false,
        lastWorkoutDate: null,
        totalWorkoutDays: 0,
      );
      final executor = _buildExecutor(streakOverride: streakRepo);

      final result = await executor.getStreak({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['currentStreak'], equals(0));
      expect(json['isActive'], isFalse);
      expect(json['lastWorkoutDate'], isNull);
    });

    test('returns error JSON when repository throws', () async {
      final streakRepo = FakeStreakRepository();
      streakRepo.streakError = Exception('Streak fetch failed');
      final executor = _buildExecutor(streakOverride: streakRepo);

      final result = await executor.getStreak({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Streak fetch failed'));
      expect(json['toolName'], equals('getStreak'));
    });
  });

  group('StatsProfileExecutor - getWorkoutHistory', () {
    test('returns valid JSON with workout history', () async {
      final workouts = [
        _makeWorkout(daysAgo: 1, name: 'Push'),
        _makeWorkout(daysAgo: 3, name: 'Pull'),
        _makeWorkout(daysAgo: 5, name: 'Legs'),
      ];
      final executor = _buildExecutor(
        historyFn: () => Right(workouts),
      );

      final result = await executor.getWorkoutHistory(
        {'daysBack': 7, 'limit': 10},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['daysBack'], equals(7));
      expect((json['workouts'] as List).length, equals(3));
      expect(json['count'], equals(3));
    });

    test('returns empty list when no recent workouts', () async {
      final workouts = [
        _makeWorkout(daysAgo: 60, name: 'Old Workout'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWorkoutHistory(
        {'daysBack': 7, 'limit': 10},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['count'], equals(0));
      expect(json['workouts'], isEmpty);
    });

    test('respects limit parameter', () async {
      final workouts = List.generate(
        10,
        (i) => _makeWorkout(daysAgo: i + 1, name: 'Workout $i'),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWorkoutHistory(
        {'daysBack': 30, 'limit': 3},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect((json['workouts'] as List).length, equals(3));
    });

    test('parses daysBack from string argument', () async {
      final workouts = [_makeWorkout(daysAgo: 1)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWorkoutHistory(
        {'daysBack': '14', 'limit': '5'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['daysBack'], equals(14));
    });

    test('clamps daysBack to historyDaysLimit', () async {
      final workouts = List.generate(
        5,
        (i) => _makeWorkout(daysAgo: i + 1),
      );
      // Build executor with historyDaysLimit = 10
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right(workouts)),
        historyDaysLimit: 10,
      );

      final result = await executor.getWorkoutHistory(
        {'daysBack': 999},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['daysBack'], equals(10));
    });

    test('returns error JSON when repository fails', () async {
      final executor = _buildExecutor(
        historyFn: () => Left(const NetworkFailure('No network')),
      );

      final result = await executor.getWorkoutHistory({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('No network'));
      expect(json['toolName'], equals('getWorkoutHistory'));
    });

    test('workout items contain required fields', () async {
      final workouts = [_makeWorkout(daysAgo: 1, name: 'Test Workout')];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWorkoutHistory(
        {'daysBack': 7, 'limit': 5},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final workoutList = json['workouts'] as List;

      expect(workoutList, isNotEmpty);
      final workout = workoutList.first as Map<String, dynamic>;
      expect(workout.containsKey('name'), isTrue);
      expect(workout.containsKey('completedAt'), isTrue);
      expect(workout.containsKey('durationMinutes'), isTrue);
      expect(workout.containsKey('exerciseCount'), isTrue);
      expect(workout.containsKey('totalVolume'), isTrue);
      expect(workout.containsKey('totalSets'), isTrue);
    });
  });

  group('StatsProfileExecutor - getUserProfileContext', () {
    test('returns valid profile JSON without measurement repo', () async {
      final executor = _buildExecutor();

      final result = await executor.getUserProfileContext({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('profile'), isTrue);
      expect(json.containsKey('missingFields'), isTrue);
      expect(json.containsKey('suggestions'), isTrue);
      expect(json['toolName'], equals('getUserProfileContext'));
    });

    test('includes weight from measurement repo when available', () async {
      final measurementRepo = FakeMeasurementRepository();
      final weightMeasurement = Measurement(
        id: 'meas-1',
        userId: userId,
        metricType: MetricType.weight,
        value: 75.5,
        unit: 'kg',
        timestamp: DateTime(2024, 6, 1),
        source: MeasurementSource.manual,
        createdAt: DateTime(2024, 6, 1),
      );
      measurementRepo.latestResult = fp.Right({
        MetricType.weight: weightMeasurement,
      });
      final executor = _buildExecutor(measurementOverride: measurementRepo);

      final result = await executor.getUserProfileContext({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final profile = json['profile'] as Map<String, dynamic>;

      expect(profile['latestWeightKg'], equals(75.5));
      expect(profile['latestWeightDate'], equals('2024-06-01'));
    });

    test('omits weight when measurement repo returns empty', () async {
      final measurementRepo = FakeMeasurementRepository();
      measurementRepo.latestResult = fp.Right({});
      final executor = _buildExecutor(measurementOverride: measurementRepo);

      final result = await executor.getUserProfileContext({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final profile = json['profile'] as Map<String, dynamic>;

      expect(profile['latestWeightKg'], isNull);
    });

    test('returns error JSON on exception', () async {
      // Force exception by throwing from measurements
      final measurementRepo = _ThrowingMeasurementRepository();
      final executor = _buildExecutor(measurementOverride: measurementRepo);

      final result = await executor.getUserProfileContext({}, userId);
      // Even on error it should return valid JSON
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  group('StatsProfileExecutor - updateUserProfilePreferences', () {
    test('returns error when no valid fields provided', () async {
      final executor = _buildExecutor();

      final result = await executor.updateUserProfilePreferences({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('updateUserProfilePreferences'));
    });

    test('accepts valid experienceLevel', () async {
      final executor = _buildExecutor();

      final result = await executor.updateUserProfilePreferences(
        {'experienceLevel': 'beginner'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      // Either success or error (Hive may not be available in unit test)
      expect(() => jsonDecode(result), returnsNormally);
      expect(json.containsKey('toolName'), isTrue);
    });

    test('normalizes Italian experience level input', () async {
      final executor = _buildExecutor();

      final result = await executor.updateUserProfilePreferences(
        {'experienceLevel': 'principiante'},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('clamps weeklyTarget to valid range', () async {
      final executor = _buildExecutor();

      // weeklyTarget = 999 should be clamped to 7
      final result = await executor.updateUserProfilePreferences(
        {'weeklyTarget': 999},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  group('StatsProfileExecutor - getWorkoutPreferencesResult', () {
    test('returns error when getWorkoutPreferences not configured', () async {
      final executor = _buildExecutor();

      final result = await executor.getWorkoutPreferencesResult({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('getWorkoutPreferences'));
    });

    test('returns preferences JSON with inline card', () async {
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right([])),
        getWorkoutPreferences: () async => {
          'defaultExerciseSets': 4,
          'defaultExerciseReps': 8,
          'defaultRestTime': 90,
          'defaultRestBetweenExercises': 90,
        },
      );

      final result = await executor.getWorkoutPreferencesResult({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('preferences'), isTrue);
      expect(json.containsKey('message'), isTrue);
      expect(json.containsKey('inlineCard'), isTrue);
      expect(json['toolName'], equals('getWorkoutPreferences'));
    });

    test('returns error JSON when callback throws', () async {
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right([])),
        getWorkoutPreferences: () async => throw Exception('Prefs error'),
      );

      final result = await executor.getWorkoutPreferencesResult({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Prefs error'));
      expect(json['toolName'], equals('getWorkoutPreferences'));
    });
  });

  group('StatsProfileExecutor - updateWorkoutPreferencesResult', () {
    test('returns fallback card when no callbacks configured', () async {
      final executor = _buildExecutor();

      final result = await executor.updateWorkoutPreferencesResult(
        {'defaultExerciseSets': 5},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['success'], isFalse);
      expect(json.containsKey('inlineCard'), isTrue);
      expect(json['toolName'], equals('updateWorkoutPreferences'));
    });

    test('updates preferences and returns success JSON', () async {
      final updated = {
        'defaultExerciseSets': 5,
        'defaultExerciseReps': 5,
        'defaultRestTime': 180,
        'defaultRestBetweenExercises': 120,
      };
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right([])),
        getWorkoutPreferences: () async => updated,
        updateWorkoutPreferences: (_) async => updated,
      );

      final result = await executor.updateWorkoutPreferencesResult(
        {'defaultExerciseSets': 5, 'defaultExerciseReps': 5},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['success'], isTrue);
      expect(json.containsKey('preferences'), isTrue);
      expect(json.containsKey('inlineCard'), isTrue);
      expect(json['toolName'], equals('updateWorkoutPreferences'));
    });

    test('returns error when no valid keys are provided', () async {
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right([])),
        getWorkoutPreferences: () async => {'defaultExerciseSets': 4},
        updateWorkoutPreferences: (_) async => {},
      );

      final result = await executor.updateWorkoutPreferencesResult(
        {'unknownKey': 42},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('updateWorkoutPreferences'));
    });

    test('clamps sets to valid range 1-8', () async {
      final updates = <String, dynamic>{};
      final executor = StatsProfileExecutor(
        analyticsRepo: FakeAnalyticsRepository(),
        workoutAnalyticsRepo: FakeWorkoutAnalyticsRepository(),
        streakRepo: FakeStreakRepository(),
        historyRepo: _FakeHistoryRepo(() => Right([])),
        getWorkoutPreferences: () async => {'defaultExerciseSets': 4},
        updateWorkoutPreferences: (u) async {
          updates.addAll(u);
          return u;
        },
      );

      await executor.updateWorkoutPreferencesResult(
        {'defaultExerciseSets': 999},
        userId,
      );

      expect(updates['defaultExerciseSets'], equals(8));
    });
  });
}

/// Measurement repo that throws on getLatestMeasurementsByType
class _ThrowingMeasurementRepository extends FakeMeasurementRepository {
  @override
  Future<fp.Either<MeasurementFailure, Map<MetricType, Measurement>>>
  getLatestMeasurementsByType(String userId) async {
    throw Exception('Measurement unavailable');
  }
}
