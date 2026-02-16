import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/template_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:shimmer/shimmer.dart';

/// Card showing AI-suggested template for today based on muscle recovery
///
/// Displays the best template recommendation from [templateSuggestionProvider]
/// with rationale and quick start button.
class TodaysWorkoutCard extends ConsumerWidget {
  const TodaysWorkoutCard({
    required this.onStartTemplate,
    super.key,
  });

  /// Callback when user taps "Start" button
  final void Function(WorkoutTemplate template) onStartTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🆕 FASE 1 MVP: Use new multi-factor scoring algorithm
    final suggestionAsync = ref.watch(smartTemplateSuggestionAdapterProvider);
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return suggestionAsync.when(
      loading: () => _buildShimmer(context),
      error: (_, __) => _buildRestDayCard(context), // Show rest day on error
      data: (suggestions) {
        // No suggestions or empty → show rest day card
        if (suggestions == null || suggestions.isEmpty) {
          return _buildRestDayCard(context);
        }

        // Get best suggestion (first in list, already sorted by optimality)
        final bestSuggestion = suggestions.first;

        // Find the actual WorkoutTemplate from template provider
        return templatesAsync.when(
          loading: () => _buildShimmer(context),
          error: (_, __) => _buildRestDayCard(context),
          data: (templates) {
            try {
              final template = templates.firstWhere(
                (t) => t.id == bestSuggestion.templateId,
              );
              return _buildCard(context, bestSuggestion, template);
            } catch (_) {
              // Template not found, show rest day card
              return _buildRestDayCard(context);
            }
          },
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceContainerLow,
      highlightColor: context.colors.surfaceContainerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        height: 140,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: "Suggested for today" badge
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: context.colors.success,
                  semanticLabel: context.l10n.suggestedForToday,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.suggestedForToday,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Rest day title
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.bedtime,
                  size: AppIconSize.large,
                  color: context.colors.success,
                  semanticLabel: context.l10n.restDaySuggestion,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.restDay,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.l10n.restDaySuggestion,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    dynamic suggestion,
    WorkoutTemplate template,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: "Suggested for today" badge
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                  semanticLabel: context.l10n.suggestedForToday,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.suggestedForToday,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Recovery indicator badge
                _buildRecoveryBadge(context, suggestion),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Template name
            Text(
              template.name,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Rationale (why this template)
            Text(
              suggestion.rationale as String,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),

            // Start button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => onStartTemplate(template),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.play,
                      size: AppIconSize.small,
                      semanticLabel: context.l10n.start,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.start),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryBadge(BuildContext context, dynamic suggestion) {
    // Get recovery status icon/text based on recommendation
    final isOptimal = suggestion.recommendation.toString().contains('optimal');
    final icon = isOptimal ? AppIcons.check : AppIcons.info;
    final text = isOptimal
        ? context.l10n.musclesRecovered
        : context.l10n.acceptable;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOptimal
            ? context.colors.success.withValues(alpha: 0.15)
            : context.colors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: icon,
            size: AppIconSize.tiny,
            color: isOptimal ? context.colors.success : context.colors.warning,
            semanticLabel: text,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: isOptimal ? context.colors.success : context.colors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
