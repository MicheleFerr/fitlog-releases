/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// Chat Screen - Pattern-based conversational AI (NO LLM, NO API)
///
/// **Features**:
/// - Real-time message streaming with typewriter effect
/// - Hive-backed conversation history (instant load)
/// - Intent detection (8 supported intents)
/// - Personalized responses using analyzer data
/// - Offline-first (100% local)
///
/// **Navigation**:
/// - Entry point: AI Coach Screen or Home dashboard
/// - Route: /ai-coach/chat
///
/// **Usage**:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const ChatScreen()),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/chat_input.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/suggestion_chips.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/onboarding_modal.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Chat Screen - AI Coach conversational interface
///
/// **State Management**: Riverpod ConsumerWidget
/// **Auto-dispose**: Yes (chat notifier auto-disposes when unmounted)
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    // Track session start
    _sessionStartTime = DateTime.now();

    // Check onboarding status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
      _trackSessionStarted();
    });
  }

  @override
  void dispose() {
    // Track session end
    _trackSessionEnded();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// Track session started
  void _trackSessionStarted() {
    const userId = 'test-user';
    final analytics = ref.read(aiCoachAnalyticsProvider);
    analytics.trackSessionStarted(userId: userId);
  }

  /// Track session ended
  void _trackSessionEnded() {
    if (_sessionStartTime == null) return;

    const userId = 'test-user';
    final analytics = ref.read(aiCoachAnalyticsProvider);
    final chatState = ref.read(chatNotifierProvider(userId));

    final duration = DateTime.now().difference(_sessionStartTime!);
    final messageCount = chatState.messages.where((m) => m.role == MessageRole.user).length;

    analytics.trackSessionEnded(
      userId: userId,
      durationSeconds: duration.inSeconds,
      messageCount: messageCount,
    );
  }

  /// Check if user has seen onboarding and show modal if not
  Future<void> _checkAndShowOnboarding() async {
    if (!mounted) return;

    // Get user ID
    const userId = 'test-user';

    // Get user profile for display name
    final userProfile = ref.read(userProfileProvider);
    final displayName = userProfile.valueOrNull?.displayName ?? 'GymBro';
    final firstName = displayName.split(' ').first;

    // Check onboarding status
    final datasource = ref.read(hiveChatLocalDatasourceProvider);
    final hasSeenOnboarding = await datasource.hasSeenOnboarding(userId: userId);

    // Show onboarding if not seen
    if (!hasSeenOnboarding && mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => OnboardingModal(
          userName: firstName,
          onDismiss: () async {
            // Capture navigator before async call
            final navigator = Navigator.of(modalContext);

            // Mark onboarding as seen
            await datasource.markOnboardingSeen(userId: userId);

            // Track onboarding completion
            final analytics = ref.read(aiCoachAnalyticsProvider);
            await analytics.trackOnboardingCompleted(userId: userId);

            // Pop modal
            navigator.pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get user ID from auth provider
    const userId = 'test-user';
    final chatState = ref.watch(chatNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.ai,
              semanticLabel: 'AI Coach',
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(context.l10n.aiCoach),
          ],
        ),
        actions: [
          // Back navigation button (show only when tree has parent)
          if (chatState.tree?.getParentNode() != null)
            IconButton(
              icon: const SemanticIcon(
                icon: AppIcons.arrowBack,
                semanticLabel: 'Back to parent',
                size: AppIconSize.medium,
              ),
              onPressed: () {
                ref.read(chatNotifierProvider(userId).notifier).navigateToParent();
              },
            ),
          // Clear history button
          IconButton(
            icon: SemanticIcon(
              icon: AppIcons.delete,
              semanticLabel: context.l10n.clearHistory,
              size: AppIconSize.medium,
            ),
            onPressed: () => _showClearHistoryDialog(context, userId),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.isLoading
                ? const Center(child: LoadingIndicator())
                : chatState.messages.isEmpty
                    ? _buildEmptyState(context, userId)
                    : _buildMessagesList(context, chatState, userId),
          ),

          // Error banner (if any)
          if (chatState.error != null) _buildErrorBanner(context, chatState.error!),

          // Suggestion chips (always visible)
          if (chatState.messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SuggestionChips(
                onSuggestionTap: (query) {
                  _textController.text = query;
                  _sendMessage(context, userId, query);
                },
              ),
            ),

          // Chat input
          ChatInput(
            controller: _textController,
            onSend: (message) => _sendMessage(context, userId, message),
            enabled: !chatState.isStreaming,
          ),
        ],
      ),
    );
  }

  /// Build messages list
  Widget _buildMessagesList(
    BuildContext context,
    ChatState chatState,
    String userId,
  ) {
    // Auto-scroll to bottom when new message arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return MessageBubble(
          message: message,
          showTypingIndicator: message.isStreaming,
          onChipTap: (chip) => _handleChipTap(context, userId, chip),
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, String userId) {
    // Watch user profile to get display name
    final userProfile = ref.watch(userProfileProvider);

    // Get user's first name (extract from display name or use fallback)
    final displayName = userProfile.valueOrNull?.displayName ?? 'GymBro';
    final firstName = displayName.split(' ').first;

    // Get time-based greeting
    final greeting = _getTimeBasedGreeting(context, firstName);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.ai,
              semanticLabel: 'AI Coach',
              size: AppIconSize.xxlarge,
              color: context.colors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              greeting,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.aiCoachChatDescription,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SuggestionChips(
              onSuggestionTap: (query) {
                _textController.text = query;
                _sendMessage(context, userId, query);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build error banner
  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.errorContainer,
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.error,
            color: context.colors.error,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Send message
  Future<void> _sendMessage(BuildContext context, String userId, String message) async {
    if (message.trim().isEmpty) return;

    // Clear input
    _textController.clear();

    // Send via notifier
    await ref.read(chatNotifierProvider(userId).notifier).sendMessage(message);
  }

  /// Handle follow-up chip tap
  Future<void> _handleChipTap(BuildContext context, String userId, FollowUpChip chip) async {
    // Track chip tap
    final analytics = ref.read(aiCoachAnalyticsProvider);
    await analytics.trackChipTapped(
      userId: userId,
      intent: chip.intent,
      chipLabel: chip.label,
    );

    // Get locale from context (default to 'en' if not available)
    final locale = Localizations.localeOf(context).languageCode;

    // Get response repository from provider
    final responseRepository = ref.read(responseRepositoryProvider);

    // Convert chip intent to full question for intent detection
    final fullQuestion = responseRepository.getFullQuestionForChip(chip.intent, locale);

    // Send the full question as a message
    await _sendMessage(context, userId, fullQuestion);
  }

  /// Show clear history confirmation dialog
  Future<void> _showClearHistoryDialog(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.clearHistory),
        content: Text(context.l10n.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.clearHistory),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(chatNotifierProvider(userId).notifier).clearHistory();
    }
  }

  /// Get time-based greeting
  ///
  /// **Logic**:
  /// - Morning: 5:00 AM - 11:59 AM
  /// - Afternoon: 12:00 PM - 5:59 PM
  /// - Evening: 6:00 PM - 4:59 AM
  ///
  /// **Returns**: Localized greeting with user's name
  String _getTimeBasedGreeting(BuildContext context, String name) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: 5 AM - 11:59 AM
      return context.l10n.goodMorning(name);
    } else if (hour >= 12 && hour < 18) {
      // Afternoon: 12 PM - 5:59 PM
      return context.l10n.goodAfternoon(name);
    } else {
      // Evening: 6 PM - 4:59 AM
      return context.l10n.goodEvening(name);
    }
  }
}
