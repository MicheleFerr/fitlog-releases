/// Unit tests for TemplateExerciseExecutor
///
/// Tests JSON validity, error handling, disambiguation flows,
/// confirmation flows, and success paths for:
/// - addExerciseToTemplate
/// - replaceExerciseInTemplate
/// - removeExerciseFromTemplate
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_exercise_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Mocks using mocktail
// ---------------------------------------------------------------------------

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockExerciseSearchService extends Mock
    implements ExerciseSearchService {}

// Fakes for types used with any() / captureAny()
class _FakeExercise extends Fake implements Exercise {}
// ignore: deprecated_member_use
class _FakeExerciseDefinitionTemplate extends Fake
    // ignore: deprecated_member_use
    implements ExerciseDefinitionTemplate {}

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

ExerciseSet _makeSet({int setNumber = 1, int reps = 10, int? restTime}) {
  return ExerciseSet(
    setNumber: setNumber,
    reps: reps,
    restTime: restTime ?? 90,
  );
}

Exercise _makeExercise({
  required String name,
  ExerciseCategory category = ExerciseCategory.chest,
  ExerciseType type = ExerciseType.single,
  int setCount = 3,
  int restTime = 90,
}) {
  return Exercise(
    name: name,
    category: category,
    type: type,
    sets: List.generate(
      setCount,
      (i) => _makeSet(setNumber: i + 1, reps: 10, restTime: restTime),
    ),
    restTime: restTime,
  );
}

// ignore: deprecated_member_use
CommunityWorkoutTemplate _makeTemplate({
  required String name,
  String id = '',
  String userId = 'user123',
  TemplateCategory category = TemplateCategory.custom,
  List<Exercise>? exercises,
}) {
  // ignore: deprecated_member_use
  return CommunityWorkoutTemplate(
    id: id.isEmpty ? 'id_${name.replaceAll(' ', '_')}' : id,
    userId: userId,
    name: name,
    exercises: exercises ?? [_makeExercise(name: 'Bench Press')],
    category: category,
    createdAt: DateTime(2025, 1, 1),
  );
}

// ignore: deprecated_member_use
ExerciseDefinitionTemplate _makeExerciseTemplate({
  required String name,
  ExerciseCategory category = ExerciseCategory.chest,
  ExerciseType type = ExerciseType.single,
  List<String>? muscleGroups,
  String? imageUrl,
}) {
  // ignore: deprecated_member_use
  return ExerciseDefinitionTemplate(
    id: 'ex_${name.replaceAll(' ', '_')}',
    name: name,
    description: '$name exercise',
    category: category,
    type: type,
    muscleGroups: muscleGroups ?? ['chest'],
    equipment: ['barbell'],
    imageUrl: imageUrl,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _decodeResult(String result) {
  return jsonDecode(result) as Map<String, dynamic>;
}

void main() {
  late MockTemplateRepository mockRepo;
  late MockExerciseSearchService mockSearchService;
  const userId = 'user123';

  setUpAll(() {
    registerFallbackValue(_FakeExercise());
    // ignore: deprecated_member_use
    registerFallbackValue(_FakeExerciseDefinitionTemplate());
  });

  setUp(() {
    mockRepo = MockTemplateRepository();
    mockSearchService = MockExerciseSearchService();
  });

  TemplateExerciseExecutor _makeExecutor() {
    return TemplateExerciseExecutor(
      templateRepo: mockRepo,
      exerciseSearchService: mockSearchService,
    );
  }

  // ===========================================================================
  // addExerciseToTemplate
  // ===========================================================================

  group('TemplateExerciseExecutor.addExerciseToTemplate', () {
    // -------------------------------------------------------------------------
    // Test 1: Returns error when templateName is null/empty
    // -------------------------------------------------------------------------
    group('when templateName is null or empty', () {
      test('returns error JSON when no templates exist', () async {
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => []);
        final executor = _makeExecutor();

        final result = await executor.addExerciseToTemplate({}, userId);
        final decoded = _decodeResult(result);

        expect(decoded.containsKey('error'), isTrue);
        expect(decoded['toolName'], equals('addExerciseToTemplate'));
      });

      test('returns error JSON when templateName is empty string', () async {
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => []);
        final executor = _makeExecutor();

        final result = await executor.addExerciseToTemplate(
          {'templateName': ''},
          userId,
        );
        final decoded = _decodeResult(result);

        expect(decoded.containsKey('error'), isTrue);
        expect(decoded['toolName'], equals('addExerciseToTemplate'));
      });

      // -----------------------------------------------------------------------
      // Test 2: Returns disambiguation when no templateName but templates exist
      // -----------------------------------------------------------------------
      test('returns disambiguation when templates exist', () async {
        final templates = [
          _makeTemplate(name: 'Push Day'),
          _makeTemplate(name: 'Pull Day'),
          _makeTemplate(name: 'Leg Day'),
        ];
        when(
          () => mockRepo.getUserTemplates(),
        ).thenAnswer((_) async => templates);
        final executor = _makeExecutor();

        final result = await executor.addExerciseToTemplate({}, userId);
        final decoded = _decodeResult(result);

        expect(decoded['disambiguation'], isTrue);
        expect(decoded['toolName'], equals('addExerciseToTemplate'));
        expect(decoded.containsKey('options'), isTrue);
        expect(decoded.containsKey('suggestions'), isTrue);
        final suggestions = decoded['suggestions'] as List<dynamic>;
        expect(suggestions, containsAll(['Push Day', 'Pull Day', 'Leg Day']));
      });
    });

    // -------------------------------------------------------------------------
    // Test 3: Returns error when exerciseName is null/empty
    // -------------------------------------------------------------------------
    group('when exerciseName is null or empty', () {
      test('returns error JSON when exerciseName is missing', () async {
        final executor = _makeExecutor();

        final result = await executor.addExerciseToTemplate(
          {'templateName': 'Push Day'},
          userId,
        );
        final decoded = _decodeResult(result);

        expect(decoded.containsKey('error'), isTrue);
        expect(decoded['toolName'], equals('addExerciseToTemplate'));
        // getUserTemplates should not be called since templateName is present.
        verifyNever(() => mockRepo.getUserTemplates());
      });

      test('returns error JSON when exerciseName is empty string', () async {
        final executor = _makeExecutor();

        final result = await executor.addExerciseToTemplate(
          {'templateName': 'Push Day', 'exerciseName': ''},
          userId,
        );
        final decoded = _decodeResult(result);

        expect(decoded.containsKey('error'), isTrue);
        expect(decoded['toolName'], equals('addExerciseToTemplate'));
      });
    });

    // -------------------------------------------------------------------------
    // Test 4: Returns error when no templates saved
    // -------------------------------------------------------------------------
    test('returns error when no templates saved', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {'templateName': 'Push Day', 'exerciseName': 'Bench Press'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 5: Returns error when template not found (with suggestions)
    // -------------------------------------------------------------------------
    test('returns error with availableTemplates when template not found',
        () async {
      final templates = [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {'templateName': 'Nonexistent Template', 'exerciseName': 'Bench Press'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded.containsKey('availableTemplates'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 6: Returns disambiguation when multiple template matches
    // -------------------------------------------------------------------------
    test('returns disambiguation when multiple templates match', () async {
      final templates = [
        _makeTemplate(name: 'Push Day A'),
        _makeTemplate(name: 'Push Day B'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      // "Push Day" is a substring of both, so both match without exact name.
      final result = await executor.addExerciseToTemplate(
        {'templateName': 'Push', 'exerciseName': 'Bench Press'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded.containsKey('options'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 7: Returns error when exercise not found in search
    // -------------------------------------------------------------------------
    test('returns error when exercise not found in search', () async {
      final templates = [_makeTemplate(name: 'Push Day')];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Unknown Exercise', any()),
      ).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {'templateName': 'Push Day', 'exerciseName': 'Unknown Exercise'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 8: Returns confirmationRequired when not confirmed
    // -------------------------------------------------------------------------
    test('returns confirmationRequired when confirmed is false', () async {
      final templates = [_makeTemplate(name: 'Push Day')];
      final exerciseTemplates = [
        _makeExerciseTemplate(name: 'Bench Press', muscleGroups: ['chest']),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Bench Press', any()),
      ).thenAnswer((_) async => exerciseTemplates);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded.containsKey('exercise'), isTrue);
      expect(decoded.containsKey('plannedSetup'), isTrue);
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded.containsKey('suggestedPayload'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 9: Returns success with inlineCard when confirmed
    // -------------------------------------------------------------------------
    test('returns success with inlineCard when confirmed is true', () async {
      final benchExercise = _makeExercise(name: 'Bench Press');
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [benchExercise],
        ),
      ];
      final exerciseTemplates = [
        _makeExerciseTemplate(name: 'Squat', muscleGroups: ['legs']),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [benchExercise, _makeExercise(name: 'Squat')],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Squat', any()),
      ).thenAnswer((_) async => exerciseTemplates);
      when(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: any(named: 'exercise'),
          allowDuplicate: any(named: 'allowDuplicate'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Squat',
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['success'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded['addedExercise'], equals('Squat'));
      expect(decoded.containsKey('exerciseCount'), isTrue);
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 10: Returns error for duplicate exercise (already exists)
    // -------------------------------------------------------------------------
    test('returns error for duplicate exercise when addExerciseToTemplate throws',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ];
      final exerciseTemplates = [
        _makeExerciseTemplate(name: 'Bench Press', muscleGroups: ['chest']),
      ];

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Bench Press', any()),
      ).thenAnswer((_) async => exerciseTemplates);
      when(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: any(named: 'exercise'),
          allowDuplicate: any(named: 'allowDuplicate'),
        ),
      ).thenThrow(
        Exception('Exercise "Bench Press" already exists in template'),
      );
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'confirmed': true,
          'allowDuplicate': false,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('addExerciseToTemplate'));
      // The error message should mention the duplicate.
      final errorMsg = decoded['error'] as String;
      expect(
        errorMsg.toLowerCase(),
        anyOf(
          contains('già presente'),
          contains('già presente'),
          contains('already'),
        ),
      );
    });

    // -------------------------------------------------------------------------
    // Test 11: Passes custom sets/reps/restSeconds correctly
    // -------------------------------------------------------------------------
    test('passes custom sets, reps and restSeconds to addExerciseToTemplate',
        () async {
      final templates = [_makeTemplate(name: 'Push Day')];
      final exerciseTemplates = [
        _makeExerciseTemplate(name: 'Squat', muscleGroups: ['legs']),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [_makeExercise(name: 'Squat', setCount: 5)],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Squat', any()),
      ).thenAnswer((_) async => exerciseTemplates);
      when(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: any(named: 'exercise'),
          allowDuplicate: any(named: 'allowDuplicate'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Squat',
          'sets': 5,
          'reps': 8,
          'restSeconds': 120,
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      // Verify success and that appliedSetup contains the custom values.
      expect(decoded['success'], isTrue);
      final appliedSetup = decoded['appliedSetup'] as Map<String, dynamic>;
      expect(appliedSetup['sets'], equals(5));
      expect(appliedSetup['reps'], equals(8));
      expect(appliedSetup['restSeconds'], equals(120));

      // Verify Exercise was created with correct structure (5 sets × 8 reps).
      final capturedCall = verify(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: captureAny(named: 'exercise'),
          allowDuplicate: any(named: 'allowDuplicate'),
        ),
      ).captured;
      final capturedExercise = capturedCall.first as Exercise;
      expect(capturedExercise.sets.length, equals(5));
      expect(capturedExercise.sets.first.reps, equals(8));
      expect(capturedExercise.restTime, equals(120));
    });

    // -------------------------------------------------------------------------
    // Test 12: parseBoolFlag handles allowDuplicate
    // -------------------------------------------------------------------------
    test('parseBoolFlag handles allowDuplicate as string "true"', () async {
      final templates = [_makeTemplate(name: 'Push Day')];
      final exerciseTemplates = [
        _makeExerciseTemplate(name: 'Bench Press', muscleGroups: ['chest']),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press'),
          _makeExercise(name: 'Bench Press'),
        ],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Bench Press', any()),
      ).thenAnswer((_) async => exerciseTemplates);
      when(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: any(named: 'exercise'),
          allowDuplicate: any(named: 'allowDuplicate'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'confirmed': true,
          'allowDuplicate': 'true', // String representation
        },
        userId,
      );
      final decoded = _decodeResult(result);

      // Should succeed because allowDuplicate=true parsed from string.
      expect(decoded['success'], isTrue);

      // Verify allowDuplicate=true was passed to the repo.
      final capturedCall = verify(
        () => mockRepo.addExerciseToTemplate(
          templateId: any(named: 'templateId'),
          exercise: any(named: 'exercise'),
          allowDuplicate: captureAny(named: 'allowDuplicate'),
        ),
      ).captured;
      expect(capturedCall.first, isTrue);
    });

    // -------------------------------------------------------------------------
    // Result is always valid JSON
    // -------------------------------------------------------------------------
    test('result is always valid JSON regardless of error', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result = await executor.addExerciseToTemplate({}, userId);
      expect(() => _decodeResult(result), returnsNormally);
    });
  });

  // ===========================================================================
  // replaceExerciseInTemplate
  // ===========================================================================

  group('TemplateExerciseExecutor.replaceExerciseInTemplate', () {
    // -------------------------------------------------------------------------
    // Test 13: Returns error when templateName is null
    // -------------------------------------------------------------------------
    test('returns error JSON when templateName is null and no templates',
        () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result =
          await executor.replaceExerciseInTemplate({}, userId);
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    test('returns disambiguation when templateName null but templates exist',
        () async {
      final templates = [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result =
          await executor.replaceExerciseInTemplate({}, userId);
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 14: Returns disambiguation when no old exercise specified
    // -------------------------------------------------------------------------
    test(
        'returns disambiguation listing template exercises when oldExerciseName missing',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Bench Press'),
            _makeExercise(name: 'Military Press'),
          ],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.replaceExerciseInTemplate(
        {'templateName': 'Push Day'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
      final suggestions = decoded['suggestions'] as List<dynamic>;
      expect(suggestions, containsAll(['Bench Press', 'Military Press']));
    });

    // -------------------------------------------------------------------------
    // Test 15: Returns error when old exercise not found in template
    // -------------------------------------------------------------------------
    test('returns error when old exercise not found in template', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.replaceExerciseInTemplate(
        {
          'templateName': 'Push Day',
          'oldExerciseName': 'Squat', // Not in template
          'newExerciseName': 'Leg Press',
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded.containsKey('availableExercises'), isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 16: Returns disambiguation when multiple old exercise matches
    // -------------------------------------------------------------------------
    test(
        'returns disambiguation when multiple old exercise matches in template',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Curl Bilanciere'),
            _makeExercise(name: 'Curl Manubri'),
          ],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      // "curl" matches both "Curl Bilanciere" and "Curl Manubri".
      final result = await executor.replaceExerciseInTemplate(
        {
          'templateName': 'Push Day',
          'oldExerciseName': 'curl',
          'newExerciseName': 'French Press',
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 17: Returns disambiguation when no new exercise specified
    // -------------------------------------------------------------------------
    test(
        'returns disambiguation with search results when newExerciseName missing',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(
              name: 'Bench Press',
              category: ExerciseCategory.chest,
            ),
          ],
        ),
      ];
      final chestAlternatives = [
        _makeExerciseTemplate(
          name: 'Incline Press',
          category: ExerciseCategory.chest,
          muscleGroups: ['chest'],
        ),
        _makeExerciseTemplate(
          name: 'Chest Fly',
          category: ExerciseCategory.chest,
          muscleGroups: ['chest'],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      // The executor will search by category keyword 'petto' for chest exercises.
      when(
        () => mockSearchService.searchExercises(any(), any()),
      ).thenAnswer((_) async => chestAlternatives);
      final executor = _makeExecutor();

      final result = await executor.replaceExerciseInTemplate(
        {
          'templateName': 'Push Day',
          'oldExerciseName': 'Bench Press',
          // No newExerciseName
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 18: Returns confirmationRequired when not confirmed
    // -------------------------------------------------------------------------
    test('returns confirmationRequired when confirmed is false', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(
              name: 'Bench Press',
              category: ExerciseCategory.chest,
            ),
          ],
        ),
      ];
      final newExerciseResults = [
        _makeExerciseTemplate(
          name: 'Incline Press',
          category: ExerciseCategory.chest,
          muscleGroups: ['chest'],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Incline Press', any()),
      ).thenAnswer((_) async => newExerciseResults);
      final executor = _makeExecutor();

      final result = await executor.replaceExerciseInTemplate(
        {
          'templateName': 'Push Day',
          'oldExerciseName': 'Bench Press',
          'newExerciseName': 'Incline Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded['oldExercise'], equals('Bench Press'));
      expect(decoded.containsKey('newExercise'), isTrue);
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded.containsKey('suggestedPayload'), isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 19: Returns success when confirmed
    // -------------------------------------------------------------------------
    test('returns success JSON when confirmed is true', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(
              name: 'Bench Press',
              category: ExerciseCategory.chest,
            ),
          ],
        ),
      ];
      final newExerciseResults = [
        _makeExerciseTemplate(
          name: 'Incline Press',
          category: ExerciseCategory.chest,
          muscleGroups: ['chest'],
        ),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [_makeExercise(name: 'Incline Press')],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Incline Press', any()),
      ).thenAnswer((_) async => newExerciseResults);
      when(
        () => mockRepo.replaceExerciseInTemplate(
          templateId: any(named: 'templateId'),
          oldExerciseName: any(named: 'oldExerciseName'),
          newExercise: any(named: 'newExercise'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.replaceExerciseInTemplate(
        {
          'templateName': 'Push Day',
          'oldExerciseName': 'Bench Press',
          'newExerciseName': 'Incline Press',
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['success'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded['oldExercise'], equals('Bench Press'));
      expect(decoded['newExercise'], equals('Incline Press'));
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded['toolName'], equals('replaceExerciseInTemplate'));
    });

    // -------------------------------------------------------------------------
    // Result is always valid JSON
    // -------------------------------------------------------------------------
    test('result is always valid JSON regardless of error', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result =
          await executor.replaceExerciseInTemplate({}, userId);
      expect(() => _decodeResult(result), returnsNormally);
    });
  });

  // ===========================================================================
  // removeExerciseFromTemplate
  // ===========================================================================

  group('TemplateExerciseExecutor.removeExerciseFromTemplate', () {
    // -------------------------------------------------------------------------
    // Test 20: Returns error when templateName is null
    // -------------------------------------------------------------------------
    test('returns error JSON when templateName is null and no templates',
        () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result =
          await executor.removeExerciseFromTemplate({}, userId);
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    test('returns disambiguation when templateName null but templates exist',
        () async {
      final templates = [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result =
          await executor.removeExerciseFromTemplate({}, userId);
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 21: Returns disambiguation when no exercise specified
    // -------------------------------------------------------------------------
    test(
        'returns disambiguation listing template exercises when exerciseName missing',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Bench Press'),
            _makeExercise(name: 'Squat'),
          ],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {'templateName': 'Push Day'},
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
      final suggestions = decoded['suggestions'] as List<dynamic>;
      expect(suggestions, containsAll(['Bench Press', 'Squat']));
    });

    // -------------------------------------------------------------------------
    // Test 22: Returns error when exercise not found in template
    // -------------------------------------------------------------------------
    test('returns error when exercise not found in template', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Deadlift', // Not in template
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded.containsKey('availableExercises'), isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 23: Returns confirmationRequired when not confirmed
    // -------------------------------------------------------------------------
    test('returns confirmationRequired when confirmed is false', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises('Bench Press', any()),
      ).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded['exerciseName'], equals('Bench Press'));
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded.containsKey('suggestedPayload'), isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 24: Returns success when confirmed
    // -------------------------------------------------------------------------
    test('returns success JSON when confirmed is true', () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Bench Press'),
            _makeExercise(name: 'Squat'),
          ],
        ),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [_makeExercise(name: 'Squat')],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepo.removeExerciseFromTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: any(named: 'exerciseName'),
          removeAllMatches: any(named: 'removeAllMatches'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['success'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
      expect(decoded['removedExercise'], equals('Bench Press'));
      expect(decoded.containsKey('exerciseCount'), isTrue);
      expect(decoded.containsKey('inlineCard'), isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    // -------------------------------------------------------------------------
    // Test 25: Handles removeAllMatches flag
    // -------------------------------------------------------------------------
    test('handles removeAllMatches flag when exercise appears multiple times',
        () async {
      // Template with duplicate exercise names (edge case).
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Bench Press'),
            _makeExercise(name: 'Bench Press'), // Duplicate
            _makeExercise(name: 'Squat'),
          ],
        ),
      ];
      // ignore: deprecated_member_use
      final updatedTemplate = CommunityWorkoutTemplate(
        id: 'id_Push_Day',
        userId: 'user123',
        name: 'Push Day',
        exercises: [_makeExercise(name: 'Squat')],
        category: TemplateCategory.custom,
        createdAt: DateTime(2025, 1, 1),
      );

      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      when(
        () => mockSearchService.searchExercises(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepo.removeExerciseFromTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: any(named: 'exerciseName'),
          removeAllMatches: any(named: 'removeAllMatches'),
        ),
      ).thenAnswer((_) async => updatedTemplate);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'removeAllMatches': true,
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      // With removeAllMatches=true and multiple exact matches, it should
      // proceed to confirmation / success without disambiguation.
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
      // Verify removeAllMatches=true was forwarded to the repo.
      final capturedCall = verify(
        () => mockRepo.removeExerciseFromTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: any(named: 'exerciseName'),
          removeAllMatches: captureAny(named: 'removeAllMatches'),
        ),
      ).captured;
      expect(capturedCall.first, isTrue);
    });

    // -------------------------------------------------------------------------
    // Result is always valid JSON
    // -------------------------------------------------------------------------
    test('result is always valid JSON regardless of error', () async {
      when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => []);
      final executor = _makeExecutor();

      final result =
          await executor.removeExerciseFromTemplate({}, userId);
      expect(() => _decodeResult(result), returnsNormally);
    });

    // -------------------------------------------------------------------------
    // Additional edge case: template not found returns error with suggestions
    // -------------------------------------------------------------------------
    test(
        'returns error with availableTemplates when template not found in remove',
        () async {
      final templates = [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Nonexistent Template',
          'exerciseName': 'Bench Press',
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded.containsKey('availableTemplates'), isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });

    // -------------------------------------------------------------------------
    // Multiple matches without removeAllMatches triggers disambiguation
    // -------------------------------------------------------------------------
    test(
        'returns disambiguation when multiple exercise matches and removeAllMatches is false',
        () async {
      final templates = [
        _makeTemplate(
          name: 'Push Day',
          exercises: [
            _makeExercise(name: 'Curl Bilanciere'),
            _makeExercise(name: 'Curl Manubri'),
          ],
        ),
      ];
      when(
        () => mockRepo.getUserTemplates(),
      ).thenAnswer((_) async => templates);
      final executor = _makeExecutor();

      // "curl" matches both exercises; without removeAllMatches it disambiguates.
      final result = await executor.removeExerciseFromTemplate(
        {
          'templateName': 'Push Day',
          'exerciseName': 'curl',
          'removeAllMatches': false,
          'confirmed': true,
        },
        userId,
      );
      final decoded = _decodeResult(result);

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('removeExerciseFromTemplate'));
    });
  });
}
