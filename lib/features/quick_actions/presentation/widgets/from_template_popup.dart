/// From Template button
///
/// Opens a bottom sheet with the user's workout templates,
/// sorted by creation date (newest first), so the whole list
/// is reachable directly from the quick actions overlay.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class FromTemplatePopup extends StatelessWidget {
  const FromTemplatePopup({
    required this.onTemplateSelected,
    required this.onViewAll,
    super.key,
  });

  final void Function(WorkoutTemplate template) onTemplateSelected;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ModalService.showSheet(
          context,
          isScrollControlled: true,
          useRootNavigator: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => _TemplatePickerSheet(
            onTemplateSelected: onTemplateSelected,
            onViewAll: onViewAll,
          ),
        );
      },
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: AppBorderRadius.buttonRadius,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          context.l10n.fromTemplate,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TemplatePickerSheet extends ConsumerWidget {
  const _TemplatePickerSheet({
    required this.onTemplateSelected,
    required this.onViewAll,
  });

  final void Function(WorkoutTemplate template) onTemplateSelected;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.fromTemplate,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const SemanticIcon(
                      icon: AppIcons.close,
                      semanticLabel: 'Close',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: templatesAsync.when(
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (_, __) => _EmptyTemplatesState(
                    onViewAll: () {
                      Navigator.of(context).pop();
                      onViewAll();
                    },
                  ),
                  data: (templates) {
                    final chronologicalTemplates = [...templates]
                      ..sort((a, b) {
                        final createdCompare = b.createdAt.compareTo(
                          a.createdAt,
                        );
                        if (createdCompare != 0) return createdCompare;
                        return b.updatedAt.compareTo(a.updatedAt);
                      });

                    if (chronologicalTemplates.isEmpty) {
                      return _EmptyTemplatesState(
                        onViewAll: () {
                          Navigator.of(context).pop();
                          onViewAll();
                        },
                      );
                    }

                    return ListView.separated(
                      itemCount: chronologicalTemplates.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        if (index == chronologicalTemplates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onViewAll();
                              },
                              icon: const Icon(AppIcons.listAlt),
                              label: Text(
                                context.l10n.quickActionViewAllTemplates,
                              ),
                            ),
                          );
                        }

                        final template = chronologicalTemplates[index];
                        return _TemplateListTile(
                          template: template,
                          onTap: () {
                            Navigator.of(context).pop();
                            onTemplateSelected(template);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({required this.template, required this.onTap});

  final WorkoutTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final createdLabel = DateFormat.yMMMd(
      context.l10n.localeName,
    ).format(template.createdAt);

    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.listAlt,
                  color: context.colors.onPrimaryContainer,
                  size: AppIconSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${context.l10n.exerciseCount(template.exercises.length)} • ${context.l10n.createdAt}: $createdLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                AppIcons.chevronRight,
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTemplatesState extends StatelessWidget {
  const _EmptyTemplatesState({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SemanticIcon(
            icon: AppIcons.listAlt,
            semanticLabel: 'Templates',
            size: AppIconSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.quickActionNoTemplates,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(AppIcons.add),
            label: Text(context.l10n.createTemplate),
          ),
        ],
      ),
    );
  }
}
