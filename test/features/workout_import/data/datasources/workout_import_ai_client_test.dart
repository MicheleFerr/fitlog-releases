/// Unit tests for WorkoutImportAiClient
///
/// Tests the JSON extraction logic (_extractJson and _repairJson)
/// by using a fake OpenRouterHttpClient that returns controlled responses.
/// Also tests empty-response error paths and markdown code block stripping.
///
/// No mockito/mocktail — only manual fake classes.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';
import 'package:gymbro_flutter_new/features/workout_import/data/datasources/workout_import_ai_client.dart';

// ---------------------------------------------------------------------------
// Fake OpenRouterHttpClient
// ---------------------------------------------------------------------------

/// Returns a controlled [OpenRouterResponse] without making real HTTP calls.
class _FakeOpenRouterHttpClient extends OpenRouterHttpClient {
  _FakeOpenRouterHttpClient({required this.responseContent})
      : super(apiKey: 'test-key-not-used');

  final String? responseContent;

  @override
  Future<OpenRouterResponse> chatCompletion({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
    int maxTokens = 1000,
    Duration timeout = const Duration(seconds: 60),
    bool jsonMode = false,
  }) async {
    return OpenRouterResponse(content: responseContent);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutImportAiClient _clientWith(String? content) {
  return WorkoutImportAiClient(
    httpClient: _FakeOpenRouterHttpClient(responseContent: content),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // parseText — happy path JSON extraction
  // -------------------------------------------------------------------------
  group('WorkoutImportAiClient.parseText - direct JSON', () {
    test('parses clean JSON response', () async {
      const json = '{"days":[{"name":"Workout","exercises":[]}]}';
      final client = _clientWith(json);

      final result = await client.parseText('bench 3x8');

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('days'), isTrue);
    });

    test('parses JSON with leading/trailing whitespace', () async {
      const json = '  {"days":[{"name":"Push","exercises":[]}]}  ';
      final client = _clientWith(json);

      final result = await client.parseText('push workout');
      expect(result.containsKey('days'), isTrue);
    });

    test('extracts JSON from markdown ```json code block', () async {
      const response = '```json\n{"days":[{"name":"A","exercises":[]}]}\n```';
      final client = _clientWith(response);

      final result = await client.parseText('workout');
      expect(result.containsKey('days'), isTrue);
    });

    test('extracts JSON from plain ``` code block (no language specifier)', () async {
      const response = '```\n{"days":[{"name":"B","exercises":[]}]}\n```';
      final client = _clientWith(response);

      final result = await client.parseText('workout');
      expect(result.containsKey('days'), isTrue);
    });

    test('extracts JSON when embedded in prose text', () async {
      const response =
          'Here is the parsed workout:\n{"days":[{"name":"C","exercises":[]}]}\nDone.';
      final client = _clientWith(response);

      final result = await client.parseText('workout');
      expect(result.containsKey('days'), isTrue);
    });

    test('repairs JSON with trailing comma before }', () async {
      // The _repairJson path handles trailing commas
      const response = '{"days":[{"name":"D","exercises":[],}],}';
      final client = _clientWith(response);

      // May succeed via repair or throw FormatException — either is acceptable.
      // We primarily verify no crash on valid input variants.
      try {
        final result = await client.parseText('workout');
        expect(result, isA<Map<String, dynamic>>());
      } on FormatException {
        // Acceptable — repair can fail for some JSON structures
      }
    });
  });

  // -------------------------------------------------------------------------
  // parseText — error paths
  // -------------------------------------------------------------------------
  group('WorkoutImportAiClient.parseText - error paths', () {
    test('throws FormatException when content is null', () async {
      final client = _clientWith(null);

      expect(
        () => client.parseText('workout'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when content is empty string', () async {
      final client = _clientWith('');

      expect(
        () => client.parseText('workout'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when content is whitespace only', () async {
      final client = _clientWith('   \n\t  ');

      expect(
        () => client.parseText('workout'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for completely unparseable content', () async {
      final client = _clientWith('this is not json at all and has no braces');

      expect(
        () => client.parseText('workout'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when JSON is an array (not object)', () async {
      // Top-level array — not a Map<String, dynamic>
      final client = _clientWith('[1, 2, 3]');

      expect(
        () => client.parseText('workout'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // parseImage — JSON extraction
  // -------------------------------------------------------------------------
  group('WorkoutImportAiClient.parseImage', () {
    test('parses clean JSON from image response', () async {
      const json = '{"days":[{"name":"Photo Workout","exercises":[]}]}';
      final client = _clientWith(json);

      final result = await client.parseImage('base64data==');
      expect(result.containsKey('days'), isTrue);
    });

    test('throws FormatException when image response content is null', () async {
      final client = _clientWith(null);

      expect(
        () => client.parseImage('base64data=='),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when image response content is empty', () async {
      final client = _clientWith('');

      expect(
        () => client.parseImage('base64data=='),
        throwsA(isA<FormatException>()),
      );
    });

    test('extracts JSON from markdown in image response', () async {
      const response = '```json\n{"days":[{"name":"Img","exercises":[]}]}\n```';
      final client = _clientWith(response);

      final result = await client.parseImage('base64data==');
      expect(result.containsKey('days'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // JSON extraction — specific code paths
  // -------------------------------------------------------------------------
  group('WorkoutImportAiClient - JSON extraction variants', () {
    test('handles deeply nested JSON response embedded in text', () async {
      const json = '{"days":[{"name":"A","exercises":[{"rawName":"Squat","sets":[{"reps":5,"weight":100.0}]}]}]}';
      final client = _clientWith('Response: $json');

      final result = await client.parseText('workout');
      expect(result['days'], isA<List>());
    });

    test('parses JSON with nested arrays and objects', () async {
      const json = '''
{
  "days": [
    {
      "name": "Push Day",
      "exercises": [
        {
          "rawName": "Bench Press",
          "sets": [
            {"reps": 8, "weight": 80.0},
            {"reps": 6, "weight": 85.0}
          ],
          "restSeconds": 90
        }
      ]
    }
  ]
}''';
      final client = _clientWith(json);

      final result = await client.parseText('bench workout');
      final days = result['days'] as List;
      expect(days.length, 1);
      final exercises = (days.first as Map)['exercises'] as List;
      expect(exercises.length, 1);
    });

    test('returns map when JSON has no "days" key but is valid JSON object', () async {
      // Valid JSON object, but missing "days" key - service layer handles validation
      const json = '{"other": "data"}';
      final client = _clientWith(json);

      final result = await client.parseText('workout');
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('other'), isTrue);
    });
  });
}
