/// Predictive Balance Indicator Widget
///
/// Inline indicator that shows when a neglected muscle would be
/// resolved by completing the predicted missing workout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/pattern_prediction.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/presentation/providers/predictive_balance_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Inline indicator for predictive balance
///
/// Shows a contextual message like "Complete Leg Day to balance ✓"
/// when a neglected muscle would be resolved by completing the
/// predicted missing workout.
///
/// **Features**:
/// - Tappable to navigate to suggested template
/// - Subtle styling that doesn't alarm the user
/// - Shows only when pattern is detected and muscle would be resolved
///
/// **Usage**:
/// ```dart
/// // In a neglected muscle card
/// PredictiveBalanceIndicator(
///   muscleName: 'quadriceps',
/// )
/// ```
class PredictiveBalanceIndicator extends ConsumerWidget {
  const PredictiveBalanceIndicator({
    super.key,
    required this.muscleName,
    this.compact = false,
  });

  /// Muscle name to check for resolution
  final String muscleName;

  /// Use compact mode for smaller spaces
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this muscle would be resolved
    final wouldResolveAsync = ref.watch(
      muscleWouldBeResolvedProvider(muscleName),
    );

    return wouldResolveAsync.when(
      data: (wouldResolve) {
        if (!wouldResolve) return const SizedBox.shrink();

        // Get the prediction for display
        final predictionAsync = ref.watch(missingWorkoutProvider);

        return predictionAsync.when(
          data: (prediction) {
            if (prediction == null) return const SizedBox.shrink();
            return _buildIndicator(context, prediction);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIndicator(BuildContext context, PatternPrediction prediction) {
    final templateName = prediction.displayName;
    final hasTemplate = prediction.hasTemplate;

    return GestureDetector(
      onTap: hasTemplate
          ? () => _navigateToTemplate(context, prediction.suggestedTemplateId!)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.completeOutline,
              size: compact ? AppIconSize.tiny : AppIconSize.small,
              color: context.colors.primary.withValues(alpha: 0.8),
            ),
            SizedBox(width: compact ? 4 : 6),
            Flexible(
              child: Text(
                context.l10n.completeToBalance(templateName),
                style: (compact
                        ? context.textTheme.labelSmall
                        : context.textTheme.bodySmall)
                    ?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasTemplate) ...[
              SizedBox(width: compact ? 2 : 4),
              Icon(
                AppIcons.chevronRight,
                size: compact ? AppIconSize.tiny : AppIconSize.small,
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToTemplate(BuildContext context, String templateId) {
    // Navigate to start workout with template
    context.push('/workout/start/$templateId');
  }
}

/// Standalone prediction card for muscle balance tab header
///
/// Shows the overall prediction status for the current week.
/// Different from the inline indicator - this is a card-style widget.
///
/// **Usage**:
/// ```dart
/// // At the top of muscle balance tab
/// const PredictiveBalanceCard()
/// ```
class PredictiveBalanceCard extends ConsumerWidget {
  const PredictiveBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(missingWorkoutProvider);
    final patternAsync = ref.watch(weeklyPatternProvider);

    return patternAsync.when(
      data: (pattern) {
        if (pattern == null || !pattern.isValid) {
          return const SizedBox.shrink();
        }

        return predictionAsync.when(
          data: (prediction) {
            if (prediction == null) {
              // All workouts completed!
              return _buildCompletedCard(context, pattern.cycleLength);
            }
            return _buildPredictionCard(context, ref, prediction);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompletedCard(BuildContext context, int cycleLength) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.complete,
            color: context.colors.success,
            size: AppIconSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.weeklyPatternComplete,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  context.l10n.allWorkoutsCompleted(cycleLength),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    WidgetRef ref,
    PatternPrediction prediction,
  ) {
    final completionAsync = ref.watch(weekCompletionStatusProvider);

    return completionAsync.when(
      data: (status) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppIcons.insights,
                    color: context.colors.primary,
                    size: AppIconSize.medium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.weeklyProgress,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          context.l10n.workoutsCompletedThisWeek(
                            status.completedWorkouts,
                            status.expectedWorkouts,
                          ),
                          style: context.textTheme.bodySmall?.copyWith(
                            color:
                                context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      progress: status.progressPercentage,
                      strokeWidth: 4,
                      size: 40,
                      backgroundColor:
                          context.colors.primary.withValues(alpha: 0.2),
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Next workout suggestion
              GestureDetector(
                onTap: prediction.hasTemplate
                    ? () => _navigateToTemplate(
                          context,
                          prediction.suggestedTemplateId!,
                        )
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.workout,
                        color: context.colors.primary,
                        size: AppIconSize.small,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.nextWorkoutSuggestion(
                            prediction.displayName,
                          ),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (prediction.hasTemplate)
                        Icon(
                          AppIcons.chevronRight,
                          color: context.colors.onSurface.withValues(alpha: 0.4),
                          size: AppIconSize.small,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _navigateToTemplate(BuildContext context, String templateId) {
    context.push('/workout/start/$templateId');
  }
}
