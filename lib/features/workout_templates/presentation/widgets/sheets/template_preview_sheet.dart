/// Preview sheet for default workout templates in Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

class TemplatePreviewSheet extends StatelessWidget {
  const TemplatePreviewSheet({
    super.key,
    required this.template,
    required this.onUse,
  });

  final WorkoutTemplate template;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Only show difficulty badge if difficulty is not null
                              if (template.difficulty != null &&
                                  template.difficulty!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    template.difficulty!.toUpperCase(),
                                    style:
                                        context.textTheme.labelSmall?.copyWith(
                                      color:
                                          context.colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (template.difficulty != null &&
                                  template.difficulty!.isNotEmpty)
                                const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${template.exercises.length} ${l10n.exercises}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '~${template.estimatedDuration}m',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: l10n.close,
                        size: AppIconSize.medium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  template.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Exercises list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: template.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = template.exercises[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: context.colors.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.colors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(exercise.exerciseName),
                      subtitle: Text(
                        '${exercise.sets.length} set × ${exercise.sets.firstOrNull?.targetReps ?? 0} rep',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      trailing:
                          exercise.notes != null && exercise.notes!.isNotEmpty
                              ? IconButton(
                                  onPressed: () => _showExerciseNotes(
                                    context,
                                    exercise.exerciseName,
                                    exercise.notes!,
                                  ),
                                  icon: SemanticIcon(
                                    icon: AppIcons.infoOutline,
                                    semanticLabel: l10n.notes,
                                    size: AppIconSize.small,
                                    color: context.colors.primary,
                                  ),
                                )
                              : null,
                    );
                  },
                ),
              ),

              // Use button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onUse,
                    icon: SemanticIcon(
                      icon: AppIcons.add,
                      semanticLabel: l10n.add,
                      size: AppIconSize.small,
                    ),
                    label: Text(l10n.addToMyTemplates),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows exercise notes in a dialog
  void _showExerciseNotes(
    BuildContext context,
    String exerciseName,
    String notes,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          exerciseName.isNotEmpty ? exerciseName : 'Note',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(notes, style: context.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}
