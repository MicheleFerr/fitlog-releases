/// Unit tests for WorkoutImportService
///
/// Tests text preprocessing, JSON mapping, multi-day workout detection,
/// exercise parsing, set parsing, and edge cases.
///
/// Note: ExerciseFuzzyMatcher is a static class using an isolate internally.
/// We provide an empty exercise database to isolate service logic from
/// fuzzy matching, and verify that match fields remain null when db is empty.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout_import/data/datasources/workout_import_ai_client.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/services/workout_import_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Fake WorkoutImportAiClient
// ---------------------------------------------------------------------------

/// Fake AI client that returns predefined JSON without network calls.
///
/// Extends [WorkoutImportAiClient] and overrides parseText/parseImage.
/// Passes a dummy [OpenRouterHttpClient] to satisfy the super() constructor
/// since all network methods are overridden and never called.
class FakeWorkoutImportAiClient extends WorkoutImportAiClient {
  FakeWorkoutImportAiClient({
    this.textResult,
    this.imageResult,
    this.throwOnText,
    this.throwOnImage,
  }) : super(httpClient: OpenRouterHttpClient(apiKey: 'test-key-not-used'));

  /// The JSON map to return from parseText
  Map<String, dynamic>? textResult;

  /// The JSON map to return from parseImage
  Map<String, dynamic>? imageResult;

  /// If set, parseText throws this exception
  Exception? throwOnText;

  /// If set, parseImage throws this exception
  Exception? throwOnImage;

  @override
  Future<Map<String, dynamic>> parseText(String text) async {
    if (throwOnText != null) throw throwOnText!;
    return textResult ?? _emptyDaysJson();
  }

  @override
  Future<Map<String, dynamic>> parseImage(String base64Image) async {
    if (throwOnImage != null) throw throwOnImage!;
    return imageResult ?? _emptyDaysJson();
  }

  static Map<String, dynamic> _emptyDaysJson() => {
    'days': [
      {
        'name': 'Workout',
        'exercises': <dynamic>[],
      },
    ],
  };
}

// ---------------------------------------------------------------------------
// Test Helpers
// ---------------------------------------------------------------------------

/// Creates a minimal ExerciseDefinition for use in exercise database.
ExerciseDefinition makeExercise({
  required String id,
  required String nome,
  List<String> focus = const [],
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: focus,
    muscoliSecondari: [],
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push',
    rangeRipetizioni: '6-12',
    countingMode: ExerciseCountingMode.weighted,
  );
}

/// Builds a minimal valid JSON response for a single-day workout.
Map<String, dynamic> singleDayJson({
  String dayName = 'Workout',
  List<Map<String, dynamic>> exercises = const [],
}) {
  return {
    'days': [
      {'name': dayName, 'exercises': exercises},
    ],
  };
}

/// Builds a minimal valid JSON response for a multi-day workout.
Map<String, dynamic> multiDayJson(List<Map<String, dynamic>> days) {
  return {'days': days};
}

/// Builds a minimal exercise JSON object.
Map<String, dynamic> exerciseJson({
  required String rawName,
  List<Map<String, dynamic>> sets = const [],
  int? restSeconds,
  String? muscleGroup,
  String? notes,
  String? supersetGroup,
}) {
  return {
    'rawName': rawName,
    'sets': sets,
    if (restSeconds != null) 'restSeconds': restSeconds,
    if (muscleGroup != null) 'muscleGroup': muscleGroup,
    if (notes != null) 'notes': notes,
    if (supersetGroup != null) 'supersetGroup': supersetGroup,
  };
}

/// Builds a set JSON object.
Map<String, dynamic> setJson({
  int? reps,
  double? weight,
  bool isMaxReps = false,
  int? durationSeconds,
  int? minReps,
  int? maxReps,
}) {
  return {
    if (reps != null) 'reps': reps,
    'isMaxReps': isMaxReps,
    if (weight != null) 'weight': weight,
    if (durationSeconds != null) 'durationSeconds': durationSeconds,
    if (minReps != null) 'minReps': minReps,
    if (maxReps != null) 'maxReps': maxReps,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeWorkoutImportAiClient fakeClient;
  late WorkoutImportService service;

  // Empty exercise database - no fuzzy matches will be found.
  const emptyDb = <ExerciseDefinition>[];

  setUp(() {
    fakeClient = FakeWorkoutImportAiClient();
    service = WorkoutImportService(aiClient: fakeClient);
  });

  // ---------------------------------------------------------------------------
  // parseFromText - text preprocessing
  // ---------------------------------------------------------------------------
  group('parseFromText - text preprocessing', () {
    test('throws FormatException for empty string', () async {
      expect(
        () => service.parseFromText(text: '', exerciseDb: emptyDb),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for whitespace-only string', () async {
      expect(
        () => service.parseFromText(text: '   \n\t  ', exerciseDb: emptyDb),
        throwsA(isA<FormatException>()),
      );
    });

    test('replaces × with x before sending to AI', () async {
      // Verify text reaches AI cleaned - we inspect by capturing via fake client
      String? captured;
      final capturingClient = _CapturingFakeClient(
        onParseText: (text) {
          captured = text;
          return singleDayJson();
        },
      );
      final svc = WorkoutImportService(aiClient: capturingClient);
      await svc.parseFromText(text: 'Bench 3×8', exerciseDb: emptyDb);
      expect(captured, contains('3x8'));
      expect(captured, isNot(contains('×')));
    });

    test('replaces X (uppercase) with x before sending to AI', () async {
      String? captured;
      final capturingClient = _CapturingFakeClient(
        onParseText: (text) {
          captured = text;
          return singleDayJson();
        },
      );
      final svc = WorkoutImportService(aiClient: capturingClient);
      await svc.parseFromText(text: 'Squat 5X5', exerciseDb: emptyDb);
      expect(captured, contains('5x5'));
      expect(captured, isNot(contains('5X5')));
    });

    test('normalizes excessive blank lines to max two newlines', () async {
      String? captured;
      final capturingClient = _CapturingFakeClient(
        onParseText: (text) {
          captured = text;
          return singleDayJson();
        },
      );
      final svc = WorkoutImportService(aiClient: capturingClient);
      await svc.parseFromText(
        text: 'Line A\n\n\n\n\nLine B',
        exerciseDb: emptyDb,
      );
      expect(captured, isNotNull);
      expect(captured!.contains('\n\n\n'), false);
    });

    test('trims leading and trailing whitespace', () async {
      String? captured;
      final capturingClient = _CapturingFakeClient(
        onParseText: (text) {
          captured = text;
          return singleDayJson();
        },
      );
      final svc = WorkoutImportService(aiClient: capturingClient);
      await svc.parseFromText(
        text: '   Bench Press 3x8   ',
        exerciseDb: emptyDb,
      );
      expect(captured, isNotNull);
      expect(captured!.startsWith(' '), false);
      expect(captured!.endsWith(' '), false);
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromText - JSON mapping
  // ---------------------------------------------------------------------------
  group('parseFromText - JSON to domain mapping', () {
    test('throws FormatException when AI returns empty days array', () async {
      fakeClient.textResult = {'days': <dynamic>[]};
      expect(
        () => service.parseFromText(text: 'workout text', exerciseDb: emptyDb),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when AI returns no days key', () async {
      fakeClient.textResult = {'other': 'data'};
      expect(
        () => service.parseFromText(text: 'workout text', exerciseDb: emptyDb),
        throwsA(isA<FormatException>()),
      );
    });

    test('maps single-day workout correctly', () async {
      fakeClient.textResult = singleDayJson(
        dayName: 'Push Day',
        exercises: [
          exerciseJson(
            rawName: 'Bench Press',
            sets: [setJson(reps: 8, weight: 80.0)],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'Bench Press 3x8',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(1));
      expect(result.days.first.name, 'Push Day');
      expect(result.days.first.exercises, hasLength(1));
      expect(result.days.first.exercises.first.rawName, 'Bench Press');
      expect(result.hasMultipleDays, false);
    });

    test('hasMultipleDays is true when days.length > 1', () async {
      fakeClient.textResult = multiDayJson([
        {'name': 'Push', 'exercises': <dynamic>[]},
        {'name': 'Pull', 'exercises': <dynamic>[]},
      ]);

      final result = await service.parseFromText(
        text: 'Push/Pull program',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(2));
      expect(result.hasMultipleDays, true);
    });

    test('hasMultipleDays is false when only one day', () async {
      fakeClient.textResult = singleDayJson();

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.hasMultipleDays, false);
    });

    test('maps rawText from input text', () async {
      fakeClient.textResult = singleDayJson();

      final result = await service.parseFromText(
        text: 'Original workout text',
        exerciseDb: emptyDb,
      );

      expect(result.rawText, isNotNull);
      // rawText is from original input (before preprocessing)
      expect(result.rawText, contains('Original workout text'));
    });

    test('uses default day name "Workout" when JSON day name is null', () async {
      fakeClient.textResult = {
        'days': [
          {'name': null, 'exercises': <dynamic>[]},
        ],
      };

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.name, 'Workout');
    });

    test('uses default rawName "Unknown" when JSON rawName is null', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          {'rawName': null, 'sets': <dynamic>[]},
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises.first.rawName, 'Unknown');
    });

    test('maps multiple exercises in a day', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(rawName: 'Bench Press', sets: []),
          exerciseJson(rawName: 'Squat', sets: []),
          exerciseJson(rawName: 'Deadlift', sets: []),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises, hasLength(3));
      expect(result.days.first.exercises[0].rawName, 'Bench Press');
      expect(result.days.first.exercises[1].rawName, 'Squat');
      expect(result.days.first.exercises[2].rawName, 'Deadlift');
    });

    test('maps optional exercise fields (restSeconds, muscleGroup, notes, supersetGroup)', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Bench Press',
            sets: [],
            restSeconds: 90,
            muscleGroup: 'chest',
            notes: 'Touch and go',
            supersetGroup: 'A',
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final ex = result.days.first.exercises.first;
      expect(ex.restSeconds, 90);
      expect(ex.muscleGroup, 'chest');
      expect(ex.notes, 'Touch and go');
      expect(ex.supersetGroup, 'A');
    });

    test('maps null optional exercise fields gracefully', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Squat', sets: [])],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final ex = result.days.first.exercises.first;
      expect(ex.restSeconds, isNull);
      expect(ex.muscleGroup, isNull);
      expect(ex.notes, isNull);
      expect(ex.supersetGroup, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromText - set parsing
  // ---------------------------------------------------------------------------
  group('parseFromText - set parsing', () {
    test('maps reps and weight correctly', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Bench',
            sets: [setJson(reps: 8, weight: 80.0)],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.reps, 8);
      expect(set.weight, 80.0);
      expect(set.isMaxReps, false);
    });

    test('maps AMRAP (isMaxReps: true) set', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Pull-up',
            sets: [setJson(isMaxReps: true)],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.isMaxReps, true);
      expect(set.reps, isNull);
    });

    test('maps timed set (durationSeconds)', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Plank',
            sets: [setJson(durationSeconds: 60)],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.durationSeconds, 60);
      expect(set.reps, isNull);
    });

    test('maps rep-range set (minReps/maxReps)', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Cable Row',
            sets: [setJson(minReps: 10, maxReps: 12, weight: 70.0)],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.minReps, 10);
      expect(set.maxReps, 12);
      expect(set.weight, 70.0);
      expect(set.reps, isNull);
    });

    test('maps multiple sets for a single exercise', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Squat',
            sets: [
              setJson(reps: 5, weight: 100.0),
              setJson(reps: 5, weight: 105.0),
              setJson(reps: 5, weight: 110.0),
            ],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final sets = result.days.first.exercises.first.sets;
      expect(sets, hasLength(3));
      expect(sets[0].weight, 100.0);
      expect(sets[1].weight, 105.0);
      expect(sets[2].weight, 110.0);
    });

    test('handles empty sets array for an exercise', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Stretch', sets: [])],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises.first.sets, isEmpty);
    });

    test('defaults isMaxReps to false when missing from set JSON', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Curl',
            sets: [
              {'reps': 10, 'weight': 20.0},
            ],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.isMaxReps, false);
    });

    test('converts int weight from JSON to double', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Bench',
            sets: [
              {'reps': 5, 'isMaxReps': false, 'weight': 100},
            ],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.weight, 100.0);
      expect(set.weight, isA<double>());
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromText - multi-day workouts
  // ---------------------------------------------------------------------------
  group('parseFromText - multi-day workouts', () {
    test('maps push/pull/legs 3-day split', () async {
      fakeClient.textResult = multiDayJson([
        {
          'name': 'Push',
          'exercises': [exerciseJson(rawName: 'Bench Press', sets: [])],
        },
        {
          'name': 'Pull',
          'exercises': [exerciseJson(rawName: 'Barbell Row', sets: [])],
        },
        {
          'name': 'Legs',
          'exercises': [exerciseJson(rawName: 'Squat', sets: [])],
        },
      ]);

      final result = await service.parseFromText(
        text: '3-day PPL program',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(3));
      expect(result.hasMultipleDays, true);
      expect(result.days[0].name, 'Push');
      expect(result.days[1].name, 'Pull');
      expect(result.days[2].name, 'Legs');
    });

    test('preserves exercise order within each day', () async {
      final exercises = List.generate(
        5,
        (i) => exerciseJson(rawName: 'Exercise $i', sets: []),
      );
      fakeClient.textResult = singleDayJson(exercises: exercises);

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      for (var i = 0; i < 5; i++) {
        expect(result.days.first.exercises[i].rawName, 'Exercise $i');
      }
    });

    test('handles missing exercises key in day JSON gracefully', () async {
      fakeClient.textResult = {
        'days': [
          {'name': 'Empty Day'},
        ],
      };

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromText - fuzzy matching with empty database
  // ---------------------------------------------------------------------------
  group('parseFromText - fuzzy matching (empty db)', () {
    test('exercise has null match fields when db is empty', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Bench Press', sets: [])],
      );

      final result = await service.parseFromText(
        text: 'Bench Press 3x8',
        exerciseDb: emptyDb,
      );

      final ex = result.days.first.exercises.first;
      expect(ex.matchedExerciseId, isNull);
      expect(ex.matchedExerciseName, isNull);
      expect(ex.matchConfidence, isNull);
      expect(ex.matchedCategory, isNull);
    });

    test('matchLevel is none when no db match', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Random Exercise', sets: [])],
      );

      final result = await service.parseFromText(
        text: 'Random Exercise 3x10',
        exerciseDb: emptyDb,
      );

      final ex = result.days.first.exercises.first;
      expect(ex.matchLevel, MatchLevel.none);
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromImage
  // ---------------------------------------------------------------------------
  group('parseFromImage', () {
    test('maps single-day workout from image', () async {
      fakeClient.imageResult = singleDayJson(
        dayName: 'Workout A',
        exercises: [
          exerciseJson(
            rawName: 'Overhead Press',
            sets: [setJson(reps: 5, weight: 60.0)],
          ),
        ],
      );

      final result = await service.parseFromImage(
        base64Image: 'base64encodedimage==',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(1));
      expect(result.days.first.name, 'Workout A');
      expect(result.days.first.exercises.first.rawName, 'Overhead Press');
    });

    test('rawText is null for image-based parsing', () async {
      fakeClient.imageResult = singleDayJson();

      final result = await service.parseFromImage(
        base64Image: 'base64data==',
        exerciseDb: emptyDb,
      );

      // Image parsing passes null as rawText internally
      expect(result.rawText, isNull);
    });

    test('propagates exception from AI client', () async {
      fakeClient.throwOnImage = const FormatException('Vision API error');

      expect(
        () => service.parseFromImage(
          base64Image: 'image==',
          exerciseDb: emptyDb,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('maps multi-day workout from image', () async {
      fakeClient.imageResult = multiDayJson([
        {'name': 'Upper', 'exercises': <dynamic>[]},
        {'name': 'Lower', 'exercises': <dynamic>[]},
      ]);

      final result = await service.parseFromImage(
        base64Image: 'image==',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(2));
      expect(result.hasMultipleDays, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Error handling and edge cases
  // ---------------------------------------------------------------------------
  group('error handling', () {
    test('propagates FormatException from AI client during text parsing', () async {
      fakeClient.throwOnText = const FormatException('AI unavailable');

      expect(
        () => service.parseFromText(text: 'workout', exerciseDb: emptyDb),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates general exception from AI client', () async {
      fakeClient.throwOnText = Exception('Network error');

      expect(
        () => service.parseFromText(text: 'workout', exerciseDb: emptyDb),
        throwsA(isA<Exception>()),
      );
    });

    test('handles single exercise with very large set count', () async {
      final manySets = List.generate(
        20,
        (i) => setJson(reps: 10, weight: 50.0 + i),
      );
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Leg Extension', sets: manySets)],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises.first.sets, hasLength(20));
    });

    test('handles workout with many days', () async {
      final days = List.generate(
        7,
        (i) => {'name': 'Day ${i + 1}', 'exercises': <dynamic>[]},
      );
      fakeClient.textResult = multiDayJson(days);

      final result = await service.parseFromText(
        text: 'full week program',
        exerciseDb: emptyDb,
      );

      expect(result.days, hasLength(7));
      expect(result.hasMultipleDays, true);
    });

    test('handles sets JSON with null values', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Cable Fly',
            sets: [
              {
                'reps': null,
                'isMaxReps': null,
                'weight': null,
                'durationSeconds': null,
                'minReps': null,
                'maxReps': null,
              },
            ],
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final set = result.days.first.exercises.first.sets.first;
      expect(set.reps, isNull);
      expect(set.isMaxReps, false); // defaults to false when null
      expect(set.weight, isNull);
    });

    test('text with only × separator is preprocessed and sent to AI', () async {
      // × alone should be replaced with x, but then trimmed - still non-empty
      String? captured;
      final capturingClient = _CapturingFakeClient(
        onParseText: (text) {
          captured = text;
          return singleDayJson();
        },
      );
      final svc = WorkoutImportService(aiClient: capturingClient);
      await svc.parseFromText(text: 'Squat 3×10 @80kg', exerciseDb: emptyDb);
      expect(captured, contains('3x10'));
    });

    test('result preserves rawText from original input (not preprocessed)', () async {
      // The service passes the original text as rawText, before preprocessing
      fakeClient.textResult = singleDayJson();

      final result = await service.parseFromText(
        text: 'Bench Press 3×8',
        exerciseDb: emptyDb,
      );

      // rawText is the original input text passed by the caller
      expect(result.rawText, 'Bench Press 3×8');
    });
  });

  // ---------------------------------------------------------------------------
  // parseFromText - superset detection
  // ---------------------------------------------------------------------------
  group('parseFromText - superset parsing', () {
    test('maps supersetGroup for paired exercises', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [
          exerciseJson(
            rawName: 'Bench Press',
            sets: [setJson(reps: 10)],
            supersetGroup: 'A',
          ),
          exerciseJson(
            rawName: 'Pull-up',
            sets: [setJson(reps: 10)],
            supersetGroup: 'A',
          ),
          exerciseJson(
            rawName: 'Squat',
            sets: [setJson(reps: 8)],
            supersetGroup: 'B',
          ),
        ],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      final exercises = result.days.first.exercises;
      expect(exercises[0].supersetGroup, 'A');
      expect(exercises[1].supersetGroup, 'A');
      expect(exercises[2].supersetGroup, 'B');
    });

    test('exercises without supersetGroup have null value', () async {
      fakeClient.textResult = singleDayJson(
        exercises: [exerciseJson(rawName: 'Deadlift', sets: [])],
      );

      final result = await service.parseFromText(
        text: 'workout',
        exerciseDb: emptyDb,
      );

      expect(result.days.first.exercises.first.supersetGroup, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Capturing fake client for text inspection
// ---------------------------------------------------------------------------

class _CapturingFakeClient extends WorkoutImportAiClient {
  _CapturingFakeClient({required this.onParseText})
      : super(httpClient: OpenRouterHttpClient(apiKey: 'test-key-not-used'));

  final Map<String, dynamic> Function(String text) onParseText;

  @override
  Future<Map<String, dynamic>> parseText(String text) async {
    return onParseText(text);
  }

  @override
  Future<Map<String, dynamic>> parseImage(String base64Image) async {
    return {
      'days': [
        {'name': 'Workout', 'exercises': <dynamic>[]},
      ],
    };
  }
}
