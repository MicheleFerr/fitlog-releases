/// AI Message Bubble Widget
///
/// Displays a single message in the chat interface.
/// Uses DecoratedBox for performance, supports Markdown rendering.
/// Shows interactive suggestion chips when exercise not found.
/// Supports copy and clickable exercise links.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Message bubble widget with enhanced UX features
class AIMessageBubble extends StatefulWidget {
  const AIMessageBubble({
    super.key,
    required this.message,
    required this.isFromUser,
    this.onSuggestionTap,
  });

  final AIMessage message;
  final bool isFromUser;
  final void Function(String)? onSuggestionTap;

  @override
  State<AIMessageBubble> createState() => _AIMessageBubbleState();
}

class _AIMessageBubbleState extends State<AIMessageBubble> {
  bool _showActions = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    HapticFeedback.lightImpact();
    SnackBarService.showSuccess(context, context.l10n.textCopied);
  }

  void _handleLinkTap(String text, String? href, String title) {
    // Handle exercise links - format: exercise://exerciseName
    if (href != null && href.startsWith('exercise://')) {
      final exerciseName = href.replaceFirst('exercise://', '');
      _navigateToExerciseAnalytics(exerciseName);
      return;
    }

    // Handle regular links
    if (href != null) {
      // Could open in browser, for now just copy
      Clipboard.setData(ClipboardData(text: href));
      SnackBarService.showInfo(context, 'Link copiato');
    }
  }

  void _navigateToExerciseAnalytics(String exerciseName) {
    context.pushNamed(
      AppRoutes.analyticsExerciseDetailName,
      pathParameters: {'exerciseName': Uri.encodeComponent(exerciseName)},
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'ora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m fa';
    } else if (diff.inDays < 1) {
      return DateFormat.Hm().format(timestamp);
    } else {
      return DateFormat.MMMd().format(timestamp);
    }
  }

  /// Process content to make exercise names clickable
  /// Looks for patterns like **Esercizio** or `esercizio` and makes them links
  String _processContentForExerciseLinks(String content) {
    // Common exercise patterns in AI responses
    // Matches: **Exercise Name** or `Exercise Name`
    final exercisePattern = RegExp(
      r'\*\*([A-Za-zÀ-ÿ\s]+(?:\s+[A-Za-zÀ-ÿ]+)*)\*\*|`([A-Za-zÀ-ÿ\s]+)`',
    );

    // Known exercise keywords to filter
    const exerciseKeywords = [
      'panca',
      'squat',
      'stacco',
      'curl',
      'press',
      'rematore',
      'alzate',
      'affondi',
      'leg',
      'dip',
      'pull',
      'push',
      'fly',
      'crunch',
      'plank',
      'deadlift',
      'bench',
      'row',
      'extension',
      'military',
      'shoulder',
      'tricep',
      'bicep',
      'lat',
      'chest',
      'back',
    ];

    return content.replaceAllMapped(exercisePattern, (match) {
      final exerciseName = match.group(1) ?? match.group(2) ?? '';
      final lowerName = exerciseName.toLowerCase();

      // Check if it looks like an exercise
      final isExercise = exerciseKeywords.any((kw) => lowerName.contains(kw));

      if (isExercise && exerciseName.length > 3) {
        // Convert to clickable link
        return '[**$exerciseName**](exercise://$exerciseName)';
      }

      // Return original if not an exercise
      return match.group(0) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final processedContent = widget.isFromUser
        ? widget.message.content
        : _processContentForExerciseLinks(widget.message.content);

    return GestureDetector(
      onLongPress: widget.isFromUser
          ? null
          : () {
              setState(() => _showActions = !_showActions);
              HapticFeedback.mediumImpact();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment:
              widget.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Avatar (only for AI messages)
            if (!widget.isFromUser) ...[
              _buildAvatar(context),
              const SizedBox(width: AppSpacing.xs),
            ],

            Flexible(
              child: Column(
                crossAxisAlignment: widget.isFromUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Message bubble
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.isFromUser
                          ? context.colors.primary
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(widget.isFromUser ? 16 : 4),
                        bottomRight: Radius.circular(widget.isFromUser ? 4 : 16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: MarkdownBody(
                        data: processedContent,
                        onTapLink: _handleLinkTap,
                        styleSheet: MarkdownStyleSheet(
                          p: context.textTheme.bodyMedium?.copyWith(
                            color: widget.isFromUser
                                ? context.colors.onPrimary
                                : context.colors.onSurface,
                          ),
                          a: context.textTheme.bodyMedium?.copyWith(
                            color: widget.isFromUser
                                ? context.colors.onPrimary
                                : context.colors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: widget.isFromUser
                                ? context.colors.onPrimary
                                : context.colors.primary,
                          ),
                          strong: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isFromUser
                                ? context.colors.onPrimary
                                : context.colors.onSurface,
                          ),
                          listBullet: context.textTheme.bodyMedium?.copyWith(
                            color: widget.isFromUser
                                ? context.colors.onPrimary
                                : context.colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xxs,
                      left: AppSpacing.xs,
                      right: AppSpacing.xs,
                    ),
                    child: Text(
                      _formatTimestamp(widget.message.timestamp),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  // Action buttons (for AI messages)
                  if (!widget.isFromUser && _showActions) _buildActionButtons(context),

                  // Quick actions row (always visible for AI)
                  if (!widget.isFromUser) _buildQuickActions(context),

                  // Suggestion chips
                  if (!widget.isFromUser && widget.message.suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.message.suggestions.map((suggestion) {
                          return ActionChip(
                            label: Text(suggestion),
                            onPressed: () =>
                                widget.onSuggestionTap?.call(suggestion),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SemanticIcon(
          icon: AppIcons.smartToy,
          semanticLabel: 'AI Coach',
          size: AppIconSize.small,
          color: context.colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy button
          _ActionButton(
            icon: AppIcons.copy,
            tooltip: context.l10n.copy,
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          ActionChip(
            avatar: const Icon(AppIcons.copy, size: 16),
            label: Text(context.l10n.copy),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}

/// Small action button for message actions
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
