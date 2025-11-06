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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_history_editor_enhanced.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/history_view_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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
    final viewSettings = ref.watch(historyViewSettingsProvider).valueOrNull;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.workoutDatabase),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBackIos),
          onPressed: () => context.pop(),
        ),
        actions: [
          // View Mode Toggle
          if (viewSettings != null)
            IconButton(
              icon: Icon(_getViewModeIcon(viewSettings.viewMode)),
              tooltip: _getViewModeTooltip(l10n, viewSettings.viewMode),
              onPressed: () {
                final nextMode = _getNextViewMode(viewSettings.viewMode);
                ref.read(historyViewSettingsProvider.notifier).changeViewMode(nextMode);
                HapticFeedback.lightImpact();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.viewMode}: ${_getViewModeName(l10n, nextMode)}'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(_isSearchActive ? AppIcons.close : AppIcons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<WorkoutSortOption>(
            icon: const Icon(AppIcons.sort),
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
          IconButton(
            icon: Icon(
              syncStatus == SyncStatus.syncing ? AppIcons.syncIcon : AppIcons.refresh,
              color: syncStatus == SyncStatus.syncing ? colorScheme.primary : null,
            ),
            onPressed: syncStatus == SyncStatus.syncing ? null : () {
              ref.read(workoutHistoryOperationsProvider).forceSync();
            },
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
                loading: () => _buildLoadingState(l10n, colorScheme),
                error: (error, stack) => _buildErrorState(l10n, colorScheme, error),
                data: (workouts) => filteredWorkouts.isEmpty
                    ? _buildEmptyState(context, l10n, colorScheme)
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: TextField(
            controller: _searchFieldController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchWorkouts,
              prefixIcon: Icon(
                AppIcons.search,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        AppIcons.clear,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
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
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, ColorScheme colorScheme) {
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
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, ColorScheme colorScheme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingWorkouts,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.history,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nessun allenamento trovato per "$_searchQuery"'
                  : l10n.noWorkoutsInHistory,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Prova con altri termini di ricerca'
                  : l10n.startTrackingWorkouts,
              style: TextStyle(
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
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showWorkoutDetail(context, workout, l10n),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with date and actions
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        colorScheme.primary.withValues(alpha: 0.8),
                                        colorScheme.secondary.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    AppIcons.workout,
                                    color: colorScheme.onPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(workout.completedAt),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    AppIcons.moreVert,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
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
                                          Icon(AppIcons.edit, size: 20, color: colorScheme.primary),
                                          const SizedBox(width: 12),
                                          Text(l10n.editWorkout),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(AppIcons.delete, size: 20, color: colorScheme.error),
                                          const SizedBox(width: 12),
                                          Text(l10n.deleteWorkout),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Stats Row
                            Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    icon: AppIcons.schedule,
                                    label: l10n.duration,
                                    value: _formatDuration(workout.duration),
                                    color: colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatItem(
                                    icon: AppIcons.workout,
                                    label: l10n.totalVolume,
                                    value: '${workout.totalVolume.toInt()}kg',
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatItem(
                                    icon: AppIcons.list,
                                    label: 'Esercizi',
                                    value: '${workout.exercises.length}',
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Exercise preview
                            Text(
                              'Esercizi: ${workout.exercises.map((e) => e.name).join(', ')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Oggi, ${DateFormat('HH:mm').format(date)}';
    } else if (difference == 1) {
      return 'Ieri, ${DateFormat('HH:mm').format(date)}';
    } else if (difference < 7) {
      return '$difference giorni fa';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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

  // View Mode helpers
  IconData _getViewModeIcon(HistoryViewMode mode) {
    switch (mode) {
      case HistoryViewMode.list:
        return AppIcons.viewList;
      case HistoryViewMode.compact:
        return AppIcons.viewAgenda;
      case HistoryViewMode.calendar:
        return AppIcons.calendarMonth;
      case HistoryViewMode.stats:
        return AppIcons.barChart;
    }
  }

  String _getViewModeTooltip(AppLocalizations l10n, HistoryViewMode mode) {
    switch (mode) {
      case HistoryViewMode.list:
        return l10n.viewModeList;
      case HistoryViewMode.compact:
        return l10n.viewModeCompact;
      case HistoryViewMode.calendar:
        return l10n.viewModeCalendar;
      case HistoryViewMode.stats:
        return l10n.viewModeStats;
    }
  }

  String _getViewModeName(AppLocalizations l10n, HistoryViewMode mode) {
    switch (mode) {
      case HistoryViewMode.list:
        return l10n.viewModeList;
      case HistoryViewMode.compact:
        return l10n.viewModeCompact;
      case HistoryViewMode.calendar:
        return l10n.viewModeCalendar;
      case HistoryViewMode.stats:
        return l10n.viewModeStats;
    }
  }

  HistoryViewMode _getNextViewMode(HistoryViewMode current) {
    switch (current) {
      case HistoryViewMode.list:
        return HistoryViewMode.compact;
      case HistoryViewMode.compact:
        return HistoryViewMode.calendar;
      case HistoryViewMode.calendar:
        return HistoryViewMode.stats;
      case HistoryViewMode.stats:
        return HistoryViewMode.list;
    }
  }
}

class _StatItem extends StatelessWidget {

  const _StatItem({
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WorkoutDetailModal extends StatelessWidget {

  const WorkoutDetailModal({
    super.key,
    required this.workout,
  });
  final WorkoutHistoryDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy - HH:mm').format(workout.completedAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(AppIcons.close),
                ),
              ],
            ),
          ),

          // Exercise Details
          Expanded(
            child: ListView.builder(
              key: PageStorageKey('workout_detail_exercises_${workout.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...exercise.sets.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.value.setNumber}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value.weight.toInt()}kg × ${entry.value.reps} reps',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRPEColor(entry.value.rpe, colorScheme),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'RPE ${entry.value.rpe}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRPEColor(int rpe, ColorScheme colorScheme) {
    if (rpe <= 6) {
      return colorScheme.tertiary.withValues(alpha: 0.2);
    } else if (rpe <= 8) {
      return colorScheme.secondary.withValues(alpha: 0.2);
    } else {
      return colorScheme.error.withValues(alpha: 0.2);
    }
  }
}

