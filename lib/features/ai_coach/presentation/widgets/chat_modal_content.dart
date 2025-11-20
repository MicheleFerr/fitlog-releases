/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Chat Modal Content - AI Coach chat interface as bottom sheet modal
///
/// **Features**:
/// - Reusable modal version of ChatScreen (no Scaffold)
/// - Custom header with close button and clear history
/// - Same functionality as full-screen version
/// - Optimized for bottom sheet presentation
library;

import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/chat_input.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Chat Modal Content - Modal version of AI Coach chat
///
/// **Usage**: Shown via ModalService.showBottomSheet()
/// **State Management**: Riverpod ConsumerWidget
class ChatModalContent extends ConsumerStatefulWidget {
  const ChatModalContent({super.key});

  @override
  ConsumerState<ChatModalContent> createState() => _ChatModalContentState();
}

class _ChatModalContentState extends ConsumerState<ChatModalContent> {
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

    // Get keyboard height to avoid input being covered
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        children: [
          // Custom header (replaces AppBar)
          _buildModalHeader(context, userId),

          // Divider
          Divider(
            height: 1,
            color: context.colors.outlineVariant,
          ),

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

  /// Build custom modal header (replaces AppBar)
  Widget _buildModalHeader(BuildContext context, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // AI Icon + Title
          SemanticIcon(
            icon: AppIcons.ai,
            semanticLabel: 'AI Coach',
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.aiCoach,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Clear history button
          IconButton(
            icon: SemanticIcon(
              icon: AppIcons.delete,
              semanticLabel: context.l10n.clearHistory,
              size: AppIconSize.medium,
            ),
            onPressed: () => _showClearHistoryDialog(context, userId),
          ),

          // Close button
          IconButton(
            icon: SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: context.l10n.close,
              size: AppIconSize.medium,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
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

  /// Handle follow-up chip tap
  Future<void> _handleChipTap(
    BuildContext context,
    String userId,
    dynamic chip, // FollowUpChip type (imported via message_bubble)
  ) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Get locale from platform
    final locale = PlatformDispatcher.instance.locale.languageCode;

    // Get response repository to convert chip intent to full question
    final responseRepo = ref.read(responseRepositoryProvider);

    // Convert chip intent to full localized question (for better intent detection)
    final fullQuestion = responseRepo.getFullQuestionForChip(chip.intent, locale);

    // Send full question instead of short label
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
}
