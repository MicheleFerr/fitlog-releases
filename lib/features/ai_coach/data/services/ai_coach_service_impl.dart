/// AI Coach Service Implementation
///
/// Core service implementing AI Coach functionality.
/// Includes medical keyword blocking, tool calling, and system prompt.
///
/// **Layer**: Data - Service Implementation
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_safety_keywords.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_system_prompt.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_definitions.dart';
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

  /// Meta Llama 3.3 70B Instruct
  /// - Native Italian support (multilingual)
  /// - Optimized for dialogue use cases
  /// - 70B params (10x larger than Mistral 7B)
  /// - Free tier on OpenRouter (~200K tokens/day)
  /// - Paid overflow: ~$0.0006/1K tokens (6 cent ogni 100 conversazioni)
  static const String _model = 'meta-llama/llama-3.3-70b-instruct';

  @override
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
    required String userId,
  }) async {
    try {
      debugPrint('[AI_COACH_SERVICE] 🚀 Starting sendMessage');
      debugPrint('[AI_COACH_SERVICE] User: $userMessage');

      // 1. Safety check - block medical keywords
      final medicalBlock = _checkMedicalKeywords(userMessage);
      if (medicalBlock != null) {
        debugPrint('[AI_COACH_SERVICE] 🚨 Medical keyword blocked');
        return AIServiceResponse(content: medicalBlock);
      }

      // 2. Build message list with context
      final messages = await _buildMessages(userMessage, conversationHistory, userId);
      debugPrint('[AI_COACH_SERVICE] 📝 Built ${messages.length} messages for AI');

      // 3. Tool calling loop - up to 3 iterations
      var currentMessages = messages;
      int iterations = 0;
      const maxIterations = 3;

      while (iterations < maxIterations) {
        debugPrint('[AI_COACH_SERVICE] 🔄 Iteration ${iterations + 1}/$maxIterations');

        // Call OpenRouter with tool definitions
        final response = await chatRepository.sendMessage(
          model: _model,
          messages: currentMessages,
          tools: aiToolDefinitions,
        );

        debugPrint('[AI_COACH_SERVICE] 📨 Got response: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');

        // Check if AI wants to call tools
        if (response.startsWith('__TOOL_CALLS__:')) {
          debugPrint('[AI_COACH_SERVICE] 🛠️ AI requested tool calls');

          // Extract and decode JSON tool calls (robust parsing)
          final toolCallsJsonStr = response.substring('__TOOL_CALLS__:'.length);
          final toolCallsJson = jsonDecode(toolCallsJsonStr) as List<dynamic>;

          debugPrint('[AI_COACH_SERVICE] 🔧 Executing ${toolCallsJson.length} tool(s)');

          // Execute each tool and collect results
          final toolResults = <Map<String, dynamic>>[];
          for (final toolCallData in toolCallsJson) {
            try {
              final toolCall = toolCallData as Map<String, dynamic>;
              final toolName = toolCall['name'] as String? ?? 'unknown';
              final args = toolCall['arguments'] as Map<String, dynamic>? ?? {};

              debugPrint('[AI_COACH_SERVICE] 🔨 Calling tool: $toolName with args: $args');

              // Execute tool with user context
              final result = await toolExecutor.executeTool(
                toolName: toolName,
                arguments: args,
                userId: userId,
              );

              debugPrint('[AI_COACH_SERVICE] ✅ Tool result: $result');

              toolResults.add({
                'tool': toolName,
                'result': result,
              });
            } catch (e) {
              debugPrint('[AI_COACH_SERVICE] ❌ Error executing tool: $e');
              toolResults.add({
                'tool': 'unknown',
                'result': 'Error: $e',
              });
            }
          }

          // Add tool results as new assistant message
          final toolResultsMessage = toolResults
              .map((tr) => '${tr['tool']}: ${tr['result']}')
              .join('\n');

          currentMessages = [
            ...currentMessages,
            {
              'role': 'assistant',
              'content': '__INTERNAL_TOOL_CALL__', // Marker for internal use
            },
            {
              'role': 'user',
              'content': 'Tool results:\n$toolResultsMessage',
            },
          ];

          debugPrint('[AI_COACH_SERVICE] 📊 Added tool results to conversation');
          iterations++;
          continue; // Loop again with updated messages
        } else {
          // Got final text response
          debugPrint('[AI_COACH_SERVICE] ✅ Got final text response');
          return AIServiceResponse(content: response);
        }
      }

      // Max iterations reached without final answer
      debugPrint('[AI_COACH_SERVICE] ⚠️ Max iterations reached');
      return AIServiceResponse(
        content: '⚠️ Ho avuto difficoltà a elaborare la tua richiesta. Prova a riformularla.',
      );
    } catch (e, stackTrace) {
      // Log to Crashlytics
      debugPrint('[AI_COACH_SERVICE] ❌ Error: $e');
      debugPrint('[AI_COACH_SERVICE] Stack: $stackTrace');

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
