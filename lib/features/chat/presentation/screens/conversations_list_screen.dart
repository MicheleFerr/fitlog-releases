/// Conversations List Screen
///
/// Displays all chat conversations for the current user.
/// Shows coach-athlete messaging threads with unread badges.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// List of all chat conversations
class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(title: Text(context.l10n.messages)),
      body: conversationsAsync.when(
        data: (conversations) =>
            _buildContent(context, conversations, currentUserId),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.errorOutline,
                  size: 48,
                  color: context.colors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.errorLoadingConversations,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<ChatConversation> conversations,
    String currentUserId,
  ) {
    if (conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Stream refreshes automatically, but this provides user feedback
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.sm + context.tabBarInset,
        ),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72, // Avatar width + padding
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationTile(
            conversation: conversation,
            currentUserId: currentUserId,
            onTap: () => _openConversation(context, conversation),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EnhancedEmptyState(
      icon: AppIcons.chatBubbleOutline,
      title: context.l10n.noConversationsYet,
      description: context.l10n.startChattingWithCoachOrAthlete,
    );
  }

  void _openConversation(BuildContext context, ChatConversation conversation) {
    context.pushNamed(
      AppRoutes.chatName,
      pathParameters: {'conversationId': conversation.id},
    );
  }
}
