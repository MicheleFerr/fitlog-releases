/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Chat Providers - Riverpod state management for pattern-based chat bot
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/conversation_tree.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/send_chat_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/get_conversation_history.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/clear_conversation_history.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/response_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/chatbot_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/hive_chat_local_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/simple_entity_extractor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/chat_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/analyzer_registry.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/progressive_overload_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/recovery_pattern_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/cns_fatigue_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/periodization_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/mobility_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_analytics.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/tone_adapter.dart';

// ============================================================================
// Datasource Providers (Singleton)
// ============================================================================

/// AI Coach analytics provider (event tracking)
final aiCoachAnalyticsProvider = Provider<AICoachAnalytics>((ref) {
  return AICoachAnalytics();
});

/// Tone adapter provider (adaptive tone based on user profile - Phase 3.2)
final toneAdapterProvider = Provider<ToneAdapter>((ref) {
  return ToneAdapter();
});

/// Tone profile provider - Derives tone profile from user data (Phase 3.2)
///
/// TODO: Integrate with UserProfile when experienceLevel and fitnessGoals fields added
/// For now, returns default beginner profile
final toneProfileProvider = Provider<ToneProfile>((ref) {
  // TODO: Watch userProfileProvider when experience/goals fields added:
  // final userProfile = ref.watch(userProfileProvider).valueOrNull;
  // if (userProfile == null) return ToneProfile.defaultProfile;
  //
  // return ToneProfile(
  //   experienceLevel: userProfile.experienceLevel ?? ExperienceLevel.beginner,
  //   primaryGoal: userProfile.primaryFitnessGoal,
  //   isEncouraging: true,
  //   isDetailed: userProfile.experienceLevel != ExperienceLevel.advanced,
  //   isTechnical: userProfile.experienceLevel == ExperienceLevel.advanced,
  // );

  // Default: Beginner-friendly tone for all users
  return ToneProfile.beginnerProfile;
});

/// Intent detector provider (pattern-based classification)
final intentDetectorProvider = Provider<IntentDetector>((ref) {
  return IntentDetector();
});

/// Response repository provider (template responses)
final responseRepositoryProvider = Provider<ResponseRepository>((ref) {
  return ResponseRepository();
});

/// Simple entity extractor provider (keyword extraction for PR query)
final simpleEntityExtractorProvider = Provider<SimpleEntityExtractor>((ref) {
  return SimpleEntityExtractor();
});

/// Hive chat local datasource provider (conversation cache)
final hiveChatLocalDatasourceProvider = Provider<HiveChatLocalDatasource>((ref) {
  return HiveChatLocalDatasource();
});

/// Analyzer registry provider (registers all insight analyzers)
final analyzerRegistryProvider = Provider<AnalyzerRegistry>((ref) {
  final registry = AnalyzerRegistry();

  // Register all analyzers (5 analyzers with no dependencies)
  registry.registerAnalyzer(ProgressiveOverloadAnalyzer());
  registry.registerAnalyzer(RecoveryPatternAnalyzer());
  registry.registerAnalyzer(CNSFatigueAnalyzer());
  registry.registerAnalyzer(PeriodizationAnalyzer());
  registry.registerAnalyzer(MobilityAnalyzer());

  // TODO: Register VolumeBalanceAnalyzer (requires exerciseDatabase)
  // registry.registerAnalyzer(VolumeBalanceAnalyzer(exerciseDatabase));

  return registry;
});

/// ChatBot datasource provider (pattern-based bot logic)
final chatBotDatasourceProvider = Provider<ChatBotDatasource>((ref) {
  final intentDetector = ref.watch(intentDetectorProvider);
  final responseRepository = ref.watch(responseRepositoryProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  final analyzerRegistry = ref.watch(analyzerRegistryProvider);
  final exerciseRepository = ref.watch(hybridExerciseRepositoryProvider);
  final entityExtractor = ref.watch(simpleEntityExtractorProvider);
  final analyticsRepository = ref.watch(analyticsRepositoryProvider);
  final aiCoachAnalytics = ref.watch(aiCoachAnalyticsProvider);
  final toneAdapter = ref.watch(toneAdapterProvider);
  final toneProfile = ref.watch(toneProfileProvider);

  return ChatBotDatasource(
    intentDetector: intentDetector,
    responseRepository: responseRepository,
    workoutRepository: workoutRepository,
    analyzerRegistry: analyzerRegistry,
    exerciseRepository: exerciseRepository,
    entityExtractor: entityExtractor,
    analyticsRepository: analyticsRepository,
    aiCoachAnalytics: aiCoachAnalytics,
    toneAdapter: toneAdapter,
    toneProfile: toneProfile,
  );
});

// ============================================================================
// Repository Provider
// ============================================================================

/// Chat repository provider (combines bot + cache)
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final botDatasource = ref.watch(chatBotDatasourceProvider);
  final localDatasource = ref.watch(hiveChatLocalDatasourceProvider);

  return ChatRepositoryImpl(
    botDatasource: botDatasource,
    localDatasource: localDatasource,
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Send chat message use case
final sendChatMessageProvider = Provider<SendChatMessage>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendChatMessage(repository: repository);
});

/// Get conversation history use case
final getConversationHistoryProvider = Provider<GetConversationHistory>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetConversationHistory(repository: repository);
});

/// Clear conversation history use case
final clearConversationHistoryProvider = Provider<ClearConversationHistory>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ClearConversationHistory(repository: repository);
});

// ============================================================================
// State Notifier (Chat State Management)
// ============================================================================

/// Chat state
class ChatState {

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.tree,
  });
  final List<AIMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final ConversationTree? tree;

  ChatState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    ConversationTree? tree,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
      tree: tree ?? this.tree,
    );
  }
}

/// Chat state notifier
class ChatNotifier extends StateNotifier<ChatState> {

  ChatNotifier({
    required this.sendChatMessageUseCase,
    required this.getConversationHistoryUseCase,
    required this.clearConversationHistoryUseCase,
    required this.chatRepository,
    required this.userId,
  }) : super(const ChatState()) {
    _loadHistory();
  }
  final SendChatMessage sendChatMessageUseCase;
  final GetConversationHistory getConversationHistoryUseCase;
  final ClearConversationHistory clearConversationHistoryUseCase;
  final ChatRepository chatRepository;
  final String userId;

  /// Load conversation history on init
  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true);

    // Load messages
    final result = await getConversationHistoryUseCase.call(
      userId: userId,
      limit: 50,
    );

    // Load tree
    final treeResult = await chatRepository.loadTree(userId: userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (messages) {
        treeResult.fold(
          (failure) {
            // Tree load failed, but continue with messages
            state = state.copyWith(
              messages: messages,
              isLoading: false,
            );
          },
          (tree) {
            // Both loaded successfully
            state = state.copyWith(
              messages: messages,
              tree: tree,
              isLoading: false,
            );
          },
        );
      },
    );
  }

  /// Send message and stream response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Set streaming state
    state = state.copyWith(isStreaming: true, error: null);

    // Stream response
    await for (final result in sendChatMessageUseCase.call(
      message: message,
      userId: userId,
    )) {
      result.fold(
        (failure) {
          state = state.copyWith(
            isStreaming: false,
            error: failure.message,
          );
        },
        (aiMessage) {
          // Update or add message
          final updatedMessages = List<AIMessage>.from(state.messages);

          // Find existing message with same ID (for streaming updates)
          final existingIndex = updatedMessages.indexWhere(
            (msg) => msg.id == aiMessage.id,
          );

          if (existingIndex != -1) {
            // Update existing streaming message
            updatedMessages[existingIndex] = aiMessage;
          } else {
            // Add new message to end
            updatedMessages.add(aiMessage);
          }

          state = state.copyWith(
            messages: updatedMessages,
            isStreaming: aiMessage.isStreaming,
          );
        },
      );
    }
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    // Call use case to clear from Hive cache
    final result = await clearConversationHistoryUseCase.call(userId: userId);

    result.fold(
      (failure) {
        // Keep existing messages on error
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Clear UI state on success
        state = state.copyWith(messages: [], error: null);
      },
    );
  }

  /// Navigate to parent node in conversation tree
  Future<void> navigateToParent() async {
    final currentTree = state.tree;
    if (currentTree == null) return;

    // Navigate to parent in tree
    final newTree = currentTree.navigateToParent();
    if (newTree == null) return; // Already at root

    // Save updated tree
    final saveResult = await chatRepository.saveTree(newTree);

    saveResult.fold(
      (failure) {
        // Keep existing state on error
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Update state with new tree and current path messages
        state = state.copyWith(
          tree: newTree,
          messages: newTree.getCurrentPath(),
          error: null,
        );
      },
    );
  }
}

/// Chat state notifier provider
final chatNotifierProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, userId) {
    final sendMessageUseCase = ref.watch(sendChatMessageProvider);
    final getHistoryUseCase = ref.watch(getConversationHistoryProvider);
    final clearHistoryUseCase = ref.watch(clearConversationHistoryProvider);
    final repository = ref.watch(chatRepositoryProvider);

    return ChatNotifier(
      sendChatMessageUseCase: sendMessageUseCase,
      getConversationHistoryUseCase: getHistoryUseCase,
      clearConversationHistoryUseCase: clearHistoryUseCase,
      chatRepository: repository,
      userId: userId,
    );
  },
);
