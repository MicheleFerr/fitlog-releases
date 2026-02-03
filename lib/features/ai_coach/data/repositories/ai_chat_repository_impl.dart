/// AI Chat Repository Implementation
///
/// Concrete implementation using OpenRouter API.
/// Communicates with Mistral 7B Instruct (free model).
///
/// **Layer**: Data - Repository Implementation
/// **Feature**: AI Coach
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/ai_chat_repository.dart';
import 'package:openrouter_api/openrouter_api.dart';
import 'package:openrouter_api/src/models/open_router_inference.dart';

/// OpenRouter implementation of AI chat repository
class AIChatRepositoryImpl implements AIChatRepository {
  /// Creates repository with API key
  AIChatRepositoryImpl({required String apiKey})
      : _client = OpenRouter.inference(key: apiKey);

  final OpenRouterInference _client;

  @override
  Future<String> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    try {
      // Convert messages to LlmMessage format
      final llmMessages = messages.map((m) {
        final role = m['role'] as String;
        final content = m['content'] as String;

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

      return response.choices.first.content ?? '';
    } catch (e, stackTrace) {
      // Log to Crashlytics
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
