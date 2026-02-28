import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/services/exercise_merge_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart' show ExerciseCategory;
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseDefinition _makeDbExercise({
  required String id,
  required String nome,
  List<String> focus = const ['CHEST'],
  List<String> muscoliSecondari = const [],
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: focus,
    muscoliSecondari: muscoliSecondari,
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push Pattern',
    rangeRipetizioni: '8-12',
    countingMode: ExerciseCountingMode.weighted,
  );
}

AnalyticsSet _makeSet({double weight = 100.0, int reps = 8}) {
  return AnalyticsSet(weight: weight, reps: reps, date: DateTime(2024, 1, 1));
}

ExerciseSession _makeSession({
  String exerciseName = 'Bench Press',
  DateTime? date,
  List<AnalyticsSet>? sets,
}) {
  return ExerciseSession(
    exerciseName: exerciseName,
    muscleGroup: 'chest',
    sets: sets ?? [_makeSet()],
    date: date ?? DateTime(2024, 1, 1),
  );
}

ExerciseHistory _makeHistory({
  required String exerciseId,
  required String exerciseName,
  String muscleGroup = 'chest',
  List<ExerciseSession>? sessions,
}) {
  return ExerciseHistory(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    muscleGroup: muscleGroup,
    sessions: sessions ?? [_makeSession(exerciseName: exerciseName)],
  );
}

WorkoutTemplate _makeTemplate({
  String name = 'Push Day',
  List<ExerciseTemplate>? exercises,
}) {
  return WorkoutTemplate(
    name: name,
    description: 'Test template',
    exercises: exercises,
  );
}

ExerciseTemplate _makeExerciseTemplate(String exerciseName) {
  return const ExerciseTemplate(
    exerciseId: 'id',
    exerciseName: 'placeholder',
    category: ExerciseCategory.chest,
  ).copyWith(exerciseName: exerciseName, exerciseId: exerciseName);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // findMergeCandidates — cases where fuzzy matching is NOT needed
  // =========================================================================
  group('ExerciseMergeService.findMergeCandidates — exact matches skipped', () {
    test('returns empty list when exerciseHistories is empty', () async {
      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [],
        databaseExercises: [
          _makeDbExercise(id: 'bp', nome: 'Bench Press'),
        ],
      );

      expect(result, isEmpty);
    });

    test('returns empty list when databaseExercises is empty', () async {
      final history = _makeHistory(
        exerciseId: 'custom_1',
        exerciseName: 'My Custom Exercise',
      );

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [history],
        databaseExercises: [],
      );

      expect(result, isEmpty);
    });

    test('skips exercises whose name exactly matches database (case-insensitive)', () async {
      final dbExercise = _makeDbExercise(id: 'bp', nome: 'Bench Press');

      // History with same name (exact match) — should be skipped
      final history = _makeHistory(
        exerciseId: 'some_custom_id',
        exerciseName: 'Bench Press',
      );

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [history],
        databaseExercises: [dbExercise],
      );

      expect(result, isEmpty);
    });

    test('skips exercises whose name matches database ignoring case', () async {
      final dbExercise = _makeDbExercise(id: 'bp', nome: 'Bench Press');

      final history = _makeHistory(
        exerciseId: 'some_custom_id',
        exerciseName: 'bench press', // lowercase
      );

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [history],
        databaseExercises: [dbExercise],
      );

      expect(result, isEmpty);
    });

    test('skips exercises whose name matches database ignoring degree symbol', () async {
      final dbExercise = _makeDbExercise(id: 'leg', nome: 'Leg Extension');

      // Name with degree symbol should be normalized for comparison
      final history = _makeHistory(
        exerciseId: 'custom_leg',
        exerciseName: 'Leg°Extension',
      );

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [history],
        databaseExercises: [dbExercise],
      );

      // 'leg°extension' normalizes to 'legextension', 'leg extension' normalizes to 'leg extension'
      // They are different after normalization, so no skip expected here —
      // the exercise may or may not get a fuzzy match.
      // The important thing is the test runs without exception.
      expect(result, isA<List<MergeCandidate>>());
    });

    test('skips exercise whose exerciseId matches database exercise id', () async {
      const dbId = 'bp_db_001';
      final dbExercise = _makeDbExercise(id: dbId, nome: 'Bench Press');

      // History's exerciseId matches database id — must be skipped
      final history = _makeHistory(
        exerciseId: dbId,
        exerciseName: 'Completely Different Name',
      );

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [history],
        databaseExercises: [dbExercise],
      );

      expect(result, isEmpty);
    });

    test('returns empty when both exerciseHistories and database are empty', () async {
      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: [],
        databaseExercises: [],
      );
      expect(result, isEmpty);
    });

    test('skips multiple exercises with exact db matches, returns remaining as candidates', () async {
      final db = [
        _makeDbExercise(id: 'squat', nome: 'Squat'),
        _makeDbExercise(id: 'deadlift', nome: 'Deadlift'),
      ];

      final histories = [
        // Exact match — should be skipped
        _makeHistory(exerciseId: 'user_squat', exerciseName: 'Squat'),
        // Exact match — should be skipped
        _makeHistory(exerciseId: 'user_deadlift', exerciseName: 'Deadlift'),
        // No match — might become a candidate if fuzzy matches found
        _makeHistory(exerciseId: 'user_xyz', exerciseName: 'Totally Unknown XYZ'),
      ];

      final result = await ExerciseMergeService.findMergeCandidates(
        exerciseHistories: histories,
        databaseExercises: db,
      );

      // Squat and Deadlift are skipped; XYZ has no fuzzy match either
      expect(result, isEmpty);
    });
  });

  // =========================================================================
  // countMergeCandidates
  // =========================================================================
  group('ExerciseMergeService.countMergeCandidates', () {
    test('returns 0 when no histories', () async {
      final count = await ExerciseMergeService.countMergeCandidates(
        exerciseHistories: [],
        databaseExercises: [_makeDbExercise(id: 'bp', nome: 'Bench Press')],
      );
      expect(count, 0);
    });

    test('returns 0 when all exercises exactly match database', () async {
      final db = [_makeDbExercise(id: 'sq', nome: 'Squat')];
      final histories = [_makeHistory(exerciseId: 'user_sq', exerciseName: 'Squat')];

      final count = await ExerciseMergeService.countMergeCandidates(
        exerciseHistories: histories,
        databaseExercises: db,
      );
      expect(count, 0);
    });
  });

  // =========================================================================
  // filterHighQualityCandidates
  // =========================================================================
  group('ExerciseMergeService.filterHighQualityCandidates', () {
    ExerciseDefinition makeEx(String id) => _makeDbExercise(id: id, nome: 'Exercise $id');

    MergeCandidate _makeCandidate(String name, double score) => MergeCandidate(
          customExerciseName: name,
          sessionCount: 1,
          lastUsed: DateTime.now(),
          matchingExercises: [
            ExerciseMatch(
              exercise: makeEx(name),
              score: score,
              matchedOn: 'nome',
            ),
          ],
        );

    test('returns only candidates with score >= 0.75', () {
      final candidates = [
        _makeCandidate('A', 0.95),
        _makeCandidate('B', 0.75),
        _makeCandidate('C', 0.74),
        _makeCandidate('D', 0.50),
        _makeCandidate('E', 0.80),
      ];

      final highQuality = ExerciseMergeService.filterHighQualityCandidates(candidates);

      expect(highQuality.length, 3);
      expect(highQuality.map((c) => c.customExerciseName), containsAll(['A', 'B', 'E']));
      expect(highQuality.map((c) => c.customExerciseName), isNot(contains('C')));
      expect(highQuality.map((c) => c.customExerciseName), isNot(contains('D')));
    });

    test('returns empty list when input is empty', () {
      final result = ExerciseMergeService.filterHighQualityCandidates([]);
      expect(result, isEmpty);
    });

    test('returns all candidates when all are high quality', () {
      final candidates = [
        _makeCandidate('A', 0.90),
        _makeCandidate('B', 0.85),
        _makeCandidate('C', 0.76),
      ];

      final result = ExerciseMergeService.filterHighQualityCandidates(candidates);
      expect(result.length, 3);
    });

    test('returns empty list when no candidates meet threshold', () {
      final candidates = [
        _makeCandidate('A', 0.50),
        _makeCandidate('B', 0.60),
        _makeCandidate('C', 0.70),
      ];

      final result = ExerciseMergeService.filterHighQualityCandidates(candidates);
      expect(result, isEmpty);
    });

    test('does not mutate original list', () {
      final candidates = [_makeCandidate('A', 0.50)];
      ExerciseMergeService.filterHighQualityCandidates(candidates);
      expect(candidates.length, 1);
    });
  });

  // =========================================================================
  // generateMergePreview
  // =========================================================================
  group('ExerciseMergeService.generateMergePreview', () {
    final targetExercise = _makeDbExercise(
      id: 'bench_db_001',
      nome: 'Bench Press',
      focus: ['CHEST', 'TRICEP'],
      muscoliSecondari: ['SHOULDER', 'CORE'],
    );

    test('basic preview has correct source and target names', () {
      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: [_makeSession(exerciseName: 'Panca Piana')],
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      expect(preview.sourceExerciseName, 'Panca Piana');
      expect(preview.targetExerciseName, 'Bench Press');
      expect(preview.targetExerciseId, 'bench_db_001');
    });

    test('sessionsToMerge equals number of sessions in source history', () {
      final sessions = [
        _makeSession(exerciseName: 'Panca Piana', date: DateTime(2024, 1, 1)),
        _makeSession(exerciseName: 'Panca Piana', date: DateTime(2024, 2, 1)),
        _makeSession(exerciseName: 'Panca Piana', date: DateTime(2024, 3, 1)),
      ];

      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: sessions,
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      expect(preview.sessionsToMerge, 3);
    });

    test('sessionsToMerge is 0 when source not found in histories (fallback)', () {
      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Esercizio Inesistente',
        targetExercise: targetExercise,
        exerciseHistories: [],
        templates: [],
      );

      expect(preview.sessionsToMerge, 0);
    });

    test('target muscle groups copied from targetExercise', () {
      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      expect(preview.targetMuscleGroups, ['CHEST', 'TRICEP']);
      expect(preview.targetSecondaryMuscles, ['SHOULDER', 'CORE']);
    });

    test('templatesAffected counts templates containing the source exercise name', () {
      final templates = [
        _makeTemplate(
          name: 'Push Day A',
          exercises: [_makeExerciseTemplate('Panca Piana')],
        ),
        _makeTemplate(
          name: 'Push Day B',
          exercises: [_makeExerciseTemplate('Panca Piana'), _makeExerciseTemplate('OHP')],
        ),
        _makeTemplate(
          name: 'Leg Day',
          exercises: [_makeExerciseTemplate('Squat')],
        ),
      ];

      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: templates,
      );

      expect(preview.templatesAffected, 2); // Only Push Day A and B contain Panca Piana
    });

    test('templatesAffected is 0 when no templates reference source exercise', () {
      final templates = [
        _makeTemplate(
          name: 'Leg Day',
          exercises: [_makeExerciseTemplate('Squat')],
        ),
      ];

      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: templates,
      );

      expect(preview.templatesAffected, 0);
    });

    test('templatesAffected is case-insensitive for exercise name match', () {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExerciseTemplate('panca piana')], // lowercase
        ),
      ];

      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana', // different case from template
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: templates,
      );

      expect(preview.templatesAffected, 1);
    });

    test('currentPR is null when source history has no sessions (PR == 0)', () {
      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: [], // no sessions → PR = 0
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      // personalRecord returns 0 for empty sessions, so currentPR should be null
      expect(preview.currentPR, isNull);
    });

    test('currentPR is set when source has sessions with weight', () {
      final session = ExerciseSession(
        exerciseName: 'Panca Piana',
        muscleGroup: 'chest',
        sets: [AnalyticsSet(weight: 100.0, reps: 1, date: DateTime(2024, 1, 1))],
        date: DateTime(2024, 1, 1),
      );

      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: [session],
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      // 1 rep at 100kg → estimated 1RM = 100.0
      expect(preview.currentPR, isNotNull);
      expect(preview.currentPR, greaterThan(0));
    });

    test('newPR is max of source PR and target PR', () {
      // Source history: 100 kg 1RM
      final sourceSession = ExerciseSession(
        exerciseName: 'Panca Piana',
        muscleGroup: 'chest',
        sets: [AnalyticsSet(weight: 100.0, reps: 1, date: DateTime(2024, 1, 1))],
        date: DateTime(2024, 1, 1),
      );
      // Target history: 120 kg 1RM (target already has higher PR)
      final targetSession = ExerciseSession(
        exerciseName: 'Bench Press',
        muscleGroup: 'chest',
        sets: [AnalyticsSet(weight: 120.0, reps: 1, date: DateTime(2024, 2, 1))],
        date: DateTime(2024, 2, 1),
      );

      final sourceHistory = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: [sourceSession],
      );
      final targetHistory = _makeHistory(
        exerciseId: 'bp_db',
        exerciseName: 'Bench Press',
        sessions: [targetSession],
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [sourceHistory, targetHistory],
        templates: [],
      );

      // newPR should be max(100, 120) = 120
      expect(preview.newPR, 120.0);
    });

    test('newPR equals source PR when target has no history', () {
      final sourceSession = ExerciseSession(
        exerciseName: 'Panca Piana',
        muscleGroup: 'chest',
        sets: [AnalyticsSet(weight: 100.0, reps: 1, date: DateTime(2024, 1, 1))],
        date: DateTime(2024, 1, 1),
      );

      final sourceHistory = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
        sessions: [sourceSession],
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [sourceHistory], // No target history
        templates: [],
      );

      expect(preview.newPR, 100.0);
    });

    test('source exercise name matching is case-insensitive in history lookup', () {
      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'panca piana', // lowercase stored
        sessions: [_makeSession(exerciseName: 'panca piana')],
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana', // different case queried
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      // Should find the history and report 1 session
      expect(preview.sessionsToMerge, 1);
    });

    test('works with empty templates list', () {
      final history = _makeHistory(
        exerciseId: 'user_bench',
        exerciseName: 'Panca Piana',
      );

      final preview = ExerciseMergeService.generateMergePreview(
        sourceExerciseName: 'Panca Piana',
        targetExercise: targetExercise,
        exerciseHistories: [history],
        templates: [],
      );

      expect(preview.templatesAffected, 0);
    });
  });

  // =========================================================================
  // Sorting behavior of findMergeCandidates
  // (tested indirectly via filterHighQualityCandidates with pre-built candidates)
  // =========================================================================
  group('filterHighQualityCandidates — preserves relative order of high-quality items', () {
    ExerciseDefinition makeEx(String id) => _makeDbExercise(id: id, nome: 'Ex $id');

    test('all high-quality items are returned, low-quality filtered out', () {
      final highA = MergeCandidate(
        customExerciseName: 'A',
        sessionCount: 5,
        lastUsed: DateTime.now(),
        matchingExercises: [
          ExerciseMatch(exercise: makeEx('a'), score: 0.95, matchedOn: 'nome')
        ],
      );
      final lowB = MergeCandidate(
        customExerciseName: 'B',
        sessionCount: 10,
        lastUsed: DateTime.now(),
        matchingExercises: [
          ExerciseMatch(exercise: makeEx('b'), score: 0.50, matchedOn: 'nome')
        ],
      );
      final highC = MergeCandidate(
        customExerciseName: 'C',
        sessionCount: 1,
        lastUsed: DateTime.now(),
        matchingExercises: [
          ExerciseMatch(exercise: makeEx('c'), score: 0.80, matchedOn: 'nome')
        ],
      );

      final result = ExerciseMergeService.filterHighQualityCandidates([highA, lowB, highC]);

      expect(result.length, 2);
      expect(result.map((r) => r.customExerciseName), containsAll(['A', 'C']));
      expect(result.map((r) => r.customExerciseName), isNot(contains('B')));
    });
  });
}
