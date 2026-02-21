/// AI Chat Provider
///
/// Manages AI Coach conversation state using Riverpod 3.0.
/// Handles message sending, rate limiting, and loading state.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/analytics_aggregator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/ai_chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_coach_service_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/analytics_debug_utility.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_auto_sync_service.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_resync_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'ai_chat_provider.g.dart';

/// Chat state
class AIChatState {

  const AIChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });
  final List<AIMessage> messages;
  final bool isLoading;
  final String? error;

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
  final templateRepo = ref.watch(templateRepositoryProvider);
  final locale = ref.watch(localeProvider);

  final historyDaysLimit = ref.watch(tierEntitlementsProvider).historyDaysLimit;

  final toolExecutor = AIToolExecutor(
    analyticsRepo: analyticsRepo,
    historyRepo: historyRepo,
    workoutAnalyticsRepo: workoutAnalyticsRepo,
    streakRepo: streakRepo,
    measurementRepo: measurementRepo,
    templateRepo: templateRepo,
    locale: locale,
    historyDaysLimit: historyDaysLimit,
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

  // Lock to prevent concurrent message sends
  bool _isSending = false;

  // Track if auto-sync has been performed this session
  bool _hasAutoSynced = false;

  @override
  AIChatState build() {
    // IMPORTANT: Prevent re-initialization when navigating away and back
    // This keeps chat history in memory during the session
    ref.keepAlive();

    // Schedule auto-sync in background (non-blocking)
    // This ensures analytics data is up-to-date when user opens AI Coach
    _scheduleAutoSync();

    // Initialize with disclaimer message
    return AIChatState(
      messages: [_buildDisclaimerMessage()],
    );
  }

  /// Schedule automatic analytics sync in background
  ///
  /// This runs once per session when AI Coach is first opened.
  /// It checks if recent workouts are synced to analytics and
  /// syncs any missing data automatically.
  void _scheduleAutoSync() {
    if (_hasAutoSynced) return;
    _hasAutoSynced = true;

    // Run in background after a short delay to not block UI
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final userAsync = await ref.read(currentUserProvider.future);
        final userId = userAsync?.uid;

        if (userId == null) {
          debugPrint('[AI_CHAT] ⏭️ Skipping auto-sync: user not authenticated');
          return;
        }

        final analyticsRepo = ref.read(analyticsRepositoryProvider);
        final historyRepo = ref.read(workoutHistoryRepositoryProvider);

        final autoSyncService = AnalyticsAutoSyncService(
          analyticsRepo: analyticsRepo,
          historyRepo: historyRepo,
        );

        final result = await autoSyncService.ensureSynced(
          userId: userId,
          maxDaysToCheck: 30, // Only check last 30 days
        );

        if (result.wasNeeded) {
          debugPrint(
            '[AI_CHAT] ✅ Auto-sync completed: '
            '${result.workoutsSynced} workouts, ${result.exercisesSynced} exercises',
          );
        } else {
          debugPrint('[AI_CHAT] ✅ Analytics already up-to-date');
        }
      } catch (e, stackTrace) {
        // Don't crash the app if auto-sync fails - just log it
        debugPrint('[AI_CHAT] ⚠️ Auto-sync failed (non-critical): $e');
        await FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'AI Coach auto-sync failed (non-critical)',
          fatal: false,
        );
      }
    });
  }

  /// Send a message to the AI Coach
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Prevent concurrent sends (race condition protection)
    if (_isSending) {
      debugPrint('[AI_CHAT] ⚠️ Message send already in progress, ignoring');
      return;
    }
    _isSending = true;

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

      // SPECIAL COMMANDS (available in all builds for diagnostics)
      final trimmedText = text.trim().toLowerCase();

      // DEBUG COMMAND: /debug <exercise>
      // Usage: "/debug panca" to inspect analytics for "panca"
      if (trimmedText.startsWith('/debug ')) {
        final query = text.trim().substring(7).trim();
        final debugOutput = await debugAnalytics(query.isEmpty ? 'panca' : query);

        // Add debug response as AI message
        final debugMessage = AIMessage(
          id: const Uuid().v4(),
          role: MessageRole.assistant,
          content: '```\n$debugOutput\n```',
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, debugMessage],
          isLoading: false,
        );
        return;
      }

      // RESYNC COMMAND: /resync [days]
      // Usage: "/resync" for all workouts, "/resync 30" for last 30 days
      if (trimmedText.startsWith('/resync')) {
        final parts = text.trim().split(' ');
        final days = parts.length > 1 ? int.tryParse(parts[1]) : null;

        final resyncOutput = await _performResync(userId, days: days);

        final resyncMessage = AIMessage(
          id: const Uuid().v4(),
          role: MessageRole.assistant,
          content: resyncOutput,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, resyncMessage],
          isLoading: false,
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
        isDisambiguation: response.isDisambiguation,
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
          'has_tool_call': response.toolCall != null ? 1 : 0,
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
    } finally {
      _isSending = false;
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

  /// Debug: Inspect analytics data for an exercise
  ///
  /// Call this from debug screen or console to diagnose AI Coach issues.
  /// Returns detailed information about exercise history and 1RM calculations.
  ///
  /// Usage (from console or debug screen):
  /// ```dart
  /// final result = await ref.read(aIChatProvider.notifier)
  ///     .debugAnalytics('panca');
  /// ```
  Future<String> debugAnalytics(String exerciseQuery) async {
    try {
      final userAsync = await ref.read(currentUserProvider.future);
      final userId = userAsync?.uid;

      if (userId == null) {
        return '❌ User not authenticated';
      }

      final analyticsRepo = ref.read(analyticsRepositoryProvider);

      return await AnalyticsDebugUtility.debugExerciseAnalytics(
        analyticsRepo: analyticsRepo,
        userId: userId,
        exerciseQuery: exerciseQuery,
      );
    } catch (e) {
      return '❌ Debug failed: $e';
    }
  }

  /// Perform analytics resync
  ///
  /// Re-synchronizes workout data to analytics collection.
  /// Use when analytics data is missing or out of sync.
  Future<String> _performResync(String userId, {int? days}) async {
    try {
      final analyticsRepo = ref.read(analyticsRepositoryProvider);
      final historyRepo = ref.read(workoutHistoryRepositoryProvider);

      final resyncService = AnalyticsResyncService(
        analyticsRepo: analyticsRepo,
        historyRepo: historyRepo,
      );

      final buffer = StringBuffer();
      buffer.writeln('🔄 **Avvio ri-sincronizzazione analytics...**\n');

      ResyncResult result;
      if (days != null) {
        buffer.writeln('📅 Sincronizzando gli ultimi $days giorni\n');
        result = await resyncService.resyncRecentWorkouts(
          userId: userId,
          days: days,
        );
      } else {
        buffer.writeln('📅 Sincronizzando tutti i workout\n');
        result = await resyncService.resyncAllWorkouts(userId: userId);
      }

      buffer.writeln('---');
      buffer.writeln('✅ **Completato!**\n');
      buffer.writeln('- Workout processati: **${result.workoutsProcessed}**');
      buffer.writeln('- Esercizi sincronizzati: **${result.exercisesSynced}**');
      buffer.writeln('- Durata: ${result.duration.inSeconds}s');

      if (result.hasErrors) {
        buffer.writeln('\n⚠️ **Errori (${result.errors.length}):**');
        for (final error in result.errors.take(5)) {
          buffer.writeln('- $error');
        }
        if (result.errors.length > 5) {
          buffer.writeln('- ... e altri ${result.errors.length - 5} errori');
        }
      }

      buffer.writeln('\n💡 Ora prova a chiedere di nuovo il tuo massimale!');

      return buffer.toString();
    } catch (e) {
      return '❌ **Errore durante la ri-sincronizzazione:**\n\n$e';
    }
  }
}
