import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// iOS-style swipeable wrapper for TemplateCard
///
/// Features:
/// - Swipe right to reveal Schedule action (+ Refresh if TUT sync needed)
/// - Swipe left to reveal 4 action buttons
/// - Actions appear from BEHIND the card (iOS native style)
/// - Smooth BehindMotion animation
/// - HapticFeedback on actions
/// - Refresh only shows if template actually needs TUT sync
class SwipeableTemplateCard extends ConsumerWidget {
  const SwipeableTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onShare,
    required this.onDuplicate,
    required this.onEdit,
    required this.onDelete,
    this.onSchedule,
    this.onRefresh,
    this.onView,
    this.preloadedStats,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSchedule;
  final VoidCallback? onRefresh;
  final VoidCallback? onView;

  /// Pre-calculated stats from parent (optimization: avoids N provider calls)
  final TemplateStats? preloadedStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this template actually needs a refresh (only for custom templates)
    final needsRefreshAsync = template.isCustom && onRefresh != null
        ? ref.watch(templateNeedsRefreshProvider(template.id))
        : const AsyncValue<bool>.data(false);

    final needsRefresh = needsRefreshAsync.value ?? false;

    // Calculate extent ratio based on number of left actions
    final hasSchedule = onSchedule != null;
    final showRefresh = needsRefresh && onRefresh != null;
    final leftActionCount = (hasSchedule ? 1 : 0) + (showRefresh ? 1 : 0);
    final leftExtentRatio = leftActionCount > 0
        ? (0.20 * leftActionCount)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        key: ValueKey(template.id),
        // Left actions (swipe right to reveal): Schedule + Refresh
        startActionPane: leftActionCount > 0
            ? ActionPane(
                motion: const BehindMotion(),
                extentRatio: leftExtentRatio,
                // Full swipe right should open scheduling immediately without
                // dismissing the card from the list.
                dismissible: hasSchedule
                    ? DismissiblePane(
                        dismissThreshold: 0.45,
                        onDismissed: () {},
                        closeOnCancel: true,
                        confirmDismiss: () async {
                          unawaited(HapticFeedback.mediumImpact());
                          onSchedule!();
                          return false;
                        },
                      )
                    : null,
                children: [
                  if (hasSchedule)
                    _buildSlidableAction(
                      context: context,
                      icon: AppIcons.schedule,
                      label: context.l10n.scheduleWorkout,
                      backgroundColor: context.successColor,
                      foregroundColor: context.textOnSuccess,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Slidable.of(context)?.close();
                        onSchedule!();
                      },
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  if (showRefresh)
                    _buildSlidableAction(
                      context: context,
                      icon: AppIcons.sync,
                      label: context.l10n.refreshFromDatabase,
                      backgroundColor: context.infoColor,
                      foregroundColor: context.textOnInfo,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Slidable.of(context)?.close();
                        onRefresh!();
                      },
                      borderRadius: hasSchedule
                          ? null
                          : const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                    ),
                ],
              )
            : null,
        // UX FIX: Reduced from 5 actions to 3 for less accidental triggers
        // View and Share moved to long-press context menu (future)
        // Kept: Edit, Duplicate, Delete - most frequent actions
        endActionPane: ActionPane(
          motion: const StretchMotion(), // More resistance than BehindMotion
          extentRatio: 0.48, // Reduced from 0.72 - 3 actions only
          openThreshold: 0.35, // Require more intentional swipe
          children: [
            _buildSlidableAction(
              context: context,
              icon: AppIcons.edit,
              label: context.l10n.templateActionEdit,
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Slidable.of(context)?.close();
                onEdit();
              },
            ),
            _buildSlidableAction(
              context: context,
              icon: AppIcons.copy,
              label: context.l10n.templateActionDuplicate,
              backgroundColor: context.colors.tertiary,
              foregroundColor: context.colors.onTertiary,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Slidable.of(context)?.close();
                onDuplicate();
              },
            ),
            _buildSlidableAction(
              context: context,
              icon: AppIcons.delete,
              label: context.l10n.templateActionDelete,
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
              onPressed: () {
                HapticFeedback.heavyImpact();
                Slidable.of(context)?.close();
                onDelete();
              },
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        // The card has its own rounded corners - actions appear from behind
        child: TemplateCard(
          template: template,
          onTap: onTap,
          preloadedStats: preloadedStats,
        ),
      ),
    );
  }

  /// Build an iOS-style action that fills full height (appears from behind card)
  Widget _buildSlidableAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
    BorderRadius? borderRadius,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.medium,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
