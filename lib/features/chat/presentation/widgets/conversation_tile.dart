/// Conversation Tile Widget
///
/// A single conversation item in the conversations list.
/// Shows avatar, name, last message preview, time, and unread badge.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:intl/intl.dart';

/// A tile representing a single conversation in the list
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final otherName = conversation.otherParticipantName(currentUserId);
    final unreadCount = conversation.unreadCountFor(currentUserId);
    final hasUnread = unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: _buildAvatar(context, otherName),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(context, conversation.lastMessageAt!),
              style: context.textTheme.bodySmall?.copyWith(
                color: hasUnread
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: _buildSubtitle(context, hasUnread),
          ),
          if (hasUnread) ...[
            const SizedBox(width: AppSpacing.xs),
            _buildUnreadBadge(context, unreadCount),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name) {
    final initials = _getInitials(name);

    return CircleAvatar(
      radius: 24,
      backgroundColor: context.colors.primaryContainer,
      child: Text(
        initials,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, bool hasUnread) {
    String preview = conversation.lastMessage ?? '';

    // Add "You: " prefix if current user sent the last message
    if (conversation.lastMessageFromMe(currentUserId) && preview.isNotEmpty) {
      preview = '${context.l10n.youPrefix}$preview';
    }

    return Text(
      preview.isEmpty ? context.l10n.noMessagesYet : preview,
      style: context.textTheme.bodyMedium?.copyWith(
        color: hasUnread
            ? context.colors.onSurface
            : context.colors.onSurfaceVariant,
        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnreadBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      constraints: const BoxConstraints(minWidth: 20),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today: show time
      return DateFormat.Hm().format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return context.l10n.yesterday;
    } else if (now.difference(dateTime).inDays < 7) {
      // Within a week: show day name
      return DateFormat.E().format(dateTime);
    } else {
      // Older: show date
      return DateFormat.MMMd().format(dateTime);
    }
  }
}
