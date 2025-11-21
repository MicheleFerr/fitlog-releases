/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_weekly
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// WEEKLY MODAL - Weekly workout tracking with calendar view
///
/// This modal provides:
/// - Current week workout count (vs goal of 5)
/// - Weekly calendar visualization (7 days with workout indicators)
/// - Workout frequency stats
/// - Consistency tips and motivation
/// - Rest day indicators
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => WeeklyModal(
///     exerciseHistories: histories,
///     weeklyWorkouts: 4,
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

/// Modal for displaying weekly workout details with calendar and goal setter
class WeeklyModal extends StatefulWidget {
  const WeeklyModal({
    required this.exerciseHistories,
    required this.weeklyWorkouts,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final int weeklyWorkouts;

  @override
  State<WeeklyModal> createState() => _WeeklyModalState();
}

class _WeeklyModalState extends State<WeeklyModal> {
  // Weekly goal (default: 5 workouts/week)
  double _weeklyGoal = 5.0;

  /// Get workout dates for this week (last 7 days)
  List<DateTime?> _getThisWeekWorkouts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    final workoutDates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (dateOnly.isAfter(weekAgo.subtract(const Duration(days: 1))) &&
            !dateOnly.isAfter(today)) {
          workoutDates.add(dateOnly);
        }
      }
    }

    // Map to last 7 days (null = rest day)
    final weekDays = <DateTime?>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      weekDays.add(workoutDates.contains(day) ? day : null);
    }

    return weekDays;
  }

  /// Get consistency percentage (workouts / goal * 100)
  double _getConsistencyPercentage() {
    return (widget.weeklyWorkouts / _weeklyGoal * 100).clamp(0, 100);
  }

  /// Get motivational message
  String _getMotivationalMessage() {
    if (widget.weeklyWorkouts >= _weeklyGoal) return 'Excellent consistency! You hit your weekly goal! 🎯';
    if (widget.weeklyWorkouts >= _weeklyGoal - 1) return 'Almost there! One more workout to hit your goal! 💪';
    if (widget.weeklyWorkouts >= _weeklyGoal - 2) return 'Good progress! Keep the momentum going! 📈';
    if (widget.weeklyWorkouts >= 2) return 'You\'re on track! Don\'t stop now! 🔥';
    return 'Every journey starts with a single step! Let\'s go! 🚀';
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getThisWeekWorkouts();
    final consistencyPercent = _getConsistencyPercentage();
    final motivationalMessage = _getMotivationalMessage();

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

              // Weekly workout card
              _buildWeeklyCard(context),
              const SizedBox(height: 24),

              // Calendar view (7 days)
              _buildWeeklyCalendar(context, weekDays),
              const SizedBox(height: 24),

              // Consistency progress
              _buildConsistencyProgress(context, consistencyPercent),
              const SizedBox(height: 24),

              // Motivational message
              _buildMotivationalBanner(context, motivationalMessage),
              const SizedBox(height: 24),

              // Tips section
              _buildTipsSection(context),
              const SizedBox(height: 24),

              // Weekly goal setter
              _buildWeeklyGoalSetter(context),
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
            '📅 Weekly Details',
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

  /// Weekly workout card
  Widget _buildWeeklyCard(BuildContext context) {
    final goal = _weeklyGoal.round();
    final isGoalMet = widget.weeklyWorkouts >= goal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoalMet
              ? [
                  context.colors.successContainer,
                  context.colors.primaryContainer,
                ]
              : [
                  context.colors.primaryContainer,
                  context.colors.secondaryContainer,
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
          // Calendar icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGoalMet
                  ? context.colors.success.withValues(alpha: 0.2)
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: 'Weekly Workouts',
              size: AppIconSize.large,
              color: isGoalMet ? context.colors.success : context.colors.primary,
            ),
          ),
          const SizedBox(width: 16),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.weeklyWorkouts} / $goal workouts',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Goal badge
          if (isGoalMet)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.achievement,
                    size: 16,
                    color: context.colors.onSuccess,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Goal!',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Weekly calendar (7 days with workout indicators)
  Widget _buildWeeklyCalendar(BuildContext context, List<DateTime?> weekDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 Days',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Calendar grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final dayDate = today.subtract(Duration(days: 6 - index));
            final hasWorkout = weekDays[index] != null;
            final isToday = dayDate.isAtSameMomentAs(today);

            return Column(
              children: [
                // Day name
                Text(
                  weekDayNames[index],
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),

                // Day indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasWorkout
                        ? context.colors.success.withValues(alpha: 0.8)
                        : context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(
                            color: context.colors.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: hasWorkout
                      ? Icon(
                          AppIcons.checkCircle,
                          size: 20,
                          color: context.colors.onSuccess,
                        )
                      : null,
                ),

                const SizedBox(height: 4),

                // Day number
                Text(
                  '${dayDate.day}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  /// Consistency progress bar
  Widget _buildConsistencyProgress(BuildContext context, double percent) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percent.round()}%',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: context.colors.surfaceContainer,
            color: percent >= 100
                ? context.colors.success
                : context.colors.primary,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
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

  /// Tips section
  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.lightbulb,
                semanticLabel: 'Tips',
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Consistency Tips',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTipItem(context, 'Schedule workouts like appointments'),
          const SizedBox(height: 8),
          _buildTipItem(context, 'Start small: consistency > intensity'),
          const SizedBox(height: 8),
          _buildTipItem(context, 'Rest days are part of progress!'),
        ],
      ),
    );
  }

  /// Individual tip item
  Widget _buildTipItem(BuildContext context, String tip) {
    return Row(
      children: [
        Icon(
          AppIcons.checkCircle,
          size: 16,
          color: context.colors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tip,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Weekly goal setter (slider 1-7)
  Widget _buildWeeklyGoalSetter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.flag,
                semanticLabel: 'Weekly Goal',
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Goal',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Goal display
          Center(
            child: Column(
              children: [
                Text(
                  '${_weeklyGoal.round()}',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'workouts per week',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.colors.primary,
              inactiveTrackColor: context.colors.surfaceContainerHighest,
              thumbColor: context.colors.primary,
              overlayColor: context.colors.primary.withValues(alpha: 0.2),
              valueIndicatorColor: context.colors.primary,
              valueIndicatorTextStyle: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
            child: Slider(
              value: _weeklyGoal,
              min: 1,
              max: 7,
              divisions: 6,
              label: '${_weeklyGoal.round()} workouts',
              onChanged: (value) {
                setState(() => _weeklyGoal = value);
                HapticFeedback.selectionClick();
              },
            ),
          ),

          // Progress indicator
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.weeklyWorkouts / _weeklyGoal,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  color: widget.weeklyWorkouts >= _weeklyGoal
                      ? context.colors.success
                      : context.colors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.weeklyWorkouts} / ${_weeklyGoal.round()}',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.weeklyWorkouts >= _weeklyGoal
                      ? context.colors.success
                      : context.colors.primary,
                ),
              ),
            ],
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
