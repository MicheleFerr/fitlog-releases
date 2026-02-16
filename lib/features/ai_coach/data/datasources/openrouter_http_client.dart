/// OpenRouter HTTP Client
///
/// Direct HTTP client for OpenRouter API with full tool calling support.
/// Used when the official SDK doesn't support required features.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OpenRouter API response
class OpenRouterResponse {

  const OpenRouterResponse({
    this.content,
    this.toolCalls = const [],
    this.finishReason,
  });
  final String? content;
  final List<ToolCall> toolCalls;
  final String? finishReason;

  bool get hasToolCalls => toolCalls.isNotEmpty;
}

/// Tool call from AI
class ToolCall {

  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>? ?? {};
    final argumentsString = function['arguments'] as String? ?? '{}';

    return ToolCall(
      id: json['id'] as String? ?? '',
      name: function['name'] as String? ?? 'unknown',
      arguments: jsonDecode(argumentsString) as Map<String, dynamic>,
    );
  }
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
}

/// HTTP client for OpenRouter API
class OpenRouterHttpClient {
  OpenRouterHttpClient({required this.apiKey});

  final String apiKey;
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  /// Send chat completion request with optional tool calling
  ///
  /// Includes automatic retry on timeout (1 attempt).
  Future<OpenRouterResponse> chatCompletion({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
    int maxTokens = 1000,
    Duration timeout = const Duration(seconds: 60),
    bool jsonMode = false,
  }) async {
    const maxRetries = 1;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://fitlog.app',
            'X-Title': 'FitLog AI Coach',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            if (tools != null && tools.isNotEmpty) 'tools': tools,
            if (tools != null && tools.isNotEmpty) 'tool_choice': 'auto',
            'max_tokens': maxTokens,
            if (jsonMode)
              'response_format': {'type': 'json_object'},
          }),
        ).timeout(timeout);

        if (response.statusCode != 200) {
          debugPrint('[OpenRouter] API error ${response.statusCode}: ${response.body}');
          throw Exception(
            'OpenRouter API error ${response.statusCode}: ${response.body}',
          );
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = json['choices'] as List<dynamic>;
        final firstChoice = choices.first as Map<String, dynamic>;
        final message = firstChoice['message'] as Map<String, dynamic>;
        final finishReason = firstChoice['finish_reason'] as String?;

        final toolCallsJson = message['tool_calls'] as List<dynamic>?;
        final toolCalls = toolCallsJson
                ?.map((tc) => ToolCall.fromJson(tc as Map<String, dynamic>))
                .toList() ??
            [];

        return OpenRouterResponse(
          content: message['content'] as String?,
          toolCalls: toolCalls,
          finishReason: finishReason,
        );
      } on TimeoutException {
        if (attempt < maxRetries) {
          debugPrint('[OpenRouter] ⏱️ Timeout (attempt ${attempt + 1}), retrying...');
          continue;
        }
        rethrow;
      }
    }

    // Unreachable, but required by Dart
    throw Exception('OpenRouter: max retries exceeded');
  }
}
