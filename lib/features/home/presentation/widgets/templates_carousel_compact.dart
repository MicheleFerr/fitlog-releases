import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Carousel compatto di template per quick access
///
/// Mostra i 3 template più usati con possibilità di avviare workout
class TemplatesCarouselCompact extends ConsumerWidget {
  const TemplatesCarouselCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateProvider);
    final templates = templateState.userTemplates;
    final isLoading = templateState.isLoading;

    // Ordina per updatedAt (più recente prima) e prendi i primi 3
    final recentTemplates = [...templates]
      ..sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt;
        final bDate = b.updatedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
    final displayTemplates = recentTemplates.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.listAlt,
                  semanticLabel: context.l10n.templates,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.templates,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/templates');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.viewAll),
                      const SizedBox(width: 4),
                      SemanticIcon(
                        icon: AppIcons.chevronRight,
                        semanticLabel: context.l10n.viewAll,
                        size: AppIconSize.tiny,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (isLoading)
            const _LoadingSkeleton()
          else if (displayTemplates.isEmpty)
            _EmptyState()
          else
            SizedBox(
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
        ],
      ),
    );
  }
}

/// Card singolo template
class _TemplateCard extends ConsumerWidget {
  final CommunityWorkoutTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = template.name;
    final exerciseCount = template.exercises.length;
    final estimatedDuration = template.estimatedDurationMinutes ?? 45;

    return SizedBox(
      width: 140,
      child: Material(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
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
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Stats
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: context.l10n.exercises,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$exerciseCount ex.',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.timer,
                      semanticLabel: context.l10n.duration,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '~${estimatedDuration}min',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startWorkoutFromTemplate(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    // Navigate to templates screen where user can start the workout
    context.push('/templates');
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
