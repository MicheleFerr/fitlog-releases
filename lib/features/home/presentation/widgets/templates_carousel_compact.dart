import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Carousel compatto di template per quick access
///
/// Mostra i 3 template più usati con possibilità di avviare workout
class TemplatesCarouselCompact extends ConsumerWidget {
  const TemplatesCarouselCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => _buildContainer(context, child: const _LoadingSkeleton()),
      error: (error, stack) => _buildContainer(context, child: _EmptyState()),
      data: (templates) {
        // Ordina per updatedAt (più recente prima) e prendi i primi 3
        final recentTemplates = [...templates]
          ..sort((a, b) {
            return b.updatedAt.compareTo(a.updatedAt);
          });
        final displayTemplates = recentTemplates.take(3).toList();

        return _buildContent(context, displayTemplates);
      },
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    final colorScheme = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), child],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SemanticIcon(
              icon: AppIcons.listAlt,
              semanticLabel: context.l10n.templates,
              size: AppIconSize.small,
              color: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.templates,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/templates');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.viewAll,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                SemanticIcon(
                  icon: AppIcons.chevronRight,
                  semanticLabel: context.l10n.viewAll,
                  size: AppIconSize.tiny,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<WorkoutTemplate> displayTemplates,
  ) {
    if (displayTemplates.isEmpty) {
      return _buildContainer(context, child: _EmptyState());
    }

    return _buildContainer(
      context,
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          scrollDirection: Axis.horizontal,
          itemCount: displayTemplates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _TemplateCard(template: displayTemplates[index]);
          },
        ),
      ),
    );
  }
}

/// Card singolo template with elevated design
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});
  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;
    final name = template.name;
    final exerciseCount = template.exercises.length;
    final estimatedDuration = template.estimatedDuration;

    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            label: 'Start workout from $name template',
            hint: '$exerciseCount exercises, estimated $estimatedDuration minutes',
            button: true,
            child: InkWell(
              onTap: () => _startWorkoutFromTemplate(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome template
                  Text(
                    name,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Stats row
                  Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.workout,
                        semanticLabel: context.l10n.exercises,
                        size: AppIconSize.tiny,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$exerciseCount',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SemanticIcon(
                        icon: AppIcons.timer,
                        semanticLabel: context.l10n.duration,
                        size: AppIconSize.tiny,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${estimatedDuration}m',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _startWorkoutFromTemplate(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    // Start workout directly from this template
    ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);
    context.go('/workout');
  }
}

/// Skeleton loading
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

/// Empty state quando non ci sono template
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            SemanticIcon(
              icon: AppIcons.addCircle,
              semanticLabel: context.l10n.createTemplate,
              size: AppIconSize.large,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noTemplatesYet,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/templates');
              },
              child: Text(context.l10n.createTemplate),
            ),
          ],
        ),
      ),
    );
  }
}
