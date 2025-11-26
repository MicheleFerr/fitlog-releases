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
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_detail_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Database completo e modificabile per la cronologia degli allenamenti
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }


  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });

    // Update filter in provider
    final currentFilter = ref.read(workoutHistoryFilterProvider);
    ref.read(workoutHistoryFilterProvider.notifier).state =
        currentFilter.copyWith(searchQuery: query);
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
    final filteredWorkouts = ref.watch(filteredWorkoutsProvider);
    final syncStatus = ref.watch(currentSyncStatusProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.workoutDatabase),
        backgroundColor: Colors.transparent,
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

            // Subtitle
            if (!_isSearchActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.editableWorkoutHistory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Sync Status Indicator
            if (syncStatus == SyncStatus.initialSyncing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
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

            // Workouts List
            Expanded(
              child: workoutsAsync.when(
                loading: () => _buildLoadingState(l10n, colorScheme, theme),
                error: (error, stack) => _buildErrorState(l10n, colorScheme, error, theme),
                data: (workouts) => filteredWorkouts.isEmpty
                    ? _buildEmptyState(context, l10n, colorScheme, theme)
                    : ListView.builder(
                        key: const PageStorageKey('workout_history_list'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredWorkouts.length,
                        itemBuilder: (context, index) {
                          final workout = filteredWorkouts[index];
                          return _buildWorkoutCard(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingWorkouts,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, ColorScheme colorScheme, Object error, ThemeData theme) {
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme, ThemeData theme) {
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

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50).clamp(0, 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showWorkoutDetail(context, workout, l10n);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                          Text(
                            emoji,
                            style: theme.textTheme.titleLarge,
                          ),
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

                          // Duration
                          Text(
                            l10n.minWorkout(workout.duration.inMinutes),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                                      icon: AppIcons.edit,
                                      semanticLabel: l10n.editWorkout,
                                      size: AppIconSize.small,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(l10n.editWorkout),
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
                          Text(
                            intensity,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
    final difference = now.difference(date).inDays;

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

  void _showWorkoutDetail(BuildContext context, WorkoutHistoryDetail workout, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutDetailModal(workout: workout),
    );
  }

  void _editWorkout(BuildContext context, WorkoutHistoryDetail workout, AppLocalizations l10n) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutHistoryEditorEnhanced(
        historyWorkout: workout,
      ),
    );
  }

  void _deleteWorkout(BuildContext context, WorkoutHistoryDetail workout, AppLocalizations l10n) {
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

              final result = await ref.read(workoutHistoryOperationsProvider)
                  .deleteWorkout(workout.id);

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore: ${failure.message}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workoutDeletedSuccessfully)),
                  );
                },
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
  const _IntensityBar({
    required this.intensity,
    required this.colorScheme,
  });

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
