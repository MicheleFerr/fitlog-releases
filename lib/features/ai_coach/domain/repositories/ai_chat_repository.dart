/// AI Chat Repository Interface
///
/// Repository for communicating with OpenRouter API.
/// Abstracts away the HTTP/REST details from domain layer.
///
/// **Layer**: Domain - Repository Interface
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';

/// AI backend response envelope from Cloud Function.
class AIChatRepositoryResponse {
  const AIChatRepositoryResponse({required this.payload, this.quota});

  /// Text response content or `__TOOL_CALLS__:<json>` marker.
  final String payload;

  /// Latest daily quota snapshot returned by backend.
  final AIQuota? quota;
}

/// Repository for AI chat operations
abstract class AIChatRepository {
  /// Send a message to OpenRouter API
  ///
  /// [model] - OpenRouter model ID (e.g., "mistralai/mistral-7b-instruct")
  /// [messages] - Conversation history in OpenAI format
  /// [tools] - Optional function calling tools
  ///
  /// Returns payload + quota metadata from backend.
  Future<AIChatRepositoryResponse> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  });
}
