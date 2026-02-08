/// Preview sheet for predefined dropset templates in Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/common/stat_chip.dart';

class DropsetPreviewSheet extends StatelessWidget {
  const DropsetPreviewSheet({
    super.key,
    required this.template,
    required this.onUse,
  });

  final DropsetTemplate template;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.tertiary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.trendDown,
                            semanticLabel: l10n.dropset,
                            size: AppIconSize.large,
                            color: context.colors.tertiary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.name,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.tertiary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  template.difficulty.name,
                                  style:
                                      context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Stats
                    Row(
                      children: [
                        StatChip(
                          icon: AppIcons.trendDown,
                          label: '${template.drops} ${l10n.drops}',
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatChip(
                          icon: AppIcons.timer,
                          label: '${template.estimatedTimeMinutes} min',
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatChip(
                          icon: AppIcons.percent,
                          label: '-${template.dropPercentage}%',
                          color: context.colors.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Exercise info
                    Text(
                      l10n.exercise,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: context.colors.tertiary.withValues(
                          alpha: 0.2,
                        ),
                        child: SemanticIcon(
                          icon: AppIcons.workout,
                          semanticLabel: l10n.exercise,
                          size: AppIconSize.small,
                          color: context.colors.tertiary,
                        ),
                      ),
                      title: Text(template.exerciseName),
                      subtitle: Text('${template.initialReps} ${l10n.reps}'),
                    ),

                    // Scientific basis
                    if (template.scientificBasis.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.scientificBasis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          template.scientificBasis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],

                    // Notes
                    if (template.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.notes,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        template.notes!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),

              // Bottom button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onUse,
                      icon: const Icon(AppIcons.add),
                      label: Text(l10n.addToMyTemplates),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
