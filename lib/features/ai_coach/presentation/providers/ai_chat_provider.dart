/// AI Chat Provider
///
/// Manages AI Coach conversation state using Riverpod 3.0.
/// Handles message sending, rate limiting, and loading state.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_coach_service_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
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
AICoachServiceImpl aiCoachService(AiCoachServiceRef ref) {
  // TODO: Get API key from environment config
  const apiKey = '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';

  final chatRepository = AIChatRepositoryImpl(apiKey: apiKey);
  final toolExecutor = AIToolExecutor(
    analyticsRepo: null, // TODO: Wire actual repos in post-MVP
    historyRepo: null,
    recoveryRepo: null,
  );
  final contextAggregator = AnalyticsAggregator(
    analyticsRepo: null,
    historyRepo: null,
    recoveryRepo: null,
    streakRepo: null,
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
  @override
  AIChatState build() {
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
      final rateLimit = await ref.read(aiRateLimitProvider.future);
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

      // 3. Call AI service
      final service = ref.read(aiCoachServiceProvider);
      final response = await service.sendMessage(
        userMessage: text.trim(),
        conversationHistory: state.messages,
      );

      // 4. Add AI response
      final aiMessage = AIMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: response.content,
        timestamp: DateTime.now(),
        toolCall: response.toolCall,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      // 5. Increment rate limit counter
      await ref.read(aiRateLimitProvider.notifier).incrementUsage();
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
