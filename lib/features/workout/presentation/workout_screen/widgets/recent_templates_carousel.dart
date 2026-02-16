import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Horizontal carousel showing recently used workout templates
///
/// Displays up to 3 most recently updated templates with quick start buttons.
/// Last item is a "View all" card that navigates to templates screen.
class RecentTemplatesCarousel extends ConsumerWidget {
  const RecentTemplatesCarousel({
    required this.onStartTemplate,
    super.key,
  });

  /// Callback when user taps start button on a template
  final void Function(WorkoutTemplate template) onStartTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => _buildShimmer(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (templates) {
        // Empty state: no templates yet
        if (templates.isEmpty) {
          return _buildEmptyState(context);
        }

        // Sort by updatedAt descending (most recent first)
        final sortedTemplates = [...templates]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        // Take up to 3 most recent
        final recentTemplates = sortedTemplates.take(3).toList();
        final totalCount = templates.length;

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: recentTemplates.length + 1, // +1 for "View all" card
            itemBuilder: (context, index) {
              // Last item: "View all" card
              if (index == recentTemplates.length) {
                return _buildViewAllCard(context, totalCount);
              }

              // Template card
              final template = recentTemplates[index];
              return _buildTemplateCard(context, template);
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.folder,
            size: AppIconSize.large,
            color: context.colors.onSurfaceVariant,
            semanticLabel: context.l10n.noTemplatesYet,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.noTemplatesYet,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.createFirstTemplateHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () => context.push('/templates'),
            child: Text(context.l10n.createTemplate),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WorkoutTemplate template) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template name
            Expanded(
              child: Text(
                template.name,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Difficulty badge (if available)
            if (template.difficulty != null) ...[
              _buildDifficultyBadge(context, template.difficulty!),
              const SizedBox(height: AppSpacing.xs),
            ],

            // Estimated duration
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.timer,
                  size: AppIconSize.tiny,
                  color: context.colors.onSurfaceVariant,
                  semanticLabel: context.l10n.duration,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  '${template.estimatedDuration} ${context.l10n.minutes}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Start button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onStartTemplate(template),
                icon: SemanticIcon(
                  icon: AppIcons.play,
                  size: AppIconSize.tiny,
                  semanticLabel: context.l10n.start,
                ),
                label: Text(
                  context.l10n.start,
                  style: context.textTheme.labelSmall,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, String difficulty) {
    final difficultyLower = difficulty.toLowerCase();
    Color badgeColor;

    switch (difficultyLower) {
      case 'beginner':
        badgeColor = context.colors.success;
      case 'intermediate':
        badgeColor = context.colors.warning;
      case 'advanced':
      case 'expert':
        badgeColor = context.colors.error;
      default:
        badgeColor = context.colors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.xxs),
      ),
      child: Text(
        difficulty,
        style: context.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildViewAllCard(BuildContext context, int totalCount) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/templates'),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
                icon: AppIcons.arrowForward,
                size: AppIconSize.medium,
                color: context.colors.primary,
                semanticLabel: context.l10n.viewAll,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.viewAllCount(totalCount),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
