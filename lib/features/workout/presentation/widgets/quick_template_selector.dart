import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Quick selector for exercise templates (reduce taps from 15 → 3)
///
/// Shows horizontal list of recently used exercise templates
/// Tapping a template pre-fills sets with last workout's data
/// Part of P1 friction reduction - improves workout logging speed
class QuickTemplateSelector extends StatelessWidget {
  const QuickTemplateSelector({
    required this.templates,
    required this.onTemplateSelected,
    super.key,
  });

  final List<ExerciseTemplate> templates;
  final void Function(ExerciseTemplate) onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.quickStart,
          style: context.textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateChip(context, template);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateChip(BuildContext context, ExerciseTemplate template) {
    return ActionChip(
      avatar: Icon(
        AppIcons.workout,
        size: AppIconSize.small,
        color: context.colors.primary,
      ),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.exerciseName,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${template.defaultWeight.toInt()}kg × ${template.defaultReps}',
            style: context.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onPressed: () => onTemplateSelected(template),
    );
  }
}
