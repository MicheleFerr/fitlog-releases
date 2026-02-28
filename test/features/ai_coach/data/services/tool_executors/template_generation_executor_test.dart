/// Unit tests for TemplateGenerationExecutor
///
/// Tests JSON validity, exercise filtering, difficulty mapping,
/// and error handling for generateTemplate.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_generation_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Mock using mocktail
// ---------------------------------------------------------------------------

class MockExerciseSearchService extends Mock implements ExerciseSearchService {}

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

ExerciseDefinitionTemplate _makeExerciseDef({
  required String name,
  required String equipment,
  ExerciseCategory category = ExerciseCategory.chest,
  List<String>? muscles,
}) {
  return ExerciseDefinitionTemplate(
    id: 'id_$name',
    name: name,
    description: 'desc',
    category: category,
    type: ExerciseType.single,
    muscleGroups: muscles ?? ['petto'],
    equipment: [equipment],
    isActive: true,
  );
}

List<ExerciseDefinitionTemplate> _buildChestExercises() {
  return [
    _makeExerciseDef(name: 'Panca Piana', equipment: 'bilanciere'),
    _makeExerciseDef(name: 'Panca Inclinata', equipment: 'bilanciere'),
    _makeExerciseDef(name: 'Croci ai cavi', equipment: 'cavi'),
    _makeExerciseDef(name: 'Chest Press', equipment: 'macchina'),
    _makeExerciseDef(name: 'Push Up', equipment: 'corpo libero'),
    _makeExerciseDef(name: 'Dips', equipment: 'corpo libero'),
  ];
}

void main() {
  late MockExerciseSearchService mockSearch;
  const userId = 'user123';

  setUp(() {
    mockSearch = MockExerciseSearchService();
  });

  // Stub helper: return the given list for any searchExercises call
  void _stubSearch(List<ExerciseDefinitionTemplate> exercises) {
    when(
      () => mockSearch.searchExercises(any(), any()),
    ).thenAnswer((_) async => exercises);
  }

  // -------------------------------------------------------------------------
  group('TemplateGenerationExecutor.generateTemplate', () {
    test('returns valid JSON on minimal args', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns templateName, muscleGroup, difficulty keys', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'intermediate'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['templateName'], isNotNull);
      expect(decoded['muscleGroup'], equals('chest'));
      expect(decoded['difficulty'], equals('intermediate'));
      expect(decoded['exercises'], isList);
      expect(decoded['exerciseCount'], isA<int>());
      expect(decoded['estimatedDuration'], isA<int>());
    });

    test('beginner difficulty produces 3 exercises and 90s rest', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'beginner'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      expect(decoded['difficulty'], equals('beginner'));
      expect(exercises.length, equals(3));
      for (final ex in exercises) {
        final map = ex as Map<String, dynamic>;
        expect(map['restSeconds'], equals(90));
        expect(map['reps'], equals('10-12'));
        expect(map['sets'], equals(3));
      }
    });

    test('intermediate difficulty produces 5 exercises and 75s rest', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'legs', 'difficulty': 'intermediate'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      expect(exercises.length, equals(5));
      for (final ex in exercises) {
        final map = ex as Map<String, dynamic>;
        expect(map['restSeconds'], equals(75));
        expect(map['sets'], equals(4));
      }
    });

    test('advanced difficulty produces 6 exercises and 60s rest', () async {
      _stubSearch([
        ..._buildChestExercises(),
        _makeExerciseDef(name: 'Decline Press', equipment: 'bilanciere'),
      ]);
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'advanced'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      expect(exercises.length, equals(6));
      for (final ex in exercises) {
        final map = ex as Map<String, dynamic>;
        expect(map['restSeconds'], equals(60));
        expect(map['reps'], equals('6-10'));
      }
    });

    test('equipment filter "bodyweight" includes only matching exercises',
        () async {
      _stubSearch([
        _makeExerciseDef(name: 'Push Up', equipment: 'corpo libero'),
        _makeExerciseDef(name: 'Dips', equipment: 'bodyweight'),
        _makeExerciseDef(
            name: 'Panca Piana', equipment: 'bilanciere'), // excluded
      ]);
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {
          'muscleGroup': 'chest',
          'difficulty': 'beginner',
          'equipment': 'bodyweight',
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      // Only 2 bodyweight exercises available, beginner needs 3
      expect(exercises.length, lessThanOrEqualTo(2));
    });

    test('equipment filter "all" does not filter exercises', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {
          'muscleGroup': 'chest',
          'difficulty': 'intermediate',
          'equipment': 'all',
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      expect(exercises.length, equals(5)); // intermediate = 5 exercises
    });

    test('generates correct template name for known muscle group', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'beginner'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['templateName'], contains('Petto'));
      expect(decoded['templateName'], contains('Principiante'));
    });

    test('generates template name for full_body', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'full_body', 'difficulty': 'intermediate'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['templateName'], contains('Full Body'));
      expect(decoded['templateName'], contains('Intermedio'));
    });

    test('durationMinutes as string is parsed correctly', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'durationMinutes': '60'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['requestedDuration'], equals(60));
    });

    test('durationMinutes as int is used correctly', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'back', 'durationMinutes': 45},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['requestedDuration'], equals(45));
    });

    test('empty results returns valid JSON with exerciseCount 0', () async {
      // Verifies the zero-exercises path (no-throw, no Firebase needed).
      // The "search throws" path would require Firebase Crashlytics init.
      _stubSearch([]);
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'advanced'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(() => jsonDecode(result), returnsNormally);
      expect(decoded['exerciseCount'], equals(0));
    });

    test('each exercise entry has required fields', () async {
      _stubSearch(_buildChestExercises());
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'intermediate'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exercises = decoded['exercises'] as List<dynamic>;

      for (final rawEx in exercises) {
        final ex = rawEx as Map<String, dynamic>;
        expect(ex.containsKey('name'), isTrue);
        expect(ex.containsKey('category'), isTrue);
        expect(ex.containsKey('muscles'), isTrue);
        expect(ex.containsKey('sets'), isTrue);
        expect(ex.containsKey('reps'), isTrue);
        expect(ex.containsKey('restSeconds'), isTrue);
      }
    });

    test('no exercises available still returns valid JSON', () async {
      _stubSearch([]);
      final executor = TemplateGenerationExecutor(
        exerciseSearchService: mockSearch,
      );

      final result = await executor.generateTemplate(
        {'muscleGroup': 'chest', 'difficulty': 'intermediate'},
        userId,
      );
      expect(() => jsonDecode(result), returnsNormally);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['exerciseCount'], equals(0));
    });
  });
}
