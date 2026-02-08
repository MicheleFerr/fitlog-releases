/// Superset Template Preview Sheet
///
/// Bottom sheet showing full details of a superset template.
///
/// **Sections**:
/// - Template header (name, difficulty, duration)
/// - Exercise pairing details
/// - Configuration (rounds, rest times, reps)
/// - Scientific evidence (if available)
/// - Equipment requirements
/// - Action buttons (Use Template, Save Custom Copy)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/superset_template_event_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Bottom sheet with superset template details
class SupersetTemplatePreviewSheet extends ConsumerWidget {
  const SupersetTemplatePreviewSheet({
    super.key,
    required this.template,
    this.onUseTemplate,
    this.onSaveCustomCopy,
  });

  final SupersetTemplate template;
  final VoidCallback? onUseTemplate;
  final VoidCallback? onSaveCustomCopy;

  /// Show the superset template preview sheet
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required SupersetTemplate template,
    VoidCallback? onUseTemplate,
    VoidCallback? onSaveCustomCopy,
    String source = 'unknown',
  }) {
    // Track template viewed
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = SupersetTemplateEventTracker(analytics);
    tracker.trackTemplateViewed(template: template, source: source);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => SupersetTemplatePreviewSheet(
        template: template,
        onUseTemplate: onUseTemplate,
        onSaveCustomCopy: onSaveCustomCopy,
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (template.difficulty) {
      case TemplateDifficulty.beginner:
        return context.colors.success; // Green
      case TemplateDifficulty.intermediate:
      case TemplateDifficulty.intermediateAdvanced:
        return context.colors.primary; // Blue
      case TemplateDifficulty.advanced:
        return context.colors.error; // Red
    }
  }

  String _getDifficultyLabel(BuildContext context) {
    switch (template.difficulty) {
      case TemplateDifficulty.beginner:
        return context.l10n.beginner;
      case TemplateDifficulty.intermediate:
        return context.l10n.intermediate;
      case TemplateDifficulty.intermediateAdvanced:
        return context.l10n.advanced;
      case TemplateDifficulty.advanced:
        return context.l10n.advanced;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasScientificBasis = template.scientificBasis.isNotEmpty;
    final hasNotes = template.notes != null && template.notes!.isNotEmpty;
    final hasEquipment =
        template.equipmentRequired != null &&
        template.equipmentRequired!.isNotEmpty;

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: safeMax,
      snap: true,
      snapSizes: [0.6, safeMax],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.link,
                      color: context.colors.primary,
                      size: AppIconSize.large,
                    ),
                    const SizedBox(width: 12),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    context,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getDifficultyLabel(context),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getDifficultyColor(context),
                                  ),
                                ),
                              ),
                              if (hasScientificBasis) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  AppIcons.science,
                                  size: AppIconSize.small,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.evidenceBased,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    // Quick stats row
                    Row(
                      children: [
                        _StatChip(
                          icon: AppIcons.repeat,
                          label: '${template.rounds}x ${context.l10n.rounds}',
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          icon: AppIcons.timer,
                          label: '${template.estimatedTimeMinutes}min',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Exercise pairing
                    _SectionHeader(
                      icon: AppIcons.exercise,
                      title: context.l10n.exercisePairing,
                    ),
                    const SizedBox(height: 12),
                    ...template.exerciseNames.map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Configuration
                    _SectionHeader(
                      icon: AppIcons.settings,
                      title: context.l10n.configuration,
                    ),
                    const SizedBox(height: 12),
                    _ConfigRow(
                      label: context.l10n.repsRange,
                      value: template.repsRange,
                    ),
                    _ConfigRow(
                      label: context.l10n.restBetweenExercises,
                      value: '${template.restAfterSuperset}s',
                    ),
                    _ConfigRow(
                      label: context.l10n.restAfterRound,
                      value: '${template.restAfterRound}s',
                    ),
                    if (template.tut != null)
                      _ConfigRow(label: 'TUT', value: template.tut!),

                    // Scientific evidence
                    if (hasScientificBasis) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(
                        icon: AppIcons.science,
                        title: context.l10n.scientificEvidence,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          template.scientificBasis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    // Notes
                    if (hasNotes) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(
                        icon: AppIcons.notes,
                        title: context.l10n.notes,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        template.notes!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],

                    // Equipment
                    if (hasEquipment) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(
                        icon: AppIcons.build,
                        title: context.l10n.equipmentRequired,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: template.equipmentRequired!
                            .map(
                              (equipment) => Chip(
                                label: Text(
                                  equipment,
                                  style: context.textTheme.bodySmall,
                                ),
                                backgroundColor:
                                    context.colors.surfaceContainer,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Action buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary action: Use Template
                      if (onUseTemplate != null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();

                              // Track template used
                              final analytics = ref.read(
                                analyticsServiceProvider,
                              );
                              final tracker = SupersetTemplateEventTracker(
                                analytics,
                              );
                              tracker.trackTemplateUsed(
                                template: template,
                                source: 'preview_sheet',
                              );

                              Navigator.of(context).pop();
                              onUseTemplate!();
                            },
                            child: Text(context.l10n.useTemplate),
                          ),
                        ),

                      // Secondary action: Save Custom Copy
                      if (onSaveCustomCopy != null) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              // Track custom copy saved
                              final analytics = ref.read(
                                analyticsServiceProvider,
                              );
                              final tracker = SupersetTemplateEventTracker(
                                analytics,
                              );
                              tracker.trackCustomTemplateSaved(
                                template: template,
                                customTemplateName:
                                    template.name, // Will be customized later
                              );

                              Navigator.of(context).pop();
                              onSaveCustomCopy!();
                            },
                            child: Text(context.l10n.saveCustomCopy),
                          ),
                        ),
                      ],
                    ],
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

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.medium,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Configuration row widget
class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat chip widget
class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.small,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
