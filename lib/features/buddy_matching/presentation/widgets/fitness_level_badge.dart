/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
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
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class FitnessLevelBadge extends StatelessWidget {

  const FitnessLevelBadge({
    super.key,
    required this.level,
    this.compact = false,
    this.showIcon = true,
  });
  final FitnessLevel level;
  final bool compact;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getLevelColor(level, theme.colorScheme);
    final icon = _getLevelIcon(level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            level.displayName,
            style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(FitnessLevel level, ColorScheme colorScheme) {
    switch (level) {
      case FitnessLevel.beginner:
        return colorScheme.success;
      case FitnessLevel.intermediate:
        return colorScheme.secondary;
      case FitnessLevel.advanced:
        return colorScheme.error;
      case FitnessLevel.expert:
        return colorScheme.tertiary;
    }
  }

  IconData _getLevelIcon(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return Icons.fitness_center;
      case FitnessLevel.intermediate:
        return Icons.trending_up;
      case FitnessLevel.advanced:
        return Icons.local_fire_department;
      case FitnessLevel.expert:
        return Icons.emoji_events;
    }
  }
}