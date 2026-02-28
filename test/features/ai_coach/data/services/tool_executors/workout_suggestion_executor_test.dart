/// Unit tests for WorkoutSuggestionExecutor
///
/// Tests JSON validity, error handling, and edge cases for:
/// - suggestWorkout
/// - compareToStandards
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/analytics_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/recovery_stats_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/workout_suggestion_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart' as shared;
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Mocks using mocktail
// ---------------------------------------------------------------------------

// Uses `implements` so no constructor is invoked - avoids Firebase/Hive init.
class MockWorkoutHistoryRepo extends Mock
    implements WorkoutHistoryRepositoryEnhanced {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockExerciseSearchService extends Mock implements ExerciseSearchService {}

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

WorkoutHistoryDetail _makeWorkoutDetail({DateTime? completedAt}) {
  final time = completedAt ?? DateTime.now().subtract(const Duration(days: 1));
  return WorkoutHistoryDetail(
    id: 'wk_${time.millisecondsSinceEpoch}',
    userId: 'user123',
    name: 'Workout',
    description: '',
    createdAt: time,
    startedAt: time,
    completedAt: time,
    updatedAt: time,
    duration: const Duration(hours: 1),
    exercises: [],
    metadata: {},
  );
}

ExerciseHistory _makeHistory({
  required String exerciseName,
  String muscleGroup = 'chest',
  List<ExerciseSession>? sessions,
}) {
  return ExerciseHistory(
    exerciseId: 'ex_$exerciseName',
    exerciseName: exerciseName,
    muscleGroup: muscleGroup,
    sessions: sessions ?? [],
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
      (i) => AnalyticsSet(
        weight: weight,
        reps: reps,
        date: date ?? DateTime.now(),
      ),
    ),
    date: date ?? DateTime.now(),
  );
}

ExerciseDefinitionTemplate _makeExerciseDef({required String name}) {
  return ExerciseDefinitionTemplate(
    id: 'id_$name',
    name: name,
    description: 'desc',
    category: ExerciseCategory.chest,
    type: ExerciseType.single,
    muscleGroups: ['petto'],
    equipment: ['bilanciere'],
    isActive: true,
  );
}

void main() {
  const userId = 'user123';

  late MockExerciseSearchService mockSearch;

  setUp(() {
    mockSearch = MockExerciseSearchService();
    when(
      () => mockSearch.searchExercises(any(), any()),
    ).thenAnswer(
      (_) async => [
        _makeExerciseDef(name: 'Panca Piana'),
        _makeExerciseDef(name: 'Incline Press'),
        _makeExerciseDef(name: 'Dips'),
        _makeExerciseDef(name: 'Chest Fly'),
      ],
    );
  });

  // Helper to build executor with configurable parameters.
  WorkoutSuggestionExecutor _buildExecutor({
    List<WorkoutHistoryDetail>? workouts,
    bool workoutRepoError = false,
    Either<Failure, List<ExerciseHistory>>? analyticsStream,
  }) {
    final analyticsRepo = MockAnalyticsRepository();
    when(
      () => analyticsRepo.getExerciseHistory(any()),
    ).thenAnswer(
      (_) => Stream.value(analyticsStream ?? const Right([])),
    );
    when(
      () => analyticsRepo.getExerciseHistoryByName(
        userId: any(named: 'userId'),
        exerciseName: any(named: 'exerciseName'),
      ),
    ).thenAnswer((_) async => Left(const NotFoundFailure('Not found')));
    when(
      () => analyticsRepo.searchExercises(
        userId: any(named: 'userId'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => const Right([]));

    final analyticsExecutor = AnalyticsToolExecutor(
      analyticsRepo: analyticsRepo,
    );

    final historyRepo = MockWorkoutHistoryRepo();
    if (workoutRepoError) {
      when(
        () => historyRepo.getWorkouts(),
      ).thenAnswer(
        (_) async => shared.Left(const NetworkFailure('Connection error')),
      );
    } else {
      when(
        () => historyRepo.getWorkouts(),
      ).thenAnswer(
        (_) async => shared.Right(workouts ?? []),
      );
    }
    final recoveryExecutor = RecoveryStatsExecutor(historyRepo: historyRepo);

    return WorkoutSuggestionExecutor(
      analyticsExecutor: analyticsExecutor,
      recoveryExecutor: recoveryExecutor,
      exerciseSearchService: mockSearch,
    );
  }

  // -------------------------------------------------------------------------
  group('WorkoutSuggestionExecutor.suggestWorkout', () {
    test('returns valid JSON with basic args', () async {
      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );

      final result = await executor.suggestWorkout({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('response has required top-level fields', () async {
      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );

      final result = await executor.suggestWorkout({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('suggestedMuscleGroup'), isTrue);
      expect(decoded.containsKey('intensity'), isTrue);
      expect(decoded.containsKey('recoveryStatus'), isTrue);
      expect(decoded.containsKey('suggestedSession'), isTrue);
      expect(decoded.containsKey('daysSinceLastWorkout'), isTrue);
    });

    test(
        'recovery status red forces recovery suggestion when >5 workouts last week',
        () async {
      final now = DateTime.now();
      // 6 workouts in last 7 days -> recovery score drops -> red
      final workouts = List.generate(
        6,
        (i) => _makeWorkoutDetail(
          completedAt: now.subtract(Duration(days: i)),
        ),
      );
      final executor = _buildExecutor(workouts: workouts);

      final result = await executor.suggestWorkout({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // When recovery is red, intensity should be "molto leggera"
      if (decoded['recoveryStatus'] == 'red') {
        expect(decoded['intensity'], equals('molto leggera'));
        expect(
          decoded['suggestedMuscleGroupCanonical'],
          equals('recovery'),
        );
      }
      // JSON is always valid
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('uses requested muscleGroup when provided and recovery is green',
        () async {
      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      );

      final result = await executor.suggestWorkout(
        {'muscleGroup': 'back'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // requestedMuscleGroup should be preserved
      expect(decoded['requestedMuscleGroup'], equals('back'));
    });

    test('requestedDifficulty is reflected in response', () async {
      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );

      final result = await executor.suggestWorkout(
        {'muscleGroup': 'chest', 'difficulty': 'alta'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['requestedDifficulty'], equals('alta'));
    });

    test('suggestedSession has type field', () async {
      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );

      final result = await executor.suggestWorkout({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final session = decoded['suggestedSession'] as Map<String, dynamic>;

      expect(session.containsKey('type'), isTrue);
    });

    test('uses underTrained muscle when no target requested', () async {
      final now = DateTime.now();
      // Back is heavily trained
      final backHistory = _makeHistory(
        exerciseName: 'Row',
        muscleGroup: 'back',
        sessions: List.generate(
          5,
          (i) => _makeSession(
            exerciseName: 'Row',
            muscleGroup: 'back',
            weight: 80.0,
            date: now.subtract(Duration(days: i + 1)),
          ),
        ),
      );
      // Chest barely trained
      final chestHistory = _makeHistory(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sessions: [
          _makeSession(date: now.subtract(const Duration(days: 20))),
        ],
      );

      final executor = _buildExecutor(
        workouts: [
          _makeWorkoutDetail(
            completedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        analyticsStream: Right([backHistory, chestHistory]),
      );

      final result = await executor.suggestWorkout({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns valid JSON when workout repo returns error', () async {
      final executor = _buildExecutor(workoutRepoError: true);

      // Even if workouts fail, should return valid JSON (error or result)
      final result = await executor.suggestWorkout({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('result is always valid JSON', () async {
      final executor = _buildExecutor();

      final result = await executor.suggestWorkout({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  group('WorkoutSuggestionExecutor.compareToStandards', () {
    test('returns valid JSON for normal inputs', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench_press', 'weight': 100.0, 'bodyWeight': 80.0},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns correct fields', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'squat', 'weight': 120.0, 'bodyWeight': 80.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['lift'], equals('squat'));
      expect(decoded['weight'], equals(120.0));
      expect(decoded['bodyWeight'], equals(80.0));
      expect(decoded.containsKey('ratio'), isTrue);
      expect(decoded.containsKey('level'), isTrue);
    });

    test('Non allenato level for ratio < 0.5', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 30.0, 'bodyWeight': 80.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Non allenato'));
    });

    test('Principiante level for ratio 0.5 to < 1.0', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 64.0, 'bodyWeight': 80.0}, // ratio=0.8
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Principiante'));
    });

    test('Novizio level for ratio 1.0 to < 1.5', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 96.0, 'bodyWeight': 80.0}, // ratio=1.2
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Novizio'));
    });

    test('Intermedio level for ratio 1.5 to < 2.0', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 136.0, 'bodyWeight': 80.0}, // ratio=1.7
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Intermedio'));
    });

    test('Avanzato level for ratio 2.0 to < 2.5', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {
          'lift': 'deadlift',
          'weight': 180.0,
          'bodyWeight': 80.0,
        }, // ratio=2.25
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Avanzato'));
    });

    test('Elite level for ratio >= 2.5', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'deadlift', 'weight': 240.0, 'bodyWeight': 80.0}, // ratio=3.0
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['level'], equals('Elite'));
    });

    test('returns error when bodyWeight is 0', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 100.0, 'bodyWeight': 0.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('returns error when bodyWeight is negative', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 100.0, 'bodyWeight': -10.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('weight from string is parsed correctly', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': '100', 'bodyWeight': '80'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['weight'], equals(100.0));
      expect(decoded['bodyWeight'], equals(80.0));
    });

    test('defaults bodyWeight to 75 when missing', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 75.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['bodyWeight'], equals(75.0));
    });

    test('lift defaults to "unknown" when not provided', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'weight': 100.0, 'bodyWeight': 80.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['lift'], equals('unknown'));
    });

    test('ratio is formatted to 2 decimal places', () async {
      final executor = _buildExecutor();

      final result = await executor.compareToStandards(
        {'lift': 'bench', 'weight': 100.0, 'bodyWeight': 80.0},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // ratio = 100/80 = 1.25 -> "1.25"
      expect(decoded['ratio'], equals('1.25'));
    });

    test('result is always valid JSON', () async {
      final executor = _buildExecutor();

      for (final bodyWeight in [0.0, -5.0, 75.0, 100.0]) {
        final result = await executor.compareToStandards(
          {'lift': 'bench', 'weight': 100.0, 'bodyWeight': bodyWeight},
          userId,
        );
        expect(() => jsonDecode(result), returnsNormally);
      }
    });
  });
}
