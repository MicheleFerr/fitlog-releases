import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Tier-1 Exercise Header Widget with category icons, badges, and TUT timer
class ExerciseHeaderTier1 extends StatelessWidget {
  
  const ExerciseHeaderTier1({
    super.key,
    required this.exercise,
    this.onTap,
  });
  final Exercise exercise;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category Icon
            _buildCategoryIcon(theme),
            
            const SizedBox(width: 12),
            
            // Exercise Name and Type Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeBadge(theme),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Sets info
                      Text(
                        '${exercise.sets.length} ${l10n.sets}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      
                      // Future: TUT Timer will be added here
                    ],
                  ),
                ],
              ),
            ),
            
            // Chevron
            Icon(
              AppIcons.chevronRightRounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryIcon(ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (exercise.category.name.toLowerCase()) {
      case 'chest':
        icon = AppIcons.workout;
        color = theme.colorScheme.primary;
        break;
      case 'back':
        icon = AppIcons.accessibility;
        color = theme.colorScheme.secondary;
        break;
      case 'shoulders':
        icon = AppIcons.gymnastics;
        color = theme.colorScheme.tertiary;
        break;
      case 'arms':
        icon = AppIcons.sportsMartialArts;
        color = Colors.orange;
        break;
      case 'legs':
        icon = AppIcons.cardio;
        color = Colors.green;
        break;
      case 'core':
        icon = AppIcons.flexibility;
        color = Colors.purple;
        break;
      case 'cardio':
        icon = AppIcons.favorite;
        color = Colors.red;
        break;
      default:
        icon = AppIcons.workout;
        color = theme.colorScheme.primary;
    }
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
  
  Widget _buildTypeBadge(ThemeData theme) {
    String badgeText;
    Color badgeColor;
    
    switch (exercise.type.name.toLowerCase()) {
      case 'single':
        badgeText = 'S';
        badgeColor = theme.colorScheme.primary;
        break;
      case 'superset':
        badgeText = 'SS';
        badgeColor = Colors.orange;
        break;
      case 'dropset':
        badgeText = 'DS';
        badgeColor = Colors.red;
        break;
      case 'restpause':
        badgeText = 'RS';
        badgeColor = Colors.purple;
        break;
      default:
        badgeText = 'S';
        badgeColor = theme.colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
  // TUT functionality will be added in the future when the model supports it
}
