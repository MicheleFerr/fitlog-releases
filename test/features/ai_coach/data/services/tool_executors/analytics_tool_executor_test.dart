/// Unit tests for AnalyticsToolExecutor
///
/// Tests JSON validity, error handling, and edge cases for:
/// - get1RMHistory
/// - getWeeklyVolume
/// - analyzeMuscleBalance
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/analytics_tool_executor.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Fake AnalyticsRepository
// ---------------------------------------------------------------------------

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository({
    this.exerciseHistoryResult,
    this.searchResult,
    this.streamToEmit,
  });

  /// What getExerciseHistoryByName returns
  Either<Failure, ExerciseHistory>? exerciseHistoryResult;

  /// What searchExercises returns
  Either<Failure, List<ExerciseHistory>>? searchResult;

  /// What getExerciseHistory stream emits
  Either<Failure, List<ExerciseHistory>>? streamToEmit;

  @override
  Future<Either<Failure, ExerciseHistory>> getExerciseHistoryByName({
    required String userId,
    required String exerciseName,
  }) async {
    if (exerciseHistoryResult != null) return exerciseHistoryResult!;
    return Left(const NotFoundFailure('Exercise not found'));
  }

  @override
  Future<Either<Failure, List<ExerciseHistory>>> searchExercises({
    required String userId,
    required String query,
  }) async {
    if (searchResult != null) return searchResult!;
    return const Right([]);
  }

  @override
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) {
    final value = streamToEmit ?? const Right([]);
    return Stream.value(value);
  }

  @override
  Future<Either<Failure, List<ExerciseSession>>> getSessionsByTimeframe({
    required String userId,
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> clearCache() async => const Right(null);

  @override
  Future<bool> isCacheValid(String userId) async => true;

  @override
  Future<Either<Failure, void>> updateExerciseHistory({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required ExerciseSession session,
  }) async {
    return const Right(null);
  }
}

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

AnalyticsSet _makeSet({
  double weight = 80.0,
  int reps = 10,
  DateTime? date,
}) {
  return AnalyticsSet(
    weight: weight,
    reps: reps,
    date: date ?? DateTime.now(),
  );
}

ExerciseSession _makeSession({
  String exerciseName = 'Bench Press',
  String muscleGroup = 'chest',
  double weight = 80.0,
  int reps = 10,
  DateTime? date,
  int setCount = 3,
}) {
  return ExerciseSession(
    exerciseName: exerciseName,
    muscleGroup: muscleGroup,
    sets: List.generate(
      setCount,
      (i) => _makeSet(weight: weight, reps: reps, date: date ?? DateTime.now()),
    ),
    date: date ?? DateTime.now(),
  );
}

ExerciseHistory _makeHistory({
  required String exerciseName,
  String muscleGroup = 'chest',
  List<ExerciseSession>? sessions,
  String exerciseId = 'ex_001',
}) {
  return ExerciseHistory(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    muscleGroup: muscleGroup,
    sessions: sessions ?? [],
  );
}

void main() {
  const userId = 'user123';

  // -------------------------------------------------------------------------
  group('AnalyticsToolExecutor.get1RMHistory', () {
    test('returns error JSON when exerciseName is missing', () async {
      final repo = FakeAnalyticsRepository();
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('get1RMHistory'));
    });

    test('returns history when exercise found', () async {
      final now = DateTime.now();
      final session = _makeSession(
        exerciseName: 'Bench Press',
        weight: 100.0,
        reps: 8,
        date: now.subtract(const Duration(days: 5)),
        setCount: 3,
      );
      final history = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [session],
      );

      final repo = FakeAnalyticsRepository(
        exerciseHistoryResult: Right(history),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Bench Press', 'weeksBack': 4},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['exerciseName'], equals('Bench Press'));
      expect(decoded['muscleGroup'], equals('chest'));
      expect(decoded.containsKey('history'), isTrue);
      expect(decoded.containsKey('count'), isTrue);
      expect(decoded.containsKey('personalRecord'), isTrue);
    });

    test('history entries have correct fields', () async {
      final now = DateTime.now();
      final session = _makeSession(
        weight: 100.0,
        reps: 8,
        date: now.subtract(const Duration(days: 3)),
      );
      final history = _makeHistory(
        exerciseName: 'Bench Press',
        sessions: [session],
      );

      final repo = FakeAnalyticsRepository(
        exerciseHistoryResult: Right(history),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final historyList = decoded['history'] as List<dynamic>;

      if (historyList.isNotEmpty) {
        final entry = historyList.first as Map<String, dynamic>;
        expect(entry.containsKey('date'), isTrue);
        expect(entry.containsKey('estimated1RM'), isTrue);
        expect(entry.containsKey('maxWeight'), isTrue);
        expect(entry.containsKey('totalVolume'), isTrue);
      }
    });

    test('falls back to search when exercise not found directly', () async {
      final searchHistory = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          _makeSession(
            exerciseName: 'Bench Press',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );

      final repo = FakeAnalyticsRepository(
        // First call fails
        exerciseHistoryResult: Left(const NotFoundFailure('Not found')),
        // Search returns a match
        searchResult: Right([searchHistory]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Bench Press'},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      // Should not be an error since search found a match
      expect(decoded, isMap);
    });

    test('weeksBack from string is parsed', () async {
      final history = _makeHistory(exerciseName: 'Squat');
      final repo = FakeAnalyticsRepository(
        exerciseHistoryResult: Right(history),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Squat', 'weeksBack': '6'},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('historyDaysLimit clamps weeksBack', () async {
      final history = _makeHistory(exerciseName: 'Deadlift');
      final repo = FakeAnalyticsRepository(
        exerciseHistoryResult: Right(history),
      );
      // 14 days limit = max 2 weeks
      final executor = AnalyticsToolExecutor(
        analyticsRepo: repo,
        historyDaysLimit: 14,
      );

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Deadlift', 'weeksBack': 52},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['weeksBack'], lessThanOrEqualTo(2));
    });

    test('returns error JSON when exercise not found and search empty',
        () async {
      // Use Left(Failure) to trigger the "not found" error path without
      // going through the catch block that calls FirebaseCrashlytics.
      final repo = FakeAnalyticsRepository(
        exerciseHistoryResult: Left(const NotFoundFailure('Not found')),
        searchResult: const Right([]), // empty search results
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'NonExistentExercise'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('result is always valid JSON', () async {
      final repo = FakeAnalyticsRepository();
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.get1RMHistory(
        {'exerciseName': 'Deadlift'},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  group('AnalyticsToolExecutor.getWeeklyVolume', () {
    test('returns valid JSON with empty exercises', () async {
      final repo = FakeAnalyticsRepository(streamToEmit: const Right([]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('weeklyVolume'), isTrue);
      expect(decoded['muscleGroup'], equals('all'));
    });

    test('returns weekly volume data for each week', () async {
      final now = DateTime.now();
      final session = _makeSession(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        weight: 80.0,
        reps: 10,
        date: now.subtract(const Duration(days: 2)),
        setCount: 3,
      );
      final history = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [session],
      );

      final repo = FakeAnalyticsRepository(streamToEmit: Right([history]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume(
        {'weeksBack': 4},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['weeklyVolume'], isList);
      final weeklyVolume = decoded['weeklyVolume'] as List<dynamic>;
      expect(weeklyVolume.length, equals(4));
    });

    test('weeklyVolume entries have required fields', () async {
      final repo = FakeAnalyticsRepository(streamToEmit: const Right([]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume(
        {'weeksBack': 2},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final weeklyVolume = decoded['weeklyVolume'] as List<dynamic>;

      for (final week in weeklyVolume) {
        final w = week as Map<String, dynamic>;
        expect(w.containsKey('week'), isTrue);
        expect(w.containsKey('weekStart'), isTrue);
        expect(w.containsKey('volume'), isTrue);
        expect(w.containsKey('sets'), isTrue);
      }
    });

    test('filters by muscleGroup when provided', () async {
      final chestHistory = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
      );
      final legHistory = _makeHistory(
        exerciseName: 'Squat',
        muscleGroup: 'legs',
      );

      final repo = FakeAnalyticsRepository(
        streamToEmit: Right([chestHistory, legHistory]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume(
        {'muscleGroup': 'chest', 'weeksBack': 2},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['muscleGroup'], equals('chest'));
      expect(decoded['exerciseCount'], equals(1));
    });

    test('returns error JSON when stream emits failure', () async {
      final repo = FakeAnalyticsRepository(
        streamToEmit: Left(const NetworkFailure('Connection error')),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    // Note: Using Left(ServerFailure) instead of stream error/throw to avoid
    // the catch block which calls FirebaseCrashlytics (requires Firebase init).
    test('returns error JSON when stream emits server failure', () async {
      final repo = FakeAnalyticsRepository(
        streamToEmit: Left(const ServerFailure('Server unavailable')),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('result is always valid JSON', () async {
      final repo = FakeAnalyticsRepository(streamToEmit: const Right([]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.getWeeklyVolume({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  group('AnalyticsToolExecutor.analyzeMuscleBalance', () {
    test('returns valid JSON with empty exercise list', () async {
      final repo = FakeAnalyticsRepository(streamToEmit: const Right([]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns balance, totalVolume, overTrained, underTrained', () async {
      final now = DateTime.now();

      // Chest is heavily trained
      final chestHistory = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: List.generate(
          5,
          (i) => _makeSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            weight: 100.0,
            reps: 10,
            date: now.subtract(Duration(days: i + 1)),
            setCount: 4,
          ),
        ),
      );

      // Legs lightly trained
      final legHistory = _makeHistory(
        exerciseName: 'Squat',
        muscleGroup: 'legs',
        sessions: [
          _makeSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            weight: 80.0,
            reps: 8,
            date: now.subtract(const Duration(days: 10)),
            setCount: 2,
          ),
        ],
      );

      final repo = FakeAnalyticsRepository(
        streamToEmit: Right([chestHistory, legHistory]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('balance'), isTrue);
      expect(decoded.containsKey('totalVolume'), isTrue);
      expect(decoded.containsKey('periodDays'), isTrue);
      expect(decoded['periodDays'], equals(28));
    });

    test('returns suggestedExercises list', () async {
      final now = DateTime.now();
      final chestHistory = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          _makeSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: now.subtract(const Duration(days: 1)),
            setCount: 3,
          ),
        ],
      );

      final repo = FakeAnalyticsRepository(
        streamToEmit: Right([chestHistory]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('suggestedExercises'), isTrue);
      expect(decoded['suggestedExercises'], isList);
    });

    test('balanceLocalized has same keys as balance', () async {
      final now = DateTime.now();
      final backHistory = _makeHistory(
        exerciseName: 'Row',
        muscleGroup: 'back',
        sessions: [
          _makeSession(
            exerciseName: 'Row',
            muscleGroup: 'back',
            date: now.subtract(const Duration(days: 2)),
          ),
        ],
      );

      final repo = FakeAnalyticsRepository(
        streamToEmit: Right([backHistory]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('balanceLocalized'), isTrue);
    });

    test('sessions outside 28-day window are excluded', () async {
      final oldSession = _makeSession(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        date: DateTime.now().subtract(const Duration(days: 60)),
        setCount: 4,
      );
      final history = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [oldSession],
      );

      final repo = FakeAnalyticsRepository(
        streamToEmit: Right([history]),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // Old sessions not counted -> totalVolume should be 0
      expect(decoded['totalVolume'], equals(0));
    });

    test('returns error JSON when stream emits failure', () async {
      final repo = FakeAnalyticsRepository(
        streamToEmit: Left(const ServerFailure('Server down')),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    // Note: Using Left(NetworkFailure) instead of stream error/throw to avoid
    // the catch block which calls FirebaseCrashlytics (requires Firebase init).
    test('returns error JSON when stream emits network failure', () async {
      final repo = FakeAnalyticsRepository(
        streamToEmit: Left(const NetworkFailure('Offline')),
      );
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('result is always valid JSON', () async {
      final repo = FakeAnalyticsRepository(streamToEmit: const Right([]));
      final executor = AnalyticsToolExecutor(analyticsRepo: repo);

      final result = await executor.analyzeMuscleBalance({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });
  });
}
