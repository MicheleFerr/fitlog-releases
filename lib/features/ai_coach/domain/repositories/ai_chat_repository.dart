/// AI Chat Repository Interface
///
/// Repository for communicating with OpenRouter API.
/// Abstracts away the HTTP/REST details from domain layer.
///
/// **Layer**: Domain - Repository Interface
/// **Feature**: AI Coach
library;

/// Repository for AI chat operations
abstract class AIChatRepository {
  /// Send a message to OpenRouter API
  ///
  /// [model] - OpenRouter model ID (e.g., "mistralai/mistral-7b-instruct")
  /// [messages] - Conversation history in OpenAI format
  /// [tools] - Optional function calling tools
  ///
  /// Returns AI-generated text response
  Future<String> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  });
}
