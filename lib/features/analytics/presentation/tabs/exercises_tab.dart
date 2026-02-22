import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/favorite_exercises_notifier.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_avatar.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/feedback_submission_dialog.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/mini_sparkline.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_group_correction_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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

/// Exercises tab — shows exercise list with search, filters, and sort
///
/// Receives exerciseHistories and userId from the parent Statistics page.
/// Search bar is always visible (no toggle needed since this IS the exercises view).
class ExercisesTab extends ConsumerStatefulWidget {
  const ExercisesTab({
    required this.exerciseHistories,
    required this.userId,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final String userId;

  @override
  ConsumerState<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends ConsumerState<ExercisesTab>
    with SafeSetStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  SortBy _sortBy = SortBy.mostUsed; // Default: sort by most used

  /// Debounced search handler - waits 300ms after user stops typing
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery.value = query; // ValueNotifier update (no setState needed)
    });
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
    // Watch favorites from provider
    final favorites = ref.watch(favoriteExercisesNotifierProvider);

    return {
      // Favorites filter: Count exercises marked as favorite
      SortBy.favorites: widget.exerciseHistories
          .where((h) => favorites.contains(h.exerciseName))
          .length,

      // Most Used filter: Total number of exercises
      SortBy.mostUsed: widget.exerciseHistories.length,

      // Recent filter: Exercises with at least 1 workout session
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

    // Watch favorites from provider
    final favorites = ref.watch(favoriteExercisesNotifierProvider);

    // Step 2: Filter/Sort by selected criteria
    switch (_sortBy) {
      case SortBy.favorites:
        // Filter favorites, then sort alphabetically
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
      return EnhancedEmptyState(
        type: EmptyStateType.motivational,
        icon: AppIcons.barChart,
        title: context.l10n.noWorkoutDataYet,
        description: context.l10n.completeWorkoutsToSeeAnalytics,
        motivationalQuote: context.l10n.analyticsEmptyQuote,
        proTip: context.l10n.analyticsEmptyTip,
        primaryActionLabel: context.l10n.startYourFirstWorkout,
        onPrimaryAction: () => context.go(AppRoutes.workoutPath),
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, searchQuery, _) {
        final filteredHistories = _getFilteredHistories(searchQuery);

        return Column(
          children: [
            // Search bar (always visible in exercises tab)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: TextField(
                controller: _searchController,
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
                            _searchQuery.value = '';
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Sort & Filter chips with live counters
            _SortFilterChips(
              sortBy: _sortBy,
              filterCounts: _filterCounts,
              onSortChanged: (newSort) =>
                  safeSetState(() => _sortBy = newSort),
            ),

            // History limit banner for free users
            if (!ref.watch(hasUnlimitedHistoryProvider))
              _HistoryLimitBanner(),

            // Results list
            Expanded(
              child: filteredHistories.isEmpty
                  ? _buildEmptyFilteredState(context, searchQuery)
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
                      child: _buildFlatList(filteredHistories),
                    ),
            ),
          ],
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
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs + context.tabBarInset,
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

  /// Build appropriate empty state based on filter/search context
  Widget _buildEmptyFilteredState(BuildContext context, String searchQuery) {
    // Case 1: Search query with no results
    if (searchQuery.isNotEmpty) {
      return EnhancedEmptyState(
        type: EmptyStateType.info,
        icon: AppIcons.search,
        title: context.l10n.noResultsFound,
        description: context.l10n.analyticsSearchEmptyDescription,
        secondaryActionLabel: context.l10n.clearSearch,
        onSecondaryAction: () {
          _searchController.clear();
          _searchQuery.value = '';
          HapticFeedback.lightImpact();
        },
      );
    }

    // Case 2: Favorites filter with no favorites
    if (_sortBy == SortBy.favorites) {
      return EnhancedEmptyState(
        type: EmptyStateType.info,
        icon: AppIcons.starOutline,
        title: context.l10n.analyticsFavoritesEmptyTitle,
        description: context.l10n.analyticsFavoritesEmptyDescription,
        proTip: context.l10n.analyticsFavoritesEmptyTip,
      );
    }

    // Default: Generic no results
    return EnhancedEmptyState(
      type: EmptyStateType.info,
      icon: AppIcons.barChart,
      title: context.l10n.noResultsFound,
      description: context.l10n.tryAnotherSearch,
    );
  }
}

// ---------------------------------------------------------------------------
// Sort & Filter Chips
// ---------------------------------------------------------------------------

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
                  // Favorites filter
                  _FilterChipItem(
                    label: context.l10n.favorites,
                    icon: AppIcons.star,
                    count: filterCounts[SortBy.favorites] ?? 0,
                    selected: sortBy == SortBy.favorites,
                    onSelected: () => onSortChanged(SortBy.favorites),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // Most Used filter
                  _FilterChipItem(
                    label: context.l10n.mostUsed,
                    icon: AppIcons.barChart,
                    count: filterCounts[SortBy.mostUsed] ?? 0,
                    selected: sortBy == SortBy.mostUsed,
                    onSelected: () => onSortChanged(SortBy.mostUsed),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // Recent filter
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

// ---------------------------------------------------------------------------
// Exercise History Card
// ---------------------------------------------------------------------------

/// Contextual progression display info
class _ProgressionInfo {
  const _ProgressionInfo({
    required this.label,
    required this.color,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;
}

/// Exercise history card - shows exercise name, PR, sessions count
class _ExerciseHistoryCard extends ConsumerWidget {
  const _ExerciseHistoryCard({required this.history});

  final ExerciseHistory history;

  /// Determine contextual progression info based on session count and delta
  _ProgressionInfo _getProgressionInfo(
    BuildContext context,
    int sessionsCount,
    double weeklyProgression,
  ) {
    // Check if no recent session (>14 days)
    if (history.sessions.isNotEmpty) {
      final lastSessionDate = history.sessions
          .map((s) => s.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final daysSinceLastSession =
          DateTime.now().difference(lastSessionDate).inDays;
      if (daysSinceLastSession > 14) {
        return _ProgressionInfo(
          label: context.l10n.progressionResume,
          color: context.colors.onSurfaceVariant,
          icon: AppIcons.clock,
        );
      }
    }

    // Only 1 session -> "New!" badge
    if (sessionsCount <= 1) {
      return _ProgressionInfo(
        label: context.l10n.progressionNew,
        color: context.colors.primary,
        icon: AppIcons.celebration,
      );
    }

    // 2+ sessions with actual progression
    if (weeklyProgression > 0) {
      return _ProgressionInfo(
        label: context.l10n.progressionUp(weeklyProgression.toStringAsFixed(0)),
        color: context.colors.success,
        icon: AppIcons.trendingUp,
      );
    } else if (weeklyProgression < 0) {
      return _ProgressionInfo(
        label: context.l10n.progressionDown(
          weeklyProgression.abs().toStringAsFixed(0),
        ),
        color: context.colors.warning,
        icon: AppIcons.trendingDown,
      );
    }

    // delta == 0 -> "Stable"
    return _ProgressionInfo(
      label: context.l10n.progressionStable,
      color: context.colors.onSurfaceVariant,
      icon: AppIcons.trendFlat,
    );
  }

  /// Extract weight progression data points for sparkline (last 12 sessions)
  List<double> _extractWeightProgression() {
    if (history.sessions.isEmpty) return [];

    // Sort sessions by date (oldest first)
    final sortedSessions = List.of(history.sessions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Take last 12 sessions
    final recentSessions = sortedSessions.length > 12
        ? sortedSessions.sublist(sortedSessions.length - 12)
        : sortedSessions;

    // Extract average weight per session
    return recentSessions.map((session) {
      final sets = session.sets;
      if (sets.isEmpty) return 0.0;

      // Calculate average weight across sets
      final totalWeight = sets.fold<double>(
        0.0,
        (sum, set) => sum + set.weight,
      );
      return totalWeight / sets.length;
    }).toList();
  }

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
      if (context.mounted && (correction != null || submitted == true)) {
        // Local correction is already applied via Hive, just need UI refresh
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pr = history.personalRecord;
    final sessionsCount = history.sessions.length;
    final weeklyProgression = history.weeklyVolumeProgression;

    // Use select() to only rebuild when THIS exercise's favorite status changes
    final isFavorite = ref.watch(
      favoriteExercisesNotifierProvider.select(
        (favorites) => favorites.contains(history.exerciseName),
      ),
    );

    // Determine contextual progression display
    final progressionInfo = _getProgressionInfo(context, sessionsCount, weeklyProgression);

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
                  // Sparkline (compact trend visualization)
                  MiniSparkline(
                    dataPoints: _extractWeightProgression(),
                    isPositiveTrend: weeklyProgression >= 0,
                    width: 60,
                    height: 24,
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
                  // Contextual progression display
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (progressionInfo.icon != null) ...[
                        SemanticIcon(
                          icon: progressionInfo.icon!,
                          semanticLabel: progressionInfo.label,
                          size: AppIconSize.tiny,
                          color: progressionInfo.color,
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        progressionInfo.label,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: progressionInfo.color,
                        ),
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

// ---------------------------------------------------------------------------
// History Limit Banner
// ---------------------------------------------------------------------------

/// Banner informing free users that analytics data is limited to 3 months
class _HistoryLimitBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed(AppRoutes.premiumName);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.info,
              color: colorScheme.tertiary,
              size: AppIconSize.small,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.historyLimitedTo3Months,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.unlockFullHistory,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
