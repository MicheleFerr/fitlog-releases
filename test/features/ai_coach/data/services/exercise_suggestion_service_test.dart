/// Tests for ExerciseSuggestionService
///
/// Verifies:
/// - Query length validation (< 3 chars returns empty)
/// - Question detection (queries starting with question words return empty)
/// - Sorting by session count and recency
/// - Question generation for exercises with data
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/exercise_suggestion_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late ExerciseSuggestionService service;
  late MockAnalyticsRepository mockRepo;

  setUp(() {
    mockRepo = MockAnalyticsRepository();
    service = ExerciseSuggestionService(analyticsRepository: mockRepo);
  });

  group('getSuggestions', () {
    test('returns empty list for query shorter than 3 characters', () async {
      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'ab',
      );

      expect(result, isEmpty);
      verifyNever(
        () => mockRepo.searchExercises(
          userId: any(named: 'userId'),
          query: any(named: 'query'),
        ),
      );
    });

    test('returns empty list for query that starts with question word', () async {
      final queries = [
        'qual è il mio massimale',
        'come sta andando',
        'quanto peso',
        'mostra i miei',
        'what is my',
        'how am I',
      ];

      for (final query in queries) {
        final result = await service.getSuggestions(
          userId: 'user1',
          query: query,
        );

        expect(result, isEmpty, reason: 'Query "$query" should return empty');
      }

      verifyNever(
        () => mockRepo.searchExercises(
          userId: any(named: 'userId'),
          query: any(named: 'query'),
        ),
      );
    });

    test('returns empty list when repository returns failure', () async {
      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'panca',
        ),
      ).thenAnswer((_) async => Left(CacheFailure('Test error')));

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'panca',
      );

      expect(result, isEmpty);
    });

    test('returns empty list when no exercises match', () async {
      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'xyz',
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'xyz',
      );

      expect(result, isEmpty);
    });

    test('returns suggestions sorted by session count (exercises with data first)', () async {
      final exerciseWithSessions = ExerciseHistory(
        exerciseId: 'ex1',
        exerciseName: 'Panca Piana',
        muscleGroup: 'chest',
        sessions: [
          ExerciseSession(
            exerciseName: 'Panca Piana',
            muscleGroup: 'chest',
            sets: [],
            date: DateTime.now(),
          ),
        ],
      );

      final exerciseWithoutSessions = ExerciseHistory(
        exerciseId: 'ex2',
        exerciseName: 'Panca Inclinata',
        muscleGroup: 'chest',
        sessions: [],
      );

      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'panca',
        ),
      ).thenAnswer(
        (_) async => Right([exerciseWithoutSessions, exerciseWithSessions]),
      );

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'panca',
      );

      expect(result.length, 2);
      // Exercise with sessions should be first
      expect(result[0].exerciseName, 'Panca Piana');
      expect(result[0].hasData, true);
      expect(result[1].exerciseName, 'Panca Inclinata');
      expect(result[1].hasData, false);
    });

    test('generates suggested questions for exercises with data', () async {
      final exercise = ExerciseHistory(
        exerciseId: 'ex1',
        exerciseName: 'Squat',
        muscleGroup: 'legs',
        sessions: [
          ExerciseSession(
            exerciseName: 'Squat',
            muscleGroup: 'legs',
            sets: [],
            date: DateTime.now(),
          ),
        ],
      );

      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'squat',
        ),
      ).thenAnswer((_) async => Right([exercise]));

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'squat',
      );

      expect(result.length, 1);
      expect(result[0].suggestedQuestions, isNotEmpty);
      expect(result[0].suggestedQuestions.length, 4);

      // Verify questions contain exercise name
      for (final q in result[0].suggestedQuestions) {
        expect(q.fullQuestion.contains('Squat'), true);
      }
    });

    test('does not generate questions for exercises without data', () async {
      final exercise = ExerciseHistory(
        exerciseId: 'ex1',
        exerciseName: 'Deadlift',
        muscleGroup: 'back',
        sessions: [],
      );

      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'deadlift',
        ),
      ).thenAnswer((_) async => Right([exercise]));

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'deadlift',
      );

      expect(result.length, 1);
      expect(result[0].suggestedQuestions, isEmpty);
      expect(result[0].hasData, false);
    });

    test('respects maxResults parameter', () async {
      final exercises = List.generate(
        10,
        (i) => ExerciseHistory(
          exerciseId: 'ex$i',
          exerciseName: 'Exercise $i',
          muscleGroup: 'test',
          sessions: [],
        ),
      );

      when(
        () => mockRepo.searchExercises(
          userId: 'user1',
          query: 'exercise',
        ),
      ).thenAnswer((_) async => Right(exercises));

      final result = await service.getSuggestions(
        userId: 'user1',
        query: 'exercise',
        maxResults: 3,
      );

      expect(result.length, 3);
    });
  });
}
