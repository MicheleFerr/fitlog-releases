/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE CARD WIDGET - v2.0 Compatible
///
/// Features:
/// - Display routine name
/// - Show preset type (displayName)
/// - Show training days count
/// - Active/inactive status indicator
/// - Tap handler for navigation
/// - Visual distinction for active routines
/// - Material 3 design system compliance
///
/// NOTE: Rewritten for v2.0 FlexibleRoutine entity (simplified 12-field schema)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Routine Card - Display routine with key details (v2.0)
class RoutineCard extends StatelessWidget {
  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
  });

  /// Routine to display (v2.0 FlexibleRoutine)
  final FlexibleRoutine routine;

  /// Callback when card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: routine.isActive ? 4 : 1,
      color: routine.isActive
          ? context.colors.primaryContainer
          : context.colors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Name + Active badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      routine.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: routine.isActive
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (routine.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.active,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Details row: Preset + Days
              Row(
                children: [
                  // Preset type
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: routine.isActive
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    routine.presetType.displayName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: routine.isActive
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Training days count
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: routine.isActive
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${routine.trainingDays.length} ${context.l10n.daysPerWeek}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: routine.isActive
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
