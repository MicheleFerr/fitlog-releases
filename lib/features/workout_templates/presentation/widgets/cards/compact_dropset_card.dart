/// Compact dropset card for horizontal scroll in Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/common/difficulty_badge.dart';

class CompactDropsetCard extends StatelessWidget {
  const CompactDropsetCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onUse,
    this.isCustom = false,
  });

  final DropsetTemplate template;
  final VoidCallback onTap;
  final VoidCallback onUse;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template name
                Text(
                  template.name,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Stats row
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.trendDown,
                      semanticLabel: l10n.drops,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.drops}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SemanticIcon(
                      icon: AppIcons.timer,
                      semanticLabel: l10n.duration,
                      size: AppIconSize.tiny,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.estimatedTimeMinutes}\'',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Difficulty badge
                DifficultyBadge(
                  difficulty: template.difficulty.name,
                  color: context.colors.tertiary,
                ),
                const Spacer(),
                // Use button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(l10n.use, style: context.textTheme.labelSmall),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
