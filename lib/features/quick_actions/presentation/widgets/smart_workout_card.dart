/// Smart Workout Card
///
/// Section 1 of the Quick Actions overlay.
/// Shows a smart workout suggestion based on split detection,
/// with dynamic labels and action buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/quick_actions/domain/services/split_detection_service.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/providers/next_workout_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/from_template_popup.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Smart workout suggestion card for the Quick Actions overlay
class SmartWorkoutCard extends ConsumerWidget {
  const SmartWorkoutCard({
    required this.onStartSuggested,
    required this.onTemplateSelected,
    required this.onViewAllTemplates,
    required this.onEmpty,
    super.key,
  });

  /// Called when user taps INIZIA with the suggested workout
  final void Function(String? templateId) onStartSuggested;

  /// Called when user selects a template from the popup
  final void Function(WorkoutTemplate template) onTemplateSelected;

  /// Called when user taps "View all templates..."
  final VoidCallback onViewAllTemplates;

  /// Called when user taps "Vuoto"
  final VoidCallback onEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(nextWorkoutSuggestionProvider);

    return suggestionAsync.when(
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
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FromTemplatePopup(
                  onTemplateSelected: onTemplateSelected,
                  onViewAll: onViewAllTemplates,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCTAButton(
                  context,
                  label: context.l10n.quickActionStart,
                  filled: true,
                  onTap: () => onStartSuggested(null),
                ),
              ),
            ],
          ),
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.l10n.quickActionBasedOnSplit,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ),

          // Main title with emoji
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Subtitle
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 38),
              child: Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // CTA: INIZIA button (full width)
          _buildCTAButton(
            context,
            label: context.l10n.quickActionStart,
            filled: true,
            onTap: () => onStartSuggested(suggestion.templateId),
          ),

          const SizedBox(height: 10),

          // Secondary row: Da Template + Vuoto
          Row(
            children: [
              Expanded(
                child: FromTemplatePopup(
                  onTemplateSelected: onTemplateSelected,
                  onViewAll: onViewAllTemplates,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCTAButton(
                  context,
                  label: context.l10n.quickActionEmptyWorkout,
                  filled: false,
                  onTap: onEmpty,
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
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
              ? context.colors.primary
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: filled ? Colors.white : Colors.white.withValues(alpha: 0.9),
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
