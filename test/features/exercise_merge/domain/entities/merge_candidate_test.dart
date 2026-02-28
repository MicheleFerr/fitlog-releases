import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseDefinition _makeExercise({
  String id = 'ex1',
  String nome = 'Bench Press',
  List<String> focus = const ['CHEST'],
  List<String> muscoliSecondari = const ['TRICEP'],
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

ExerciseMatch _makeMatch({
  double score = 0.9,
  String matchedOn = 'nome',
  ExerciseDefinition? exercise,
}) {
  return ExerciseMatch(
    exercise: exercise ?? _makeExercise(),
    score: score,
    matchedOn: matchedOn,
  );
}

// ---------------------------------------------------------------------------
// Tests: ExerciseMatch
// ---------------------------------------------------------------------------

void main() {
  group('ExerciseMatch', () {
    test('stores exercise, score, and matchedOn', () {
      final ex = _makeExercise();
      final match = ExerciseMatch(
        exercise: ex,
        score: 0.85,
        matchedOn: 'nome',
      );

      expect(match.exercise, same(ex));
      expect(match.score, 0.85);
      expect(match.matchedOn, 'nome');
    });

    test('scorePercentage rounds to nearest integer string', () {
      expect(_makeMatch(score: 1.0).scorePercentage, '100%');
      expect(_makeMatch(score: 0.0).scorePercentage, '0%');
      expect(_makeMatch(score: 0.856).scorePercentage, '86%');
      expect(_makeMatch(score: 0.751).scorePercentage, '75%');
    });

    test('toString returns formatted string', () {
      final match = _makeMatch(score: 0.9);
      final str = match.toString();
      expect(str, contains('Bench Press'));
      expect(str, contains('90%'));
    });
  });

  // -------------------------------------------------------------------------
  // Tests: MergeCandidate
  // -------------------------------------------------------------------------

  group('MergeCandidate — constructor and stored fields', () {
    test('stores all required fields correctly', () {
      final lastUsed = DateTime(2025, 6, 1);
      final matches = [_makeMatch(score: 0.88)];

      final candidate = MergeCandidate(
        customExerciseName: 'Panca Piana',
        sessionCount: 12,
        lastUsed: lastUsed,
        matchingExercises: matches,
        personalRecord: 120.0,
      );

      expect(candidate.customExerciseName, 'Panca Piana');
      expect(candidate.sessionCount, 12);
      expect(candidate.lastUsed, lastUsed);
      expect(candidate.matchingExercises, matches);
      expect(candidate.personalRecord, 120.0);
    });

    test('personalRecord is optional (defaults to null)', () {
      final candidate = MergeCandidate(
        customExerciseName: 'Squat',
        sessionCount: 5,
        lastUsed: DateTime.now(),
        matchingExercises: [],
      );

      expect(candidate.personalRecord, isNull);
    });
  });

  group('MergeCandidate.bestMatchScore', () {
    test('returns first match score when list is non-empty', () {
      final matches = [
        _makeMatch(score: 0.95),
        _makeMatch(score: 0.70),
        _makeMatch(score: 0.55),
      ];
      final candidate = MergeCandidate(
        customExerciseName: 'Ex',
        sessionCount: 1,
        lastUsed: DateTime.now(),
        matchingExercises: matches,
      );

      expect(candidate.bestMatchScore, 0.95);
    });

    test('returns 0.0 when matchingExercises is empty', () {
      final candidate = MergeCandidate(
        customExerciseName: 'Unknown',
        sessionCount: 0,
        lastUsed: DateTime.now(),
        matchingExercises: [],
      );

      expect(candidate.bestMatchScore, 0.0);
    });
  });

  group('MergeCandidate.hasHighQualityMatch', () {
    test('returns true when bestMatchScore >= 0.75', () {
      for (final score in [0.75, 0.80, 0.95, 1.0]) {
        final candidate = MergeCandidate(
          customExerciseName: 'Ex',
          sessionCount: 1,
          lastUsed: DateTime.now(),
          matchingExercises: [_makeMatch(score: score)],
        );
        expect(candidate.hasHighQualityMatch, isTrue,
            reason: 'score=$score should be high quality');
      }
    });

    test('returns false when bestMatchScore < 0.75', () {
      for (final score in [0.0, 0.50, 0.74, 0.749]) {
        final candidate = MergeCandidate(
          customExerciseName: 'Ex',
          sessionCount: 1,
          lastUsed: DateTime.now(),
          matchingExercises: [_makeMatch(score: score)],
        );
        expect(candidate.hasHighQualityMatch, isFalse,
            reason: 'score=$score should NOT be high quality');
      }
    });

    test('returns false when no matching exercises', () {
      final candidate = MergeCandidate(
        customExerciseName: 'Ex',
        sessionCount: 0,
        lastUsed: DateTime.now(),
        matchingExercises: [],
      );

      expect(candidate.hasHighQualityMatch, isFalse);
    });
  });

  group('MergeCandidate.toString', () {
    test('includes custom exercise name and match count', () {
      final matches = [_makeMatch(), _makeMatch()];
      final candidate = MergeCandidate(
        customExerciseName: 'Curl Bicipiti',
        sessionCount: 3,
        lastUsed: DateTime.now(),
        matchingExercises: matches,
      );

      final str = candidate.toString();
      expect(str, contains('Curl Bicipiti'));
      expect(str, contains('2'));
    });
  });

  group('MergeCandidate — boundary: only one match at exact threshold', () {
    test('exactly 0.75 is considered high quality', () {
      final candidate = MergeCandidate(
        customExerciseName: 'Borderline',
        sessionCount: 1,
        lastUsed: DateTime.now(),
        matchingExercises: [_makeMatch(score: 0.75)],
      );
      expect(candidate.hasHighQualityMatch, isTrue);
    });

    test('just below 0.75 is NOT high quality', () {
      final candidate = MergeCandidate(
        customExerciseName: 'Borderline',
        sessionCount: 1,
        lastUsed: DateTime.now(),
        matchingExercises: [_makeMatch(score: 0.7499)],
      );
      expect(candidate.hasHighQualityMatch, isFalse);
    });
  });
}
