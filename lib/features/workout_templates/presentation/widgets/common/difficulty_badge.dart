/// Small difficulty badge for compact cards
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.color,
  });

  final String difficulty;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getDifficultyColor(context, difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty,
        style: context.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    final lowerDifficulty = difficulty.toLowerCase();
    if (lowerDifficulty.contains('easy') ||
        lowerDifficulty.contains('facile')) {
      return context.colors.success;
    } else if (lowerDifficulty.contains('medium') ||
        lowerDifficulty.contains('medio')) {
      return context.colors.warning;
    } else if (lowerDifficulty.contains('hard') ||
        lowerDifficulty.contains('difficile')) {
      return context.colors.error;
    }
    return context.colors.primary;
  }
}
