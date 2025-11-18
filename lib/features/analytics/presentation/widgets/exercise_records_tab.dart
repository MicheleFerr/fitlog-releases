/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// ExerciseRecordsTab - Personal records breakdown for Exercise Detail Screen
///
/// **Purpose**: Display comprehensive personal records and statistics
///
/// **Features**:
/// - Personal records cards (Max Weight, 1RM, Volume, Sets)
/// - Time-based statistics (First/Last workout, Weekly frequency)
/// - Progress indicators
/// - Empty state handling
/// - Theme-aware design
/// - Localized labels
///
/// **Records Display**:
/// - Max Weight Record (🏆 trophy icon)
/// - Estimated 1RM (💪 workout icon)
/// - Total Volume Record (📊 trend icon)
/// - Total Sets Record (📋 list icon)
/// - Days since last workout
/// - Weekly frequency (last 4 weeks)
/// - Total workouts
///
/// **Usage**:
/// ```dart
/// ExerciseRecordsTab(records: exerciseRecords)
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Exercise Records Tab Widget
///
/// **Displays**: Personal records breakdown with statistics
class ExerciseRecordsTab extends StatelessWidget {
  const ExerciseRecordsTab({
    required this.records,
    super.key,
  });

  final ExerciseRecords records;

  @override
  Widget build(BuildContext context) {
    // Handle empty/zero state
    if (records.totalWorkouts == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.achievement,
              semanticLabel: context.l10n.noRecordsYet,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noRecordsYet,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.completeWorkoutsToTrackRecords,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Personal Records
          Text(
            context.l10n.personalRecords,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Max Weight Record
          _RecordCard(
            icon: AppIcons.achievement,
            iconColor: context.colors.primary,
            title: context.l10n.maxWeight,
            value: '${records.maxWeightRecord.toStringAsFixed(1)} kg',
            subtitle: context.l10n.heaviestSingleSet,
          ),
          const SizedBox(height: 12),

          // Estimated 1RM
          _RecordCard(
            icon: AppIcons.workout,
            iconColor: context.colors.secondary,
            title: context.l10n.estimated1RM,
            value: '${records.estimated1RM.toStringAsFixed(1)} kg',
            subtitle: context.l10n.calculatedMaxStrength,
          ),
          const SizedBox(height: 12),

          // Total Volume Record
          _RecordCard(
            icon: AppIcons.trendUp,
            iconColor: context.colors.tertiary,
            title: context.l10n.volumeRecord,
            value: '${records.totalVolumeRecord.toStringAsFixed(0)} kg',
            subtitle: context.l10n.highestSingleWorkout,
          ),
          const SizedBox(height: 12),

          // Total Sets Record
          _RecordCard(
            icon: AppIcons.list,
            iconColor: context.colors.primary,
            title: context.l10n.setsRecord,
            value: '${records.totalSetsRecord} sets',
            subtitle: context.l10n.mostSetsInOneWorkout,
          ),

          const SizedBox(height: 32),

          // Section: Activity Statistics
          Text(
            context.l10n.activityStatistics,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Last Workout
          _StatCard(
            icon: AppIcons.calendar,
            iconColor: context.colors.onSurfaceVariant,
            label: context.l10n.lastWorkout,
            value: _formatLastWorkout(context, records.daysSinceLastWorkout),
            subtitle: DateFormat('MMM d, yyyy').format(records.lastWorkoutDate),
          ),
          const SizedBox(height: 12),

          // Weekly Frequency
          _StatCard(
            icon: AppIcons.barChart,
            iconColor: context.colors.onSurfaceVariant,
            label: context.l10n.weeklyFrequency,
            value: '${records.weeklyFrequency.toStringAsFixed(1)}x/week',
            subtitle: context.l10n.averageLast4Weeks,
          ),
          const SizedBox(height: 12),

          // Total Workouts
          _StatCard(
            icon: AppIcons.workout,
            iconColor: context.colors.onSurfaceVariant,
            label: context.l10n.totalWorkouts,
            value: '${records.totalWorkouts}',
            subtitle: _formatDateRange(records.firstWorkoutDate, records.lastWorkoutDate),
          ),
        ],
      ),
    );
  }

  /// Format days since last workout as human-readable string
  String _formatLastWorkout(BuildContext context, int days) {
    if (days == 0) {
      return context.l10n.today;
    } else if (days == 1) {
      return context.l10n.yesterday;
    } else if (days < 7) {
      return '$days days ago';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (days / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }

  /// Format date range (first to last workout)
  String _formatDateRange(DateTime first, DateTime last) {
    final duration = last.difference(first);
    final days = duration.inDays;

    if (days < 7) {
      return '$days ${days == 1 ? "day" : "days"}';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"}';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? "month" : "months"}';
    } else {
      final years = (days / 365).floor();
      return '$years ${years == 1 ? "year" : "years"}';
    }
  }
}

/// Personal record card (large, emphasized)
class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SemanticIcon(
                icon: icon,
                semanticLabel: title,
                size: AppIconSize.large,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity statistic card (smaller, informative)
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.medium,
              color: iconColor,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
