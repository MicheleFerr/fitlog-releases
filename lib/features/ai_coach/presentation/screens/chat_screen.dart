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
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/chat_input.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
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
                    ? _buildEmptyState(context)
                    : _buildMessagesList(context, chatState, userId),
          ),

          // Error banner (if any)
          if (chatState.error != null) _buildErrorBanner(context, chatState.error!),

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
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
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
              context.l10n.aiCoachChatWelcome,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
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
            _buildSuggestedQuestions(context),
          ],
        ),
      ),
    );
  }

  /// Build suggested questions
  Widget _buildSuggestedQuestions(BuildContext context) {
    final questions = [
      context.l10n.aiCoachQuestionProgress,
      context.l10n.aiCoachQuestionRest,
      context.l10n.aiCoachQuestionVolume,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: questions.map((question) {
        return ActionChip(
          label: Text(question),
          onPressed: () {
            _textController.text = question;
            _sendMessage(context, 'test-user', question);
          },
        );
      }).toList(),
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
}
