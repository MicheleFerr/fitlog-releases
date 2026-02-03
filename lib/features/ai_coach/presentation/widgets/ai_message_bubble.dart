/// AI Message Bubble Widget
///
/// Displays a single message in the chat interface.
/// Uses DecoratedBox for performance, supports Markdown rendering.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Message bubble widget
class AIMessageBubble extends StatelessWidget {
  const AIMessageBubble({
    super.key,
    required this.message,
    required this.isFromUser,
  });

  final AIMessage message;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isFromUser
                    ? context.colors.primary
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: MarkdownBody(
                  data: message.content,
                  styleSheet: MarkdownStyleSheet(
                    p: context.textTheme.bodyMedium?.copyWith(
                      color: isFromUser
                          ? context.colors.onPrimary
                          : context.colors.onSurface,
                    ),
                    a: context.textTheme.bodyMedium?.copyWith(
                      color: isFromUser
                          ? context.colors.onPrimary
                          : context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    strong: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isFromUser
                          ? context.colors.onPrimary
                          : context.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
