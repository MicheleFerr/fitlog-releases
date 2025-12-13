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
/// - Three view modes: Monthly (calendar), Annual (12-month grid), Multi-year (condensed strip)
/// - Dropdown to switch between views
/// - Current streak stats (weeks in a row, rest days)
/// - GitHub-like heatmap visualization
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

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// View modes for streak visualization
enum StreakViewMode {
  monthly,
  annual,
  multiYear,
}

/// Extension for localized labels
extension StreakViewModeExtension on StreakViewMode {
  String getLabel(BuildContext context) {
    switch (this) {
      case StreakViewMode.monthly:
        return context.l10n.streakViewMonthly;
      case StreakViewMode.annual:
        return context.l10n.streakViewAnnual;
      case StreakViewMode.multiYear:
        return context.l10n.streakViewMultiYear;
    }
  }
}

/// Modal for displaying workout streak details with GitHub-style contribution calendar
class StreakModal extends StatefulWidget {
  const StreakModal({
    required this.exerciseHistories,
    this.scrollController,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final ScrollController? scrollController;

  @override
  State<StreakModal> createState() => _StreakModalState();
}

class _StreakModalState extends State<StreakModal> {
  // View mode state
  StreakViewMode _viewMode = StreakViewMode.monthly;

  // Global key for capturing calendar screenshot
  final GlobalKey _calendarKey = GlobalKey();

  // 🔐 User-scoped preferences keys
  String get _defaultViewKey => userCacheKeys.userScopedKey('streak_default_view');
  String get _calendarColorKey => userCacheKeys.userScopedKey('streak_calendar_color');

  // Available calendar colors
  static const List<Color> _availableColors = [
    Color(0xFF4CAF50),  // Green (default)
    Color(0xFF2196F3),  // Blue
    Color(0xFFFF9800),  // Orange
    Color(0xFFE91E63),  // Pink
    Color(0xFF9C27B0),  // Purple
    Color(0xFFF44336),  // Red
    Color(0xFF00BCD4),  // Cyan
    Color(0xFFFFEB3B),  // Yellow
  ];

  Color _selectedCalendarColor = _availableColors[0];  // Default green

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load default view mode
    final viewIndex = prefs.getInt(_defaultViewKey);
    if (viewIndex != null && viewIndex < StreakViewMode.values.length) {
      setState(() {
        _viewMode = StreakViewMode.values[viewIndex];
      });
    }

    // Load calendar color
    final colorValue = prefs.getInt(_calendarColorKey);
    if (colorValue != null) {
      setState(() {
        _selectedCalendarColor = Color(colorValue);
      });
    }
  }

  /// Save view mode preference
  Future<void> _saveDefaultView(StreakViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultViewKey, mode.index);
  }

  /// Save calendar color preference
  Future<void> _saveCalendarColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_calendarColorKey, color.value);
  }

  /// Get all unique workout dates (normalized to day precision)
  Set<DateTime> _getAllWorkoutDates() {
    final dates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        dates.add(dateOnly);
      }
    }
    return dates;
  }

  /// Calculate current streak (consecutive weeks with at least 1 workout)
  int _calculateWeekStreak() {
    final workoutDates = _getAllWorkoutDates();
    if (workoutDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Group dates by week (ISO week number)
    final weekMap = <String, bool>{};
    for (final date in workoutDates) {
      final weekKey = _getWeekKey(date);
      weekMap[weekKey] = true;
    }

    // Count consecutive weeks backwards from current week
    final currentWeekKey = _getWeekKey(todayOnly);
    int streak = 0;
    DateTime checkDate = todayOnly;

    // Check if current week has workout
    if (!weekMap.containsKey(currentWeekKey)) {
      // Check last week
      checkDate = todayOnly.subtract(const Duration(days: 7));
      final lastWeekKey = _getWeekKey(checkDate);
      if (!weekMap.containsKey(lastWeekKey)) {
        return 0; // Streak broken
      }
    }

    // Count consecutive weeks
    while (true) {
      final weekKey = _getWeekKey(checkDate);
      if (weekMap.containsKey(weekKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get week key (year-weekNumber format)
  String _getWeekKey(DateTime date) {
    // ISO 8601 week number
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekNumber = ((dayOfYear + DateTime(date.year, 1, 1).weekday - 1) / 7).floor() + 1;
    return '${date.year}-W$weekNumber';
  }

  /// Calculate days since last workout (more meaningful than total rest days)
  int _calculateDaysSinceLastWorkout() {
    final workoutDates = _getAllWorkoutDates();
    if (workoutDates.isEmpty) return 0;

    // Find most recent workout date
    final mostRecentWorkout = workoutDates.reduce((a, b) => a.isAfter(b) ? a : b);

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Calculate days since last workout
    final daysSince = todayOnly.difference(mostRecentWorkout).inDays;

    // Return 0 if workout was today
    return daysSince < 0 ? 0 : daysSince;
  }

  @override
  Widget build(BuildContext context) {
    final weekStreak = _calculateWeekStreak();
    final daysSinceLastWorkout = _calculateDaysSinceLastWorkout();
    final workoutDates = _getAllWorkoutDates();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Header with dropdown and close button
            _buildHeader(context),
            const SizedBox(height: 20),

            // Stats header (weeks in a row, days since last workout)
            _buildStatsHeader(context, weekStreak, daysSinceLastWorkout),
            const SizedBox(height: 24),

            // Calendar view based on mode (wrapped in RepaintBoundary for screenshots)
            RepaintBoundary(
              key: _calendarKey,
              child: Container(
                color: context.colors.surface,  // Background for screenshot
                padding: const EdgeInsets.all(16),
                child: _buildCalendarView(context, workoutDates),
              ),
            ),
            const SizedBox(height: 24),

            // Close button
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  /// Header with dropdown and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SemanticIcon(
              icon: AppIcons.back,
              semanticLabel: context.l10n.back,
              size: AppIconSize.medium,
            ),
          ),
          const SizedBox(width: 12),

          // View mode dropdown
          Expanded(
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: DropdownButton<StreakViewMode>(
                value: _viewMode,
                isExpanded: true,
                isDense: false,
                underline: const SizedBox.shrink(),
                icon: const SemanticIcon(
                  icon: AppIcons.expandMore,
                  semanticLabel: 'Select view',
                  size: AppIconSize.small,
                ),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: context.colors.surfaceContainerHighest,
                items: StreakViewMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.getLabel(context)),
                  );
                }).toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() => _viewMode = mode);
                    HapticFeedback.selectionClick();
                  }
                },
              ),
            ),
          ),

          // Share/export button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showShareDialog(context);
            },
            icon: const SemanticIcon(
              icon: AppIcons.share,
              semanticLabel: 'Share',
              size: AppIconSize.medium,
            ),
          ),

          // Settings button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSettingsDialog(context);
            },
            icon: SemanticIcon(
              icon: AppIcons.settings,
              semanticLabel: context.l10n.settings,
              size: AppIconSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  /// Show info dialog for week streak metric
  void _showWeekStreakInfo(BuildContext context, int weekStreak) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Text('🔥', style: context.textTheme.displayLarge),
        title: Text(context.l10n.weeksInRow),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.weeksInRowExplanation,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.yourCurrentStreak,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$weekStreak ${context.l10n.consecutiveWeeks}',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }

  /// Show info dialog for days since last workout metric
  void _showDaysSinceWorkoutInfo(BuildContext context, int daysSinceLastWorkout) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Text('⏱️', style: context.textTheme.displayLarge),
        title: Text(context.l10n.daysSinceLastWorkout),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.daysSinceWorkoutExplanation,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: daysSinceLastWorkout == 0
                    ? context.colors.success.withValues(alpha: 0.1)
                    : daysSinceLastWorkout <= 2
                        ? context.colors.primary.withValues(alpha: 0.1)
                        : context.colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.timeSinceLastWorkout,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysSinceLastWorkout == 0
                        ? context.l10n.workedOutToday
                        : '$daysSinceLastWorkout ${context.l10n.daysAgo}',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: daysSinceLastWorkout == 0
                          ? context.colors.success
                          : daysSinceLastWorkout <= 2
                              ? context.colors.primary
                              : context.colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }

  /// Stats header (weeks in a row, days since last workout)
  Widget _buildStatsHeader(BuildContext context, int weekStreak, int daysSinceLastWorkout) {
    // IntrinsicHeight ensures both cards have equal height regardless of text length
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showWeekStreakInfo(context, weekStreak);
              },
              borderRadius: BorderRadius.circular(12),
              child: _buildStatCard(
                context,
                icon: '🔥',
                value: '$weekStreak',
                label: context.l10n.weeksInRow,
                color: context.colors.error,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showDaysSinceWorkoutInfo(context, daysSinceLastWorkout);
              },
              borderRadius: BorderRadius.circular(12),
              child: _buildStatCard(
                context,
                icon: '⏱️',
                value: '$daysSinceLastWorkout',
                label: context.l10n.daysSinceLastWorkout,
                color: daysSinceLastWorkout == 0
                    ? context.colors.success  // Green if worked out today
                    : daysSinceLastWorkout <= 2
                        ? context.colors.primary  // Blue if 1-2 days
                        : context.colors.warning,  // Warning if 3+ days
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calendar view based on selected mode
  Widget _buildCalendarView(BuildContext context, Set<DateTime> workoutDates) {
    switch (_viewMode) {
      case StreakViewMode.monthly:
        return _buildMonthlyView(context, workoutDates);
      case StreakViewMode.annual:
        return _buildAnnualView(context, workoutDates);
      case StreakViewMode.multiYear:
        return _buildMultiYearView(context, workoutDates);
    }
  }

  /// Monthly view: traditional calendar with day headers
  Widget _buildMonthlyView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Show current month and previous month
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day of week headers
        _buildDayHeaders(context),
        const SizedBox(height: 12),

        // Previous month
        _buildMonthCalendar(context, previousMonth, workoutDates, today),
        const SizedBox(height: 24),

        // Current month
        _buildMonthCalendar(context, currentMonth, workoutDates, today),
      ],
    );
  }

  /// Day of week headers (Lun, Mar, Mer, Gio, Ven, Sab, Dom)
  Widget _buildDayHeaders(BuildContext context) {
    final dayNames = [
      context.l10n.mondayShort,
      context.l10n.tuesdayShort,
      context.l10n.wednesdayShort,
      context.l10n.thursdayShort,
      context.l10n.fridayShort,
      context.l10n.saturdayShort,
      context.l10n.sundayShort,
    ];

    return Row(
      children: dayNames.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Single month calendar
  Widget _buildMonthCalendar(
    BuildContext context,
    DateTime month,
    Set<DateTime> workoutDates,
    DateTime today,
  ) {
    // Month title (e.g., "ottobre 2025")
    final monthName = DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(month);

    // Calculate first day of month and total days
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get starting weekday (1 = Monday, 7 = Sunday)
    final startWeekday = firstDayOfMonth.weekday;

    // Total cells (including empty cells for alignment)
    final totalCells = daysInMonth + (startWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          monthName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            // Calculate day number
            final dayNumber = index - (startWeekday - 1) + 1;

            // Empty cell before month starts
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(month.year, month.month, dayNumber);
            final hasWorkout = workoutDates.contains(date);
            final isToday = date.isAtSameMomentAs(today);

            return DecoratedBox(
              decoration: BoxDecoration(
                color: hasWorkout
                    ? _selectedCalendarColor.withValues(alpha: 0.15)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(
                        color: _selectedCalendarColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '$dayNumber',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                        ? context.colors.primary
                        : hasWorkout
                            ? context.colors.onSurface
                            : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Annual view: 3x4 grid with 12 months (mini heatmaps)
  Widget _buildAnnualView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final year = now.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year title
        Text(
          '$year',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 3x4 grid of months
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final monthNumber = index + 1;
            return _buildMiniMonth(context, year, monthNumber, workoutDates);
          },
        ),
      ],
    );
  }

  /// Mini month heatmap for annual view
  Widget _buildMiniMonth(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    // Month name (short form: gen, feb, mar, etc.)
    final monthNames = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
    final monthName = monthNames[month - 1];

    // Calculate days in month
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    // Total cells
    final totalCells = daysInMonth + (startWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          monthName,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Mini heatmap grid
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: rows * 7,
            itemBuilder: (context, index) {
              final dayNumber = index - (startWeekday - 1) + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(year, month, dayNumber);
              final hasWorkout = workoutDates.contains(date);
              final today = DateTime.now();
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return Container(
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? _selectedCalendarColor
                      : context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                  border: isToday
                      ? Border.all(
                          color: _selectedCalendarColor,
                          width: 1,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Multi-year view: horizontal strip for entire year
  Widget _buildMultiYearView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final year = now.year;

    // Month names
    final monthNames = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year title
        Text(
          '$year',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal month labels
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(12, (index) {
              return SizedBox(
                width: 50,
                child: Text(
                  monthNames[index],
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),

        // Single horizontal strip (all 365 days)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(12, (monthIndex) {
              final month = monthIndex + 1;
              return _buildMonthStrip(context, year, month, workoutDates);
            }),
          ),
        ),
      ],
    );
  }

  /// Month strip for multi-year view (horizontal cells)
  Widget _buildMonthStrip(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Row(
      children: List.generate(daysInMonth, (dayIndex) {
        final day = dayIndex + 1;
        final date = DateTime(year, month, day);
        final hasWorkout = workoutDates.contains(date);
        final today = DateTime.now();
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        return Container(
          width: 6,
          height: 30,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: hasWorkout
                ? _selectedCalendarColor
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
            border: isToday
                ? Border.all(
                    color: _selectedCalendarColor,
                    width: 1,
                  )
                : null,
          ),
        );
      }),
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

  /// Capture calendar screenshot and share it
  Future<void> _shareStreak(BuildContext context) async {
    try {
      // Find the RepaintBoundary and capture screenshot
      final boundary = _calendarKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not capture calendar screenshot');
      }

      // Capture image with high quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/streak_calendar.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: context.l10n.shareStreakDescription,
      );
    } catch (e) {
      // Show error snackbar if sharing fails
      if (context.mounted) {
        SnackBarService.showError(context, '${context.l10n.error}: $e');
      }
    }
  }

  /// Show share dialog with export options
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: SemanticIcon(
          icon: AppIcons.share,
          semanticLabel: context.l10n.share,
          size: AppIconSize.large,
          color: context.colors.primary,
        ),
        title: Text(context.l10n.shareYourProgress),
        content: Text(
          context.l10n.shareStreakDescription,
          style: context.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
              // Give time for dialog to close before capturing screenshot
              await Future.delayed(const Duration(milliseconds: 300));
              await _shareStreak(context);
            },
            icon: const SemanticIcon(
              icon: AppIcons.share,
              semanticLabel: '',
              size: AppIconSize.small,
            ),
            label: Text(context.l10n.share),
          ),
        ],
      ),
    );
  }

  /// Show color picker dialog
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.customizeColors),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = color.value == _selectedCalendarColor.value;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedCalendarColor = color;
                  });
                  _saveCalendarColor(color);
                  Navigator.pop(dialogContext);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: context.colors.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? SemanticIcon(
                          icon: AppIcons.check,
                          semanticLabel: '',  // Decorative icon
                          color: Theme.of(context).colorScheme.surface,
                          size: AppIconSize.large,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  /// Show default view selector dialog
  void _showDefaultViewSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.defaultView),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: StreakViewMode.values.map((mode) {
            final isSelected = mode == _viewMode;

            return RadioListTile<StreakViewMode>(
              value: mode,
              groupValue: _viewMode,
              title: Text(mode.getLabel(context)),
              selected: isSelected,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _viewMode = value;
                  });
                  _saveDefaultView(value);
                  Navigator.pop(dialogContext);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  /// Show settings dialog for customization
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: SemanticIcon(
          icon: AppIcons.settings,
          semanticLabel: context.l10n.settings,
          size: AppIconSize.large,
          color: context.colors.primary,
        ),
        title: Text(context.l10n.streakSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.streakSettingsDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(dialogContext);
                Future.delayed(const Duration(milliseconds: 200), () {
                  _showColorPicker(context);
                });
              },
              child: _buildSettingOption(
                context,
                icon: AppIcons.colorLens,
                title: context.l10n.customizeColors,
                subtitle: '${_availableColors.length} ${context.l10n.colorsAvailable}',
                enabled: true,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(dialogContext);
                Future.delayed(const Duration(milliseconds: 200), () {
                  _showDefaultViewSelector(context);
                });
              },
              child: _buildSettingOption(
                context,
                icon: AppIcons.calendarMonth,
                title: context.l10n.defaultView,
                subtitle: _viewMode.getLabel(context),
                enabled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  /// Build setting option row
  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Row(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: title,
            size: AppIconSize.medium,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
