import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_view_mode_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/favorite_exercises_notifier.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/enums/exercise_view_mode.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_group_expansion_tile.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_group_correction_sheet.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/feedback_submission_dialog.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/streak_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_modal.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pro_insights_badge.dart';

/// Filter options for exercise list
///
/// Task 5.1: Simplified to 3 chips (removed PR, frequency)
enum SortBy {
  /// Filter by favorite exercises (starred)
  favorites,

  /// Sort by workout frequency (most workouts first)
  mostUsed,

  /// Sort by most recent workout (newest first)
  recent,
}

/// Provider for search bar visibility state
///
/// **Purpose**: Controls whether search bar is visible in analytics screen
/// **Behavior**: Persistent within session (resets on screen exit)
/// **Default**: false (hidden)
final searchBarVisibilityProvider = StateProvider.autoDispose<bool>((ref) => false);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 ${context.l10n.analytics}'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.homePath);
            }
          },
        ),
        actions: [
          // Search toggle button (Task: New UX)
          Consumer(
            builder: (context, ref, child) {
              final isSearchVisible = ref.watch(searchBarVisibilityProvider);

              return IconButton(
                icon: SemanticIcon.button(
                  icon: isSearchVisible ? AppIcons.close : AppIcons.search,
                  semanticLabel: isSearchVisible ? context.l10n.close : context.l10n.search,
                ),
                tooltip: isSearchVisible ? context.l10n.close : context.l10n.search,
                onPressed: () {
                  // Toggle search bar visibility
                  ref.read(searchBarVisibilityProvider.notifier).state = !isSearchVisible;

                  // Haptic feedback
                  HapticFeedback.lightImpact();
                },
              );
            },
          ),
          // View mode selector
          Consumer(
            builder: (context, ref, child) {
              final currentMode = ref.watch(exerciseViewModeProvider);

              return PopupMenuButton<ExerciseViewMode>(
                icon: SemanticIcon.button(
                  icon: AppIcons.viewList,
                  semanticLabel: context.l10n.viewMode,
                ),
                tooltip: context.l10n.viewMode,
                onSelected: (ExerciseViewMode mode) {
                  ref.read(exerciseViewModeProvider.notifier).state = mode;
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: ExerciseViewMode.compact,
                    child: Row(
                      children: [
                        Icon(
                          currentMode == ExerciseViewMode.compact
                              ? AppIcons.checkCircle
                              : AppIcons.radioButtonUnchecked,
                          size: AppIconSize.small,
                          color: currentMode == ExerciseViewMode.compact
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(context.l10n.viewModeCompact),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ExerciseViewMode.byMuscleGroup,
                    child: Row(
                      children: [
                        Icon(
                          currentMode == ExerciseViewMode.byMuscleGroup
                              ? AppIcons.checkCircle
                              : AppIcons.radioButtonUnchecked,
                          size: AppIconSize.small,
                          color: currentMode == ExerciseViewMode.byMuscleGroup
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(context.l10n.viewModeByMuscleGroup),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ExerciseViewMode.byDate,
                    child: Row(
                      children: [
                        Icon(
                          currentMode == ExerciseViewMode.byDate
                              ? AppIcons.checkCircle
                              : AppIcons.radioButtonUnchecked,
                          size: AppIconSize.small,
                          color: currentMode == ExerciseViewMode.byDate
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(context.l10n.viewModeByDate),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? const _NotAuthenticatedView()
          : userId == null
              ? const _NotAuthenticatedView()
              : _AuthenticatedAnalyticsView(userId: userId),
    );
  }
}

class _AuthenticatedAnalyticsView extends ConsumerWidget {
  const _AuthenticatedAnalyticsView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(exerciseHistoryStreamProvider(userId));

    return historyAsync.when(
      data: (exerciseHistories) => _AnalyticsContent(
        exerciseHistories: exerciseHistories,
        userId: userId,
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

class _AnalyticsContent extends ConsumerStatefulWidget {
  const _AnalyticsContent({
    required this.exerciseHistories,
    required this.userId,
  });

  final List<ExerciseHistory> exerciseHistories;
  final String userId;

  @override
  ConsumerState<_AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends ConsumerState<_AnalyticsContent>
    with SafeSetStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  SortBy _sortBy = SortBy.mostUsed; // Default: sort by most used

  // Scroll-away behavior state
  bool _showBars = true; // Show stats + search + chips
  double _lastScrollOffset = 0.0;
  static const double _scrollThreshold = 100.0; // Minimum scroll to trigger (increased for stability)

  /// Debounced search handler - waits 300ms after user stops typing
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery.value = query; // ValueNotifier update (no setState needed)
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Handle scroll to show/hide bars
  void _onScroll() {
    final currentScroll = _scrollController.offset;
    final scrollDelta = currentScroll - _lastScrollOffset;

    // Only trigger if scrolled beyond threshold
    if (scrollDelta.abs() > _scrollThreshold) {
      final shouldShow = scrollDelta < 0; // Scroll up = show, down = hide

      // Only update if state changed (avoid unnecessary rebuilds)
      if (shouldShow != _showBars) {
        safeSetState(() => _showBars = shouldShow);
      }

      _lastScrollOffset = currentScroll;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchQuery.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Calculate filter counts for live counter badges
  /// Returns Map with counts for each filter type
  Map<SortBy, int> get _filterCounts {
    // Watch favorites from provider (Task 5.3)
    final favorites = ref.watch(favoriteExercisesNotifierProvider);

    return {
      // Favorites filter: Count exercises marked as favorite (Task 5.3)
      SortBy.favorites: widget.exerciseHistories
          .where((h) => favorites.contains(h.exerciseName))
          .length,

      // Most Used filter: Total number of exercises (Task 5.1)
      SortBy.mostUsed: widget.exerciseHistories.length,

      // Recent filter: Exercises with at least 1 workout session (Task 5.1)
      SortBy.recent: widget.exerciseHistories
          .where((h) => h.sessions.isNotEmpty)
          .length,
    };
  }

  List<ExerciseHistory> _getFilteredHistories(String searchQuery) {
    // Step 1: Filter by search query
    final filtered = searchQuery.isEmpty
        ? widget.exerciseHistories
        : widget.exerciseHistories.where((history) {
            final query = searchQuery.toLowerCase();
            final exerciseName = history.exerciseName.toLowerCase();
            final muscleGroup = history.muscleGroup.toLowerCase();
            return exerciseName.contains(query) || muscleGroup.contains(query);
          }).toList();

    // Watch favorites from provider (Task 5.3)
    final favorites = ref.watch(favoriteExercisesNotifierProvider);

    // Step 2: Filter/Sort by selected criteria (Task 5.3)
    switch (_sortBy) {
      case SortBy.favorites:
        // Filter favorites, then sort alphabetically (Task 5.3)
        final favoritesOnly = filtered
            .where((h) => favorites.contains(h.exerciseName))
            .toList();
        favoritesOnly.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));
        return favoritesOnly;

      case SortBy.mostUsed:
        // Sort by workout frequency (most sessions first)
        filtered.sort((a, b) => b.sessions.length.compareTo(a.sessions.length));
        break;

      case SortBy.recent:
        // Sort by most recent workout date
        filtered.sort((a, b) {
          final aLast = a.sessions.isEmpty
              ? DateTime(1970)
              : a.sessions
                  .map((s) => s.date)
                  .reduce((a, b) => a.isAfter(b) ? a : b);
          final bLast = b.sessions.isEmpty
              ? DateTime(1970)
              : b.sessions
                  .map((s) => s.date)
                  .reduce((a, b) => a.isAfter(b) ? a : b);
          return bLast.compareTo(aLast);
        });
        break;
    }

    return filtered;
  }

  /// Group exercises by muscle group
  Map<String, List<ExerciseHistory>> _getGroupedHistories(List<ExerciseHistory> histories) {
    final grouped = <String, List<ExerciseHistory>>{};

    for (final history in histories) {
      final muscleGroup = history.muscleGroup;
      if (!grouped.containsKey(muscleGroup)) {
        grouped[muscleGroup] = [];
      }
      grouped[muscleGroup]!.add(history);
    }

    // Sort muscle groups alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exerciseHistories.isEmpty) {
      return const _EmptyStateView();
    }

    return Stack(
      children: [
        // Main content
        ValueListenableBuilder<String>(
          valueListenable: _searchQuery,
          builder: (context, searchQuery, _) {
            final filteredHistories = _getFilteredHistories(searchQuery);

            return Column(
              children: [
        // Stats bar (with scroll-away animation)
        AnimatedSize(
          duration: AppAnimations.normal,
          curve: AppAnimations.decelerate,
          child: _showBars
              ? _QuickStatsSummary(exerciseHistories: widget.exerciseHistories)
              : const SizedBox.shrink(),
        ),

        // Search bar (conditional with slide animation + scroll-away)
        Consumer(
          builder: (context, ref, child) {
            final isSearchVisible = ref.watch(searchBarVisibilityProvider);

            return AnimatedSize(
              duration: AppAnimations.normal,
              curve: AppAnimations.decelerate,
              child: (_showBars && isSearchVisible)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true, // Auto-focus when appears
                        decoration: InputDecoration(
                          hintText: context.l10n.searchExercises,
                          prefixIcon: SemanticIcon(
                            icon: AppIcons.search,
                            semanticLabel: context.l10n.search,
                            size: AppIconSize.medium,
                            color: context.colors.onSurfaceVariant,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: SemanticIcon.button(
                                    icon: AppIcons.close,
                                    semanticLabel: context.l10n.clear,
                                  ),
                                  onPressed: () {
                                    _debounce?.cancel();
                                    _searchController.clear();
                                    _searchQuery.value = ''; // ValueNotifier update
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    )
                  : const SizedBox.shrink(), // Hidden state: no height
            );
          },
        ),

        // Sort & Filter chips with live counters (with scroll-away animation)
        AnimatedSize(
          duration: AppAnimations.normal,
          curve: AppAnimations.decelerate,
          child: _showBars
              ? _SortFilterChips(
                  sortBy: _sortBy,
                  filterCounts: _filterCounts,
                  onSortChanged: (newSort) => safeSetState(() => _sortBy = newSort),
                )
              : const SizedBox.shrink(),
        ),

        // Pro Insights Badge - Compact clickable badge with PRO label
        // Click → Navigate to /analytics/pro for full analytics view
        // FREE: Lock icon + upgrade CTA
        // PREMIUM: Quick stats preview + "View Details"
        if (_showBars)
          ProInsightsBadge(exerciseHistories: widget.exerciseHistories),

        // Results list
        Expanded(
          child: filteredHistories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
                        icon: AppIcons.search,
                        semanticLabel: context.l10n.noResultsFound,
                        size: AppIconSize.xxlarge,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.noResultsFound,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.tryAnotherSearch,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Invalidate provider to trigger fresh data fetch
                    ref.invalidate(exerciseHistoryStreamProvider(widget.userId));
                    // Wait for new data to be available
                    await ref.read(exerciseHistoryStreamProvider(widget.userId).future);
                  },
                  child: Consumer(
                    builder: (context, ref, child) {
                      final viewMode = ref.watch(exerciseViewModeProvider);

                      switch (viewMode) {
                        case ExerciseViewMode.detailed:
                          return _buildFlatList(filteredHistories);
                        case ExerciseViewMode.compact:
                          return _buildFlatList(filteredHistories);
                        case ExerciseViewMode.byMuscleGroup:
                          return _buildAccordionList(filteredHistories);
                        case ExerciseViewMode.byDate:
                          return _buildTimelineList(filteredHistories);
                        case ExerciseViewMode.byMajorWorkouts:
                          return _buildFlatList(filteredHistories); // Filter to major workouts only
                      }
                    },
                  ),
                ),
        ),
              ],
            ); // Close Column
          }, // Close ValueListenableBuilder builder
        ), // Close ValueListenableBuilder

      ],
    ); // Close Stack
  }


  /// Build accordion list of exercises grouped by muscle group
  ///
  /// Uses MuscleGroupExpansionTile for expand/collapse functionality
  Widget _buildAccordionList(List<ExerciseHistory> filteredHistories) {
    final grouped = _getGroupedHistories(filteredHistories);

    if (grouped.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final muscleGroup = grouped.keys.elementAt(groupIndex);
        final exercises = grouped[muscleGroup]!;

        return Padding(
          key: ValueKey(muscleGroup),
          padding: const EdgeInsets.only(bottom: 8),
          child: MuscleGroupExpansionTile(
            muscleGroup: muscleGroup,
            exerciseCount: exercises.length,
            children: exercises
                .map((history) => _ExerciseHistoryCard(history: history))
                .toList(),
          ),
        );
      },
    );
  }

  /// Build flat list of exercises (compact view)
  ///
  /// Shows exercises in a simple list without grouping
  Widget _buildFlatList(List<ExerciseHistory> filteredHistories) {
    final histories = filteredHistories;

    if (histories.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Padding(
          key: ValueKey(history.exerciseName),
          padding: const EdgeInsets.only(bottom: 8),
          child: _ExerciseHistoryCard(history: history),
        );
      },
    );
  }

  /// Build timeline list of exercises grouped by date periods
  ///
  /// Groups exercises by date periods (Today, Yesterday, This Week, This Month, Older)
  Widget _buildTimelineList(List<ExerciseHistory> filteredHistories) {
    final grouped = _groupByDatePeriod(filteredHistories);

    if (grouped.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final periodLabel = entry.key;
        final exercises = entry.value;

        return Padding(
          key: ValueKey(periodLabel),
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              initiallyExpanded: index == 0, // Expand first section (today/most recent)
              leading: SemanticIcon(
                icon: AppIcons.calendar,
                semanticLabel: periodLabel,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              title: Text(
                periodLabel,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              subtitle: Text(
                '${exercises.length} ${exercises.length == 1 ? context.l10n.exercise : context.l10n.exercises}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              children: exercises
                  .map((history) => _ExerciseHistoryCard(history: history))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  /// Group exercises by date period
  Map<String, List<ExerciseHistory>> _groupByDatePeriod(
      List<ExerciseHistory> histories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    final grouped = <String, List<ExerciseHistory>>{
      context.l10n.today: [],
      context.l10n.yesterday: [],
      context.l10n.thisWeek: [],
      context.l10n.thisMonth: [],
      context.l10n.older: [],
    };

    for (final history in histories) {
      // Get most recent session date
      if (history.sessionsSortedByDate.isEmpty) continue;
      final lastSessionDate = history.sessionsSortedByDate.first.date;
      final sessionDay =
          DateTime(lastSessionDate.year, lastSessionDate.month, lastSessionDate.day);

      if (sessionDay == today) {
        grouped[context.l10n.today]!.add(history);
      } else if (sessionDay == yesterday) {
        grouped[context.l10n.yesterday]!.add(history);
      } else if (sessionDay.isAfter(weekAgo)) {
        grouped[context.l10n.thisWeek]!.add(history);
      } else if (sessionDay.isAfter(monthAgo)) {
        grouped[context.l10n.thisMonth]!.add(history);
      } else {
        grouped[context.l10n.older]!.add(history);
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}

/// Hybrid Motivator Card - Combines gamification + analytics
/// Shows: Streak, Weekly Goal, Volume Trend, Recent PRs
class _QuickStatsSummary extends StatelessWidget {
  const _QuickStatsSummary({required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  /// Calculate current streak (consecutive days with workouts)
  int _calculateStreak() {
    if (exerciseHistories.isEmpty) return 0;

    // Get all unique workout dates (across all exercises)
    final allDates = <DateTime>{};
    for (final history in exerciseHistories) {
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

  /// Calculate workouts this week (last 7 days including today)
  int _calculateWeeklyWorkouts() {
    final now = DateTime.now();
    // Use date-only comparison (no time component) for consistency
    final today = DateTime(now.year, now.month, now.day);
    // 6 days back = 7 day range (today + 6 previous days)
    final weekStart = today.subtract(const Duration(days: 6));

    final weeklyDates = <DateTime>{};
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        // Include if within [weekStart, today] inclusive
        if (!dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today)) {
          weeklyDates.add(dateOnly);
        }
      }
    }

    return weeklyDates.length;
  }

  /// Calculate average weekly volume progression across all exercises
  double _calculateVolumeProgression() {
    if (exerciseHistories.isEmpty) return 0;

    final progressions = exerciseHistories
        .map((h) => h.weeklyVolumeProgression)
        .where((p) => p != 0) // Exclude exercises with no baseline
        .toList();

    if (progressions.isEmpty) return 0;

    final avgProgression =
        progressions.reduce((a, b) => a + b) / progressions.length;
    return avgProgression;
  }

  /// Calculate recent PRs (last 7 days including today)
  int _calculateRecentPRs() {
    final now = DateTime.now();
    // Use date-only comparison (no time component) for consistency
    final today = DateTime(now.year, now.month, now.day);
    // 6 days back = 7 day range (today + 6 previous days)
    final weekStart = today.subtract(const Duration(days: 6));

    int prCount = 0;

    for (final history in exerciseHistories) {
      if (history.sessions.isEmpty) continue;

      // Find personal record (highest 1RM)
      final pr = history.personalRecord;

      // Check if any session in last 7 days achieved this PR
      for (final session in history.sessions) {
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!sessionDate.isBefore(weekStart) &&
            !sessionDate.isAfter(today) &&
            session.highestEstimated1RM >= pr * 0.99) {
          // Within 1% of PR (accounts for rounding)
          prCount++;
          break; // Count once per exercise
        }
      }
    }

    return prCount;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak();
    final weeklyWorkouts = _calculateWeeklyWorkouts();
    final volumeProgression = _calculateVolumeProgression();
    final recentPRs = _calculateRecentPRs();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primaryContainer,
            context.colors.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.streak,
              label: 'Streak',
              value: '$streak',
              suffix: streak == 1 ? 'giorno' : 'giorni',
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => StreakModal(
                      exerciseHistories: exerciseHistories,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // Volume
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.trendUp,
              label: 'Volume',
              value: volumeProgression >= 0
                  ? '+${volumeProgression.toStringAsFixed(0)}'
                  : volumeProgression.toStringAsFixed(0),
              suffix: '%',
              color: context.colors.onPrimaryContainer,
              trend: volumeProgression >= 0 ? 'up' : 'down',
              trendColor: volumeProgression >= 0
                  ? context.colors.success
                  : context.colors.error,
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => VolumeModal(
                      exerciseHistories: exerciseHistories,
                      volumeProgression: volumeProgression,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // Settimana
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.calendar,
              label: 'Settimana',
              value: '$weeklyWorkouts',
              suffix: '/5 allenamenti',
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => WeeklyModal(
                      exerciseHistories: exerciseHistories,
                      weeklyWorkouts: weeklyWorkouts,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // PR
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.achievement,
              label: 'PR (7 giorni)',
              value: '$recentPRs',
              suffix: recentPRs == 1 ? 'nuovo' : 'nuovi',
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => PRModal(
                      exerciseHistories: exerciseHistories,
                      recentPRCount: recentPRs,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated counter widget - Smoothly animates from 0 to target value
/// **Used in**: Quick Stats card for dynamic number animation
class _AnimatedCounter extends StatefulWidget {
  const _AnimatedCounter({
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  final String value; // Can be "123", "12.5t", etc.
  final TextStyle? style;
  final Duration duration;

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _targetValue = 0;
  String _suffix = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _parseValueAndAnimate();
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseValueAndAnimate();
    }
  }

  void _parseValueAndAnimate() {
    // Extract number and suffix (e.g., "12.5t" -> 12.5 + "t")
    final match = RegExp(r'([\d.]+)(.*)').firstMatch(widget.value);
    if (match != null) {
      _targetValue = double.tryParse(match.group(1)!) ?? 0;
      _suffix = match.group(2)!;

      _animation = Tween<double>(
        begin: 0,
        end: _targetValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Format based on suffix
        final currentValue = _animation.value;
        final formattedValue = _suffix == 't'
            ? currentValue.toStringAsFixed(1) // Decimal for tons
            : currentValue.toInt().toString(); // Integer for counts

        return Text(
          '$formattedValue$_suffix',
          style: widget.style,
        );
      },
    );
  }
}

/// Hybrid stat item - compact horizontal layout with optional trend indicator
class _HybridStatItem extends StatelessWidget {
  const _HybridStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.trend,
    this.trendColor,
    this.onTap, // NEW: Tap callback for interactive stats
  });

  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final Color color;
  final String? trend; // 'up', 'down', or null
  final Color? trendColor;
  final VoidCallback? onTap; // NEW: Optional tap callback

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Label
          Row(
            children: [
              SemanticIcon(
                icon: icon,
                semanticLabel: label,
                size: AppIconSize.tiny,
                color: color.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Trend indicator (if provided)
              if (trend != null && trendColor != null)
                SemanticIcon(
                  icon: trend == 'up' ? AppIcons.trendingUp : AppIcons.trendingDown,
                  semanticLabel: trend == 'up' ? 'Aumentato' : 'Diminuito',
                  size: AppIconSize.tiny,
                  color: trendColor!,
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Value + Suffix
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: context.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  suffix,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

/// Exercise history card - shows exercise name, PR, sessions count
class _ExerciseHistoryCard extends ConsumerWidget{
  const _ExerciseHistoryCard({required this.history});

  final ExerciseHistory history;

  /// Show muscle group correction bottom sheet
  Future<void> _showCorrectionSheet(BuildContext context) async {
    // Show bottom sheet
    final correction = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MuscleGroupCorrectionSheet(
          exerciseName: history.exerciseName,
          currentMuscleGroup: history.muscleGroup,
        ),
      ),
    );

    // If correction was saved, ask if user wants to report to admin
    if (correction != null && context.mounted) {
      final submitted = await showDialog<bool>(
        context: context,
        builder: (_) => FeedbackSubmissionDialog(
          correction: correction,
        ),
      );

      // Refresh analytics data if correction was made
      // (local correction is already applied via Hive, just need UI refresh)
      if (context.mounted && (correction != null || submitted == true)) {
        // TODO: Trigger analytics refresh if needed
        // For now, the expansion state provider will handle UI updates
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pr = history.personalRecord;
    final sessionsCount = history.sessions.length;
    final weeklyProgression = history.weeklyVolumeProgression;

    // Use select() to only rebuild when THIS exercise's favorite status changes
    // High-impact: _ExerciseHistoryCard is rendered N times in list
    final isFavorite = ref.watch(
      favoriteExercisesNotifierProvider.select(
        (favorites) => favorites.contains(history.exerciseName),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to Exercise Detail Screen using named route
          context.pushNamed(
            AppRoutes.analyticsExerciseDetailName,
            pathParameters: {
              'exerciseName': Uri.encodeComponent(history.exerciseName),
            },
          );
        },
        onLongPress: () {
          // Show correction sheet on long press
          HapticFeedback.mediumImpact();
          _showCorrectionSheet(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name + muscle group + favorite toggle (Task 5.2)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.exerciseName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          history.muscleGroup.toUpperCase(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite star icon toggle (Task 5.2)
                  IconButton(
                    icon: SemanticIcon.button(
                      icon: isFavorite
                          ? AppIcons.star
                          : AppIcons.starOutline,
                      semanticLabel: isFavorite
                          ? context.l10n.removeFromFavorites
                          : context.l10n.addToFavorites,
                    ),
                    color: isFavorite
                        ? context.iconWarning  // Yellow/warning color for favorites
                        : context.colors.onSurfaceVariant,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoriteExercisesNotifierProvider.notifier)
                          .toggleFavorite(history.exerciseName);
                    },
                    tooltip: isFavorite
                        ? context.l10n.removeFromFavorites
                        : context.l10n.addToFavorites,
                  ),
                  SemanticIcon(
                    icon: AppIcons.chevronRight,
                    semanticLabel: context.l10n.viewDetails,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  // PR
                  Expanded(
                    child: _StatChip(
                      icon: AppIcons.achievement,
                      label: 'PR', // Short for Personal Record
                      value: '${pr.toStringAsFixed(1)} kg',
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sessions count
                  Expanded(
                    child: _StatChip(
                      icon: AppIcons.calendar,
                      label: context.l10n.workouts, // Using existing key
                      value: '$sessionsCount',
                      color: context.colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Weekly progression
                  Expanded(
                    child: _StatChip(
                      icon: weeklyProgression >= 0
                          ? AppIcons.trendingUp
                          : AppIcons.trendingDown,
                      label: context.l10n.progress, // Using existing key
                      value: '${weeklyProgression.toStringAsFixed(1)}%',
                      color: weeklyProgression >= 0
                          ? context.colors.success
                          : context.colors.error,
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

/// Stat chip widget - small colored box with icon and value
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: '$label: $value',
            size: AppIconSize.small,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Empty/Error/Loading States
class _NotAuthenticatedView extends StatelessWidget {
  const _NotAuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.lock,
            semanticLabel: context.l10n.pleaseLoginToViewAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.pleaseLoginToViewAnalytics,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonLoadingView();
  }
}

/// Skeleton loading view with shimmer effect for better UX
class _SkeletonLoadingView extends StatelessWidget {
  const _SkeletonLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Search bar skeleton
        Padding(
          padding: EdgeInsets.all(16),
          child: _ShimmerBox(
            width: double.infinity,
            height: 56,
            borderRadius: 12,
          ),
        ),

        // Exercise cards skeletons
        Expanded(
          child: _SkeletonList(),
        ),
      ],
    );
  }
}

/// Skeleton list with multiple cards
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) => const _SkeletonExerciseCard(),
    );
  }
}

/// Skeleton exercise card
class _SkeletonExerciseCard extends StatelessWidget {
  const _SkeletonExerciseCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name skeleton
            _ShimmerBox(width: 200, height: 20, borderRadius: 4),
            SizedBox(height: 8),
            // Muscle group skeleton
            _ShimmerBox(width: 100, height: 14, borderRadius: 4),
            SizedBox(height: 16),

            // Stats row skeleton
            Row(
              children: [
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer box widget for skeleton loading
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                context.colors.surfaceContainerHighest,
                context.colors.surfaceContainerHigh,
                context.colors.surfaceContainerHighest,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.errorLoadingAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.workout,
            semanticLabel: context.l10n.noWorkoutDataYet,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.noWorkoutDataYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.workoutPath),
            icon: SemanticIcon.button(
              icon: AppIcons.play,
              semanticLabel: context.l10n.startYourFirstWorkout,
            ),
            label: Text(context.l10n.startYourFirstWorkout),
          ),
        ],
      ),
    );
  }
}

/// Sort & Filter chips widget - Horizontal row of filter options
/// **Enhanced with live counters** showing number of exercises per filter
class _SortFilterChips extends ConsumerWidget {
  const _SortFilterChips({
    required this.sortBy,
    required this.filterCounts,
    required this.onSortChanged,
  });

  final SortBy sortBy;
  final Map<SortBy, int> filterCounts;
  final ValueChanged<SortBy> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            context.colors.surface,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Scrollable filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Favorites ⭐ filter (Task 5.1)
                  _FilterChipItem(
                    label: context.l10n.favorites,
                    icon: AppIcons.star,
                    count: filterCounts[SortBy.favorites] ?? 0,
                    selected: sortBy == SortBy.favorites,
                    onSelected: () => onSortChanged(SortBy.favorites),
                  ),
                  const SizedBox(width: 8),

                  // Most Used 🔥 filter (Task 5.1)
                  _FilterChipItem(
                    label: context.l10n.mostUsed,
                    icon: AppIcons.barChart,
                    count: filterCounts[SortBy.mostUsed] ?? 0,
                    selected: sortBy == SortBy.mostUsed,
                    onSelected: () => onSortChanged(SortBy.mostUsed),
                  ),
                  const SizedBox(width: 8),

                  // Recent 📅 filter (Task 5.1)
                  _FilterChipItem(
                    label: context.l10n.recent,
                    icon: AppIcons.clock,
                    count: filterCounts[SortBy.recent] ?? 0,
                    selected: sortBy == SortBy.recent,
                    onSelected: () => onSortChanged(SortBy.recent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual filter chip item with live counter and scale animation
class _FilterChipItem extends StatefulWidget {
  const _FilterChipItem({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Trigger scale animation
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: widget.icon,
              semanticLabel: widget.label,
              size: AppIconSize.tiny,
              color: widget.selected
                  ? context.colors.onPrimary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(widget.label),
            const SizedBox(width: 6),
            // Live counter badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.selected
                    ? context.colors.onPrimary.withValues(alpha: 0.2)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.count}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: widget.selected
                      ? context.colors.onPrimary
                      : context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        selected: widget.selected,
        onSelected: (_) => _handleTap(),
        selectedColor: context.colors.primary,
        checkmarkColor: context.colors.onPrimary,
        labelStyle: context.textTheme.bodyMedium?.copyWith(
          color: widget.selected
              ? context.colors.onPrimary
              : context.colors.onSurface,
          fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Pro Insights Section - Premium analytics with REAL user data
/// Shows user's actual stats blurred for FREE users, unlocked for PREMIUM
/// Uses benefit-driven copy and single prominent CTA
class _ProInsightsSection extends ConsumerWidget {
  const _ProInsightsSection({required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;

    // Calculate REAL stats from user data
    final stats = _calculateRealStats();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with PRO badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // PRO badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.premium,
                        size: AppIconSize.tiny,
                        color: colorScheme.onTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.proInsights,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.proInsightsSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal scrolling cards with REAL data
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Card 1: Rep Zone Distribution (REAL data)
                _ProInsightCard(
                  icon: AppIcons.barChart,
                  title: l10n.seeWhichRepZones,
                  isPremium: isPremium,
                  onTap: () => _showUpgradeDialog(context),
                  child: _RealRepZoneChart(
                    strengthPercent: stats.strengthPercent,
                    hypertrophyPercent: stats.hypertrophyPercent,
                    endurancePercent: stats.endurancePercent,
                    l10n: l10n,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),

                // Card 2: Volume Trend (REAL data)
                _ProInsightCard(
                  icon: AppIcons.trendUp,
                  title: l10n.watchVolumeGrow,
                  isPremium: isPremium,
                  onTap: () => _showUpgradeDialog(context),
                  child: _RealVolumeChart(
                    weeklyVolumes: stats.weeklyVolumes,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),

                // Card 3: Muscle Balance (REAL data)
                _ProInsightCard(
                  icon: AppIcons.accessibility,
                  title: l10n.analyzeBalance,
                  isPremium: isPremium,
                  onTap: () => _showUpgradeDialog(context),
                  child: _RealMuscleChips(
                    topMuscles: stats.topMuscles,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),

          // Single CTA button for non-premium users
          if (!isPremium) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showUpgradeDialog(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(AppIcons.premium, size: AppIconSize.small),
                  label: Text(
                    l10n.upgradeToPro,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Calculate REAL stats from user's exercise history
  _ProInsightStats _calculateRealStats() {
    if (exerciseHistories.isEmpty) {
      return _ProInsightStats.empty();
    }

    // Calculate rep zone distribution from all sessions
    int strengthSets = 0; // 1-5 reps
    int hypertrophySets = 0; // 6-12 reps
    int enduranceSets = 0; // 13+ reps

    // Calculate weekly volumes (last 4 weeks)
    final weeklyVolumes = <double>[0, 0, 0, 0];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Collect muscle groups
    final muscleCount = <String, int>{};

    for (final history in exerciseHistories) {
      // Count muscle groups
      final muscle = history.muscleGroup;
      if (muscle.isNotEmpty) {
        muscleCount[muscle] = (muscleCount[muscle] ?? 0) + history.sessions.length;
      }

      for (final session in history.sessions) {
        // Rep zone distribution
        for (final set in session.sets) {
          final reps = set.reps;
          if (reps <= 5) {
            strengthSets++;
          } else if (reps <= 12) {
            hypertrophySets++;
          } else {
            enduranceSets++;
          }
        }

        // Weekly volume (simplified: count sessions per week)
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        final daysAgo = today.difference(sessionDate).inDays;

        if (daysAgo < 7) {
          weeklyVolumes[0] += session.totalVolume;
        } else if (daysAgo < 14) {
          weeklyVolumes[1] += session.totalVolume;
        } else if (daysAgo < 21) {
          weeklyVolumes[2] += session.totalVolume;
        } else if (daysAgo < 28) {
          weeklyVolumes[3] += session.totalVolume;
        }
      }
    }

    // Calculate percentages
    final totalSets = strengthSets + hypertrophySets + enduranceSets;
    final strengthPercent = totalSets > 0 ? strengthSets / totalSets : 0.0;
    final hypertrophyPercent = totalSets > 0 ? hypertrophySets / totalSets : 0.0;
    final endurancePercent = totalSets > 0 ? enduranceSets / totalSets : 0.0;

    // Get top 3 muscles
    final sortedMuscles = muscleCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMuscles = sortedMuscles.take(3).map((e) => e.key).toList();

    return _ProInsightStats(
      strengthPercent: strengthPercent,
      hypertrophyPercent: hypertrophyPercent,
      endurancePercent: endurancePercent,
      weeklyVolumes: weeklyVolumes.reversed.toList(), // Oldest first
      topMuscles: topMuscles,
    );
  }

  /// Show upgrade dialog with preview
  void _showUpgradeDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ProUpgradeDialog(),
    );
  }
}

/// Premium upgrade dialog with hardcoded preview data
class _ProUpgradeDialog extends StatelessWidget {
  const _ProUpgradeDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Premium icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.tertiary,
                      colorScheme.tertiary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.tertiary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  AppIcons.premium,
                  size: AppIconSize.xlarge,
                  color: colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                l10n.unlockProInsights,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                l10n.proInsightsDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Preview cards with HARDCODED demo data
              _buildPreviewCard(
                context: context,
                icon: AppIcons.barChart,
                title: l10n.repZoneAnalysis,
                description: l10n.repZoneDescription,
                child: _DemoRepZoneChart(l10n: l10n, colorScheme: colorScheme),
              ),
              const SizedBox(height: 12),

              _buildPreviewCard(
                context: context,
                icon: AppIcons.analytics,
                title: l10n.volumeProgression,
                description: l10n.volumeProgressionDescription,
                child: _DemoVolumeChart(colorScheme: colorScheme),
              ),
              const SizedBox(height: 12),

              _buildPreviewCard(
                context: context,
                icon: AppIcons.workout,
                title: l10n.muscleBalance,
                description: l10n.muscleBalanceDescription,
                child: _DemoMuscleChips(colorScheme: colorScheme),
              ),
              const SizedBox(height: 32),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                    // TODO: Navigate to actual subscription flow
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(AppIcons.premium, size: AppIconSize.small),
                  label: Text(
                    l10n.upgradeToPro,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Maybe Later
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.maybeLater,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.medium, color: colorScheme.tertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Demo rep zone chart with hardcoded data
class _DemoRepZoneChart extends StatelessWidget {
  const _DemoRepZoneChart({
    required this.l10n,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo data - shows typical bodybuilder distribution
    const strengthPercent = 0.25;
    const hypertrophyPercent = 0.55;
    const endurancePercent = 0.20;

    return Column(
      children: [
        _buildBar(l10n.strengthZone, strengthPercent, Colors.red.shade400),
        const SizedBox(height: 8),
        _buildBar(l10n.hypertrophyZone, hypertrophyPercent, Colors.orange.shade400),
        const SizedBox(height: 8),
        _buildBar(l10n.enduranceZone, endurancePercent, Colors.green.shade400),
      ],
    );
  }

  Widget _buildBar(String label, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${(percent * 100).toInt()}%',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Demo volume chart with hardcoded trend data
class _DemoVolumeChart extends StatelessWidget {
  const _DemoVolumeChart({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo data - 4 weeks of increasing volume
    final demoVolumes = [12500.0, 14200.0, 15800.0, 17500.0];
    final maxVolume = demoVolumes.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 60,
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _DemoVolumeChartPainter(
          volumes: demoVolumes,
          maxVolume: maxVolume,
          lineColor: colorScheme.tertiary,
          fillColor: colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

/// Demo volume chart painter
class _DemoVolumeChartPainter extends CustomPainter {
  _DemoVolumeChartPainter({
    required this.volumes,
    required this.maxVolume,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> volumes;
  final double maxVolume;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (volumes.isEmpty || maxVolume == 0) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < volumes.length; i++) {
      final x = (i / (volumes.length - 1)) * size.width;
      final y = size.height - (volumes[i] / maxVolume) * size.height * 0.8;
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DemoVolumeChartPainter oldDelegate) => false;
}

/// Demo muscle chips with hardcoded data
class _DemoMuscleChips extends StatelessWidget {
  const _DemoMuscleChips({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo muscles - typical push/pull/legs focus
    const demoMuscles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: demoMuscles.map((muscle) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            muscle,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.tertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Stats holder for Pro Insights
class _ProInsightStats {
  const _ProInsightStats({
    required this.strengthPercent,
    required this.hypertrophyPercent,
    required this.endurancePercent,
    required this.weeklyVolumes,
    required this.topMuscles,
  });

  factory _ProInsightStats.empty() => const _ProInsightStats(
        strengthPercent: 0.33,
        hypertrophyPercent: 0.34,
        endurancePercent: 0.33,
        weeklyVolumes: [0, 0, 0, 0],
        topMuscles: ['Chest', 'Back', 'Legs'],
      );

  final double strengthPercent;
  final double hypertrophyPercent;
  final double endurancePercent;
  final List<double> weeklyVolumes;
  final List<String> topMuscles;
}

/// Single insight card with blur effect for non-premium
class _ProInsightCard extends StatelessWidget {
  const _ProInsightCard({
    required this.icon,
    required this.title,
    required this.isPremium,
    required this.onTap,
    required this.child,
  });

  final IconData icon;
  final String title;
  final bool isPremium;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isPremium ? null : onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Chart/data visualization
                Expanded(child: child),
              ],
            ),

            // Blur overlay for non-premium
            if (!isPremium)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: ColoredBox(
                      color: colorScheme.surface.withValues(alpha: 0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.lock,
                                size: AppIconSize.tiny,
                                color: colorScheme.onTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onTertiary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Real rep zone distribution chart using actual user data
class _RealRepZoneChart extends StatelessWidget {
  const _RealRepZoneChart({
    required this.strengthPercent,
    required this.hypertrophyPercent,
    required this.endurancePercent,
    required this.l10n,
    required this.colorScheme,
  });

  final double strengthPercent;
  final double hypertrophyPercent;
  final double endurancePercent;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar('S', strengthPercent, colorScheme.error),
        _buildBar('H', hypertrophyPercent, colorScheme.primary),
        _buildBar('E', endurancePercent, colorScheme.tertiary),
      ],
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 30 * value + 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Real volume chart using actual user weekly data
class _RealVolumeChart extends StatelessWidget {
  const _RealVolumeChart({
    required this.weeklyVolumes,
    required this.colorScheme,
  });

  final List<double> weeklyVolumes;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _RealVolumeChartPainter(
        volumes: weeklyVolumes,
        color: colorScheme.primary,
      ),
    );
  }
}

/// Custom painter for real volume trend
class _RealVolumeChartPainter extends CustomPainter {
  _RealVolumeChartPainter({
    required this.volumes,
    required this.color,
  });

  final List<double> volumes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (volumes.isEmpty || volumes.every((v) => v == 0)) {
      // Draw placeholder line
      final paint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
    if (maxVolume == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    for (var i = 0; i < volumes.length; i++) {
      final x = (size.width / (volumes.length - 1)) * i;
      final y = size.height - (volumes[i] / maxVolume * size.height * 0.8);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RealVolumeChartPainter oldDelegate) =>
      volumes != oldDelegate.volumes || color != oldDelegate.color;
}

/// Real muscle distribution chips using actual user data
class _RealMuscleChips extends StatelessWidget {
  const _RealMuscleChips({
    required this.topMuscles,
    required this.colorScheme,
  });

  final List<String> topMuscles;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: topMuscles.asMap().entries.map((entry) {
        final index = entry.key;
        final muscle = entry.value;
        final color = colors[index % colors.length];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            muscle,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
