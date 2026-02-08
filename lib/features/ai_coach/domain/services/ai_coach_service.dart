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
  /// [userId] - Current authenticated user ID for context aggregation
  ///
  /// Returns AI response with optional tool call
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
    required String userId,
  });

  /// Invalidate the context cache
  ///
  /// Call this after significant user actions that change context:
  /// - Completing a workout
  /// - Adding body measurements
  /// - Updating user profile
  void invalidateContextCache();
}

/// Response from AI service
class AIServiceResponse {

  const AIServiceResponse({
    required this.content,
    this.toolCall,
    this.suggestions,
  });
  /// AI-generated text content
  final String content;

  /// Optional tool call made by AI
  final AIToolCall? toolCall;

  /// Exercise name suggestions when a tool search didn't find exact match
  final List<String>? suggestions;
}
