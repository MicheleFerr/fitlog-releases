/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Message Bubble - Chat message UI component
///
/// **Features**:
/// - User vs Assistant styling (alignment, colors)
/// - Typewriter effect for streaming messages
/// - Timestamp display
/// - Smooth animations
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  final AIMessage message;
  final bool showTypingIndicator;
  final Function(FollowUpChip)? onChipTap; // Callback for chip tap

  const MessageBubble({
    super.key,
    required this.message,
    this.showTypingIndicator = false,
    this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final hasChips = !isUser &&
                     message.followUpChips.isNotEmpty &&
                     !showTypingIndicator;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble row
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI Coach avatar (left side)
              if (!isUser) ...[
                _buildAvatar(context, isUser),
                const SizedBox(width: 8),
              ],

              // Message bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? context.colors.primary
                        : context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      Text(
                        message.content,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isUser
                              ? context.colors.onPrimary
                              : context.colors.onSurface,
                        ),
                      ),

                      // Typing indicator (for streaming messages)
                      if (showTypingIndicator) ...[
                        const SizedBox(height: 4),
                        _buildTypingIndicator(context),
                      ],

                      // Timestamp
                      if (!showTypingIndicator) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isUser
                                ? context.colors.onPrimary.withValues(alpha: 0.7)
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // User avatar (right side)
              if (isUser) ...[
                const SizedBox(width: 8),
                _buildAvatar(context, isUser),
              ],
            ],
          ),

          // Follow-up chips (only for assistant messages)
          if (hasChips) ...[
            const SizedBox(height: 8),
            _buildFollowUpChips(context),
          ],
        ],
      ),
    );
  }

  /// Build avatar
  Widget _buildAvatar(BuildContext context, bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? context.colors.primaryContainer
          : context.colors.tertiaryContainer,
      child: SemanticIcon(
        icon: isUser ? AppIcons.person : AppIcons.ai,
        semanticLabel: isUser ? 'User' : 'AI Coach',
        size: AppIconSize.small,
        color: isUser
            ? context.colors.onPrimaryContainer
            : context.colors.onTertiaryContainer,
      ),
    );
  }

  /// Build typing indicator
  Widget _buildTypingIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(context, 0),
        const SizedBox(width: 4),
        _buildDot(context, 1),
        const SizedBox(width: 4),
        _buildDot(context, 2),
      ],
    );
  }

  /// Build animated dot for typing indicator
  Widget _buildDot(BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.onSurfaceVariant.withValues(alpha: value * 0.7),
          ),
        );
      },
      onEnd: () {
        // Loop animation
        if (showTypingIndicator) {
          Future.delayed(const Duration(milliseconds: 200), () {
            // Trigger rebuild for loop
          });
        }
      },
    );
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  /// Build follow-up chips
  Widget _buildFollowUpChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40), // Align with message text (avatar + spacing)
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: message.followUpChips.map((chip) {
          return ActionChip(
            avatar: chip.emoji != null
                ? Text(
                    chip.emoji!,
                    style: context.textTheme.bodyMedium,
                  )
                : null,
            label: Text(chip.label),
            onPressed: onChipTap != null ? () => onChipTap!(chip) : null,
            backgroundColor: context.colors.secondaryContainer,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSecondaryContainer,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }).toList(),
      ),
    );
  }
}
