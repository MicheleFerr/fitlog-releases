// lib/features/routine/presentation/widgets/workout_selector_card.dart

// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
//
// 📁 Layer: features/routine/presentation/widgets
// 🎯 Feature: routine_center
// 🔧 Type: widget
// 🌍 Localization: YES
// 🎨 Theme: YES
// 📱 Platform: Universal
//
// WORKOUT SELECTOR CARD - Display individual workout for selection
//
// Visual Design:
// ┌─────────────────────────────────────────┐
// │ 🏋️ Giorno A              [✅ Match]     │
// │ Today 14:30 • 45min • 8 exercises       │
// └─────────────────────────────────────────┘
//
// Features:
// - Template match badge (green)
// - Already linked warning (orange)
// - Haptic feedback on tap
// - Highlight styling for matches

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class WorkoutSelectorCard extends StatelessWidget {
  const WorkoutSelectorCard({
    super.key,
    required this.workout,
    required this.isTemplateMatch,
    required this.isAlreadyLinked,
    this.linkedDate,
    required this.onTap,
  });

  final Workout workout;
  final bool isTemplateMatch;
  final bool isAlreadyLinked;
  final DateTime? linkedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isTemplateMatch
              ? context.colors.primaryContainer
              : context.colors.surfaceContainerHighest,
          border: isTemplateMatch
              ? Border.all(color: context.colors.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading: Workout icon
            Icon(
              AppIcons.workout,
              size: AppIconSize.large,
              color: context.colors.primary,
            ),
            SizedBox(width: 16),

            // Content: Name + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _buildMetadataText(context),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: Badge (match or linked warning)
            if (isTemplateMatch) _buildMatchBadge(context),
            if (isAlreadyLinked) _buildLinkedBadge(context),
          ],
        ),
      ),
    );
  }

  String _buildMetadataText(BuildContext context) {
    final parts = <String>[];

    // Date/time
    if (workout.startTime != null) {
      final now = DateTime.now();
      final workoutDate = workout.startTime!;
      final difference = now.difference(workoutDate).inDays;

      final locale = Localizations.localeOf(context).toString();
      if (difference == 0) {
        parts.add('${context.l10n.today} ${DateFormat.Hm(locale).format(workoutDate)}');
      } else if (difference == 1) {
        parts.add('${context.l10n.yesterday} ${DateFormat.Hm(locale).format(workoutDate)}');
      } else {
        parts.add('$difference ${context.l10n.daysAgo}');
      }
    }

    // Duration
    if (workout.duration != null) {
      parts.add('${workout.duration!.inMinutes}min');
    }

    // Exercise count
    final exerciseCount = workout.exercises.length;
    parts.add('$exerciseCount ${exerciseCount == 1 ? context.l10n.exercise : context.l10n.exercises}');

    return parts.join(' • ');
  }

  Widget _buildMatchBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.successContainer,
        border: Border.all(color: context.colors.success),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.checkCircle,
            size: AppIconSize.small,
            color: context.colors.success,
          ),
          SizedBox(width: 4),
          Text(
            context.l10n.match,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.warningContainer,
        border: Border.all(color: context.colors.warning),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.warning,
            size: AppIconSize.small,
            color: context.colors.warning,
          ),
          SizedBox(width: 4),
          Text(
            '${context.l10n.linkedTo} ${linkedDate != null ? DateFormat.MMMd(Localizations.localeOf(context).toString()).format(linkedDate!) : ''}',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
