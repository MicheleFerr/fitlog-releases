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
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/ai_chat_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/exceptions/ai_coach_exception.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_safety_keywords.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_system_prompt.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_definitions.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_service.dart';

/// English indicators for language violation detection
const _englishIndicators = [
  'here is',
  'here are',
  'let me',
  'i can help',
  'based on',
  'however',
  'therefore',
  'furthermore',
  'in conclusion',
  'workout',
  'training',
  'exercise',
  'muscle',
  'strength',
  'should',
  'could',
  'would',
  'the ',
  ' a ',
  ' an ',
];

/// Implementation of AI Coach service
class AICoachServiceImpl implements AICoachService {
  AICoachServiceImpl({
    required this.chatRepository,
    required this.toolExecutor,
    required this.contextAggregator,
  });

  final AIChatRepository chatRepository;
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
      _debugLog('[AI_COACH_SERVICE] 🚀 Starting sendMessage');
      _debugLog(
        '[AI_COACH_SERVICE] User message length: ${userMessage.length}',
      );

      // 1. Safety check - block medical keywords
      final medicalBlock = _checkMedicalKeywords(userMessage);
      if (medicalBlock != null) {
        _debugLog('[AI_COACH_SERVICE] 🚨 Medical keyword blocked');
        return AIServiceResponse(content: medicalBlock);
      }

      // 2. Build message list with context
      final messages = await _buildMessages(
        userMessage,
        conversationHistory,
        userId,
      );
      _debugLog(
        '[AI_COACH_SERVICE] 📝 Built ${messages.length} messages for AI',
      );

      // 3. Tool calling loop - max 3 iterations to reduce API costs
      // First request includes system prompt + context + history
      // Subsequent requests only include new messages (no system prompt repeat)
      final systemMessage = messages[0]; // Extract system prompt for reuse
      var conversationMessages = messages.sublist(
        1,
      ); // History without system prompt

      var iterations = 0;
      const maxIterations = 3; // Reduced from 5 to 3 for cost optimization
      List<String>? extractedSuggestions;
      bool extractedIsDisambiguation = false;
      Map<String, double>? extractedMuscleHeatmap;
      String? extractedUnderTrainedLabel;
      String? extractedOverTrainedLabel;
      Map<String, dynamic>? extractedTemplateActionCard;
      AIQuota? latestQuota;

      while (iterations < maxIterations) {
        _debugLog(
          '[AI_COACH_SERVICE] 🔄 Iteration ${iterations + 1}/$maxIterations',
        );

        // Build request: system prompt only on first iteration, then conversation
        final requestMessages = iterations == 0
            ? messages
            : [
                systemMessage,
                ...conversationMessages,
              ]; // Reuse system message, no duplication

        // Filter tools based on user message (optimization: reduce tokens)
        // CRITICAL: After 2 iterations, REMOVE tools to force a text response
        final relevantTools = iterations >= 2
            ? <Map<String, dynamic>>[] // No tools = force text response
            : _selectRelevantTools(userMessage);

        if (iterations >= 2) {
          _debugLog(
            '[AI_COACH_SERVICE] ⚠️ Iteration $iterations: Forcing text response (no tools)',
          );
        } else {
          _debugLog(
            '[AI_COACH_SERVICE] 📋 Using ${relevantTools.length} relevant tools (of ${aiToolDefinitions.length})',
          );
        }

        // Call OpenRouter with filtered tool definitions
        final backendResponse = await chatRepository.sendMessage(
          model: _model,
          messages: requestMessages,
          tools: relevantTools.isNotEmpty ? relevantTools : null,
        );
        latestQuota = backendResponse.quota ?? latestQuota;
        final response = backendResponse.payload;

        _debugLog(
          '[AI_COACH_SERVICE] 📨 Got response: ${response.substring(0, response.length > 100 ? 100 : response.length)}...',
        );

        // Check if AI wants to call tools
        if (response.startsWith('__TOOL_CALLS__:')) {
          _debugLog('[AI_COACH_SERVICE] 🛠️ AI requested tool calls');

          // Extract and decode JSON tool calls (robust parsing)
          final toolCallsJsonStr = response.substring('__TOOL_CALLS__:'.length);
          final toolCallsJson = jsonDecode(toolCallsJsonStr) as List<dynamic>;

          _debugLog(
            '[AI_COACH_SERVICE] 🔧 Executing ${toolCallsJson.length} tool(s) in parallel',
          );

          // PERFORMANCE FIX: Execute tools in parallel with Future.wait
          // This reduces latency by ~60% when multiple tools are called
          final toolResults = await Future.wait(
            toolCallsJson.map((toolCallData) async {
              try {
                final toolCall = toolCallData as Map<String, dynamic>;
                final toolName = toolCall['name'] as String? ?? 'unknown';
                final args =
                    toolCall['arguments'] as Map<String, dynamic>? ?? {};

                _debugLog(
                  '[AI_COACH_SERVICE] 🔨 Calling tool: $toolName with args: $args',
                );

                // Execute tool with user context
                final result = await toolExecutor.executeTool(
                  toolName: toolName,
                  arguments: args,
                  userId: userId,
                );

                _debugLog('[AI_COACH_SERVICE] ✅ Tool result: $result');

                // Extract suggestions and disambiguation from tool result
                List<String>? foundSuggestions;
                bool foundDisambiguation = false;
                Map<String, double>? foundMuscleHeatmap;
                String? foundUnderTrainedLabel;
                String? foundOverTrainedLabel;
                Map<String, dynamic>? foundTemplateActionCard;
                try {
                  final resultJson = jsonDecode(result) as Map<String, dynamic>;
                  if (resultJson.containsKey('suggestions')) {
                    final suggestions =
                        (resultJson['suggestions'] as List<dynamic>)
                            .cast<String>();
                    if (suggestions.isNotEmpty) {
                      foundSuggestions = suggestions;
                      _debugLog(
                        '[AI_COACH_SERVICE] 💡 Found suggestions: $suggestions',
                      );
                    }
                  }
                  if (resultJson.containsKey('disambiguation') &&
                      resultJson['disambiguation'] == true) {
                    foundDisambiguation = true;
                    _debugLog('[AI_COACH_SERVICE] 🔀 Disambiguation detected');
                  }

                  if (toolName == 'analyzeMuscleBalance') {
                    final heatmap = _extractHeatmapValues(resultJson);
                    if (heatmap.isNotEmpty) {
                      foundMuscleHeatmap = heatmap;
                      foundUnderTrainedLabel =
                          resultJson['underTrainedLabel'] as String?;
                      foundOverTrainedLabel =
                          resultJson['overTrainedLabel'] as String?;
                      _debugLog(
                        '[AI_COACH_SERVICE] 🧠 Heatmap data extracted: ${heatmap.length} muscle groups',
                      );
                    }
                  }

                  final inlineCard = resultJson['inlineCard'];
                  if (inlineCard is Map && inlineCard.isNotEmpty) {
                    foundTemplateActionCard = inlineCard.map(
                      (key, value) => MapEntry(key.toString(), value),
                    );
                  }
                } catch (_) {
                  // Tool result wasn't valid JSON or had no suggestions - that's fine
                }

                return {
                  'tool': toolName,
                  'result': result,
                  'suggestions': foundSuggestions,
                  'isDisambiguation': foundDisambiguation,
                  'muscleHeatmap': foundMuscleHeatmap,
                  'underTrainedLabel': foundUnderTrainedLabel,
                  'overTrainedLabel': foundOverTrainedLabel,
                  'templateActionCard': foundTemplateActionCard,
                };
              } catch (e) {
                _debugLog('[AI_COACH_SERVICE] ❌ Error executing tool: $e');
                return {
                  'tool': 'unknown',
                  'result': 'Error: $e',
                  'suggestions': null,
                };
              }
            }),
          );

          // Collect suggestions and disambiguation from all tools (last one wins)
          for (final toolResult in toolResults) {
            final suggestions = toolResult['suggestions'] as List<String>?;
            if (suggestions != null && suggestions.isNotEmpty) {
              extractedSuggestions = suggestions;
            }
            if (toolResult['isDisambiguation'] == true) {
              extractedIsDisambiguation = true;
            }
            final heatmap = toolResult['muscleHeatmap'] as Map<String, double>?;
            if (heatmap != null && heatmap.isNotEmpty) {
              extractedMuscleHeatmap = heatmap;
              extractedUnderTrainedLabel =
                  toolResult['underTrainedLabel'] as String?;
              extractedOverTrainedLabel =
                  toolResult['overTrainedLabel'] as String?;
            }
            final actionCard =
                toolResult['templateActionCard'] as Map<String, dynamic>?;
            if (actionCard != null && actionCard.isNotEmpty) {
              extractedTemplateActionCard = actionCard;
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
              'content':
                  '''Tool results:
$toolResultsMessage

---
ISTRUZIONE: Ora hai i dati. Genera una risposta COMPLETA in italiano per l'utente basandoti su questi risultati. NON richiedere altri tool. Rispondi direttamente.''',
            },
          ];

          _debugLog('[AI_COACH_SERVICE] 📊 Added tool results to conversation');
          iterations++;
          continue; // Loop again with updated messages
        } else {
          // Got final text response
          _debugLog('[AI_COACH_SERVICE] ✅ Got final text response');

          if (iterations < maxIterations - 1 &&
              relevantTools.isNotEmpty &&
              _looksLikeToolCallLeak(response)) {
            _debugLog(
              '[AI_COACH_SERVICE] ⚠️ Detected leaked tool-intent text, forcing one more tool-calling attempt',
            );

            final sanitizedLeak = _sanitizeResponse(response);
            conversationMessages = [
              ...conversationMessages,
              {'role': 'assistant', 'content': sanitizedLeak},
              {
                'role': 'user',
                'content':
                    'ISTRUZIONE CRITICA: La tua risposta precedente menzionava nomi di funzioni interne. '
                    'NON menzionare MAI nomi di tool/funzioni (getRecoveryData, suggestWorkout, ecc.) all\'utente. '
                    'Se ti servono dati, CHIAMA il tool direttamente ora. '
                    'Se hai già i dati, rispondi direttamente in italiano presentando le informazioni in modo naturale, '
                    'come se le avessi già. NON dire "la funzione X ti fornirà...".',
              },
            ];
            iterations++;
            continue;
          }

          final sanitized = _sanitizeResponse(response);
          final responseWithActionCard = _appendInlineTemplateActionMarker(
            sanitized,
            cardPayload: extractedTemplateActionCard,
          );
          final enrichedResponse = _appendInlineHeatmapMarker(
            responseWithActionCard,
            heatmapValues: extractedMuscleHeatmap,
            underTrainedLabel: extractedUnderTrainedLabel,
            overTrainedLabel: extractedOverTrainedLabel,
          );

          // Check for language violations (monitoring only, doesn't block)
          if (_detectEnglishContent(enrichedResponse)) {
            await _logLanguageViolation(enrichedResponse);
          }

          return AIServiceResponse(
            content: enrichedResponse,
            suggestions: extractedSuggestions,
            isDisambiguation: extractedIsDisambiguation,
            quota: latestQuota,
          );
        }
      }

      // Max iterations reached - return best effort response
      _debugLog('[AI_COACH_SERVICE] ⚠️ Max iterations reached ($iterations)');

      return AIServiceResponse(
        content:
            '⚠️ Non sono riuscito a completare l\'analisi in modo affidabile. Per continuare senza fermarci, dimmi: 1) obiettivo principale, 2) tempo disponibile oggi, 3) attrezzatura disponibile.',
        suggestions: null,
        quota: latestQuota,
      );
    } on AICoachException {
      rethrow;
    } catch (e, stackTrace) {
      // Log to Crashlytics
      _debugLog('[AI_COACH_SERVICE] ❌ Error: $e');
      _debugLog('[AI_COACH_SERVICE] Stack: $stackTrace');

      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach service error',
        information: ['userMessageLength: ${userMessage.length}'],
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
    final cacheValid =
        _cachedContext != null &&
        _contextCachedAt != null &&
        _cachedUserId == userId &&
        now.difference(_contextCachedAt!) < _contextCacheDuration;

    if (cacheValid) {
      _debugLog(
        '[AI_COACH] 📦 Using cached context (age: ${now.difference(_contextCachedAt!).inSeconds}s)',
      );
      return _cachedContext!;
    }

    // Fetch fresh context
    _debugLog('[AI_COACH] 🔄 Fetching fresh context');
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
    _debugLog('[AI_COACH] 🗑️ Context cache invalidated');
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
      ...history
          .where((m) => m.isVisible)
          .map(
            (m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': _stripInlineUiMarkers(m.content),
            },
          ),

      // New user message
      {'role': 'user', 'content': userMsg},
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
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'\{\s*"(?:name|type|function)"[^}]*\{[^}]*\}[^}]*\}',
            caseSensitive: false,
            multiLine: true,
          ),
          '',
        )
        .trim();

    // Fallback: remove any remaining simple JSON objects
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'\{[^{}]*"(?:type|name|function|parameters)"[^{}]*\}',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Remove markdown code blocks containing JSON (```json ... ```)
    cleaned = cleaned
        .replaceAll(RegExp(r'```json[\s\S]*?```', caseSensitive: false), '')
        .trim();

    // Remove __TOOL_CALLS__ markers that might leak through
    cleaned = cleaned.replaceAll(RegExp(r'__TOOL_CALLS__:.*'), '').trim();
    cleaned = cleaned.replaceAll('__INTERNAL_TOOL_CALL__', '').trim();

    // Remove meta lines where model talks about function calls/JSON output
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'^.*(?:permettimi di chiamare la funzione|chiamare la funzione).*$',
            caseSensitive: false,
            multiLine: true,
          ),
          '',
        )
        .trim();
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'^.*(?:risposta in formato json|formato json).*$',
            caseSensitive: false,
            multiLine: true,
          ),
          '',
        )
        .trim();

    // Remove lines where model describes tool names to the user
    // e.g., "La funzione getRecoveryData ti fornirà informazioni..."
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'^.*(?:la funzione|la tool|il tool)\s+\w+\s+(?:ti fornirà|ti darà|ti mostrerà|fornirà|restituirà|permette di|serve per).*$',
            caseSensitive: false,
            multiLine: true,
          ),
          '',
        )
        .trim();

    // Remove lines mentioning specific tool names in camelCase (leaked internal names)
    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'^.*\b(?:get(?:RecoveryData|WeeklyVolume|WorkoutStats|PersonalRecords|Streak|WorkoutHistory|1RMHistory|BodyProgress|UserTemplates|TemplateDetails|AccessoryExercises|UserProfileContext|WorkoutPreferences|WeeklyCheckin|AutoProgressionPlan|AdherenceInsights)|suggestWorkout|generateTemplate|analyzeMuscleBalance|compareToStandards|addBodyMeasurement|searchExercises|searchScientificSources|addExerciseToTemplate|replaceExerciseInTemplate|removeExerciseFromTemplate|updateTemplateRestTime|updateTemplateExerciseSetup|updateUserProfilePreferences|updateWorkoutPreferences)\b.*$',
            multiLine: true,
          ),
          '',
        )
        .trim();

    // Collapse multiple blank lines into one
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.isEmpty
        ? 'Non ho dati sufficienti per rispondere. Prova a riformulare.'
        : cleaned;
  }

  bool _looksLikeToolCallLeak(String response) {
    final lower = response.toLowerCase();
    final mentionsJson =
        lower.contains('formato json') ||
        lower.contains('json:') ||
        lower.contains('```json');
    final mentionsFunction =
        lower.contains('chiamare la funzione') ||
        lower.contains('la funzione') ||
        lower.contains('funzione') ||
        lower.contains('tool') ||
        lower.contains('function');
    final mentionsKnownTool = RegExp(
      r'\b(get[a-z0-9_]+|addexercisetotemplate|replaceexerciseintemplate|removeexercisefromtemplate|updatetemplateresttime|updatetemplateexercisesetup|searchexercises|analyzemusclebalance|comparetostandards|generatetemplate|suggestworkout|addBodyMeasurement|getAccessoryExercises|searchScientificSources|getUserProfileContext|updateUserProfilePreferences|getWeeklyCheckin|getAutoProgressionPlan|getAdherenceInsights|getWorkoutPreferences|updateWorkoutPreferences)\b',
      caseSensitive: false,
    ).hasMatch(response);

    // Also detect patterns like "ti fornirà informazioni" near tool names
    final describesToolToUser =
        mentionsKnownTool &&
        (lower.contains('ti fornirà') ||
            lower.contains('fornirà informazioni') ||
            lower.contains('ti darà') ||
            lower.contains('ti mostrerà') ||
            lower.contains('questa funzione') ||
            lower.contains('la funzione'));

    return ((mentionsJson || mentionsFunction) && mentionsKnownTool) ||
        describesToolToUser;
  }

  /// Detect if response contains too much English content
  /// Returns true if 3+ English indicators found (likely English response)
  bool _detectEnglishContent(String response) {
    final lower = response.toLowerCase();
    int matches = 0;
    for (final indicator in _englishIndicators) {
      if (lower.contains(indicator)) {
        matches++;
        if (matches >= 3) return true;
      }
    }
    return false;
  }

  /// Log language violation to Crashlytics for monitoring
  Future<void> _logLanguageViolation(String response) async {
    _debugLog('[AI_COACH] ⚠️ LANGUAGE VIOLATION detected');
    await FirebaseCrashlytics.instance.recordError(
      Exception('AI Coach responded in English'),
      StackTrace.current,
      reason: 'Language violation',
      fatal: false,
    );
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
  Map<String, double> _extractHeatmapValues(Map<String, dynamic> resultJson) {
    final rawBalance = resultJson['balance'];
    if (rawBalance is! Map) return const {};

    final heatmap = <String, double>{};

    for (final entry in rawBalance.entries) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;
      if (value is! Map) continue;

      final rawPercentage = value['percentage'];
      final percentage = _safeToDouble(rawPercentage).clamp(0.0, 100.0);
      if (percentage <= 0) continue;

      switch (key) {
        case 'chest':
          heatmap['chest'] = percentage;
          break;
        case 'back':
          heatmap['lats'] = percentage;
          break;
        case 'shoulders':
          heatmap['shoulders'] = percentage;
          break;
        case 'core':
          heatmap['abs'] = percentage;
          break;
        case 'glutes':
          heatmap['glutes'] = percentage;
          break;
        case 'arms':
          heatmap['biceps'] = percentage;
          heatmap['triceps'] = percentage;
          heatmap['forearms'] = percentage;
          break;
        case 'legs':
          heatmap['quadriceps'] = percentage;
          heatmap['hamstrings'] = percentage;
          heatmap['calves'] = percentage;
          break;
        default:
          // Ignore unsupported categories like "other" / "full_body"
          break;
      }
    }

    return heatmap;
  }

  double _safeToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  String _appendInlineHeatmapMarker(
    String response, {
    Map<String, double>? heatmapValues,
    String? underTrainedLabel,
    String? overTrainedLabel,
  }) {
    if (heatmapValues == null || heatmapValues.isEmpty) return response;

    final payload = jsonEncode({
      'values': heatmapValues,
      'underTrained': underTrainedLabel,
      'overTrained': overTrainedLabel,
    });
    return '$response\n\n[[MUSCLE_HEATMAP:$payload]]';
  }

  String _appendInlineTemplateActionMarker(
    String response, {
    Map<String, dynamic>? cardPayload,
  }) {
    if (cardPayload == null || cardPayload.isEmpty) return response;

    final payload = jsonEncode(cardPayload);
    return '$response\n\n[[TEMPLATE_ACTION_CARD:$payload]]';
  }

  String _stripInlineUiMarkers(String content) {
    return content
        .replaceAll(RegExp(r'\[\[MUSCLE_HEATMAP:(\{[\s\S]*?\})\]\]'), '')
        .replaceAll(RegExp(r'\[\[TEMPLATE_ACTION_CARD:[\s\S]*?\]\]'), '')
        .trim();
  }

  List<Map<String, dynamic>> _selectRelevantTools(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();
    final relevantTools = <Map<String, dynamic>>[];
    final toolByName = <String, Map<String, dynamic>>{
      for (final tool in aiToolDefinitions)
        (tool['function'] as Map<String, dynamic>)['name'] as String: tool,
    };

    void addTool(String name) {
      final tool = toolByName[name];
      if (tool != null) {
        relevantTools.add(tool);
      }
    }

    void addTools(List<String> names) {
      for (final name in names) {
        addTool(name);
      }
    }

    // Define tool categories with keywords
    const performanceKeywords = [
      'forza',
      'massimale',
      'panca',
      'squat',
      'stacco',
      'ripetizioni',
      'kg',
      'incremento',
      'progressive',
      'carico',
      'peso sollevato',
      '1rm',
      'pr',
      'personale',
      'record',
      'migliore',
      'quanto sollevo',
      'sollevo',
    ];

    const recoveryKeywords = [
      'riposo',
      'stanchezza',
      'stanco',
      'recupero',
      'overtraining',
      'frequenza',
      'quanto mi alleno',
      'giorni',
      'ripresa',
      'affaticamento',
      'fatica',
      'dormo',
      'sonno',
      'riposo',
    ];

    const planningKeywords = [
      'cosa alleno',
      'allenamento',
      'allenarmi',
      'scheda',
      'esercizi',
      'workout',
      'routine',
      'piano',
      'cosa fare',
      'che fare oggi',
      'allenare',
      'focus',
      'muscolo',
      'muscoli',
      'sessione',
      'programma',
      'template',
      'templates',
      'i miei template',
      'mie schede',
      'domani',
      'oggi',
      'stasera',
      'viaggio',
      'trasferta',
      'salto',
      'saltato',
      'poco tempo',
    ];

    const exerciseSearchKeywords = [
      'esercizio',
      'alternativa',
      'alternative',
      'sostituire',
      'simile',
      'cerca',
      'trova',
      'esiste',
    ];

    const analysisKeywords = [
      'bilancio',
      'bilanciamento',
      'squilibrio',
      'debole',
      'trascurato',
      'troppo',
      'poco',
      'difetto',
      'compenso',
      'asimmetria',
      'muscoli',
      'proporzionale',
      'preferisco',
      'preferito',
      'forte',
      'debole',
    ];

    const bodyCompositionKeywords = [
      'peso',
      'pesato',
      'circonferenza',
      'grasso',
      'magra',
      'misure',
      'body fat',
      'bmi',
      'composizione',
      'misurazione',
      'kg',
      'percentuale',
      'dimagrito',
      'ingrassato',
      'cambiato',
      'girovita',
      'cm',
      'salva',
      'salvare',
      'confermo',
      'conferma',
      'procedi',
    ];

    const profileKeywords = [
      'livello',
      'esperienza',
      'obiettivo',
      'principiante',
      'intermedio',
      'avanzato',
      'atleta',
      'profilo',
      'settimana',
      'volte a settimana',
      'personalizza',
      'personalizzazione',
      'preferenze',
      'massa muscolare',
      'dimagrimento',
      'forza',
      '5x5',
      '4x8',
      'set e reps',
      'serie e ripetizioni',
      'setup guidato',
      'impostazioni',
      'settings',
    ];

    const weeklyCheckKeywords = [
      'check settimanale',
      'check-in',
      'settimana',
      'questa settimana',
      'settimana scorsa',
      'riepilogo',
      'review',
      'aggiustamenti',
    ];

    const progressionKeywords = [
      'progressione',
      'stallo',
      'plateau',
      'deload',
      'aumentare peso',
      'quando aumento',
      'autoregol',
      'carico prossimo',
    ];

    const adherenceKeywords = [
      'motivazione',
      'aderenza',
      'costanza',
      'non riesco',
      'saltare allenamenti',
      'disciplina',
      'giorni difficili',
      'faccio fatica',
      'routine',
    ];

    const templateDetailsKeywords = [
      'dettagli template',
      'dettaglio template',
      'analizza template',
      'analizzare template',
      'analizzare i template',
      'analisi template',
      'template specifico',
      'template presenti',
      'template salvati',
      'schede presenti',
      'cosa c e nel template',
      'esercizi nel template',
      'contenuto template',
      'struttura template',
    ];

    const templateEditKeywords = [
      'aggiungi esercizio',
      'aggiungere esercizio',
      'inserisci esercizio',
      'inserire esercizio',
      'metti esercizio',
      'sostituisci esercizio',
      'sostituire esercizio',
      'rimuovi esercizio',
      'rimuovere esercizio',
      'replace exercise',
      'remove exercise',
      'modifica template',
      'modificare template',
      'aggiorna template',
      'cambia template',
      'edit template',
      'insert exercise',
      'add exercise',
      'tempo di recupero',
      'tempi di recupero',
      'recupero tra serie',
      'secondi di recupero',
      'rest time',
      'rest timer',
      'aumenta recupero',
      'riduci recupero',
      'modifica recupero',
      'cambia recupero',
      'modifica serie',
      'cambia serie',
      'aumenta serie',
      'riduci serie',
      'modifica ripetizioni',
      'cambia ripetizioni',
      'aumenta ripetizioni',
      'riduci ripetizioni',
      'set e reps',
      'sets and reps',
      'rep range',
      'range ripetizioni',
      'serie e ripetizioni',
    ];

    const accessoryKeywords = [
      'accessori',
      'accessorio',
      'complementare',
      'complementari',
      'supporto',
      'supportare',
      'per migliorare',
      'ausiliario',
    ];

    const scientificSourceKeywords = [
      'fonte',
      'fonti',
      'studio',
      'studi',
      'scientifico',
      'scientifiche',
      'evidenza',
      'evidence',
      'paper',
      'ricerca',
      'ricerche',
      'citazione',
      'citazioni',
      'bibliografia',
      'meta-analisi',
      'meta analisi',
      'review scientifica',
    ];

    // Check which categories match
    final hasPerformance = performanceKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasRecovery = recoveryKeywords.any((kw) => lowerMsg.contains(kw));
    final hasPlanning = planningKeywords.any((kw) => lowerMsg.contains(kw));
    final hasAnalysis = analysisKeywords.any((kw) => lowerMsg.contains(kw));
    final hasBodyComposition = bodyCompositionKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasExerciseSearch = exerciseSearchKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasTemplateDetails = templateDetailsKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasTemplateEdit = templateEditKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasAccessory = accessoryKeywords.any((kw) => lowerMsg.contains(kw));
    final hasScientificSources = scientificSourceKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasProfile = profileKeywords.any((kw) => lowerMsg.contains(kw));
    final hasWeeklyCheck = weeklyCheckKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasProgression = progressionKeywords.any(
      (kw) => lowerMsg.contains(kw),
    );
    final hasAdherence = adherenceKeywords.any((kw) => lowerMsg.contains(kw));

    // Always include general stats tool as baseline
    addTool('getWorkoutStats');
    addTool('getUserProfileContext');

    // Add tools based on categories
    if (hasPerformance) {
      addTools([
        'get1RMHistory',
        'compareToStandards',
        'getPersonalRecords',
        'getStreak',
        'getWeeklyVolume',
      ]);
    }

    if (hasRecovery) {
      addTools(['getRecoveryData', 'getWorkoutHistory']);
    }

    if (hasPlanning) {
      addTools([
        'generateTemplate',
        'suggestWorkout',
        'getUserTemplates',
        'getTemplateDetails',
        'addExerciseToTemplate',
        'replaceExerciseInTemplate',
        'removeExerciseFromTemplate',
        'updateTemplateRestTime',
        'updateTemplateExerciseSetup',
        'getWorkoutPreferences',
        'updateWorkoutPreferences',
        'getWeeklyVolume',
        'getRecoveryData',
      ]);
    }

    if (hasTemplateDetails) {
      addTools(['getTemplateDetails', 'getUserTemplates']);
    }

    if (hasTemplateEdit) {
      addTools([
        'getUserTemplates',
        'getTemplateDetails',
        'searchExercises',
        'addExerciseToTemplate',
        'replaceExerciseInTemplate',
        'removeExerciseFromTemplate',
        'updateTemplateRestTime',
        'updateTemplateExerciseSetup',
      ]);
    }

    if (hasAnalysis) {
      addTool('analyzeMuscleBalance');
    }

    if (hasBodyComposition) {
      addTools(['getBodyProgress', 'addBodyMeasurement']);
    }

    if (hasExerciseSearch) {
      addTool('searchExercises');
    }

    if (hasAccessory) {
      addTools(['getAccessoryExercises', 'searchExercises']);
    }

    if (hasScientificSources) {
      addTool('searchScientificSources');
    }

    if (hasProfile) {
      addTools([
        'getUserProfileContext',
        'updateUserProfilePreferences',
        'getWorkoutPreferences',
        'updateWorkoutPreferences',
      ]);
    }

    if (hasWeeklyCheck) {
      addTools(['getWeeklyCheckin', 'getRecoveryData', 'getAdherenceInsights']);
    }

    if (hasProgression) {
      addTools([
        'getAutoProgressionPlan',
        'get1RMHistory',
        'getWorkoutHistory',
        'getWeeklyVolume',
      ]);
    }

    if (hasAdherence) {
      addTools(['getAdherenceInsights', 'getWeeklyCheckin', 'suggestWorkout']);
    }

    // Default: if no specific category matched, include a broader fallback set
    if (relevantTools.length <= 2) {
      addTools([
        'getWeeklyVolume',
        'getWorkoutHistory',
        'getPersonalRecords',
        'suggestWorkout',
        'getRecoveryData',
      ]);
    }

    // Remove duplicates while preserving order
    final seen = <String>{};
    return relevantTools.where((tool) {
      final name = (tool['function']['name'] as String);
      if (seen.contains(name)) return false;
      seen.add(name);
      return true;
    }).toList();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
