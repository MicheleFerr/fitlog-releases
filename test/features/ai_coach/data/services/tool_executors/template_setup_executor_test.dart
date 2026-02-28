/// Unit tests for TemplateSetupExecutor
///
/// Tests updateTemplateRestTime and updateTemplateExerciseSetup methods,
/// covering disambiguation flows, confirmation flows, smart defaults,
/// delta adjustments, range modes, clamping, and error paths.
library;

import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_setup_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockExerciseSearchService extends Mock implements ExerciseSearchService {}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

ExerciseSet _makeSet({
  int setNumber = 1,
  int? reps,
  int? minReps,
  int? maxReps,
  double? weight,
  int? restTime,
}) {
  return ExerciseSet(
    setNumber: setNumber,
    reps: reps ?? 10,
    minReps: minReps,
    maxReps: maxReps,
    weight: weight ?? 60.0,
    restTime: restTime,
  );
}

Exercise _makeExercise({
  required String name,
  ExerciseCategory category = ExerciseCategory.chest,
  int setCount = 3,
  int? reps,
  int? restTime,
  int? minReps,
  int? maxReps,
}) {
  final sets = List.generate(
    setCount,
    (i) => _makeSet(
      setNumber: i + 1,
      reps: (minReps == null && maxReps == null) ? (reps ?? 10) : null,
      minReps: minReps,
      maxReps: maxReps,
      restTime: restTime,
    ),
  );
  return Exercise(
    name: name,
    category: category,
    type: ExerciseType.single,
    sets: sets,
    restTime: restTime,
  );
}

CommunityWorkoutTemplate _makeTemplate({
  required String name,
  TemplateCategory category = TemplateCategory.custom,
  List<Exercise>? exercises,
  String? id,
}) {
  return CommunityWorkoutTemplate(
    id: id ?? 'tpl_${name.replaceAll(' ', '_').toLowerCase()}',
    userId: 'user123',
    name: name,
    exercises: exercises ??
        [
          _makeExercise(name: 'Bench Press'),
        ],
    category: category,
    createdAt: DateTime(2025, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// Shared stub helpers
// ---------------------------------------------------------------------------

void _stubGetUserTemplates(
  MockTemplateRepository mockRepo,
  List<CommunityWorkoutTemplate> templates,
) {
  when(() => mockRepo.getUserTemplates()).thenAnswer((_) async => templates);
}

void _stubSearchExercises(MockExerciseSearchService mockSearch) {
  when(
    () => mockSearch.searchExercises(any(), any()),
  ).thenAnswer((_) async => <ExerciseTemplate>[]);
}

void _stubUpdateRestTime(
  MockTemplateRepository mockRepo,
  CommunityWorkoutTemplate returnTemplate,
) {
  when(
    () => mockRepo.updateExerciseRestTimeInTemplate(
      templateId: any(named: 'templateId'),
      exerciseName: any(named: 'exerciseName'),
      restSeconds: any(named: 'restSeconds'),
      applyToAllExercises: any(named: 'applyToAllExercises'),
      updateAllMatches: any(named: 'updateAllMatches'),
    ),
  ).thenAnswer((_) async => returnTemplate);
}

void _stubUpdateSetReps(
  MockTemplateRepository mockRepo,
  CommunityWorkoutTemplate returnTemplate,
) {
  when(
    () => mockRepo.updateExerciseSetRepsInTemplate(
      templateId: any(named: 'templateId'),
      exerciseName: any(named: 'exerciseName'),
      sets: any(named: 'sets'),
      reps: any(named: 'reps'),
      minReps: any(named: 'minReps'),
      maxReps: any(named: 'maxReps'),
      applyToAllExercises: any(named: 'applyToAllExercises'),
      updateAllMatches: any(named: 'updateAllMatches'),
    ),
  ).thenAnswer((_) async => returnTemplate);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  late MockTemplateRepository mockRepo;
  late MockExerciseSearchService mockSearch;
  const userId = 'user123';

  setUp(() {
    mockRepo = MockTemplateRepository();
    mockSearch = MockExerciseSearchService();
    _stubSearchExercises(mockSearch);
  });

  TemplateSetupExecutor _makeExecutor({Locale? locale}) {
    return TemplateSetupExecutor(
      templateRepo: mockRepo,
      exerciseSearchService: mockSearch,
      locale: locale,
    );
  }

  // =========================================================================
  // updateTemplateRestTime
  // =========================================================================

  group('updateTemplateRestTime', () {
    // -----------------------------------------------------------------------
    // Test 1: null / empty templateName
    // -----------------------------------------------------------------------
    test('returns error when templateName is null and no templates exist',
        () async {
      _stubGetUserTemplates(mockRepo, []);

      final result =
          await _makeExecutor().updateTemplateRestTime({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    test('returns disambiguation when templateName is null but templates exist',
        () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ]);

      final result =
          await _makeExecutor().updateTemplateRestTime({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['suggestions'], isList);
      expect((decoded['suggestions'] as List).length, equals(2));
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    test('returns error when templateName is empty string and no templates',
        () async {
      _stubGetUserTemplates(mockRepo, []);

      final result = await _makeExecutor().updateTemplateRestTime(
        {'templateName': ''},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 2: disambiguation when no templateName but templates exist
    // (covered above; also verify suggestions content)
    // -----------------------------------------------------------------------
    test('disambiguation options include template names', () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Alpha'),
        _makeTemplate(name: 'Beta'),
        _makeTemplate(name: 'Gamma'),
      ]);

      final result =
          await _makeExecutor().updateTemplateRestTime({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['disambiguation'], isTrue);
      final suggestions = decoded['suggestions'] as List<dynamic>;
      expect(suggestions, containsAll(['Alpha', 'Beta', 'Gamma']));
    });

    // -----------------------------------------------------------------------
    // Test 3: error when no templates saved (templateName provided)
    // -----------------------------------------------------------------------
    test('returns error when no templates are saved', () async {
      _stubGetUserTemplates(mockRepo, []);

      final result = await _makeExecutor().updateTemplateRestTime(
        {'templateName': 'Push Day'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 4: error when template not found
    // -----------------------------------------------------------------------
    test('returns error when template name does not match any template',
        () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Push Day'),
      ]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {'templateName': 'NonExistent XYZ'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['availableTemplates'], isList);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 5: disambiguation when multiple templates match
    // -----------------------------------------------------------------------
    test('returns disambiguation when multiple templates match query', () async {
      // Both templates contain "push" so query "push" matches both
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Push Upper'),
        _makeTemplate(name: 'Push Lower'),
      ]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {'templateName': 'push'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // Two ambiguous results, no exact match -> disambiguation
      expect(decoded['disambiguation'], isTrue);
      expect(decoded['options'], isList);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 6: disambiguation when no exerciseName and not applyToAll
    // -----------------------------------------------------------------------
    test(
        'returns disambiguation when exerciseName is missing and not applyToAll',
        () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
          _makeExercise(name: 'Overhead Press', restTime: 60),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {'templateName': 'Push Day'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['query'], equals('esercizio'));
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 7: error when exercise not found in template
    // -----------------------------------------------------------------------
    test('returns error when exercise not found in template', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press'),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Squat',
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['availableExercises'], isList);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 8: returns confirmationRequired when not confirmed
    // -----------------------------------------------------------------------
    test('returns confirmationRequired when confirmed is false', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 120,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedRestSeconds'], equals(120));
      expect(decoded['suggestedPayload'], isMap);
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Test 9: success when confirmed with explicit rest time
    // -----------------------------------------------------------------------
    test('returns success when confirmed with explicit restSeconds', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 120,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['restSeconds'], equals(120));
      expect(decoded['toolName'], equals('updateTemplateRestTime'));

      verify(
        () => mockRepo.updateExerciseRestTimeInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: 'Bench Press',
          restSeconds: 120,
          applyToAllExercises: false,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 10: applies to all exercises when applyToAllExercises is true
    // -----------------------------------------------------------------------
    test('applies to all exercises when applyToAllExercises is true', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
          _makeExercise(name: 'Overhead Press', restTime: 60),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'applyToAllExercises': true,
          'restSeconds': 120,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['target'], equals('tutti gli esercizi'));
      expect(decoded['toolName'], equals('updateTemplateRestTime'));

      verify(
        () => mockRepo.updateExerciseRestTimeInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: null,
          restSeconds: 120,
          applyToAllExercises: true,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 11: uses deltaSeconds to adjust from current rest
    // -----------------------------------------------------------------------
    test('uses deltaSeconds to adjust from current restTime', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 100),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      // delta = +30 -> 100 + 30 = 130
      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'deltaSeconds': 30,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['restSeconds'], equals(130));
    });

    // -----------------------------------------------------------------------
    // Test 12: smart default for strength template (180s)
    // -----------------------------------------------------------------------
    test('uses 180s smart default for strength category template', () async {
      final template = _makeTemplate(
        name: 'Strength Session',
        category: TemplateCategory.strength,
        exercises: [
          _makeExercise(name: 'Squat', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      // No explicit restSeconds -> smart default applies
      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Strength Session',
          'exerciseName': 'Squat',
          'confirmed': false, // check proposed value
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedRestSeconds'], equals(180));
    });

    // -----------------------------------------------------------------------
    // Test 13: smart default for hypertrophy template (90s)
    // -----------------------------------------------------------------------
    test('uses 90s smart default for hypertrophy category template', () async {
      final template = _makeTemplate(
        name: 'Hypertrophy Session',
        category: TemplateCategory.hypertrophy,
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 120),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Hypertrophy Session',
          'exerciseName': 'Bench Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedRestSeconds'], equals(90));
    });

    // -----------------------------------------------------------------------
    // Test 14: clamps rest time between 20 and 300
    // -----------------------------------------------------------------------
    test('clamps rest time to minimum 20 seconds', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 30),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 5, // below minimum
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // parseBoundedInt clamps to 20 at parse time
      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedRestSeconds'], equals(20));
    });

    test('clamps rest time to maximum 300 seconds', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 999, // above maximum
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedRestSeconds'], equals(300));
    });

    // -----------------------------------------------------------------------
    // Test 15: error when template has no exercises
    // -----------------------------------------------------------------------
    test('returns error when template has no exercises', () async {
      final emptyTemplate = _makeTemplate(
        name: 'Empty Template',
        exercises: [],
      );
      _stubGetUserTemplates(mockRepo, [emptyTemplate]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Empty Template',
          'exerciseName': 'Bench Press',
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(
        (decoded['error'] as String).contains('non ha esercizi'),
        isTrue,
      );
      expect(decoded['toolName'], equals('updateTemplateRestTime'));
    });

    // -----------------------------------------------------------------------
    // Additional: result is always valid JSON
    // -----------------------------------------------------------------------
    test('result is always valid JSON regardless of path', () async {
      _stubGetUserTemplates(mockRepo, []);

      final result =
          await _makeExecutor().updateTemplateRestTime({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    // -----------------------------------------------------------------------
    // Additional: template name is case-insensitive matched
    // -----------------------------------------------------------------------
    test('matches template name case-insensitively', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      // 'push day' matches 'Push Day'
      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'push day',
          'exerciseName': 'Bench Press',
          'restSeconds': 120,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // Should reach confirmation, not error
      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['templateName'], equals('Push Day'));
    });

    // -----------------------------------------------------------------------
    // Additional: confirmationRequired includes inlineCard
    // -----------------------------------------------------------------------
    test('confirmationRequired response includes inlineCard', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 120,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['inlineCard'], isMap);
      final card = decoded['inlineCard'] as Map<String, dynamic>;
      expect(card['actions'], isList);
    });

    // -----------------------------------------------------------------------
    // Additional: success response includes inlineCard
    // -----------------------------------------------------------------------
    test('success response includes inlineCard with actions', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 90),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'restSeconds': 120,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['inlineCard'], isMap);
    });

    // -----------------------------------------------------------------------
    // Additional: deltaSeconds clamps to [-120, 120] range
    // -----------------------------------------------------------------------
    test('large negative deltaSeconds results in minimum 20s rest', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 30),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      // delta -120 (max negative) -> 30 - 120 = -90 -> clamped to 20
      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'deltaSeconds': -200, // clamped to -120 -> 30 + (-120) = -90 -> 20
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['restSeconds'], equals(20));
    });

    // -----------------------------------------------------------------------
    // Additional: applyToAll with confirmed uses average rest as currentRest
    // -----------------------------------------------------------------------
    test('applyToAll computes average restTime for currentRest display',
        () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', restTime: 60),
          _makeExercise(name: 'Incline Press', restTime: 120),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateRestTime(mockRepo, template);

      final result = await _makeExecutor().updateTemplateRestTime(
        {
          'templateName': 'Push Day',
          'applyToAllExercises': true,
          'restSeconds': 90,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      // Average of 60 and 120 is 90
      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['currentRestSeconds'], equals(90));
    });
  });

  // =========================================================================
  // updateTemplateExerciseSetup
  // =========================================================================

  group('updateTemplateExerciseSetup', () {
    // -----------------------------------------------------------------------
    // Test 16: error when templateName is null/empty
    // -----------------------------------------------------------------------
    test('returns error when templateName is null and no templates exist',
        () async {
      _stubGetUserTemplates(mockRepo, []);

      final result =
          await _makeExecutor().updateTemplateExerciseSetup({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    test(
        'returns disambiguation when templateName is null but templates exist',
        () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Push Day'),
      ]);

      final result =
          await _makeExecutor().updateTemplateExerciseSetup({}, userId);
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Test 17: error for minReps without maxReps (and vice versa)
    // -----------------------------------------------------------------------
    test('returns error when minReps is set but maxReps is not', () async {
      // Note: templateName must be null/empty to trigger the range validation
      // before the template lookup. But looking at the code, the range
      // validation happens after template lookup. We set a valid template.
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'minReps': 8,
          // maxReps intentionally missing
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(
        (decoded['error'] as String).contains('minReps') ||
            (decoded['error'] as String).contains('maxReps') ||
            (decoded['error'] as String).contains('range'),
        isTrue,
      );
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    test('returns error when maxReps is set but minReps is not', () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'maxReps': 12,
          // minReps intentionally missing
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Test 18: disambiguation when no exerciseName specified
    // -----------------------------------------------------------------------
    test('returns disambiguation when exerciseName is not provided', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press'),
          _makeExercise(name: 'Overhead Press'),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {'templateName': 'Push Day'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['disambiguation'], isTrue);
      expect(decoded['query'], equals('esercizio'));
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Test 19: error when exercise not found
    // -----------------------------------------------------------------------
    test('returns error when exercise is not found in template', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press'),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Deadlift',
          'sets': 4,
          'reps': 6,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['availableExercises'], isList);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Test 20: confirmationRequired when not confirmed
    // -----------------------------------------------------------------------
    test('returns confirmationRequired when confirmed is false', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
      expect(decoded['proposedReps'], equals('8'));
      expect(decoded['suggestedPayload'], isMap);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Test 21: success when confirmed
    // -----------------------------------------------------------------------
    test('returns success when confirmed is true', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['sets'], equals(4));
      expect(decoded['reps'], equals('8'));
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));

      verify(
        () => mockRepo.updateExerciseSetRepsInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: 'Bench Press',
          sets: 4,
          reps: 8,
          minReps: null,
          maxReps: null,
          applyToAllExercises: false,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 22: applies explicit sets and reps correctly
    // -----------------------------------------------------------------------
    test('applies explicit sets and reps in payload', () async {
      final template = _makeTemplate(
        name: 'Leg Day',
        exercises: [
          _makeExercise(name: 'Squat', setCount: 3, reps: 8),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Leg Day',
          'exerciseName': 'Squat',
          'sets': 5,
          'reps': 3,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['sets'], equals(5));
      expect(decoded['reps'], equals('3'));
    });

    // -----------------------------------------------------------------------
    // Test 23: uses deltaSets and deltaReps adjustments
    // -----------------------------------------------------------------------
    test('uses deltaSets to increment sets from current', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      // deltaSets = +1 -> current 3 + 1 = 4
      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'deltaSets': 1,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
    });

    test('uses deltaReps to increment reps from current', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 8),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      // deltaReps = +2 -> 8 + 2 = 10
      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'deltaReps': 2,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedReps'], equals('10'));
    });

    // -----------------------------------------------------------------------
    // Test 24: supports minReps/maxReps range mode
    // -----------------------------------------------------------------------
    test('supports minReps/maxReps range mode and displays range', () async {
      final template = _makeTemplate(
        name: 'Hypertrophy Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Hypertrophy Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'minReps': 8,
          'maxReps': 12,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedReps'], equals('8-12'));
      expect(decoded['proposedSets'], equals(4));
    });

    test('passes minReps and maxReps to repository when confirmed', () async {
      final template = _makeTemplate(
        name: 'Hypertrophy Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Hypertrophy Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'minReps': 8,
          'maxReps': 12,
          'confirmed': true,
        },
        userId,
      );

      verify(
        () => mockRepo.updateExerciseSetRepsInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: 'Bench Press',
          sets: 4,
          reps: null,
          minReps: 8,
          maxReps: 12,
          applyToAllExercises: false,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 25: swaps minReps/maxReps when min > max
    // -----------------------------------------------------------------------
    test('swaps minReps and maxReps when minReps is greater than maxReps',
        () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      // min=15, max=8 -> should be swapped to min=8, max=15
      await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'minReps': 15,
          'maxReps': 8,
          'confirmed': true,
        },
        userId,
      );

      verify(
        () => mockRepo.updateExerciseSetRepsInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: 'Bench Press',
          sets: 4,
          reps: null,
          minReps: 8, // swapped
          maxReps: 15, // swapped
          applyToAllExercises: false,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 26: smart defaults for strength templates (4x5)
    // -----------------------------------------------------------------------
    test('uses 4x5 smart default for strength category template', () async {
      final template = _makeTemplate(
        name: 'Strength Block',
        category: TemplateCategory.strength,
        exercises: [
          _makeExercise(name: 'Deadlift', setCount: 3, reps: 8),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      // No explicit sets/reps -> smart default
      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Strength Block',
          'exerciseName': 'Deadlift',
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
      expect(decoded['proposedReps'], equals('5'));
    });

    // -----------------------------------------------------------------------
    // Test 27: smart defaults for hypertrophy templates (4x10)
    // -----------------------------------------------------------------------
    test('uses 4x10 smart default for hypertrophy category template', () async {
      final template = _makeTemplate(
        name: 'Hypertrophy Block',
        category: TemplateCategory.hypertrophy,
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 12),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Hypertrophy Block',
          'exerciseName': 'Bench Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
      expect(decoded['proposedReps'], equals('10'));
    });

    // -----------------------------------------------------------------------
    // Test 28: applies to all exercises when applyToAllExercises
    // -----------------------------------------------------------------------
    test('applies to all exercises when applyToAllExercises is true', () async {
      final template = _makeTemplate(
        name: 'Full Body',
        exercises: [
          _makeExercise(name: 'Squat', setCount: 3, reps: 10),
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
          _makeExercise(name: 'Row', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Full Body',
          'applyToAllExercises': true,
          'sets': 4,
          'reps': 8,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['target'], equals('tutti gli esercizi'));

      verify(
        () => mockRepo.updateExerciseSetRepsInTemplate(
          templateId: any(named: 'templateId'),
          exerciseName: null,
          sets: 4,
          reps: 8,
          minReps: null,
          maxReps: null,
          applyToAllExercises: true,
          updateAllMatches: false,
        ),
      ).called(1);
    });

    // -----------------------------------------------------------------------
    // Test 29: clamps sets 1-8 and reps 3-30
    // -----------------------------------------------------------------------
    test('clamps sets to maximum of 8', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 20, // above max -> clamped to 8
          'reps': 10,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(8));
    });

    test('clamps sets to minimum of 1', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 0, // below min -> clamped to 1
          'reps': 10,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(1));
    });

    test('clamps reps to maximum of 30', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 3,
          'reps': 100, // above max -> clamped to 30
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedReps'], equals('30'));
    });

    test('clamps reps to minimum of 3', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 3,
          'reps': 1, // below min -> clamped to 3
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedReps'], equals('3'));
    });

    // -----------------------------------------------------------------------
    // Test 30: error when template has no exercises
    // -----------------------------------------------------------------------
    test('returns error when template has no exercises', () async {
      final emptyTemplate = _makeTemplate(
        name: 'Empty Template',
        exercises: [],
      );
      _stubGetUserTemplates(mockRepo, [emptyTemplate]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Empty Template',
          'exerciseName': 'Bench Press',
          'sets': 3,
          'reps': 10,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(
        (decoded['error'] as String).contains('non ha esercizi'),
        isTrue,
      );
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Additional: result is always valid JSON
    // -----------------------------------------------------------------------
    test('result is always valid JSON regardless of path', () async {
      _stubGetUserTemplates(mockRepo, []);

      final result =
          await _makeExecutor().updateTemplateExerciseSetup({}, userId);
      expect(() => jsonDecode(result), returnsNormally);
    });

    // -----------------------------------------------------------------------
    // Additional: confirmationRequired includes inlineCard
    // -----------------------------------------------------------------------
    test('confirmationRequired includes inlineCard with actions', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['inlineCard'], isMap);
      final card = decoded['inlineCard'] as Map<String, dynamic>;
      expect(card['actions'], isList);
      expect((card['actions'] as List).isNotEmpty, isTrue);
    });

    // -----------------------------------------------------------------------
    // Additional: bodybuilding category also uses hypertrophy smart defaults
    // -----------------------------------------------------------------------
    test('bodybuilding category uses 4x10 smart defaults', () async {
      final template = _makeTemplate(
        name: 'BBuild Block',
        category: TemplateCategory.bodybuilding,
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 12),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'BBuild Block',
          'exerciseName': 'Bench Press',
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
      expect(decoded['proposedReps'], equals('10'));
    });

    // -----------------------------------------------------------------------
    // Additional: powerlifting category uses strength smart defaults (4x5)
    // -----------------------------------------------------------------------
    test('powerlifting category uses 4x5 smart defaults', () async {
      final template = _makeTemplate(
        name: 'PL Session',
        category: TemplateCategory.powerlifting,
        exercises: [
          _makeExercise(name: 'Squat', setCount: 3, reps: 8),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'PL Session',
          'exerciseName': 'Squat',
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      expect(decoded['proposedSets'], equals(4));
      expect(decoded['proposedReps'], equals('5'));
    });

    // -----------------------------------------------------------------------
    // Additional: no templates saved returns error
    // -----------------------------------------------------------------------
    test('returns error when no templates saved and templateName provided',
        () async {
      _stubGetUserTemplates(mockRepo, []);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {'templateName': 'Nonexistent'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Additional: template not found returns error with availableTemplates
    // -----------------------------------------------------------------------
    test('returns error with availableTemplates when template not found',
        () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(name: 'Push Day'),
        _makeTemplate(name: 'Pull Day'),
      ]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {'templateName': 'ZZZZZ Nonexistent'},
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded.containsKey('error'), isTrue);
      expect(decoded['availableTemplates'], isList);
      expect(decoded['toolName'], equals('updateTemplateExerciseSetup'));
    });

    // -----------------------------------------------------------------------
    // Additional: exercise with minReps/maxReps shows range in currentReps
    // -----------------------------------------------------------------------
    test('current reps display shows range when exercise uses minReps/maxReps',
        () async {
      final exercise = Exercise(
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [
          _makeSet(setNumber: 1, minReps: 8, maxReps: 12, reps: null),
          _makeSet(setNumber: 2, minReps: 8, maxReps: 12, reps: null),
          _makeSet(setNumber: 3, minReps: 8, maxReps: 12, reps: null),
        ],
      );
      final template = _makeTemplate(
        name: 'Hyper Day',
        exercises: [exercise],
      );
      _stubGetUserTemplates(mockRepo, [template]);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Hyper Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 10,
          'confirmed': false,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['confirmationRequired'], isTrue);
      // currentReps should show the range display
      expect(decoded['currentReps'], equals('8-12'));
    });

    // -----------------------------------------------------------------------
    // Additional: locale is forwarded to executor without errors
    // -----------------------------------------------------------------------
    test('accepts optional locale without errors', () async {
      _stubGetUserTemplates(mockRepo, [
        _makeTemplate(
          name: 'Push Day',
          exercises: [_makeExercise(name: 'Bench Press')],
        ),
      ]);

      final executor = _makeExecutor(locale: const Locale('it'));
      final result = await executor.updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 10,
          'confirmed': false,
        },
        userId,
      );

      expect(() => jsonDecode(result), returnsNormally);
    });

    // -----------------------------------------------------------------------
    // Additional: success response includes inlineCard
    // -----------------------------------------------------------------------
    test('success response includes inlineCard', () async {
      final template = _makeTemplate(
        name: 'Push Day',
        exercises: [
          _makeExercise(name: 'Bench Press', setCount: 3, reps: 10),
        ],
      );
      _stubGetUserTemplates(mockRepo, [template]);
      _stubUpdateSetReps(mockRepo, template);

      final result = await _makeExecutor().updateTemplateExerciseSetup(
        {
          'templateName': 'Push Day',
          'exerciseName': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'confirmed': true,
        },
        userId,
      );
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['success'], isTrue);
      expect(decoded['inlineCard'], isMap);
    });
  });
}
