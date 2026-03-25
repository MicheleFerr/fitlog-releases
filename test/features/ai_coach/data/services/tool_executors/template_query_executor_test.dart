/// Unit tests for TemplateQueryExecutor
///
/// Tests JSON validity, error handling, and edge cases for
/// getUserTemplates and getTemplateDetails methods.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_query_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Mocks using mocktail
// ---------------------------------------------------------------------------

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockExerciseSearchService extends Mock implements ExerciseSearchService {}

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

ExerciseSet _makeSet({int? reps, double? weight}) {
  return ExerciseSet(setNumber: 1, reps: reps ?? 10, weight: weight ?? 80.0);
}

Exercise _makeExercise({
  required String name,
  ExerciseCategory category = ExerciseCategory.chest,
  int setCount = 3,
}) {
  return Exercise(
    name: name,
    category: category,
    type: ExerciseType.single,
    sets: List.generate(setCount, (i) => _makeSet()),
  );
}

// ignore: deprecated_member_use
CommunityWorkoutTemplate _makeTemplate({
  required String name,
  TemplateCategory category = TemplateCategory.strength,
  List<Exercise>? exercises,
  int? estimatedDurationMinutes,
  String? difficultyLevel,
  List<String> targetMuscles = const [],
}) {
  // ignore: deprecated_member_use
  return CommunityWorkoutTemplate(
    id: 'id_$name',
    userId: 'user123',
    name: name,
    exercises: exercises ?? [_makeExercise(name: 'Bench Press')],
    category: category,
    createdAt: DateTime(2025, 1, 1),
    estimatedDurationMinutes: estimatedDurationMinutes,
    difficultyLevel: difficultyLevel,
    targetMuscles: targetMuscles,
  );
}

void main() {
  late MockTemplateRepository mockRepo;
  late MockExerciseSearchService mockSearchService;
  const userId = 'user123';

  setUp(() {
    mockRepo = MockTemplateRepository();
    mockSearchService = MockExerciseSearchService();
  });

  // -------------------------------------------------------------------------
  group('TemplateQueryExecutor.getUserTemplates', () {
    test('returns valid JSON with empty message when no templates', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getUserTemplates({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['message'], isNotNull);
      expect(decoded['count'], equals(0));
    });

    test(
      'returns valid JSON with template list when templates exist',
      () async {
        final templates = [
          _makeTemplate(
            name: 'Push Day',
            exercises: [
              _makeExercise(
                name: 'Bench Press',
                category: ExerciseCategory.chest,
                setCount: 4,
              ),
              _makeExercise(
                name: 'Military Press',
                category: ExerciseCategory.shoulders,
                setCount: 3,
              ),
            ],
            targetMuscles: ['chest', 'shoulders'],
          ),
          _makeTemplate(
            name: 'Leg Day',
            exercises: [
              _makeExercise(
                name: 'Squat',
                category: ExerciseCategory.legs,
                setCount: 5,
              ),
            ],
          ),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = TemplateQueryExecutor(
          templateRepo: mockRepo,
          exerciseSearchService: mockSearchService,
        );

        final result = await executor.getUserTemplates({}, userId);
        final decoded = jsonDecode(result) as Map<String, dynamic>;

        expect(decoded['templates'], isList);
        expect(decoded['count'], equals(2));
        expect(decoded['showing'], greaterThan(0));
        expect(decoded['aggregateBalanceAllTemplates'], isMap);
      },
    );

    test('filters by category when category arg is provided', () async {
      final templates = [
        _makeTemplate(
          name: 'My Strength Template',
          category: TemplateCategory.strength,
        ),
        _makeTemplate(
          name: 'My Cardio Template',
          category: TemplateCategory.cardio,
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getUserTemplates({
        'category': 'strength',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // Total count reflects all templates
      expect(decoded['count'], equals(2));
      // Templates list contains only filtered ones
      final templateList = decoded['templates'] as List<dynamic>;
      for (final t in templateList) {
        expect(
          (t as Map<String, dynamic>)['category'].toString().toLowerCase(),
          equals('strength'),
        );
      }
    });

    test(
      'returns no-match message when category filter yields empty result',
      () async {
        final templates = [
          _makeTemplate(name: 'Push Day', category: TemplateCategory.strength),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = TemplateQueryExecutor(
          templateRepo: mockRepo,
          exerciseSearchService: mockSearchService,
        );

        final result = await executor.getUserTemplates({
          'category': 'cardio',
        }, userId);
        final decoded = jsonDecode(result) as Map<String, dynamic>;

        expect(decoded['count'], equals(0));
        expect(decoded['message'], isNotNull);
        expect(decoded['availableCategories'], isList);
      },
    );

    test('returns count 0 when repository returns empty list', () async {
      // Verifies the empty-result error path (no-throw, no Firebase needed).
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getUserTemplates({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['count'], equals(0));
      expect(decoded['message'], isNotNull);
    });

    test('result is always valid JSON', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer(
        (_) async => [
          _makeTemplate(name: 'Alpha'),
          _makeTemplate(name: 'Beta'),
        ],
      );
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getUserTemplates({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test(
      'setDistribution and primaryFocus fields are present per template',
      () async {
        final templates = [
          _makeTemplate(
            name: 'Chest Day',
            exercises: [
              _makeExercise(
                name: 'Panca',
                category: ExerciseCategory.chest,
                setCount: 4,
              ),
            ],
          ),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = TemplateQueryExecutor(
          templateRepo: mockRepo,
          exerciseSearchService: mockSearchService,
        );

        final result = await executor.getUserTemplates({}, userId);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final templateList = decoded['templates'] as List<dynamic>;

        expect(templateList, hasLength(1));
        final template = templateList.first as Map<String, dynamic>;
        expect(template['setDistribution'], isMap);
        expect(template['primaryFocus'], isList);
        expect(template['totalSets'], equals(4));
      },
    );

    test(
      'splitDetected true when templates have upper and lower names',
      () async {
        final templates = [
          _makeTemplate(name: 'Upper Push'),
          _makeTemplate(name: 'Lower Legs'),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = TemplateQueryExecutor(
          templateRepo: mockRepo,
          exerciseSearchService: mockSearchService,
        );

        final result = await executor.getUserTemplates({}, userId);
        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final framework = decoded['analysisFramework'] as Map<String, dynamic>;

        expect(framework['splitDetected'], isTrue);
      },
    );

    test('aggregateBalanceAllTemplates has upperLowerRatio field', () async {
      final templates = [
        _makeTemplate(
          name: 'Upper Day',
          exercises: [
            _makeExercise(
              name: 'Bench Press',
              category: ExerciseCategory.chest,
              setCount: 4,
            ),
          ],
        ),
        _makeTemplate(
          name: 'Leg Day',
          exercises: [
            _makeExercise(
              name: 'Squat',
              category: ExerciseCategory.legs,
              setCount: 4,
            ),
          ],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getUserTemplates({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final aggregate =
          decoded['aggregateBalanceAllTemplates'] as Map<String, dynamic>;

      expect(aggregate.containsKey('upperLowerStatus'), isTrue);
      expect(aggregate.containsKey('totalSets'), isTrue);
      expect(aggregate.containsKey('setDistribution'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('TemplateQueryExecutor.getTemplateDetails', () {
    test('returns disambiguation when templateName is null', () async {
      final templates = [
        _makeTemplate(name: 'Chest Day'),
        _makeTemplate(name: 'Leg Day'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(
        decoded.containsKey('disambiguation') || decoded.containsKey('error'),
        isTrue,
      );
    });

    test('returns error when templateName is empty string', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': '',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('returns full details for exact template name match', () async {
      final exercises = [
        _makeExercise(
          name: 'Bench Press',
          category: ExerciseCategory.chest,
          setCount: 4,
        ),
        _makeExercise(
          name: 'Squat',
          category: ExerciseCategory.legs,
          setCount: 3,
        ),
      ];
      final templates = [
        _makeTemplate(
          name: 'Full Body Alpha',
          exercises: exercises,
          estimatedDurationMinutes: 60,
          difficultyLevel: 'intermediate',
          targetMuscles: ['chest', 'legs'],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'Full Body Alpha',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['templateName'], equals('Full Body Alpha'));
      expect(decoded['exerciseCount'], equals(2));
      expect(decoded['totalSets'], equals(7));
      expect(decoded['estimatedDuration'], equals(60));
      expect(decoded['exercises'], isList);
      expect(decoded['setDistribution'], isMap);
      expect(decoded['primaryFocus'], isList);
    });

    test('returns details for partial name match (case-insensitive)', () async {
      final templates = [_makeTemplate(name: 'Upper Body Push')];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'upper body',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isFalse);
      expect(decoded['templateName'], equals('Upper Body Push'));
    });

    test(
      'returns error with available templates when name not found',
      () async {
        final templates = [
          _makeTemplate(name: 'Push Day'),
          _makeTemplate(name: 'Pull Day'),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = TemplateQueryExecutor(
          templateRepo: mockRepo,
          exerciseSearchService: mockSearchService,
        );

        final result = await executor.getTemplateDetails({
          'templateName': 'Leg Day XYZ',
        }, userId);
        final decoded = jsonDecode(result) as Map<String, dynamic>;

        expect(decoded.containsKey('error'), isTrue);
        expect(decoded['availableTemplates'], isList);
      },
    );

    test('returns error when no templates exist at all', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'Anything',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
    });

    test('result is always valid JSON', () async {
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => [_makeTemplate(name: 'Test Template')]);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'Test Template',
      }, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('returns error when no templates exist and name is given', () async {
      // Verifies the "not found" error path when repo returns empty list.
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'NonExistent',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded.containsKey('error'), isTrue);
    });

    test('exercise details include name, category, sets, reps', () async {
      final exercises = [
        Exercise(
          name: 'Bench Press',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [
            ExerciseSet(setNumber: 1, reps: 8, weight: 100.0),
            ExerciseSet(setNumber: 2, reps: 8, weight: 100.0),
            ExerciseSet(setNumber: 3, reps: 6, weight: 105.0),
          ],
        ),
      ];
      when(() => mockRepo.getUserTemplates()).thenAnswer(
        (_) async => [
          _makeTemplate(name: 'Chest Session', exercises: exercises),
        ],
      );
      final executor = TemplateQueryExecutor(
        templateRepo: mockRepo,
        exerciseSearchService: mockSearchService,
      );

      final result = await executor.getTemplateDetails({
        'templateName': 'Chest Session',
      }, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      final exerciseList = decoded['exercises'] as List<dynamic>;

      expect(exerciseList, hasLength(1));
      final ex = exerciseList.first as Map<String, dynamic>;
      expect(ex['name'], equals('Bench Press'));
      expect(ex['sets'], equals(3));
      // avg of [8,8,6] = 22/3 = 7.33 -> round -> 7
      expect(ex['reps'], equals(7));
    });
  });
}
