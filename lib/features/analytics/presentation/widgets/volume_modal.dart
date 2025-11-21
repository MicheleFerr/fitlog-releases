/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_volume
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// VOLUME MODAL - Volume progression tracking and visualization
///
/// This modal provides:
/// - Volume progression explanation (+/- % from last week)
/// - Weekly comparison chart (last 4 weeks)
/// - Volume trend visualization
/// - Motivational insights based on progression
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => VolumeModal(
///     exerciseHistories: histories,
///     volumeProgression: 12.5,
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal for displaying volume progression details and trends
class VolumeModal extends StatefulWidget {
  const VolumeModal({
    required this.exerciseHistories,
    required this.volumeProgression,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final double volumeProgression;

  @override
  State<VolumeModal> createState() => _VolumeModalState();
}

class _VolumeModalState extends State<VolumeModal> {
  /// Calculate workouts and volume for last N weeks
  List<({int workouts, double volume})> _calculateWeeklyData(int weeks) {
    final now = DateTime.now();
    final weeklyData = <({int workouts, double volume})>[];

    for (int i = 0; i < weeks; i++) {
      final weekStart = now.subtract(Duration(days: 7 * (i + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * i));

      final workoutDates = <DateTime>{};
      double totalVolume = 0.0;

      for (final history in widget.exerciseHistories) {
        for (final session in history.sessions) {
          final dateOnly = DateTime(
            session.date.year,
            session.date.month,
            session.date.day,
          );
          if (dateOnly.isAfter(weekStart) && !dateOnly.isAfter(weekEnd)) {
            workoutDates.add(dateOnly);

            // Calculate volume for this session (weight × reps × sets)
            for (final set in session.sets) {
              totalVolume += (set.weight ?? 0.0) * (set.reps ?? 0);
            }
          }
        }
      }

      weeklyData.insert(0, (workouts: workoutDates.length, volume: totalVolume));
    }

    return weeklyData;
  }

  /// Get insight message based on progression
  String _getInsightMessage(double progression) {
    if (progression > 20) return 'Exceptional growth! You\'re crushing your goals! 🚀';
    if (progression > 10) return 'Great progress! Keep up the momentum! 💪';
    if (progression > 0) return 'Steady improvement! You\'re on the right track! 📈';
    if (progression > -10) return 'Minor dip, but you\'ve got this! Stay consistent! 💫';
    return 'Time to refocus! Remember your goals! 🎯';
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyData(4);
    final insightMessage = _getInsightMessage(widget.volumeProgression);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 20),

              // Volume progression card
              _buildVolumeCard(context),
              const SizedBox(height: 24),

              // Explanation
              _buildExplanation(context),
              const SizedBox(height: 24),

              // Weekly comparison chart
              _buildWeeklyChart(context, weeklyData),
              const SizedBox(height: 24),

              // Insight message
              _buildInsightBanner(context, insightMessage),
              const SizedBox(height: 24),

              // Close button
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '📊 Volume Details',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SemanticIcon(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }

  /// Volume progression card (prominent)
  Widget _buildVolumeCard(BuildContext context) {
    final isPositive = widget.volumeProgression >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [
                  context.colors.successContainer,
                  context.colors.primaryContainer,
                ]
              : [
                  context.colors.errorContainer,
                  context.colors.surfaceContainerHighest,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trend icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositive
                  ? context.colors.success.withValues(alpha: 0.2)
                  : context.colors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SemanticIcon(
              icon: isPositive ? AppIcons.trendUp : AppIcons.trendDown,
              semanticLabel: 'Volume Trend',
              size: AppIconSize.large,
              color: isPositive ? context.colors.success : context.colors.error,
            ),
          ),
          const SizedBox(width: 16),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Volume Progression',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isPositive
                        ? context.colors.onSuccessContainer
                        : context.colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${widget.volumeProgression.toStringAsFixed(1)}%',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? context.colors.onSuccessContainer
                        : context.colors.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Explanation section
  Widget _buildExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.info,
                semanticLabel: 'Information',
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'What is Volume?',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Volume is the total amount of work you perform in your workouts. '
            'We track your weekly workout frequency to show your progression over time. '
            'Positive progression means you\'re doing more workouts than last week!',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Weekly comparison chart (last 4 weeks) with tap handlers
  Widget _buildWeeklyChart(BuildContext context, List<({int workouts, double volume})> weeklyData) {
    final maxWorkouts = weeklyData.isEmpty
        ? 7
        : weeklyData.map((d) => d.workouts).reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 4 Weeks',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Bar chart
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            if (index >= weeklyData.length) return const SizedBox.shrink();

            final data = weeklyData[index];
            final workouts = data.workouts;
            final volume = data.volume;
            final heightPercent = maxWorkouts > 0 ? workouts / maxWorkouts : 0;
            final isCurrentWeek = index == weeklyData.length - 1;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showVolumeDetails(context, index, workouts, volume, isCurrentWeek);
              },
              child: Column(
                children: [
                  // Value
                  Text(
                    '$workouts',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrentWeek
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bar
                  Container(
                    width: 60,
                    height: (120 * heightPercent).toDouble(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCurrentWeek
                            ? [
                                context.colors.primary,
                                context.colors.primaryContainer,
                              ]
                            : [
                                context.colors.surfaceContainerHighest,
                                context.colors.surfaceContainer,
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Week label
                  Text(
                    index == weeklyData.length - 1
                        ? 'This Week'
                        : 'Week ${weeklyData.length - index}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Show volume details dialog when tapping on a bar
  void _showVolumeDetails(BuildContext context, int weekIndex, int workouts, double volume, bool isCurrentWeek) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: 'Volume Details',
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCurrentWeek ? 'This Week Details' : 'Week ${4 - weekIndex} Details',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workouts count
            _buildDetailRow(
              context,
              icon: AppIcons.workout,
              label: 'Total Workouts',
              value: '$workouts',
            ),
            const SizedBox(height: 16),

            // Total volume
            _buildDetailRow(
              context,
              icon: AppIcons.trendUp,
              label: 'Total Volume',
              value: '${volume.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 16),

            // Average per workout
            if (workouts > 0)
              _buildDetailRow(
                context,
                icon: AppIcons.barChart,
                label: 'Avg per Workout',
                value: '${(volume / workouts).toStringAsFixed(1)} kg',
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  /// Helper to build detail row in dialog
  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Insight banner
  Widget _buildInsightBanner(BuildContext context, String message) {
    final isPositive = widget.volumeProgression >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? context.colors.successContainer
            : context.colors.warningContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: isPositive ? AppIcons.trendUp : AppIcons.info,
            semanticLabel: 'Insight',
            size: AppIconSize.medium,
            color: isPositive
                ? context.colors.onSuccessContainer
                : context.colors.onWarningContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isPositive
                    ? context.colors.onSuccessContainer
                    : context.colors.onWarningContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Close button
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: SemanticIcon(
          icon: AppIcons.close,
          semanticLabel: context.l10n.close,
          size: AppIconSize.buttonPrimary,
        ),
        label: Text(context.l10n.close),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
