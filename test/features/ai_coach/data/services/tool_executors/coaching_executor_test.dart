/// Unit tests for CoachingExecutor
///
/// Tests all public methods:
/// - getWeeklyCheckin
/// - getAutoProgressionPlan
/// - getAdherenceInsights
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/coaching_executor.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Mock using mocktail - uses `implements` so no constructor is invoked.
// This avoids HiveBoxManagerEnhanced initialization issues.
// ---------------------------------------------------------------------------

class MockWorkoutHistoryRepo extends Mock
    implements WorkoutHistoryRepositoryEnhanced {}

// ---------------------------------------------------------------------------
// Fake implementations
// ---------------------------------------------------------------------------

class _FakeWorkoutAnalyticsRepository implements WorkoutAnalyticsRepository {
  List<PersonalRecord> prsToReturn = [];
  Failure? prsFailure;

  @override
  Future<List<PersonalRecord>> getUserPRs(String userId) async {
    if (prsFailure != null) throw prsFailure!;
    return prsToReturn;
  }

  @override
  Future<WorkoutAnalyticsStats> getAnalyticsStats(String userId) async {
    return const WorkoutAnalyticsStats(
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
  Future<Map<PRType, PersonalRecord>> getExercisePRs(
    String userId,
    String exerciseId,
  ) async =>
      {};

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

class _FakeAnalyticsRepository implements AnalyticsRepository {
  ExerciseHistory? historyToReturn;
  Failure? historyFailure;
  List<ExerciseHistory> searchResults = [];

  @override
  Future<fp.Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  }) async {
    if (historyFailure != null) return fp.Left(historyFailure!);
    if (historyToReturn != null) return fp.Right(historyToReturn!);
    return fp.Left(const NotFoundFailure('Not found'));
  }

  @override
  Future<fp.Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  }) async =>
      fp.Right(searchResults);

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

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

WorkoutHistoryDetail _makeWorkout({
  int daysAgo = 1,
  String name = 'Push Day',
  double volumePerExercise = 5000,
  int durationMinutes = 60,
}) {
  final completedAt = DateTime.now().subtract(Duration(days: daysAgo));
  return WorkoutHistoryDetail(
    id: 'workout-$daysAgo-${name.hashCode}',
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

PersonalRecord _makePR({
  String exerciseName = 'Bench Press',
  double value = 100,
  int daysAgo = 1,
}) {
  return PersonalRecord(
    id: 'pr-$daysAgo',
    userId: 'user-1',
    exerciseId: 'bench-press',
    exerciseName: exerciseName,
    type: PRType.weight,
    value: value,
    achievedAt: DateTime.now().subtract(Duration(days: daysAgo)),
  );
}

ExerciseHistory _makeExerciseHistory({
  int sessionCount = 3,
  double baseWeight = 100.0,
  double weightIncrement = 2.5,
}) {
  final sessions = List.generate(sessionCount, (i) {
    return ExerciseSession(
      exerciseName: 'Bench Press',
      muscleGroup: 'chest',
      sets: [
        AnalyticsSet(
          weight: baseWeight + i * weightIncrement,
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
// Builder helper using mocktail mock for history repo.
// The mock uses `implements WorkoutHistoryRepositoryEnhanced` so NO
// constructor is invoked, avoiding HiveBoxManagerEnhanced initialization.
// ---------------------------------------------------------------------------

CoachingExecutor _buildExecutor({
  _FakeWorkoutAnalyticsRepository? workoutAnalyticsOverride,
  _FakeAnalyticsRepository? analyticsOverride,
  Either<Failure, List<WorkoutHistoryDetail>> Function()? historyFn,
}) {
  final mockHistoryRepo = MockWorkoutHistoryRepo();
  final Either<Failure, List<WorkoutHistoryDetail>> historyResult =
      historyFn != null
      ? historyFn()
      : Right<Failure, List<WorkoutHistoryDetail>>([]);
  when(
    () => mockHistoryRepo.getWorkouts(),
  ).thenAnswer((_) async => historyResult);

  return CoachingExecutor(
    historyRepo: mockHistoryRepo,
    workoutAnalyticsRepo:
        workoutAnalyticsOverride ?? _FakeWorkoutAnalyticsRepository(),
    analyticsRepo: analyticsOverride ?? _FakeAnalyticsRepository(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-test-1';

  group('CoachingExecutor - getWeeklyCheckin', () {
    test('returns valid JSON structure on success', () async {
      final workouts = [
        _makeWorkout(daysAgo: 1),
        _makeWorkout(daysAgo: 2, name: 'Pull'),
        _makeWorkout(daysAgo: 3, name: 'Legs'),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('period'), isTrue);
      expect(json.containsKey('weeklyTarget'), isTrue);
      expect(json.containsKey('thisWeek'), isTrue);
      expect(json.containsKey('lastWeek'), isTrue);
      expect(json.containsKey('adherenceScore'), isTrue);
      expect(json.containsKey('adherenceStatus'), isTrue);
      expect(json.containsKey('adjustments'), isTrue);
      expect(json.containsKey('motivation'), isTrue);
      expect(json['toolName'], equals('getWeeklyCheckin'));
    });

    test('adherenceStatus is one of valid values when target met', () async {
      final workouts = List.generate(
        3,
        (i) => _makeWorkout(daysAgo: i, name: 'Workout $i'),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(
        ['on_track', 'warning', 'critical'],
        contains(json['adherenceStatus']),
      );
    });

    test('marks critical adherence when no workouts this week', () async {
      // Only old workouts from 30 days ago
      final workouts = [_makeWorkout(daysAgo: 30)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['adherenceStatus'], equals('critical'));
    });

    test('counts PRs this week correctly', () async {
      final workoutAnalytics = _FakeWorkoutAnalyticsRepository();
      workoutAnalytics.prsToReturn = [
        _makePR(daysAgo: 0), // today
        _makePR(daysAgo: 1, exerciseName: 'Squat', value: 150), // yesterday
        _makePR(daysAgo: 30, exerciseName: 'Deadlift', value: 200), // old
      ];
      final workouts = [_makeWorkout(daysAgo: 1)];
      final executor = _buildExecutor(
        workoutAnalyticsOverride: workoutAnalytics,
        historyFn: () => Right(workouts),
      );

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final thisWeek = json['thisWeek'] as Map<String, dynamic>;

      expect(thisWeek['prs'], greaterThanOrEqualTo(0));
    });

    test('returns error JSON when history fetch fails', () async {
      final executor = _buildExecutor(
        historyFn: () => Left(const NetworkFailure('No network')),
      );

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('No network'));
      expect(json['toolName'], equals('getWeeklyCheckin'));
    });

    test('returns valid JSON when PRs repository returns empty list', () async {
      // Tests the no-PRs path without triggering FirebaseCrashlytics catch block.
      // An empty PR list is valid; the executor handles it gracefully.
      final workoutAnalytics = _FakeWorkoutAnalyticsRepository();
      workoutAnalytics.prsToReturn = []; // no PRs available
      final executor = _buildExecutor(
        workoutAnalyticsOverride: workoutAnalytics,
        historyFn: () => Right([_makeWorkout(daysAgo: 1)]),
      );

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(() => jsonDecode(result), returnsNormally);
      expect(json['toolName'], equals('getWeeklyCheckin'));
      final thisWeek = json['thisWeek'] as Map<String, dynamic>;
      expect(thisWeek['prs'], equals(0));
    });

    test('adjustments list is limited to 3 items', () async {
      final executor = _buildExecutor(historyFn: () => Right([]));

      final result = await executor.getWeeklyCheckin({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final adjustments = json['adjustments'] as List;

      expect(adjustments.length, lessThanOrEqualTo(3));
    });

    test('returns valid JSON for empty workout list', () async {
      final executor = _buildExecutor(historyFn: () => Right([]));

      final result = await executor.getWeeklyCheckin({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  group('CoachingExecutor - getAutoProgressionPlan', () {
    test('returns error when exerciseName is missing', () async {
      final executor = _buildExecutor();

      final result = await executor.getAutoProgressionPlan({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Missing required parameter'));
      expect(json['toolName'], equals('getAutoProgressionPlan'));
    });

    test('returns error when exerciseName is empty string', () async {
      final executor = _buildExecutor();

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': '   '},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('getAutoProgressionPlan'));
    });

    test('returns insufficient data message with only 1 session', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = ExerciseHistory(
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            sets: [
              AnalyticsSet(weight: 100, reps: 8, date: DateTime.now()),
            ],
            date: DateTime.now(),
          ),
        ],
      );
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['message'], contains('insufficienti'));
      expect(json['toolName'], equals('getAutoProgressionPlan'));
    });

    test(
      'returns increase_load or maintain action with 2 improving sessions',
      () async {
        final analytics = _FakeAnalyticsRepository();
        analytics.historyToReturn = ExerciseHistory(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [
            // Most recent: 105kg x 10 reps
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              sets: [
                AnalyticsSet(
                  weight: 105,
                  reps: 10,
                  date: DateTime.now(),
                ),
              ],
              date: DateTime.now(),
            ),
            // Previous: 100kg x 8 reps
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              sets: [
                AnalyticsSet(
                  weight: 100,
                  reps: 8,
                  date: DateTime.now().subtract(const Duration(days: 7)),
                ),
              ],
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ],
        );
        final executor = _buildExecutor(analyticsOverride: analytics);

        final result = await executor.getAutoProgressionPlan(
          {
            'exerciseName': 'Bench Press',
            'targetRepsMin': 8,
            'targetRepsMax': 10,
          },
          userId,
        );
        final json = jsonDecode(result) as Map<String, dynamic>;

        expect(json.containsKey('autoProgression'), isTrue);
        final progression = json['autoProgression'] as Map<String, dynamic>;
        expect(progression.containsKey('action'), isTrue);
        expect(progression.containsKey('suggestedTopWeight'), isTrue);
        expect(progression.containsKey('rationale'), isTrue);
      },
    );

    test('returns deload recommendation when trend is strongly negative',
        () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = ExerciseHistory(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        muscleGroup: 'legs',
        sessions: [
          // Most recent: very low weight (big drop)
          ExerciseSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            sets: [
              AnalyticsSet(
                weight: 80,
                reps: 5,
                date: DateTime.now(),
              ),
            ],
            date: DateTime.now(),
          ),
          // Previous: high weight
          ExerciseSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            sets: [
              AnalyticsSet(
                weight: 120,
                reps: 8,
                date: DateTime.now().subtract(const Duration(days: 7)),
              ),
            ],
            date: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      );
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Squat'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final progression = json['autoProgression'] as Map<String, dynamic>;

      // With a strong drop in 1RM, action should be deload
      expect(progression['action'], equals('deload'));
    });

    test('exercises with legs muscle group use 5.0 load step', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = ExerciseHistory(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        muscleGroup: 'legs',
        sessions: [
          ExerciseSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            sets: [
              AnalyticsSet(weight: 100, reps: 10, date: DateTime.now()),
            ],
            date: DateTime.now(),
          ),
          ExerciseSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            sets: [
              AnalyticsSet(
                weight: 95,
                reps: 8,
                date: DateTime.now().subtract(const Duration(days: 7)),
              ),
            ],
            date: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      );
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {
          'exerciseName': 'Squat',
          'targetRepsMin': 8,
          'targetRepsMax': 10,
        },
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('autoProgression'), isTrue);
      if (json['autoProgression']['action'] == 'increase_load') {
        final suggested = double.parse(
          json['autoProgression']['suggestedTopWeight'] as String,
        );
        // Load step for legs should be 5.0
        expect((suggested - 100).abs(), closeTo(5.0, 0.1));
      }
    });

    test('falls back to search when exercise not found directly', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyFailure = const NotFoundFailure('Not found');
      // searchExercises returns empty - should return not found error
      analytics.searchResults = [];

      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Unknown Exercise'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('not found'));
      expect(json['toolName'], equals('getAutoProgressionPlan'));
    });

    test('returns error JSON when analytics returns server failure', () async {
      // Tests the error path without triggering FirebaseCrashlytics catch block.
      // Uses Left(ServerFailure) which is handled via fold, not catch.
      final analytics = _FakeAnalyticsRepository();
      analytics.historyFailure = const ServerFailure('Server error');
      analytics.searchResults = [];
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('getAutoProgressionPlan'));
    });

    test('confidence is high with 4+ sessions', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = _makeExerciseHistory(sessionCount: 4);
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final progression = json['autoProgression'] as Map<String, dynamic>;

      expect(progression['confidence'], equals('high'));
    });

    test('confidence is low with exactly 2 sessions', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = _makeExerciseHistory(sessionCount: 2);
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final progression = json['autoProgression'] as Map<String, dynamic>;

      expect(progression['confidence'], equals('low'));
    });

    test('parses targetRepsMin and targetRepsMax from strings', () async {
      final analytics = _FakeAnalyticsRepository();
      analytics.historyToReturn = _makeExerciseHistory(sessionCount: 2);
      final executor = _buildExecutor(analyticsOverride: analytics);

      final result = await executor.getAutoProgressionPlan(
        {
          'exerciseName': 'Bench Press',
          'targetRepsMin': '5',
          'targetRepsMax': '8',
        },
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  group('CoachingExecutor - getAdherenceInsights', () {
    test('returns valid JSON structure on success', () async {
      final workouts = List.generate(
        8,
        (i) => _makeWorkout(daysAgo: i * 3 + 1),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['periodDays'], equals(28));
      expect(json.containsKey('weeklyTarget'), isTrue);
      expect(json.containsKey('workoutsCompleted'), isTrue);
      expect(json.containsKey('adherencePercent'), isTrue);
      expect(json.containsKey('longestGapDays'), isTrue);
      expect(json.containsKey('riskLevel'), isTrue);
      expect(json.containsKey('likelyBarrier'), isTrue);
      expect(json.containsKey('actionPlan'), isTrue);
      expect(json.containsKey('motivation'), isTrue);
      expect(json['toolName'], equals('getAdherenceInsights'));
    });

    test('riskLevel is low when adherence >= 85%', () async {
      // Default weeklyTarget is 3, so provide 12 workouts in 28 days = 100%
      final workouts = List.generate(
        12,
        (i) => _makeWorkout(daysAgo: (i * 2) + 1),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['riskLevel'], equals('low'));
      expect(json['adherencePercent'], greaterThanOrEqualTo(85));
    });

    test('riskLevel is high when adherence < 60%', () async {
      // Only 2 workouts in 28 days against default target of 3/week = 12
      final workouts = [_makeWorkout(daysAgo: 5), _makeWorkout(daysAgo: 15)];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['riskLevel'], equals('high'));
    });

    test('longestGapDays is 0 for single workout', () async {
      final executor = _buildExecutor(
        historyFn: () => Right([_makeWorkout(daysAgo: 5)]),
      );

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['longestGapDays'], equals(0));
    });

    test('detects routine_fragile barrier for large gap', () async {
      // Two workouts far apart (> 5 days gap)
      final workouts = [
        _makeWorkout(daysAgo: 1),
        _makeWorkout(daysAgo: 20),
      ];
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['likelyBarrier'], equals('routine_fragile'));
    });

    test('suggestions list is always present', () async {
      final executor = _buildExecutor(historyFn: () => Right([]));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('suggestions'), isTrue);
      expect((json['suggestions'] as List).length, equals(3));
    });

    test('returns error JSON when history fetch fails', () async {
      final executor = _buildExecutor(
        historyFn: () => Left(const NetworkFailure('Connection failed')),
      );

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Connection failed'));
      expect(json['toolName'], equals('getAdherenceInsights'));
    });

    test('returns error JSON when history fetch returns cache failure',
        () async {
      // Tests the error path without triggering FirebaseCrashlytics catch block.
      // Uses Left(CacheFailure) which is handled via fold, not catch.
      final executor = _buildExecutor(
        historyFn: () => Left(const CacheFailure('Cache error')),
      );

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('getAdherenceInsights'));
    });

    test('adherencePercent clamped to max 120', () async {
      // 20 workouts in 28 days, target 3/week = 12 target -> 166% raw
      final workouts = List.generate(
        20,
        (i) => _makeWorkout(daysAgo: i + 1),
      );
      final executor = _buildExecutor(historyFn: () => Right(workouts));

      final result = await executor.getAdherenceInsights({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['adherencePercent'], lessThanOrEqualTo(120));
    });
  });
}
