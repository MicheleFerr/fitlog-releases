/// Workout Import AI Client
///
/// DataSource that interfaces with OpenRouter AI to parse
/// workout text and photos into structured JSON.
///
/// **Layer**: Data - DataSource
/// **Feature**: Workout Import
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';

/// AI client for parsing workout text/photos into structured JSON
class WorkoutImportAiClient {
  WorkoutImportAiClient({required this.httpClient});

  final OpenRouterHttpClient httpClient;

  static const _textModel = 'meta-llama/llama-3.3-70b-instruct:free';
  // Google Gemini 2.0 Flash - fast, reliable vision model
  static const _visionModel = 'google/gemini-2.0-flash-001';

  static const _systemPrompt = '''You are a workout plan parser. Extract exercise data from the input and return ONLY valid JSON.

Rules:
- Output MUST be a single JSON object, no markdown, no explanation
- Each exercise needs: name (original language), sets array with reps/weight/duration
- Group exercises by day if multiple days are present
- If weight unit is not specified, assume kg
- "4x8" means 4 sets of 8 reps
- "3x10-12" means 3 sets of 10-12 reps (use minReps/maxReps)
- "AMRAP" or "max" means isMaxReps: true
- If no day structure, use a single day named "Workout"

JSON schema:
{
  "days": [
    {
      "name": "Day name",
      "exercises": [
        {
          "rawName": "Exercise Name",
          "muscleGroup": "chest|back|shoulders|arms|legs|abs|cardio|other",
          "sets": [
            {"reps": 8, "weight": 80.0},
            {"minReps": 10, "maxReps": 12},
            {"isMaxReps": true},
            {"durationSeconds": 30}
          ],
          "restSeconds": 90,
          "notes": "optional notes",
          "supersetGroup": "A"
        }
      ]
    }
  ]
}''';

  /// Parse workout text into structured JSON
  Future<Map<String, dynamic>> parseText(String text) async {
    final response = await httpClient.chatCompletion(
      model: _textModel,
      messages: [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': 'Parse this workout plan:\n\n$text'},
      ],
      maxTokens: 4000,
      timeout: const Duration(seconds: 45),
      jsonMode: true,
    );

    final content = response.content;
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('AI returned empty response');
    }

    return _extractJson(content);
  }

  /// Parse workout photo into structured JSON
  Future<Map<String, dynamic>> parseImage(String base64Image) async {
    // Note: jsonMode disabled for vision - not all providers support
    // response_format with multimodal input. The system prompt enforces JSON output.
    final response = await httpClient.chatCompletion(
      model: _visionModel,
      messages: [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  'Parse the workout plan in this image. Return ONLY the JSON object, no markdown.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      maxTokens: 4000,
      timeout: const Duration(seconds: 60),
    );

    final content = response.content;
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('AI returned empty response for image');
    }

    return _extractJson(content);
  }

  /// Extract and validate JSON from AI response, with repair attempts
  Map<String, dynamic> _extractJson(String content) {
    // Try direct parse first
    try {
      final json = jsonDecode(content.trim());
      if (json is Map<String, dynamic>) return json;
    } catch (_) {
      // Try to extract JSON from markdown code blocks
    }

    // Try extracting from markdown code blocks
    final codeBlockMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
    ).firstMatch(content);
    if (codeBlockMatch != null) {
      try {
        final json = jsonDecode(codeBlockMatch.group(1)!.trim());
        if (json is Map<String, dynamic>) return json;
      } catch (_) {
        // Continue to repair
      }
    }

    // Try to find JSON object in response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    if (jsonMatch != null) {
      try {
        final json = jsonDecode(jsonMatch.group(0)!);
        if (json is Map<String, dynamic>) return json;
      } catch (_) {
        // Try repair
      }
    }

    // Attempt basic JSON repair
    final repaired = _repairJson(content);
    if (repaired != null) return repaired;

    debugPrint('[WorkoutImport] Failed to parse AI response: ${content.substring(0, content.length.clamp(0, 200))}');
    throw const FormatException('Could not extract valid JSON from AI response');
  }

  /// Attempt basic JSON repair for common AI mistakes
  Map<String, dynamic>? _repairJson(String content) {
    try {
      var repaired = content.trim();

      // Remove trailing commas before } or ]
      repaired = repaired.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

      // Try to fix unquoted keys
      repaired = repaired.replaceAllMapped(
        RegExp(r'(\{|,)\s*(\w+)\s*:'),
        (m) => '${m.group(1)}"${m.group(2)}":',
      );

      final json = jsonDecode(repaired);
      if (json is Map<String, dynamic>) return json;
    } catch (_) {
      // Repair failed
    }
    return null;
  }
}
