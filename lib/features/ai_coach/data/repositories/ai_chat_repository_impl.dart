/// AI Chat Repository Implementation
///
/// Concrete implementation using OpenRouter API.
/// Communicates with Mistral 7B Instruct (free model).
///
/// **Layer**: Data - Repository Implementation
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/ai_chat_repository.dart';
import 'package:openrouter_api/openrouter_api.dart';
import 'package:openrouter_api/src/models/open_router_inference.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';

/// OpenRouter implementation of AI chat repository
class AIChatRepositoryImpl implements AIChatRepository {
  /// Creates repository with API key
  AIChatRepositoryImpl({required String apiKey})
      : _client = OpenRouter.inference(key: apiKey),
        _httpClient = OpenRouterHttpClient(apiKey: apiKey);

  final OpenRouterInference _client;
  final OpenRouterHttpClient _httpClient;

  @override
  Future<String> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    try {
      debugPrint('[AI_CHAT_REPO] 🌐 Calling OpenRouter API...');
      debugPrint('[AI_CHAT_REPO] Model: $model');
      debugPrint('[AI_CHAT_REPO] Messages count: ${messages.length}');
      debugPrint('[AI_CHAT_REPO] Tools available: ${tools?.length ?? 0}');

      // Use HTTP client if tools are provided (SDK doesn't support tools)
      if (tools != null && tools.isNotEmpty) {
        debugPrint('[AI_CHAT_REPO] Using HTTP client (tools enabled)');

        final response = await _httpClient.chatCompletion(
          model: model,
          messages: messages,
          tools: tools,
          maxTokens: 1000,
        );

        if (response.hasToolCalls) {
          debugPrint('[AI_CHAT_REPO] 🛠️ AI wants to call ${response.toolCalls.length} tools');

          // Serialize tool calls to JSON (robust encoding)
          final toolCallsJson = response.toolCalls.map((tc) => {
            'id': tc.id,
            'name': tc.name,
            'arguments': tc.arguments,
          }).toList();

          // Return special marker + JSON-encoded tool calls
          // Service will handle execution and re-call
          return '__TOOL_CALLS__:${jsonEncode(toolCallsJson)}';
        }

        debugPrint('[AI_CHAT_REPO] ✅ Got text response from OpenRouter');
        return response.content ?? '';
      }

      // Fallback to SDK for non-tool completions
      debugPrint('[AI_CHAT_REPO] Using SDK (no tools)');

      final llmMessages = messages.map((m) {
        final role = m['role'] as String? ?? 'user';
        final content = m['content'] as String? ?? '';

        switch (role) {
          case 'system':
            return LlmMessage.system(content);
          case 'assistant':
            return LlmMessage.assistant(content);
          case 'user':
          default:
            return LlmMessage.user(LlmMessageContent.text(content));
        }
      }).toList();

      final response = await _client.getCompletion(
        modelId: model,
        messages: llmMessages,
        maxTokens: 1000,
      );

      debugPrint('[AI_CHAT_REPO] ✅ Got response from OpenRouter');

      if (response.choices.isEmpty) {
        debugPrint('[AI_CHAT_REPO] ⚠️ Empty choices in response');
        return '';
      }

      return response.choices.first.content;
    } catch (e, stackTrace) {
      debugPrint('[AI_CHAT_REPO] ❌ OpenRouter API error: $e');
      debugPrint('[AI_CHAT_REPO] Stack trace: $stackTrace');

      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'OpenRouter API error in AI Coach',
        information: ['model: $model', 'messagesCount: ${messages.length}'],
      );

      throw Exception('OpenRouter error: $e');
    }
  }
}
