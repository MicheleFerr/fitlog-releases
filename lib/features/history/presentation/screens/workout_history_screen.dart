/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: history
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// WorkoutHistoryScreen - Database completo e modificabile per allenamenti passati
library;

import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_history_editor_enhanced.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_detail_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/material_scroll_list.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_time_edit_sheet.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Date range filter options
enum DateRangeOption { today, thisWeek, thisMonth, allTime }

/// Provider for the selected date range filter
final dateRangeFilterProvider = createStateProvider<DateRangeOption>((ref) {
  return DateRangeOption.allTime;
});

/// Provider for view settings (grouping, calendar view)
final historyViewSettingsProvider = createStateProvider<HistoryViewSettings>((ref) {
  return const HistoryViewSettings();
});

/// View settings for workout history
class HistoryViewSettings {
  const HistoryViewSettings({
    this.groupByDate = false,
    this.isCalendarView = false,
  });

  final bool groupByDate;
  final bool isCalendarView;

  HistoryViewSettings copyWith({bool? groupByDate, bool? isCalendarView}) {
    return HistoryViewSettings(
      groupByDate: groupByDate ?? this.groupByDate,
      isCalendarView: isCalendarView ?? this.isCalendarView,
    );
  }
}

/// Provider for tracking which sections are expanded
final expandedSectionsProvider = StateProvider<Set<String>>((ref) {
  return {}; // All collapsed by default, will expand first section
});

/// Provider for the selected date in calendar view
final selectedCalendarDateProvider = createStateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for the focused month in calendar view
final focusedCalendarDateProvider = createStateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Database completo e modificabile per la cronologia degli allenamenti
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _searchAnimation;

  final TextEditingController _searchFieldController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh handler - syncs old workouts from Firestore
  Future<void> _onRefresh() async {
    unawaited(HapticFeedback.mediumImpact());

    final repo = ref.read(workoutHistoryRepositoryProvider);

    // Clear cache and re-sync everything from Firestore
    await repo.clearCache();
    await repo.forceSync();

    // Invalidate the provider to force UI refresh
    ref.invalidate(workoutHistoryProvider);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });

    // Update filter in provider
    final currentFilter = ref.read(workoutHistoryFilterProvider);
    ref.read(workoutHistoryFilterProvider.notifier).state = currentFilter
        .copyWith(searchQuery: query);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });

    if (_isSearchActive) {
      _searchController.forward();
    } else {
      _searchController.reverse();
      _searchFieldController.clear();
      _onSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final syncStatus = ref.watch(currentSyncStatusProvider);
    final dateRangeFilter = ref.watch(dateRangeFilterProvider);
    final stats = ref.watch(workoutStatsProvider);
    // Select only the fields we need to prevent unnecessary rebuilds
    final isCalendarView = ref.watch(
      historyViewSettingsProvider.select((s) => s.isCalendarView),
    );
    final groupByDate = ref.watch(
      historyViewSettingsProvider.select((s) => s.groupByDate),
    );

    // Get filtered workouts based on date range
    final filteredByDateRange = _getFilteredByDateRange(
      ref.watch(filteredWorkoutsProvider),
      dateRangeFilter,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.workoutDatabase),
        backgroundColor: colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const SemanticIcon(
            icon: AppIcons.arrowBackIos,
            semanticLabel: 'Arrow back ios',
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_isSearchActive ? AppIcons.close : AppIcons.search),
            onPressed: _toggleSearch,
          ),
          // Settings button
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.settings,
              semanticLabel: 'Settings',
            ),
            onPressed: () => _showViewSettingsSheet(context, l10n),
          ),
          // Sort options
          PopupMenuButton<WorkoutSortOption>(
            icon: const SemanticIcon(
              icon: AppIcons.sort,
              semanticLabel: 'Sort',
            ),
            onSelected: (value) {
              final currentFilter = ref.read(workoutHistoryFilterProvider);
              ref.read(workoutHistoryFilterProvider.notifier).state =
                  currentFilter.copyWith(sortBy: value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: WorkoutSortOption.dateDesc,
                child: Text(l10n.sortByDate),
              ),
              PopupMenuItem(
                value: WorkoutSortOption.duration,
                child: Text(l10n.sortByDuration),
              ),
              PopupMenuItem(
                value: WorkoutSortOption.volume,
                child: Text(l10n.sortByVolume),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar (animated)
            AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                return SizedBox(
                  height: 80 * _searchAnimation.value,
                  child: Opacity(
                    opacity: _searchAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSearchBar(context, l10n, colorScheme),
                    ),
                  ),
                );
              },
            ),

            // Quick Stats Header
            if (!_isSearchActive)
              _buildQuickStatsHeader(context, stats, colorScheme, theme, l10n),

            // Date Range Filter Chips
            if (!_isSearchActive)
              _buildDateFilterChips(
                context,
                dateRangeFilter,
                colorScheme,
                l10n,
              ),

            // Sync Status Indicator
            if (syncStatus == SyncStatus.initialSyncing)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    LoadingIndicator(size: 16, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      l10n.syncingWorkouts,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

            // Workouts List or Calendar View
            Expanded(
              child: workoutsAsync.when(
                loading: () => _buildLoadingState(l10n, colorScheme, theme),
                error: (error, stack) =>
                    _buildErrorState(l10n, colorScheme, error, theme),
                data: (workouts) => isCalendarView
                    ? _buildCalendarView(
                        context,
                        filteredByDateRange,
                        colorScheme,
                        theme,
                        l10n,
                      )
                    : filteredByDateRange.isEmpty
                    ? _buildEmptyStateWithRefresh(
                        context,
                        l10n,
                        colorScheme,
                        theme,
                      )
                    : groupByDate
                    ? _buildGroupedListWithRefresh(
                        context,
                        filteredByDateRange,
                        colorScheme,
                        theme,
                        l10n,
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: colorScheme.primary,
                        child: MaterialScrollList(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredByDateRange.length,
                          itemBuilder: (context, index) {
                            final workout = filteredByDateRange[index];
                            return _buildSwipeableWorkoutCard(
                              context,
                              workout,
                              colorScheme,
                              theme,
                              l10n,
                              index,
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter workouts by selected date range
  List<WorkoutHistoryDetail> _getFilteredByDateRange(
    List<WorkoutHistoryDetail> workouts,
    DateRangeOption dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (dateRange) {
      case DateRangeOption.today:
        return workouts.where((w) {
          final workoutDay = DateTime(
            w.completedAt.year,
            w.completedAt.month,
            w.completedAt.day,
          );
          return workoutDay.isAtSameMomentAs(today);
        }).toList();
      case DateRangeOption.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return workouts.where((w) {
          final workoutDay = DateTime(
            w.completedAt.year,
            w.completedAt.month,
            w.completedAt.day,
          );
          return workoutDay.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) ||
              workoutDay.isAtSameMomentAs(weekStart);
        }).toList();
      case DateRangeOption.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return workouts.where((w) {
          final workoutDay = DateTime(
            w.completedAt.year,
            w.completedAt.month,
            w.completedAt.day,
          );
          return workoutDay.isAfter(
                monthStart.subtract(const Duration(days: 1)),
              ) ||
              workoutDay.isAtSameMomentAs(monthStart);
        }).toList();
      case DateRangeOption.allTime:
        return workouts;
    }
  }

  /// Group workouts by week
  Map<String, List<WorkoutHistoryDetail>> _groupWorkoutsByWeek(
    List<WorkoutHistoryDetail> workouts,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final groups = <String, List<WorkoutHistoryDetail>>{};

    for (final workout in workouts) {
      final workoutDay = DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      );

      String groupKey;
      if (workoutDay.isAfter(thisWeekStart.subtract(const Duration(days: 1))) ||
          workoutDay.isAtSameMomentAs(thisWeekStart)) {
        groupKey = l10n.thisWeek;
      } else if (workoutDay.isAfter(
            lastWeekStart.subtract(const Duration(days: 1)),
          ) ||
          workoutDay.isAtSameMomentAs(lastWeekStart)) {
        groupKey = l10n.lastWeek;
      } else {
        // Get start of the week for this workout
        final weekStart = workoutDay.subtract(
          Duration(days: workoutDay.weekday - 1),
        );
        final weekLabel = DateFormat(
          'd MMM',
          l10n.localeName,
        ).format(weekStart);
        groupKey = l10n.weekOfDate(weekLabel);
      }

      groups.putIfAbsent(groupKey, () => []);
      groups[groupKey]!.add(workout);
    }

    return groups;
  }

  /// Build grouped list with collapsible sections
  Widget _buildGroupedList(
    BuildContext context,
    List<WorkoutHistoryDetail> workouts,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final groupedWorkouts = _groupWorkoutsByWeek(workouts, l10n);
    final expandedSections = ref.watch(expandedSectionsProvider);
    final sectionKeys = groupedWorkouts.keys.toList();

    // Expand first section by default if nothing is expanded
    if (expandedSections.isEmpty && sectionKeys.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(expandedSectionsProvider.notifier).state = {sectionKeys.first};
      });
    }

    return ListView.builder(
      key: const PageStorageKey('workout_history_grouped_list'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sectionKeys.length,
      itemBuilder: (context, sectionIndex) {
        final sectionKey = sectionKeys[sectionIndex];
        final sectionWorkouts = groupedWorkouts[sectionKey]!;
        final isExpanded = expandedSections.contains(sectionKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(
              context,
              sectionKey,
              sectionWorkouts.length,
              isExpanded,
              colorScheme,
              theme,
              l10n,
            ),

            // Section Content (animated)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  for (int i = 0; i < sectionWorkouts.length; i++)
                    _buildSwipeableWorkoutCard(
                      context,
                      sectionWorkouts[i],
                      colorScheme,
                      theme,
                      l10n,
                      i,
                    ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            if (sectionIndex < sectionKeys.length - 1)
              const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Build grouped list with pull-to-refresh support
  Widget _buildGroupedListWithRefresh(
    BuildContext context,
    List<WorkoutHistoryDetail> workouts,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: _buildGroupedList(context, workouts, colorScheme, theme, l10n),
    );
  }

  /// Build section header with expand/collapse toggle
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int workoutCount,
    bool isExpanded,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final currentExpanded = ref.read(expandedSectionsProvider);
        final newExpanded = Set<String>.from(currentExpanded);
        if (isExpanded) {
          newExpanded.remove(title);
        } else {
          newExpanded.add(title);
        }
        ref.read(expandedSectionsProvider.notifier).state = newExpanded;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Expand/collapse icon
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                AppIcons.chevronRight,
                size: AppIconSize.small,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),

            // Section title
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Workout count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.nWorkoutsCount(workoutCount),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calendar view with workout markers
  Widget _buildCalendarView(
    BuildContext context,
    List<WorkoutHistoryDetail> workouts,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final selectedDay = ref.watch(selectedCalendarDateProvider);
    final focusedDay = ref.watch(focusedCalendarDateProvider);

    // Create a map of dates to workouts for markers
    final workoutsByDate = <DateTime, List<WorkoutHistoryDetail>>{};
    for (final workout in workouts) {
      final date = DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      );
      workoutsByDate.putIfAbsent(date, () => []);
      workoutsByDate[date]!.add(workout);
    }

    // Get workouts for selected day
    final selectedDayNormalized = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final selectedDayWorkouts = workoutsByDate[selectedDayNormalized] ?? [];

    return Column(
      children: [
        // Calendar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar<WorkoutHistoryDetail>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 1)),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              HapticFeedback.lightImpact();
              ref.read(selectedCalendarDateProvider.notifier).state = selected;
              ref.read(focusedCalendarDateProvider.notifier).state = focused;
            },
            onPageChanged: (focused) {
              ref.read(focusedCalendarDateProvider.notifier).state = focused;
            },
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return workoutsByDate[normalizedDay] ?? [];
            },
            calendarStyle: CalendarStyle(
              // Today
              todayDecoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              // Selected
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              // Default
              defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
              weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
              outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              // Markers
              markerDecoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              leftChevronIcon: Icon(
                AppIcons.chevronLeft,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
              rightChevronIcon: Icon(
                AppIcons.chevronRight,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: theme.textTheme.labelSmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            locale: l10n.localeName,
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),
        ),

        const SizedBox(height: 16),

        // Selected day workouts header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                AppIcons.calendarToday,
                size: AppIconSize.small,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatSelectedDate(selectedDay, l10n),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.nWorkoutsCount(selectedDayWorkouts.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Workouts list for selected day
        Expanded(
          child: selectedDayWorkouts.isEmpty
              ? _buildNoWorkoutsForDay(
                  context,
                  selectedDay,
                  colorScheme,
                  theme,
                  l10n,
                )
              : MaterialScrollList(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedDayWorkouts.length,
                  itemBuilder: (context, index) {
                    return _buildSwipeableWorkoutCard(
                      context,
                      selectedDayWorkouts[index],
                      colorScheme,
                      theme,
                      l10n,
                      index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Format the selected date for the calendar header
  String _formatSelectedDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedNormalized = DateTime(date.year, date.month, date.day);
    final difference = today.difference(selectedNormalized).inDays;

    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.yesterday;
    } else {
      return DateFormat('EEEE, d MMMM', l10n.localeName).format(date);
    }
  }

  /// Empty state when no workouts for selected day
  Widget _buildNoWorkoutsForDay(
    BuildContext context,
    DateTime date,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.calendarMonth,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWorkoutsOnThisDay,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Stats Header widget
  Widget _buildQuickStatsHeader(
    BuildContext context,
    WorkoutStats stats,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '🏋️',
            stats.totalWorkouts.toString(),
            l10n.totalWorkouts,
            colorScheme,
            theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            context,
            '⏱️',
            _formatTotalTime(stats.totalTime),
            l10n.totalTime,
            colorScheme,
            theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            context,
            '💪',
            _formatVolume(stats.totalVolume),
            l10n.totalVolume,
            colorScheme,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String value,
    String label,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _formatTotalTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M kg';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K kg';
    }
    return '${volume.toInt()} kg';
  }

  /// Date filter chips
  Widget _buildDateFilterChips(
    BuildContext context,
    DateRangeOption selected,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            l10n.today,
            DateRangeOption.today,
            selected,
            colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            l10n.thisWeek,
            DateRangeOption.thisWeek,
            selected,
            colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            l10n.thisMonth,
            DateRangeOption.thisMonth,
            selected,
            colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            l10n.allTime,
            DateRangeOption.allTime,
            selected,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    DateRangeOption option,
    DateRangeOption selected,
    ColorScheme colorScheme,
  ) {
    final isSelected = option == selected;
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        ref.read(dateRangeFilterProvider.notifier).state = option;
      },
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Swipeable workout card with delete and repeat actions
  Widget _buildSwipeableWorkoutCard(
    BuildContext context,
    WorkoutHistoryDetail workout,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
    int index,
  ) {
    return Dismissible(
      key: Key(workout.id),
      background: _buildSwipeBackground(
        context,
        colorScheme.tertiary,
        AppIcons.refresh,
        l10n.repeatWorkout,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        colorScheme.error,
        AppIcons.delete,
        l10n.deleteWorkout,
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        // Fire-and-forget haptic feedback
        unawaited(HapticFeedback.mediumImpact());
        if (direction == DismissDirection.startToEnd) {
          // Repeat workout
          await _repeatWorkout(context, workout, l10n);
          return false; // Don't dismiss
        } else {
          // Delete workout - show confirmation
          return await _confirmDelete(context, workout, l10n);
        }
      },
      child: _buildWorkoutCard(
        context,
        workout,
        colorScheme,
        theme,
        l10n,
        index,
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    Color color,
    IconData icon,
    String label,
    Alignment alignment,
  ) {
    final theme = Theme.of(context);
    // 🔧 PERF FIX: Use theme color instead of hardcoded Colors.white
    final onColorText = theme.colorScheme.onPrimary;
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: onColorText,
      fontWeight: FontWeight.bold,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: onColorText, size: AppIconSize.medium),
                const SizedBox(width: 8),
                Text(label, style: textStyle),
              ]
            : [
                Text(label, style: textStyle),
                const SizedBox(width: 8),
                Icon(icon, color: onColorText, size: AppIconSize.medium),
              ],
      ),
    );
  }

  Future<void> _repeatWorkout(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) async {
    // Navigate to start workout from template
    SnackBarService.showSuccess(context, l10n.workoutRepeated);
    // TODO: Implement actual repeat functionality (create workout from history)
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteWorkoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.discardChanges),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.deleteWorkout),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final deleteResult = await ref
          .read(workoutHistoryOperationsProvider)
          .deleteWorkout(workout.id);

      deleteResult.fold(
        (failure) {
          SnackBarService.showError(
            context,
            l10n.errorWithMessage(failure.message),
          );
        },
        (_) {
          SnackBarService.showInfo(context, l10n.workoutDeletedSuccessfully);
        },
      );
    }

    return false; // We handle deletion ourselves
  }

  /// Show view settings bottom sheet
  void _showViewSettingsSheet(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => _ViewSettingsSheet(l10n: l10n),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _searchFieldController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchWorkouts,
            prefixIcon: Icon(
              AppIcons.search,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      AppIcons.clear,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchFieldController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return LoadingIndicator(
      message: l10n.loadingWorkouts,
      color: colorScheme.primary,
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    Object error,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: 'Error',
              size: AppIconSize.medium,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingWorkouts,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(workoutHistoryProvider);
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.history,
              semanticLabel: 'History',
              size: AppIconSize.medium,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.noWorkoutsFoundForQuery(_searchQuery)
                  : l10n.noWorkoutsInHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.tryDifferentSearchTerms
                  : l10n.startTrackingWorkouts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state with pull-to-refresh support to sync workouts from Firestore
  Widget _buildEmptyStateWithRefresh(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildEmptyState(context, l10n, colorScheme, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    WorkoutHistoryDetail workout,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
    int index,
  ) {
    final emoji = _getWorkoutEmoji(workout.name);
    final intensity = _getIntensityBadge(workout);
    final canEdit = _canEditWorkout(workout);

    // 🐛 BUG FIX: Removed TweenAnimationBuilder that was causing flash on scroll rebuild
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showWorkoutDetail(context, workout, l10n);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          // 🔧 PERF FIX: Use theme shadow color instead of hardcoded Colors.black
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Emoji + Name + Duration + Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout emoji
                  Text(emoji, style: theme.textTheme.titleLarge),
                  const SizedBox(width: 12),

                  // Name and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_getTimeOfDayEmoji(workout.completedAt)} ${_formatDate(workout.completedAt, l10n)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration (tappable to edit)
                  Semantics(
                    label: canEdit
                        ? l10n.minWorkout(workout.duration.inMinutes)
                        : '${l10n.minWorkout(workout.duration.inMinutes)} - ${l10n.premiumFeature}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => _editWorkoutDuration(context, workout, l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: canEdit
                              ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: canEdit
                              ? null
                              : Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.timer,
                              size: AppIconSize.tiny,
                              color: canEdit
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.minWorkout(workout.duration.inMinutes),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: canEdit
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                            ),
                            // Show lock badge for non-editable workouts
                            if (!canEdit) ...[
                              const SizedBox(width: 4),
                              Icon(
                                AppIcons.lock,
                                size: AppIconSize.tiny - 2,
                                color: colorScheme.outline,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      AppIcons.moreVert,
                      color: colorScheme.onSurfaceVariant,
                      size: AppIconSize.small,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _editWorkout(context, workout, l10n);
                          break;
                        case 'delete':
                          _deleteWorkout(context, workout, l10n);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: canEdit ? AppIcons.edit : AppIcons.lock,
                              semanticLabel: canEdit
                                  ? l10n.editWorkout
                                  : l10n.editWorkoutLocked,
                              size: AppIconSize.small,
                              color: canEdit
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.editWorkout,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: canEdit ? null : colorScheme.outline,
                                ),
                              ),
                            ),
                            if (!canEdit) ...[
                              const SizedBox(width: 4),
                              Icon(
                                AppIcons.premium,
                                size: AppIconSize.tiny,
                                color: colorScheme.tertiary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.delete,
                              semanticLabel: l10n.deleteWorkout,
                              size: AppIconSize.small,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.deleteWorkout),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exercise chips row
              _buildExerciseChips(workout, colorScheme, theme, l10n),
              const SizedBox(height: 12),

              // Progress bar + intensity badge
              Row(
                children: [
                  Expanded(
                    child: _IntensityBar(
                      intensity: _calculateIntensity(workout),
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(intensity, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseChips(
    WorkoutHistoryDetail workout,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final exercises = workout.exercises;
    final visibleExercises = exercises.take(3).toList();
    final remainingCount = exercises.length - 3;

    return Row(
      children: [
        ...visibleExercises.map((exercise) {
          final displayName = exercise.name.length > 8
              ? '${exercise.name.substring(0, 7)}…'
              : exercise.name;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
        if (remainingCount > 0)
          Text(
            l10n.andNMore(remainingCount),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  String _getWorkoutEmoji(String workoutName) {
    final nameLower = workoutName.toLowerCase();

    if (nameLower.contains('push') ||
        nameLower.contains('chest') ||
        nameLower.contains('petto')) {
      return '🏋️';
    } else if (nameLower.contains('pull') ||
        nameLower.contains('back') ||
        nameLower.contains('schiena')) {
      return '🔙';
    } else if (nameLower.contains('leg') || nameLower.contains('gamb')) {
      return '🦵';
    } else if (nameLower.contains('arm') || nameLower.contains('bracc')) {
      return '💪';
    } else if (nameLower.contains('shoulder') || nameLower.contains('spall')) {
      return '🤷';
    } else if (nameLower.contains('core') ||
        nameLower.contains('abs') ||
        nameLower.contains('addom')) {
      return '🎯';
    } else if (nameLower.contains('full') || nameLower.contains('total')) {
      return '⚡';
    } else if (nameLower.contains('cardio')) {
      return '🏃';
    }

    return '🏋️'; // Default
  }

  /// Returns emoji based on time of day
  /// 🌅 Morning (5-11), ☀️ Afternoon (12-16), 🌆 Evening (17-20), 🌙 Night (21-4)
  String _getTimeOfDayEmoji(DateTime date) {
    final hour = date.hour;
    if (hour >= 5 && hour < 12) {
      return '🌅'; // Morning
    } else if (hour >= 12 && hour < 17) {
      return '☀️'; // Afternoon
    } else if (hour >= 17 && hour < 21) {
      return '🌆'; // Evening
    } else {
      return '🌙'; // Late night (21-4)
    }
  }

  String _getIntensityBadge(WorkoutHistoryDetail workout) {
    final intensity = _calculateIntensity(workout);
    if (intensity > 0.8) return '🔥';
    if (intensity > 0.6) return '⚡';
    return '💪';
  }

  double _calculateIntensity(WorkoutHistoryDetail workout) {
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.length,
    );

    final durationMinutes = workout.duration.inMinutes;
    if (durationMinutes == 0) return 0.5;

    final setsPerMinute = totalSets / durationMinutes;
    return (setsPerMinute * 2).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    // Use calendar days (without time) for correct comparison
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return '${l10n.today}, ${DateFormat('HH:mm').format(date)}';
    } else if (difference == 1) {
      return '${l10n.yesterday}, ${DateFormat('HH:mm').format(date)}';
    } else if (difference < 7) {
      return l10n.daysAgo(difference);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _showWorkoutDetail(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.8,
        maxChildSize: 1.0,
        expand: false,
        snap: true,
        builder: (context, scrollController) => WorkoutDetailModal(
          workout: workout,
          scrollController: scrollController,
        ),
      ),
    );
  }

  /// Check if user can edit the given workout
  /// Premium users can edit all workouts
  /// Free users can only edit the most recent workout
  bool _canEditWorkout(WorkoutHistoryDetail workout) {
    // Check if user is premium
    final isPremium = ref.read(isPremiumUserProvider);
    if (isPremium) return true;

    // Free user: check if this is the latest workout
    final workoutsAsync = ref.read(workoutHistoryProvider);
    return workoutsAsync.whenOrNull(
          data: (workouts) {
            if (workouts.isEmpty) return true;
            // Find the workout with most recent completedAt
            final latestWorkout = workouts.reduce(
              (a, b) => a.completedAt.isAfter(b.completedAt) ? a : b,
            );
            return workout.id == latestWorkout.id;
          },
        ) ??
        false;
  }

  /// Show dialog when user tries to edit a locked workout
  void _showEditLockedDialog(BuildContext context, AppLocalizations l10n) {
    // Distinct haptic feedback for locked feature
    HapticFeedback.heavyImpact();

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          AppIcons.lock,
          color: colorScheme.tertiary,
          size: AppIconSize.xlarge,
        ),
        title: Text(l10n.premiumFeature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.onlyLatestWorkoutEditable),
            const SizedBox(height: 12),
            // Premium benefit highlight
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.premium,
                    color: colorScheme.tertiary,
                    size: AppIconSize.medium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.upgradeToEditAll,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to premium/subscription screen when ready
              SnackBarService.showSuccess(context, l10n.premiumComingSoon);
            },
            icon: const Icon(AppIcons.premium, size: AppIconSize.small),
            label: Text(l10n.upgradeToPremium),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _editWorkout(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) {
    HapticFeedback.lightImpact();

    // Check if user can edit this workout
    if (!_canEditWorkout(workout)) {
      _showEditLockedDialog(context, l10n);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) =>
          WorkoutHistoryEditorEnhanced(historyWorkout: workout),
    );
  }

  /// Edit workout duration using the time edit sheet
  Future<void> _editWorkoutDuration(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) async {
    unawaited(HapticFeedback.lightImpact());

    // Check if user can edit this workout
    if (!_canEditWorkout(workout)) {
      _showEditLockedDialog(context, l10n);
      return;
    }

    // Convert to Workout entity for the sheet
    final workoutEntity = workout.toWorkout();

    // Show the time edit sheet (without suspicious warning for manual edit)
    final newDuration = await WorkoutTimeEditSheet.show(
      context: context,
      workout: workoutEntity,
      showSuspiciousWarning:
          false, // User is manually editing, no warning needed
    );

    // If user selected a new duration, update the workout
    if (newDuration != null && context.mounted) {
      final updatedWorkout = workout.copyWith(duration: newDuration);

      final result = await ref
          .read(workoutHistoryOperationsProvider)
          .updateWorkout(updatedWorkout);

      result.fold(
        (failure) {
          SnackBarService.showError(
            context,
            l10n.errorWithMessage(failure.message),
          );
        },
        (_) {
          SnackBarService.showSuccess(context, l10n.workoutUpdatedSuccessfully);
          // Refresh the history list
          ref.invalidate(workoutHistoryProvider);
        },
      );
    }
  }

  void _deleteWorkout(
    BuildContext context,
    WorkoutHistoryDetail workout,
    AppLocalizations l10n,
  ) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteWorkoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.discardChanges),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await ref
                  .read(workoutHistoryOperationsProvider)
                  .deleteWorkout(workout.id);

              result.fold(
                (failure) => SnackBarService.showError(
                  context,
                  l10n.errorWithMessage(failure.message),
                ),
                (_) => SnackBarService.showInfo(
                  context,
                  l10n.workoutDeletedSuccessfully,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.deleteWorkout),
          ),
        ],
      ),
    );
  }
}

/// Horizontal intensity bar
class _IntensityBar extends StatelessWidget {
  const _IntensityBar({required this.intensity, required this.colorScheme});

  final double intensity;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: intensity,
        minHeight: 4,
        backgroundColor: colorScheme.surfaceContainerLow,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getIntensityColor(intensity),
        ),
      ),
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity > 0.8) {
      return colorScheme.error; // High intensity - red/orange
    } else if (intensity > 0.5) {
      return colorScheme.primary; // Medium intensity - primary
    }
    return colorScheme.tertiary; // Low intensity - tertiary
  }
}

/// View settings bottom sheet
class _ViewSettingsSheet extends ConsumerWidget {
  const _ViewSettingsSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    // Select only needed fields for surgical rebuilds
    final isCalendarView = ref.watch(
      historyViewSettingsProvider.select((s) => s.isCalendarView),
    );
    final groupByDate = ref.watch(
      historyViewSettingsProvider.select((s) => s.groupByDate),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.settings,
                    size: AppIconSize.medium,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.viewSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List View / Calendar View toggle
            _SettingsTile(
              icon: isCalendarView ? AppIcons.calendarMonth : AppIcons.list,
              title: isCalendarView ? l10n.calendarView : l10n.listView,
              subtitle: isCalendarView ? l10n.calendarView : l10n.listView,
              trailing: Switch.adaptive(
                value: isCalendarView,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  final currentSettings = ref.read(historyViewSettingsProvider);
                  ref.read(historyViewSettingsProvider.notifier).state =
                      currentSettings.copyWith(isCalendarView: value);
                },
              ),
            ),

            // Group by date toggle
            _SettingsTile(
              icon: AppIcons.calendarToday,
              title: l10n.groupByDate,
              subtitle: l10n.groupByDate,
              trailing: Switch.adaptive(
                value: groupByDate,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  final currentSettings = ref.read(historyViewSettingsProvider);
                  ref.read(historyViewSettingsProvider.notifier).state =
                      currentSettings.copyWith(groupByDate: value);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Settings tile widget
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        size: AppIconSize.medium,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }
}
