/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// PATTERN SELECTION STEP - Step 2 of routine creation wizard
///
/// Allows selection of:
/// - Preset patterns (PPL, Upper/Lower, Full Body, etc.)
/// - Custom pattern creation (future)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/custom_pattern_builder.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 2: Pattern selection
class PatternSelectionStep extends ConsumerWidget {
  const PatternSelectionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineEditorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.l10n.routinePatternChooseTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.routinePatternChooseDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Toggle between preset and custom
          _buildPatternModeToggle(context, ref, state),

          const SizedBox(height: 24),

          // Show preset patterns or custom builder
          if (state.usePresetPattern) ...[
            Text(
              context.l10n.routinePatternPopular,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildPresetPatterns(context, ref, state),
          ] else ...[
            const CustomPatternBuilder(),
          ],

          // Calendar Preview (if pattern selected)
          if (state.finalPattern != null) ...[
            const SizedBox(height: 32),
            _buildCalendarPreview(context, state),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternModeToggle(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                ref.read(routineEditorProvider.notifier).clearCustomPattern();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: state.usePresetPattern
                      ? context.colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.gridView,
                      color: state.usePresetPattern
                          ? context.colors.onPrimary
                          : context.colors.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.routinePatternPreset,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: state.usePresetPattern
                            ? context.colors.onPrimary
                            : context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // Switch to custom mode
                ref.read(routineEditorProvider.notifier).setCustomSequence([]);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !state.usePresetPattern
                      ? context.colors.tertiary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.editCalendar,
                      color: !state.usePresetPattern
                          ? context.colors.onTertiary
                          : context.colors.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.routinePatternCustom,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: !state.usePresetPattern
                            ? context.colors.onTertiary
                            : context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPatterns(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
  ) {
    final presets = RoutinePatterns.allPatterns;
    final hasSelection = state.selectedPattern != null;

    return Column(
      children: presets.map((pattern) {
        final isSelected = state.selectedPattern?.name == pattern.name;
        final workoutDays = _getWorkoutDays(pattern);
        final restDays = _getRestDays(pattern);

        // Collapse other patterns when one is selected
        final shouldCollapse = hasSelection && !isSelected;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                ref.read(routineEditorProvider.notifier).selectPresetPattern(pattern);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outlineVariant.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: isSelected
                                ? context.colors.onPrimary
                                : context.colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocalizedPatternName(pattern, context),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? context.colors.primary
                                      : context.colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.l10n.routineWorkoutCount(workoutDays)}, ${context.l10n.routineRestCount(restDays)}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: context.colors.primary,
                            size: 28,
                          )
                        else if (shouldCollapse)
                          Icon(
                            Icons.chevron_right,
                            color: context.colors.onSurface.withValues(alpha: 0.4),
                            size: 24,
                          ),
                      ],
                    ),

                    // Show details only if selected or no pattern is selected
                    if (!shouldCollapse) ...[
                      const SizedBox(height: 12),
                      Text(
                        _getLocalizedPatternDescription(pattern, context),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPatternSequence(context, pattern, isSelected),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternSequence(
    BuildContext context,
    RoutinePattern pattern,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primary.withValues(alpha: 0.1)
            : context.colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: pattern.sequence.map((day) {
          final isRest = day.toLowerCase() == 'rest';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isRest
                  ? context.colors.secondary.withValues(alpha: 0.2)
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRest
                    ? context.colors.secondary.withValues(alpha: 0.3)
                    : context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRest ? Icons.bed : Icons.fitness_center,
                  size: 14,
                  color: isRest
                      ? context.colors.secondary
                      : context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDayLabel(day),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isRest
                        ? context.colors.secondary
                        : context.colors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomPatternInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.secondaryContainer.withValues(alpha: 0.3),
            context.colors.secondaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.construction,
            color: context.colors.secondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Pattern Builder',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your own custom workout sequence - Coming soon!',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getWorkoutDays(RoutinePattern pattern) {
    return pattern.sequence
        .where((day) => day.toLowerCase() != 'rest')
        .length;
  }

  int _getRestDays(RoutinePattern pattern) {
    return pattern.sequence
        .where((day) => day.toLowerCase() == 'rest')
        .length;
  }

  String _formatDayLabel(String day) {
    if (day.toLowerCase() == 'rest') return 'Rest';
    // Format "Workout 1" → "W1", "Workout 2" → "W2", etc.
    if (day.startsWith('Workout ')) {
      final number = day.replaceFirst('Workout ', '');
      return 'W$number';
    }
    return day;
  }

  /// Build live calendar preview showing first 7-10 days
  Widget _buildCalendarPreview(
    BuildContext context,
    RoutineEditorState state,
  ) {
    final pattern = state.finalPattern!;
    final startDate = state.startDate;
    final endDate = state.endDate;
    final totalDays = endDate.difference(startDate).inDays + 1;

    // Calculate preview days (max 10)
    final previewDays = totalDays > 10 ? 10 : totalDays;
    final daysToShow = <_CalendarDay>[];

    for (int i = 0; i < previewDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dayName = pattern.sequence[i % pattern.sequence.length];
      final isRest = dayName.toLowerCase() == 'rest';

      daysToShow.add(_CalendarDay(
        date: date,
        dayName: dayName,
        isRest: isRest,
        dayNumber: i + 1,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primaryContainer.withValues(alpha: 0.2),
            context.colors.secondaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppIcons.calendarViewWeek,
                  color: context.colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.routineCalendarPreview,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    Text(
                      context.l10n.routineCalendarPreviewSubtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calendar grid view (monthly layout)
          _buildCalendarGrid(context, pattern, startDate, endDate),

          const SizedBox(height: 12),

          // Summary stats - Calculate totals for entire period
          Builder(
            builder: (context) {
              final cycleLength = pattern.sequence.length;
              final fullCycles = totalDays ~/ cycleLength;
              final remainingDays = totalDays % cycleLength;

              // Calculate total workout and rest days
              int totalWorkoutDays = fullCycles * _getWorkoutDays(pattern);
              int totalRestDays = fullCycles * _getRestDays(pattern);

              // Add days from incomplete cycle
              for (int i = 0; i < remainingDays; i++) {
                final day = pattern.sequence[i];
                if (day.toLowerCase() == 'rest') {
                  totalRestDays++;
                } else {
                  totalWorkoutDays++;
                }
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          context,
                          icon: Icons.fitness_center,
                          label: context.l10n.routineWorkoutDayLabel,
                          value: totalWorkoutDays.toString(),
                          color: context.colors.primary,
                        ),
                        _buildStat(
                          context,
                          icon: Icons.bed,
                          label: context.l10n.routineRestDayLabel,
                          value: totalRestDays.toString(),
                          color: context.colors.secondary,
                        ),
                        _buildStat(
                          context,
                          icon: Icons.calendar_today,
                          label: context.l10n.routineTotalDaysLabel,
                          value: totalDays.toString(),
                          color: context.colors.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.routineTotalWorkouts(totalWorkoutDays),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.l10n.routineTotalRestDays(totalRestDays),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build calendar grid view showing monthly layout
  Widget _buildCalendarGrid(
    BuildContext context,
    RoutinePattern pattern,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Show up to 3 months maximum for performance
    final monthsToShow = _calculateMonthsToShow(startDate, endDate);
    final shouldShowMore = monthsToShow.length < _getTotalMonths(startDate, endDate);

    return Column(
      children: [
        // Month calendars
        ...monthsToShow.map((monthStart) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMonthCalendar(
              context,
              pattern,
              monthStart,
              startDate,
              endDate,
            ),
          );
        }),

        // "Show more months" indicator
        if (shouldShowMore) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getTotalMonths(startDate, endDate) - monthsToShow.length} more months...',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build a single month calendar
  Widget _buildMonthCalendar(
    BuildContext context,
    RoutinePattern pattern,
    DateTime monthStart,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final firstDayWeekday = monthStart.weekday; // 1 = Monday, 7 = Sunday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _formatMonthYear(monthStart, context),
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ),

        // Weekday headers
        Row(
          children: [
            for (int i = 1; i <= 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _getWeekdayShort(i, context),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Calendar grid
        ...List.generate((daysInMonth + firstDayWeekday - 1) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstDayWeekday + 2;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  // Empty cell
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(monthStart.year, monthStart.month, dayNumber);
                final isInPeriod = !date.isBefore(periodStart) && !date.isAfter(periodEnd);

                if (!isInPeriod) {
                  // Day outside routine period (grayed out)
                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNumber',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Calculate if workout or rest day
                final dayOffset = date.difference(periodStart).inDays;
                final sequenceItem = pattern.sequence[dayOffset % pattern.sequence.length];
                final isRest = sequenceItem.toLowerCase() == 'rest';

                return Expanded(
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isRest
                            ? context.colors.secondaryContainer.withValues(alpha: 0.4)
                            : context.colors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isRest
                              ? context.colors.secondary.withValues(alpha: 0.3)
                              : context.colors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNumber',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isRest
                              ? context.colors.onSecondaryContainer
                              : context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  /// Calculate which months to show (max 3)
  List<DateTime> _calculateMonthsToShow(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month, 1);
    final endMonth = DateTime(end.year, end.month, 1);

    while (!current.isAfter(endMonth) && months.length < 3) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    return months;
  }

  /// Get total number of months in period
  int _getTotalMonths(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month) + 1;
  }

  /// Format month and year for header
  String _formatMonthYear(DateTime date, BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get short weekday name (Mon, Tue, etc.)
  String _getWeekdayShort(int weekday, BuildContext context) {
    final full = _getWeekdayName(weekday, context);
    return full.substring(0, 3);
  }

  Widget _buildCalendarDayItem(BuildContext context, _CalendarDay day) {
    final weekdayName = _getWeekdayName(day.date.weekday, context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Day badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: day.isRest
                  ? context.colors.secondaryContainer
                  : context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: day.isRest
                    ? context.colors.secondary.withValues(alpha: 0.3)
                    : context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'D${day.dayNumber}',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: day.isRest
                        ? context.colors.onSecondaryContainer
                        : context.colors.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${day.date.day}/${day.date.month}',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: (day.isRest
                            ? context.colors.onSecondaryContainer
                            : context.colors.onPrimaryContainer)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Day info
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    day.isRest ? Icons.bed : Icons.fitness_center,
                    size: 20,
                    color: day.isRest
                        ? context.colors.secondary
                        : context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekdayName,
                          style: context.textTheme.labelSmall?.copyWith(
                            color:
                                context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          day.dayName,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: day.isRest
                                ? context.colors.secondary
                                : context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday, BuildContext context) {
    final weekdays = [
      context.l10n.routineWeekdayMonday,
      context.l10n.routineWeekdayTuesday,
      context.l10n.routineWeekdayWednesday,
      context.l10n.routineWeekdayThursday,
      context.l10n.routineWeekdayFriday,
      context.l10n.routineWeekdaySaturday,
      context.l10n.routineWeekdaySunday,
    ];
    return weekdays[weekday - 1];
  }

  /// Maps pattern names to localized strings
  String _getLocalizedPatternName(RoutinePattern pattern, BuildContext context) {
    switch (pattern.name) {
      case '1 Workout + 1 Rest':
        return context.l10n.routinePatternOneWorkoutOneRest;
      case '2 Workouts + 1 Rest':
        return context.l10n.routinePatternTwoWorkoutsOneRest;
      case '3 Workouts + 1 Rest':
        return context.l10n.routinePatternThreeWorkoutsOneRest;
      case '3 Workouts + 2 Rest':
        return context.l10n.routinePatternThreeWorkoutsTwoRest;
      case '4 Workouts + 1 Rest':
        return context.l10n.routinePatternFourWorkoutsOneRest;
      case '4 Workouts + 3 Rest':
        return context.l10n.routinePatternFourWorkoutsThreeRest;
      case '5 Workouts + 2 Rest':
        return context.l10n.routinePatternFiveWorkoutsTwoRest;
      case '6 Workouts + 1 Rest':
        return context.l10n.routinePatternSixWorkoutsOneRest;
      default:
        return pattern.name; // Fallback for custom patterns
    }
  }

  /// Maps pattern descriptions to localized strings
  String _getLocalizedPatternDescription(RoutinePattern pattern, BuildContext context) {
    switch (pattern.name) {
      case '1 Workout + 1 Rest':
        return context.l10n.routinePatternOneWorkoutOneRestDesc;
      case '2 Workouts + 1 Rest':
        return context.l10n.routinePatternTwoWorkoutsOneRestDesc;
      case '3 Workouts + 1 Rest':
        return context.l10n.routinePatternThreeWorkoutsOneRestDesc;
      case '3 Workouts + 2 Rest':
        return context.l10n.routinePatternThreeWorkoutsTwoRestDesc;
      case '4 Workouts + 1 Rest':
        return context.l10n.routinePatternFourWorkoutsOneRestDesc;
      case '4 Workouts + 3 Rest':
        return context.l10n.routinePatternFourWorkoutsThreeRestDesc;
      case '5 Workouts + 2 Rest':
        return context.l10n.routinePatternFiveWorkoutsTwoRestDesc;
      case '6 Workouts + 1 Rest':
        return context.l10n.routinePatternSixWorkoutsOneRestDesc;
      default:
        return pattern.description; // Fallback for custom patterns
    }
  }
}

/// Helper class for calendar preview
class _CalendarDay {

  _CalendarDay({
    required this.date,
    required this.dayName,
    required this.isRest,
    required this.dayNumber,
  });
  final DateTime date;
  final String dayName;
  final bool isRest;
  final int dayNumber;
}
