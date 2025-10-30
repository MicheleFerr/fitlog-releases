/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
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

class TemplateCard extends StatelessWidget {
  
  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });
  final WorkoutTemplate template;
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
                    _getCategoryColor(template.category),
                    _getCategoryColor(template.category).withValues(alpha: 0.7),
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
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.category.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'PUBLIC',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
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
                          Icons.fitness_center,
                          '${template.exercises.length}',
                          colorScheme,
                        ),
                        const SizedBox(width: 12),
                        if (template.estimatedDurationMinutes != null)
                          _buildStat(
                            Icons.timer,
                            '${template.estimatedDurationMinutes}m',
                            colorScheme,
                          ),
                        if (template.visibility == TemplateVisibility.public) ...[
                          const SizedBox(width: 12),
                          _buildStat(
                            Icons.star,
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
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit',
                    ),
                  if (onShare != null)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onShare!();
                      },
                      icon: const Icon(Icons.share, size: 18),
                      tooltip: 'Share',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDelete!();
                      },
                      icon: Icon(
                        Icons.delete,
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
  
  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return Colors.red;
      case TemplateCategory.hypertrophy:
        return Colors.blue;
      case TemplateCategory.endurance:
        return Colors.green;
      case TemplateCategory.powerlifting:
        return Colors.deepPurple;
      case TemplateCategory.bodybuilding:
        return Colors.orange;
      case TemplateCategory.crossfit:
        return Colors.teal;
      case TemplateCategory.calisthenics:
        return Colors.indigo;
      case TemplateCategory.cardio:
        return Colors.pink;
      case TemplateCategory.mixed:
        return Colors.grey;
      case TemplateCategory.custom:
        return Colors.blueGrey;
    }
  }
  
  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return Icons.fitness_center;
      case TemplateCategory.hypertrophy:
        return Icons.expand;
      case TemplateCategory.endurance:
        return Icons.directions_run;
      case TemplateCategory.powerlifting:
        return Icons.sports_martial_arts;
      case TemplateCategory.bodybuilding:
        return Icons.accessibility_new;
      case TemplateCategory.crossfit:
        return Icons.sports;
      case TemplateCategory.calisthenics:
        return Icons.accessibility;
      case TemplateCategory.cardio:
        return Icons.favorite;
      case TemplateCategory.mixed:
        return Icons.shuffle;
      case TemplateCategory.custom:
        return Icons.tune;
    }
  }
}