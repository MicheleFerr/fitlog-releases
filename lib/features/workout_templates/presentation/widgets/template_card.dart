/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// This is for COMMUNITY/PUBLIC templates (shareable with others).
/// For internal workout template cards, see:
/// `lib/features/workout/presentation/widgets/template_card.dart`
///
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// @deprecated Use [CommunityTemplateCard] instead to avoid naming conflicts
/// with workout internal TemplateCard widget.
@Deprecated('Use CommunityTemplateCard instead - avoids naming conflict with workout TemplateCard')
typedef TemplateCard = CommunityTemplateCard;

class CommunityTemplateCard extends StatelessWidget {

  const CommunityTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });
  final CommunityWorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con categoria e visibilità
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(context, template.category),
                    _getCategoryColor(context, template.category).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(template.category),
                    color: context.colors.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.category.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (template.visibility == TemplateVisibility.public)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.public,
                            size: 12,
                            color: context.colors.surface,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'PUBLIC',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.colors.surface,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (template.description != null)
                      Text(
                        template.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const Spacer(),
                    
                    // Stats
                    Row(
                      children: [
                        _buildStat(
                          AppIcons.workout,
                          '${template.exercises.length}',
                          colorScheme,
                        ),
                        const SizedBox(width: 12),
                        if (template.estimatedDurationMinutes != null)
                          _buildStat(
                            AppIcons.timer,
                            '${template.estimatedDurationMinutes}m',
                            colorScheme,
                          ),
                        if (template.visibility == TemplateVisibility.public) ...[
                          const SizedBox(width: 12),
                          _buildStat(
                            AppIcons.star,
                            template.averageRating.toStringAsFixed(1),
                            colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onEdit!();
                      },
                      icon: Icon(AppIcons.edit, size: 18),
                      tooltip: 'Edit',
                    ),
                  if (onShare != null)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onShare!();
                      },
                      icon: Icon(AppIcons.share, size: 18),
                      tooltip: 'Share',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDelete!();
                      },
                      icon: Icon(
                        AppIcons.delete,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(IconData icon, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Color _getCategoryColor(BuildContext context, TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.colors.error;
      case TemplateCategory.hypertrophy:
        return context.colors.primary;
      case TemplateCategory.endurance:
        return context.colors.success;
      case TemplateCategory.powerlifting:
        return context.colors.tertiary;
      case TemplateCategory.bodybuilding:
        return context.colors.secondary;
      case TemplateCategory.crossfit:
        return context.colors.tertiary;
      case TemplateCategory.calisthenics:
        return context.colors.primary;
      case TemplateCategory.cardio:
        return context.colors.secondary;
      case TemplateCategory.mixed:
        return context.colors.surfaceContainerHighest;
      case TemplateCategory.custom:
        return context.colors.onSurfaceVariant;
    }
  }
  
  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return AppIcons.workout;
      case TemplateCategory.hypertrophy:
        return AppIcons.expand;
      case TemplateCategory.endurance:
        return AppIcons.cardio;
      case TemplateCategory.powerlifting:
        return AppIcons.sportsMartialArts;
      case TemplateCategory.bodybuilding:
        return AppIcons.accessibility;
      case TemplateCategory.crossfit:
        return AppIcons.sports;
      case TemplateCategory.calisthenics:
        return AppIcons.accessibility;
      case TemplateCategory.cardio:
        return AppIcons.favorite;
      case TemplateCategory.mixed:
        return AppIcons.shuffle;
      case TemplateCategory.custom:
        return AppIcons.tune;
    }
  }
}