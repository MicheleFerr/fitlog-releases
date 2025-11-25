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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/inline_chart.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Message bubble widget
class MessageBubble extends ConsumerWidget { // Callback for chip tap

  const MessageBubble({
    super.key,
    required this.message,
    this.showTypingIndicator = false,
    this.onChipTap,
  });
  final AIMessage message;
  final bool showTypingIndicator;
  final Function(FollowUpChip)? onChipTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;
    final hasChips = !isUser &&
                     !isSystem &&
                     message.followUpChips.isNotEmpty &&
                     !showTypingIndicator;

    // System messages use special layout
    if (isSystem) {
      return _buildSystemMessage(context, ref);
    }

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

                      // Inline chart (for assistant messages with chart metadata)
                      if (!isUser &&
                          message.metadata != null &&
                          message.metadata!.containsKey('chartType')) ...[
                        Builder(
                          builder: (context) {
                            // Track chart viewed
                            final analytics = ref.read(aiCoachAnalyticsProvider);
                            final chartType = message.metadata!['chartType'] as String;
                            final chartData = message.metadata!['chartData'] as Map<String, dynamic>?;
                            final dataPoints = (chartData?['data'] as List<dynamic>?)?.length ?? 0;

                            // Track on first build (chart now visible)
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              analytics.trackChartViewed(
                                userId: 'test-user',
                                chartType: chartType,
                                dataPoints: dataPoints,
                              );
                            });

                            return InlineChart.fromMetadata(message.metadata!);
                          },
                        ),
                      ],

                      // Reasoning section for transparency (Phase 3.3)
                      if (!isUser &&
                          message.metadata != null &&
                          message.metadata!.containsKey('reasoning')) ...[
                        const SizedBox(height: 12),
                        _buildReasoningSection(context),
                      ],

                      // Exercise demonstration (Phase 3.4 - Multi-modal)
                      if (!isUser &&
                          message.metadata != null &&
                          message.metadata!.containsKey('exerciseMedia')) ...[
                        const SizedBox(height: 12),
                        _buildExerciseDemonstration(context),
                      ],

                      // Workout plan table (Phase 3.4 - Multi-modal)
                      if (!isUser &&
                          message.metadata != null &&
                          message.metadata!.containsKey('workoutTable')) ...[
                        const SizedBox(height: 12),
                        _buildWorkoutPlanTable(context),
                      ],

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

  /// Build system message (special styling for tips, warnings, info)
  Widget _buildSystemMessage(BuildContext context, WidgetRef ref) {
    // Detect message type from content or metadata
    final isWarning = message.content.toLowerCase().contains('warning') ||
                      message.content.toLowerCase().contains('attenzione') ||
                      message.metadata?['type'] == 'warning';

    final isTip = message.content.toLowerCase().contains('tip') ||
                  message.content.toLowerCase().contains('consiglio') ||
                  message.metadata?['type'] == 'tip';

    // Track system message shown
    final messageType = isWarning ? 'warning' : isTip ? 'tip' : 'info';
    final analytics = ref.read(aiCoachAnalyticsProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analytics.trackSystemMessageShown(
        userId: 'test-user',
        messageType: messageType,
      );
    });

    // Select icon and colors based on type
    final IconData icon;
    final Color backgroundColor;
    final Color iconColor;

    if (isWarning) {
      icon = AppIcons.warning;
      backgroundColor = context.colors.errorContainer;
      iconColor = context.colors.error;
    } else if (isTip) {
      icon = AppIcons.lightbulb;
      backgroundColor = context.colors.primaryContainer;
      iconColor = context.colors.primary;
    } else {
      // Default: info message
      icon = AppIcons.info;
      backgroundColor = context.colors.surfaceContainerHighest;
      iconColor = context.colors.tertiary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            SemanticIcon(
              icon: icon,
              semanticLabel: isWarning
                  ? 'Warning'
                  : isTip
                      ? 'Tip'
                      : 'Info',
              size: AppIconSize.medium,
              color: iconColor,
            ),
            const SizedBox(width: 12),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label (System / Tip / Warning)
                  Text(
                    isWarning
                        ? (message.metadata?['label'] ?? 'Warning')
                        : isTip
                            ? (message.metadata?['label'] ?? 'Tip')
                            : (message.metadata?['label'] ?? 'System'),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Message text
                  Text(
                    message.content,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),

                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
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

  /// Build reasoning section for transparency (Phase 3.3)
  ///
  /// Shows expandable "Why?" section with:
  /// - Data sources used
  /// - Analysis methods
  /// - Reasoning logic
  Widget _buildReasoningSection(BuildContext context) {
    final reasoning = message.metadata!['reasoning'] as List<dynamic>;
    final dataSource = message.metadata!['dataSource'] as String?;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        title: Row(
          children: [
            Icon(
              AppIcons.info,
              size: AppIconSize.small,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Why this answer?',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data source
              if (dataSource != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      AppIcons.storage,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dataSource,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Reasoning points
              ...reasoning.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value as String;

                return Padding(
                  padding: EdgeInsets.only(bottom: index < reasoning.length - 1 ? 8 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Build exercise demonstration widget (Phase 3.4 - Multi-modal)
  ///
  /// Shows:
  /// - Exercise image
  /// - Form cues (bullet list)
  Widget _buildExerciseDemonstration(BuildContext context) {
    final exerciseMedia =
        message.metadata!['exerciseMedia'] as Map<String, dynamic>;
    final exerciseName = exerciseMedia['exerciseName'] as String;
    final imageUrl = exerciseMedia['imageUrl'] as String?;
    final formCues = exerciseMedia['formCues'] as List<dynamic>?;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Exercise name
          Row(
            children: [
              Icon(
                AppIcons.workout,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exerciseName,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Exercise image
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: context.colors.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.error,
                          color: context.colors.error,
                          size: AppIconSize.large,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Form cues
          if (formCues != null && formCues.isNotEmpty) ...[
            Text(
              'Form Cues:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...formCues.asMap().entries.map((entry) {
              final cue = entry.value as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cue,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Build workout plan table widget (Phase 3.4 - Multi-modal)
  ///
  /// Shows:
  /// - Structured exercise list
  /// - Sets, reps, rest for each exercise
  /// - Progressive overload notes
  Widget _buildWorkoutPlanTable(BuildContext context) {
    final workoutTable =
        message.metadata!['workoutTable'] as Map<String, dynamic>;
    final title = workoutTable['title'] as String;
    final exercises = workoutTable['exercises'] as List<dynamic>;
    final totalVolume = workoutTable['totalVolume'] as int;
    final estimatedDuration = workoutTable['estimatedDuration'] as String;
    final progressionNotes = workoutTable['progressionNotes'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Plan title
          Row(
            children: [
              Icon(
                AppIcons.document,
                size: AppIconSize.small,
                color: context.colors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Meta info: Total volume + duration
          Text(
            '$totalVolume sets • $estimatedDuration',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          // Exercise table
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value as Map<String, dynamic>;
            final name = exercise['name'] as String;
            final sets = exercise['sets'] as int;
            final reps = exercise['reps'] as String;
            final rest = exercise['rest'] as String;
            final notes = exercise['notes'] as String?;

            return Container(
              margin: EdgeInsets.only(bottom: index < exercises.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    '${index + 1}. $name',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Sets × Reps • Rest
                  Row(
                    children: [
                      Icon(
                        AppIcons.repeat,
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$sets × $reps',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        AppIcons.timer,
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rest,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Notes
                  if (notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notes,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Progression notes
          if (progressionNotes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.lightbulb,
                    size: AppIconSize.small,
                    color: context.colors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      progressionNotes,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
