import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/favorite_exercises_notifier.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
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
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pro_insights_badge.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_avatar.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

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
final searchBarVisibilityProvider = createStateProviderAutoDispose<bool>(
  false,
);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statistics),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        // No leading back button - this is a tab root
        actions: [
          // Search toggle button (Task: New UX)
          Consumer(
            builder: (context, ref, child) {
              final isSearchVisible = ref.watch(searchBarVisibilityProvider);

              return IconButton(
                icon: SemanticIcon.button(
                  icon: isSearchVisible ? AppIcons.close : AppIcons.search,
                  semanticLabel: isSearchVisible
                      ? context.l10n.close
                      : context.l10n.search,
                ),
                tooltip: isSearchVisible
                    ? context.l10n.close
                    : context.l10n.search,
                onPressed: () {
                  // Toggle search bar visibility
                  ref.read(searchBarVisibilityProvider.notifier).state =
                      !isSearchVisible;

                  // Haptic feedback
                  HapticFeedback.lightImpact();
                },
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
  static const double _scrollThreshold =
      100.0; // Minimum scroll to trigger (increased for stability)

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
    _scrollController.removeListener(_onScroll);
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
                      ? _QuickStatsSummary(
                          exerciseHistories: widget.exerciseHistories,
                        )
                      : const SizedBox.shrink(),
                ),

                // Search bar (conditional with slide animation + scroll-away)
                Consumer(
                  builder: (context, ref, child) {
                    final isSearchVisible = ref.watch(
                      searchBarVisibilityProvider,
                    );

                    return AnimatedSize(
                      duration: AppAnimations.normal,
                      curve: AppAnimations.decelerate,
                      child: (_showBars && isSearchVisible)
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                0,
                                AppSpacing.md,
                                AppSpacing.xs,
                              ),
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
                                            _searchQuery.value =
                                                ''; // ValueNotifier update
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
                          onSortChanged: (newSort) =>
                              safeSetState(() => _sortBy = newSort),
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
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                context.l10n.noResultsFound,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
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
                            ref.invalidate(
                              exerciseHistoryStreamProvider(widget.userId),
                            );
                            // Wait for new data to be available
                            await ref.read(
                              exerciseHistoryStreamProvider(
                                widget.userId,
                              ).future,
                            );
                          },
                          // Use compact flat list - simplified UX (removed view mode toggle)
                          child: _buildFlatList(filteredHistories),
                        ),
                ),
              ],
            ); // Close Column
          }, // Close ValueListenableBuilder builder
        ), // Close ValueListenableBuilder
      ],
    ); // Close Stack
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Padding(
          key: ValueKey(history.exerciseName),
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _ExerciseHistoryCard(history: history),
        );
      },
    );
  }
}

/// Hybrid Motivator Card - Combines gamification + analytics
/// Shows: Streak, Weekly Goal, Volume Trend, Recent PRs
class _QuickStatsSummary extends ConsumerWidget {
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
    final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));

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
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _calculateStreak();
    final weeklyWorkouts = _calculateWeeklyWorkouts();
    final volumeProgression = _calculateVolumeProgression();
    final recentPRs = _calculateRecentPRs();
    final weeklyGoal = ref.watch(weeklyWorkoutGoalProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
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
              label: context.l10n.streak,
              value: '$streak',
              suffix: streak == 1 ? context.l10n.day : context.l10n.days,
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(context,
                  isScrollControlled: true,
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

          // Volume (vs last week comparison)
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.trendUp,
              label: '${context.l10n.volume} (${context.l10n.vsLastWeek})',
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
                ModalService.showSheet(context,
                  isScrollControlled: true,
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

          // Weekly (configurable goal)
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.calendar,
              label: context.l10n.weekly,
              value: '$weeklyWorkouts',
              suffix: '/$weeklyGoal ${context.l10n.workouts.toLowerCase()}',
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(context,
                  isScrollControlled: true,
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
              label: '${context.l10n.pr} (7 ${context.l10n.days})',
              value: '$recentPRs',
              suffix: recentPRs == 1
                  ? context.l10n.newSingular
                  : context.l10n.newPlural,
              color: context.colors.onPrimaryContainer,
              trend: null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(context,
                  isScrollControlled: true,
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
  const _AnimatedCounter({required this.value, required this.style});

  final String value; // Can be "123", "12.5t", etc.
  final TextStyle? style;

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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
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

      _animation = Tween<double>(begin: 0, end: _targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

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

        return Text('$formattedValue$_suffix', style: widget.style);
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
      color: context.colors.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
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
                  const SizedBox(width: AppSpacing.xxs),
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
                      icon: trend == 'up'
                          ? AppIcons.trendingUp
                          : AppIcons.trendingDown,
                      semanticLabel: trend == 'up' ? 'Aumentato' : 'Diminuito',
                      size: AppIconSize.tiny,
                      color: trendColor!,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),

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
class _ExerciseHistoryCard extends ConsumerWidget {
  const _ExerciseHistoryCard({required this.history});

  final ExerciseHistory history;

  /// Show muscle group correction bottom sheet
  Future<void> _showCorrectionSheet(BuildContext context) async {
    // Show bottom sheet
    final correction = await ModalService.showSheet(context,
      isScrollControlled: true,
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
        builder: (_) => FeedbackSubmissionDialog(correction: correction),
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

    // Determine progression color and icon
    final progressionColor = weeklyProgression >= 0
        ? context.colors.success
        : context.colors.error;
    final progressionIcon = weeklyProgression >= 0
        ? AppIcons.trendingUp
        : AppIcons.trendingDown;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Exercise avatar + name + stats inline
              Row(
                children: [
                  // Exercise avatar (40px for compact card)
                  ExerciseAvatar(
                    exerciseId: history.exerciseId,
                    exerciseName: history.exerciseName,
                    muscleGroup: history.muscleGroup,
                    size: 40,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Exercise name (flexible width)
                  Expanded(
                    child: Text(
                      history.exerciseName,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Favorite star (compact)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoriteExercisesNotifierProvider.notifier)
                          .toggleFavorite(history.exerciseName);
                    },
                    child: SemanticIcon(
                      icon: isFavorite ? AppIcons.star : AppIcons.starOutline,
                      semanticLabel: isFavorite
                          ? context.l10n.removeFromFavorites
                          : context.l10n.addToFavorites,
                      size: AppIconSize.small,
                      color: isFavorite
                          ? context.iconWarning
                          : context.colors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // PR value (compact, bold)
                  Text(
                    '${pr.toStringAsFixed(0)}kg',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Progression with icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${weeklyProgression >= 0 ? '+' : ''}${weeklyProgression.toStringAsFixed(0)}%',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: progressionColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SemanticIcon(
                        icon: progressionIcon,
                        semanticLabel: weeklyProgression >= 0
                            ? context.l10n.trendImproving
                            : context.l10n.trendDeclining,
                        size: AppIconSize.tiny,
                        color: progressionColor,
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Chevron
                  SemanticIcon(
                    icon: AppIcons.chevronRight,
                    semanticLabel: context.l10n.viewDetails,
                    size: AppIconSize.small,
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Row 2: Muscle group + sessions count
              Text(
                '${history.muscleGroup.toUpperCase()} · $sessionsCount ${context.l10n.sessions}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
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
          const SizedBox(height: AppSpacing.md),
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
          padding: EdgeInsets.all(AppSpacing.md),
          child: _ShimmerBox(
            width: double.infinity,
            height: 56,
            borderRadius: 12,
          ),
        ),

        // Exercise cards skeletons
        Expanded(child: _SkeletonList()),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name skeleton
            _ShimmerBox(width: 200, height: 20, borderRadius: 4),
            SizedBox(height: AppSpacing.xs),
            // Muscle group skeleton
            _ShimmerBox(width: 100, height: 14, borderRadius: 4),
            SizedBox(height: AppSpacing.md),

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
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
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

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
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
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.noWorkoutDataYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                  const SizedBox(width: AppSpacing.xs),

                  // Most Used 🔥 filter (Task 5.1)
                  _FilterChipItem(
                    label: context.l10n.mostUsed,
                    icon: AppIcons.barChart,
                    count: filterCounts[SortBy.mostUsed] ?? 0,
                    selected: sortBy == SortBy.mostUsed,
                    onSelected: () => onSortChanged(SortBy.mostUsed),
                  ),
                  const SizedBox(width: AppSpacing.xs),

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
