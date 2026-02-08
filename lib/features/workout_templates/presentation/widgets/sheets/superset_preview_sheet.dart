/// Preview sheet for predefined superset templates in Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/common/stat_chip.dart';

class SupersetPreviewSheet extends StatelessWidget {
  const SupersetPreviewSheet({
    super.key,
    required this.template,
    required this.onUse,
  });

  final SupersetTemplate template;
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
                            color: context.colors.secondary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.link,
                            semanticLabel: l10n.superset,
                            size: AppIconSize.large,
                            color: context.colors.secondary,
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
                                  color: context.colors.secondary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  template.difficulty.name,
                                  style:
                                      context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.secondary,
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
                          icon: AppIcons.repeat,
                          label: '${template.rounds} ${l10n.rounds}',
                          color: context.colors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatChip(
                          icon: AppIcons.timer,
                          label: '${template.estimatedTimeMinutes} min',
                          color: context.colors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatChip(
                          icon: AppIcons.workout,
                          label: template.repsRange,
                          color: context.colors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Exercises
                    Text(
                      l10n.exercises,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...template.exerciseNames.asMap().entries.map((entry) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colors.secondary.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(color: context.colors.secondary),
                          ),
                        ),
                        title: Text(entry.value),
                        dense: true,
                      );
                    }),

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
