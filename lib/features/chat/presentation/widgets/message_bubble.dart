/// Message Bubble Widget
///
/// Displays a single chat message with styling based on sender.
/// Supports text, image, and workout link message types.
///
/// **Layer**: Presentation
/// **Feature**: Chat
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:intl/intl.dart';

/// A single message bubble in the chat
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onDelete,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxs,
        left: isMe ? AppSpacing.xl : 0,
        right: isMe ? 0 : AppSpacing.xl,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onDelete != null
              ? () => _showDeleteDialog(context)
              : null,
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _buildBubble(context),
              const SizedBox(height: 2),
              _buildTimestamp(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final bubbleColor = isMe
        ? context.colors.primaryContainer
        : context.colors.surfaceContainerHigh;

    final textColor = isMe
        ? context.colors.onPrimaryContainer
        : context.colors.onSurface;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: switch (message.type) {
          MessageType.text => _buildTextContent(context, textColor),
          MessageType.image => _buildImageContent(context, textColor),
          MessageType.workoutLink => _buildWorkoutLinkContent(
            context,
            textColor,
          ),
        },
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        message.text,
        style: context.textTheme.bodyMedium?.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, Color textColor) {
    final metadata = message.imageMetadata;
    if (metadata == null) return _buildTextContent(context, textColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image
        AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl: metadata.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => ColoredBox(
              color: context.colors.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  AppIcons.image,
                  size: 48,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => ColoredBox(
              color: context.colors.errorContainer,
              child: Center(
                child: Icon(
                  AppIcons.errorOutline,
                  size: 48,
                  color: context.colors.onErrorContainer,
                ),
              ),
            ),
          ),
        ),

        // Caption (if any)
        if (message.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              message.text,
              style: context.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutLinkContent(BuildContext context, Color textColor) {
    final metadata = message.workoutMetadata;
    if (metadata == null) return _buildTextContent(context, textColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Workout card header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.fitnessCenter,
                  size: 20,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.workoutName,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat.yMMMd().format(metadata.completedAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _buildWorkoutStat(
                context,
                textColor,
                AppIcons.timer,
                '${metadata.durationMinutes} min',
              ),
              if (metadata.exerciseCount != null) ...[
                const SizedBox(width: AppSpacing.md),
                _buildWorkoutStat(
                  context,
                  textColor,
                  AppIcons.fitnessCenter,
                  '${metadata.exerciseCount} ex',
                ),
              ],
              if (metadata.totalVolumeKg != null) ...[
                const SizedBox(width: AppSpacing.md),
                _buildWorkoutStat(
                  context,
                  textColor,
                  AppIcons.scale,
                  '${(metadata.totalVolumeKg! / 1000).toStringAsFixed(1)}t',
                ),
              ],
            ],
          ),
        ),

        // Comment (if any)
        if (message.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              message.text,
              style: context.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutStat(
    BuildContext context,
    Color textColor,
    IconData icon,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final time = DateFormat.Hm().format(message.createdAt);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        if (isMe && message.readAt != null) ...[
          const SizedBox(width: 4),
          Icon(
            AppIcons.doneAll,
            size: 14,
            color: context.colors.primary.withValues(alpha: 0.7),
          ),
        ] else if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            AppIcons.done,
            size: 14,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteMessage),
        content: Text(context.l10n.deleteMessageConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}
