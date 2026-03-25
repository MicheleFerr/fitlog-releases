/// Smart Workout Card
///
/// Section 1 of the Quick Actions overlay.
/// Shows a smart workout suggestion based on split detection,
/// with dynamic labels and action buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/quick_actions/domain/services/split_detection_service.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/providers/next_workout_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/from_template_popup.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/recent_workouts_popup.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Smart workout suggestion card for the Quick Actions overlay
class SmartWorkoutCard extends ConsumerWidget {
  const SmartWorkoutCard({
    required this.onStartSuggested,
    required this.onTemplateSelected,
    required this.onRecentWorkoutSelected,
    required this.onViewAllTemplates,
    required this.onViewHistory,
    required this.onEmpty,
    this.onResumeDraft,
    this.onDiscardDraft,
    super.key,
  });

  static const double _contentIndent = AppSpacing.xxl + AppSpacing.xs;

  /// Called when user taps INIZIA with the suggested workout
  final void Function(String? templateId) onStartSuggested;

  /// Called when user selects a template from the popup
  final void Function(WorkoutTemplate template) onTemplateSelected;

  /// Called when user selects a recent workout to repeat
  final void Function(WorkoutHistoryDetail workout) onRecentWorkoutSelected;

  /// Called when user taps "View all templates..."
  final VoidCallback onViewAllTemplates;

  /// Called when user opens full workout history
  final VoidCallback onViewHistory;

  /// Called when user taps "Vuoto"
  final VoidCallback onEmpty;

  /// Called when user taps "Resume" on a pending draft
  final VoidCallback? onResumeDraft;

  /// Called when user taps "Discard" on a pending draft
  final VoidCallback? onDiscardDraft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(nextWorkoutSuggestionProvider);
    final draftAsync = ref.watch(pendingDraftInfoProvider);

    final suggestionCard = suggestionAsync.when(
      loading: () => _buildCardContainer(
        context,
        child: const SizedBox(
          height: 80,
          child: Center(child: LoadingIndicator()),
        ),
      ),
      error: (_, __) => _buildNewUserCard(context),
      data: (suggestion) => _buildSuggestionCard(context, suggestion),
    );

    // Show draft recovery card above suggestion card if draft exists
    final draftCard = draftAsync.whenOrNull(
      data: (info) =>
          info != null ? _buildDraftRecoveryCard(context, info) : null,
    );

    if (draftCard != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          draftCard,
          const SizedBox(height: AppSpacing.sm),
          suggestionCard,
        ],
      );
    }

    return suggestionCard;
  }

  Widget _buildDraftRecoveryCard(BuildContext context, PendingDraftInfo info) {
    final warningColor = context.warningColor;
    final onWarningContainer = context.colors.onWarningContainer;

    // Minutes since workout started
    final minutesAgo = info.startTime != null
        ? DateTime.now().difference(info.startTime!).inMinutes
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.warningContainer,
        borderRadius: AppBorderRadius.lgRadius,
        border: Border.all(color: warningColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: icon + title
          Row(
            children: [
              Icon(Icons.pause_circle_filled, color: warningColor, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.pendingWorkout,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: warningColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Info: name + stats
          Padding(
            padding: const EdgeInsets.only(left: _contentIndent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.workoutName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: onWarningContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.pendingWorkoutInfo(
                    info.exerciseCount,
                    info.completedSets,
                    info.totalSets,
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: onWarningContainer.withValues(alpha: 0.8),
                  ),
                ),
                if (minutesAgo != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.pendingWorkoutStartedAgo(minutesAgo),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: onWarningContainer.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Resume button
          _buildCTAButton(
            context,
            label: context.l10n.resumeWorkout,
            filled: true,
            filledBackgroundColor: warningColor,
            filledForegroundColor: context.textOnWarning,
            onTap: () => onResumeDraft?.call(),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Discard button (subtle)
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onDiscardDraft?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Text(
                  context.l10n.discard,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: warningColor.withValues(alpha: 0.85),
                    decoration: TextDecoration.underline,
                    decorationColor: warningColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    NextWorkoutSuggestion suggestion,
  ) {
    return switch (suggestion.type) {
      SplitDetectionType.newUser => _buildNewUserCard(context),
      _ => _buildSmartCard(context, suggestion),
    };
  }

  Widget _buildNewUserCard(BuildContext context) {
    return _buildCardContainer(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.quickActionStartWorkout,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCTAButton(
            context,
            label: context.l10n.quickActionStart,
            filled: true,
            onTap: () => onStartSuggested(null),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSecondaryActions(context),
        ],
      ),
    );
  }

  Widget _buildSmartCard(
    BuildContext context,
    NextWorkoutSuggestion suggestion,
  ) {
    final categoryName = _categoryLabel(context, suggestion.suggestedCategory);
    final emoji = _categoryEmoji(suggestion.suggestedCategory);

    // Build dynamic title
    final title = _buildTitle(context, suggestion, categoryName);

    // Build subtitle
    final subtitle = _buildSubtitle(context, suggestion);

    return _buildCardContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: "Basato sulla tua split:"
          if (suggestion.type == SplitDetectionType.patternDetected)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                context.l10n.quickActionBasedOnSplit,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ),

          // Main title with emoji
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Subtitle
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xxs,
                left: _contentIndent,
              ),
              child: Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // CTA: INIZIA button (full width)
          _buildCTAButton(
            context,
            label: context.l10n.quickActionStart,
            filled: true,
            onTap: () => onStartSuggested(suggestion.templateId),
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildSecondaryActions(context),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FromTemplatePopup(
                onTemplateSelected: onTemplateSelected,
                onViewAll: onViewAllTemplates,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RecentWorkoutsPopup(
                onWorkoutSelected: onRecentWorkoutSelected,
                onViewHistory: onViewHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCTAButton(
          context,
          label: context.l10n.quickActionEmptyWorkout,
          filled: false,
          onTap: onEmpty,
        ),
      ],
    );
  }

  String _buildTitle(
    BuildContext context,
    NextWorkoutSuggestion suggestion,
    String categoryName,
  ) {
    return switch (suggestion.type) {
      SplitDetectionType.patternDetected when suggestion.templateName != null =>
        '${suggestion.templateName} (${context.l10n.suggested})',
      SplitDetectionType.patternDetected =>
        '$categoryName (${context.l10n.suggested})',
      SplitDetectionType.recoveryBased =>
        '$categoryName — ${context.l10n.daysAgoShort(suggestion.daysSinceLast ?? 0)}',
      SplitDetectionType.imbalanceDetected =>
        '$categoryName — ${context.l10n.quickActionNotTrainedSince(suggestion.daysSinceLast ?? 0)}',
      SplitDetectionType.newUser => context.l10n.quickActionStartWorkout,
    };
  }

  String? _buildSubtitle(
    BuildContext context,
    NextWorkoutSuggestion suggestion,
  ) {
    if (suggestion.templateName != null &&
        suggestion.type == SplitDetectionType.patternDetected) {
      return context.l10n.quickActionTemplateLabel(suggestion.templateName!);
    }
    return null;
  }

  Widget _buildCardContainer(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh.withValues(alpha: 0.92),
        borderRadius: AppBorderRadius.lgRadius,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildCTAButton(
    BuildContext context, {
    required String label,
    required bool filled,
    required VoidCallback onTap,
    Color? filledBackgroundColor,
    Color? filledForegroundColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled
              ? (filledBackgroundColor ?? context.colors.primary)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: AppBorderRadius.buttonRadius,
          border: filled
              ? null
              : Border.all(
                  color: context.colors.outline.withValues(alpha: 0.25),
                ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.labelLarge?.copyWith(
            color: filled
                ? (filledForegroundColor ?? context.colors.onPrimary)
                : context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String _categoryLabel(
    BuildContext context,
    ExerciseCategory? category,
  ) {
    if (category == null) return '';
    return switch (category) {
      ExerciseCategory.chest => context.l10n.chest,
      ExerciseCategory.back => context.l10n.back,
      ExerciseCategory.shoulders => context.l10n.shoulders,
      ExerciseCategory.arms => context.l10n.arms,
      ExerciseCategory.legs => context.l10n.legs,
      ExerciseCategory.abs => context.l10n.abs,
      ExerciseCategory.cardio => context.l10n.cardio,
      ExerciseCategory.other => context.l10n.other,
    };
  }

  static String _categoryEmoji(ExerciseCategory? category) {
    return switch (category) {
      ExerciseCategory.chest => '\u{1F4AA}', // 💪
      ExerciseCategory.back => '\u{1F9B4}', // 🦴
      ExerciseCategory.shoulders => '\u{1F3CB}', // 🏋
      ExerciseCategory.arms => '\u{1F4AA}', // 💪
      ExerciseCategory.legs => '\u{1F9B5}', // 🦵
      ExerciseCategory.abs => '\u{1F3AF}', // 🎯
      ExerciseCategory.cardio => '\u{1F3C3}', // 🏃
      ExerciseCategory.other => '\u{2B50}', // ⭐
      null => '\u{1F3CB}', // 🏋
    };
  }
}
