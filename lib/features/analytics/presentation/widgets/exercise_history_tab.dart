/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// ExerciseHistoryTab - Workout session history for Exercise Detail Screen
///
/// **Purpose**: Display chronological list of workout sessions for a specific exercise
///
/// **Features**:
/// - Session cards showing date, sets, volume, max weight
/// - Chronological order (newest first)
/// - Scrollable list
/// - Empty state handling
/// - Theme-aware design
/// - Localized labels
///
/// **Session Card Layout**:
/// ```
/// ┌─────────────────────────────────────┐
/// │  📅 Nov 18, 2024          🏆 NEW PR│
/// │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
/// │  5 sets  •  750 kg  •  Max: 100kg │
/// └─────────────────────────────────────┘
/// ```
///
/// **Usage**:
/// ```dart
/// ExerciseHistoryTab(history: exerciseHistory)
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Exercise History Tab Widget
///
/// **Displays**: Scrollable list of workout session cards
class ExerciseHistoryTab extends StatelessWidget {
  const ExerciseHistoryTab({
    required this.history,
    super.key,
  });

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context) {
    final sessions = history.sessionsSortedByDate;

    // Handle empty state
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: 'No workout history', // TODO(Phase 4.1): Replace with context.l10n.noWorkoutHistory
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history yet', // TODO(Phase 4.1): Replace with context.l10n.noWorkoutHistoryYet
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a workout to see history', // TODO(Phase 4.1): Replace with context.l10n.completeWorkoutToSeeHistory
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Find personal record (highest 1RM) session for badge
    final prSession = sessions.reduce(
      (current, next) => next.highestEstimated1RM > current.highestEstimated1RM
          ? next
          : current,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isNewPR = session.date == prSession.date;

        return _SessionCard(
          session: session,
          isNewPR: isNewPR,
        );
      },
    );
  }
}

/// Individual workout session card
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.isNewPR,
  });

  final dynamic session; // ExerciseSession
  final bool isNewPR;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(session.date);
    final setsCount = session.sets.length;
    final volume = session.totalVolume;
    final maxWeight = session.maxWeight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date + PR Badge
            Row(
              children: [
                // Calendar icon
                SemanticIcon(
                  icon: AppIcons.calendar,
                  semanticLabel: formattedDate,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),

                // Date
                Expanded(
                  child: Text(
                    formattedDate,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // PR Badge (if this session is the PR)
                if (isNewPR)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SemanticIcon(
                          icon: AppIcons.achievement,
                          semanticLabel: 'Personal Record', // TODO(Phase 4.1): Replace with context.l10n.personalRecord
                          size: AppIconSize.tiny,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PR', // TODO(Phase 4.1): Replace with context.l10n.pr
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(
              color: context.colors.outlineVariant,
              height: 1,
            ),
            const SizedBox(height: 12),

            // Stats row: Sets • Volume • Max Weight
            Row(
              children: [
                // Sets
                _StatItem(
                  icon: AppIcons.list,
                  label: '$setsCount ${setsCount == 1 ? "set" : "sets"}', // TODO(Phase 4.1): Localize
                  color: context.colors.onSurfaceVariant,
                ),

                // Separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),

                // Volume
                _StatItem(
                  icon: AppIcons.trendUp,
                  label: '${volume.toStringAsFixed(0)} kg',
                  color: context.colors.onSurfaceVariant,
                ),

                // Separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),

                // Max Weight
                _StatItem(
                  icon: AppIcons.workout,
                  label: 'Max: ${maxWeight.toStringAsFixed(1)} kg',
                  color: context.colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual stat item (icon + label)
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.tiny,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
