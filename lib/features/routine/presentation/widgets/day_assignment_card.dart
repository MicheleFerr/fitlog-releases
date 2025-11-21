/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// DAY ASSIGNMENT CARD WIDGET - Card for Assigning Templates to Days
///
/// Features:
/// - Display day name (localized)
/// - Show assigned template name (or placeholder if none)
/// - Visual indicator (checkmark if assigned, circle if not)
/// - Tap handler to open template picker
/// - Material 3 design system compliance
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Day Assignment Card - Display day with template assignment status
class DayAssignmentCard extends StatelessWidget {
  const DayAssignmentCard({
    super.key,
    required this.dayNumber,
    required this.dayName,
    this.assignedTemplate,
    required this.onTap,
  });

  /// Day number (1=Monday, 7=Sunday)
  final int dayNumber;

  /// Localized day name (e.g., "Monday", "Lunedì")
  final String dayName;

  /// Assigned workout template (null if not assigned yet)
  final WorkoutTemplate? assignedTemplate;

  /// Callback when card is tapped (to open template picker)
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTemplate = assignedTemplate != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasTemplate ? 2 : 1,
      child: ListTile(
        leading: Icon(
          hasTemplate ? Icons.check_circle : Icons.circle_outlined,
          color: hasTemplate
              ? context.colors.primary
              : context.colors.outline,
        ),
        title: Text(
          dayName,
          style: context.textTheme.titleMedium,
        ),
        subtitle: Text(
          assignedTemplate?.name ?? context.l10n.tapToAssignTemplate,
          style: context.textTheme.bodyMedium?.copyWith(
            fontStyle: hasTemplate ? null : FontStyle.italic,
            color: hasTemplate
                ? context.colors.onSurface
                : context.colors.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
