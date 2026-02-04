/// AI Chat Provider
///
/// Manages AI Coach conversation state using Riverpod 3.0.
/// Handles message sending, rate limiting, and loading state.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_coach_service_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'ai_chat_provider.g.dart';

/// Chat state
class AIChatState {
  final List<AIMessage> messages;
  final bool isLoading;
  final String? error;

  const AIChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  AIChatState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// AI Coach service provider
@riverpod
AICoachServiceImpl aiCoachService(Ref ref) {
  // Get API key from environment config (.env or --dart-define)
  final apiKey = EnvironmentConfig.openRouterApiKey;

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception(
      'OPENROUTER_API_KEY not configured. Add to .env or use --dart-define',
    );
  }

  final chatRepository = AIChatRepositoryImpl(apiKey: apiKey);

  // Wire real repositories for function calling and context aggregation
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final historyRepo = ref.watch(workoutHistoryRepositoryProvider);
  final streakRepo = ref.watch(streakRepositoryProvider);

  final workoutAnalyticsRepo = ref.watch(workoutAnalyticsRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);

  final toolExecutor = AIToolExecutor(
    analyticsRepo: analyticsRepo,
    historyRepo: historyRepo,
    workoutAnalyticsRepo: workoutAnalyticsRepo,
    streakRepo: streakRepo,
    measurementRepo: measurementRepo,
  );
  final contextAggregator = AnalyticsAggregator(
    analyticsRepo: analyticsRepo,
    historyRepo: historyRepo,
    streakRepo: streakRepo,
  );

  return AICoachServiceImpl(
    chatRepository: chatRepository,
    toolExecutor: toolExecutor,
    contextAggregator: contextAggregator,
  );
}

/// AI Chat provider
@riverpod
class AIChat extends _$AIChat {
  // Memory limit: keep last 10 messages (design requirement line 585)
  static const int _maxMessages = 10;

  @override
  AIChatState build() {
    // IMPORTANT: Prevent re-initialization when navigating away and back
    // This keeps chat history in memory during the session
    ref.keepAlive();

    // Initialize with disclaimer message
    return AIChatState(
      messages: [_buildDisclaimerMessage()],
    );
  }

  /// Send a message to the AI Coach
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // 1. Check rate limit
      final rateLimit = await ref.read(aIRateLimitProvider.future);
      if (rateLimit.isBlocked) {
        state = state.copyWith(
          error: rateLimit.message,
        );
        return;
      }

      // 2. Add user message immediately
      final userMessage = AIMessage(
        id: const Uuid().v4(),
        role: MessageRole.user,
        content: text.trim(),
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
        error: null,
      );

      // 3. Get current user ID
      final userAsync = await ref.read(currentUserProvider.future);
      final userId = userAsync?.uid;

      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Devi essere autenticato per usare l\'AI Coach',
        );
        return;
      }

      // 4. Call AI service with real user ID
      final service = ref.read(aiCoachServiceProvider);
      final response = await service.sendMessage(
        userMessage: text.trim(),
        conversationHistory: state.messages,
        userId: userId,
      );

      // 5. Add AI response
      final aiMessage = AIMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: response.content,
        timestamp: DateTime.now(),
        toolCall: response.toolCall,
        suggestions: response.suggestions ?? [],
      );

      // 6. Apply memory limit: keep last 10 messages (design requirement line 585)
      final updatedMessages = [...state.messages, aiMessage];
      final trimmedMessages = updatedMessages.length > _maxMessages
          ? updatedMessages.sublist(updatedMessages.length - _maxMessages)
          : updatedMessages;

      state = state.copyWith(
        messages: trimmedMessages,
        isLoading: false,
      );

      // 7. Track analytics (design requirement: docs/AI_COACH_DESIGN.md line 671-681)
      await FirebaseAnalytics.instance.logEvent(
        name: 'ai_coach_message_sent',
        parameters: {
          'message_count': trimmedMessages.length,
          'function_calls_used': response.toolCall != null ? 1 : 0,
          'has_tool_call': response.toolCall != null,
          'tool_name': response.toolCall?.name ?? 'none',
        },
      );

      // 8. Increment rate limit counter
      await ref.read(aIRateLimitProvider.notifier).incrementUsage();
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Error sending AI Coach message',
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Errore durante l\'invio del messaggio. Riprova.',
      );
    }
  }

  /// Clear conversation history
  void clearMessages() {
    state = AIChatState(
      messages: [_buildDisclaimerMessage()],
    );
  }

  /// Build disclaimer message shown on first load
  AIMessage _buildDisclaimerMessage() {
    return AIMessage(
      id: 'disclaimer',
      role: MessageRole.system,
      content: '''
👋 Ciao! Sono il tuo AI Coach di FitLog.

⚠️ **Disclaimer Importante**:
- Non sono un medico o fisioterapista
- Non posso diagnosticare infortuni o condizioni mediche
- Per dolori, infortuni o sintomi fisici, consulta un professionista

💡 **Cosa posso fare**:
- Consigli su allenamento e progressione
- Analisi dei tuoi dati (quando disponibili)
- Suggerimenti basati su scienza dello sport
- Motivazione e supporto

🔒 **Privacy**: Le tue chat NON vengono salvate.

Chiedimi pure! 💪
''',
      timestamp: DateTime.now(),
    );
  }
}
