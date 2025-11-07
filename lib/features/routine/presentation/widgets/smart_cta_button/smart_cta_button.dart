/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/smart_cta_button
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// SMART CTA BUTTON - Context-aware call-to-action button
///
/// Features:
/// - Auto-detects user state (completed today, rest day, scheduled, etc.)
/// - Adapts UI and action based on state
/// - GDPR-compliant (uses only workout metadata, no health data)
/// - Real-time state updates via Riverpod providers
///
/// Usage:
/// ```dart
/// SmartCTAButton()  // No parameters needed - auto-detects state
/// ```
///
/// States:
/// - activeWorkout: Primary button → "Inizia [Workout Name]"
/// - completedToday: Success button → "Visualizza Recap"
/// - restDay: Secondary container → "Riposa. Prossimo: [date]"
/// - noScheduled: Tertiary button → "Esplora Workout"
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Smart CTA Button - Context-aware workout action button
///
/// This widget automatically adapts its appearance and action based on the user's
/// current training context by watching the active routine and completed workouts.
///
/// The button state is determined by:
/// 1. Whether user completed a workout today
/// 2. Active routine's schedule for today
/// 3. Day status (scheduled, rest, skipped, etc.)
class SmartCTAButton extends ConsumerWidget {
  const SmartCTAButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('🎯 [SmartCTAButton] BUILD START');
    }

    final today = DateTime.now();

    // Watch active routine (real-time updates)
    final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);

    if (kDebugMode) {
      debugPrint('🎯 [SmartCTAButton] activeRoutineAsync state: ${activeRoutineAsync.runtimeType}');
    }

    // Watch completed workouts today (real-time updates)
    final completedTodayAsync = ref.watch(
      completedWorkoutsByDateProvider(today),
    );

    if (kDebugMode) {
      debugPrint('🎯 [SmartCTAButton] completedTodayAsync state: ${completedTodayAsync.runtimeType}');
    }

    return activeRoutineAsync.when(
      data: (routine) {
        if (routine == null) {
          return _buildNoRoutineState(context);
        }

        return completedTodayAsync.when(
          data: (completedWorkouts) {
            final state = _determineState(
              routine: routine,
              today: today,
              hasCompletedToday: completedWorkouts.isNotEmpty,
            );
            return _buildButton(context, state, routine, today);
          },
          loading: () => const LoadingIndicator(),
          error: (_, __) => _buildErrorState(context),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (_, __) => _buildErrorState(context),
    );
  }

  /// Determine button state based on user's current status
  ///
  /// Priority order:
  /// 1. Completed today → completedToday (highest priority)
  /// 2. Rest day → restDay
  /// 3. Scheduled workout → activeWorkout
  /// 4. No schedule → noScheduled (fallback)
  SmartButtonState _determineState({
    required FlexibleRoutine routine,
    required DateTime today,
    required bool hasCompletedToday,
  }) {
    // Priority 1: If workout completed today → show recap
    if (hasCompletedToday) {
      return SmartButtonState.completedToday;
    }

    final dayInfo = routine.getDayInfo(today);

    // Priority 2: No day info → no workout scheduled
    if (dayInfo == null) {
      return SmartButtonState.noScheduled;
    }

    // Priority 3: Rest day scheduled
    if (dayInfo.status == DayStatus.rest) {
      return SmartButtonState.restDay;
    }

    // Priority 4: Workout scheduled but not completed
    if (dayInfo.status == DayStatus.scheduled) {
      return SmartButtonState.activeWorkout;
    }

    // Default fallback: no scheduled
    return SmartButtonState.noScheduled;
  }

  /// Build button based on state
  Widget _buildButton(
    BuildContext context,
    SmartButtonState state,
    FlexibleRoutine routine,
    DateTime today,
  ) {
    switch (state) {
      case SmartButtonState.activeWorkout:
        final dayInfo = routine.getDayInfo(today)!;
        return _buildActiveWorkoutButton(context, dayInfo);

      case SmartButtonState.completedToday:
        return _buildCompletedButton(context);

      case SmartButtonState.restDay:
        final nextWorkoutDate = _findNextWorkoutDate(routine, today);
        return _buildRestButton(context, nextWorkoutDate);

      case SmartButtonState.noScheduled:
        return _buildExploreButton(context);
    }
  }

  /// Build active workout button (primary CTA)
  ///
  /// Appearance: Primary elevated button with workout icon
  /// Label: "Inizia [Workout Name]"
  /// Action: Start workout session with scheduled template
  Widget _buildActiveWorkoutButton(
    BuildContext context,
    ScheduledDay dayInfo,
  ) {
    final workoutName = dayInfo.templateId ?? 'Workout';

    return ElevatedButton.icon(
      onPressed: () => _startWorkout(context, dayInfo),
      icon: const Icon(AppIcons.workout, size: AppIconSize.medium),
      label: Text(
        context.l10n.smartButtonStartWorkout(workoutName),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Build completed workout button (view recap)
  ///
  /// Appearance: Success-colored outlined button with checkmark icon
  /// Label: "Visualizza Recap"
  /// Action: Navigate to today's workout summary
  Widget _buildCompletedButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _viewWorkoutSummary(context),
      icon: const Icon(AppIcons.complete, size: AppIconSize.medium),
      label: Text(
        context.l10n.smartButtonViewRecap,
        style: context.textTheme.titleMedium,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.success,
        side: BorderSide(color: context.colors.success, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Build rest day button (with recovery tips)
  ///
  /// Appearance: Secondary-colored container with bedtime icon
  /// Label: "Riposa. Prossimo: [date]"
  /// Action: Show recovery tips modal
  Widget _buildRestButton(BuildContext context, DateTime? nextDate) {
    final nextDateStr = nextDate != null
        ? _formatDate(context, nextDate)
        : context.l10n.tomorrow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.secondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.bedtime,
            size: AppIconSize.xlarge,
            color: context.colors.secondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.smartButtonRestDay(nextDateStr),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _showRecoveryTips(context),
                  child: Text(context.l10n.smartButtonRecoveryTips),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build explore workouts button (fallback)
  ///
  /// Appearance: Tertiary text button with search icon
  /// Label: "Esplora Workout"
  /// Action: Navigate to workout library
  Widget _buildExploreButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _exploreWorkouts(context),
      icon: const Icon(AppIcons.search, size: AppIconSize.medium),
      label: Text(context.l10n.smartButtonExploreWorkouts),
      style: TextButton.styleFrom(
        foregroundColor: context.colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  /// Build no routine state (create routine CTA)
  ///
  /// Fallback state when user has no active routine
  Widget _buildNoRoutineState(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO: Navigate to routine creation screen
        // Navigator.pushNamed(context, '/routine/create');
        debugPrint('📝 Navigating to routine creation');
      },
      child: Text(
        'Create Routine', // TODO: Add localization key
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }

  /// Build error state
  ///
  /// Shown when providers fail to load data
  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        context.l10n.errorLoadingData,
        style: TextStyle(color: context.colors.error),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Find next scheduled workout date
  ///
  /// Searches up to 7 days ahead to find the next scheduled workout.
  /// Returns null if no workout found in the next week.
  DateTime? _findNextWorkoutDate(FlexibleRoutine routine, DateTime today) {
    for (int i = 1; i <= 7; i++) {
      final nextDate = today.add(Duration(days: i));
      final dayInfo = routine.getDayInfo(nextDate);
      if (dayInfo?.status == DayStatus.scheduled) {
        return nextDate;
      }
    }
    return null;
  }

  /// Format date for display (today/tomorrow/date)
  ///
  /// Returns:
  /// - "Today" if date is today
  /// - "Tomorrow" if date is tomorrow
  /// - Formatted date (e.g., "Ven 8 Nov") otherwise
  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return context.l10n.today;
    if (diff == 1) return context.l10n.tomorrow;

    // Format with locale-aware date format
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('E d MMM', locale);
    return dateFormat.format(date);
  }

  // ============================================================================
  // ACTION HANDLERS (TODO: Implement navigation in Phase 2)
  // ============================================================================

  /// Start workout action handler
  ///
  /// TODO: Navigate to workout session screen with scheduled template
  /// For MVP: Debug print only
  void _startWorkout(BuildContext context, ScheduledDay dayInfo) {
    // TODO: Navigate to workout screen
    // Navigator.pushNamed(context, '/workout/start',
    //     arguments: {'templateId': dayInfo.templateId});
    debugPrint('🏋️ Starting workout: ${dayInfo.templateId}');
  }

  /// View workout summary action handler
  ///
  /// TODO: Navigate to today's workout history/summary
  /// For MVP: Debug print only
  void _viewWorkoutSummary(BuildContext context) {
    // TODO: Navigate to today's workout summary
    // Navigator.pushNamed(context, '/workout/history/today');
    debugPrint('📊 Viewing workout summary');
  }

  /// Show recovery tips action handler
  ///
  /// TODO: Show recovery tips modal with stretching/nutrition advice
  /// For MVP: Debug print only
  void _showRecoveryTips(BuildContext context) {
    // TODO: Show recovery tips modal
    // ModalService.showModal(context: context, child: RecoveryTipsModal());
    debugPrint('💡 Showing recovery tips');
  }

  /// Explore workouts action handler
  ///
  /// TODO: Navigate to workout library/exploration screen
  /// For MVP: Debug print only
  void _exploreWorkouts(BuildContext context) {
    // TODO: Navigate to workout library
    // Navigator.pushNamed(context, '/workout/library');
    debugPrint('🔍 Exploring workouts');
  }
}
