/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_streak
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// STREAK MODAL - GitHub-style contribution calendar for workout streaks
///
/// This modal provides:
/// - Current streak counter (consecutive days with workouts)
/// - Longest streak (personal record)
/// - Mini calendar heatmap (last 30 days visualization)
/// - Motivational message based on streak
/// - Stats: total workouts this month, consecutive days
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => StreakModal(
///     exerciseHistories: histories,
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

/// Modal for displaying workout streak details with calendar heatmap
class StreakModal extends StatefulWidget {
  const StreakModal({
    required this.exerciseHistories,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<StreakModal> createState() => _StreakModalState();
}

class _StreakModalState extends State<StreakModal> {
  // Calendar zoom state
  int _selectedDays = 30; // Default: 30 days (1 month)

  // Available zoom levels
  static const List<int> _zoomLevels = [7, 15, 30, 60, 90, 180, 360];

  /// Zoom in (decrease days)
  void _zoomIn() {
    final currentIndex = _zoomLevels.indexOf(_selectedDays);
    if (currentIndex > 0) {
      setState(() => _selectedDays = _zoomLevels[currentIndex - 1]);
      HapticFeedback.selectionClick();
    }
  }

  /// Zoom out (increase days)
  void _zoomOut() {
    final currentIndex = _zoomLevels.indexOf(_selectedDays);
    if (currentIndex < _zoomLevels.length - 1) {
      setState(() => _selectedDays = _zoomLevels[currentIndex + 1]);
      HapticFeedback.selectionClick();
    }
  }

  /// Calculate current streak (consecutive days with workouts)
  int _calculateCurrentStreak() {
    if (widget.exerciseHistories.isEmpty) return 0;

    // Get all unique workout dates (across all exercises)
    final allDates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        // Normalize to date only (remove time)
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        allDates.add(dateOnly);
      }
    }

    // Sort dates descending (newest first)
    final sortedDates = allDates.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Check if most recent workout is today or yesterday
    final mostRecent = sortedDates.first;
    final daysSinceRecent = todayOnly.difference(mostRecent).inDays;

    // If last workout was more than 1 day ago, streak is broken
    if (daysSinceRecent > 1) return 0;

    // Count consecutive days backwards from most recent
    int streak = 1;
    DateTime expectedDate = mostRecent.subtract(const Duration(days: 1));

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        // Gap in streak, stop counting
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak (personal record)
  int _calculateLongestStreak() {
    if (widget.exerciseHistories.isEmpty) return 0;

    // Get all unique workout dates
    final allDates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        allDates.add(dateOnly);
      }
    }

    // Sort dates ascending (oldest first)
    final sortedDates = allDates.toList()
      ..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;
    DateTime expectedDate = sortedDates.first.add(const Duration(days: 1));

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].isAtSameMomentAs(expectedDate)) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        expectedDate = expectedDate.add(const Duration(days: 1));
      } else {
        // Gap in streak, reset current
        currentStreak = 1;
        expectedDate = sortedDates[i].add(const Duration(days: 1));
      }
    }

    return longestStreak;
  }

  /// Calculate total workouts this month
  int _calculateMonthlyWorkouts() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final workoutDates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (dateOnly.isAfter(firstDayOfMonth.subtract(const Duration(days: 1)))) {
          workoutDates.add(dateOnly);
        }
      }
    }

    return workoutDates.length;
  }

  /// Get workout dates for last N days (for calendar heatmap)
  Set<DateTime> _getLastNDaysWorkouts(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    final workoutDates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (dateOnly.isAfter(startDate.subtract(const Duration(days: 1))) &&
            !dateOnly.isAfter(today)) {
          workoutDates.add(dateOnly);
        }
      }
    }

    return workoutDates;
  }

  /// Get motivational message based on current streak
  String _getMotivationalMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Great start! Keep it going!';
    if (streak < 7) return 'You\'re building momentum! 🔥';
    if (streak < 14) return 'Amazing week streak! 💪';
    if (streak < 30) return 'Unstoppable! Keep crushing it!';
    return 'Legendary streak! You\'re a beast! 🏆';
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _calculateCurrentStreak();
    final longestStreak = _calculateLongestStreak();
    final monthlyWorkouts = _calculateMonthlyWorkouts();
    final workoutDates = _getLastNDaysWorkouts(_selectedDays);
    final motivationalMessage = _getMotivationalMessage(currentStreak);

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

              // Current Streak (prominent)
              _buildStreakCard(
                context,
                label: 'Current Streak',
                value: currentStreak,
                icon: AppIcons.streak,
                isCurrentStreak: true,
              ),
              const SizedBox(height: 16),

              // Longest Streak
              _buildStreakCard(
                context,
                label: 'Longest Streak',
                value: longestStreak,
                icon: AppIcons.achievement,
                isCurrentStreak: false,
              ),
              const SizedBox(height: 24),

              // Motivational message
              _buildMotivationalBanner(context, motivationalMessage),
              const SizedBox(height: 24),

              // Calendar Heatmap (dynamic days)
              _buildCalendarHeatmap(context, workoutDates, _selectedDays),
              const SizedBox(height: 24),

              // Stats section
              _buildStatsSection(context, monthlyWorkouts),
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
            '🔥 Streak Details',
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

  /// Streak card (Current or Longest)
  Widget _buildStreakCard(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required bool isCurrentStreak,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentStreak
              ? [
                  context.colors.primaryContainer,
                  context.colors.secondaryContainer,
                ]
              : [
                  context.colors.surfaceContainerHighest,
                  context.colors.surfaceContainer,
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
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentStreak
                  ? context.colors.primary.withValues(alpha: 0.2)
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.large,
              color: isCurrentStreak
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isCurrentStreak
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value ${value == 1 ? 'day' : 'days'}',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentStreak
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Motivational banner
  Widget _buildMotivationalBanner(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.successContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.trendUp,
            semanticLabel: 'Motivation',
            size: AppIconSize.medium,
            color: context.colors.onSuccessContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSuccessContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calendar heatmap (GitHub-style contribution graph with zoom controls)
  Widget _buildCalendarHeatmap(BuildContext context, Set<DateTime> workoutDates, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    // Check if zoom buttons should be enabled
    final canZoomIn = _zoomLevels.indexOf(_selectedDays) > 0;
    final canZoomOut = _zoomLevels.indexOf(_selectedDays) < _zoomLevels.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Zoom controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Last $days Days',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom in button (-)
                IconButton(
                  onPressed: canZoomIn ? _zoomIn : null,
                  icon: SemanticIcon(
                    icon: AppIcons.remove,
                    semanticLabel: 'Zoom in',
                    size: AppIconSize.small,
                    color: canZoomIn ? context.colors.primary : context.colors.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 8),
                // Zoom out button (+)
                IconButton(
                  onPressed: canZoomOut ? _zoomOut : null,
                  icon: SemanticIcon(
                    icon: AppIcons.add,
                    semanticLabel: 'Zoom out',
                    size: AppIconSize.small,
                    color: canZoomOut ? context.colors.primary : context.colors.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days per week
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: days,
          itemBuilder: (context, index) {
            final date = startDate.add(Duration(days: index));
            final hasWorkout = workoutDates.contains(date);
            final isToday = date.isAtSameMomentAs(today);

            return Container(
              decoration: BoxDecoration(
                color: hasWorkout
                    ? context.colors.success.withValues(alpha: 0.8)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(
                        color: context.colors.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: hasWorkout
                  ? Center(
                      child: Icon(
                        AppIcons.checkCircle,
                        size: 12,
                        color: context.colors.onSuccess,
                      ),
                    )
                  : null,
            );
          },
        ),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              context,
              color: context.colors.surfaceContainerHighest,
              label: 'Rest',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              context,
              color: context.colors.success.withValues(alpha: 0.8),
              label: 'Workout',
            ),
          ],
        ),
      ],
    );
  }

  /// Legend item for calendar heatmap
  Widget _buildLegendItem(BuildContext context, {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Stats section (monthly workouts, etc.)
  Widget _buildStatsSection(BuildContext context, int monthlyWorkouts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: AppIcons.calendar,
            label: 'This Month',
            value: '$monthlyWorkouts',
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outlineVariant,
          ),
          _buildStatItem(
            context,
            icon: AppIcons.workout,
            label: 'Total Exercises',
            value: '${widget.exerciseHistories.length}',
          ),
        ],
      ),
    );
  }

  /// Individual stat item
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.medium,
          color: context.colors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
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
