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
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
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

  // === Context Cache (Phase 2 Optimization) ===
  // Caches context for 5 minutes to avoid redundant Firebase calls
  AIContext? _cachedContext;
  DateTime? _contextCachedAt;
  String? _cachedUserId;
  static const _contextCacheDuration = Duration(minutes: 5);

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

      // 3. Tool calling loop - max 3 iterations to reduce API costs
      // First request includes system prompt + context + history
      // Subsequent requests only include new messages (no system prompt repeat)
      final systemMessage = messages[0]; // Extract system prompt for reuse
      var conversationMessages = messages.sublist(1); // History without system prompt

      var iterations = 0;
      const maxIterations = 3; // Reduced from 5 to 3 for cost optimization
      List<String>? extractedSuggestions;

      while (iterations < maxIterations) {
        debugPrint('[AI_COACH_SERVICE] 🔄 Iteration ${iterations + 1}/$maxIterations');

        // Build request: system prompt only on first iteration, then conversation
        final requestMessages = iterations == 0
          ? messages
          : [systemMessage, ...conversationMessages]; // Reuse system message, no duplication

        // Filter tools based on user message (optimization: reduce tokens)
        // CRITICAL: After 2 iterations, REMOVE tools to force a text response
        final relevantTools = iterations >= 2
            ? <Map<String, dynamic>>[] // No tools = force text response
            : _selectRelevantTools(userMessage);

        if (iterations >= 2) {
          debugPrint('[AI_COACH_SERVICE] ⚠️ Iteration $iterations: Forcing text response (no tools)');
        } else {
          debugPrint('[AI_COACH_SERVICE] 📋 Using ${relevantTools.length} relevant tools (of ${aiToolDefinitions.length})');
        }

        // Call OpenRouter with filtered tool definitions
        final response = await chatRepository.sendMessage(
          model: _model,
          messages: requestMessages,
          tools: relevantTools.isNotEmpty ? relevantTools : null,
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

              // Extract suggestions from tool result if present
              try {
                final resultJson = jsonDecode(result) as Map<String, dynamic>;
                if (resultJson.containsKey('suggestions')) {
                  final suggestions = (resultJson['suggestions'] as List<dynamic>)
                      .cast<String>();
                  if (suggestions.isNotEmpty) {
                    extractedSuggestions = suggestions;
                    debugPrint('[AI_COACH_SERVICE] 💡 Found suggestions: $suggestions');
                  }
                }
              } catch (_) {
                // Tool result wasn't valid JSON or had no suggestions - that's fine
              }

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

          // Add tool results only to conversation messages for next iteration
          // DON'T keep accumulating tool results - only pass the latest ones
          final toolResultsMessage = toolResults
              .map((tr) => '${tr['tool']}: ${tr['result']}')
              .join('\n');

          // Update conversation messages (without system prompt)
          // CRITICAL: Use proper tool response format + explicit instruction to respond
          conversationMessages = [
            ...conversationMessages,
            {
              'role': 'assistant',
              'content': '__INTERNAL_TOOL_CALL__', // Marker for internal use
            },
            {
              'role': 'user',
              'content': '''Tool results:
$toolResultsMessage

---
ISTRUZIONE: Ora hai i dati. Genera una risposta COMPLETA in italiano per l'utente basandoti su questi risultati. NON richiedere altri tool. Rispondi direttamente.''',
            },
          ];

          debugPrint('[AI_COACH_SERVICE] 📊 Added tool results to conversation');
          iterations++;
          continue; // Loop again with updated messages
        } else {
          // Got final text response
          debugPrint('[AI_COACH_SERVICE] ✅ Got final text response');
          return AIServiceResponse(
            content: _sanitizeResponse(response),
            suggestions: extractedSuggestions,
          );
        }
      }

      // Max iterations reached - return best effort response
      debugPrint('[AI_COACH_SERVICE] ⚠️ Max iterations reached (${iterations})');

      return const AIServiceResponse(
        content: '⚠️ Ho avuto difficoltà a completare l\'analisi. I dati raccolti suggeriscono: verificare con uno specialista se hai domande sulla tua progressione.',
        suggestions: null,
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
      return const AIServiceResponse(
        content:
            '⚠️ Scusa, ho riscontrato un errore. Riprova tra qualche secondo.',
      );
    }
  }

  /// Get context with caching (Phase 2 Optimization)
  ///
  /// Caches context for 5 minutes to avoid redundant Firebase calls.
  /// Invalidates cache if userId changes or cache expires.
  Future<AIContext> _getContext(String userId) async {
    final now = DateTime.now();

    // Check if cache is valid
    final cacheValid = _cachedContext != null &&
        _contextCachedAt != null &&
        _cachedUserId == userId &&
        now.difference(_contextCachedAt!) < _contextCacheDuration;

    if (cacheValid) {
      debugPrint('[AI_COACH] 📦 Using cached context (age: ${now.difference(_contextCachedAt!).inSeconds}s)');
      return _cachedContext!;
    }

    // Fetch fresh context
    debugPrint('[AI_COACH] 🔄 Fetching fresh context');
    _cachedContext = await contextAggregator.aggregateContext(userId: userId);
    _contextCachedAt = now;
    _cachedUserId = userId;
    return _cachedContext!;
  }

  /// Invalidate context cache
  ///
  /// Call this after significant user actions like:
  /// - Completing a workout
  /// - Adding body measurements
  /// - Updating profile
  @override
  void invalidateContextCache() {
    _cachedContext = null;
    _contextCachedAt = null;
    _cachedUserId = null;
    debugPrint('[AI_COACH] 🗑️ Context cache invalidated');
  }

  /// Build messages for OpenRouter API
  Future<List<Map<String, dynamic>>> _buildMessages(
    String userMsg,
    List<AIMessage> history,
    String userId,
  ) async {
    // Get base context with caching (Phase 2 Optimization)
    final context = await _getContext(userId);

    return [
      // System prompt with user context
      {
        'role': 'system',
        'content': '$aiSystemPrompt\n\n${context.toPromptString()}',
      },

      // Conversation history (only visible messages)
      ...history.where((m) => m.isVisible).map((m) => {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content,
          }),

      // New user message
      {
        'role': 'user',
        'content': userMsg,
      },
    ];
  }

  /// Remove JSON artifacts and tool call fragments from AI response
  ///
  /// Some models leak raw JSON tool call objects into the text response.
  /// This strips them so the user sees only natural language.
  String _sanitizeResponse(String response) {
    var cleaned = response;

    // Remove "erta raa" artifact that sometimes appears before tool calls
    cleaned = cleaned.replaceAll(RegExp(r'erta\s+raa'), '').trim();

    // Remove JSON tool call blocks with nested objects
    // More robust pattern that handles nested braces
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\{\s*"(?:name|type|function)"[^}]*\{[^}]*\}[^}]*\}',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    ).trim();

    // Fallback: remove any remaining simple JSON objects
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\{[^{}]*"(?:type|name|function|parameters)"[^{}]*\}',
        caseSensitive: false,
      ),
      '',
    ).trim();

    // Remove markdown code blocks containing JSON (```json ... ```)
    cleaned = cleaned.replaceAll(
      RegExp(r'```json[\s\S]*?```', caseSensitive: false),
      '',
    ).trim();

    // Remove __TOOL_CALLS__ markers that might leak through
    cleaned = cleaned.replaceAll(RegExp(r'__TOOL_CALLS__:.*'), '').trim();
    cleaned = cleaned.replaceAll('__INTERNAL_TOOL_CALL__', '').trim();

    // Collapse multiple blank lines into one
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.isEmpty ? 'Non ho dati sufficienti per rispondere. Prova a riformulare.' : cleaned;
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

  /// Filter tool definitions based on user message content
  /// Reduces token consumption by only sending relevant tools (~30% savings)
  List<Map<String, dynamic>> _selectRelevantTools(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();
    final relevantTools = <Map<String, dynamic>>[];

    // Define tool categories with keywords
    // (toolNames defined below but used implicitly in tool selection logic)
    const performanceKeywords = [
      'forza', 'massimale', 'panca', 'squat', 'stacco', 'ripetizioni', 'kg',
      'incremento', 'progressive', 'carico', 'peso sollevato', '1rm', 'pr',
      'personale', 'record', 'migliore', 'quanto sollevo', 'sollevo'
    ];

    const recoveryKeywords = [
      'riposo', 'stanchezza', 'stanco', 'recupero', 'overtraining', 'frequenza',
      'quanto mi alleno', 'giorni', 'ripresa', 'affaticamento', 'fatica',
      'dormo', 'sonno', 'riposo'
    ];

    const planningKeywords = [
      'cosa alleno', 'allenamento', 'scheda', 'esercizi', 'workout', 'routine',
      'piano', 'cosa fare', 'che fare oggi', 'allenare', 'focus', 'muscolo',
      'muscoli', 'sessione', 'programma'
    ];

    const analysisKeywords = [
      'bilancio', 'squilibrio', 'debole', 'trascurato', 'troppo', 'poco',
      'difetto', 'compenso', 'asimmetria', 'muscoli', 'proporzionale',
      'preferisco', 'preferito', 'forte', 'debole'
    ];

    const bodyCompositionKeywords = [
      'peso', 'pesato', 'circonferenza', 'grasso', 'magra', 'misure',
      'body fat', 'bmi', 'composizione', 'misurazione', 'kg', 'percentuale',
      'dimagrito', 'ingrassato', 'cambiato', 'girovita', 'cm'
    ];

    // Check which categories match
    final hasPerformance = performanceKeywords.any((kw) => lowerMsg.contains(kw));
    final hasRecovery = recoveryKeywords.any((kw) => lowerMsg.contains(kw));
    final hasPlanning = planningKeywords.any((kw) => lowerMsg.contains(kw));
    final hasAnalysis = analysisKeywords.any((kw) => lowerMsg.contains(kw));
    final hasBodyComposition = bodyCompositionKeywords.any((kw) => lowerMsg.contains(kw));

    // Add tools based on matched categories
    // Tool indexes in aiToolDefinitions array:
    // 0:get1RMHistory, 1:getWeeklyVolume, 2:analyzeMuscleBalance, 3:getRecoveryData
    // 4:suggestWorkout, 5:compareToStandards, 6:getWorkoutStats, 7:getPersonalRecords
    // 8:getStreak, 9:getWorkoutHistory, 10:generateTemplate, 11:getBodyProgress, 12:addBodyMeasurement

    // Always include general stats tool as baseline
    relevantTools.add(aiToolDefinitions[6]); // getWorkoutStats

    // Add tools based on categories
    if (hasPerformance) {
      relevantTools.addAll([
        aiToolDefinitions[0], // get1RMHistory
        aiToolDefinitions[5], // compareToStandards
        aiToolDefinitions[7], // getPersonalRecords
        aiToolDefinitions[8], // getStreak
        aiToolDefinitions[1], // getWeeklyVolume
      ]);
    }

    if (hasRecovery) {
      relevantTools.addAll([
        aiToolDefinitions[3], // getRecoveryData
        aiToolDefinitions[9], // getWorkoutHistory
      ]);
    }

    if (hasPlanning) {
      relevantTools.addAll([
        aiToolDefinitions[4], // suggestWorkout
        aiToolDefinitions[10], // generateTemplate
        aiToolDefinitions[1], // getWeeklyVolume
      ]);
    }

    if (hasAnalysis) {
      relevantTools.add(aiToolDefinitions[2]); // analyzeMuscleBalance
    }

    if (hasBodyComposition) {
      relevantTools.addAll([
        aiToolDefinitions[11], // getBodyProgress
        aiToolDefinitions[12], // addBodyMeasurement
      ]);
    }

    // Default: if no category matched, include top 5 tools
    if (relevantTools.length == 1) {
      relevantTools.addAll([
        aiToolDefinitions[1],  // getWeeklyVolume
        aiToolDefinitions[9],  // getWorkoutHistory
        aiToolDefinitions[7],  // getPersonalRecords
        aiToolDefinitions[4],  // suggestWorkout
      ]);
    }

    // Remove duplicates while preserving order
    final seen = <String>{};
    return relevantTools
        .where((tool) {
          final name = (tool['function']['name'] as String);
          if (seen.contains(name)) return false;
          seen.add(name);
          return true;
        })
        .toList();
  }
}
