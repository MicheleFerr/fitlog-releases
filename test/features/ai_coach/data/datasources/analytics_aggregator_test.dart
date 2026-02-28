/// Unit tests for AnalyticsAggregator
///
/// Tests the aggregation logic that collects data from multiple repositories
/// (analytics, history, streak, measurements) and combines them into an
/// AIContext for the AI Coach feature.
///
/// Uses manual fake implementations — no mockito/mocktail required.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

// AnalyticsRepository uses fpdart Either; import with prefix to avoid conflict
// with the project's custom Either used by WorkoutHistoryRepositoryEnhanced.
import 'package:fpdart/fpdart.dart' as fp;

import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart' as ce;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Firebase auth fake (minimal — only currentUser needed by repo ctor)
// ---------------------------------------------------------------------------

class _FakeUser implements User {
  const _FakeUser(this.uid);
  @override
  final String uid;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth({User? user}) : _currentUser = user;
  final User? _currentUser;
  @override
  User? get currentUser => _currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// FakeWorkoutHistoryRepo
//
// Subclasses WorkoutHistoryRepositoryEnhanced — a concrete class — and
// overrides getWorkouts() completely. FakeFirebaseFirestore + _FakeFirebaseAuth
// are injected so the super-constructor never touches real Firebase.
// _initialize() is fire-and-forget; since getWorkouts() is overridden,
// Hive paths are never exercised.
// ---------------------------------------------------------------------------

class FakeWorkoutHistoryRepo extends WorkoutHistoryRepositoryEnhanced {
  FakeWorkoutHistoryRepo()
    : super(
        boxManager: HiveBoxManagerEnhanced(),
        firestore: FakeFirebaseFirestore(),
        auth: _FakeFirebaseAuth(user: const _FakeUser('user123')),
      );

  List<WorkoutHistoryDetail> workoutsResult = [];
  Failure? workoutsFailure;

  /// The parent declares:
  ///   Future<Either<Failure, List<WorkoutHistoryDetail>>> getWorkouts()
  /// where Either comes from `package:gymbro_flutter_new/shared/domain/either/either.dart`.
  /// We use the `ce` alias (custom_either) to satisfy that return type.
  @override
  Future<ce.Either<Failure, List<WorkoutHistoryDetail>>> getWorkouts() async {
    if (workoutsFailure != null) return ce.Left(workoutsFailure!);
    return ce.Right(workoutsResult);
  }
}

// ---------------------------------------------------------------------------
// FakeAnalyticsRepository
// AnalyticsRepository uses fpdart Either (fp.Either).
// ---------------------------------------------------------------------------

class FakeAnalyticsRepository implements AnalyticsRepository {
  List<ExerciseHistory> exerciseHistoryResult = [];
  Failure? exerciseHistoryFailure;
  bool shouldTimeout = false;

  @override
  Stream<fp.Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) {
    if (shouldTimeout) return const Stream.empty();
    if (exerciseHistoryFailure != null) {
      return Stream.value(fp.Left(exerciseHistoryFailure!));
    }
    return Stream.value(fp.Right(exerciseHistoryResult));
  }

  @override
  Future<fp.Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  }) async => const fp.Right([]);

  @override
  Future<fp.Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  }) async => const fp.Left(NetworkFailure('not implemented'));

  @override
  Future<fp.Either<Failure, List<ExerciseSession>>> getSessionsByTimeframe({
    required String userId,
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  }) async => const fp.Right([]);

  @override
  Future<fp.Either<Failure, void>> clearCache() async => const fp.Right(null);

  @override
  Future<bool> isCacheValid(String userId) async => false;

  @override
  Future<fp.Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  }) async => const fp.Right(null);
}

// ---------------------------------------------------------------------------
// FakeStreakRepository
// ---------------------------------------------------------------------------

class FakeStreakRepository implements StreakRepository {
  int currentStreakDays = 0;
  bool shouldThrow = false;

  @override
  Future<WorkoutStreak> getCurrentStreak() async {
    if (shouldThrow) throw Exception('Streak repo error');
    return WorkoutStreak(
      currentStreak: currentStreakDays,
      longestStreak: currentStreakDays,
      isActive: currentStreakDays > 0,
      lastWorkoutDate: currentStreakDays > 0 ? DateTime.now() : null,
      totalWorkoutDays: currentStreakDays,
    );
  }

  @override
  Future<void> checkAndNotifyMilestone(int newStreak) async {}
}

// ---------------------------------------------------------------------------
// FakeMeasurementRepository
// MeasurementRepository uses fpdart Either (fp.Either).
// ---------------------------------------------------------------------------

class FakeMeasurementRepository implements MeasurementRepository {
  Map<MetricType, Measurement>? latestMeasurementsResult;
  MeasurementFailure? latestMeasurementsFailure;
  bool shouldThrow = false;

  @override
  Future<fp.Either<MeasurementFailure, Map<MetricType, Measurement>>>
  getLatestMeasurementsByType(String userId) async {
    if (shouldThrow) throw Exception('Measurement repo error');
    if (latestMeasurementsFailure != null) {
      return fp.Left(latestMeasurementsFailure!);
    }
    return fp.Right(latestMeasurementsResult ?? {});
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async => const fp.Right([]);

  @override
  Future<fp.Either<MeasurementFailure, void>> updateMeasurement(
    Measurement measurement,
  ) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  }) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  ) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  }) async => const fp.Left(StorageFailure(message: 'not implemented'));

  @override
  Future<fp.Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(
    String userId,
  ) async => const fp.Right([]);

  @override
  Future<fp.Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(
    String userId,
  ) async => const fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, int>> cleanupExpiredMeasurements(
    String userId, {
    int retentionDays = 30,
  }) async => const fp.Right(0);
}

// ---------------------------------------------------------------------------
// Helper factories
// ---------------------------------------------------------------------------

/// Build an ExerciseHistory with a single session whose highest 1RM equals
/// the given [estimated1RM] (weight × 1 rep → Epley 1RM ≈ weight).
ExerciseHistory makeExerciseHistory({
  required String name,
  required double estimated1RM,
}) {
  final set = AnalyticsSet(
    weight: estimated1RM,
    reps: 1,
    date: DateTime(2025, 1, 1),
  );
  final session = ExerciseSession(
    exerciseName: name,
    muscleGroup: 'chest',
    sets: [set],
    date: DateTime(2025, 1, 1),
  );
  return ExerciseHistory(
    exerciseId: name.toLowerCase().replaceAll(' ', '_'),
    exerciseName: name,
    muscleGroup: 'chest',
    sessions: [session],
  );
}

/// Build a minimal WorkoutHistoryDetail completed [daysAgo] days in the past.
WorkoutHistoryDetail makeWorkout({
  required String id,
  required String name,
  int daysAgo = 1,
  int durationMinutes = 60,
  int exerciseCount = 3,
}) {
  final completedAt = DateTime.now().subtract(Duration(days: daysAgo));
  return WorkoutHistoryDetail(
    id: id,
    userId: 'user123',
    name: name,
    description: '',
    createdAt: completedAt,
    startedAt: completedAt,
    completedAt: completedAt,
    updatedAt: completedAt,
    duration: Duration(minutes: durationMinutes),
    exercises: List.generate(
      exerciseCount,
      (i) => ExerciseHistoryDetail(
        id: 'ex_$i',
        name: 'Exercise $i',
        category: 'barbell',
        sets: [],
        exerciseData: {},
      ),
    ),
    metadata: {},
  );
}

/// Build a body weight Measurement.
Measurement makeWeightMeasurement(double kg) {
  return Measurement(
    id: 'meas_1',
    userId: 'user123',
    metricType: MetricType.weight,
    value: kg,
    unit: 'kg',
    timestamp: DateTime(2025, 1, 1),
    source: MeasurementSource.manual,
  );
}

/// Wire up an AnalyticsAggregator with the provided fakes.
AnalyticsAggregator makeAggregator({
  FakeAnalyticsRepository? analytics,
  FakeWorkoutHistoryRepo? history,
  FakeStreakRepository? streak,
  FakeMeasurementRepository? measurements,
  OnboardingState? onboardingState,
  String accountTier = 'free',
}) {
  return AnalyticsAggregator(
    analyticsRepo: analytics ?? FakeAnalyticsRepository(),
    historyRepo: history ?? FakeWorkoutHistoryRepo(),
    streakRepo: streak ?? FakeStreakRepository(),
    measurementRepo: measurements,
    onboardingState: onboardingState,
    accountTier: accountTier,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------- getTop5OneRM -------------------------------------------------
  group('getTop5OneRM', () {
    test('returns empty map when exercise history stream emits empty list',
        () async {
      final analytics = FakeAnalyticsRepository()..exerciseHistoryResult = [];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result, isEmpty);
    });

    test('returns map with single exercise when one exercise present',
        () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [
          makeExerciseHistory(name: 'Squat', estimated1RM: 150),
        ];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result, {'Squat': 150});
    });

    test('returns top 5 by highest 1RM, dropping the 6th weakest', () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [
          makeExerciseHistory(name: 'Curl', estimated1RM: 40),
          makeExerciseHistory(name: 'Bench Press', estimated1RM: 120),
          makeExerciseHistory(name: 'Squat', estimated1RM: 180),
          makeExerciseHistory(name: 'Deadlift', estimated1RM: 220),
          makeExerciseHistory(name: 'OHP', estimated1RM: 90),
          makeExerciseHistory(name: 'Row', estimated1RM: 130),
        ];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result.length, 5);
      expect(result.containsKey('Curl'), isFalse);
      expect(result['Deadlift'], 220);
      expect(result['Squat'], 180);
    });

    test('limits result to exactly 5 exercises when more than 5 present',
        () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = List.generate(
          10,
          (i) => makeExerciseHistory(
            name: 'Exercise $i',
            estimated1RM: (i + 1) * 10.0,
          ),
        );
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result.length, 5);
    });

    test('returns empty map when stream emits Left failure', () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryFailure = const NetworkFailure('connection error');
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result, isEmpty);
    });

    test('returns empty map when stream never emits (timeout)', () async {
      final analytics = FakeAnalyticsRepository()..shouldTimeout = true;
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 20)));

    test('skips exercises that have no sessions', () async {
      const noSessionExercise = ExerciseHistory(
        exerciseId: 'empty',
        exerciseName: 'Empty Exercise',
        muscleGroup: 'back',
        sessions: [],
      );
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [
          noSessionExercise,
          makeExerciseHistory(name: 'Squat', estimated1RM: 100),
        ];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result.containsKey('Empty Exercise'), isFalse);
      expect(result['Squat'], 100);
    });

    test('rounds fractional 1RM to nearest integer', () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [
          makeExerciseHistory(name: 'Bench Press', estimated1RM: 115.7),
        ];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result['Bench Press'], 116);
    });

    test('uses highest 1RM across multiple sessions for same exercise',
        () async {
      final exercise = ExerciseHistory(
        exerciseId: 'bench',
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            sets: [
              AnalyticsSet(weight: 80, reps: 1, date: DateTime(2025, 1, 1)),
            ],
            date: DateTime(2025, 1, 1),
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            sets: [
              AnalyticsSet(weight: 120, reps: 1, date: DateTime(2025, 2, 1)),
            ],
            date: DateTime(2025, 2, 1),
          ),
        ],
      );
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [exercise];
      final aggregator = makeAggregator(analytics: analytics);

      final result = await aggregator.getTop5OneRM('user123');

      expect(result['Bench Press'], 120);
    });
  });

  // ---------- getCurrentStreak ---------------------------------------------
  group('getCurrentStreak', () {
    test('returns streak days from streak repository', () async {
      final streak = FakeStreakRepository()..currentStreakDays = 7;
      final aggregator = makeAggregator(streak: streak);

      final result = await aggregator.getCurrentStreak('user123');

      expect(result, 7);
    });

    test('returns 0 when streak repository throws', () async {
      final streak = FakeStreakRepository()..shouldThrow = true;
      final aggregator = makeAggregator(streak: streak);

      final result = await aggregator.getCurrentStreak('user123');

      expect(result, 0);
    });

    test('returns 0 for new user with no workouts', () async {
      final streak = FakeStreakRepository()..currentStreakDays = 0;
      final aggregator = makeAggregator(streak: streak);

      final result = await aggregator.getCurrentStreak('user123');

      expect(result, 0);
    });

    test('returns large streak value correctly', () async {
      final streak = FakeStreakRepository()..currentStreakDays = 365;
      final aggregator = makeAggregator(streak: streak);

      final result = await aggregator.getCurrentStreak('user123');

      expect(result, 365);
    });
  });

  // ---------- getLastWorkout -----------------------------------------------
  group('getLastWorkout', () {
    test('returns null when history is empty', () async {
      final history = FakeWorkoutHistoryRepo()..workoutsResult = [];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result, isNull);
    });

    test('returns first element as the most recent workout', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          makeWorkout(id: 'w1', name: 'Leg Day', daysAgo: 1),
          makeWorkout(id: 'w2', name: 'Push Day', daysAgo: 3),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result?.name, 'Leg Day');
      expect(result?.id, 'w1');
    });

    test('maps exercise count from history detail', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          makeWorkout(id: 'w1', name: 'Full Body', exerciseCount: 6),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result?.exerciseCount, 6);
    });

    test('maps duration in minutes from history detail', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          makeWorkout(id: 'w1', name: 'Push Day', durationMinutes: 75),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result?.durationMinutes, 75);
    });

    test('returns null when history repo returns Left failure', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsFailure = const NetworkFailure('offline');
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result, isNull);
    });

    test('captures completedAt from workout detail', () async {
      final fixedDate = DateTime(2025, 6, 15, 10, 30);
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          WorkoutHistoryDetail(
            id: 'w1',
            userId: 'user123',
            name: 'Morning Run',
            description: '',
            createdAt: fixedDate,
            startedAt: fixedDate,
            completedAt: fixedDate,
            updatedAt: fixedDate,
            duration: const Duration(minutes: 45),
            exercises: [],
            metadata: {},
          ),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getLastWorkout('user123');

      expect(result?.completedAt, fixedDate);
    });
  });

  // ---------- getRecoveryStatus --------------------------------------------
  group('getRecoveryStatus', () {
    test('returns green when fewer than 4 workouts in last 7 days', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          makeWorkout(id: 'w1', name: 'A', daysAgo: 1),
          makeWorkout(id: 'w2', name: 'B', daysAgo: 3),
          makeWorkout(id: 'w3', name: 'C', daysAgo: 5),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.green);
    });

    test('returns amber when exactly 4 workouts in last 7 days', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = List.generate(
          4,
          (i) => makeWorkout(id: 'w$i', name: 'W$i', daysAgo: i + 1),
        );
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.amber);
    });

    test('returns amber when exactly 5 workouts in last 7 days', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = List.generate(
          5,
          (i) => makeWorkout(id: 'w$i', name: 'W$i', daysAgo: i + 1),
        );
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.amber);
    });

    test('returns red when exactly 6 workouts in last 7 days', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = List.generate(
          6,
          (i) => makeWorkout(id: 'w$i', name: 'W$i', daysAgo: i + 1),
        );
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.red);
    });

    test('ignores workouts older than 7 days for recovery calculation',
        () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [
          makeWorkout(id: 'w1', name: 'Old', daysAgo: 8),
          makeWorkout(id: 'w2', name: 'Old2', daysAgo: 14),
          makeWorkout(id: 'w3', name: 'Old3', daysAgo: 30),
        ];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.green);
    });

    test('returns green as fallback when history repo returns failure',
        () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsFailure = const NetworkFailure('offline');
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.green);
    });

    test('returns green when workout list is empty', () async {
      final history = FakeWorkoutHistoryRepo()..workoutsResult = [];
      final aggregator = makeAggregator(history: history);

      final result = await aggregator.getRecoveryStatus('user123');

      expect(result, RecoveryStatus.green);
    });
  });

  // ---------- aggregateContext (full integration of all repos) -------------
  group('aggregateContext', () {
    test('assembles complete AIContext from all repositories', () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryResult = [
          makeExerciseHistory(name: 'Bench Press', estimated1RM: 120),
          makeExerciseHistory(name: 'Squat', estimated1RM: 160),
        ];
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = [makeWorkout(id: 'w1', name: 'Push Day')];
      final streak = FakeStreakRepository()..currentStreakDays = 5;
      final aggregator = makeAggregator(
        analytics: analytics,
        history: history,
        streak: streak,
      );

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.currentStreak, 5);
      expect(context.lastWorkout?.name, 'Push Day');
      expect(context.top5OneRM.containsKey('Bench Press'), isTrue);
      expect(context.top5OneRM.containsKey('Squat'), isTrue);
      expect(context.userTier, 'free');
    });

    test('uses provided accountTier in resulting context', () async {
      final aggregator = makeAggregator(accountTier: 'premium');

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.userTier, 'premium');
    });

    test('returns safe fallback context when streak repo throws', () async {
      final streak = FakeStreakRepository()..shouldThrow = true;
      final aggregator = makeAggregator(streak: streak);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.currentStreak, 0);
      expect(context.userTier, 'free');
      expect(context.recoveryStatus, RecoveryStatus.green);
    });

    test('resolves beginner experience from onboarding userExperienceLevel',
        () async {
      const onboarding = OnboardingState(userExperienceLevel: 'beginner');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.experienceLevel, 'beginner');
    });

    test('maps onboarding "expert" to "experienced" level', () async {
      const onboarding = OnboardingState(userExperienceLevel: 'expert');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.experienceLevel, 'experienced');
    });

    test('resolves experience from stepData aiExperienceLevel (Italian)',
        () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'principiante'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.experienceLevel, 'beginner');
    });

    test('resolves muscle goal from buildMuscle userGoal', () async {
      const onboarding = OnboardingState(userGoal: 'buildMuscle');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal, contains('muscle'));
    });

    test('resolves fat_loss goal from Italian aiGoal stepData', () async {
      const onboarding = OnboardingState(stepData: {'aiGoal': 'perdere peso'});
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal, contains('fat_loss'));
    });

    test('includes weekly_target in pipe-separated fitnessGoal string',
        () async {
      const onboarding = OnboardingState(
        userGoal: 'getStronger',
        weeklyWorkoutTarget: 4,
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal, contains('weekly_target:4'));
      expect(context.fitnessGoal, contains('strength'));
    });

    test('fitnessGoal is null when no onboarding state', () async {
      final aggregator = makeAggregator(onboardingState: null);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal, isNull);
    });

    test('experienceLevel is null when no onboarding state', () async {
      final aggregator = makeAggregator(onboardingState: null);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.experienceLevel, isNull);
    });

    test('includes body_weight_kg tag from measurement repo weight data',
        () async {
      final measurements = FakeMeasurementRepository()
        ..latestMeasurementsResult = {
          MetricType.weight: makeWeightMeasurement(82.5),
        };
      final aggregator = makeAggregator(measurements: measurements);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal, contains('body_weight_kg:82.5'));
    });

    test('omits body_weight_kg when no measurement repo provided', () async {
      final aggregator = makeAggregator(measurements: null);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal?.contains('body_weight_kg'), isNot(true));
    });

    test('omits body_weight_kg when measurement repo returns Left failure',
        () async {
      final measurements = FakeMeasurementRepository()
        ..latestMeasurementsFailure =
            const StorageFailure(message: 'db error');
      final aggregator = makeAggregator(measurements: measurements);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal?.contains('body_weight_kg'), isNot(true));
    });

    test('omits body_weight_kg when measurement repo throws', () async {
      final measurements = FakeMeasurementRepository()..shouldThrow = true;
      final aggregator = makeAggregator(measurements: measurements);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal?.contains('body_weight_kg'), isNot(true));
    });

    test('omits body_weight_kg when weight metric absent from measurements',
        () async {
      final measurements = FakeMeasurementRepository()
        ..latestMeasurementsResult = {
          MetricType.bodyFatPercentage: makeWeightMeasurement(15),
        };
      final aggregator = makeAggregator(measurements: measurements);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.fitnessGoal?.contains('body_weight_kg'), isNot(true));
    });

    test('recovery is red when 6+ workouts found within last 7 days', () async {
      final history = FakeWorkoutHistoryRepo()
        ..workoutsResult = List.generate(
          6,
          (i) => makeWorkout(id: 'w$i', name: 'Day $i', daysAgo: i + 1),
        );
      final aggregator = makeAggregator(history: history);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.recoveryStatus, RecoveryStatus.red);
    });

    test('top5OneRM is empty when analytics repo returns failure', () async {
      final analytics = FakeAnalyticsRepository()
        ..exerciseHistoryFailure = const NetworkFailure('offline');
      final aggregator = makeAggregator(analytics: analytics);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.top5OneRM, isEmpty);
    });

    test('lastWorkout is null when history repo returns empty list', () async {
      final history = FakeWorkoutHistoryRepo()..workoutsResult = [];
      final aggregator = makeAggregator(history: history);

      final context = await aggregator.aggregateContext(userId: 'user123');

      expect(context.lastWorkout, isNull);
    });

    test('combines all goal parts with pipe separator', () async {
      final measurements = FakeMeasurementRepository()
        ..latestMeasurementsResult = {
          MetricType.weight: makeWeightMeasurement(75.0),
        };
      const onboarding = OnboardingState(
        userGoal: 'loseWeight',
        weeklyWorkoutTarget: 3,
      );
      final aggregator = makeAggregator(
        measurements: measurements,
        onboardingState: onboarding,
      );

      final context = await aggregator.aggregateContext(userId: 'user123');

      final goal = context.fitnessGoal!;
      expect(goal, contains('fat_loss'));
      expect(goal, contains('weekly_target:3'));
      expect(goal, contains('body_weight_kg:75.0'));
      expect(goal, contains('|'));
    });
  });

  // ---------- experience level normalization (via aggregateContext) ---------
  group('experience level normalization', () {
    test('recognizes "athlete" keyword (English)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'athlete'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'athlete');
    });

    test('recognizes "atleta" keyword (Italian) case-insensitively', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'Atleta'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'athlete');
    });

    test('recognizes "intermediate" keyword', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'intermediate'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'some');
    });

    test('recognizes "avanzato" keyword (Italian advanced)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'avanzato'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'experienced');
    });

    test('recognizes "esperto" keyword (Italian expert)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'Esperto'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'experienced');
    });

    test('returns null for whitespace-only experience level string', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': '   '},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, isNull);
    });

    test('recognizes "some" keyword in stepData experience', () async {
      const onboarding = OnboardingState(
        stepData: {'aiExperienceLevel': 'some experience'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.experienceLevel, 'some');
    });
  });

  // ---------- fitness goal normalization (via aggregateContext) -------------
  group('fitness goal normalization', () {
    test('recognizes "massa" keyword (Italian muscle)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiGoal': 'Aumento massa'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('muscle'));
    });

    test('recognizes "forza" keyword (Italian strength)', () async {
      const onboarding = OnboardingState(stepData: {'aiGoal': 'forza pura'});
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('strength'));
    });

    test('recognizes "ricomposizione" keyword (Italian recomposition)',
        () async {
      const onboarding = OnboardingState(
        stepData: {'aiGoal': 'ricomposizione corporea'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('recomposition'));
    });

    test('recognizes "resistenza" keyword (Italian endurance)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiGoal': 'resistenza e fitness'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('endurance'));
    });

    test('maps stayFit userGoal to endurance', () async {
      const onboarding = OnboardingState(userGoal: 'stayFit');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('endurance'));
    });

    test('maps loseWeight userGoal to fat_loss', () async {
      const onboarding = OnboardingState(userGoal: 'loseWeight');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('fat_loss'));
    });

    test('returns null fitnessGoal for unknown userGoal without extras',
        () async {
      const onboarding = OnboardingState(userGoal: 'unknownGoal');
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, isNull);
    });

    test('recognizes "ipertrof" keyword (Italian hypertrophy)', () async {
      const onboarding = OnboardingState(
        stepData: {'aiGoal': 'ipertrofia muscolare'},
      );
      final aggregator = makeAggregator(onboardingState: onboarding);

      final context = await aggregator.aggregateContext(userId: 'u1');

      expect(context.fitnessGoal, contains('muscle'));
    });
  });
}
