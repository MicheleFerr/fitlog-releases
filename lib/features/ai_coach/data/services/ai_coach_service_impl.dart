/// AI Coach Service Implementation
///
/// Core service implementing AI Coach functionality.
/// Includes medical keyword blocking, tool calling, and system prompt.
///
/// **Layer**: Data - Service Implementation
/// **Feature**: AI Coach
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_safety_keywords.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_system_prompt.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_service.dart';

/// Implementation of AI Coach service
class AICoachServiceImpl implements AICoachService {
  AICoachServiceImpl({
    required this.chatRepository,
    required this.toolExecutor,
    required this.contextAggregator,
  });

  final AIChatRepositoryImpl chatRepository;
  final AIToolExecutor toolExecutor;
  final AnalyticsAggregator contextAggregator;

  /// Mistral 7B Instruct (free model on OpenRouter)
  static const String _model = 'mistralai/mistral-7b-instruct';

  @override
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
    required String userId,
  }) async {
    try {
      // 1. Safety check - block medical keywords
      final medicalBlock = _checkMedicalKeywords(userMessage);
      if (medicalBlock != null) {
        return AIServiceResponse(content: medicalBlock);
      }

      // 2. Build message list
      final messages = await _buildMessages(userMessage, conversationHistory, userId);

      // 3. Call OpenRouter (tools not implemented in MVP)
      final response = await chatRepository.sendMessage(
        model: _model,
        messages: messages,
      );

      return AIServiceResponse(content: response);
    } catch (e, stackTrace) {
      // Log to Crashlytics
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach service error',
        information: ['userMessage: $userMessage'],
      );

      // Conservative fallback
      return AIServiceResponse(
        content:
            '⚠️ Scusa, ho riscontrato un errore. Riprova tra qualche secondo.',
      );
    }
  }

  /// Build messages for OpenRouter API
  Future<List<Map<String, dynamic>>> _buildMessages(
    String userMsg,
    List<AIMessage> history,
    String userId,
  ) async {
    // Get base context with real user ID
    final context = await contextAggregator.aggregateContext(userId: userId);

    return [
      // System prompt with user context
      {
        'role': 'system',
        'content': '$aiSystemPrompt\n\n${context.toPromptString()}',
      },

      // Conversation history (only visible messages)
      ...history
          .where((m) => m.isVisible)
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList(),

      // New user message
      {
        'role': 'user',
        'content': userMsg,
      },
    ];
  }

  /// Check message for medical keywords and block if found
  String? _checkMedicalKeywords(String message) {
    final lowerMessage = message.toLowerCase();

    for (final keyword in medicalSafetyKeywords) {
      if (lowerMessage.contains(keyword.toLowerCase())) {
        return '🚨 Ho rilevato "$keyword" nel tuo messaggio.\n\n'
            'Per sintomi fisici, dolori o infortuni, consulta un medico o fisioterapista.\n\n'
            'Disclaimer: Non sono un medico e non posso dare consigli medici.';
      }
    }

    return null;
  }
}
