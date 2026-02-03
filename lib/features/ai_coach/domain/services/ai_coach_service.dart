/// AI Coach Service Interface
///
/// Domain service for AI Coach functionality.
/// Handles message sending with conversation history and tool calling.
///
/// **Layer**: Domain - Service Interface
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

/// AI Coach service interface
abstract class AICoachService {
  /// Send a message to the AI coach
  ///
  /// [userMessage] - User's text message
  /// [conversationHistory] - Previous messages in conversation
  ///
  /// Returns AI response with optional tool call
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
  });
}

/// Response from AI service
class AIServiceResponse {
  /// AI-generated text content
  final String content;

  /// Optional tool call made by AI
  final AIToolCall? toolCall;

  const AIServiceResponse({
    required this.content,
    this.toolCall,
  });
}
